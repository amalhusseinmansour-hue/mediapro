<?php

/**
 * اختبار تسجيل المستخدم في Laravel
 *
 * هذا السكريبت يتحقق من:
 * 1. الاتصال بقاعدة البيانات
 * 2. وجود جدول users
 * 3. الحقول المطلوبة
 * 4. آخر المستخدمين المسجلين
 *
 * الاستخدام:
 * cd backend
 * php test_user_registration.php
 */

require __DIR__.'/vendor/autoload.php';

use Illuminate\Support\Facades\DB;
use App\Models\User;

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "========================================\n";
echo "🔍 اختبار تسجيل المستخدم في Laravel\n";
echo "========================================\n\n";

// 1. التحقق من الاتصال بقاعدة البيانات
echo "1️⃣ اختبار الاتصال بقاعدة البيانات...\n";
try {
    DB::connection()->getPdo();
    echo "   ✅ الاتصال بقاعدة البيانات ناجح\n\n";
} catch (\Exception $e) {
    echo "   ❌ فشل الاتصال بقاعدة البيانات: " . $e->getMessage() . "\n";
    exit(1);
}

// 2. التحقق من وجود جدول users
echo "2️⃣ التحقق من وجود جدول users...\n";
try {
    $tableExists = DB::select("SHOW TABLES LIKE 'users'");
    if (count($tableExists) > 0) {
        echo "   ✅ جدول users موجود\n\n";
    } else {
        echo "   ❌ جدول users غير موجود\n";
        echo "   💡 قم بتشغيل: php artisan migrate\n";
        exit(1);
    }
} catch (\Exception $e) {
    echo "   ❌ خطأ في التحقق من الجدول: " . $e->getMessage() . "\n";
    exit(1);
}

// 3. التحقق من الحقول المطلوبة
echo "3️⃣ التحقق من حقول جدول users...\n";
try {
    $columns = DB::select("DESCRIBE users");
    $requiredFields = [
        'id', 'name', 'email', 'phone', 'password',
        'type_of_audience', 'is_phone_verified', 'is_admin',
        'is_active', 'last_login_at'
    ];

    $existingColumns = array_map(function($col) {
        return $col->Field;
    }, $columns);

    echo "   الحقول الموجودة:\n";
    foreach ($requiredFields as $field) {
        if (in_array($field, $existingColumns)) {
            echo "   ✅ $field\n";
        } else {
            echo "   ⚠️ $field (غير موجود)\n";
        }
    }
    echo "\n";
} catch (\Exception $e) {
    echo "   ❌ خطأ في التحقق من الحقول: " . $e->getMessage() . "\n";
}

// 4. عرض إحصائيات المستخدمين
echo "4️⃣ إحصائيات المستخدمين:\n";
try {
    $totalUsers = User::count();
    $verifiedUsers = User::where('is_phone_verified', true)->count();
    $activeUsers = User::where('is_active', true)->count();

    echo "   📊 إجمالي المستخدمين: $totalUsers\n";
    echo "   ✅ مستخدمين موثقين: $verifiedUsers\n";
    echo "   🟢 مستخدمين نشطين: $activeUsers\n\n";
} catch (\Exception $e) {
    echo "   ❌ خطأ في جلب الإحصائيات: " . $e->getMessage() . "\n";
}

// 5. عرض آخر 5 مستخدمين
echo "5️⃣ آخر 5 مستخدمين مسجلين:\n";
try {
    $latestUsers = User::latest()->take(5)->get([
        'id', 'name', 'phone', 'email', 'type_of_audience',
        'is_phone_verified', 'created_at'
    ]);

    if ($latestUsers->count() > 0) {
        echo "   \n";
        echo "   | ID | الاسم | رقم الهاتف | النوع | موثق | تاريخ التسجيل |\n";
        echo "   |----|----|----|----|----|----|----|\n";

        foreach ($latestUsers as $user) {
            $verified = $user->is_phone_verified ? '✅' : '❌';
            echo sprintf(
                "   | %s | %s | %s | %s | %s | %s |\n",
                $user->id,
                substr($user->name, 0, 15),
                $user->phone ?? 'N/A',
                $user->type_of_audience ?? 'N/A',
                $verified,
                $user->created_at->format('Y-m-d H:i')
            );
        }
        echo "\n";
    } else {
        echo "   ℹ️ لا يوجد مستخدمين بعد\n\n";
    }
} catch (\Exception $e) {
    echo "   ❌ خطأ في جلب المستخدمين: " . $e->getMessage() . "\n";
}

// 6. التحقق من Auth Tokens (Laravel Sanctum)
echo "6️⃣ التحقق من Laravel Sanctum Tokens...\n";
try {
    $tableExists = DB::select("SHOW TABLES LIKE 'personal_access_tokens'");
    if (count($tableExists) > 0) {
        $tokensCount = DB::table('personal_access_tokens')->count();
        echo "   ✅ جدول Sanctum موجود\n";
        echo "   📊 عدد Tokens النشطة: $tokensCount\n\n";
    } else {
        echo "   ⚠️ جدول Sanctum غير موجود\n";
        echo "   💡 قم بتشغيل: php artisan migrate\n\n";
    }
} catch (\Exception $e) {
    echo "   ❌ خطأ: " . $e->getMessage() . "\n\n";
}

// 7. اختبار إنشاء مستخدم تجريبي (اختياري)
echo "7️⃣ هل تريد إنشاء مستخدم تجريبي؟ (y/n): ";
$handle = fopen("php://stdin", "r");
$input = trim(fgets($handle));

if (strtolower($input) === 'y') {
    try {
        $testPhone = '+971' . rand(500000000, 599999999);
        $testUser = User::create([
            'name' => 'مستخدم تجريبي',
            'email' => $testPhone . '@test.user',
            'phone' => $testPhone,
            'password' => bcrypt('password123'),
            'type_of_audience' => 'individual',
            'is_phone_verified' => true,
            'is_admin' => false,
            'is_active' => true,
            'last_login_at' => now(),
        ]);

        echo "   ✅ تم إنشاء مستخدم تجريبي:\n";
        echo "   - ID: {$testUser->id}\n";
        echo "   - الاسم: {$testUser->name}\n";
        echo "   - رقم الهاتف: {$testUser->phone}\n";
        echo "   - البريد: {$testUser->email}\n\n";
    } catch (\Exception $e) {
        echo "   ❌ خطأ في إنشاء المستخدم: " . $e->getMessage() . "\n\n";
    }
}

echo "========================================\n";
echo "✅ اكتمل الاختبار\n";
echo "========================================\n";
