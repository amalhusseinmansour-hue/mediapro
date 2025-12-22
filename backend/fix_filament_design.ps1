# ============================================
# Filament Admin Panel Design Fix Script
# إصلاح تصميم Filament Admin
# ============================================

# Set Error Action
$ErrorActionPreference = "Continue"

# Colors
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$White = "White"

# Header
Write-Host ""
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host "   🎨 إصلاح تصميم Filament Admin Panel" -ForegroundColor $Green
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host ""

# Change to backend directory
Push-Location (Split-Path $MyInvocation.MyCommand.Path)

# Step 1: Install Dependencies
Write-Host "📦 الخطوة 1: تثبيت Dependencies..." -ForegroundColor $Yellow
Write-Host "تشغيل: npm install" -ForegroundColor $White
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ خطأ في تثبيت npm" -ForegroundColor $Red
    Pop-Location
    exit 1
}
Write-Host "✅ تم التثبيت بنجاح" -ForegroundColor $Green
Write-Host ""

# Step 2: Build CSS/Tailwind
Write-Host "🔨 الخطوة 2: بناء CSS/Tailwind..." -ForegroundColor $Yellow
Write-Host "تشغيل: npm run build" -ForegroundColor $White
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ خطأ في بناء CSS" -ForegroundColor $Red
    Pop-Location
    exit 1
}
Write-Host "✅ تم البناء بنجاح" -ForegroundColor $Green
Write-Host ""

# Step 3: Update Filament Assets
Write-Host "📂 الخطوة 3: تحديث Filament Assets..." -ForegroundColor $Yellow
Write-Host "تشغيل: php artisan filament:install" -ForegroundColor $White
php artisan filament:install | Out-Null
Write-Host "تشغيل: php artisan filament:assets" -ForegroundColor $White
php artisan filament:assets | Out-Null
Write-Host "✅ تم التحديث بنجاح" -ForegroundColor $Green
Write-Host ""

# Step 4: Create Storage Link
Write-Host "🔗 الخطوة 4: إنشاء Storage Link..." -ForegroundColor $Yellow
Write-Host "تشغيل: php artisan storage:link" -ForegroundColor $White
php artisan storage:link 2>&1 | Out-Null
Write-Host "✅ تم الإنشاء بنجاح" -ForegroundColor $Green
Write-Host ""

# Step 5: Clear Cache
Write-Host "🧹 الخطوة 5: مسح الكاش..." -ForegroundColor $Yellow
Write-Host "تشغيل: php artisan cache:clear" -ForegroundColor $White
php artisan cache:clear | Out-Null
Write-Host "تشغيل: php artisan config:clear" -ForegroundColor $White
php artisan config:clear | Out-Null
Write-Host "تشغيل: php artisan view:clear" -ForegroundColor $White
php artisan view:clear | Out-Null
Write-Host "✅ تم مسح الكاش بنجاح" -ForegroundColor $Green
Write-Host ""

# Success Message
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host "✅ تم الإصلاح بنجاح!" -ForegroundColor $Green
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host ""
Write-Host "🌐 الآن زر الـ URL:" -ForegroundColor $Cyan
Write-Host "   https://mediaprosocial.io/admin/login" -ForegroundColor $Green
Write-Host ""
Write-Host "✨ التصميم يجب أن يظهر بشكل جميل الآن" -ForegroundColor $Green
Write-Host ""
Write-Host "📝 ملاحظات مهمة:" -ForegroundColor $Yellow
Write-Host "   1. تأكد من أن Laravel Running" -ForegroundColor $White
Write-Host "   2. إذا لم يعمل, شغّل: npm run build مرة أخرى" -ForegroundColor $White
Write-Host "   3. امسح الكوكيز من المتصفح" -ForegroundColor $White
Write-Host "   4. جرّب الـ Incognito Mode" -ForegroundColor $White
Write-Host ""

# Restore Location
Pop-Location

Write-Host "Press Enter to exit..." -ForegroundColor $Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
