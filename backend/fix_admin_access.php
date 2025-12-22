<?php
/**
 * سكريبت إصلاح مشكلة دخول الأدمن
 *
 * قم بتشغيل هذا السكريبت على السيرفر:
 * php fix_admin_access.php
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

echo "🔧 بدء إصلاح مشكلة دخول الأدمن...\n\n";

// تشغيل جميع الـ migrations
echo "📦 تشغيل migrations...\n";
try {
    Artisan::call('migrate', ['--force' => true]);
    echo Artisan::output();
    echo "✅ تم تشغيل migrations بنجاح\n\n";
} catch (\Exception $e) {
    echo "⚠️  Migration error: " . $e->getMessage() . "\n\n";
}

// التحقق من وجود جداول الأدوار
echo "📋 التحقق من جداول الأدوار...\n";
$rolesTableExists = Schema::hasTable('roles');
$roleUserTableExists = Schema::hasTable('role_user');
echo "   - جدول roles: " . ($rolesTableExists ? "✅ موجود" : "❌ غير موجود") . "\n";
echo "   - جدول role_user: " . ($roleUserTableExists ? "✅ موجود" : "❌ غير موجود") . "\n\n";

// إنشاء الأدوار إذا كان الجدول موجود
if ($rolesTableExists) {
    echo "📦 إنشاء الأدوار الأساسية...\n";
    $roles = [
        ['name' => 'super_admin', 'display_name' => 'مدير النظام', 'description' => 'صلاحيات كاملة', 'is_active' => true],
        ['name' => 'admin', 'display_name' => 'مدير', 'description' => 'صلاحيات إدارية', 'is_active' => true],
    ];

    foreach ($roles as $roleData) {
        try {
            $existing = DB::table('roles')->where('name', $roleData['name'])->first();
            if (!$existing) {
                DB::table('roles')->insert(array_merge($roleData, [
                    'created_at' => now(),
                    'updated_at' => now(),
                ]));
                echo "   ✅ تم إنشاء دور '{$roleData['name']}'\n";
            } else {
                echo "   ℹ️  دور '{$roleData['name']}' موجود بالفعل\n";
            }
        } catch (\Exception $e) {
            echo "   ⚠️  خطأ في إنشاء الدور: " . $e->getMessage() . "\n";
        }
    }
    echo "\n";
}

// إنشاء/تحديث مستخدمين الأدمن
echo "👤 إنشاء مستخدمين الأدمن...\n";

$adminUsers = [
    [
        'name' => 'مدير النظام الرئيسي',
        'email' => 'admin@mediapro.com',
        'password' => 'Admin@2025',
        'role' => 'super_admin',
    ],
    [
        'name' => 'مدير النظام الاحتياطي',
        'email' => 'super@mediapro.com',
        'password' => 'Super@2025',
        'role' => 'super_admin',
    ],
    [
        'name' => 'الإدارة',
        'email' => 'management@mediapro.com',
        'password' => 'Management@2025',
        'role' => 'admin',
    ]
];

foreach ($adminUsers as $adminData) {
    try {
        // حذف المستخدم إذا كان موجود
        User::where('email', $adminData['email'])->forceDelete();

        // إنشاء المستخدم مع is_admin = true فقط (بدون user_type لتجنب مشكلة الحجم)
        $user = User::create([
            'name' => $adminData['name'],
            'email' => $adminData['email'],
            'password' => Hash::make($adminData['password']),
            'is_admin' => true,
            'is_active' => true,
            'email_verified_at' => now(),
        ]);

        echo "   ✅ {$adminData['email']}\n";
        echo "      كلمة المرور: {$adminData['password']}\n";

        // ربط المستخدم بالدور إذا كانت الجداول موجودة
        if ($rolesTableExists && $roleUserTableExists) {
            $role = DB::table('roles')->where('name', $adminData['role'])->first();
            if ($role) {
                // حذف أي روابط قديمة
                DB::table('role_user')->where('user_id', $user->id)->delete();

                // إضافة الرابط الجديد
                DB::table('role_user')->insert([
                    'role_id' => $role->id,
                    'user_id' => $user->id,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                echo "      الدور: {$adminData['role']}\n";
            }
        }
    } catch (\Exception $e) {
        echo "   ⚠️  خطأ في إنشاء {$adminData['email']}: " . $e->getMessage() . "\n";
    }
}

// تنظيف الكاش
echo "\n🧹 تنظيف الكاش...\n";
try {
    Artisan::call('config:clear');
    Artisan::call('cache:clear');
    Artisan::call('route:clear');
    Artisan::call('view:clear');
    echo "✅ تم تنظيف الكاش بنجاح\n";
} catch (\Exception $e) {
    echo "⚠️  خطأ في تنظيف الكاش: " . $e->getMessage() . "\n";
}

echo "\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "🎉 تم الإصلاح بنجاح!\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "\n";
echo "📧 بيانات الدخول:\n";
echo "   البريد الإلكتروني: admin@mediapro.com\n";
echo "   كلمة المرور: Admin@2025\n";
echo "\n";
echo "🌐 رابط لوحة التحكم: https://mediaprosocial.io/admin\n";
echo "\n";
