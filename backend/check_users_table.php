<?php
require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// Get all columns from users table
$columns = Illuminate\Support\Facades\Schema::getColumnListing('users');

echo "Users table columns:\n";
echo "==================\n";
foreach ($columns as $column) {
    echo "- " . $column . "\n";
}

// Check specific columns
$requiredColumns = ['user_type', 'phone', 'is_phone_verified', 'is_admin', 'company_name'];
echo "\nChecking required columns:\n";
echo "=========================\n";
foreach ($requiredColumns as $col) {
    $exists = in_array($col, $columns) ? '✓ EXISTS' : '✗ MISSING';
    echo $col . ": " . $exists . "\n";
}
