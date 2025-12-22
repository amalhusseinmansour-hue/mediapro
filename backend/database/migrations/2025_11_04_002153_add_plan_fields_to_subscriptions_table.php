<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            // جعل user_id nullable للسماح بخطط الاشتراك
            $table->foreignId('user_id')->nullable()->change();

            // إضافة حقل للتمييز بين الخطط والاشتراكات
            $table->boolean('is_plan')->default(false)->after('id');

            // إضافة الوصف
            $table->text('description')->nullable()->after('name');

            // إضافة حقل is_active للخطط
            $table->boolean('is_active')->default(true)->after('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->dropColumn(['is_plan', 'description', 'is_active']);
        });
    }
};
