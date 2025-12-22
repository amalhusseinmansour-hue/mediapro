<?php
/**
 * Simple Admin Creator - Run via SSH
 * Command: php admin_creator.php
 */

echo "\n";
echo "==========================================\n";
echo "  Creating Admin User\n";
echo "==========================================\n\n";

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Http\Kernel');
$response = $kernel->handle(
    $request = \Illuminate\Http\Request::capture()
);

use App\Models\User;

try {
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

    echo "✅ SUCCESS! Admin user created!\n\n";
    echo "==========================================\n";
    echo "  Login Credentials\n";
    echo "==========================================\n";
    echo "📧 Email:    admin@mediapro.com\n";
    echo "🔐 Password: Admin@12345\n";
    echo "🌐 URL:      https://mediaprosocial.io/admin/login\n";
    echo "🆔 User ID:  {$user->id}\n";
    echo "==========================================\n\n";

} catch (\Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n\n";
    exit(1);
}
