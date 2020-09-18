variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "atp_password" {}
variable "atp_admin_password" {}
variable "private_key_oci" {}
variable "public_key_oci" {}

variable "OsImage" {
  default = "Oracle-Linux-7.8-2020.05.26-0"
}

variable "atp_admin_user" {
 default = "admin"
}

variable "atp_user" {
 default = "fkuser"
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
  default = ["80", "443"]
}

variable "Shapes" {
 default = ["VM.Standard2.1"]
}

variable "ATP_database_cpu_core_count" {
  default = 1
}

variable "ATP_database_data_storage_size_in_tbs" {
  default = 1
}

variable "ATP_database_db_name" {
  default = "fkatpdb5"
}

variable "ATP_database_db_version" {
  default = "18c"
}

variable "ATP_database_defined_tags_value" {
  default = "value"
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

variable "ocir_namespace" {
  default = ""
}

variable "ocir_repo_name" {
  default = ""
}

variable "ocir_docker_repository" {
  default = ""
}

variable "ocir_user_name" {
  default = ""
}

variable "ocir_user_password" {
  default = ""
}