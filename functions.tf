## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_functions_application" "Stream2ATPFnApp" {
  depends_on     = [oci_identity_policy.FunctionsServiceReposAccessPolicy,
                      oci_identity_policy.FunctionsDevelopersManageAccessPolicy,
                      oci_identity_policy.FunctionsDevelopersManageNetworkAccessPolicy,
                      oci_identity_policy.FunctionsServiceNetworkAccessPolicy,
                      oci_identity_dynamic_group.FunctionsServiceDynamicGroup,
                      oci_identity_policy.FunctionsServiceDynamicGroupPolicy]
  compartment_id = var.compartment_ocid
  display_name   = "Stream2ATPFnApp"
  subnet_ids     = [oci_core_subnet.websubnet.id]
  defined_tags   = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }  
}

resource "oci_functions_function" "UpdateSetupATPFn" {
  depends_on     = [null_resource.SetupATPFnPush2OCIR]
  application_id = oci_functions_application.Stream2ATPFnApp.id
  display_name   = "SetupATPFn"
  image          = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
  memory_in_mbs  = "256" 
  defined_tags   = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }  

  provisioner "local-exec" {
       command = "sleep 60"
  }
}

resource "oci_functions_invoke_function" "UpdateSetupATPFnInvoke" {
  depends_on = [oci_database_autonomous_database.ATPdatabase, oci_functions_function.UpdateSetupATPFn]
  function_id = oci_functions_function.UpdateSetupATPFn.id
}

resource "oci_functions_function" "Stream2ATPFn" {
  depends_on     = [null_resource.Stream2ATPFnPush2OCIR, oci_functions_function.UpdateSetupATPFn]
  application_id = oci_functions_application.Stream2ATPFnApp.id
  display_name   = "Stream2ATPFn"
  image          = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
  memory_in_mbs  = "256" 
  defined_tags   = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }  
}

resource "oci_functions_application" "Upload2StreamFnApp" {
  depends_on     = [oci_identity_policy.FunctionsServiceReposAccessPolicy,
                    oci_identity_policy.FunctionsDevelopersManageAccessPolicy,
                    oci_identity_policy.FunctionsDevelopersManageNetworkAccessPolicy,
                    oci_identity_policy.FunctionsServiceNetworkAccessPolicy,
                    oci_identity_dynamic_group.FunctionsServiceDynamicGroup,
                    oci_identity_policy.FunctionsServiceDynamicGroupPolicy]
  compartment_id = var.compartment_ocid
  display_name   = "Upload2StreamFnApp"
  subnet_ids     = [oci_core_subnet.websubnet.id]
  defined_tags   = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }  
}

resource "oci_functions_function" "Upload2StreamFn" {
  depends_on      = [null_resource.Upload2StreamFnPush2OCIR]
  application_id  = oci_functions_application.Upload2StreamFnApp.id
  display_name    = "Upload2StreamFn"
  image           = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
  memory_in_mbs   = "256" 
  defined_tags    = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }  
}

