## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "Login2OCIR" {
  depends_on = [null_resource.webserver_ConfigMgmt,
                oci_functions_application.Stream2ATPFnApp, 
                oci_database_autonomous_database.ATPdatabase,
                oci_identity_policy.FunctionsServiceReposAccessPolicy,
                oci_identity_policy.FunctionsServiceNetworkAccessPolicy,
                oci_identity_dynamic_group.FunctionsServiceDynamicGroup,
                oci_identity_policy.FunctionsServiceDynamicGroupPolicy,
                oci_identity_policy.ManageAPIGWFamilyPolicy,
                oci_identity_policy.ManageVCNFamilyPolicy,
                oci_identity_policy.UseFnFamilyPolicy,
                oci_identity_policy.AnyUserUseFnPolicy]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${var.ocir_docker_repository} --username ${var.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }
}

resource "null_resource" "SetupATPFnPush2OCIR" {
  depends_on = [null_resource.Login2OCIR, null_resource.webserver_ConfigMgmt, oci_functions_application.Stream2ATPFnApp, oci_database_autonomous_database.ATPdatabase]

  provisioner "local-exec" {
    command = "cp ${var.ATP_tde_wallet_zip_file} functions/SetupATPFn/" 
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep setupatpfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_ADMIN_ATP_PASSWORD=${var.atp_admin_password} --build-arg ARG_ATP_USER=${var.atp_user} --build-arg ARG_ATP_PASSWORD=${var.atp_password} --build-arg ARG_ATP_ALIAS=${var.ATP_database_db_name}_medium"
    working_dir = "functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep setupatpfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    working_dir = "functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    working_dir = "functions/SetupATPFn"
  }

}


resource "null_resource" "Stream2ATPFnPush2OCIR" {
  depends_on = [null_resource.Login2OCIR, null_resource.webserver_ConfigMgmt, oci_streaming_stream.stream, oci_streaming_stream_pool.streamPool, oci_functions_application.Stream2ATPFnApp, oci_database_autonomous_database.ATPdatabase, null_resource.SetupATPFnPush2OCIR]


  provisioner "local-exec" {
    command = "cp ${var.ATP_tde_wallet_zip_file} functions/Stream2ATPFn/" 
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep stream2atpfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/Stream2ATPFn"
  }
  
  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_ATP_USER=${var.atp_user} --build-arg ARG_ATP_PASSWORD=${var.atp_password} --build-arg ARG_ATP_ALIAS=${var.ATP_database_db_name}_medium --build-arg ARG_STREAM_OCID=${oci_streaming_stream.stream.id} --build-arg ARG_STREAM_ENDPOINT=${data.oci_streaming_stream_pool.streamPool.endpoint_fqdn}"
    working_dir = "functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep stream2atpfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
    working_dir = "functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
    working_dir = "functions/Stream2ATPFn"
  }

}


resource "null_resource" "Upload2StreamFnPush2OCIR" {
  depends_on = [null_resource.Login2OCIR, oci_streaming_stream.stream, oci_streaming_stream_pool.streamPool, oci_functions_application.Upload2StreamFnApp]

  provisioner "local-exec" {
    command = "image=$(docker images | grep upload2streamfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/Upload2StreamFn"
  }
  
  provisioner "local-exec" {
    command = "echo 'ARG_STREAM_OCID=${oci_streaming_stream.stream.id}' "
    
  }

  provisioner "local-exec" {
    command = "echo 'ARG_STREAM_ENDPOINT=${data.oci_streaming_stream_pool.streamPool.endpoint_fqdn}'"
    
  }

  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_STREAM_OCID='${oci_streaming_stream.stream.id}' --build-arg ARG_STREAM_ENDPOINT='${data.oci_streaming_stream_pool.streamPool.endpoint_fqdn}'"
    working_dir = "functions/Upload2StreamFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep upload2streamfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
    working_dir = "functions/Upload2StreamFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
    working_dir = "functions/Upload2StreamFn"
  }

}