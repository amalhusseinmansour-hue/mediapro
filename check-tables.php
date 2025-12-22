<?php
/**
 * Check Database Tables
 *
 * رفع هذا الملف إلى: /public_html
 * ثم افتح: https://mediaprosocial.io/check-tables.php
 */

// Change to the Laravel root directory
chdir(__DIR__);

// Load Laravel
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';

// Boot the application
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "<pre>";
echo "===========================================\n";
echo "فحص قاعدة البيانات\n";
echo "===========================================\n\n";

try {
    // Get database name
    $database = DB::connection()->getDatabaseName();
    echo "قاعدة البيانات: " . $database . "\n\n";

    // Check if tables exist
    echo "-------------------------------------------\n";
    echo "الجداول الموجودة:\n";
    echo "-------------------------------------------\n";

    $tables = DB::select('SHOW TABLES');
    $tableNames = [];

    foreach ($tables as $table) {
        $tableName = array_values((array) $table)[0];
        $tableNames[] = $tableName;
        echo "✓ " . $tableName . "\n";
    }

    echo "\n";
    echo "-------------------------------------------\n";
    echo "فحص الجداول المطلوبة:\n";
    echo "-------------------------------------------\n";

    $requiredTables = [
        'users',
        'website_requests',
        'sponsored_ad_requests',
        'migrations'
    ];

    $missingTables = [];

    foreach ($requiredTables as $tableName) {
        if (in_array($tableName, $tableNames)) {
            echo "✅ " . $tableName . " - موجود\n";
        } else {
            echo "❌ " . $tableName . " - غير موجود\n";
            $missingTables[] = $tableName;
        }
    }

    echo "\n";

    if (empty($missingTables)) {
        echo "🎉 جميع الجداول موجودة!\n\n";

        // Check if there are any website requests
        $websiteRequestsCount = DB::table('website_requests')->count();
        $sponsoredAdsCount = DB::table('sponsored_ad_requests')->count();

        echo "-------------------------------------------\n";
        echo "إحصائيات:\n";
        echo "-------------------------------------------\n";
        echo "عدد طلبات المواقع: " . $websiteRequestsCount . "\n";
        echo "عدد طلبات الإعلانات: " . $sponsoredAdsCount . "\n";

    } else {
        echo "⚠️ جداول مفقودة: " . implode(', ', $missingTables) . "\n";
        echo "يجب تشغيل Migrations!\n";
        echo "\nافتح: https://mediaprosocial.io/run-migrations.php\n";
    }

    echo "\n";
    echo "===========================================\n";

} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
    echo "\n" . $e->getTraceAsString() . "\n";
}

echo "</pre>";

echo "<br><br>";
echo "<a href='https://mediaprosocial.io/admin' style='padding: 10px 20px; background: #4CAF50; color: white; text-decoration: none; border-radius: 4px;'>فتح لوحة التحكم</a>";
