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

    print("Connected! Merging chunks...")

    # Merge chunks
    merge_command = "cd domains/mediaprosocial.io/public_html && cat backend-part-* > backend-full.tar.gz && ls -lh backend-full.tar.gz"
    stdin, stdout, stderr = ssh.exec_command(merge_command, timeout=120)
    exit_status = stdout.channel.recv_exit_status()

    output = stdout.read().decode('utf-8', errors='ignore')
    error = stderr.read().decode('utf-8', errors='ignore')

    print(f"\nMerge exit status: {exit_status}")
    if output:
        print(f"Merge output:\n{output}")
    if error:
        print(f"Merge errors:\n{error}")

    if exit_status == 0:
        print("\nChunks merged successfully!")

        # Extract the archive
        print("\nExtracting backend archive...")
        extract_command = "cd domains/mediaprosocial.io/public_html && tar -xzf backend-full.tar.gz && ls -la backend/ | head -20"
        stdin, stdout, stderr = ssh.exec_command(extract_command, timeout=180)
        exit_status = stdout.channel.recv_exit_status()

        output = stdout.read().decode('utf-8', errors='ignore')
        error = stderr.read().decode('utf-8', errors='ignore')

        print(f"\nExtraction exit status: {exit_status}")
        if output:
            print(f"Extraction output:\n{output}")
        if error:
            print(f"Extraction errors:\n{error}")

        if exit_status == 0:
            print("\n*** Backend extracted successfully! ***")
        else:
            print("\n*** Extraction failed! ***")
    else:
        print("\n*** Merge failed! ***")

    # Cleanup chunks
    print("\nCleaning up chunk files...")
    cleanup_command = "cd domains/mediaprosocial.io/public_html && rm -f backend-part-* && echo 'Cleanup complete'"
    stdin, stdout, stderr = ssh.exec_command(cleanup_command, timeout=60)
    exit_status = stdout.channel.recv_exit_status()
    output = stdout.read().decode('utf-8', errors='ignore')
    print(output)

    ssh.close()

except Exception as e:
    print(f"\nError: {e}")
    import traceback
    traceback.print_exc()
