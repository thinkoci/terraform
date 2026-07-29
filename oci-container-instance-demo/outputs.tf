output "tenancy_ocid_from_local_config" {
  description = "Tenancy OCID read from the selected ~/.oci/config profile."
  value       = local.tenancy_ocid
}

output "configured_region" {
  description = "OCI region read from the selected ~/.oci/config profile."
  value       = local.configured_region
}

output "compartment_ocid" {
  description = "Compartment used for the deployment."
  value       = local.compartment_ocid
}

output "availability_domain" {
  description = "Availability domain used by the container instance."
  value       = oci_container_instances_container_instance.app.availability_domain
}

output "container_instance_id" {
  description = "OCID of the OCI Container Instance."
  value       = oci_container_instances_container_instance.app.id
}

output "container_ids" {
  description = "Container names and OCIDs, useful for OCI CLI log retrieval."
  value = {
    for container in oci_container_instances_container_instance.app.containers :
    container.display_name => container.container_id
  }
}

output "public_ip" {
  description = "Ephemeral public IP assigned to the container instance VNIC."
  value       = data.oci_core_vnic.app.public_ip_address
}

output "app_url" {
  description = "Public frontend URL."
  value       = "http://${data.oci_core_vnic.app.public_ip_address}"
}

output "api_health_url" {
  description = "Backend health endpoint exposed through Nginx."
  value       = "http://${data.oci_core_vnic.app.public_ip_address}/api/health"
}

output "api_message_url" {
  description = "Backend sample endpoint exposed through Nginx."
  value       = "http://${data.oci_core_vnic.app.public_ip_address}/api/message"
}
