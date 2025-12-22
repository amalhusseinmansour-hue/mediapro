#!/usr/bin/env python3
import paramiko
import os

# Configuration
hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"
local_file = "backend-new.tar.gz"
remote_path = "domains/mediaprosocial.io/public_html/backend.tar.gz"

print(f"Connecting to {hostname}:{port}...")

try:
    # Create SSH transport
    transport = paramiko.Transport((hostname, port))
    transport.connect(username=username, password=password)

    # Create SFTP client
    sftp = paramiko.SFTPClient.from_transport(transport)

    print(f"Uploading {local_file}...")
    file_size = os.path.getsize(local_file)
    print(f"File size: {file_size / (1024*1024):.2f} MB")

    # Upload file
    sftp.put(local_file, remote_path)

    print("Upload completed!")

    # Verify
    stat = sftp.stat(remote_path)
    print(f"Remote file size: {stat.st_size / (1024*1024):.2f} MB")

    sftp.close()
    transport.close()

    print("Success!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
