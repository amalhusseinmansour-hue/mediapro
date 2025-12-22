<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Social Accounts Table
        if (!Schema::hasTable('social_accounts')) {
            Schema::create('social_accounts', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('user_id');
                $table->string('integration_id');
                $table->string('platform', 50);
                $table->string('account_name')->nullable();
                $table->string('username')->nullable();
                $table->text('profile_picture')->nullable();
                $table->text('access_token')->nullable();
                $table->text('refresh_token')->nullable();
                $table->timestamp('token_expires_at')->nullable();
                $table->integer('followers')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();

                $table->index('user_id');
                $table->index('platform');
                $table->index('integration_id');
                $table->index(['user_id', 'platform']);
            });
        }

        // Posts Table
        if (!Schema::hasTable('posts')) {
            Schema::create('posts', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('user_id');
                $table->json('content');
                $table->json('integration_ids');
                $table->enum('status', ['draft', 'scheduled', 'publishing', 'published', 'failed'])->default('draft');
                $table->timestamp('scheduled_at')->nullable();
                $table->timestamp('published_at')->nullable();
                $table->json('platform_post_ids')->nullable();
                $table->text('error_message')->nullable();
                $table->timestamps();

                $table->index('user_id');
                $table->index('status');
                $table->index('scheduled_at');
                $table->index('published_at');
                $table->index(['user_id', 'status']);
            });
        }

        // Post Analytics Table
        if (!Schema::hasTable('post_analytics')) {
            Schema::create('post_analytics', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('post_id');
                $table->string('platform', 50);
                $table->string('platform_post_id')->nullable();
                $table->integer('likes')->default(0);
                $table->integer('comments')->default(0);
                $table->integer('shares')->default(0);
                $table->integer('views')->default(0);
                $table->integer('reach')->default(0);
                $table->integer('impressions')->default(0);
                $table->integer('clicks')->default(0);
                $table->integer('saves')->default(0);
                $table->decimal('engagement_rate', 5, 2)->default(0.00);
                $table->timestamp('last_synced_at')->nullable();
                $table->timestamps();

                $table->index('post_id');
                $table->index('platform');
                $table->index('platform_post_id');
                $table->unique(['post_id', 'platform']);
                $table->foreign('post_id')->references('id')->on('posts')->onDelete('cascade');
            });
        }

        // Account Analytics Table
        if (!Schema::hasTable('account_analytics')) {
            Schema::create('account_analytics', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('social_account_id');
                $table->date('date');
                $table->integer('followers')->default(0);
                $table->integer('following')->default(0);
                $table->integer('posts_count')->default(0);
                $table->integer('total_likes')->default(0);
                $table->integer('total_comments')->default(0);
                $table->integer('total_shares')->default(0);
                $table->integer('total_reach')->default(0);
                $table->integer('total_impressions')->default(0);
                $table->decimal('engagement_rate', 5, 2)->default(0.00);
                $table->timestamps();

                $table->index('social_account_id');
                $table->index('date');
                $table->unique(['social_account_id', 'date']);
                $table->foreign('social_account_id')->references('id')->on('social_accounts')->onDelete('cascade');
            });
        }

        // Media Table
        if (!Schema::hasTable('media')) {
            Schema::create('media', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('user_id');
                $table->enum('type', ['image', 'video', 'gif']);
                $table->text('url');
                $table->string('path', 500)->nullable();
                $table->string('filename')->nullable();
                $table->integer('size')->nullable();
                $table->string('mime_type', 100)->nullable();
                $table->integer('width')->nullable();
                $table->integer('height')->nullable();
                $table->integer('duration')->nullable();
                $table->timestamps();

                $table->index('user_id');
                $table->index('type');
            });
        }

        // Add columns to users table if they don't exist
        if (Schema::hasTable('users')) {
            Schema::table('users', function (Blueprint $table) {
                if (!Schema::hasColumn('users', 'subscription_plan')) {
                    $table->enum('subscription_plan', ['free', 'basic', 'pro', 'enterprise'])->default('free');
                }
                if (!Schema::hasColumn('users', 'subscription_status')) {
                    $table->enum('subscription_status', ['active', 'inactive', 'cancelled', 'expired'])->default('inactive');
                }
                if (!Schema::hasColumn('users', 'subscription_expires_at')) {
                    $table->timestamp('subscription_expires_at')->nullable();
                }
                if (!Schema::hasColumn('users', 'posts_limit')) {
                    $table->integer('posts_limit')->default(10);
                }
                if (!Schema::hasColumn('users', 'accounts_limit')) {
                    $table->integer('accounts_limit')->default(3);
                }
                if (!Schema::hasColumn('users', 'posts_count_this_month')) {
                    $table->integer('posts_count_this_month')->default(0);
                }
                if (!Schema::hasColumn('users', 'last_reset_at')) {
                    $table->timestamp('last_reset_at')->nullable();
                }
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('account_analytics');
        Schema::dropIfExists('post_analytics');
        Schema::dropIfExists('media');
        Schema::dropIfExists('posts');
        Schema::dropIfExists('social_accounts');

        if (Schema::hasTable('users')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn([
                    'subscription_plan',
                    'subscription_status',
                    'subscription_expires_at',
                    'posts_limit',
                    'accounts_limit',
                    'posts_count_this_month',
                    'last_reset_at'
                ]);
            });
        }
    }
};
