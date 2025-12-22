<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Http\Kernel');
$response = $kernel->handle(
    $request = \Illuminate\Http\Request::capture()
);

use App\Models\User;

try {
    // Create or update admin user
    $user = User::updateOrCreate(
        ['email' => 'admin@mediapro.com'],
        [
            'name' => 'Admin Manager',
            'email' => 'admin@mediapro.com',
            'password' => bcrypt('Admin@12345'),
            'is_admin' => true,
            'is_active' => true,
        ]
    );

    echo "\n";
    echo "✅ Admin User Created Successfully!\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "📧 Email: admin@mediapro.com\n";
    echo "🔐 Password: Admin@12345\n";
    echo "🌐 Login URL: https://mediaprosocial.io/admin/login\n";
    echo "✓ User ID: " . $user->id . "\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "\n";

} catch (\Exception $e) {
    echo "\n";
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n";
}
