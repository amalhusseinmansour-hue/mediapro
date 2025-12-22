<?php

// Test registration with the exact same data from Flutter app
$url = 'https://mediaprosocial.io/api/auth/register';

$data = [
    'name' => 'User 4811',
    'email' => 'testuser' . rand(1000, 9999) . '@example.com', // Using a random email to avoid duplicates
    'password' => '33510421',
    'password_confirmation' => '33510421',
    'phone_number' => '+966540224811',
    'user_type' => 'individual'
];

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
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";

if ($httpCode === 201) {
    echo "\n✓ Registration successful!\n";
} else {
    echo "\n✗ Registration failed!\n";
}
