#!/usr/bin/env python3
import paramiko
import time

hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

print(f"Connecting to {hostname}:{port}...")

try:
    # Create SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname, port=port, username=username, password=password, timeout=30)

    print("Connected! Executing extraction command...")

    # Execute tar extraction command
    command = "cd domains/mediaprosocial.io/public_html && tar -xzf backend.tar.gz && ls -la backend/"
    stdin, stdout, stderr = ssh.exec_command(command, timeout=120)

    # Wait for command to complete
    exit_status = stdout.channel.recv_exit_status()

    # Get output
    output = stdout.read().decode('utf-8', errors='ignore')
    error = stderr.read().decode('utf-8', errors='ignore')

    print(f"\nExit status: {exit_status}")

    if output:
        print("\nOutput:")
        print(output)

    if error:
        print("\nErrors/Warnings:")
        print(error)

    if exit_status == 0:
        print("\n✓ Extraction completed successfully!")
    else:
        print("\n✗ Extraction failed!")

    ssh.close()

except Exception as e:
    print(f"\nError: {e}")
    import traceback
    traceback.print_exc()
