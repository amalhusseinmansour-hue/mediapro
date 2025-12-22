# إنشاء مستخدم إدمين لـ MediaPro Social
# PowerShell Script

Write-Host "🔧 إنشاء مستخدم إدمين جديد..." -ForegroundColor Cyan

# Navigate to Laravel project
$projectPath = "c:\Users\HP\social_media_manager\backend"
Set-Location $projectPath

# Admin user data
$adminUsers = @(
    @{
        name = "مدير النظام الرئيسي"
        email = "admin@mediapro.com"
        password = "Admin@2025"
    },
    @{
        name = "مدير النظام الاحتياطي"  
        email = "super@mediapro.com"
        password = "Super@2025"
    },
    @{
        name = "إدارة المحتوى"
        email = "content@mediapro.com"
        password = "Content@2025"
    }
)

Write-Host "📋 سيتم إنشاء $($adminUsers.Count) مدير:" -ForegroundColor Yellow
foreach ($user in $adminUsers) {
    Write-Host "  - $($user.name) ($($user.email))" -ForegroundColor Gray
}

$confirm = Read-Host "هل تريد المتابعة؟ (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "❌ تم إلغاء العملية" -ForegroundColor Red
    exit
}

# Create PHP script to add admin users
$phpScript = @"
<?php
require_once 'vendor/autoload.php';
require_once 'bootstrap/app.php';

use App\Models\User;
use Illuminate\Support\Facades\Hash;

try {
    // Admin users data
    `$adminUsers = [
"@

foreach ($user in $adminUsers) {
    $phpScript += @"
        [
            'name' => '$($user.name)',
            'email' => '$($user.email)',
            'password' => '$($user.password)',
        ],
"@
}

$phpScript += @"
    ];

    // Delete existing admin users
    `$emails = array_column(`$adminUsers, 'email');
    User::whereIn('email', `$emails)->delete();
    echo "🗑️ تم حذف المديرين السابقين\n";

    // Create new admin users
    foreach (`$adminUsers as `$adminData) {
        `$admin = User::create([
            'name' => `$adminData['name'],
            'email' => `$adminData['email'],
            'password' => Hash::make(`$adminData['password']),
            'is_admin' => true,
            'is_active' => true,
            'user_type' => 'admin',
            'email_verified_at' => now(),
            'bio' => 'مدير النظام - صلاحيات كاملة',
            'company_name' => 'MediaPro Social',
        ]);

        echo "✅ تم إنشاء المدير: " . `$adminData['email'] . "\n";
    }

    echo "\n🎉 تم إنشاء جميع المديرين بنجاح!\n";
    echo "🔗 رابط الدخول: https://mediaprosocial.io/admin/login\n";

} catch (Exception `$e) {
    echo "❌ خطأ: " . `$e->getMessage() . "\n";
}
?>
"@

# Save and execute PHP script
$phpScript | Out-File -FilePath "temp_create_admin.php" -Encoding UTF8

Write-Host "⚙️ تنفيذ السكريبت..." -ForegroundColor Yellow
php temp_create_admin.php

# Clean up
Remove-Item "temp_create_admin.php" -ErrorAction SilentlyContinue

Write-Host "`n📋 بيانات الدخول للمديرين:" -ForegroundColor Green
Write-Host "🔗 رابط الدخول: https://mediaprosocial.io/admin/login" -ForegroundColor Cyan
foreach ($user in $adminUsers) {
    Write-Host "📧 $($user.email) | 🔑 $($user.password)" -ForegroundColor White
}

Write-Host "`n🎉 انتهى إنشاء المديرين!" -ForegroundColor Green