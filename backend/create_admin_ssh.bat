@echo off
echo ================================================
echo Connecting to Production Server...
echo ================================================
echo.
echo Server: 82.25.83.217
echo Port: 65002
echo User: u126213189
echo.
echo When prompted, enter password: gtWD8vyZBXT7qv$
echo.
echo ================================================
echo.

ssh -p 65002 u126213189@82.25.83.217 "cd public_html && pwd && ls -la && php artisan tinker --execute=\"\App\Models\User::updateOrCreate(['email' => 'admin@mediapro.com'], ['name' => 'Admin Manager', 'password' => bcrypt('Admin@12345'), 'is_admin' => true, 'is_active' => true]); echo 'Admin created successfully!';\""

echo.
echo ================================================
echo Done!
echo ================================================
pause
