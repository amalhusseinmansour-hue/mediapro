<?php

$host = '82.25.83.217';
$dbname = 'u126213189_socialmedia_ma';
$username = 'u126213189';
$password = 'Alenwanapp33510421@';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Connected to database successfully!\n\n";

    $sql = "INSERT INTO users (
        name, email, password, is_admin, is_active,
        user_type, email_verified_at, created_at, updated_at
    ) VALUES (
        'Admin User',
        'admin@mediapro.com',
        '\$2y\$12\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        1, 1, 'admin', NOW(), NOW(), NOW()
    )";

    $pdo->exec($sql);

    echo "✓ Admin user created successfully!\n";
    echo "Email: admin@mediapro.com\n";
    echo "Password: password\n";
    echo "\nYou can now login with these credentials.\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
