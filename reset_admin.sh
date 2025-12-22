#!/bin/bash

# Reset admin password script for MediaPro Social

echo "🔄 Resetting admin password for MediaPro Social..."

# Navigate to Laravel backend
cd /path/to/backend || exit 1

# Method 1: Using Artisan Tinker
echo "Method 1: Using Laravel Tinker"
php artisan tinker --execute="
\$admin = App\Models\User::where('email', 'admin@mediapro.com')->first();
if (!\$admin) {
    \$admin = App\Models\User::create([
        'name' => 'Admin User',
        'email' => 'admin@mediapro.com', 
        'password' => Hash::make('Admin@2025'),
        'is_admin' => true,
        'is_active' => true,
        'user_type' => 'admin',
        'email_verified_at' => now()
    ]);
    echo 'New admin user created';
} else {
    \$admin->password = Hash::make('Admin@2025');
    \$admin->is_admin = true;
    \$admin->is_active = true;
    \$admin->save();
    echo 'Admin password updated';
}
echo PHP_EOL . 'Admin credentials:' . PHP_EOL;
echo 'Email: admin@mediapro.com' . PHP_EOL;
echo 'Password: Admin@2025' . PHP_EOL;
"

echo "✅ Admin password reset completed!"