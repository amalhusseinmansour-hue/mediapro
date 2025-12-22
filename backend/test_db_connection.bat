@echo off
REM Database Connection Test Script
REM اختبار الاتصال بـ MySQL

echo.
echo ============================================
echo   Database Connection Test
echo ============================================
echo.

set DB_HOST=localhost
set DB_USER=u126213189
set DB_PASSWORD=Alenwanapp33510421@
set DB_NAME=u126213189_socialmedia_ma

echo 📊 محاولة الاتصال بـ MySQL...
echo Host: %DB_HOST%
echo User: %DB_USER%
echo Database: %DB_NAME%
echo.

mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% -e "SELECT 'Connection Successful!' as Status; SHOW TABLES;" 2>&1

if errorlevel 1 (
    echo.
    echo ❌ فشل الاتصال!
    echo.
    echo المشاكل المحتملة:
    echo 1. كلمة المرور خاطئة
    echo 2. اسم Host خاطئ
    echo 3. MySQL لا يعمل
    echo 4. اسم Database خاطئ
    echo.
    echo جرب هذه الخيارات:
    echo - Host: localhost. (مع نقطة)
    echo - Host: 127.0.0.1
    echo - Host: sql.mediaprosocial.io
    echo - Host: mysql.hostinger.com
    echo.
) else (
    echo.
    echo ✅ الاتصال نجح!
    echo الآن يمكنك تشغيل الـ Migrations
    echo.
)

pause
