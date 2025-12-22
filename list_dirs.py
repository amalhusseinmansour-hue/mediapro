#!/usr/bin/env python3
import paramiko

hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

print(f"Connecting to {hostname}:{port}...")

try:
    transport = paramiko.Transport((hostname, port))
    transport.connect(username=username, password=password)
    sftp = paramiko.SFTPClient.from_transport(transport)

    print("\nListing home directory:")
    files = sftp.listdir(".")
    for f in files:
        print(f"  - {f}")

    print("\nSuccess!")
    sftp.close()
    transport.close()

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
