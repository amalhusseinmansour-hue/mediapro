<?php

$hosts = [
    'localhost',
    '127.0.0.1',
    'mediaprosocial.io',
    'mysql.mediaprosocial.io',
    'db.mediaprosocial.io',
];

$username = 'u126213189';
$password = 'Alenwanapp33510421@';
$database = 'u126213189_socialmedia_ma';

echo "Testing database connections...\n";
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

foreach ($hosts as $host) {
    echo "Testing: $host ... ";

    try {
        $dsn = "mysql:host=$host;dbname=$database;charset=utf8mb4";
        $pdo = new PDO($dsn, $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_TIMEOUT => 5,
        ]);

        echo "✅ SUCCESS!\n";
        echo "  → Connected to database successfully\n";
        echo "  → This is the correct host: $host\n\n";

        // Try to query users table
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "  → Users table exists with {$result['count']} records\n\n";

        break;

    } catch (PDOException $e) {
        echo "❌ Failed\n";
        echo "  → Error: " . $e->getMessage() . "\n\n";
    }
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
