# ============================================
# Fix Filament CSS in Production
# إصلاح CSS الفيلمنت في Production
# ============================================

$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

Write-Host ""
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host "   🎨 إصلاح CSS الفيلمنت" -ForegroundColor $Green
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host ""

# Change to backend directory
$backendPath = Join-Path $PSScriptRoot "backend"
if (-not (Test-Path $backendPath)) {
    Write-Host "❌ Backend directory not found!" -ForegroundColor $Red
    exit 1
}

Push-Location $backendPath

try {
    # Step 1: Build
    Write-Host "[1/5] 🔨 بناء الـ CSS مع Vite..." -ForegroundColor $Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ خطأ في البناء!" -ForegroundColor $Red
        exit 1
    }
    Write-Host "✓ تم البناء بنجاح" -ForegroundColor $Green
    Write-Host ""

    # Step 2: Clear cache
    Write-Host "[2/5] 🧹 مسح الكاش..." -ForegroundColor $Yellow
    php artisan cache:clear | Out-Null
    Write-Host "✓ تم مسح الكاش" -ForegroundColor $Green
    Write-Host ""

    # Step 3: Clear config
    Write-Host "[3/5] ⚙️  مسح الإعدادات..." -ForegroundColor $Yellow
    php artisan config:clear | Out-Null
    Write-Host "✓ تم مسح الإعدادات" -ForegroundColor $Green
    Write-Host ""

    # Step 4: Clear views
    Write-Host "[4/5] 👁️  مسح الـ Views..." -ForegroundColor $Yellow
    php artisan view:clear | Out-Null
    Write-Host "✓ تم مسح الـ Views" -ForegroundColor $Green
    Write-Host ""

    # Step 5: Verify build
    Write-Host "[5/5] ✓ التحقق من الملفات المبنية..." -ForegroundColor $Yellow
    if (Test-Path "public\build\manifest.json") {
        Write-Host "✓ Build manifest موجود!" -ForegroundColor $Green
    } else {
        Write-Host "⚠️  تحذير: Build manifest غير موجود!" -ForegroundColor $Yellow
    }
    Write-Host ""

    # Success message
    Write-Host "============================================" -ForegroundColor $Cyan
    Write-Host "✅ تم الإصلاح بنجاح!" -ForegroundColor $Green
    Write-Host "============================================" -ForegroundColor $Cyan
    Write-Host ""
    
    Write-Host "📋 الخطوات التالية:" -ForegroundColor $Yellow
    Write-Host "   1. امسح كاش المتصفح (Ctrl+Shift+Delete)" -ForegroundColor $Cyan
    Write-Host "   2. أعد تحميل الصفحة (Ctrl+F5)" -ForegroundColor $Cyan
    Write-Host "   3. زر: https://mediaprosocial.io/admin/login" -ForegroundColor $Cyan
    Write-Host ""
    
    Write-Host "✨ التصميم يجب أن يظهر الآن!" -ForegroundColor $Green
    Write-Host ""

}
catch {
    Write-Host "❌ خطأ: $_" -ForegroundColor $Red
    exit 1
}
finally {
    Pop-Location
}

Write-Host "Press Enter to exit..." -ForegroundColor $Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
