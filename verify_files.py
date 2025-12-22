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

    print("\nListing files in public_html:")
    try:
        files = sftp.listdir("domains/mediaprosocial.io/public_html")
        for f in sorted(files):
            try:
                stat = sftp.stat(f"domains/mediaprosocial.io/public_html/{f}")
                if stat.st_mode & 0o040000:  # directory
                    print(f"  [DIR]  {f}")
                else:
                    size = stat.st_size / (1024*1024) if stat.st_size > 1024*1024 else stat.st_size / 1024
                    unit = "MB" if stat.st_size > 1024*1024 else "KB"
                    print(f"  [FILE] {f} ({size:.2f} {unit})")
            except:
                print(f"  {f}")
    except Exception as e:
        print(f"Error listing files: {e}")

    # Check if backend folder exists
    print("\nChecking for backend folder:")
    try:
        backend_files = sftp.listdir("domains/mediaprosocial.io/public_html/backend")
        print(f"✓ Backend folder exists with {len(backend_files)} items")
        print("First 10 items:")
        for f in sorted(backend_files)[:10]:
            print(f"  - {f}")
    except Exception as e:
        print(f"✗ Backend folder not found or error: {e}")

    sftp.close()
    transport.close()

    print("\nSuccess!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
