<?php

// Test registration with the exact same data from Flutter app
$url = 'https://mediaprosocial.io/api/auth/register';

// First test: With the phone number that already exists (should fail with validation error)
$data = [
    'name' => 'User 4811',
    'email' => 'loloamoola1992@gmail.com',
    'password' => 'Aa33510421@',
    'password_confirmation' => 'Aa33510421@',
    'phone_number' => '+966540224811',
    'user_type' => 'individual'
];

echo "=== Test 1: Duplicate phone number (should get validation error) ===\n";
echo "Testing registration with:\n";
echo json_encode($data, JSON_PRETTY_PRINT) . "\n\n";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status Code: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n\n";

// Second test: With a new phone number (should succeed)
$data2 = [
    'name' => 'User 4811',
    'email' => 'loloamoola1992@gmail.com',
    'password' => 'Aa33510421@',
    'password_confirmation' => 'Aa33510421@',
    'phone_number' => '+966540229999', // Different phone number
    'user_type' => 'individual'
];

echo "\n=== Test 2: New phone number but duplicate email (should get validation error) ===\n";
echo "Testing registration with:\n";
echo json_encode($data2, JSON_PRETTY_PRINT) . "\n\n";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data2));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status Code: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";
