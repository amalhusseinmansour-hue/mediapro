#!/usr/bin/env python3
import paramiko

hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

try:
    transport = paramiko.Transport((hostname, port))
    transport.connect(username=username, password=password)
    sftp = paramiko.SFTPClient.from_transport(transport)

    print("Downloading PricingController...")

    # Download the PricingController
    remote_file = "domains/mediaprosocial.io/public_html/app/Http/Controllers/PricingController.php"
    local_file = "PricingController.php"

    sftp.get(remote_file, local_file)
    print(f"Downloaded to {local_file}")

    sftp.close()
    transport.close()

except Exception as e:
    print(f"Error: {e}")
