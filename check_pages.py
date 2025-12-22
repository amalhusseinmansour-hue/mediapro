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

    print("Checking pages in database...")

    # Check pages table
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute='DB::table(\"pages\")->select(\"slug\", \"title\")->get()->each(function(\$p) { echo \$p->slug . \" - \" . \$p->title . \"\\n\"; });'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='ignore')
    print(f"Existing pages:\n{result}")

    # Check web routes
    print("\n" + "="*60)
    print("Checking routes...")
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan route:list | grep -E 'contact|about|terms|privacy'",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('ascii', errors='ignore')
    print(f"Routes:\n{result}")

    # Run PagesSeeder which should have these pages
    print("\n" + "="*60)
    print("Running PagesSeeder...")
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan db:seed --class=PagesSeeder --force",
        timeout=120
    )
    exit_status = stdout.channel.recv_exit_status()
    result = stdout.read().decode('ascii', errors='ignore')
    print(f"Exit status: {exit_status}")
    print(f"Output: {result}")

    ssh.close()

except Exception as e:
    print(f"Error: {e}")
