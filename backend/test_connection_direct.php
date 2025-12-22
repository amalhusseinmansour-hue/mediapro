<?php
// Direct PDO connection test

$hosts = [
    'localhost',
    '127.0.0.1',
    'localhost.',
    'sql.mediaprosocial.io',
    'mysql.mediaprosocial.io',
    'mediaprosocial.io'
];

$username = 'u126213189';
$password = 'v.J6H3Re28AXT-T';
$database = 'u126213189_socialmedia_ma';
$port = 3306;

echo "========== DATABASE CONNECTION TEST ==========\n\n";
echo "Username: $username\n";
echo "Database: $database\n";
echo "Password: ••••••••••\n";
echo "Testing 6 hosts...\n\n";

foreach ($hosts as $host) {
    echo "Testing: $host ... ";
    
    try {
        $dsn = "mysql:host=$host;port=$port;dbname=$database;charset=utf8mb4";
        $pdo = new PDO($dsn, $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_TIMEOUT => 5
        ]);
        
        // Test connection
        $result = $pdo->query('SELECT 1');
        echo "✅ SUCCESS!\n";
        echo "   Host: $host\n";
        echo "   Connection established successfully!\n\n";
        
    } catch (PDOException $e) {
        $error = $e->getMessage();
        if (strpos($error, '1045') !== false) {
            echo "❌ Access denied [1045]\n";
        } elseif (strpos($error, '2002') !== false) {
            echo "❌ Host not found [2002]\n";
        } else {
            echo "❌ Error: " . substr($error, 0, 100) . "\n";
        }
    }
}

echo "\n========== END TEST ==========\n";
?>
