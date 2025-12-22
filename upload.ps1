$Password = "Alenwanapp33510421@"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential("u126213189", $SecurePassword)

# Using WinSCP or psftp if available
if (Get-Command psftp -ErrorAction SilentlyContinue) {
    $commands = @"
cd domains/mediaprosocial.io/
put backend.tar.gz
ls backend.tar.gz
bye
"@
    $commands | psftp -P 65002 -l u126213189 -pw $Password 82.25.83.217
}
else {
    Write-Host "PSFTP not found. Trying alternative method..."
    # Create batch file for psftp
    $batchContent = @"
open u126213189@82.25.83.217 -P 65002
$Password
cd domains/mediaprosocial.io/
put backend.tar.gz
ls -l
bye
"@
    $batchContent | Out-File -FilePath sftp_commands.txt -Encoding ASCII
    Write-Host "Batch file created. Please install WinSCP or psftp to upload."
}
