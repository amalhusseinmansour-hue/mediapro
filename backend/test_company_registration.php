<?php

// Test registration with company user_type
$url = 'https://mediaprosocial.io/api/auth/register';

$data = [
    'name' => 'Test Company',
    'email' => 'company' . rand(1000, 9999) . '@example.com',
    'password' => '33510421',
    'password_confirmation' => '33510421',
    'phone_number' => '+966540225555',
    'user_type' => 'company',
    'company_name' => 'My Test Company'
];

echo "Testing company registration with:\n";
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
$responseData = json_decode($response, true);
echo json_encode($responseData, JSON_PRETTY_PRINT) . "\n";

if ($httpCode === 201) {
    echo "\n✓ Registration successful!\n";
    echo "User type in DB should be 'business': " . $responseData['user']['user_type'] . "\n";
} else {
    echo "\n✗ Registration failed!\n";
}
