## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "atp_password" {}
variable "atp_admin_password" {}
variable "availablity_domain_name" {}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0"
}

variable "oracle_instant_client_version" {
  default     = "21.1"
}

variable "oracle_instant_client_version_short" {
  default     = "21"
}

variable "atp_admin_user" {
 default = "admin"
}

variable "atp_user" {
 default = "iotuser"
}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "websubnet-CIDR" {
  default = "10.0.1.0/24"
}

variable "ATPsubnet-CIDR" {
  default = "10.0.2.0/24"
}

variable "VCNname" {
  default = "VCN"
}

variable "httpx_ports" {
  type = list(string)
  default = ["80","443"]
}

variable "Shape" {
   default = "VM.Standard.E3.Flex"
}

variable "Shape_flex_ocpus" {
    default = 1
}

variable "Shape_flex_memory" {
    default = 10
}

variable "ssh_public_key" {
  default = ""
}

variable "ATP_private_endpoint" {
  default = true
}

variable "ATP_database_cpu_core_count" {
  default = 1
}

variable "ATP_database_data_storage_size_in_tbs" {
  default = 1
}

variable "ATP_database_db_name" {
  default = "iotpdb"
}

variable "ATP_database_db_version" {
  default = "19c"
}

variable "ATP_database_defined_tags_value" {
  default = ""
}

variable "ATP_database_display_name" {
  default = "ATP"
}

variable "ATP_database_freeform_tags" {
  default = {
    "Owner" = ""
  }
}

variable "ATP_database_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "ATP_tde_wallet_zip_file" {
  default = "tde_wallet.zip"
}

variable "ATP_database_atp_private_endpoint_label" {
  default = "ATPPrivateEndpoint"
}

#variable "ocir_namespace" {
#  default = ""
#}

variable "ocir_repo_name" {
  default = "iotfunctions"
}

#variable "ocir_docker_repository" {
#  default = ""
#}

variable "ocir_user_name" {
  default = ""
}

variable "ocir_user_password" {
  default = ""
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
#  default     = "8"
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.Shape)
}

# OCIR repo name & namespace

locals {
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key" )), ".ocir.io"])
  ocir_namespace = lookup(data.oci_identity_tenancy.oci_tenancy, "name" )
}

