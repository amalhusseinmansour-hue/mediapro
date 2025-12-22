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
        Schema::create('content_templates', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('platform'); // facebook, instagram, twitter, linkedin, tiktok, youtube, all
            $table->string('category')->nullable();
            $table->string('type'); // text, image, video, carousel, story, reel
            $table->text('content');
            $table->json('variables')->nullable(); // Variables that can be replaced
            $table->json('hashtags')->nullable();
            $table->json('media_requirements')->nullable(); // Size, format requirements
            $table->json('best_posting_times')->nullable();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->integer('usage_count')->default(0);
            $table->timestamps();

            $table->index(['platform', 'type']);
            $table->index(['user_id', 'is_active']);
            $table->index('category');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('content_templates');
    }
};
