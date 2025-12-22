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

    print("Checking database tables...")

    # Check subscription_plans table
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute='echo count(DB::table(\"subscription_plans\")->get());'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"subscription_plans table count: {result.strip()}")

    # Check subscriptions table
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute='echo count(DB::table(\"subscriptions\")->get());'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"subscriptions table count: {result.strip()}")

    # Check settings table
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute='echo count(DB::table(\"settings\")->get());'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"settings table count: {result.strip()}")

    # Let's see what the SubscriptionPlansSeeder creates
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && cat database/seeders/SubscriptionPlansSeeder.php | head -50",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"\nSubscriptionPlansSeeder content:\n{result}")

    ssh.close()

except Exception as e:
    print(f"Error: {e}")
