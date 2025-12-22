@echo off
echo ====================================
echo اصلاح Sidebar في Filament
echo ====================================
echo.

echo 1. مسح الكاش...
php artisan optimize:clear
php artisan filament:optimize-clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
echo تم مسح الكاش
echo.

echo 2. تحديث Autoloader...
composer dump-autoload
echo تم التحديث
echo.

echo 3. اختبار المسارات...
echo.
echo صفحة طلبات المواقع:
echo https://mediaprosocial.io/admin/website-requests
echo.
echo صفحة الاعلانات الممولة:
echo https://mediaprosocial.io/admin/sponsored-ad-requests
echo.

echo ====================================
echo انتهى! افتح المسارات اعلاه
echo ====================================
pause
