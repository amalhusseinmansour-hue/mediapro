<?php
/**
 * تشغيل Migration وSeeder للباقات
 *
 * رفع هذا الملف إلى: /public_html
 * ثم افتح: https://mediaprosocial.io/run-subscription-plans-migration.php
 * ثم احذف الملف فوراً!
 */

// Change to Laravel root
chdir(__DIR__);

echo "<!DOCTYPE html><html><head><meta charset='UTF-8'>";
echo "<style>body{font-family:Arial;padding:20px;background:#f5f5f5;max-width:800px;margin:0 auto}";
echo ".success{color:green;background:#e8f5e9;padding:10px;border-radius:5px;margin:10px 0}";
echo ".error{color:red;background:#ffebee;padding:10px;border-radius:5px;margin:10px 0}";
echo ".info{color:#1976d2;background:#e3f2fd;padding:10px;border-radius:5px;margin:10px 0}";
echo "pre{background:white;padding:15px;border-radius:5px;overflow:auto;border:1px solid #ddd}";
echo "h1{color:#1976d2}h2{color:#388e3c;border-bottom:2px solid #4caf50;padding-bottom:5px}</style></head><body>";

echo "<h1>🚀 تشغيل Migration و Seeder للباقات</h1>";

try {
    // Load Laravel
    require __DIR__ . '/vendor/autoload.php';
    $app = require_once __DIR__ . '/bootstrap/app.php';
    $kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
    $kernel->bootstrap();

    echo "<div class='success'>✅ تم تحميل Laravel بنجاح</div>";

    // 1. Run Migration
    echo "<h2>الخطوة 1: تشغيل Migration</h2>";
    echo "<pre>";

    $exitCode = Artisan::call('migrate', [
        '--force' => true,
        '--path' => 'database/migrations/2025_01_09_000002_add_audience_type_to_subscription_plans.php',
    ]);

    echo Artisan::output();
    echo "</pre>";

    if ($exitCode === 0) {
        echo "<div class='success'>✅ تم تشغيل Migration بنجاح!</div>";
    } else {
        echo "<div class='error'>❌ حدث خطأ في Migration (Exit Code: $exitCode)</div>";
    }

    // 2. Run Seeder
    echo "<h2>الخطوة 2: تشغيل Seeder للباقات</h2>";
    echo "<pre>";

    $exitCode = Artisan::call('db:seed', [
        '--class' => 'SubscriptionPlanSeeder',
        '--force' => true,
    ]);

    echo Artisan::output();
    echo "</pre>";

    if ($exitCode === 0) {
        echo "<div class='success'>✅ تم تشغيل Seeder بنجاح!</div>";
    } else {
        echo "<div class='error'>❌ حدث خطأ في Seeder (Exit Code: $exitCode)</div>";
    }

    // 3. Check Results
    echo "<h2>الخطوة 3: التحقق من النتائج</h2>";

    $individualPlans = DB::table('subscription_plans')
        ->where('audience_type', 'individual')
        ->count();

    $businessPlans = DB::table('subscription_plans')
        ->where('audience_type', 'business')
        ->count();

    echo "<div class='info'>";
    echo "📊 <strong>إحصائيات الباقات:</strong><br>";
    echo "- باقات الأفراد: " . $individualPlans . "<br>";
    echo "- باقات الأعمال: " . $businessPlans . "<br>";
    echo "- الإجمالي: " . ($individualPlans + $businessPlans);
    echo "</div>";

    // 4. Display Plans
    echo "<h2>الخطوة 4: عرض الباقات</h2>";

    echo "<h3>📱 باقات الأفراد:</h3>";
    echo "<table style='width:100%;border-collapse:collapse;background:white'>";
    echo "<tr style='background:#4caf50;color:white'>";
    echo "<th style='padding:10px;border:1px solid #ddd'>الاسم</th>";
    echo "<th style='padding:10px;border:1px solid #ddd'>السعر</th>";
    echo "<th style='padding:10px;border:1px solid #ddd'>النوع</th>";
    echo "<th style='padding:10px;border:1px solid #ddd'>شعبية</th>";
    echo "</tr>";

    $plans = DB::table('subscription_plans')
        ->where('audience_type', 'individual')
        ->orderBy('sort_order')
        ->get();

    foreach ($plans as $plan) {
        $popular = $plan->is_popular ? '⭐ نعم' : 'لا';
        echo "<tr>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$plan->name}</td>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$plan->price} {$plan->currency}</td>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$plan->type}</td>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$popular}</td>";
        echo "</tr>";
    }
    echo "</table>";

    echo "<h3>🏢 باقات الأعمال:</h3>";
    echo "<table style='width:100%;border-collapse:collapse;background:white'>";
    echo "<tr style='background:#2196f3;color:white'>";
    echo "<th style='padding:10px;border:1px solid #ddd'>الاسم</th>";
    echo "<th style='padding:10px;border:1px solid #ddd'>السعر</th>";
    echo "<th style='padding:10px;border:1px solid #ddd'>النوع</th>";
    echo "<th style='padding:10px;border:1px solid #ddd'>شعبية</th>";
    echo "</tr>";

    $plans = DB::table('subscription_plans')
        ->where('audience_type', 'business')
        ->orderBy('sort_order')
        ->get();

    foreach ($plans as $plan) {
        $popular = $plan->is_popular ? '⭐ نعم' : 'لا';
        echo "<tr>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$plan->name}</td>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$plan->price} {$plan->currency}</td>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$plan->type}</td>";
        echo "<td style='padding:10px;border:1px solid #ddd'>{$popular}</td>";
        echo "</tr>";
    }
    echo "</table>";

    // 5. Test API
    echo "<h2>الخطوة 5: اختبار API</h2>";
    echo "<div class='info'>";
    echo "🔗 <strong>روابط API الجاهزة للاستخدام:</strong><br><br>";
    echo "• جميع الباقات: <a href='/api/subscription-plans' target='_blank'>https://mediaprosocial.io/api/subscription-plans</a><br>";
    echo "• باقات الأفراد: <a href='/api/subscription-plans/individual' target='_blank'>https://mediaprosocial.io/api/subscription-plans/individual</a><br>";
    echo "• باقات الأعمال: <a href='/api/subscription-plans/business' target='_blank'>https://mediaprosocial.io/api/subscription-plans/business</a><br>";
    echo "• الباقات الشهرية: <a href='/api/subscription-plans/monthly' target='_blank'>https://mediaprosocial.io/api/subscription-plans/monthly</a><br>";
    echo "• الباقات الشعبية: <a href='/api/subscription-plans/popular' target='_blank'>https://mediaprosocial.io/api/subscription-plans/popular</a>";
    echo "</div>";

    // Clear cache
    echo "<h2>الخطوة 6: مسح Cache</h2>";
    echo "<pre>";
    Artisan::call('optimize:clear');
    echo Artisan::output();
    echo "</pre>";
    echo "<div class='success'>✅ تم مسح Cache بنجاح!</div>";

    // Final message
    echo "<div style='background:#4caf50;color:white;padding:20px;border-radius:10px;margin:20px 0;text-align:center'>";
    echo "<h2 style='color:white;margin:0'>🎉 تم بنجاح!</h2>";
    echo "<p style='margin:10px 0'>تم تفعيل باقات الأفراد والأعمال</p>";
    echo "<p style='margin:0'>" . ($individualPlans + $businessPlans) . " باقة جاهزة للاستخدام</p>";
    echo "</div>";

} catch (Exception $e) {
    echo "<div class='error'>";
    echo "<strong>❌ خطأ:</strong><br>";
    echo htmlspecialchars($e->getMessage());
    echo "<br><br><strong>التفاصيل:</strong><br>";
    echo "<pre>" . htmlspecialchars($e->getTraceAsString()) . "</pre>";
    echo "</div>";
}

echo "<br><br>";
echo "<div style='background:#ff5722;color:white;padding:15px;border-radius:5px;text-align:center'>";
echo "<strong>⚠️ هام جداً: احذف هذا الملف الآن!</strong><br>";
echo "<small>هذا الملف يحتوي على أوامر حساسة ويجب حذفه فوراً من السيرفر</small>";
echo "</div>";

echo "<br>";
echo "<div style='text-align:center'>";
echo "<a href='/admin' style='display:inline-block;padding:15px 30px;background:#1976d2;color:white;text-decoration:none;border-radius:5px;font-weight:bold'>فتح لوحة التحكم</a>";
echo "</div>";

echo "</body></html>";
