<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('agent_workflows', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->cascadeOnDelete();

            // Workflow details
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('workflow_type'); // 'single', 'multi_step', 'scheduled'
            $table->boolean('is_active')->default(true);

            // N8N Integration
            $table->string('n8n_workflow_id')->nullable();
            $table->string('webhook_id')->unique()->nullable();
            $table->text('webhook_url')->nullable();

            // Automation settings
            $table->json('trigger_config')->nullable(); // متى يتم تشغيل الـ workflow
            $table->json('steps_config')->nullable(); // خطوات الـ workflow
            $table->json('success_actions')->nullable(); // ماذا يحدث عند النجاح
            $table->json('failure_actions')->nullable(); // ماذا يحدث عند الفشل

            // Statistics
            $table->integer('total_executions')->default(0);
            $table->integer('successful_executions')->default(0);
            $table->integer('failed_executions')->default(0);
            $table->timestamp('last_executed_at')->nullable();

            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['user_id', 'is_active']);
            $table->index('webhook_id');
        });

        // Telegram bot connections
        Schema::create('telegram_connections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            $table->string('chat_id')->unique();
            $table->string('username')->nullable();
            $table->string('first_name')->nullable();
            $table->string('last_name')->nullable();

            $table->boolean('is_active')->default(true);
            $table->boolean('notifications_enabled')->default(true);

            // Preferences
            $table->json('preferences')->nullable(); // تفضيلات المستخدم
            $table->string('language')->default('ar'); // ar, en

            $table->timestamp('last_interaction_at')->nullable();
            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'is_active']);
            $table->index('chat_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('telegram_connections');
        Schema::dropIfExists('agent_workflows');
    }
};
