@echo off
echo ========================================
echo الحصول على SHA-1 Fingerprint
echo ========================================
echo.

cd /d "%~dp0android"

echo [1/2] تشغيل Gradle...
echo.

call gradlew.bat signingReport

echo.
echo ========================================
echo انتهى!
echo ========================================
echo.
echo ابحث في النتيجة أعلاه عن:
echo SHA1: XX:XX:XX:...
echo.
pause
