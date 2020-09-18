resource "oci_streaming_stream_pool" "streamPool" {
    compartment_id = var.compartment_ocid
    name = "FoggyKitchenStreamPool"
}

resource "oci_streaming_stream" "stream" {
    name = "stream"
    partitions = 1
    stream_pool_id = oci_streaming_stream_pool.streamPool.id
}

