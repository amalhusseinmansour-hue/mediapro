# Simple Admin Password Update Script


Write-Host "Updating admin password..." -ForegroundColor Green

# Navigate to project directory
cd "c:\Users\HP\social_media_manager\backend"

# Create simple PHP script
$phpCode = @'
<?php
require_once 'vendor/autoload.php';
require_once 'bootstrap/app.php';

use App\Models\User;
use Illuminate\Support\Facades\Hash;

try {
    // Find admin user
    $user = User::where('email', 'admin@mediapro.com')->first();
    
    if (!$user) {
        echo "User not found, creating new admin...\n";
        $user = User::create([
            'name' => 'Admin User',
            'email' => 'admin@mediapro.com',
            'password' => Hash::make('Admin@2025'),
            'is_admin' => true,
            'is_active' => true,
            'user_type' => 'admin',
            'email_verified_at' => now(),
        ]);
        echo "New admin user created!\n";
    } else {
        // Update existing user
        $user->password = Hash::make('Admin@2025');
        $user->is_admin = true;
        $user->is_active = true;
        $user->save();
        echo "Password updated successfully!\n";
    }
    
    echo "Login credentials:\n";
    echo "Email: admin@mediapro.com\n";
    echo "Password: Admin@2025\n";
    echo "URL: https://mediaprosocial.io/admin/login\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
'@

# Save PHP script
$phpCode | Out-File -FilePath "update_password.php" -Encoding UTF8

# Execute script
Write-Host "Executing password update..." -ForegroundColor Yellow
php update_password.php

# Cleanup
Remove-Item "update_password.php" -ErrorAction SilentlyContinue

Write-Host "Done!" -ForegroundColor Green