resource "oci_container_instances_container_instance" "app" {
  availability_domain = data.oci_identity_availability_domains.available.availability_domains[var.availability_domain_index].name
  compartment_id      = local.compartment_ocid
  display_name        = "${var.project_name}-instance"
  shape               = var.container_instance_shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  container_restart_policy             = "ALWAYS"
  graceful_shutdown_timeout_in_seconds = 30
  state                                = "ACTIVE"

  vnics {
    subnet_id              = oci_core_subnet.public.id
    display_name           = "${var.project_name}-vnic"
    hostname_label         = "app"
    is_public_ip_assigned  = true
    skip_source_dest_check = false
  }

  containers {
    display_name                   = "frontend"
    image_url                      = var.frontend_image
    command                        = ["/usr/sbin/nginx"]
    arguments                      = ["-g", "daemon off;"]
    is_resource_principal_disabled = true

    health_checks {
      health_check_type        = "HTTP"
      name                     = "frontend-http"
      path                     = "/healthz"
      port                     = 80
      failure_action           = "KILL"
      initial_delay_in_seconds = 10
      interval_in_seconds      = 30
      timeout_in_seconds       = 5
      failure_threshold        = 3
      success_threshold        = 1
    }

    volume_mounts {
      volume_name  = "frontend-static"
      mount_path   = "/usr/share/nginx/html"
      is_read_only = true
    }

    volume_mounts {
      volume_name  = "nginx-config"
      mount_path   = "/etc/nginx/conf.d"
      is_read_only = true
    }
  }

  containers {
    display_name                   = "backend"
    image_url                      = var.backend_image
    command                        = ["/usr/local/bin/python"]
    arguments                      = ["/app/app.py"]
    is_resource_principal_disabled = true

    environment_variables = {
      APP_NAME = var.project_name
      PORT     = "8080"
    }

    health_checks {
      health_check_type        = "HTTP"
      name                     = "backend-http"
      path                     = "/api/health"
      port                     = 8080
      failure_action           = "KILL"
      initial_delay_in_seconds = 10
      interval_in_seconds      = 30
      timeout_in_seconds       = 5
      failure_threshold        = 3
      success_threshold        = 1
    }

    volume_mounts {
      volume_name  = "backend-source"
      mount_path   = "/app"
      is_read_only = true
    }
  }

  volumes {
    name        = "frontend-static"
    volume_type = "CONFIGFILE"

    configs {
      file_name = "index.html"
      data      = filebase64("${path.module}/app/frontend/index.html")
    }

    configs {
      file_name = "app.js"
      data      = filebase64("${path.module}/app/frontend/app.js")
    }

    configs {
      file_name = "styles.css"
      data      = filebase64("${path.module}/app/frontend/styles.css")
    }
  }

  volumes {
    name        = "nginx-config"
    volume_type = "CONFIGFILE"

    configs {
      file_name = "default.conf"
      data      = filebase64("${path.module}/app/frontend/default.conf")
    }
  }

  volumes {
    name        = "backend-source"
    volume_type = "CONFIGFILE"

    configs {
      file_name = "app.py"
      data      = filebase64("${path.module}/app/backend/app.py")
    }
  }

  freeform_tags = merge(local.common_tags, {
    application-sha = local.application_sha
  })

  lifecycle {
    precondition {
      condition     = var.availability_domain_index < length(data.oci_identity_availability_domains.available.availability_domains)
      error_message = "availability_domain_index is outside the list of availability domains returned for the configured region."
    }

    precondition {
      condition     = var.container_instance_shape == "CI.Standard.E5.Flex" || var.memory_in_gbs >= var.ocpus
      error_message = "For CI.Standard.E4.Flex and CI.Standard.A1.Flex, memory_in_gbs must be at least the number of OCPUs."
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

data "oci_core_vnic" "app" {
  vnic_id = oci_container_instances_container_instance.app.vnics[0].vnic_id
}
