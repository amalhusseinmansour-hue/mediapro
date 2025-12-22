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
            // تتبع المنشورات
            $table->integer('current_posts_count')->default(0)->after('max_posts');
            $table->timestamp('posts_reset_date')->nullable()->after('current_posts_count');

            // تتبع AI
            $table->integer('current_ai_requests_count')->default(0)->after('ai_features');
            $table->timestamp('ai_requests_reset_date')->nullable()->after('current_ai_requests_count');

            // حدود مخصصة (اختيارية - قد تختلف عن الباقة الافتراضية)
            $table->integer('custom_max_posts')->nullable()->after('max_posts');
            $table->integer('custom_max_ai_requests')->nullable()->after('ai_features');

            // فهرسة لتحسين الأداء
            $table->index('current_posts_count');
            $table->index('current_ai_requests_count');
            $table->index('posts_reset_date');
            $table->index('ai_requests_reset_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->dropIndex(['current_posts_count']);
            $table->dropIndex(['current_ai_requests_count']);
            $table->dropIndex(['posts_reset_date']);
            $table->dropIndex(['ai_requests_reset_date']);

            $table->dropColumn([
                'current_posts_count',
                'posts_reset_date',
                'current_ai_requests_count',
                'ai_requests_reset_date',
                'custom_max_posts',
                'custom_max_ai_requests',
            ]);
        });
    }
};
