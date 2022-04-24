resource "random_pet" "name" {}

resource "oci_core_instance" "tf_example_instance" {
  count               = var.num_instances
  availability_domain = data.oci_identity_availability_domain.tf_example_ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "TfExample${random_pet.name.id}${count.index}"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.tf_example_subnet.id
    display_name              = "Primaryvnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "tfexampleinstance${count.index}"
  }

  source_details {
    source_type             = "image"
    # Examples
    # source_id = var.flex_instance_image_ocid[var.region]
    source_id               = data.oci_core_images.tf_example_supported_platform_config_shape_images.images[0]["id"]
    # Apply this to set the size of the boot volume that is created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    boot_volume_size_in_gbs = var.volume_size
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata     = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("./userdata/bootstrap"))
  }
  defined_tags = {
    "${oci_identity_tag_namespace.tf_example_tag_namespace1.name}.${oci_identity_tag.tf_example_tag2.name}" = "tf-example-app-server"
  }

  freeform_tags = {
    "freeformkey${count.index}" = "tf-example-freeform-value${count.index}"
  }

  preemptible_instance_config {
    preemption_action {
      type                 = "TERMINATE"
      preserve_boot_volume = false
    }
  }

  timeouts {
    create = "60m"
  }
}

resource "local_file" "private_key_file" {
  content  = var.ssh_private_key
  filename = "${path.module}/id_rsa"
  file_permission = "400"
}

# Define the volumes that are attached to the compute instances.
resource "oci_core_volume" "tf_example_block_volume" {
  count               = var.num_instances * var.num_iscsi_volumes_per_instance
  availability_domain = data.oci_identity_availability_domain.tf_example_ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "TfExampleBlock${count.index}"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "tf_example_block_attach" {
  count           = var.num_instances * var.num_iscsi_volumes_per_instance
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.tf_example_instance[floor(count.index / var.num_iscsi_volumes_per_instance)].id
  volume_id       = oci_core_volume.tf_example_block_volume[count.index].id
  device          = count.index == 0 ? "/dev/oracleoci/oraclevdb" : ""

  # Set this to enable CHAP authentication for an ISCSI volume attachment. The oci_core_volume_attachment resource will
  # contain the CHAP authentication details via the "chap_secret" and "chap_username" attributes.
  use_chap = true
  # Set this to attach the volume as read-only.
  #is_read_only = true
}

resource "oci_core_volume" "tf_example_block_volume_paravirtualized" {
  count               = var.num_instances * var.num_paravirtualized_volumes_per_instance
  availability_domain = data.oci_identity_availability_domain.tf_example_ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "TestBlockParavirtualized${count.index}"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "tf_example_block_volume_attach_paravirtualized" {
  count           = var.num_instances * var.num_paravirtualized_volumes_per_instance
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf_example_instance[floor(count.index / var.num_paravirtualized_volumes_per_instance)].id
  volume_id       = oci_core_volume.tf_example_block_volume_paravirtualized[count.index].id
  # Set this to attach the volume as read-only.
  #is_read_only = true
}

resource "oci_core_volume_backup_policy_assignment" "tf_example_policy" {
  count     = var.num_instances
  asset_id  = oci_core_instance.tf_example_instance[count.index].boot_volume_id
  policy_id = data.oci_core_volume_backup_policies.tf_example_predefined_volume_backup_policies.volume_backup_policies[0].id
}

resource "null_resource" "remote-exec" {
  depends_on = [
    oci_core_instance.tf_example_instance,
    oci_core_volume_attachment.tf_example_block_attach,
  ]
  count      = var.num_instances * var.num_iscsi_volumes_per_instance

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = oci_core_instance.tf_example_instance[count.index % var.num_instances].public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }

    inline = [
      "touch ~/IMadeAFile.Right.Here",
      "sudo iscsiadm -m node -o new -T ${oci_core_volume_attachment.tf_example_block_attach[count.index].iqn} -p ${oci_core_volume_attachment.tf_example_block_attach[count.index].ipv4}:${oci_core_volume_attachment.tf_example_block_attach[count.index].port}",
      "sudo iscsiadm -m node -o update -T ${oci_core_volume_attachment.tf_example_block_attach[count.index].iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.tf_example_block_attach[count.index].iqn} -p ${oci_core_volume_attachment.tf_example_block_attach[count.index].ipv4}:${oci_core_volume_attachment.tf_example_block_attach[count.index].port} -o update -n node.session.auth.authmethod -v CHAP",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.tf_example_block_attach[count.index].iqn} -p ${oci_core_volume_attachment.tf_example_block_attach[count.index].ipv4}:${oci_core_volume_attachment.tf_example_block_attach[count.index].port} -o update -n node.session.auth.username -v ${oci_core_volume_attachment.tf_example_block_attach[count.index].chap_username}",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.tf_example_block_attach[count.index].iqn} -p ${oci_core_volume_attachment.tf_example_block_attach[count.index].ipv4}:${oci_core_volume_attachment.tf_example_block_attach[count.index].port} -o update -n node.session.auth.password -v ${oci_core_volume_attachment.tf_example_block_attach[count.index].chap_secret}",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.tf_example_block_attach[count.index].iqn} -p ${oci_core_volume_attachment.tf_example_block_attach[count.index].ipv4}:${oci_core_volume_attachment.tf_example_block_attach[count.index].port} -l",
    ]
  }
}