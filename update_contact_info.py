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

    print("Updating contact information...")

    # Check current settings
    print("\nChecking current settings...")
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute=\"DB::table('settings')->whereIn('key', ['contact_email', 'contact_phone', 'support_email', 'phone'])->get()->each(function(\$s) { echo \$s->key . ': ' . \$s->value . chr(10); });\"",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('ascii', errors='ignore')
    print(result)

    # Update email
    print("\nUpdating email to support@mediaprosocial.io...")
    email_keys = ['contact_email', 'support_email', 'email', 'site_email']
    for key in email_keys:
        cmd = f"cd domains/mediaprosocial.io/public_html && php artisan tinker --execute=\"DB::table('settings')->where('key', '{key}')->update(['value' => 'support@mediaprosocial.io']); echo 'Updated {key}';\""
        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=60)
        stdout.channel.recv_exit_status()

    # Update phone
    print("\nUpdating phone to 00971545783573...")
    phone_keys = ['contact_phone', 'phone', 'site_phone']
    for key in phone_keys:
        cmd = f"cd domains/mediaprosocial.io/public_html && php artisan tinker --execute=\"DB::table('settings')->where('key', '{key}')->update(['value' => '00971545783573']); echo 'Updated {key}';\""
        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=60)
        stdout.channel.recv_exit_status()

    # Check updated settings
    print("\nVerifying updates...")
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan tinker --execute=\"DB::table('settings')->whereIn('key', ['contact_email', 'contact_phone', 'support_email', 'phone', 'email', 'site_email', 'site_phone'])->get()->each(function(\$s) { echo \$s->key . ': ' . \$s->value . chr(10); });\"",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('ascii', errors='ignore')
    print(result)

    # Clear cache
    print("\nClearing cache...")
    stdin, stdout, stderr = ssh.exec_command(
        "cd domains/mediaprosocial.io/public_html && php artisan cache:clear && php artisan config:clear",
        timeout=60
    )
    stdout.channel.recv_exit_status()
    print("Cache cleared!")

    ssh.close()
    print("\nContact information updated successfully!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
