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

    print("Running database seeders...")

    # Run all seeders
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan db:seed --force",
        timeout=180
    )
    exit_status = stdout.channel.recv_exit_status()

    result = stdout.read().decode('utf-8', errors='ignore')
    errors = stderr.read().decode('utf-8', errors='ignore')

    print(f"Status: {'SUCCESS' if exit_status == 0 else 'FAILED'}")
    if result:
        print(f"\nOutput:\n{result[:1000]}")
    if errors:
        print(f"\nErrors:\n{errors[:1000]}")

    # Check subscription count again
    print("\n" + "="*60)
    print("Verifying seeded data...")
    print("="*60)

    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute='echo count(App\\Models\\Subscription::all());'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"Subscription plans count: {result.strip()}")

    # Check users count
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute='echo count(App\\Models\\User::all());'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"Users count: {result.strip()}")

    print("\nSeeding completed!")
    ssh.close()

except Exception as e:
    print(f"Error: {e}")
