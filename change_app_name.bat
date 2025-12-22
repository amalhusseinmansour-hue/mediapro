@echo off
chcp 65001 >nul
echo ========================================
echo   ✏️  تغيير اسم التطبيق إلى "MEDIA PRO"
echo ========================================
echo.

set "MANIFEST_FILE=%~dp0android\app\src\main\AndroidManifest.xml"

echo [1/2] البحث عن ملف AndroidManifest.xml...
if not exist "%MANIFEST_FILE%" (
    echo ❌ لم يتم العثور على الملف:
    echo %MANIFEST_FILE%
    echo.
    echo تأكد من تشغيل هذا الملف من المجلد الرئيسي للمشروع.
    pause
    exit /b
)
echo ✓ تم العثور على الملف.
echo.

echo [2/2] جاري تعديل android:label إلى "MEDIA PRO"...
powershell -Command "(Get-Content -path '%MANIFEST_FILE%' -Raw) -replace 'android:label=\"[^\"]*\"', 'android:label=\"MEDIA PRO\"' | Set-Content -Path '%MANIFEST_FILE%'"

echo.
echo ========================================
echo ✅ تم تغيير اسم التطبيق بنجاح!
echo.
echo 💡 ملاحظة: عند بناء نسخة APK جديدة، سيظهر اسم التطبيق "MEDIA PRO" على الهاتف.
echo ========================================
echo.
pause