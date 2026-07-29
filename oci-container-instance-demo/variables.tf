variable "oci_profile" {
  description = "Profile name from ~/.oci/config."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = length(trimspace(var.oci_profile)) > 0
    error_message = "oci_profile must not be empty."
  }
}

variable "compartment_ocid" {
  description = "Compartment OCID for all resources. If null, the tenancy OCID from ~/.oci/config is used."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = var.compartment_ocid == null || can(regex(
      "^ocid1\\.(compartment|tenancy)\\.",
      var.compartment_ocid
    ))
    error_message = "compartment_ocid must be a compartment or tenancy OCID, or null."
  }
}

variable "project_name" {
  description = "Name prefix used for OCI resources and tags."
  type        = string
  default     = "oci-ci-demo"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{2,39}$", var.project_name))
    error_message = "project_name must start with a letter and contain 3-40 letters, numbers, or hyphens."
  }
}

variable "availability_domain_index" {
  description = "Zero-based index of the availability domain in the configured OCI region."
  type        = number
  default     = 0

  validation {
    condition     = var.availability_domain_index >= 0 && floor(var.availability_domain_index) == var.availability_domain_index
    error_message = "availability_domain_index must be a non-negative integer."
  }
}

variable "container_instance_shape" {
  description = "OCI Container Instances shape. Change this if the default shape is unavailable in your region."
  type        = string
  default     = "CI.Standard.E4.Flex"
}

variable "ocpus" {
  description = "OCPUs allocated to the container instance."
  type        = number
  default     = 1

  validation {
    condition     = var.ocpus >= 1
    error_message = "ocpus must be at least 1."
  }
}

variable "memory_in_gbs" {
  description = "Memory in GB allocated to the container instance."
  type        = number
  default     = 2

  validation {
    condition     = var.memory_in_gbs >= 1
    error_message = "memory_in_gbs must be at least 1."
  }
}

variable "vcn_cidr" {
  description = "CIDR block for the demo VCN."
  type        = string
  default     = "10.42.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vcn_cidr))
    error_message = "vcn_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.42.0.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_cidr))
    error_message = "public_subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "allowed_cidr" {
  description = "IPv4 CIDR allowed to reach the public HTTP endpoint on port 80. Use your public IP/32 for tighter access."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.allowed_cidr))
    error_message = "allowed_cidr must be a valid IPv4 CIDR block."
  }
}

variable "frontend_image" {
  description = "Public Nginx image used for the frontend and reverse proxy."
  type        = string
  default     = "docker.io/library/nginx:1.30.4-alpine"
}

variable "backend_image" {
  description = "Public Python image used for the backend API."
  type        = string
  default     = "docker.io/library/python:3.12-alpine"
}
