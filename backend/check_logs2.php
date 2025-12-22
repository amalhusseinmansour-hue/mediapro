<?php
require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

header('Content-Type: text/plain; charset=utf-8');

$logFile = storage_path('logs/laravel.log');

if (file_exists($logFile)) {
    $content = file_get_contents($logFile);
    // البحث عن آخر خطأ
    preg_match_all('/\[[\d-]+ [\d:]+\] production\.ERROR: (.+?) \{/', $content, $matches);

    echo "=== آخر 10 أخطاء ===\n\n";
    $errors = array_slice($matches[1], -10);
    foreach ($errors as $i => $error) {
        echo ($i + 1) . ". " . $error . "\n\n";
    }
} else {
    echo "ملف السجل غير موجود";
}
