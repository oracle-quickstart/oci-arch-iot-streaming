## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_database_autonomous_database" "ATPdatabase" {
  admin_password           = var.atp_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.ATP_database_cpu_core_count
  data_storage_size_in_tbs = var.ATP_database_data_storage_size_in_tbs
  db_name                  = var.ATP_database_db_name
  db_version               = var.ATP_database_db_version
  display_name             = var.ATP_database_display_name
  freeform_tags            = var.ATP_database_freeform_tags
  license_model            = var.ATP_database_license_model
  nsg_ids                  = var.ATP_private_endpoint ? [oci_core_network_security_group.ATP_nsg.id] : null   
  private_endpoint_label   = var.ATP_private_endpoint ? var.ATP_database_atp_private_endpoint_label : null 
  subnet_id                = var.ATP_private_endpoint ? oci_core_subnet.ATPsubnet.id : null      
  defined_tags             = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }  
}

resource "random_password" "wallet_password" {
  length  = 16
  special = true
}

resource "oci_database_autonomous_database_wallet" "ATP_database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.ATPdatabase.id
  password               = random_password.wallet_password.result
  base64_encode_content  = "true"
}
