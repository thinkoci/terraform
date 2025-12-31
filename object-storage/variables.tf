variable "compartment_ocid" {
  description = "Compartment OCID where bucket will be created"
  type        = string
}

variable "bucket_name" {
  description = "Object Storage bucket name"
  type        = string
}

variable "namespace" {
  description = "OCI Object Storage namespace"
  type        = string
}