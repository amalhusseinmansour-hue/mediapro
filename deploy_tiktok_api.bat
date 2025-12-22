@echo off
echo ================================================
echo   رفع TikTok API Files إلى السيرفر
echo ================================================
echo.

echo الخطوة 1: رفع ApifyTikTokService.php...
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" backend\app\Services\ApifyTikTokService.php u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Services/
echo.

echo الخطوة 2: رفع TikTokAnalyticsController.php...
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" backend\app\Http\Controllers\Api\TikTokAnalyticsController.php u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/Api/
echo.

echo الخطوة 3: رفع routes/api.php...
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" backend\routes\api.php u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/routes/
echo.

echo الخطوة 4: رفع config/services.php...
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" backend\config\services.php u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/config/
echo.

echo الخطوة 5: تحديث ملف .env...
echo ملاحظة: يجب عليك إضافة APIFY_API_TOKEN يدوياً في ملف .env
echo.

echo الخطوة 6: تنظيف الكاش...
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan config:clear && php artisan cache:clear && php artisan route:clear && echo 'Cache cleared successfully'"
echo.

echo الخطوة 7: إعادة بناء الكاش...
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan config:cache && php artisan route:cache && echo 'Cache rebuilt successfully'"
echo.

echo ================================================
echo   اكتمل الرفع بنجاح!
echo ================================================
echo.
echo الخطوات التالية:
echo 1. احصل على API Token من Apify.com
echo 2. أضف APIFY_API_TOKEN في ملف .env على السيرفر
echo 3. راجع ملف دليل_استخدام_TikTok_Apify.md للتفاصيل
echo.
pause
