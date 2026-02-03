# ------------------------------------------------
# SSH Key Generation
# ------------------------------------------------

resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.vm_ssh_key.private_key_pem
  filename        = "${path.module}/ubuntu_vm_key.pem"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content  = tls_private_key.vm_ssh_key.public_key_openssh
  filename = "${path.module}/ubuntu_vm_key.pub"
}
