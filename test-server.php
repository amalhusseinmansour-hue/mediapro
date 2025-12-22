<?php
/**
 * Server Test File
 * ارفع هذا الملف إلى: /public_html
 * افتح: https://mediaprosocial.io/test-server.php
 */

echo "<pre>";
echo "===========================================\n";
echo "فحص السيرفر\n";
echo "===========================================\n\n";

// 1. Current directory
echo "المسار الحالي:\n";
echo __DIR__ . "\n\n";

// 2. Check if Laravel exists
echo "-------------------------------------------\n";
echo "فحص ملفات Laravel:\n";
echo "-------------------------------------------\n";

$files = [
    'vendor/autoload.php' => 'Composer Autoload',
    'bootstrap/app.php' => 'Laravel Bootstrap',
    'artisan' => 'Artisan CLI',
    '.env' => 'Environment File',
    'app/Filament/Resources/WebsiteRequestResource.php' => 'WebsiteRequestResource',
    'app/Filament/Resources/SponsoredAdRequestResource.php' => 'SponsoredAdRequestResource',
];

foreach ($files as $file => $name) {
    if (file_exists(__DIR__ . '/' . $file)) {
        echo "✅ " . $name . " - موجود\n";
        echo "   (" . $file . ")\n";
    } else {
        echo "❌ " . $name . " - غير موجود\n";
        echo "   (" . $file . ")\n";
    }
}

echo "\n";
echo "-------------------------------------------\n";
echo "محتويات المجلد الحالي:\n";
echo "-------------------------------------------\n";

$contents = scandir(__DIR__);
foreach ($contents as $item) {
    if ($item === '.' || $item === '..') continue;

    if (is_dir(__DIR__ . '/' . $item)) {
        echo "📁 " . $item . "/\n";
    } else {
        echo "📄 " . $item . "\n";
    }
}

echo "\n";
echo "-------------------------------------------\n";
echo "محتويات مجلد app (إذا كان موجوداً):\n";
echo "-------------------------------------------\n";

if (is_dir(__DIR__ . '/app')) {
    $appContents = scandir(__DIR__ . '/app');
    foreach ($appContents as $item) {
        if ($item === '.' || $item === '..') continue;
        echo "📁 app/" . $item . "\n";
    }
} else {
    echo "❌ مجلد app غير موجود\n";
}

echo "\n";
echo "===========================================\n";

// Try to load Laravel
echo "\nمحاولة تحميل Laravel:\n";
echo "-------------------------------------------\n";

try {
    if (file_exists(__DIR__ . '/vendor/autoload.php')) {
        require __DIR__ . '/vendor/autoload.php';
        echo "✅ Composer Autoload تم تحميله\n";

        if (file_exists(__DIR__ . '/bootstrap/app.php')) {
            $app = require_once __DIR__ . '/bootstrap/app.php';
            echo "✅ Laravel App تم تحميله\n";

            $kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
            $kernel->bootstrap();
            echo "✅ Laravel Kernel تم تحميله\n";

            // Get database info
            echo "\nمعلومات قاعدة البيانات:\n";
            echo "-------------------------------------------\n";
            $database = DB::connection()->getDatabaseName();
            echo "اسم قاعدة البيانات: " . $database . "\n";

            // Test connection
            try {
                DB::connection()->getPdo();
                echo "✅ الاتصال بقاعدة البيانات ناجح\n";

                // Check tables
                $tables = DB::select('SHOW TABLES');
                echo "\nعدد الجداول: " . count($tables) . "\n";

                $requiredTables = ['website_requests', 'sponsored_ad_requests'];
                foreach ($requiredTables as $table) {
                    $exists = false;
                    foreach ($tables as $t) {
                        $tableName = array_values((array) $t)[0];
                        if ($tableName === $table) {
                            $exists = true;
                            break;
                        }
                    }

                    if ($exists) {
                        echo "✅ جدول " . $table . " موجود\n";
                    } else {
                        echo "❌ جدول " . $table . " مفقود\n";
                    }
                }

            } catch (Exception $e) {
                echo "❌ خطأ في الاتصال: " . $e->getMessage() . "\n";
            }

        } else {
            echo "❌ bootstrap/app.php غير موجود\n";
        }
    } else {
        echo "❌ vendor/autoload.php غير موجود\n";
    }
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
}

echo "\n";
echo "===========================================\n";
echo "نهاية الفحص\n";
echo "===========================================\n";

echo "</pre>";
