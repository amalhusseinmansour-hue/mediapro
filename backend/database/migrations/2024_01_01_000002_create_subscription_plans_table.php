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
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // اسم الباقة
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('type'); // monthly, yearly, lifetime
            $table->decimal('price', 10, 2);
            $table->string('currency', 3)->default('USD');
            $table->integer('max_accounts')->default(0);
            $table->integer('max_posts')->default(0);
            $table->boolean('ai_features')->default(false);
            $table->boolean('analytics')->default(false);
            $table->boolean('scheduling')->default(false);
            $table->boolean('is_popular')->default(false);
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->text('features')->nullable(); // JSON
            $table->string('stripe_price_id')->nullable();
            $table->string('paypal_plan_id')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('slug');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subscription_plans');
    }
};