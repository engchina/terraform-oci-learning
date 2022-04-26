resource "random_id" "tag" {
  byte_length = 2
}

resource "oci_identity_tag_namespace" "tf_example_tag_namespace1" {
  provider = oci.homeregion
  #Required
  compartment_id = var.tenancy_ocid
  description    = var.tag_namespace_description
  name           = "${var.tag_namespace_name}_${random_id.tag.hex}"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "oci_identity_tag" "tf_example_tag1" {
  provider = oci.homeregion
  #Required
  description      = "TfExampleTag1"
  name             = "tf_example_tag_1"
  tag_namespace_id = oci_identity_tag_namespace.tf_example_tag_namespace1.id

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "oci_identity_tag" "tf_example_tag2" {
  provider = oci.homeregion
  #Required
  description      = "TfExampleTag2"
  name             = "tf_example_tag_2"
  tag_namespace_id = oci_identity_tag_namespace.tf_example_tag_namespace1.id

  provisioner "local-exec" {
    command = "sleep 120"
  }
}