@echo off
chcp 65001 >nul
echo ========================================
echo   🚀 اختبار وتشغيل التطبيق (مع التعديلات)
echo ========================================
echo.
cd /d "%~dp0"

echo [1/4] ✏️  تطبيق التعديلات التلقائية (تغيير الاسم)...
set "MANIFEST_FILE=%~dp0android\app\src\main\AndroidManifest.xml"
if exist "%MANIFEST_FILE%" (
    powershell -Command "(Get-Content -path '%MANIFEST_FILE%' -Raw) -replace 'android:label=\"[^\"]*\"', 'android:label=\"MEDIA PRO\"' | Set-Content -Path '%MANIFEST_FILE%'"
    echo    - تم تحديث اسم التطبيق إلى "MEDIA PRO".
)
echo.

echo [2/4] تنظيف المشروع...
call flutter clean
echo.

echo [3/4] تحميل التبعيات...
call flutter pub get
echo.

echo [4/4] تشغيل التطبيق على الهاتف...
echo.
echo ملاحظات الاختبار:
echo ----------------
echo 1. OTP: أدخل أي رقم من 6 أرقام (مثل: 123456)
echo 2. الاشتراكات: افتح صفحة الباقات وتحقق من ظهور البيانات
echo 3. راقب console logs لرؤية:
echo    - "✅ OTP format valid"
echo    - "✅ Loaded X plans from Laravel"
echo.
echo اضغط أي مفتاح لبدء التشغيل...
pause >nul

echo.
echo جاري التشغيل...
call flutter run

echo.
echo ========================================
echo انتهى الاختبار
echo ========================================
pause
