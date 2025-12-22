# Database Structure - البنية الكاملة لقاعدة البيانات

## Migrations الكاملة

### 1. Subscriptions Table

```php
<?php
// database/migrations/xxxx_create_subscriptions_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('plan_type', ['individual', 'company'])->default('individual');
            $table->string('plan_name');
            $table->decimal('price', 10, 2);
            $table->string('currency', 3)->default('USD');
            $table->enum('billing_cycle', ['monthly', 'yearly'])->default('monthly');
            $table->json('features')->nullable();
            $table->json('limits')->nullable(); // {accounts_limit, posts_limit, ai_requests_limit}
            $table->enum('status', ['active', 'cancelled', 'expired', 'pending'])->default('pending');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->boolean('auto_renew')->default(true);
            $table->string('payment_method')->nullable();
            $table->string('transaction_id')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('subscriptions');
    }
};
```

### 2. Update Users Table

```php
<?php
// database/migrations/xxxx_add_subscription_fields_to_users_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->nullable()->after('email');
            $table->string('avatar')->nullable();
            $table->enum('subscription_type', ['individual', 'company', 'trial'])->default('trial');
            $table->enum('subscription_status', ['active', 'inactive', 'expired', 'trial'])->default('trial');
            $table->timestamp('subscription_start_date')->nullable();
            $table->timestamp('subscription_end_date')->nullable();
            $table->string('company_name')->nullable();
            $table->integer('company_size')->nullable();
            $table->string('timezone')->default('UTC');
            $table->string('language', 2)->default('ar');
            $table->json('preferences')->nullable();
            $table->timestamp('last_login_at')->nullable();
            $table->softDeletes();
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'phone', 'avatar', 'subscription_type', 'subscription_status',
                'subscription_start_date', 'subscription_end_date', 'company_name',
                'company_size', 'timezone', 'language', 'preferences', 'last_login_at'
            ]);
            $table->dropSoftDeletes();
        });
    }
};
```

### 3. Social Accounts Table

```php
<?php
// database/migrations/xxxx_create_social_accounts_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('social_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('platform', ['facebook', 'instagram', 'twitter', 'linkedin', 'tiktok', 'youtube', 'pinterest']);
            $table->string('account_name');
            $table->string('account_username')->nullable();
            $table->string('account_id'); // Platform-specific ID
            $table->text('access_token'); // Encrypted
            $table->text('refresh_token')->nullable(); // Encrypted
            $table->timestamp('token_expires_at')->nullable();
            $table->string('profile_picture_url')->nullable();
            $table->bigInteger('followers_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_sync_at')->nullable();
            $table->json('settings')->nullable();
            $table->json('capabilities')->nullable(); // What the account can do
            $table->timestamps();
            $table->unique(['user_id', 'platform', 'account_id']);
            $table->index(['user_id', 'is_active']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('social_accounts');
    }
};
```

### 4. Posts Table

```php
<?php
// database/migrations/xxxx_create_posts_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title')->nullable();
            $table->text('content');
            $table->json('media_urls')->nullable();
            $table->enum('media_type', ['image', 'video', 'mixed', 'none'])->default('none');
            $table->enum('post_type', ['post', 'story', 'reel', 'thread'])->default('post');
            $table->enum('status', ['draft', 'scheduled', 'publishing', 'published', 'failed'])->default('draft');
            $table->timestamp('scheduled_at')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->json('platforms'); // Array of platform names
            $table->json('platform_specific_content')->nullable();
            $table->boolean('ai_generated')->default(false);
            $table->text('ai_prompt')->nullable();
            $table->string('ai_service')->nullable();
            $table->json('hashtags')->nullable();
            $table->json('mentions')->nullable();
            $table->string('location')->nullable();
            $table->json('engagement_metrics')->nullable(); // {likes, comments, shares, views}
            $table->timestamps();
            $table->softDeletes();
            $table->index(['user_id', 'status']);
            $table->index(['scheduled_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('posts');
    }
};
```

### 5. Post Schedules Table

