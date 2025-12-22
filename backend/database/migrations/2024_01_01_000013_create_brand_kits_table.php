<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('brand_kits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('logo')->nullable();
            $table->json('colors')->nullable(); // Primary, secondary, accent colors
            $table->json('fonts')->nullable(); // Font names and styles
            $table->string('tone')->nullable(); // Professional, Casual, Friendly, etc.
            $table->string('voice')->nullable(); // Brand voice characteristics
            $table->text('tagline')->nullable();
            $table->json('keywords')->nullable(); // Brand keywords
            $table->json('target_audience')->nullable(); // Demographic info
            $table->json('social_links')->nullable(); // Social media links
            $table->boolean('is_default')->default(false);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('brand_kits');
    }
};
