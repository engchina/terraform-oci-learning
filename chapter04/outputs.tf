# Output the private and public IPs of the instance

output "tf_example_instance_private_ips" {
  value = [oci_core_instance.tf_example_instance.*.private_ip]
}

output "tf_example_instance_public_ips" {
  value = [oci_core_instance.tf_example_instance.*.public_ip]
}

output "tf_example_ssh_to_instance" {
  value = {for i in range(var.num_instances) : i => "ssh -i id_rsa -o ServerAliveInterval=10 opc@${oci_core_instance.tf_example_instance[i].public_ip}"}
}

output "tf_example_application_url" {
  value = {for i in range(var.num_instances) : i => "http://${oci_core_instance.tf_example_instance[i].public_ip}/index.php"}
}

# Output the boot volume IDs of the instance
output "tf_example_boot_volume_ids" {
  value = [oci_core_instance.tf_example_instance.*.boot_volume_id]
}

output "tf_example_namespace" {
  value = data.oci_objectstorage_namespace.ns.namespace
}
