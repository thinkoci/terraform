resource "oci_core_vcn" "demo_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "thinkoci-vcn"
  dns_label      = "thinkocivcn"
}