```php
<?php
// database/migrations/xxxx_create_post_schedules_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('post_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('post_id')->constrained()->cascadeOnDelete();
            $table->foreignId('social_account_id')->constrained()->cascadeOnDelete();
            $table->timestamp('scheduled_at');
            $table->timestamp('published_at')->nullable();
            $table->string('platform_post_id')->nullable();
            $table->string('platform_post_url')->nullable();
            $table->enum('status', ['pending', 'publishing', 'published', 'failed'])->default('pending');
            $table->text('error_message')->nullable();
            $table->integer('retry_count')->default(0);
            $table->timestamp('next_retry_at')->nullable();
            $table->timestamps();
            $table->index(['post_id', 'status']);
            $table->index(['scheduled_at', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('post_schedules');
    }
};
```

### 6. AI Requests Table

```php
<?php
// database/migrations/xxxx_create_ai_requests_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('ai_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('request_type', ['text_generation', 'image_generation', 'content_ideas', 'hashtags', 'caption']);
            $table->enum('ai_service', ['chatgpt', 'gemini', 'dalle'])->default('chatgpt');
            $table->text('prompt');
            $table->json('parameters')->nullable();
            $table->text('response')->nullable();
            $table->integer('tokens_used')->default(0);
            $table->decimal('cost', 10, 4)->default(0);
            $table->enum('status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->text('error_message')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'status']);
            $table->index(['created_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('ai_requests');
    }
};
```

### 7. Analytics Table

```php
<?php
// database/migrations/xxxx_create_analytics_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('analytics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('social_account_id')->constrained()->cascadeOnDelete();
            $table->foreignId('post_id')->nullable()->constrained()->nullOnDelete();
            $table->enum('metric_type', ['followers', 'engagement', 'reach', 'impressions', 'clicks', 'saves', 'shares']);
            $table->bigInteger('metric_value');
            $table->date('date');
            $table->string('platform');
            $table->json('additional_data')->nullable();
            $table->timestamps();
            $table->unique(['social_account_id', 'metric_type', 'date']);
            $table->index(['user_id', 'date']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('analytics');
    }
};
```

### 8. Activity Logs Table

```php
<?php
// database/migrations/xxxx_create_activity_logs_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('action');
            $table->string('model_type')->nullable();
            $table->bigInteger('model_id')->nullable();
            $table->text('description');
            $table->json('properties')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'created_at']);
            $table->index(['model_type', 'model_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('activity_logs');
    }
};
```

### 9. Content Templates Table

```php
<?php
// database/migrations/xxxx_create_content_templates_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('content_templates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('content');
            $table->string('category')->nullable();
            $table->json('tags')->nullable();
            $table->json('default_platforms')->nullable();
            $table->boolean('is_public')->default(false);
            $table->integer('usage_count')->default(0);
            $table->timestamps();
            $table->index(['user_id', 'category']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('content_templates');
    }
};
```

### 10. Media Library Table

```php
<?php
// database/migrations/xxxx_create_media_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('media', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('file_name');
            $table->string('mime_type');
            $table->string('path');
            $table->bigInteger('size'); // bytes
            $table->integer('width')->nullable();
            $table->integer('height')->nullable();
            $table->integer('duration')->nullable(); // for videos in seconds
            $table->json('metadata')->nullable();
            $table->enum('type', ['image', 'video', 'document'])->default('image');
            $table->string('thumbnail_path')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'type']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('media');
    }
};
```

## تشغيل Migrations

```bash
cd backend
php artisan migrate
```

## ملاحظات مهمة

1. **Encryption**: يجب تشفير `access_token` و `refresh_token` باستخدام Laravel Encryption
2. **Indexes**: تم إضافة indexes للأعمدة الأكثر استخداماً في الاستعلامات
3. **Foreign Keys**: تم إضافة foreign keys مع cascadeOnDelete لحذف البيانات المرتبطة تلقائياً
4. **Soft Deletes**: تم إضافة soft deletes للجداول المهمة (users, posts)
5. **JSON Fields**: استخدام JSON لتخزين البيانات المرنة
6. **Timestamps**: جميع الجداول تحتوي على timestamps

---

الملف التالي سيحتوي على جميع الـ Models مع العلاقات
