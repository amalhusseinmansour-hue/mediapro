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
        Schema::create('ai_generated_videos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->text('prompt');
            $table->string('provider')->default('runway'); // runway, pika, d-id, stability
            $table->string('video_url')->nullable();
            $table->string('thumbnail_url')->nullable();
            $table->string('task_id')->nullable();
            $table->enum('status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->integer('duration')->default(4);
            $table->string('aspect_ratio')->default('16:9');
            $table->decimal('cost', 8, 4)->default(0);
            $table->json('metadata')->nullable(); // extra settings, error messages, etc.
            $table->json('api_response')->nullable(); // full API response for debugging
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('status');
            $table->index('provider');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ai_generated_videos');
    }
};