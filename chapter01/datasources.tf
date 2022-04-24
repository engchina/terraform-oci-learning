/*
# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "tf_example_boot_volume_attachments" {
  depends_on          = [oci_core_instance.tf_example_instance]
  count               = var.num_instances
  availability_domain = oci_core_instance.tf_example_instance[count.index].availability_domain
  compartment_id      = var.compartment_ocid
  instance_id = oci_core_instance.tf_example_instance[count.index].id
}
*/

data "oci_core_instance_devices" "tf_example_instance_devices" {
  count       = var.num_instances
  instance_id = oci_core_instance.tf_example_instance[count.index].id
}

data "oci_core_volume_backup_policies" "tf_example_predefined_volume_backup_policies" {
  filter {
    name = "display_name"

    values = [
      "silver",
    ]
  }
}

data "oci_identity_availability_domain" "tf_example_ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

data "oci_identity_region_subscriptions" "tf_example_home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
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