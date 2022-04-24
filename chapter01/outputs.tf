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

# Output all the devices for all instances
output "tf_example_instance_devices" {
  value = [data.oci_core_instance_devices.tf_example_instance_devices.*.devices]
}

# Output the chap secret information for ISCSI volume attachments. This can be used to output
# CHAP information for ISCSI volume attachments that have "use_chap" set to true.
#output "IscsiVolumeAttachmentChapUsernames" {
#  value = [oci_core_volume_attachment.test_block_attach.*.chap_username]
#}
#
#output "IscsiVolumeAttachmentChapSecrets" {
#  value = [oci_core_volume_attachment.test_block_attach.*.chap_secret]
#}

output "tf_example_silver_policy_id" {
  value = data.oci_core_volume_backup_policies.tf_example_predefined_volume_backup_policies.volume_backup_policies[0].id
}

/*
output "tf_example_attachment_instance_id" {
  value = data.oci_core_boot_volume_attachments.test_boot_volume_attachments.*.instance_id
}
*/
