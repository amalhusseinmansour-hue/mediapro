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
        Schema::create('n8n_workflow_executions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('workflow_id')->comment('N8N Workflow ID');
            $table->string('execution_id')->nullable()->comment('N8N Execution ID');
            $table->string('platform');
            $table->string('status')->default('pending')->comment('pending, running, success, failed');
            $table->json('input_data')->comment('Input parameters sent to workflow');
            $table->json('output_data')->nullable()->comment('Output from workflow');
            $table->text('error_message')->nullable();
            $table->json('error_details')->nullable();
            $table->string('post_url')->nullable()->comment('URL of published post');
            $table->integer('duration')->nullable()->comment('Execution duration in seconds');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->foreign('workflow_id')->references('workflow_id')->on('n8n_workflows')->onDelete('cascade');
            $table->index(['workflow_id', 'status']);
            $table->index('user_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('n8n_workflow_executions');
    }
};
