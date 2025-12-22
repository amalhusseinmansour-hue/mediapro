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
        if (!Schema::hasTable('video_generations')) {
            Schema::create('video_generations', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->string('provider'); // runway, replicate, stability, pika, did, kieai
                $table->string('task_id')->nullable(); // External task/job ID
                $table->text('prompt')->nullable();
                $table->string('image_url')->nullable(); // Source image for image-to-video
                $table->json('options')->nullable(); // Generation options
                $table->enum('status', ['pending', 'processing', 'completed', 'failed', 'cancelled'])->default('pending');
                $table->integer('progress')->default(0); // 0-100
                $table->string('video_url')->nullable();
                $table->string('thumbnail_url')->nullable();
                $table->integer('duration')->nullable(); // Video duration in seconds
                $table->text('error_message')->nullable();
                $table->decimal('cost', 10, 4)->nullable(); // Cost in credits/dollars
                $table->timestamp('started_at')->nullable();
                $table->timestamp('completed_at')->nullable();
                $table->timestamps();

                // Indexes
                $table->index('user_id');
                $table->index('provider');
                $table->index('status');
                $table->index('task_id');
                $table->index('created_at');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('video_generations');
    }
};
