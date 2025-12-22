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

    print("\nChecking backend folder contents:")
    try:
        backend_files = sftp.listdir("domains/mediaprosocial.io/public_html/backend")
        print(f"Backend folder exists with {len(backend_files)} items")
        print("\nFirst 20 items:")
        for f in sorted(backend_files)[:20]:
            print(f"  - {f}")
    except Exception as e:
        print(f"Error accessing backend folder: {e}")

    print("\n\nChecking uploaded chunks:")
    files = sftp.listdir("domains/mediaprosocial.io/public_html")
    chunks = [f for f in files if f.startswith("backend-part-")]
    print(f"Found {len(chunks)} uploaded chunks:")
    for chunk in sorted(chunks):
        stat = sftp.stat(f"domains/mediaprosocial.io/public_html/{chunk}")
        size = stat.st_size / (1024*1024)
        print(f"  {chunk}: {size:.2f} MB")

    sftp.close()
    transport.close()

    print("\nSuccess!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
