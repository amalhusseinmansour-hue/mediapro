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
        if (!Schema::hasTable('platform_posts')) {
            Schema::create('platform_posts', function (Blueprint $table) {
                $table->id();
                $table->foreignId('social_media_post_id')->constrained()->onDelete('cascade');
                $table->string('platform'); // facebook, instagram, twitter, etc.
                $table->string('platform_post_id')->nullable(); // ID from the platform
                $table->string('platform_post_url')->nullable(); // URL on the platform
                $table->enum('status', ['pending', 'published', 'failed'])->default('pending');
                $table->text('error_message')->nullable();
                $table->json('response_data')->nullable(); // Full response from platform API
                $table->timestamp('published_at')->nullable();
                $table->timestamps();

                // Indexes
                $table->index('social_media_post_id');
                $table->index('platform');
                $table->index('status');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('platform_posts');
    }
};
