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
        Schema::create('auto_scheduled_posts', function (Blueprint $table) {
            $table->id();
            $table->string('user_id')->index();
            $table->text('content');
            $table->json('media_urls')->nullable();
            $table->json('platforms');
            $table->timestamp('schedule_time');
            $table->enum('recurrence_pattern', ['once', 'daily', 'weekly', 'monthly', 'custom'])->default('once');
            $table->integer('recurrence_interval')->nullable(); // For custom intervals
            $table->timestamp('recurrence_end_date')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->enum('status', ['pending', 'active', 'paused', 'completed', 'failed'])->default('pending')->index();
            $table->timestamp('last_posted_at')->nullable();
            $table->timestamp('next_post_at')->nullable()->index();
            $table->integer('post_count')->default(0);
            $table->json('metadata')->nullable();
            $table->timestamps();

            // Foreign keys
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('auto_scheduled_posts');
    }
};
