# 🎯 سكريبت تجهيز نظام OTP Firebase - PowerShell للـ Windows

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                 Firebase OTP Setup Script                      ║" -ForegroundColor Cyan
Write-Host "║              سكريبت تجهيز نظام OTP مع Firebase                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# الدوال
function Print-Success {
    param([string]$message)
    Write-Host "✅ $message" -ForegroundColor Green
}

function Print-Error {
    param([string]$message)
    Write-Host "❌ $message" -ForegroundColor Red
}

function Print-Warning {
    param([string]$message)
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

function Print-Info {
    param([string]$message)
    Write-Host "ℹ️  $message" -ForegroundColor Blue
}

# Step 1: تنظيف المشروع
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Step 1: تنظيف المشروع" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Print-Info "Running: flutter clean"

try {
    $output = flutter clean 2>&1
    Print-Success "Project cleaned successfully"
} catch {
    Print-Error "Failed to clean project"
    exit 1
}

# Step 2: الحصول على المكتبات
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Step 2: الحصول على المكتبات" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Print-Info "Running: flutter pub get"

try {
    $output = flutter pub get 2>&1
    Print-Success "Dependencies fetched successfully"
} catch {
    Print-Error "Failed to fetch dependencies"
    exit 1
}

# Step 3: التحقق من الملفات
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Step 3: التحقق من وجود الملفات" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$files = @(
    "lib/screens/auth/phone_registration_screen.dart",
    "lib/services/firebase_phone_auth_service.dart",
    "lib/screens/auth/firebase_otp_verification_screen.dart",
    "lib/screens/auth/login_screen.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Print-Success "Found: $file"
    } else {
        Print-Error "Missing: $file"
    }
}

# Step 4: التحقق من Firebase
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Step 4: التحقق من Firebase" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$pubspecContent = Get-Content pubspec.yaml -Raw
if ($pubspecContent -match "firebase_core") {
    Print-Success "Firebase dependencies found"
} else {
    Print-Warning "Firebase dependencies may not be installed"
}

# Step 5: عرض الأجهزة المتاحة
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Step 5: الأجهزة المتاحة" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

flutter devices
Write-Host ""

# Step 6: تشغيل التطبيق
$runApp = Read-Host "هل تريد تشغيل التطبيق الآن؟ (y/n)"

if ($runApp -eq "y" -or $runApp -eq "Y") {
    Print-Info "Starting application..."
    Write-Host ""
    flutter run
} else {
    Print-Info "Skipped running the application"
}

# الملخص النهائي
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    Setup Complete! 🎉                         ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host ""
Write-Host "📋 ملخص الإجراءات المنجزة:" -ForegroundColor Blue
Print-Success "Project cleaned"
Print-Success "Dependencies fetched"
Print-Success "Verified essential files"
Print-Success "Firebase configuration checked"

Write-Host ""
Write-Host "🎯 الخطوات التالية:" -ForegroundColor Blue
Write-Host "1. تفعيل Phone Authentication في Firebase Console" -ForegroundColor White
Write-Host "2. اختبار التسجيل برقم الهاتف" -ForegroundColor White
Write-Host "3. استقبال OTP عبر SMS" -ForegroundColor White
Write-Host "4. التحقق من الرمز والدخول" -ForegroundColor White

Write-Host ""
Write-Host "📖 الملفات المرجعية:" -ForegroundColor Blue
Write-Host "├─ OTP_FIREBASE_FINAL_SUMMARY.md       (الملخص الشامل)" -ForegroundColor White
Write-Host "├─ FIREBASE_OTP_COMPLETE_SOLUTION.md   (الحل الكامل)" -ForegroundColor White
Write-Host "├─ FIREBASE_OTP_QUICK_SETUP.md         (البدء السريع)" -ForegroundColor White
Write-Host "└─ FIREBASE_OTP_PHONE_REGISTRATION_FIX.md (تفاصيل الإصلاح)" -ForegroundColor White

Write-Host ""
Write-Host "💡 نصيحة: اقرأ OTP_FIREBASE_FINAL_SUMMARY.md أولاً" -ForegroundColor Yellow
Write-Host ""
