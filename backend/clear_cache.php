<?php
require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Artisan;

header('Content-Type: text/plain; charset=utf-8');

echo "تنظيف الكاش...\n\n";

try {
    Artisan::call('config:clear');
    echo "✅ config:clear\n";

    Artisan::call('cache:clear');
    echo "✅ cache:clear\n";

    Artisan::call('route:clear');
    echo "✅ route:clear\n";

    Artisan::call('view:clear');
    echo "✅ view:clear\n";

    // إعادة بناء الكاش
    Artisan::call('config:cache');
    echo "✅ config:cache\n";

    echo "\n🎉 تم تنظيف الكاش بنجاح!\n";
} catch (\Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
}
