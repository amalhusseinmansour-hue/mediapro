# Reset Admin Password for MediaPro Social
# PowerShell Script

Write-Host "🔄 Resetting admin password for MediaPro Social..." -ForegroundColor Cyan

# Navigate to Laravel backend
Set-Location "c:\Users\HP\social_media_manager\backend"

# Create admin user using raw PHP
$phpCode = @"
<?php
require_once 'vendor/autoload.php';
require_once 'bootstrap/app.php';

use App\Models\User;
use Illuminate\Support\Facades\Hash;

try {
    // Find or create admin user
    `$admin = User::where('email', 'admin@mediapro.com')->first();
    
    if (!`$admin) {
        `$admin = User::create([
            'name' => 'Admin User',
            'email' => 'admin@mediapro.com',
            'password' => Hash::make('Admin@2025'),
            'is_admin' => true,
            'is_active' => true,
            'user_type' => 'admin',
            'email_verified_at' => now()
        ]);
        echo '✅ New admin user created successfully!\n';
    } else {
        `$admin->password = Hash::make('Admin@2025');
        `$admin->is_admin = true;
        `$admin->is_active = true;
        `$admin->save();
        echo '✅ Admin password updated successfully!\n';
    }
    
    echo 'Admin Credentials:\n';
    echo 'Email: admin@mediapro.com\n';
    echo 'Password: Admin@2025\n';
    echo 'Admin Status: ' . (`$admin->is_admin ? 'YES' : 'NO') . '\n';
    
} catch (Exception `$e) {
    echo '❌ Error: ' . `$e->getMessage() . '\n';
}
?>
"@

# Save PHP code to temporary file
$phpCode | Out-File -FilePath "temp_admin_reset.php" -Encoding UTF8

# Execute the PHP script
Write-Host "Executing admin reset..." -ForegroundColor Yellow
php temp_admin_reset.php

# Clean up
Remove-Item "temp_admin_reset.php" -ErrorAction SilentlyContinue

Write-Host "🎉 Admin reset process completed!" -ForegroundColor Green