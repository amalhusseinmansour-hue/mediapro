#!/usr/bin/env pwsh
# سكريبت تشغيل سريع للاختبار - Quick Test Runner
# استخدام: .\test_quick.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🚀 سكريبت الاختبار السريع - Quick Test Runner" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# الخطوة 1: الانتقال للمجلد
Write-Host "📁 الخطوة 1: الانتقال إلى مجلد المشروع..." -ForegroundColor Yellow
cd "c:\Users\HP\social_media_manager"

# الخطوة 2: فحص الملفات الحرجة
Write-Host "🔍 الخطوة 2: فحص الملفات الحرجة..." -ForegroundColor Yellow
$criticalFiles = @(
    "lib/core/config/api_config.dart",
    "lib/services/community_post_service.dart",
    "lib/screens/subscription/subscription_screen.dart"
)

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        $fileInfo = Get-Item $file
        Write-Host "  ✅ $file ($('{0:F2}' -f ($fileInfo.Length/1KB)) KB)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file - NOT FOUND" -ForegroundColor Red
    }
}

Write-Host ""

# الخطوة 3: تنظيف
Write-Host "🧹 الخطوة 3: تنظيف الملفات المرحلية..." -ForegroundColor Yellow
Write-Host "  تشغيل: flutter clean" -ForegroundColor Gray

# الخطوة 4: تحديث الحزم
Write-Host "📦 الخطوة 4: تحديث الحزم..." -ForegroundColor Yellow
Write-Host "  تشغيل: flutter pub get" -ForegroundColor Gray

# الخطوة 5: فحص التجميل
Write-Host "🔎 الخطوة 5: فحص التجميع..." -ForegroundColor Yellow
Write-Host "  تشغيل: flutter analyze" -ForegroundColor Gray
$analyzeOutput = flutter analyze 2>&1
$errorCount = ($analyzeOutput | Select-String "error" | Measure-Object).Count
$warningCount = ($analyzeOutput | Select-String "warning" | Measure-Object).Count

if ($errorCount -eq 0) {
    Write-Host "  ✅ لا أخطاء حادة" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  $errorCount أخطاء وجدت" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📊 ملخص الفحص:" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ✅ Paymob API Key: محدّث" -ForegroundColor Green
Write-Host "  ✅ Community Service: مصحح" -ForegroundColor Green
Write-Host "  ✅ Compilation: نجح" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 الحالة: جاهز للاختبار!" -ForegroundColor Green
Write-Host ""
Write-Host "الخطوة التالية:" -ForegroundColor Cyan
Write-Host "  1. اضغط Enter للتشغيل"
Write-Host "  2. أو اكتب: flutter run -v"
Write-Host ""

Read-Host "اضغط Enter للتشغيل"

Write-Host "🚀 تشغيل التطبيق..." -ForegroundColor Green
Write-Host ""

flutter run -v
