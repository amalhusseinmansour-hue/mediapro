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
        Schema::create('users_social_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // Platform identification
            $table->enum('platform', [
                'facebook',
                'instagram',
                'twitter',
                'linkedin',
                'tiktok',
                'youtube',
                'pinterest',
                'threads',
                'snapchat'
            ])->index();

            // Account details
            $table->string('platform_user_id')->nullable(); // User ID on the platform
            $table->string('username')->nullable();
            $table->string('display_name')->nullable();
            $table->string('profile_image_url')->nullable();

            // OAuth tokens
            $table->text('access_token')->nullable();
            $table->text('refresh_token')->nullable();
            $table->timestamp('token_expires_at')->nullable();

            // Additional platform-specific data (JSON)
            $table->json('platform_data')->nullable(); // Store page_id, business_account_id, etc.

            // Account status
            $table->enum('status', [
                'active',
                'inactive',
                'token_expired',
                'authentication_failed',
                'rate_limited',
                'suspended'
            ])->default('active')->index();

            // Tracking
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('last_token_refresh_at')->nullable();
            $table->integer('failed_attempts')->default(0);
            $table->text('last_error')->nullable();

            // Rate limiting info
            $table->integer('rate_limit_remaining')->nullable();
            $table->timestamp('rate_limit_reset_at')->nullable();

            $table->timestamps();
            $table->softDeletes();

            // Unique constraint: one account per platform per user
            $table->unique(['user_id', 'platform', 'platform_user_id'], 'unique_user_platform_account');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users_social_accounts');
    }
};
