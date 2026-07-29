provider "oci" {
  # The OCI provider reads credentials and region from ~/.oci/config.
  # Use oci_profile to select a profile other than DEFAULT.
  config_file_profile = var.oci_profile
}

data "external" "oci_config" {
  program = ["python3", "${path.module}/scripts/read_oci_config.py"]

  query = {
    config_file = pathexpand("~/.oci/config")
    profile     = var.oci_profile
  }
}
