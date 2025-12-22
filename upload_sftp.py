#!/usr/bin/env python3
import paramiko
import os
import sys

# SFTP connection details
hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"
remote_path = "/home/u126213189/domains/mediaprosocial.io/"
local_file = "backend.tar.gz"

print(f"Starting upload of {local_file}...")
print(f"File size: {os.path.getsize(local_file) / (1024*1024):.2f} MB")

try:
    # Create SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    print(f"Connecting to {hostname}:{port}...")
    ssh.connect(hostname, port=port, username=username, password=password, timeout=30)

    # Create SFTP client
    sftp = ssh.open_sftp()

    print(f"Uploading to {remote_path}{local_file}...")

    # Upload with progress callback
    def progress(transferred, total):
        percent = (transferred / total) * 100
        print(f"\rProgress: {percent:.1f}% ({transferred/(1024*1024):.2f}/{total/(1024*1024):.2f} MB)", end='', flush=True)

    sftp.put(local_file, remote_path + local_file, callback=progress)

    print("\n\nUpload completed successfully!")

    # Verify the file exists on the server
    print("Verifying file on server...")
    file_stat = sftp.stat(remote_path + local_file)
    print(f"Remote file size: {file_stat.st_size / (1024*1024):.2f} MB")

    # Close connections
    sftp.close()
    ssh.close()

    print("\nDone!")
    sys.exit(0)

except Exception as e:
    print(f"\nError: {e}")
    sys.exit(1)
