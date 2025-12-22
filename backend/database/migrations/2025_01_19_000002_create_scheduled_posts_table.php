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
        Schema::create('scheduled_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // Post content
            $table->text('content')->nullable();
            $table->string('title')->nullable(); // For LinkedIn articles, YouTube videos

            // Media attachments
            $table->json('media_urls')->nullable(); // Array of image/video URLs
            $table->enum('media_type', ['none', 'image', 'video', 'carousel', 'link'])->default('none');

            // Link preview
            $table->string('link_url')->nullable();
            $table->string('link_title')->nullable();
            $table->text('link_description')->nullable();
            $table->string('link_image_url')->nullable();

            // Platform targeting
            $table->json('platforms')->nullable(); // ['facebook', 'instagram', 'twitter']
            $table->json('account_ids')->nullable(); // Specific account IDs to post to

            // Scheduling
            $table->timestamp('scheduled_at')->nullable()->index();
            $table->enum('scheduling_type', ['immediate', 'scheduled', 'optimal'])->default('scheduled');

            // Platform-specific settings
            $table->json('platform_settings')->nullable(); // e.g., {'facebook': {'type': 'reel'}, 'instagram': {'first_comment': 'text'}}

            // Publishing status
            $table->enum('status', [
                'draft',
                'scheduled',
                'publishing',
                'published',
                'failed',
                'partially_published',
                'cancelled'
            ])->default('draft')->index();

            // Publishing results
            $table->json('publish_results')->nullable(); // Store platform-specific post IDs and responses
            $table->timestamp('published_at')->nullable();

            // Retry mechanism
            $table->integer('attempts')->default(0);
            $table->integer('max_attempts')->default(3);
            $table->timestamp('next_retry_at')->nullable();

            // Error tracking
            $table->text('error_message')->nullable();
            $table->json('error_details')->nullable();

            // Analytics tracking
            $table->boolean('track_analytics')->default(false);
            $table->json('analytics_data')->nullable(); // Cached analytics data

            // Automation rule reference
            $table->foreignId('automation_rule_id')->nullable()->constrained()->onDelete('set null');

            $table->timestamps();
            $table->softDeletes();

            // Indexes for performance
            $table->index(['status', 'scheduled_at']);
            $table->index(['user_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('scheduled_posts');
    }
};
