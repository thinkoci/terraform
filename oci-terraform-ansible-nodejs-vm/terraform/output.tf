output "vm_public_ip" {
  value = oci_core_instance.ubuntu_public_vm.public_ip
}