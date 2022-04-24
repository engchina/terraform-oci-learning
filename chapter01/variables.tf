variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
}

# Defines the number of instances to deploy
variable "num_instances" {
  default = "3"
}

# Defines the number of volumes to create and attach to each instance
# NOTE: Changing this value after applying it could result in re-attaching existing volumes to different instances.
# This is a result of using 'count' variables to specify the volume and instance IDs for the volume attachment resource.
variable "num_iscsi_volumes_per_instance" {
  default = "1"
}

variable "num_paravirtualized_volumes_per_instance" {
  default = "2"
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "instance_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  default = 1
}

variable "instance_shape_config_memory_in_gbs" {
  default = 1
}

variable "instance_image_ocid" {
  type = map(string)

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-provided image "Oracle-Linux-7.9-2022.04.04-0"
    ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaazuiu6ap7pgeizjf2egwz4wde7lounvjgq5aayolwmeauanbqkv6q"
    # Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaoqj42sokaoh42l76wsyhn3k2beuntrh5maj3gmgmzeyr55zzrwwa"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaitzn6tdyjer7jl34h2ujz74jwy5nkbukbh55ekp6oyzwrtfa4zma"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa32voyikkkzfxyo4xbdmadc2dmvorfxxgdhpnk6dw64fa3l4jh7wa"
  }
}

variable "flex_instance_image_ocid" {
  type    = map(string)
  default = {
    ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaazuiu6ap7pgeizjf2egwz4wde7lounvjgq5aayolwmeauanbqkv6q"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaa6hooptnlbfwr5lwemqjbu3uqidntrlhnt45yihfj222zahe7p3wq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvt4jz4vc47qoc2ec4anha"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaadvi77prh3vjijhwe5xbd6kjg3n5ndxjcpod6om6qaiqeu3csof7a"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaw5gvriwzjhzt2tnylrfnpanz5ndztyrv3zpwhlzxdbkqsjfkwxaq"
  }
}

variable "volume_size" {
  default = "50" # size in GBs
}

variable "tag_namespace_description" {
  default = "TfExamplesTagNamespace"
}

variable "tag_namespace_name" {
  default = "tf_example_tag_namespace"
}