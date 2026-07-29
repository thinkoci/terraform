data "oci_identity_availability_domains" "available" {
  compartment_id = local.tenancy_ocid
}
