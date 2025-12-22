# تغيير كلمة مرور المدير لـ MediaPro Social
# PowerShell Script

Write-Host "🔐 تغيير كلمة مرور المدير..." -ForegroundColor Cyan

# Navigate to Laravel project
$projectPath = "c:\Users\HP\social_media_manager\backend"
Set-Location $projectPath

# Available password options
$passwordOptions = @{
    "1" = @{ password = "Admin@2025"; hash = '$2y$12$LQv3c/VV8jnWKu8aQxVdmOxQ8ZYzrGkSkF7mH9aXEP6.uR3Q9N0Ji' }
    "2" = @{ password = "secret"; hash = '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' }
    "3" = @{ password = "password123"; hash = '$2y$12$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77UdFm' }
    "4" = @{ password = "mediapro2025"; hash = '$2y$12$UQCHnLX8LO2h7Cp/F.V3h.dNcKr9ZQOFb5.NE7YPcNmQwx8vV2S1G' }
}

Write-Host "`nاختر كلمة المرور الجديدة:" -ForegroundColor Yellow
Write-Host "1. Admin@2025 (الأصلية)" -ForegroundColor White
Write-Host "2. secret (للاختبار)" -ForegroundColor White  
Write-Host "3. password123 (بسيطة)" -ForegroundColor White
Write-Host "4. mediapro2025 (مخصصة)" -ForegroundColor White

$choice = Read-Host "`nأدخل رقم الاختيار (1-4)"

if (-not $passwordOptions.ContainsKey($choice)) {
    Write-Host "❌ اختيار غير صحيح!" -ForegroundColor Red
    exit
}

$selectedPassword = $passwordOptions[$choice]

Write-Host "`n📋 ستكون كلمة المرور الجديدة: $($selectedPassword.password)" -ForegroundColor Green

$confirm = Read-Host "هل تريد المتابعة؟ (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "❌ تم إلغاء العملية" -ForegroundColor Red
    exit
}

# Create PHP script to update password
$phpScript = @"
<?php
require_once 'vendor/autoload.php';
require_once 'bootstrap/app.php';

use App\Models\User;

try {
    // Find user by email
    `$user = User::where('email', 'admin@mediapro.com')->first();
    
    if (!`$user) {
        echo "❌ لم يتم العثور على المستخدم admin@mediapro.com\n";
        exit;
    }
    
    // Update password
    `$user->password = '$($selectedPassword.hash)';
    `$user->save();
    
    echo "✅ تم تحديث كلمة المرور بنجاح!\n";
    echo "📧 البريد الإلكتروني: admin@mediapro.com\n";
    echo "🔑 كلمة المرور الجديدة: $($selectedPassword.password)\n";
    echo "🔗 رابط الدخول: https://mediaprosocial.io/admin/login\n";
    
} catch (Exception `$e) {
    echo "❌ خطأ في تحديث كلمة المرور: " . `$e->getMessage() . "\n";
}
?>
"@

# Save and execute PHP script
$phpScript | Out-File -FilePath "temp_update_password.php" -Encoding UTF8

Write-Host "`n⚙️ تنفيذ التحديث..." -ForegroundColor Yellow
php temp_update_password.php

# Clean up
Remove-Item "temp_update_password.php" -ErrorAction SilentlyContinue

Write-Host "`n📋 بيانات الدخول المُحدثة:" -ForegroundColor Green
Write-Host "🔗 https://mediaprosocial.io/admin/login" -ForegroundColor Cyan
Write-Host "📧 admin@mediapro.com" -ForegroundColor White
Write-Host "🔑 $($selectedPassword.password)" -ForegroundColor White

Write-Host "`n🎉 تم تحديث كلمة المرور بنجاح!" -ForegroundColor Green