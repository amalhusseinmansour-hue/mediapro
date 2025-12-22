<?php
require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

header('Content-Type: text/plain; charset=utf-8');

// قراءة آخر 100 سطر من ملف الـ log
$logFile = storage_path('logs/laravel.log');

if (file_exists($logFile)) {
    $lines = file($logFile);
    $lastLines = array_slice($lines, -100);
    echo "=== آخر 100 سطر من سجل الأخطاء ===\n\n";
    echo implode('', $lastLines);
} else {
    echo "ملف السجل غير موجود: $logFile";
}
