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
        Schema::table('subscriptions', function (Blueprint $table) {
            // AI Video limits
            if (!Schema::hasColumn('subscriptions', 'max_ai_videos')) {
                $table->integer('max_ai_videos')->default(0);
            }
            if (!Schema::hasColumn('subscriptions', 'current_ai_videos_count')) {
                $table->integer('current_ai_videos_count')->default(0);
            }
            if (!Schema::hasColumn('subscriptions', 'max_video_duration')) {
                $table->integer('max_video_duration')->default(4);
            }
            if (!Schema::hasColumn('subscriptions', 'video_quality')) {
                $table->string('video_quality')->default('480p');
            }

            // AI Image limits
            if (!Schema::hasColumn('subscriptions', 'max_ai_images')) {
                $table->integer('max_ai_images')->default(0);
            }
            if (!Schema::hasColumn('subscriptions', 'current_ai_images_count')) {
                $table->integer('current_ai_images_count')->default(0);
            }

            // AI Text limits
            if (!Schema::hasColumn('subscriptions', 'max_ai_texts')) {
                $table->integer('max_ai_texts')->default(0);
            }
            if (!Schema::hasColumn('subscriptions', 'current_ai_texts_count')) {
                $table->integer('current_ai_texts_count')->default(0);
            }

            // Social accounts limit
            if (!Schema::hasColumn('subscriptions', 'max_social_accounts')) {
                $table->integer('max_social_accounts')->default(1);
            }

            // Team members (for business)
            if (!Schema::hasColumn('subscriptions', 'max_team_members')) {
                $table->integer('max_team_members')->default(1);
            }

            // Priority processing
            if (!Schema::hasColumn('subscriptions', 'priority_processing')) {
                $table->boolean('priority_processing')->default(false);
            }

            // Advanced analytics
            if (!Schema::hasColumn('subscriptions', 'advanced_analytics')) {
                $table->boolean('advanced_analytics')->default(false);
            }
        });

        // Also add to subscription_plans table
        Schema::table('subscription_plans', function (Blueprint $table) {
            if (!Schema::hasColumn('subscription_plans', 'max_ai_videos')) {
                $table->integer('max_ai_videos')->default(0);
            }
            if (!Schema::hasColumn('subscription_plans', 'max_video_duration')) {
                $table->integer('max_video_duration')->default(4);
            }
            if (!Schema::hasColumn('subscription_plans', 'video_quality')) {
                $table->string('video_quality')->default('480p');
            }
            if (!Schema::hasColumn('subscription_plans', 'max_ai_images')) {
                $table->integer('max_ai_images')->default(0);
            }
            if (!Schema::hasColumn('subscription_plans', 'max_ai_texts')) {
                $table->integer('max_ai_texts')->default(0);
            }
            if (!Schema::hasColumn('subscription_plans', 'max_social_accounts')) {
                $table->integer('max_social_accounts')->default(1);
            }
            if (!Schema::hasColumn('subscription_plans', 'max_team_members')) {
                $table->integer('max_team_members')->default(1);
            }
            if (!Schema::hasColumn('subscription_plans', 'priority_processing')) {
                $table->boolean('priority_processing')->default(false);
            }
            if (!Schema::hasColumn('subscription_plans', 'advanced_analytics')) {
                $table->boolean('advanced_analytics')->default(false);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->dropColumn([
                'max_ai_videos',
                'current_ai_videos_count',
                'max_video_duration',
                'video_quality',
                'max_ai_images',
                'current_ai_images_count',
                'max_ai_texts',
                'current_ai_texts_count',
                'max_social_accounts',
                'max_team_members',
                'priority_processing',
                'advanced_analytics',
            ]);
        });

        Schema::table('subscription_plans', function (Blueprint $table) {
            $table->dropColumn([
                'max_ai_videos',
                'max_video_duration',
                'video_quality',
                'max_ai_images',
                'max_ai_texts',
                'max_social_accounts',
                'max_team_members',
                'priority_processing',
                'advanced_analytics',
            ]);
        });
    }
};
