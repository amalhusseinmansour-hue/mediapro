<?php
/**
 * 🔐 OAuth Credentials Update Script
 *
 * استخدم هذا السكريبت لتحديث OAuth credentials على السيرفر
 *
 * Usage:
 * php update_env_credentials.php facebook APP_ID APP_SECRET
 */

// Server Configuration
$serverConfig = [
    'host' => '82.25.83.217',
    'port' => 65002,
    'username' => 'u126213189',
    'password' => 'Alenwanapp33510421@',
    'env_path' => '/home/u126213189/domains/mediaprosocial.io/public_html/.env',
    'app_path' => '/home/u126213189/domains/mediaprosocial.io/public_html',
];

// Platform mappings
$platforms = [
    'facebook' => [
        'client_id_key' => 'FACEBOOK_CLIENT_ID',
        'client_secret_key' => 'FACEBOOK_CLIENT_SECRET',
    ],
    'instagram' => [
        'client_id_key' => 'INSTAGRAM_CLIENT_ID',
        'client_secret_key' => 'INSTAGRAM_CLIENT_SECRET',
    ],
    'linkedin' => [
        'client_id_key' => 'LINKEDIN_CLIENT_ID',
        'client_secret_key' => 'LINKEDIN_CLIENT_SECRET',
    ],
    'twitter' => [
        'client_id_key' => 'TWITTER_CLIENT_ID',
        'client_secret_key' => 'TWITTER_CLIENT_SECRET',
    ],
    'google' => [
        'client_id_key' => 'GOOGLE_CLIENT_ID',
        'client_secret_key' => 'GOOGLE_CLIENT_SECRET',
    ],
    'youtube' => [
        'client_id_key' => 'GOOGLE_CLIENT_ID',
        'client_secret_key' => 'GOOGLE_CLIENT_SECRET',
    ],
    'tiktok' => [
        'client_id_key' => 'TIKTOK_CLIENT_ID',
        'client_secret_key' => 'TIKTOK_CLIENT_SECRET',
    ],
    'snapchat' => [
        'client_id_key' => 'SNAPCHAT_CLIENT_ID',
        'client_secret_key' => 'SNAPCHAT_CLIENT_SECRET',
    ],
];

/**
 * Execute SSH command
 */
function executeSSHCommand($command, $config) {
    $sshCommand = sprintf(
        'plink -batch -P %d -pw "%s" %s@%s "%s" 2>&1',
        $config['port'],
        $config['password'],
        $config['username'],
        $config['host'],
        addslashes($command)
    );

    exec($sshCommand, $output, $returnCode);

    return [
        'success' => $returnCode === 0,
        'output' => implode("\n", $output),
        'code' => $returnCode
    ];
}

/**
 * Update .env value
 */
function updateEnvValue($key, $value, $config) {
    echo "📝 تحديث $key...\n";

    $sedCommand = sprintf(
        "sed -i 's/^%s=.*/%s=%s/' %s",
        $key,
        $key,
        $value,
        $config['env_path']
    );

    $result = executeSSHCommand($sedCommand, $config);

    if ($result['success']) {
        echo "✅ تم تحديث $key بنجاح\n";
        return true;
    } else {
        echo "❌ فشل تحديث $key: " . $result['output'] . "\n";
        return false;
    }
}

/**
 * Clear Laravel cache
 */
function clearCache($config) {
    echo "\n🧹 مسح الكاش...\n";

    $clearCommands = [
        'config:clear',
        'cache:clear',
        'route:clear',
    ];

    $allSuccess = true;

    foreach ($clearCommands as $cmd) {
        $command = sprintf(
            "cd %s && php artisan %s",
            $config['app_path'],
            $cmd
        );

        $result = executeSSHCommand($command, $config);

        if ($result['success']) {
            echo "✅ تم تنفيذ php artisan $cmd\n";
        } else {
            echo "❌ فشل php artisan $cmd\n";
            $allSuccess = false;
        }
    }

    return $allSuccess;
}

/**
 * Verify credentials on server
 */
function verifyCredentials($config) {
    echo "\n🔍 التحقق من البيانات المحفوظة...\n";

    $command = sprintf(
        "cat %s | grep -E '(CLIENT_ID|CLIENT_SECRET)'",
        $config['env_path']
    );

    $result = executeSSHCommand($command, $config);

    if ($result['success']) {
        echo "\n📋 القيم الحالية:\n";
        echo "================================\n";
        echo $result['output'] . "\n";
        echo "================================\n";
        return true;
    }

    return false;
}

/**
 * Main update function
 */
function updatePlatformCredentials($platform, $clientId, $clientSecret, $platforms, $config) {
    if (!isset($platforms[$platform])) {
        echo "❌ منصة غير مدعومة: $platform\n";
        echo "المنصات المدعومة: " . implode(', ', array_keys($platforms)) . "\n";
        return false;
    }

    echo "\n🔐 تحديث بيانات $platform...\n";
    echo "================================\n";

    $platformConfig = $platforms[$platform];

    // Update Client ID
    if (!updateEnvValue($platformConfig['client_id_key'], $clientId, $config)) {
        return false;
    }

    // Update Client Secret
    if (!updateEnvValue($platformConfig['client_secret_key'], $clientSecret, $config)) {
        return false;
    }

    // Clear cache
    if (!clearCache($config)) {
        return false;
    }

    echo "\n✅ تم تحديث $platform بنجاح!\n";
    echo "================================\n";

    return true;
}

// Main execution
if (php_sapi_name() === 'cli') {
    // CLI Mode
    if ($argc < 4) {
        echo "Usage: php update_env_credentials.php <platform> <client_id> <client_secret>\n";
        echo "\nPlatforms: " . implode(', ', array_keys($platforms)) . "\n";
        echo "\nExample:\n";
        echo "  php update_env_credentials.php facebook 123456789 abcdef123456\n";
        exit(1);
    }

    $platform = strtolower($argv[1]);
    $clientId = $argv[2];
    $clientSecret = $argv[3];

    if (updatePlatformCredentials($platform, $clientId, $clientSecret, $platforms, $serverConfig)) {
        echo "\n🎉 تم بنجاح!\n";
        echo "\n🔄 الخطوات التالية:\n";
        echo "1. افتح التطبيق على هاتفك\n";
        echo "2. اذهب إلى إعدادات > ربط الحسابات\n";
        echo "3. اختر $platform\n";
        echo "4. سجل دخول ووافق على الصلاحيات\n";

        // Verify
        verifyCredentials($serverConfig);

        exit(0);
    } else {
        echo "\n❌ حدث خطأ أثناء التحديث\n";
        exit(1);
    }
} else {
    // Web Mode (API)
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        exit;
    }

    $input = json_decode(file_get_contents('php://input'), true);

    if (!isset($input['platform']) || !isset($input['client_id']) || !isset($input['client_secret'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields: platform, client_id, client_secret']);
        exit;
    }

    $platform = strtolower($input['platform']);
    $clientId = $input['client_id'];
    $clientSecret = $input['client_secret'];

    ob_start();
    $success = updatePlatformCredentials($platform, $clientId, $clientSecret, $platforms, $serverConfig);
    $output = ob_get_clean();

    if ($success) {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => "تم تحديث $platform بنجاح",
            'platform' => $platform,
            'output' => $output
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => "فشل تحديث $platform",
            'platform' => $platform,
            'output' => $output
        ]);
    }
}
