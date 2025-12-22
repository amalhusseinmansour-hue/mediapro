# Upload fixed AuthController to production
$password = "gtWD8vyZBXT7qv$"
$username = "u126213189"
$server = "82.25.83.217"
$port = 65002
$localFile = "C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\AuthController.php"
$remotePath = "/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/Api/AuthController.php"

# Read the file content
$content = Get-Content -Path $localFile -Raw

# Create SSH command to write file
$sshCommand = @"
cat > $remotePath << 'EOFMARKER'
$content
EOFMARKER
"@

# Execute via SSH
echo $password | ssh -p $port -o StrictHostKeyChecking=no -o PubkeyAuthentication=no "$username@$server" "$sshCommand"

Write-Host "Upload complete!"
