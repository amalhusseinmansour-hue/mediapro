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

    print("Connected! Moving backend files to public_html root...")

    # Move all files from backend to public_html
    commands = [
        # First, backup any existing default files
        "cd domains/mediaprosocial.io/public_html && if [ -f default.php ]; then mv default.php default.php.bak; fi",

        # Move all files from backend to parent directory
        "cd domains/mediaprosocial.io/public_html && mv backend/* . && mv backend/.* . 2>/dev/null || true",

        # Remove empty backend directory
        "cd domains/mediaprosocial.io/public_html && rmdir backend",

        # List the files
        "cd domains/mediaprosocial.io/public_html && ls -la | head -30"
    ]

    for cmd in commands:
        print(f"\nExecuting: {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=120)
        exit_status = stdout.channel.recv_exit_status()

        output = stdout.read().decode('utf-8', errors='ignore')
        error = stderr.read().decode('utf-8', errors='ignore')

        if output:
            print(f"Output:\n{output}")
        if error and "No such file or directory" not in error:
            print(f"Note: {error}")

    print("\n=== Files moved successfully to public_html root! ===")

    ssh.close()

except Exception as e:
    print(f"\nError: {e}")
    import traceback
    traceback.print_exc()
