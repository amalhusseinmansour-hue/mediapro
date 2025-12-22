@echo off
REM ============================================
REM   Fix Filament CSS in Production
REM   إصلاح CSS الفيلمنت في Production
REM ============================================

echo.
echo ============================================
echo   Fixing Filament CSS...
echo ============================================
echo.

cd /d "%~dp0backend" || (
    echo Error: Could not change to backend directory
    pause
    exit /b 1
)

echo [1/5] Building with Vite...
call npm run build
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo [2/5] Clearing cache...
call php artisan cache:clear

echo.
echo [3/5] Clearing config...
call php artisan config:clear

echo.
echo [4/5] Clearing views...
call php artisan view:clear

echo.
echo [5/5] Checking build files...
if exist public\build\manifest.json (
    echo ✓ Build manifest found!
) else (
    echo ✗ WARNING: Build manifest not found!
)

echo.
echo ============================================
echo ✓ DONE!
echo ============================================
echo.
echo Next steps:
echo 1. Clear browser cache (Ctrl+Shift+Delete)
echo 2. Reload page (Ctrl+F5)
echo 3. Visit: https://mediaprosocial.io/admin/login
echo.
pause
