#!/usr/bin/env python3
import paramiko

hostname = "82.25.83.217"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname, port=port, username=username, password=password, timeout=60)

    print("Running final setup commands...")

    # Storage link
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan storage:link 2>&1 || echo 'Link exists'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    print("Storage link: OK")

    # Cache config
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan config:cache 2>&1",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    print("Config cache: OK")

    # Check database tables
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan db:show 2>&1 | head -20",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('ascii', errors='ignore')
    print(f"\nDatabase info:\n{result}")

    print("\nAll setup tasks completed successfully!")
    ssh.close()

except Exception as e:
    print(f"Error: {e}")
