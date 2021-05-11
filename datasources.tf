## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.Shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data "oci_identity_regions" "oci_regions" {
  
  filter {
    name = "name" 
    values = [var.region]
  }

}

data "oci_identity_tenancy" "oci_tenancy" {
    tenancy_id = var.tenancy_ocid
}

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
    tenancy_id = var.tenancy_ocid

    filter {
      name   = "is_home_region"
      values = [true]
    }
}

data "oci_core_vnic_attachments" "webserver_VNIC1_attach" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.webserver.id
}

data "oci_core_vnic" "webserver_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.webserver_VNIC1_attach.vnic_attachments.0.vnic_id
}

data "oci_apigateway_deployment" "apigateway_deployment" {
    deployment_id = oci_apigateway_deployment.apigateway_deployment.id
}

data "oci_streaming_stream_pool" "streamPool" {
    stream_pool_id = oci_streaming_stream_pool.streamPool.id
}

data "oci_database_autonomous_databases" "ATPdatabases" {
  compartment_id = var.compartment_ocid
  display_name = var.ATP_database_display_name
}

data "oci_core_services" "oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_core_service_gateways" "sgws" {
  compartment_id = var.compartment_ocid
  state  = "AVAILABLE"
  vcn_id = oci_core_virtual_network.vcn.id
}