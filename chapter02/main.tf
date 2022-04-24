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

resource "null_resource" "remote-exec" {
  depends_on = [
    oci_core_instance.tf_example_instance,
  ]
  count      = var.num_instances

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = oci_core_instance.tf_example_instance[count.index].public_ip
      user        = "opc"
      private_key = var.ssh_private_key
    }

    inline = [
      "echo hello",
    ]
  }
}