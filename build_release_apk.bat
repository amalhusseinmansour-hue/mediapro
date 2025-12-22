@echo off
chcp 65001 >nul
echo ========================================
echo   🚀 بناء نسخة APK نهائية للتطبيق
echo ========================================
echo.

echo [1/4] الانتقال إلى مجلد المشروع...
cd /d "%~dp0"
echo.

echo [2/4] تنظيف المشروع (flutter clean)...
call flutter clean
echo.

echo [3/4] تحميل التبعيات (flutter pub get)...
call flutter pub get
echo.

echo [4/4] بناء نسخة APK النهائية (flutter build apk --release)...
call flutter build apk --release
echo.

echo ========================================
echo ✅ تم بناء نسخة APK بنجاح!
echo.
echo 📍 يمكنك إيجاد الملف هنا:
echo    %~dp0build\app\outputs\flutter-apk\app-release.apk
echo ========================================
echo.
pause