<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\DB;

echo "=== تنظيف البيانات التجريبية ===\n\n";

// حذف المستخدمين التجريبيين (رقم الهاتف يبدأ بـ +966540224811 أو البريد يحتوي على test/example)
$testUsers = User::where(function($query) {
    $query->where('phone_number', 'like', '+966540224811%')
          ->orWhere('email', 'like', '%test%')
          ->orWhere('email', 'like', '%example.com%')
          ->orWhere('name', 'like', 'User %')
          ->orWhere('name', 'like', 'Test %');
})->where('is_admin', false)->get();

echo "عدد المستخدمين التجريبيين المراد حذفهم: " . $testUsers->count() . "\n";

if ($testUsers->count() > 0) {
    foreach ($testUsers as $user) {
        echo "- حذف المستخدم: {$user->name} ({$user->email}) - {$user->phone_number}\n";
    }

    $deleted = User::where(function($query) {
        $query->where('phone_number', 'like', '+966540224811%')
              ->orWhere('email', 'like', '%test%')
              ->orWhere('email', 'like', '%example.com%')
              ->orWhere('name', 'like', 'User %')
              ->orWhere('name', 'like', 'Test %');
    })->where('is_admin', false)->delete();

    echo "\n✓ تم حذف $deleted مستخدم تجريبي\n";
} else {
    echo "✓ لا يوجد مستخدمين تجريبيين للحذف\n";
}

echo "\n=== إحصائيات قاعدة البيانات ===\n";
echo "عدد المستخدمين الحاليين: " . User::count() . "\n";
echo "عدد المديرين: " . User::where('is_admin', true)->count() . "\n";

echo "\n✓ تم الانتهاء من التنظيف!\n";
