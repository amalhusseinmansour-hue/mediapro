<?php
/**
 * Test All API Endpoints
 * هذا الملف يختبر جميع endpoints في Laravel API
 */

$baseUrl = 'https://mediaprosocial.io/api';
$token = ''; // سيتم تحديثه بعد التسجيل

// تلوين النتائج
function colorLog($message, $type = 'info') {
    $colors = [
        'success' => "\033[32m", // أخضر
        'error' => "\033[31m",   // أحمر
        'info' => "\033[36m",    // أزرق
        'warning' => "\033[33m", // أصفر
    ];
    $reset = "\033[0m";
    echo $colors[$type] . $message . $reset . "\n";
}

function makeRequest($method, $url, $data = null, $token = null) {
    $ch = curl_init();

    $headers = [
        'Content-Type: application/json',
        'Accept: application/json',
    ];

    if ($token) {
        $headers[] = 'Authorization: Bearer ' . $token;
    }

    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);

    if ($data && in_array($method, ['POST', 'PUT', 'PATCH'])) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }

    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);

    curl_close($ch);

    return [
        'code' => $httpCode,
        'response' => json_decode($response, true),
        'error' => $error,
        'raw' => $response
    ];
}

echo "\n";
colorLog("═══════════════════════════════════════════════════", 'info');
colorLog("      اختبار جميع Laravel API Endpoints", 'info');
colorLog("═══════════════════════════════════════════════════", 'info');
echo "\n";

// 1. Test Health Check
colorLog("📋 1. Testing Health Check...", 'info');
$result = makeRequest('GET', "$baseUrl/health");
if ($result['code'] == 200) {
    colorLog("✅ Health Check: SUCCESS", 'success');
    print_r($result['response']);
} else {
    colorLog("❌ Health Check: FAILED (HTTP {$result['code']})", 'error');
    echo $result['raw'] . "\n";
}
echo "\n";

