resource "null_resource" "run_ansible" {

  depends_on = [oci_core_instance.ubuntu_public_vm]

  provisioner "local-exec" {
    command = <<EOT
      echo "[web]" > ../ansible/hosts.ini
      echo "${oci_core_instance.ubuntu_public_vm.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/ubuntu_vm_key.pem" >> ../ansible/hosts.ini

      echo "Waiting for SSH to be ready..."
      sleep 90

      cd ../ansible
      ansible-playbook playbooks/site.yml
    EOT
  }
}
