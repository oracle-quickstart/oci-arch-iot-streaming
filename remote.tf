## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "webserver_ConfigMgmt" {
  depends_on = [oci_core_instance.webserver, oci_database_autonomous_database.ATPdatabase, local_file.ATP_database_wallet_file]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '== 1. Install Oracle instant client'",
      "sudo -u root yum -y install oracle-release-el7",
      "sudo -u root yum-config-manager --enable ol7_oracle_instantclient",
      "sudo -u root yum -y install oracle-instantclient18.3-basic",

      "echo '== 2. Install Python3, and then with pip3 cx_Oracle and flask'",
      "sudo -u root yum install -y python36",
      "sudo -u root pip3 install cx_Oracle",
      "sudo -u root pip3 install flask",
      "sudo -u root mkdir /tmp/templates/",
      "sudo -u root chown opc /tmp/templates/",

      "echo '== 3. Disabling firewall and starting HTTPD service'",
      "sudo -u root service firewalld stop"]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "sqlnet.ora"
    destination = "/tmp/sqlnet.ora"
  }

  provisioner "local-exec" {
    command = "echo '${data.oci_database_autonomous_database_wallet.ATP_database_wallet.content}' >> ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${var.ATP_tde_wallet_zip_file}_encoded > ${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = var.ATP_tde_wallet_zip_file
    destination = "/tmp/${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "flask/flask_atp.py"
    destination = "/tmp/flask_atp.py"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "flask/templates/index.html"
    destination = "/tmp/templates/index.html"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 4. Unzip TDE wallet zip file'",
      "sudo -u root unzip -o /tmp/${var.ATP_tde_wallet_zip_file} -d /usr/lib/oracle/18.3/client64/lib/network/admin/",

      "echo '== 5. Move sqlnet.ora to /usr/lib/oracle/18.3/client64/lib/network/admin/'",
    "sudo -u root cp /tmp/sqlnet.ora /usr/lib/oracle/18.3/client64/lib/network/admin/"]
  }

}

resource "null_resource" "webserver_Flask_WebServer_and_access_ATP" {
  depends_on = [null_resource.webserver_ConfigMgmt,oci_apigateway_deployment.apigateway_deployment]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 6. Run Flask with ATP access'",
      "sudo -u root python3 --version",
      "sudo -u root rm -rf /tmp/flask_atp.sh",
      "sudo -u root touch /tmp/flask_atp.sh",
      "sudo -u root touch /tmp/flask_atp.cfg",
      "sudo -u root chmod +x /tmp/flask_atp.sh",
      "sudo /bin/su -c \"echo '#!/bin/bash' >> /tmp/flask_atp.sh\"",
      "sudo /bin/su -c \"echo 'export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib' >> /tmp/flask_atp.sh\"",
      "sudo -u root sed -i 's/atp_user/${var.atp_user}/g' /tmp/flask_atp.py",
      "sudo -u root sed -i 's/atp_password/${var.atp_password}/g' /tmp/flask_atp.py",
      "sudo -u root sed -i 's/atp_alias/${var.ATP_database_db_name}_medium/g' /tmp/flask_atp.py",
      "sudo -u root sed -i 's#apigw_endpoint_URL#${data.oci_apigateway_deployment.apigateway_deployment.endpoint}#g' /tmp/flask_atp.py",
      "sudo /bin/su -c \"echo 'python3 /tmp/flask_atp.py > /tmp/flask_atp.log ' >> /tmp/flask_atp.sh\"",
      "sudo -u root ln -s /usr/lib/oracle/18.3/client64/lib/libclntsh.so.18.1 /usr/lib/oracle/18.3/client64/lib/libclntsh.so",
      "sudo -u root nohup /tmp/flask_atp.sh &",
      "sleep 5",
      "sudo -u root ps -ef | grep flask"]
  }

}