// 2. Test User Registration
colorLog("📋 2. Testing User Registration...", 'info');
$testUser = [
    'name' => 'Test User ' . time(),
    'email' => 'test' . time() . '@example.com',
    'password' => 'password123',
    'password_confirmation' => 'password123',
];
$result = makeRequest('POST', "$baseUrl/auth/register", $testUser);
if ($result['code'] == 200 || $result['code'] == 201) {
    colorLog("✅ User Registration: SUCCESS", 'success');
    if (isset($result['response']['access_token'])) {
        $token = $result['response']['access_token'];
        colorLog("   Token: " . substr($token, 0, 20) . "...", 'info');
    }
    print_r($result['response']);
} else {
    colorLog("❌ User Registration: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 3. Test Phone Registration
colorLog("📋 3. Testing Phone Registration...", 'info');
$phoneUser = [
    'phoneNumber' => '+966500000' . rand(100, 999),
    'email' => 'phone' . time() . '@example.com',
    'name' => 'Phone User ' . time(),
];
$result = makeRequest('POST', "$baseUrl/auth/register", $phoneUser);
if ($result['code'] == 200 || $result['code'] == 201) {
    colorLog("✅ Phone Registration: SUCCESS", 'success');
    if (isset($result['response']['access_token']) && !$token) {
        $token = $result['response']['access_token'];
    }
    print_r($result['response']);
} else {
    colorLog("❌ Phone Registration: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 4. Test Login
colorLog("📋 4. Testing Login...", 'info');
$loginData = [
    'email' => $testUser['email'],
    'password' => $testUser['password'],
];
$result = makeRequest('POST', "$baseUrl/auth/login", $loginData);
if ($result['code'] == 200) {
    colorLog("✅ Login: SUCCESS", 'success');
    if (isset($result['response']['access_token'])) {
        $token = $result['response']['access_token'];
        colorLog("   Token Updated", 'info');
    }
    print_r($result['response']);
} else {
    colorLog("❌ Login: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

if (!$token) {
    colorLog("⚠️ No token available. Cannot test protected endpoints.", 'warning');
    exit;
}

// 5. Test Get Current User
colorLog("📋 5. Testing Get Current User...", 'info');
$result = makeRequest('GET', "$baseUrl/auth/user", null, $token);
if ($result['code'] == 200) {
    colorLog("✅ Get Current User: SUCCESS", 'success');
    print_r($result['response']);
} else {
    colorLog("❌ Get Current User: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 6. Test Get All Users
colorLog("📋 6. Testing Get All Users...", 'info');
$result = makeRequest('GET', "$baseUrl/users", null, $token);
if ($result['code'] == 200) {
    colorLog("✅ Get All Users: SUCCESS", 'success');
    colorLog("   Total Users: " . count($result['response']['data'] ?? []), 'info');
} else {
    colorLog("❌ Get All Users: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 7. Test Create User
colorLog("📋 7. Testing Create User (Admin)...", 'info');
$newUser = [
    'name' => 'Admin Created User',
    'email' => 'admin' . time() . '@example.com',
    'password' => 'password123',
];
$result = makeRequest('POST', "$baseUrl/users", $newUser, $token);
if ($result['code'] == 200 || $result['code'] == 201) {
    colorLog("✅ Create User: SUCCESS", 'success');
    $createdUserId = $result['response']['user']['id'] ?? null;
    print_r($result['response']);
} else {
    colorLog("❌ Create User: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 8. Test Get User by ID
if (isset($createdUserId)) {
    colorLog("📋 8. Testing Get User by ID...", 'info');
    $result = makeRequest('GET', "$baseUrl/users/$createdUserId", null, $token);
    if ($result['code'] == 200) {
        colorLog("✅ Get User by ID: SUCCESS", 'success');
        print_r($result['response']);
    } else {
        colorLog("❌ Get User by ID: FAILED (HTTP {$result['code']})", 'error');
        print_r($result['response']);
    }
    echo "\n";
}

// 9. Test Update User
if (isset($createdUserId)) {
    colorLog("📋 9. Testing Update User...", 'info');
    $updateData = [
        'name' => 'Updated User Name',
    ];
    $result = makeRequest('PUT', "$baseUrl/users/$createdUserId", $updateData, $token);
    if ($result['code'] == 200) {
        colorLog("✅ Update User: SUCCESS", 'success');
        print_r($result['response']);
    } else {
        colorLog("❌ Update User: FAILED (HTTP {$result['code']})", 'error');
        print_r($result['response']);
    }
    echo "\n";
}

// 10. Test Wallet - Get User Wallet
colorLog("📋 10. Testing Get User Wallet...", 'info');
$userId = $result['response']['user']['id'] ?? '1'; // استخدم ID المستخدم الحالي
$result = makeRequest('GET', "$baseUrl/wallets/$userId", null, $token);
if ($result['code'] == 200) {
    colorLog("✅ Get Wallet: SUCCESS", 'success');
    print_r($result['response']);
} else {
    colorLog("❌ Get Wallet: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 11. Test Wallet - Get Transactions
colorLog("📋 11. Testing Get Wallet Transactions...", 'info');
$result = makeRequest('GET', "$baseUrl/wallets/$userId/transactions", null, $token);
if ($result['code'] == 200) {
    colorLog("✅ Get Transactions: SUCCESS", 'success');
    colorLog("   Total Transactions: " . count($result['response']['transactions'] ?? []), 'info');
} else {
    colorLog("❌ Get Transactions: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 12. Test Wallet - Credit (Admin)
colorLog("📋 12. Testing Credit Wallet (Admin)...", 'info');
$creditData = [
    'amount' => 100.50,
    'description' => 'Test Credit',
    'reference_id' => 'TEST-' . time(),
];
$result = makeRequest('POST', "$baseUrl/wallets/$userId/credit", $creditData, $token);
if ($result['code'] == 200) {
    colorLog("✅ Credit Wallet: SUCCESS", 'success');
    print_r($result['response']);
} else {
    colorLog("❌ Credit Wallet: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 13. Test Wallet - Debit
colorLog("📋 13. Testing Debit Wallet...", 'info');
$debitData = [
    'amount' => 10.00,
    'description' => 'Test Debit',
    'reference_id' => 'DEBIT-' . time(),
];
$result = makeRequest('POST', "$baseUrl/wallets/$userId/debit", $debitData, $token);
if ($result['code'] == 200) {
    colorLog("✅ Debit Wallet: SUCCESS", 'success');
    print_r($result['response']);
} else {
    colorLog("❌ Debit Wallet: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 14. Test Wallet - Statistics (Admin)
colorLog("📋 14. Testing Wallet Statistics...", 'info');
$result = makeRequest('GET', "$baseUrl/wallets/statistics/all", null, $token);
if ($result['code'] == 200) {
    colorLog("✅ Wallet Statistics: SUCCESS", 'success');
    print_r($result['response']);
} else {
    colorLog("❌ Wallet Statistics: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// 15. Test Subscription - Create
colorLog("📋 15. Testing Create Subscription...", 'info');
// ملاحظة: يحتاج plan_id موجود في قاعدة البيانات
$subscriptionData = [
    'plan_id' => 1, // افترض أن هناك plan بهذا الـ ID
    'payment_method' => 'stripe',
];
$result = makeRequest('POST', "$baseUrl/subscriptions", $subscriptionData, $token);
if ($result['code'] == 200 || $result['code'] == 201) {
    colorLog("✅ Create Subscription: SUCCESS", 'success');
    $subscriptionId = $result['response']['id'] ?? null;
    print_r($result['response']);
} else {
    colorLog("⚠️ Create Subscription: FAILED (HTTP {$result['code']}) - May need valid plan_id", 'warning');
    print_r($result['response']);
}
echo "\n";

// 16. Test Delete User
if (isset($createdUserId)) {
    colorLog("📋 16. Testing Delete User...", 'info');
    $result = makeRequest('DELETE', "$baseUrl/users/$createdUserId", null, $token);
    if ($result['code'] == 200) {
        colorLog("✅ Delete User: SUCCESS", 'success');
        print_r($result['response']);
    } else {
        colorLog("❌ Delete User: FAILED (HTTP {$result['code']})", 'error');
        print_r($result['response']);
    }
    echo "\n";
}

// 17. Test Logout
colorLog("📋 17. Testing Logout...", 'info');
$result = makeRequest('POST', "$baseUrl/auth/logout", null, $token);
if ($result['code'] == 200) {
    colorLog("✅ Logout: SUCCESS", 'success');
    print_r($result['response']);
} else {
    colorLog("❌ Logout: FAILED (HTTP {$result['code']})", 'error');
    print_r($result['response']);
}
echo "\n";

// Summary
colorLog("═══════════════════════════════════════════════════", 'info');
colorLog("      انتهى الاختبار", 'success');
colorLog("═══════════════════════════════════════════════════", 'info');
echo "\n";
