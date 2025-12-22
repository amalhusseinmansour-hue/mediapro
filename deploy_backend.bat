@echo off
REM ========================================
REM Backend Deployment Script (Windows)
REM ========================================
REM This script deploys the Laravel backend to the production server
REM Server: mediaprosocial.io
REM ========================================

setlocal enabledelayedexpansion

REM Server Configuration
set SERVER_USER=u126213189
set SERVER_HOST=82.25.83.217
set SERVER_PORT=65002
set SERVER_PASSWORD=Alenwanapp33510421@
set SERVER_PATH=/home/u126213189/domains/mediaprosocial.io/public_html

REM Local paths
set LOCAL_BACKEND_PATH=backend
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set ARCHIVE_NAME=backend_deployment_%TIMESTAMP%.tar.gz

echo ========================================
echo   Backend Deployment Script
echo ========================================
echo.

REM Step 1: Check if backend directory exists
echo [1/8] Checking backend directory...
if not exist "%LOCAL_BACKEND_PATH%" (
    echo [ERROR] Backend directory not found!
    pause
    exit /b 1
)
echo [OK] Backend directory found
echo.

REM Step 2: Create archive
echo [2/8] Creating deployment archive...
echo This may take a moment...

cd "%LOCAL_BACKEND_PATH%"

REM Create list of files to exclude
(
    echo .env
    echo node_modules
    echo vendor
    echo storage/logs/*
    echo .git
    echo .gitignore
    echo *.log
    echo .phpunit.result.cache
) > ..\exclude_list.txt

REM Create archive using tar
tar --exclude-from="..\exclude_list.txt" -czf "..\%ARCHIVE_NAME%" .

cd ..
del exclude_list.txt

if not exist "%ARCHIVE_NAME%" (
    echo [ERROR] Failed to create archive!
    pause
    exit /b 1
)

for %%A in ("%ARCHIVE_NAME%") do set ARCHIVE_SIZE=%%~zA
echo [OK] Archive created: %ARCHIVE_NAME%
echo.

REM Step 3: Upload archive to server
echo [3/8] Uploading to server...
echo This may take a few minutes depending on your internet speed...

"C:\Program Files\PuTTY\pscp" -P %SERVER_PORT% -pw "%SERVER_PASSWORD%" "%ARCHIVE_NAME%" %SERVER_USER%@%SERVER_HOST%:%SERVER_PATH%/

if errorlevel 1 (
    echo [ERROR] Upload failed!
    echo Cleaning up local archive...
    del "%ARCHIVE_NAME%"
    pause
    exit /b 1
)
echo [OK] Upload completed successfully
echo.

REM Step 4: Verify upload
echo [4/8] Verifying upload...
"C:\Program Files\PuTTY\plink" -batch -P %SERVER_PORT% -pw "%SERVER_PASSWORD%" %SERVER_USER%@%SERVER_HOST% "ls -lh %SERVER_PATH%/%ARCHIVE_NAME%"

if errorlevel 1 (
    echo [ERROR] File not found on server!
    pause
    exit /b 1
)
echo [OK] File verified on server
echo.

REM Step 5: Extract on server
echo [5/8] Extracting files on server...
"C:\Program Files\PuTTY\plink" -batch -P %SERVER_PORT% -pw "%SERVER_PASSWORD%" %SERVER_USER%@%SERVER_HOST% "cd %SERVER_PATH% && tar -xzf %ARCHIVE_NAME% && echo 'Extraction completed'"

if errorlevel 1 (
    echo [ERROR] Extraction failed!
    pause
    exit /b 1
)
echo [OK] Files extracted successfully
echo.

REM Step 6: Run Laravel commands
echo [6/8] Running Laravel setup commands...
echo This will take a few minutes...

"C:\Program Files\PuTTY\plink" -batch -P %SERVER_PORT% -pw "%SERVER_PASSWORD%" %SERVER_USER%@%SERVER_HOST% "cd %SERVER_PATH% && composer install --no-dev --optimize-autoloader && chmod -R 755 storage bootstrap/cache && chmod -R 775 storage/logs && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache && php artisan storage:link && echo 'Laravel setup completed!'"

if errorlevel 1 (
    echo [WARNING] Some Laravel commands may have failed
    echo You may need to run them manually
) else (
    echo [OK] Laravel setup completed
)
echo.

REM Step 7: Cleanup
echo [7/8] Cleaning up...

REM Remove archive from server
"C:\Program Files\PuTTY\plink" -batch -P %SERVER_PORT% -pw "%SERVER_PASSWORD%" %SERVER_USER%@%SERVER_HOST% "rm %SERVER_PATH%/%ARCHIVE_NAME%"

REM Remove local archive
del "%ARCHIVE_NAME%"

echo [OK] Cleanup completed
echo.

REM Step 8: Final verification
echo [8/8] Final verification...
"C:\Program Files\PuTTY\plink" -batch -P %SERVER_PORT% -pw "%SERVER_PASSWORD%" %SERVER_USER%@%SERVER_HOST% "cd %SERVER_PATH% && php artisan --version"

if errorlevel 1 (
    echo [WARNING] Could not verify Laravel installation
) else (
    echo [OK] Deployment verification passed
)
echo.

REM Success message
echo ========================================
echo   Deployment Completed Successfully!
echo ========================================
echo.
echo Next Steps:
echo 1. Update .env file on server with production credentials
echo 2. Run: php artisan key:generate
echo 3. Test API endpoints: https://mediaprosocial.io/api/health
echo 4. Check logs: tail -f storage/logs/laravel.log
echo.
echo WARNING - IMPORTANT:
echo Don't forget to:
echo - Update .env with production credentials
echo - Rotate all API keys (see SECURITY_NOTES.md)
echo - Test all API endpoints
echo - Monitor logs for any errors
echo.
pause
