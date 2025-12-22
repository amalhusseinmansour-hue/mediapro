<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('agent_executions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            // Agent details
            $table->string('agent_type'); // 'content', 'posting', 'email', 'calendar', etc.
            $table->string('action'); // 'create_image', 'post_instagram', 'send_email', etc.
            $table->string('status')->default('pending'); // pending, processing, completed, failed

            // Execution data
            $table->json('input_data')->nullable(); // البيانات المدخلة
            $table->json('output_data')->nullable(); // النتيجة
            $table->json('error_data')->nullable(); // الأخطاء إن وجدت

            // Integration IDs
            $table->string('n8n_execution_id')->nullable();
            $table->string('telegram_chat_id')->nullable();
            $table->string('telegram_message_id')->nullable();

            // Files and media
            $table->string('google_drive_file_id')->nullable();
            $table->text('result_url')->nullable(); // رابط الصورة/الفيديو الناتج

            // Metrics
            $table->integer('execution_time')->nullable(); // بالثواني
            $table->integer('credits_used')->default(0); // AI credits used

            // Timestamps
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'status']);
            $table->index(['user_id', 'agent_type']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('agent_executions');
    }
};
