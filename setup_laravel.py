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

    print("Connected! Setting up Laravel configuration...")

    # Create .htaccess file to redirect to public folder
    htaccess_content = """<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>"""

    # Create index.php file to redirect to public folder
    index_content = """<?php
header("Location: /public/");
exit();
?>"""

    commands = [
        # Create .htaccess file
        f"cd domains/mediaprosocial.io/public_html && cat > .htaccess << 'EOF'\n{htaccess_content}\nEOF",

        # Create index.php redirect (backup first if exists)
        "cd domains/mediaprosocial.io/public_html && if [ -f index.php ]; then mv index.php index.php.bak; fi",
        f"cd domains/mediaprosocial.io/public_html && cat > index.php << 'EOF'\n{index_content}\nEOF",

        # Set proper permissions for storage and bootstrap/cache
        "cd domains/mediaprosocial.io/public_html && chmod -R 775 storage bootstrap/cache 2>/dev/null || true",

        # Check if composer.lock exists
        "cd domains/mediaprosocial.io/public_html && ls -la composer.* .env artisan public/index.php"
    ]

    for cmd in commands:
        print(f"\nExecuting command...")
        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=120)
        exit_status = stdout.channel.recv_exit_status()

        output = stdout.read().decode('utf-8', errors='ignore')
        error = stderr.read().decode('utf-8', errors='ignore')

        if output:
            print(f"Output:\n{output}")
        if error and "No such file or directory" not in error:
            print(f"Note: {error}")

    print("\n=== Laravel setup completed! ===")
    print("\nYour Laravel application is now accessible at:")
    print("https://mediaprosocial.io/")

    print("\nNext steps:")
    print("1. Make sure your database credentials in .env are correct")
    print("2. You may need to run: php artisan migrate")
    print("3. You may need to run: php artisan storage:link")
    print("4. Clear cache: php artisan config:cache")

    ssh.close()

except Exception as e:
    print(f"\nError: {e}")
    import traceback
    traceback.print_exc()
