# PowerShell Script to Fix 419 Error on Server
# Run this script: Right-click -> Run with PowerShell

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  إصلاح خطأ 419 عبر SSH" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$server = "82.25.83.217"
$port = "65002"
$username = "u126213189"
$password = "gtWD8vyZBXT7qv$"

Write-Host "Server: $server" -ForegroundColor Yellow
Write-Host "Port: $port" -ForegroundColor Yellow
Write-Host "User: $username" -ForegroundColor Yellow
Write-Host ""

# Create the fix commands
$commands = @"
cd domains/mediaprosocial.io/public_html
echo '==========================================';
echo 'Step 1: تعديل SESSION_ENCRYPT';
sed -i.backup 's/SESSION_ENCRYPT=true/SESSION_ENCRYPT=false/g' .env
sed -i 's/SESSION_ENCRYPT=false/SESSION_ENCRYPT=false/g' .env
grep SESSION_ENCRYPT .env || echo 'SESSION_ENCRYPT=false' >> .env
echo 'تم تعديل SESSION_ENCRYPT';
echo '';
echo 'Step 2: حذف ملفات الجلسات';
cd storage/framework/sessions
ls -1 | grep -v '.gitignore' | xargs rm -f
echo 'تم حذف ملفات الجلسات';
cd ../../..
echo '';
echo 'Step 3: مسح الكاش';
php artisan config:clear
php artisan cache:clear
php artisan view:clear
echo '';
echo '✅ تم الإصلاح بنجاح!';
echo '';
echo 'الآن جرب تسجيل الدخول:';
echo 'https://mediaprosocial.io/admin/login';
echo 'Email: admin@mediapro.com';
echo 'Password: Admin@12345';
exit
"@

# Save commands to temp file
$tempFile = "$env:TEMP\ssh_commands.txt"
$commands | Out-File -FilePath $tempFile -Encoding ASCII

Write-Host "Connecting to server..." -ForegroundColor Green
Write-Host "When prompted, enter password: $password" -ForegroundColor Yellow
Write-Host ""

# Execute SSH with commands
$sshCommand = "ssh -p $port -o StrictHostKeyChecking=no $username@$server"
Write-Host "Command: $sshCommand" -ForegroundColor Gray
Write-Host ""
Write-Host "Copy these commands and paste them after connecting:" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host $commands
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Start SSH
Start-Process ssh -ArgumentList "-p $port -o StrictHostKeyChecking=no $username@$server" -Wait

Write-Host ""
Write-Host "Done! Press any key to exit..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
