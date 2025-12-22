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
        Schema::create('automation_rules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // Rule identification
            $table->string('name');
            $table->text('description')->nullable();

            // Rule type
            $table->enum('rule_type', [
                'recurring_post',        // Post on schedule (daily, weekly, etc.)
                'rss_feed',             // Auto-post from RSS feed
                'content_recycling',    // Repost old content
                'cross_posting',        // Auto-cross-post between platforms
                'auto_reply',           // Auto-reply to comments/messages
                'scheduled_campaign'    // Multi-post campaign
            ])->index();

            // Trigger configuration
            $table->json('trigger_config')->nullable(); // e.g., {'schedule': 'daily', 'time': '09:00', 'timezone': 'UTC'}

            // Action configuration
            $table->json('action_config')->nullable(); // What to post, where to post, etc.

            // Target platforms
            $table->json('platforms')->nullable();
            $table->json('account_ids')->nullable();

            // Scheduling
            $table->string('frequency')->nullable(); // daily, weekly, monthly, custom
            $table->json('schedule_pattern')->nullable(); // Cron-like pattern or custom schedule
            $table->time('time_of_day')->nullable();
            $table->string('timezone')->default('UTC');

            // Recurrence
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->timestamp('last_executed_at')->nullable();
            $table->timestamp('next_execution_at')->nullable()->index();

            // Content pool (for recurring posts)
            $table->json('content_pool')->nullable(); // Array of content variations
            $table->integer('current_content_index')->default(0);

            // Rule status
            $table->enum('status', [
                'active',
                'paused',
                'completed',
                'failed'
            ])->default('active')->index();

            // Execution tracking
            $table->integer('execution_count')->default(0);
            $table->integer('max_executions')->nullable(); // null = unlimited

            // Error handling
            $table->integer('failed_executions')->default(0);
            $table->text('last_error')->nullable();

            // Conditions/Filters
            $table->json('conditions')->nullable(); // e.g., only post if weather is sunny, etc.

            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['user_id', 'status']);
            $table->index(['status', 'next_execution_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('automation_rules');
    }
};
