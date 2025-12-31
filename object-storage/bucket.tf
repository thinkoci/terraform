resource "oci_objectstorage_bucket" "private_bucket" {
  compartment_id = var.compartment_ocid
  name           = var.bucket_name
  namespace      = var.namespace

  access_type  = "NoPublicAccess"
  storage_tier = "Standard"
}