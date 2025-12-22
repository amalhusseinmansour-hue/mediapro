<?php
// Test file to check PHP and Laravel setup
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "<h1>Server Test</h1>";

// Test 1: PHP Version
echo "<h2>1. PHP Version</h2>";
echo "PHP Version: " . phpversion() . "<br>";
echo "Required: 8.2 or higher<br>";

// Test 2: Check if vendor exists
echo "<h2>2. Vendor Directory</h2>";
if (file_exists(__DIR__.'/../vendor/autoload.php')) {
    echo "✅ Vendor directory exists<br>";
    require __DIR__.'/../vendor/autoload.php';
} else {
    echo "❌ Vendor directory NOT found - Run 'composer install'<br>";
    die();
}

// Test 3: Check .env file
echo "<h2>3. Environment File</h2>";
if (file_exists(__DIR__.'/../.env')) {
    echo "✅ .env file exists<br>";
} else {
    echo "❌ .env file NOT found<br>";
}

// Test 4: Check storage permissions
echo "<h2>4. Storage Permissions</h2>";
$storagePath = __DIR__.'/../storage/logs';
if (is_writable($storagePath)) {
    echo "✅ Storage directory is writable<br>";
} else {
    echo "❌ Storage directory is NOT writable<br>";
}

// Test 5: Try to load Laravel
echo "<h2>5. Laravel Bootstrap</h2>";
try {
    $app = require_once __DIR__.'/../bootstrap/app.php';
    echo "✅ Laravel app loaded successfully<br>";

    // Test database connection
    echo "<h2>6. Database Connection</h2>";
    try {
        $pdo = new PDO(
            'mysql:host=127.0.0.1;dbname=socialmedia_manager',
            'admin_mediapro',
            '3e8tWh72~'
        );
        echo "✅ Database connection successful<br>";
    } catch (Exception $e) {
        echo "❌ Database connection failed: " . $e->getMessage() . "<br>";
    }

} catch (Exception $e) {
    echo "❌ Laravel failed to load: " . $e->getMessage() . "<br>";
    echo "<pre>" . $e->getTraceAsString() . "</pre>";
}

echo "<h2>Done!</h2>";
