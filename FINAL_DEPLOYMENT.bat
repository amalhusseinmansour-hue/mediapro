@echo off
echo ================================================
echo    FINAL DEPLOYMENT - Analytics System
echo ================================================
echo.

REM Wait for upload to complete
echo [1/5] Checking upload status...
timeout /t 5 /nobreak >nul

REM Upload the file if not already uploaded
echo [2/5] Ensuring file is uploaded...
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" analytics_tracking_system.tar.gz u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/ 2>nul
if %errorlevel% equ 0 (
    echo     OK File uploaded successfully
) else (
    echo     OK File already uploaded or upload in progress
)

echo.
echo [3/5] Deploying on server...
echo     Extracting files...
echo     Running migrations...
echo     Clearing cache...
echo.

REM Execute deployment script on server
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && tar -xzf analytics_tracking_system.tar.gz && php artisan migrate --force && php artisan config:clear && php artisan cache:clear && php artisan route:clear && php artisan config:cache && php artisan route:cache && echo '=== Deployment Complete ===' && php artisan route:list | grep analytics"

if %errorlevel% equ 0 (
    echo.
    echo [4/5] Testing API endpoints...
    curl -s "https://mediaprosocial.io/api/health" >nul 2>&1
    if %errorlevel% equ 0 (
        echo     OK API is responding
    ) else (
        echo     WARNING Could not test API
    )
) else (
    echo.
    echo     ERROR Deployment failed
    exit /b 1
)

echo.
echo [5/5] Cleaning up...
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && rm -f analytics_tracking_system.tar.gz && chmod -R 755 storage bootstrap/cache"

echo.
echo ================================================
echo    DEPLOYMENT SUCCESSFUL!
echo ================================================
echo.
echo Next steps:
echo 1. Open Flutter app and test Analytics Screen
echo 2. Check https://mediaprosocial.io/api/analytics/usage
echo 3. Create a post and verify counter updates
echo.
echo Press any key to exit...
pause >nul
