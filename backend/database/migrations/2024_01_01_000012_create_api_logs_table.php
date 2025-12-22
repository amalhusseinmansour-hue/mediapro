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
        Schema::create('api_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('api_key_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('method'); // GET, POST, PUT, DELETE
            $table->string('endpoint'); // المسار
            $table->string('ip_address');
            $table->string('user_agent')->nullable();
            $table->json('request_headers')->nullable();
            $table->json('request_body')->nullable();
            $table->integer('response_status'); // 200, 404, 500, etc
            $table->json('response_body')->nullable();
            $table->integer('response_time')->nullable(); // بالميلي ثانية
            $table->timestamp('created_at');

            $table->index('api_key_id');
            $table->index('user_id');
            $table->index('endpoint');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('api_logs');
    }
};
