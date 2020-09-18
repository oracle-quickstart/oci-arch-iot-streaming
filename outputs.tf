output "Upload2StreamFn_POST_EndPoint_URL" {
  value = [join("", [data.oci_apigateway_deployment.apigateway_deployment.endpoint, "/upload2stream"])]
}

output "Flask_Webserver_URL" {
  value = [join("", ["http://", data.oci_core_vnic.webserver_VNIC1.public_ip_address, "/"])]
}