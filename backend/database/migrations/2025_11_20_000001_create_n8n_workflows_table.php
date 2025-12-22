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
        Schema::create('n8n_workflows', function (Blueprint $table) {
            $table->id();
            $table->string('workflow_id')->unique()->comment('N8N Workflow ID');
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('platform')->comment('instagram, tiktok, youtube, facebook, twitter');
            $table->string('type')->default('video')->comment('video, image, text, carousel');
            $table->json('workflow_json')->comment('Complete N8N workflow JSON');
            $table->json('input_schema')->nullable()->comment('Required input parameters');
            $table->string('n8n_url')->nullable()->comment('N8N instance URL');
            $table->string('credential_id')->nullable()->comment('Upload Post credential ID');
            $table->string('upload_post_user')->default('uploadn8n')->comment('Upload Post username');
            $table->boolean('is_active')->default(true);
            $table->integer('execution_count')->default(0)->comment('Total executions');
            $table->timestamp('last_executed_at')->nullable();
            $table->timestamps();

            $table->index('platform');
            $table->index('type');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('n8n_workflows');
    }
};
