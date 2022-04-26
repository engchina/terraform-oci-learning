data "oci_identity_availability_domain" "tf_example_ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}