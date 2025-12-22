@echo off
REM Try Different Database Hosts
REM تجربة أسماء Host مختلفة

echo.
echo ================================================
echo   Trying Different Database Hosts
echo   تجربة أسماء Host مختلفة
echo ================================================
echo.

setlocal enabledelayedexpansion

set DB_USER=u126213189
set DB_PASSWORD=Alenwanapp33510421@
set DB_NAME=u126213189_socialmedia_ma

REM Array of hosts to try
set hosts[0]=localhost
set hosts[1]=localhost.
set hosts[2]=127.0.0.1
set hosts[3]=sql.mediaprosocial.io
set hosts[4]=mysql.mediaprosocial.io
set hosts[5]=db.mediaprosocial.io
set hosts[6]=database.mediaprosocial.io

echo Testing different hosts...
echo.

for /L %%i in (0,1,6) do (
    set host=!hosts[%%i]!
    echo Trying: !host!
    mysql -h !host! -u !DB_USER! -p!DB_PASSWORD! !DB_NAME! -e "SELECT 'Success!' as Status;" 2>nul
    if !errorlevel! equ 0 (
        echo ✅ SUCCESS with host: !host!
        echo Update your .env:
        echo   DB_HOST=!host!
        pause
        exit /b 0
    ) else (
        echo ❌ Failed with !host!
    )
    echo.
)

echo.
echo ❌ None of the hosts worked!
echo.
echo Please contact Hosting Provider for correct DB_HOST
echo.

pause
