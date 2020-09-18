resource "oci_core_network_security_group" "ATP_nsg" {
    compartment_id = var.compartment_ocid
    display_name   = "ATP_nsg"
    vcn_id         = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group" "web_nsg" {
    compartment_id = var.compartment_ocid
    display_name   = "web_nsg"
    vcn_id         = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group" "ssh_nsg" {
    compartment_id = var.compartment_ocid
    display_name   = "ssh_nsg"
    vcn_id         = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group_security_rule" "ATP_nsg_eagress_rule1" {
    network_security_group_id = oci_core_network_security_group.ATP_nsg.id
    direction = "EGRESS"
    protocol = "6"
    destination = var.VCN-CIDR
    destination_type = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "ATP_nsg_ingress_rule1" {
    network_security_group_id = oci_core_network_security_group.ATP_nsg.id
    direction = "INGRESS"
    protocol = "6"
    source = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}

resource "oci_core_network_security_group_security_rule" "web_nsg_egress_rule1" {
    network_security_group_id = oci_core_network_security_group.web_nsg.id
    direction = "EGRESS"
    protocol = "6"
    destination = oci_core_network_security_group.ATP_nsg.id
    destination_type = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "web_nsg_egress_rule2" {
    network_security_group_id = oci_core_network_security_group.web_nsg.id
    direction = "EGRESS"
    protocol = "6"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "web_nsg_ingress_rule1" {
    network_security_group_id = oci_core_network_security_group.web_nsg.id
    direction = "INGRESS"
    protocol = "6"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}

resource "oci_core_network_security_group_security_rule" "ssh_nsg_egress_rule1" {
    network_security_group_id = oci_core_network_security_group.ssh_nsg.id
    direction = "EGRESS"
    protocol = "6"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "ssh_nsg_ingress_rule1" {
    network_security_group_id = oci_core_network_security_group.ssh_nsg.id
    direction = "INGRESS"
    protocol = "6"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}