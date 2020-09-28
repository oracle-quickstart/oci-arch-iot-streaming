resource "oci_core_virtual_network" "vcn" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "vcn"
  compartment_id = var.compartment_ocid
  display_name   = "vcn"
}

resource "oci_core_internet_gateway" "igw" {
    compartment_id = var.compartment_ocid
    display_name   = "igw"
    vcn_id         = oci_core_virtual_network.vcn.id
}

/*
resource "oci_core_nat_gateway" "natgw" {
    compartment_id = var.compartment_ocid
    display_name   = "natgw"
    vcn_id         = oci_core_virtual_network.vcn.id
}
*/

resource "oci_core_route_table" "rt_transit_routing_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "rt_transit_routing_sgw"
}


resource "oci_core_service_gateway" "sgw" {
  #Required
  compartment_id = var.compartment_ocid

  services {
    service_id = data.oci_core_services.oci_services.services[0]["id"]
  }

  vcn_id = oci_core_virtual_network.vcn.id

  #Optional
  display_name   = "ServiceGateway"
  route_table_id = oci_core_route_table.rt_transit_routing_sgw.id
}

resource "oci_core_route_table" "rt_via_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "rt_via_sgw"

  route_rules {
    destination       = data.oci_core_services.oci_services.services[0]["cidr_block"]
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

resource "oci_core_route_table" "rt_via_igw" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.vcn.id
    display_name   = "rt_via_igw"
    route_rules {
        destination = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = oci_core_internet_gateway.igw.id
    }
}

/*
resource "oci_core_route_table" "rt_via_nat" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.vcn.id
    display_name   = "rt_via_nat"
    route_rules {
        destination = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = oci_core_nat_gateway.natgw.id
    }
}
*/

resource "oci_core_security_list" "seclist1" {
    compartment_id = var.compartment_ocid
    display_name   = "seclist1"
    vcn_id         = oci_core_virtual_network.vcn.id

    egress_security_rules {
        protocol = "6"
        destination = "0.0.0.0/0"
    }

    dynamic "ingress_security_rules" {
    for_each = var.httpx_ports
    content {
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = ingress_security_rules.value
            min = ingress_security_rules.value
            }
        }
    }

    ingress_security_rules {
        protocol = "6"
        source = var.VCN-CIDR
    }
}

resource "oci_core_dhcp_options" "dhcpoptions1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "dhcpoptions1"

  // required
  options {
    type = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type = "SearchDomain"
    search_domain_names = [ "example.com" ]
  }
}

resource "oci_core_subnet" "websubnet" {
  cidr_block        = var.websubnet-CIDR
  display_name      = "websubnet"
  dns_label         = "sub1"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  route_table_id    = oci_core_route_table.rt_via_igw.id
  dhcp_options_id   = oci_core_dhcp_options.dhcpoptions1.id
  security_list_ids = [oci_core_security_list.seclist1.id]
}

resource "oci_core_subnet" "ATPsubnet" {
  cidr_block                 = var.ATPsubnet-CIDR
  display_name               = "ATPSubnet"
  dns_label                  = "sub2"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  route_table_id             = oci_core_route_table.rt_via_igw.id
  dhcp_options_id            = oci_core_dhcp_options.dhcpoptions1.id
  prohibit_public_ip_on_vnic = true
}