## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_streaming_stream_pool" "streamPool" {
    compartment_id = var.compartment_ocid
    name = "FoggyKitchenStreamPool"
}

resource "oci_streaming_stream" "stream" {
    name = "stream"
    partitions = 1
    stream_pool_id = oci_streaming_stream_pool.streamPool.id
}

