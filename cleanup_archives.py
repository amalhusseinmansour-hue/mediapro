#!/usr/bin/env python3
import paramiko

hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

print(f"Connecting to {hostname}:{port}...")

try:
    # Create SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname, port=port, username=username, password=password, timeout=60)

    print("Connected! Cleaning up archive files...")

    # Remove archive files
    commands = [
        # Remove the large archive files
        "cd domains/mediaprosocial.io/public_html && rm -f backend-full.tar.gz backend.tar.gz",

        # Check remaining files
        "cd domains/mediaprosocial.io/public_html && du -sh . && echo '' && ls -lh | grep -E 'tar.gz|zip|part-' || echo 'No archive files found'"
    ]

    for cmd in commands:
        print(f"\nExecuting: {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=120)
        exit_status = stdout.channel.recv_exit_status()

        output = stdout.read().decode('utf-8', errors='ignore')
        error = stderr.read().decode('utf-8', errors='ignore')

        if output:
            print(f"Output:\n{output}")
        if error and exit_status != 0:
            print(f"Error: {error}")

    print("\n=== Cleanup completed! ===")

    ssh.close()

except Exception as e:
    print(f"\nError: {e}")
    import traceback
    traceback.print_exc()
