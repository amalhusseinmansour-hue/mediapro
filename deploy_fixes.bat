@echo off
REM Deployment script for fixes to production server
REM This script connects via SSH and applies all critical fixes

echo.
echo ==========================================
echo Deploying Critical Fixes to Production
echo ==========================================
echo.

setlocal enabledelayedexpansion

REM SSH connection details
set SERVER=82.25.83.217
set PORT=65002
set USER=u126213189
set PASSWORD=Alenwanapp33510421@
set BACKEND_PATH=~/public_html/backend

REM Create SSH command script
(
  echo cd ~/public_html/backend
  echo.
  echo echo Backing up .env...
  echo cp .env .env.backup.^!date +\%%Y\%%m\%%d_\%%H\%%M\%%S^!
  echo.
  echo echo Updating .env with critical fixes...
  echo sed -i "s/^DB_HOST=.*/DB_HOST=82.25.83.217/" .env
  echo sed -i "s/^SESSION_LIFETIME=.*/SESSION_LIFETIME=480/" .env
  echo sed -i "s/^SESSION_DOMAIN=.*/SESSION_DOMAIN=.mediaprosocial.io/" .env
  echo sed -i "s/^CACHE_STORE=.*/CACHE_STORE=database/" .env
  echo grep -q "^COOKIE_DOMAIN=" .env ^|^| echo "COOKIE_DOMAIN=.mediaprosocial.io" ^>^> .env
  echo grep -q "^COOKIE_SECURE=" .env ^|^| echo "COOKIE_SECURE=true" ^>^> .env
  echo grep -q "^COOKIE_HTTP_ONLY=" .env ^|^| echo "COOKIE_HTTP_ONLY=true" ^>^> .env
  echo grep -q "^COOKIE_SAME_SITE=" .env ^|^| echo "COOKIE_SAME_SITE=Lax" ^>^> .env
  echo.
  echo echo Clearing Laravel caches...
  echo php artisan config:clear
  echo php artisan cache:clear
  echo php artisan view:clear
  echo php artisan optimize:clear
  echo.
  echo echo Testing database connection...
  echo php artisan tinker ^<^< 'TINKER'
  echo try {
  echo   DB::connection(^)::getPdo(^);
  echo   echo "Database connection successful\n";
  echo } catch (\Exception $e^) {
  echo   echo "Database connection failed: " . $e-^>getMessage(^) . "\n";
  echo }
  echo exit;
  echo TINKER
  echo.
  echo echo ==========================================
  echo echo Deployment Complete!
  echo echo ==========================================
) > ssh_commands.txt

echo Running SSH deployment...
ssh -p %PORT% %USER%@%SERVER% -i ssh_commands.txt

echo.
echo Deployment completed!
echo.
echo Next steps:
echo 1. Test admin login at: https://mediaprosocial.io/admin/login
echo 2. Use credentials: admin@mediapro.com / Admin@12345
echo 3. If 419 error persists, check: storage/logs/laravel.log
echo 4. If database fails, run: php artisan cache:table ^&^& php artisan migrate
echo.

pause
