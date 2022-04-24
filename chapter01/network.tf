locals {
  tcp_protocol   = "6"
  all_protocols  = "all"
  anywhere       = "0.0.0.0/0"
  vcn_cidr_block = "10.1.0.0/16"
}

resource "oci_core_vcn" "tf_example_vcn" {
  cidr_block     = local.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "TfExampleVcn"
  dns_label      = "tfexamplevcn"

  defined_tags = {
    "${oci_identity_tag_namespace.tf_example_tag_namespace1.name}.${oci_identity_tag.tf_example_tag1.name}" = "tf-example-vcn"
  }
}

resource "oci_core_internet_gateway" "tf_example_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "TfExampleInternetGateway"
  vcn_id         = oci_core_vcn.tf_example_vcn.id
}

resource "oci_core_default_route_table" "tf_example_route_table" {
  manage_default_resource_id = oci_core_vcn.tf_example_vcn.default_route_table_id
  display_name               = "TfExampleRouteTable"

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.tf_example_internet_gateway.id
  }
}

resource "oci_core_subnet" "tf_example_subnet" {
  availability_domain = data.oci_identity_availability_domain.tf_example_ad.name
  cidr_block          = "10.1.20.0/24"
  display_name        = "TfExampleSubnet"
  dns_label           = "tfexamplesubnet"
  security_list_ids   = [oci_core_vcn.tf_example_vcn.default_security_list_id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tf_example_vcn.id
  route_table_id      = oci_core_vcn.tf_example_vcn.default_route_table_id
  dhcp_options_id     = oci_core_vcn.tf_example_vcn.default_dhcp_options_id
}

resource "oci_core_security_list" "tf_example_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tf_example_vcn.id
  display_name   = "TfExampleSecurityList"

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      max = "80"
      min = "80"
    }
  }
}