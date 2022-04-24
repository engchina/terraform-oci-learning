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
  default = "1"
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

variable "volume_size" {
  default = "50" # size in GBs
}

variable "ssh_config_file" {
  description = "SSH Private Key Path"
  default     = "./ssh-config/ssh-config.tpl"
}

variable "destination_ssh_username" {
  description = "SSH Username"
  default     = "opc"
}

variable "playbook_path" {
  description = "httpd ansible playbook path"
  default     = "./httpd/httpd-install.yaml"
}