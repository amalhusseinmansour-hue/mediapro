<?php

// Quick Admin User Creation Script
// إنشاء Admin User بسرعة

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Http\Kernel');
$response = $kernel->handle(
    $request = \Illuminate\Http\Request::capture()
);

use App\Models\User;

try {
    // Delete existing if exists
    User::where('email', 'admin@mediapro.com')->delete();
    
    // Create new admin
    $user = User::create([
        'name' => 'Admin Manager',
        'email' => 'admin@mediapro.com',
        'password' => bcrypt('Admin@12345'),
        'is_admin' => true,
    ]);
    
    echo "✅ Admin User Created Successfully!\n";
    echo "📧 Email: admin@mediapro.com\n";
    echo "🔐 Password: Admin@12345\n";
    echo "✓ ID: " . $user->id . "\n";
    
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
