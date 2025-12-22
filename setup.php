<?php
// نسخ هذا الكود كاملاً
// ثم في cPanel File Manager:
// 1. اضغط "+ File"
// 2. اسم الملف: setup.php
// 3. الصق الكود هنا
// 4. احفظ
// 5. افتح: https://mediaprosocial.io/setup.php

chdir(__DIR__);
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "<pre style='background:#000;color:#0f0;padding:20px;font-family:monospace'>";
echo "========================================\n";
echo "تشغيل باقات الاشتراك\n";
echo "========================================\n\n";

// 1. Migration
echo "1. Migration...\n";
Artisan::call('migrate', ['--force' => true, '--path' => 'database/migrations/2025_01_09_000002_add_audience_type_to_subscription_plans.php']);
echo Artisan::output() . "\n";

// 2. Seeder
echo "2. Seeder...\n";
Artisan::call('db:seed', ['--class' => 'SubscriptionPlanSeeder', '--force' => true]);
echo Artisan::output() . "\n";

// 3. Cache
echo "3. Cache...\n";
Artisan::call('optimize:clear');
echo "✓ Done\n\n";

// 4. Results
$ind = DB::table('subscription_plans')->where('audience_type', 'individual')->count();
$bus = DB::table('subscription_plans')->where('audience_type', 'business')->count();

echo "========================================\n";
echo "✓ باقات الأفراد: $ind\n";
echo "✓ باقات الأعمال: $bus\n";
echo "========================================\n";
echo "\nAPI: /api/subscription-plans/individual\n";
echo "</pre>";
echo "<h3 style='color:red'>⚠️ احذف هذا الملف الآن!</h3>";
