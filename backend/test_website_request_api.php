<?php

// اختبار API لطلب موقع إلكتروني
$url = 'https://mediaprosocial.io/api/website-requests';

$data = [
    'name' => 'أحمد محمد',
    'email' => 'ahmed@example.com',
    'phone' => '+966501234567',
    'company_name' => 'شركة الاختبار',
    'website_type' => 'corporate',
    'description' => 'نريد موقع إلكتروني احترافي لشركتنا',
    'budget' => 5000,
    'currency' => 'SAR',
    'deadline' => date('Y-m-d', strtotime('+30 days')),
    'features' => ['responsive', 'cms', 'seo']
];

echo "=== اختبار API لطلب موقع إلكتروني ===\n";
echo "URL: $url\n";
echo "البيانات المرسلة:\n";
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

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
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Status Code: $httpCode\n";
if ($error) {
    echo "CURL Error: $error\n";
}
echo "الرد من السيرفر:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

if ($httpCode === 201) {
    echo "\n✓ تم إرسال الطلب بنجاح!\n";
} else {
    echo "\n✗ فشل إرسال الطلب!\n";
}
