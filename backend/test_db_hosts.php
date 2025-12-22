<?php

// Database Connection Test
echo "Testing Database Connection...\n\n";

$hosts = [
    'localhost',
    'localhost.',
    '127.0.0.1',
    'sql.mediaprosocial.io',
    'mysql.mediaprosocial.io',
];

$user = 'u126213189';
$password = 'Alenwanapp33510421@';
$database = 'u126213189_socialmedia_ma';

foreach ($hosts as $host) {
    echo "Testing: $host\n";
    
    try {
        $pdo = new PDO(
            "mysql:host=$host;port=3306;dbname=$database",
            $user,
            $password,
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
        
        echo "✅ SUCCESS with host: $host\n";
        echo "Update your .env with: DB_HOST=$host\n";
        
        $pdo = null;
        exit(0);
        
    } catch (PDOException $e) {
        echo "❌ Failed: " . $e->getMessage() . "\n\n";
    }
}

echo "\n❌ All hosts failed!\n";
echo "Please contact Hosting Provider for correct DB_HOST\n";
