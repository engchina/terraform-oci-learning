# ------ Create SSH Config File
data "template_file" "ssh_userdata" {
  count    = var.num_instances
  template = file(var.ssh_config_file)
  vars     = {
    destination_public_ip = "${oci_core_instance.tf_example_instance[count.index].public_ip}"
    destination_ssh_user  = "${var.destination_ssh_username}"
    private_key_path      = "${local_file.private_key_file.filename}"
  }
}

# Get the latest Oracle Linux image
data "oci_core_images" "tf_example_supported_platform_config_shape_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.instance_shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}