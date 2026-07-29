locals {
  tenancy_ocid      = data.external.oci_config.result.tenancy
  configured_region = data.external.oci_config.result.region
  compartment_ocid  = coalesce(var.compartment_ocid, local.tenancy_ocid)

  common_tags = {
    project    = var.project_name
    managed-by = "terraform"
    workload   = "oci-container-instance-demo"
  }

  application_files = [
    "${path.module}/app/frontend/index.html",
    "${path.module}/app/frontend/app.js",
    "${path.module}/app/frontend/styles.css",
    "${path.module}/app/frontend/default.conf",
    "${path.module}/app/backend/app.py"
  ]

  application_sha = substr(sha256(join("", [for filename in local.application_files : filesha256(filename)])), 0, 12)
}
