<?php
/**
 * Final Fix for 419 Page Expired Error
 * Upload this to your server root and run: php fix_419_final.php
 * Then delete this file
 */

echo "\n";
echo "==========================================\n";
echo "  Fixing 419 Page Expired Error\n";
echo "==========================================\n\n";

$envPath = __DIR__ . '/.env';

if (!file_exists($envPath)) {
    die("❌ Error: .env file not found!\n");
}

$envContent = file_get_contents($envPath);
$changes = [];

// 1. Disable session encryption (main fix)
if (strpos($envContent, 'SESSION_ENCRYPT=true') !== false) {
    $envContent = str_replace('SESSION_ENCRYPT=true', 'SESSION_ENCRYPT=false', $envContent);
    $changes[] = 'SESSION_ENCRYPT changed to false';
} else if (strpos($envContent, 'SESSION_ENCRYPT=false') === false) {
    // Add it if missing
    $envContent = preg_replace('/(SESSION_PATH=.*)/', "$1\nSESSION_ENCRYPT=false", $envContent);
    $changes[] = 'SESSION_ENCRYPT=false added';
}

// 2. Ensure APP_URL is correct
if (strpos($envContent, 'APP_URL=https://mediaprosocial.io') === false) {
    $envContent = preg_replace('/APP_URL=.*/', 'APP_URL=https://mediaprosocial.io', $envContent);
    $changes[] = 'APP_URL updated to https://mediaprosocial.io';
}

// 3. Ensure SESSION_DOMAIN is null
if (strpos($envContent, 'SESSION_DOMAIN=null') === false) {
    $envContent = preg_replace('/SESSION_DOMAIN=.*/', 'SESSION_DOMAIN=null', $envContent);
    $changes[] = 'SESSION_DOMAIN set to null';
}

// Write changes
file_put_contents($envPath, $envContent);

echo "✅ Changes Applied:\n";
foreach ($changes as $change) {
    echo "   - $change\n";
}

echo "\n";

// Clear caches
echo "Clearing caches...\n";

if (file_exists(__DIR__ . '/artisan')) {
    exec('php artisan config:clear 2>&1', $output);
    echo implode("\n", $output) . "\n";

    exec('php artisan cache:clear 2>&1', $output);
    echo implode("\n", $output) . "\n";

    exec('php artisan view:clear 2>&1', $output);
    echo implode("\n", $output) . "\n";
}

// Clear session files
$sessionsPath = __DIR__ . '/storage/framework/sessions';
if (is_dir($sessionsPath)) {
    $files = glob($sessionsPath . '/*');
    foreach ($files as $file) {
        if (is_file($file) && basename($file) !== '.gitignore') {
            unlink($file);
        }
    }
    echo "✅ Session files cleared\n";
}

echo "\n";
echo "==========================================\n";
echo "  Fix Complete!\n";
echo "==========================================\n";
echo "\n";
echo "Next steps:\n";
echo "1. Delete this file (fix_419_final.php)\n";
echo "2. Clear your browser cache/cookies\n";
echo "3. Go to: https://mediaprosocial.io/admin/login\n";
echo "4. Login with:\n";
echo "   Email: admin@mediapro.com\n";
echo "   Password: Admin@12345\n";
echo "\n";
