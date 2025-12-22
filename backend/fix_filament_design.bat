@echo off
REM ============================================
REM   Filament Admin Panel Design Fix Script
REM   إصلاح تصميم Filament
REM ============================================

setlocal enabledelayedexpansion

cd /d "%~dp0"

echo.
echo ============================================
echo   🎨 إصلاح تصميم Filament Admin Panel
echo ============================================
echo.

REM Colors (Windows doesn't support colors in batch, so we use text)
echo 📦 الخطوة 1: تثبيت Dependencies...
call npm install
if !errorlevel! neq 0 (
    echo ❌ خطأ في تثبيت npm
    exit /b 1
)

echo.
echo 🔨 الخطوة 2: بناء CSS/Tailwind...
call npm run build
if !errorlevel! neq 0 (
    echo ❌ خطأ في بناء CSS
    exit /b 1
)

echo.
echo 📂 الخطوة 3: تحديث Filament Assets...
call php artisan filament:install
call php artisan filament:assets

echo.
echo 🔗 الخطوة 4: إنشاء Storage Link...
call php artisan storage:link

echo.
echo 🧹 الخطوة 5: مسح الكاش...
call php artisan cache:clear
call php artisan config:clear
call php artisan view:clear

echo.
echo ============================================
echo ✅ تم الإصلاح بنجاح!
echo.
echo 🌐 الآن زر: https://mediaprosocial.io/admin/login
echo.
echo ✨ التصميم يجب أن يظهر بشكل جميل الآن
echo ============================================
echo.

pause
