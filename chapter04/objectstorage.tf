resource "oci_objectstorage_bucket" "tf_example_bucket" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "TfExampleBucket"
  access_type    = "NoPublicAccess"
  auto_tiering   = "Disabled"
}