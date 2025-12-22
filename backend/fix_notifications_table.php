<?php
require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Schema\Blueprint;

header('Content-Type: text/plain; charset=utf-8');

echo "🔧 إصلاح جدول notifications...\n\n";

try {
    // التحقق من وجود الجدول
    if (!Schema::hasTable('notifications')) {
        echo "📦 إنشاء جدول notifications...\n";
        Schema::create('notifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('type');
            $table->morphs('notifiable');
            $table->text('data');
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });
        echo "✅ تم إنشاء الجدول بنجاح\n";
    } else {
        echo "📋 الجدول موجود، التحقق من الأعمدة...\n";

        // التحقق من وجود الأعمدة المطلوبة
        $columns = Schema::getColumnListing('notifications');
        echo "   الأعمدة الموجودة: " . implode(', ', $columns) . "\n";

        if (!in_array('notifiable_type', $columns)) {
            echo "   ⚠️  العمود notifiable_type غير موجود\n";

            // محاولة إضافة الأعمدة
            Schema::table('notifications', function (Blueprint $table) {
                $table->string('notifiable_type')->after('type')->nullable();
            });
            echo "   ✅ تم إضافة notifiable_type\n";
        }

        if (!in_array('notifiable_id', $columns)) {
            echo "   ⚠️  العمود notifiable_id غير موجود\n";
            Schema::table('notifications', function (Blueprint $table) {
                $table->unsignedBigInteger('notifiable_id')->after('notifiable_type')->nullable();
            });
            echo "   ✅ تم إضافة notifiable_id\n";
        }

        // إضافة الفهارس إذا لم تكن موجودة
        try {
            Schema::table('notifications', function (Blueprint $table) {
                $table->index(['notifiable_type', 'notifiable_id'], 'notifications_notifiable_type_notifiable_id_index');
            });
            echo "   ✅ تم إضافة الفهرس\n";
        } catch (\Exception $e) {
            echo "   ℹ️  الفهرس موجود بالفعل\n";
        }
    }

    echo "\n🎉 تم إصلاح جدول notifications بنجاح!\n";

} catch (\Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
}

// تنظيف الكاش
echo "\n🧹 تنظيف الكاش...\n";
Artisan::call('cache:clear');
echo "✅ تم\n";
