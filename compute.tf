resource "oci_core_instance" "webserver" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "webserver"
  shape               = var.Shapes[0]
  subnet_id           = oci_core_subnet.websubnet.id
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImageLocal.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = var.public_key_oci
  }
  create_vnic_details {
    subnet_id = oci_core_subnet.websubnet.id
    nsg_ids   = [oci_core_network_security_group.web_nsg.id, oci_core_network_security_group.ssh_nsg.id]
  }
}
