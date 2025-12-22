@echo off
echo ====================================
echo   Deploying Updates to Server
echo ====================================
echo.

REM Step 1: Upload Website Request Controller
echo [1/5] Uploading WebsiteRequestController...
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" ^
  "C:\Users\HP\social_media_manager\WEBSITE_REQUEST_CONTROLLER.php" ^
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/WebsiteRequestController.php
if %errorlevel% equ 0 (
    echo [OK] WebsiteRequestController uploaded successfully
) else (
    echo [ERROR] Failed to upload WebsiteRequestController
)
echo.

REM Step 2: Upload Sponsored Ads Controller
echo [2/5] Uploading SponsoredAdsRequestController...
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" ^
  "C:\Users\HP\social_media_manager\SPONSORED_ADS_REQUEST_CONTROLLER.php" ^
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/SponsoredAdsRequestController.php
if %errorlevel% equ 0 (
    echo [OK] SponsoredAdsRequestController uploaded successfully
) else (
    echo [ERROR] Failed to upload SponsoredAdsRequestController
)
echo.

REM Step 3: Upload SQL Migrations (for manual execution)
echo [3/5] Uploading SQL migrations...
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" ^
  "C:\Users\HP\social_media_manager\WEBSITE_REQUESTS_MIGRATION.sql" ^
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/database/migrations/
if %errorlevel% equ 0 (
    echo [OK] WEBSITE_REQUESTS_MIGRATION.sql uploaded successfully
) else (
    echo [WARN] May need to create migrations folder first
)

"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" ^
  "C:\Users\HP\social_media_manager\SPONSORED_ADS_REQUESTS_MIGRATION.sql" ^
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/database/migrations/
if %errorlevel% equ 0 (
    echo [OK] SPONSORED_ADS_REQUESTS_MIGRATION.sql uploaded successfully
) else (
    echo [WARN] May need to create migrations folder first
)
echo.

REM Step 4: Execute SQL migrations on database
echo [4/5] NOTE: Execute SQL migrations manually via phpMyAdmin
echo     - WEBSITE_REQUESTS_MIGRATION.sql
echo     - SPONSORED_ADS_REQUESTS_MIGRATION.sql
echo.
pause
echo.

REM Step 5: Clear Laravel cache
echo [5/5] Clearing Laravel cache...
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" ^
  u126213189@82.25.83.217 ^
  -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" ^
  "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan config:clear && php artisan cache:clear && php artisan route:clear"
if %errorlevel% equ 0 (
    echo [OK] Cache cleared successfully
) else (
    echo [ERROR] Failed to clear cache
)
echo.

echo ====================================
echo   Deployment Complete!
echo ====================================
echo.
echo Next steps:
echo 1. Add routes to routes/api.php (see WEBSITE_REQUEST_ROUTES.php and SPONSORED_ADS_ROUTES.php)
echo 2. Test APIs using provided curl commands
echo 3. Update Flutter app if needed
echo.
pause
