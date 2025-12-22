#!/usr/bin/env python3
import paramiko
import os
import glob
import time

hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"
remote_dir = "domains/mediaprosocial.io/public_html"

print(f"Starting robust chunk upload...")

# Get all chunk files
chunks = sorted(glob.glob("backend-part-*"))
print(f"\nFound {len(chunks)} chunks to upload")

# Upload each chunk with reconnection for each file
for i, chunk in enumerate(chunks, 1):
    print(f"\n[{i}/{len(chunks)}] Processing {chunk}...")
    file_size = os.path.getsize(chunk)
    print(f"  Size: {file_size / (1024*1024):.2f} MB")

    # Check if already uploaded
    try:
        print(f"  Connecting to server...")
        transport = paramiko.Transport((hostname, port))
        transport.connect(username=username, password=password)
        sftp = paramiko.SFTPClient.from_transport(transport)

        # Check if file exists on server
        try:
            remote_stat = sftp.stat(f"{remote_dir}/{os.path.basename(chunk)}")
            if remote_stat.st_size == file_size:
                print(f"  Already uploaded! Skipping...")
                sftp.close()
                transport.close()
                continue
            else:
                print(f"  File exists but size mismatch. Re-uploading...")
        except:
            print(f"  File not found on server. Uploading...")

        # Upload the file
        sftp.put(chunk, f"{remote_dir}/{os.path.basename(chunk)}")
        print(f"  Upload complete!")

        # Close connection
        sftp.close()
        transport.close()

        # Wait before next upload to avoid rate limiting
        if i < len(chunks):
            print(f"  Waiting 3 seconds before next upload...")
            time.sleep(3)

    except Exception as e:
        print(f"  Failed: {e}")
        print(f"  Will retry this chunk after 10 seconds...")
        time.sleep(10)

        # Retry once
        try:
            print(f"  Retrying {chunk}...")
            transport = paramiko.Transport((hostname, port))
            transport.connect(username=username, password=password)
            sftp = paramiko.SFTPClient.from_transport(transport)
            sftp.put(chunk, f"{remote_dir}/{os.path.basename(chunk)}")
            print(f"  Retry successful!")
            sftp.close()
            transport.close()
            time.sleep(3)
        except Exception as e2:
            print(f"  Retry failed: {e2}")
            print(f"  Stopping upload process.")
            break

print("\n\nUpload process completed!")
