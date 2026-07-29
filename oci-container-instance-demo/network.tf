resource "oci_core_vcn" "app" {
  compartment_id = local.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-vcn"
  dns_label      = "cidemo"
  freeform_tags  = local.common_tags
}

resource "oci_core_internet_gateway" "app" {
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.app.id
  display_name   = "${var.project_name}-internet-gateway"
  enabled        = true
  freeform_tags  = local.common_tags
}

resource "oci_core_route_table" "public" {
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.app.id
  display_name   = "${var.project_name}-public-routes"
  freeform_tags  = local.common_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.app.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.app.id
  display_name   = "${var.project_name}-public-security-list"
  freeform_tags  = local.common_tags

  ingress_security_rules {
    protocol    = "6"
    source      = var.allowed_cidr
    source_type = "CIDR_BLOCK"
    description = "Public HTTP access to the demo application"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allows path-MTU discovery responses, which OCI recommends for public subnets.
  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "ICMP fragmentation-needed messages"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow outbound access for public image pulls and responses"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = local.compartment_ocid
  vcn_id                     = oci_core_vcn.app.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "${var.project_name}-public-subnet"
  dns_label                  = "public"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
  freeform_tags              = local.common_tags
}
