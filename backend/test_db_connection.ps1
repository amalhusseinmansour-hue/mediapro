# Database Connection Test Script
# اختبار الاتصال بـ MySQL

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host ""
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host "   Database Connection Test" -ForegroundColor $Green
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host ""

$DB_HOST = "localhost"
$DB_USER = "u126213189"
$DB_PASSWORD = "Alenwanapp33510421@"
$DB_NAME = "u126213189_socialmedia_ma"

Write-Host "📊 محاولة الاتصال بـ MySQL..." -ForegroundColor $Yellow
Write-Host "Host: $DB_HOST" -ForegroundColor $Cyan
Write-Host "User: $DB_USER" -ForegroundColor $Cyan
Write-Host "Database: $DB_NAME" -ForegroundColor $Cyan
Write-Host ""

try {
    $output = mysql -h $DB_HOST -u $DB_USER "-p$DB_PASSWORD" $DB_NAME -e "SELECT 'Connection Successful!' as Status; SHOW TABLES;" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ الاتصال نجح!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "الجداول:" -ForegroundColor $Green
        Write-Host $output
        Write-Host ""
        Write-Host "الآن يمكنك تشغيل:" -ForegroundColor $Yellow
        Write-Host "  php artisan migrate --force" -ForegroundColor $Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ فشل الاتصال!" -ForegroundColor $Red
        Write-Host ""
        Write-Host "المشاكل المحتملة:" -ForegroundColor $Yellow
        Write-Host "  1. كلمة المرور خاطئة" -ForegroundColor $Red
        Write-Host "  2. اسم Host خاطئ" -ForegroundColor $Red
        Write-Host "  3. MySQL لا يعمل" -ForegroundColor $Red
        Write-Host "  4. اسم Database خاطئ" -ForegroundColor $Red
        Write-Host ""
        Write-Host "جرّب هذه الخيارات:" -ForegroundColor $Yellow
        Write-Host "  - Host: localhost." -ForegroundColor $White
        Write-Host "  - Host: 127.0.0.1" -ForegroundColor $White
        Write-Host "  - Host: sql.mediaprosocial.io" -ForegroundColor $White
        Write-Host "  - Host: mysql.hostinger.com" -ForegroundColor $White
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "❌ حدث خطأ: $_" -ForegroundColor $Red
    Write-Host ""
}

Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor $Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
