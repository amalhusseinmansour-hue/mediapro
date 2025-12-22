<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$columns = Illuminate\Support\Facades\DB::select("SHOW COLUMNS FROM users WHERE Field IN ('phone', 'phone_number', 'user_type')");

echo "Columns found:\n";
foreach ($columns as $col) {
    echo "Field: " . $col->Field . "\n";
    echo "Type: " . $col->Type . "\n";
    echo "Null: " . $col->Null . "\n";
    echo "Default: " . ($col->Default ?? 'NULL') . "\n";
    echo "---\n";
}
