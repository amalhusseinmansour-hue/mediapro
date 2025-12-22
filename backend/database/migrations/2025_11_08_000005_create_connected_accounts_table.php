<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('connected_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            $table->string('platform'); // facebook, instagram, twitter, linkedin, tiktok, youtube
            $table->string('platform_user_id')->nullable(); // ID on the platform
            $table->string('username')->nullable(); // Username/handle on the platform
            $table->string('display_name')->nullable(); // Display name on the platform
            $table->string('profile_picture')->nullable(); // Profile picture URL
            $table->string('email')->nullable(); // Email associated with the account

            // OAuth tokens
            $table->text('access_token')->nullable();
            $table->text('refresh_token')->nullable();
            $table->timestamp('token_expires_at')->nullable();

            // Permissions/Scopes
            $table->json('scopes')->nullable(); // What permissions the user granted

            // Account status
            $table->boolean('is_active')->default(true);
            $table->timestamp('connected_at')->nullable();
            $table->timestamp('last_used_at')->nullable();

            // Additional data
            $table->json('metadata')->nullable(); // Any additional platform-specific data

            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['user_id', 'platform']);
            $table->unique(['user_id', 'platform', 'platform_user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('connected_accounts');
    }
};
