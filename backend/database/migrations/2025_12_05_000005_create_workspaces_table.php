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
        // Workspaces table
        Schema::create('workspaces', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('logo')->nullable();
            $table->foreignId('owner_id')->constrained('users')->onDelete('cascade');
            $table->enum('plan_type', ['free', 'starter', 'professional', 'enterprise'])->default('free');
            $table->integer('max_members')->default(3);
            $table->integer('max_social_accounts')->default(5);
            $table->json('settings')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('trial_ends_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        // Workspace members pivot table
        Schema::create('workspace_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workspace_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('role', ['owner', 'admin', 'editor', 'viewer'])->default('viewer');
            $table->json('permissions')->nullable();
            $table->timestamp('invited_at')->nullable();
            $table->timestamp('accepted_at')->nullable();
            $table->foreignId('invited_by')->nullable()->constrained('users')->onDelete('set null');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['workspace_id', 'user_id']);
        });

        // Workspace invitations
        Schema::create('workspace_invitations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workspace_id')->constrained()->onDelete('cascade');
            $table->string('email');
            $table->enum('role', ['admin', 'editor', 'viewer'])->default('viewer');
            $table->string('token', 64)->unique();
            $table->foreignId('invited_by')->constrained('users')->onDelete('cascade');
            $table->timestamp('expires_at');
            $table->timestamp('accepted_at')->nullable();
            $table->timestamps();

            $table->unique(['workspace_id', 'email']);
        });

        // Workspace activity log
        Schema::create('workspace_activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workspace_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('action'); // created, updated, deleted, member_added, etc.
            $table->string('subject_type')->nullable(); // Post, SocialAccount, etc.
            $table->unsignedBigInteger('subject_id')->nullable();
            $table->json('properties')->nullable(); // Additional data
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->timestamps();

            $table->index(['workspace_id', 'created_at']);
            $table->index(['subject_type', 'subject_id']);
        });

        // Add workspace_id to social_accounts if not exists
        if (!Schema::hasColumn('social_accounts', 'workspace_id')) {
            Schema::table('social_accounts', function (Blueprint $table) {
                $table->foreignId('workspace_id')->nullable()->after('user_id')->constrained()->onDelete('cascade');
            });
        }

        // Add workspace_id to social_media_posts if not exists
        if (Schema::hasTable('social_media_posts') && !Schema::hasColumn('social_media_posts', 'workspace_id')) {
            Schema::table('social_media_posts', function (Blueprint $table) {
                $table->foreignId('workspace_id')->nullable()->after('user_id')->constrained()->onDelete('cascade');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove workspace_id from tables
        if (Schema::hasColumn('social_media_posts', 'workspace_id')) {
            Schema::table('social_media_posts', function (Blueprint $table) {
                $table->dropForeign(['workspace_id']);
                $table->dropColumn('workspace_id');
            });
        }

        if (Schema::hasColumn('social_accounts', 'workspace_id')) {
            Schema::table('social_accounts', function (Blueprint $table) {
                $table->dropForeign(['workspace_id']);
                $table->dropColumn('workspace_id');
            });
        }

        Schema::dropIfExists('workspace_activities');
        Schema::dropIfExists('workspace_invitations');
        Schema::dropIfExists('workspace_members');
        Schema::dropIfExists('workspaces');
    }
};
