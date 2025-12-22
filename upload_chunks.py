#!/usr/bin/env python3
import paramiko
import os
import glob

hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"
remote_dir = "domains/mediaprosocial.io/public_html"

print(f"Connecting to {hostname}:{port}...")

try:
    transport = paramiko.Transport((hostname, port))
    transport.connect(username=username, password=password)
    sftp = paramiko.SFTPClient.from_transport(transport)

    # Get all chunk files
    chunks = sorted(glob.glob("backend-part-*"))
    print(f"\nFound {len(chunks)} chunks to upload")

    # Upload each chunk
    for i, chunk in enumerate(chunks, 1):
        print(f"\n[{i}/{len(chunks)}] Uploading {chunk}...")
        file_size = os.path.getsize(chunk)
        print(f"  Size: {file_size / (1024*1024):.2f} MB")

        try:
            sftp.put(chunk, f"{remote_dir}/{os.path.basename(chunk)}")
            print(f"  Done!")
        except Exception as e:
            print(f"  Failed: {e}")
            break

    print("\n\nUpload completed!")
    sftp.close()
    transport.close()

except Exception as e:
    print(f"\nError: {e}")
    import traceback
    traceback.print_exc()
