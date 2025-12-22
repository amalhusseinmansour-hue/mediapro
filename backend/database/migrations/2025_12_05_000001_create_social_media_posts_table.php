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
        if (!Schema::hasTable('social_media_posts')) {
            Schema::create('social_media_posts', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->text('content')->nullable();
                $table->json('platforms')->nullable(); // ['facebook', 'instagram', ...]
                $table->json('media')->nullable(); // URLs or paths to media files
                $table->string('media_type')->nullable(); // image, video, carousel
                $table->string('link')->nullable();
                $table->enum('status', ['draft', 'scheduled', 'published', 'failed'])->default('draft');
                $table->timestamp('scheduled_at')->nullable();
                $table->timestamp('published_at')->nullable();
                $table->json('publish_results')->nullable(); // Results from each platform
                $table->text('error_message')->nullable();
                $table->timestamps();
                $table->softDeletes();

                // Indexes
                $table->index('user_id');
                $table->index('status');
                $table->index('scheduled_at');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('social_media_posts');
    }
};
