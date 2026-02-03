variable "region" {
  default = "ap-mumbai-1"
}

variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "ssh_public_key_path" {
  default = "./ol9_vm_key.pub"
}

