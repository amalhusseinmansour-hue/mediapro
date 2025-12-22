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

    print("Checking for seeders...")

    # List seeders
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && ls -la database/seeders/",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"Available seeders:\n{result}")

    # Check if there are any subscription records
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute='echo count(App\\Models\\Subscription::all());'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"\nCurrent subscription count: {result}")

    ssh.close()

except Exception as e:
    print(f"Error: {e}")
