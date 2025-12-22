<?php
/**
 * Run Laravel Migrations
 *
 * رفع هذا الملف إلى: /public_html
 * ثم افتح: https://mediaprosocial.io/run-migrations.php
 * ثم احذف الملف فوراً!
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
echo "تشغيل Migrations\n";
echo "===========================================\n\n";

try {
    // Run migrations
    $exitCode = Artisan::call('migrate', [
        '--force' => true,
    ]);

    echo Artisan::output();

    if ($exitCode === 0) {
        echo "\n✅ تم تشغيل Migrations بنجاح!\n\n";
    } else {
        echo "\n❌ حدث خطأ أثناء تشغيل Migrations\n";
        echo "Exit Code: " . $exitCode . "\n\n";
    }

    // Show current tables
    echo "-------------------------------------------\n";
    echo "الجداول الموجودة:\n";
    echo "-------------------------------------------\n";

    $tables = DB::select('SHOW TABLES');
    foreach ($tables as $table) {
        $tableName = array_values((array) $table)[0];
        echo "✓ " . $tableName . "\n";
    }

    echo "\n";
    echo "===========================================\n";
    echo "✅ انتهى!\n";
    echo "===========================================\n";

} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
    echo "\n" . $e->getTraceAsString() . "\n";
}

echo "</pre>";

echo "<br><br>";
echo "<strong style='color: red;'>⚠️ هام: احذف هذا الملف الآن!</strong>";
echo "<br>";
echo "<a href='#' onclick='deleteFile(); return false;' style='color: blue; text-decoration: underline;'>اضغط هنا لحذف الملف</a>";

echo "<script>
function deleteFile() {
    if (confirm('هل تريد حذف هذا الملف؟')) {
        fetch('run-migrations.php', { method: 'DELETE' })
            .then(() => {
                alert('تم الحذف! يرجى التأكد يدوياً من cPanel');
                window.close();
            });
    }
}
</script>";
