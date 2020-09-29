## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Functions Policies

resource "oci_identity_policy" "FunctionsServiceReposAccessPolicy" {
  name = "FunctionsServiceReposAccessPolicy"
  description = "FunctionsServiceReposAccessPolicy"
  compartment_id = var.tenancy_ocid
  statements = ["Allow service FaaS to read repos in tenancy"]
}

resource "oci_identity_policy" "FunctionsDevelopersManageAccessPolicy" {
  name = "FunctionsDevelopersManageAccessPolicy"
  description = "FunctionsDevelopersManageAccessPolicy"
  compartment_id = var.compartment_ocid
  statements = ["Allow group Administrators to manage functions-family in compartment id ${var.compartment_ocid}",
                "Allow group Administrators to read metrics in compartment id ${var.compartment_ocid}"]
}

resource "oci_identity_policy" "FunctionsDevelopersManageNetworkAccessPolicy" {
  name = "FunctionsDevelopersManageNetworkAccessPolicy"
  description = "FunctionsDevelopersManageNetworkAccessPolicy"
  compartment_id = var.compartment_ocid
  statements = ["Allow group Administrators to use virtual-network-family in compartment id ${var.compartment_ocid}"]
}

resource "oci_identity_policy" "FunctionsServiceNetworkAccessPolicy" {
  name = "FunctionsServiceNetworkAccessPolicy"
  description = "FunctionsServiceNetworkAccessPolicy"
  compartment_id = var.tenancy_ocid
  statements = ["Allow service FaaS to use virtual-network-family in compartment id ${var.compartment_ocid}"]
}

resource "oci_identity_dynamic_group" "FunctionsServiceDynamicGroup" {
    name = "FunctionsServiceDynamicGroup"
    description = "FunctionsServiceDynamicGroup"
    compartment_id = var.tenancy_ocid
    matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_identity_policy" "FunctionsServiceDynamicGroupPolicy" {
  depends_on = [oci_identity_dynamic_group.FunctionsServiceDynamicGroup]
  name = "FunctionsServiceDynamicGroupPolicy"
  description = "FunctionsServiceDynamicGroupPolicy"
  compartment_id = var.compartment_ocid
  statements = ["allow dynamic-group ${oci_identity_dynamic_group.FunctionsServiceDynamicGroup.name} to manage all-resources in compartment id ${var.compartment_ocid}"]
}

# API GW Policies

resource "oci_identity_policy" "ManageAPIGWFamilyPolicy" {
  name = "ManageAPIGWFamilyPolicy"
  description = "ManageAPIGWFamilyPolicy"
  compartment_id = var.compartment_ocid
  statements = ["Allow group Administrators to manage api-gateway-family in compartment id ${var.compartment_ocid}"]
}

resource "oci_identity_policy" "ManageVCNFamilyPolicy" {
  name = "ManageVCNFamilyPolicy"
  description = "ManageVCNFamilyPolicy"
  compartment_id = var.compartment_ocid
  statements = ["Allow group Administrators to manage virtual-network-family in compartment id ${var.compartment_ocid}"]
}

resource "oci_identity_policy" "UseFnFamilyPolicy" {
  name = "UseFnFamilyPolicy"
  description = "UseFnFamilyPolicy"
  compartment_id = var.compartment_ocid
  statements = ["Allow group Administrators to use functions-family in compartment id ${var.compartment_ocid}"]
}

resource "oci_identity_policy" "AnyUserUseFnPolicy" {
  name = "AnyUserUseFnPolicy"
  description = "AnyUserUseFnPolicy"
  compartment_id = var.compartment_ocid
  statements = ["ALLOW any-user to use functions-family in compartment id ${var.compartment_ocid} where ALL { request.principal.type= 'ApiGateway' , request.resource.compartment.id = '${var.compartment_ocid}'}"]
}