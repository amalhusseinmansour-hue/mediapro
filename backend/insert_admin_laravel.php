<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Http\Kernel');
$response = $kernel->handle(
    $request = \Illuminate\Http\Request::capture()
);

use Illuminate\Support\Facades\DB;

try {
    // Execute the raw SQL
    DB::statement("INSERT INTO users (
        name, email, password, is_admin, is_active,
        user_type, email_verified_at, created_at, updated_at
    ) VALUES (
        'Admin User',
        'admin@mediapro.com',
        '\$2y\$12\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        1, 1, 'admin', NOW(), NOW(), NOW()
    )");

    echo "✓ Admin user created successfully!\n";
    echo "Email: admin@mediapro.com\n";
    echo "Password: password\n";
    echo "\nYou can now login with these credentials.\n";

} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";

    // If user already exists, show helpful message
    if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
        echo "\nThe admin user already exists. You can login with:\n";
        echo "Email: admin@mediapro.com\n";
        echo "Password: password (or the current password)\n";
    }
    exit(1);
}
