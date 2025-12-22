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
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name'); // اسم الباقة
            $table->string('type'); // monthly, yearly, lifetime
            $table->decimal('price', 10, 2); // السعر
            $table->string('currency', 3)->default('USD');
            $table->text('features')->nullable(); // JSON features
            $table->integer('max_accounts')->default(0); // عدد الحسابات المسموح بها
            $table->integer('max_posts')->default(0); // عدد المنشورات المسموح بها
            $table->boolean('ai_features')->default(false); // ميزات الذكاء الاصطناعي
            $table->boolean('analytics')->default(false); // التحليلات
            $table->boolean('scheduling')->default(false); // الجدولة
            $table->string('status')->default('active'); // active, cancelled, expired
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->string('stripe_subscription_id')->nullable();
            $table->string('paypal_subscription_id')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('status');
            $table->index(['starts_at', 'ends_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};