<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Hash;
use App\Models\User;

echo "Fixing admin passwords...\n\n";

// Password to set
$newPassword = 'Admin@2025!';

// Update admin@mediapro.com
$user1 = User::where('email', 'admin@mediapro.com')->first();
if ($user1) {
    $user1->password = Hash::make($newPassword);
    $user1->save();
    echo "✅ Updated password for: admin@mediapro.com\n";
} else {
    echo "❌ User not found: admin@mediapro.com\n";
}

// Update admin@example.com
$user2 = User::where('email', 'admin@example.com')->first();
if ($user2) {
    $user2->password = Hash::make($newPassword);
    $user2->save();
    echo "✅ Updated password for: admin@example.com\n";
} else {
    echo "❌ User not found: admin@example.com\n";
}

echo "\n✅ All admin passwords have been updated!\n";
echo "New password: $newPassword\n";
