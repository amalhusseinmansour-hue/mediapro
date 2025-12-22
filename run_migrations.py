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
    ssh.connect(hostname, port=port, username=username, password=password, timeout=60)

    print("Connected! Running Laravel migrations and setup...")

    commands = [
        # Check current database settings
        ("Check .env database config",
         "cd domains/mediaprosocial.io/public_html && grep -E 'DB_CONNECTION|DB_HOST|DB_DATABASE|DB_USERNAME' .env"),

        # Clear config cache
        ("Clear config cache",
         "cd domains/mediaprosocial.io/public_html && php artisan config:clear"),

        # Run migrations
        ("Run database migrations",
         "cd domains/mediaprosocial.io/public_html && php artisan migrate --force"),

        # Create storage link
        ("Create storage link",
         "cd domains/mediaprosocial.io/public_html && php artisan storage:link"),

        # Cache config
        ("Cache config",
         "cd domains/mediaprosocial.io/public_html && php artisan config:cache"),

        # Check if seeders exist and run them
        ("Check for seeders",
         "cd domains/mediaprosocial.io/public_html && ls -la database/seeders/"),
    ]

    for description, cmd in commands:
        print(f"\n{'='*60}")
        print(f"{description}")
        print(f"{'='*60}")

        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=180)

        # Wait for command to complete
        exit_status = stdout.channel.recv_exit_status()

        output = stdout.read().decode('utf-8', errors='ignore')
        error = stderr.read().decode('utf-8', errors='ignore')

        if output:
            print(f"\nOutput:")
            print(output)

        if error:
            print(f"\nErrors/Warnings:")
            print(error)

        print(f"\nExit Status: {exit_status}")

        # Small delay between commands
        time.sleep(1)

    print("\n" + "="*60)
    print("Setup completed! Check the output above for any errors.")
    print("="*60)

    ssh.close()

except Exception as e:
    print(f"\nError: {e}")
    import traceback
    traceback.print_exc()
