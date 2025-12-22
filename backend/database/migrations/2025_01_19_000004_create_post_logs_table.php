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
        Schema::create('post_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('scheduled_post_id')->nullable()->constrained()->onDelete('cascade');
            $table->foreignId('automation_rule_id')->nullable()->constrained()->onDelete('set null');

            // Platform information
            $table->string('platform')->index();
            $table->foreignId('social_account_id')->nullable()->constrained('users_social_accounts')->onDelete('set null');

            // Action details
            $table->enum('action', [
                'publish_attempt',
                'publish_success',
                'publish_failed',
                'token_refresh',
                'token_refresh_failed',
                'rate_limit_hit',
                'webhook_sent',
                'webhook_failed',
                'analytics_fetched'
            ])->index();

            // Request/Response
            $table->text('request_url')->nullable();
            $table->json('request_payload')->nullable();
            $table->json('response_data')->nullable();
            $table->integer('http_status_code')->nullable();

            // Publishing method
            $table->enum('publish_method', [
                'ayrshare',
                'postsyncer',
                'webhook',
                'direct_api',
                'manual'
            ])->nullable();

            // Status and errors
            $table->enum('status', ['success', 'failed', 'pending', 'retrying'])->index();
            $table->text('error_message')->nullable();
            $table->text('error_code')->nullable();
            $table->json('error_details')->nullable();

            // Platform response
            $table->string('platform_post_id')->nullable(); // ID of the post on the platform
            $table->string('platform_post_url')->nullable();

            // Timing
            $table->integer('execution_time_ms')->nullable(); // How long the API call took
            $table->integer('attempt_number')->default(1);

            // Rate limiting info
            $table->integer('rate_limit_remaining')->nullable();
            $table->timestamp('rate_limit_reset_at')->nullable();

            // Metadata
            $table->json('metadata')->nullable(); // Any additional context
            $table->ipAddress('ip_address')->nullable();
            $table->string('user_agent')->nullable();

            $table->timestamps();

            // Indexes for reporting and debugging
            $table->index(['user_id', 'action', 'created_at']);
            $table->index(['status', 'created_at']);
            $table->index(['platform', 'action', 'created_at']);
            $table->index('created_at'); // For cleanup jobs
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('post_logs');
    }
};
