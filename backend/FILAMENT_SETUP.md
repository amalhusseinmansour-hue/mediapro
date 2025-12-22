# Social Media Manager - دليل إعداد Backend Filament

## نظرة عامة
Backend كامل مبني على Laravel + Filament لإدارة تطبيق Social Media Manager

## المتطلبات
- PHP 8.2+
- Composer
- MySQL/PostgreSQL
- Node.js & NPM

## خطوات التثبيت الأولية

### 1. إعداد البيئة

```bash
# نسخ ملف البيئة
cd backend
cp .env.example .env

# توليد مفتاح التطبيق
php artisan key:generate
```

### 2. إعداد قاعدة البيانات

في ملف `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_manager
DB_USERNAME=root
DB_PASSWORD=
```

### 3. تثبيت Filament

```bash
# تثبيت Filament Panel
php artisan filament:install --panels

# إنشاء مستخدم Admin
php artisan make:filament-user
```

## هيكل قاعدة البيانات

### الجداول الأساسية

#### 1. جدول المستخدمين (Users)
```sql
- id
- name
- email
- password
- phone
- avatar
- subscription_type (enum: individual, company)
- subscription_status (enum: active, inactive, expired)
- subscription_start_date
- subscription_end_date
- company_name (nullable)
- company_size (nullable)
- timezone
- language
- email_verified_at
- remember_token
- timestamps
- soft_deletes
```

#### 2. جدول الاشتراكات (Subscriptions)
```sql
- id
- user_id
- plan_type (enum: individual, company)
- plan_name
- price
- currency
- billing_cycle (enum: monthly, yearly)
- features (json)
- limits (json) -> {accounts_limit, posts_limit, ai_requests_limit}
- status (enum: active, cancelled, expired)
- started_at
- expires_at
- auto_renew (boolean)
- timestamps
```

#### 3. جدول الحسابات الاجتماعية (SocialAccounts)
```sql
- id
- user_id
- platform (enum: facebook, instagram, twitter, linkedin, tiktok, youtube, pinterest)
- account_name
- account_username
- account_id (platform-specific ID)
- access_token (encrypted)
- refresh_token (encrypted, nullable)
- token_expires_at
- profile_picture_url
- followers_count
- is_active (boolean)
- last_sync_at
- settings (json)
- timestamps
```

#### 4. جدول المنشورات (Posts)
```sql
- id
- user_id
- title
- content
- media_urls (json) -> array of image/video URLs
- media_type (enum: image, video, mixed, none)
- post_type (enum: post, story, reel)
- status (enum: draft, scheduled, published, failed)
- scheduled_at
- published_at
- platforms (json) -> array of platform names
- platform_specific_content (json)
- ai_generated (boolean)
- ai_prompt (text, nullable)
- hashtags (json)
- mentions (json)
- location (string, nullable)
- engagement_metrics (json) -> {likes, comments, shares, views}
- timestamps
- soft_deletes
```

#### 5. جدول جدولة المنشورات (PostSchedules)
```sql
- id
- post_id
- social_account_id
- scheduled_at
- published_at
- platform_post_id (nullable)
- status (enum: pending, published, failed)
- error_message (text, nullable)
- retry_count (integer, default: 0)
- timestamps
```

#### 6. جدول طلبات الذكاء الاصطناعي (AIRequests)
```sql
- id
- user_id
- request_type (enum: text_generation, image_generation, content_ideas, hashtags)
- ai_service (enum: chatgpt, gemini, dalle)
- prompt (text)
- parameters (json)
- response (text)
- tokens_used (integer)
- cost (decimal)
- status (enum: pending, completed, failed)
- error_message (text, nullable)
- timestamps
```

#### 7. جدول التحليلات (Analytics)
```sql
- id
- user_id
- social_account_id
- post_id (nullable)
- metric_type (enum: followers, engagement, reach, impressions)
- metric_value (integer)
- date
- platform
- additional_data (json)
- timestamps
```

#### 8. جدول الإشعارات (Notifications)
```sql
- id
- user_id
- type
- title
- message
- data (json)
- read_at
- action_url (nullable)
- timestamps
```

#### 9. جدول السجلات (ActivityLogs)
```sql
- id
- user_id
- action
- model_type
- model_id
- description
- ip_address
- user_agent
- timestamps
```

## الأوامر المطلوبة

### إنشاء Migrations

```bash
# المستخدمون والاشتراكات
php artisan make:migration create_subscriptions_table
php artisan make:migration add_subscription_fields_to_users_table

# الحسابات الاجتماعية
php artisan make:migration create_social_accounts_table

# المنشورات
php artisan make:migration create_posts_table
php artisan make:migration create_post_schedules_table

# الذكاء الاصطناعي
php artisan make:migration create_ai_requests_table

# التحليلات
php artisan make:migration create_analytics_table

# الإشعارات والسجلات
php artisan make:migration create_activity_logs_table

# تشغيل Migrations
php artisan migrate
```

### إنشاء Models

```bash
php artisan make:model Subscription
php artisan make:model SocialAccount
php artisan make:model Post
php artisan make:model PostSchedule
php artisan make:model AIRequest
php artisan make:model Analytics
php artisan make:model ActivityLog
```

### إنشاء Filament Resources

```bash
# Resources للمستخدمين والاشتراكات
php artisan make:filament-resource User --generate
php artisan make:filament-resource Subscription --generate

# Resources للحسابات الاجتماعية
php artisan make:filament-resource SocialAccount --generate

# Resources للمنشورات
php artisan make:filament-resource Post --generate
php artisan make:filament-resource PostSchedule --generate

# Resources للذكاء الاصطناعي
php artisan make:filament-resource AIRequest --generate

# Resources للتحليلات
php artisan make:filament-resource Analytics --generate

# Resources للسجلات
php artisan make:filament-resource ActivityLog --generate
```

### إنشاء Widgets للـ Dashboard

```bash
php artisan make:filament-widget StatsOverview --stats-overview
php artisan make:filament-widget LatestPosts --table
php artisan make:filament-widget EngagementChart --chart
php artisan make:filament-widget PlatformDistribution --chart
```

## إعدادات API

### إنشاء API Controllers

```bash
php artisan make:controller Api/AuthController
php artisan make:controller Api/UserController
php artisan make:controller Api/PostController
php artisan make:controller Api/SocialAccountController
php artisan make:controller Api/AIController
php artisan make:controller Api/AnalyticsController
```

### API Endpoints المطلوبة

#### Authentication
- POST `/api/register` - تسجيل مستخدم جديد
- POST `/api/login` - تسجيل الدخول
- POST `/api/logout` - تسجيل الخروج
- POST `/api/refresh` - تحديث Token
- GET `/api/user` - معلومات المستخدم الحالي

#### Users
- GET `/api/users/{id}` - معلومات مستخدم
- PUT `/api/users/{id}` - تحديث معلومات المستخدم
- GET `/api/users/{id}/subscription` - معلومات الاشتراك

#### Social Accounts
- GET `/api/social-accounts` - قائمة الحسابات
- POST `/api/social-accounts` - ربط حساب جديد
- PUT `/api/social-accounts/{id}` - تحديث حساب
- DELETE `/api/social-accounts/{id}` - حذف حساب
- POST `/api/social-accounts/{id}/sync` - مزامنة البيانات

#### Posts
- GET `/api/posts` - قائمة المنشورات
- GET `/api/posts/{id}` - تفاصيل منشور
- POST `/api/posts` - إنشاء منشور جديد
- PUT `/api/posts/{id}` - تحديث منشور
- DELETE `/api/posts/{id}` - حذف منشور
- POST `/api/posts/{id}/schedule` - جدولة منشور
- POST `/api/posts/{id}/publish` - نشر منشور فوراً
- GET `/api/posts/{id}/analytics` - إحصائيات منشور

#### AI Services
- POST `/api/ai/generate-text` - توليد نص
- POST `/api/ai/generate-image` - توليد صورة
- POST `/api/ai/generate-ideas` - توليد أفكار
- POST `/api/ai/generate-hashtags` - توليد هاشتاجات
- GET `/api/ai/usage` - استخدام الذكاء الاصطناعي

#### Analytics
- GET `/api/analytics/overview` - نظرة عامة
- GET `/api/analytics/engagement` - إحصائيات التفاعل
- GET `/api/analytics/growth` - إحصائيات النمو
- GET `/api/analytics/platforms` - إحصائيات حسب المنصة
- GET `/api/analytics/export` - تصدير التقارير

## Packages الإضافية المطلوبة

```bash
# Laravel Sanctum للـ API Authentication
composer require laravel/sanctum

# Spatie Media Library لإدارة الملفات
composer require spatie/laravel-medialibrary

# Laravel Horizon لإدارة Queues
composer require laravel/horizon

# Laravel Telescope للـ debugging
composer require laravel/telescope --dev

# Laravel Excel لتصدير البيانات
composer require maatwebsite/excel

# Intervention Image لمعالجة الصور
composer require intervention/image

# Carbon للتعامل مع التواريخ
composer require nesbot/carbon

# Guzzle للـ HTTP requests
composer require guzzlehttp/guzzle

# Socialite للـ OAuth
composer require laravel/socialite
```

## إعداد Queue & Jobs

```bash
# إنشاء Jobs
php artisan make:job PublishPostJob
php artisan make:job SyncSocialAccountJob
php artisan make:job GenerateAIContentJob
php artisan make:job CollectAnalyticsJob

# إعداد Queue في .env
QUEUE_CONNECTION=database

# إنشاء جدول Jobs
php artisan queue:table
php artisan queue:failed-table
php artisan migrate

# تشغيل Queue Worker
php artisan queue:work
```

## إعداد Scheduler

في `app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule)
{
    // نشر المنشورات المجدولة كل دقيقة
    $schedule->job(new PublishScheduledPostsJob)->everyMinute();

    // مزامنة التحليلات كل ساعة
    $schedule->job(new SyncAnalyticsJob)->hourly();

    // تحديث بيانات الحسابات الاجتماعية كل 6 ساعات
    $schedule->job(new SyncSocialAccountsJob)->everySixHours();

    // تنظيف السجلات القديمة يومياً
    $schedule->command('activitylog:clean')->daily();
}
```

## إعدادات الأمان

### في `.env`:

```env
# API Rate Limiting
API_RATE_LIMIT=60

# Session Configuration
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=true

# CORS
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,your-domain.com
```

### إعداد CORS في `config/cors.php`

## التوثيق

### Swagger/OpenAPI Documentation

```bash
composer require darkaonline/l5-swagger
php artisan vendor:publish --provider="L5Swagger\L5SwaggerServiceProvider"
php artisan l5-swagger:generate
```

## الاختبارات

```bash
# إنشاء Tests
php artisan make:test UserTest
php artisan make:test PostTest
php artisan make:test SocialAccountTest

# تشغيل Tests
php artisan test
```

## تشغيل المشروع

```bash
# Development Server
php artisan serve

# Compile Assets (إذا لزم الأمر)
npm install
npm run dev

# تشغيل Queue
php artisan queue:work

# تشغيل Scheduler (في الإنتاج)
# أضف إلى crontab:
# * * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
```

## الوصول إلى Filament Panel

```
URL: http://localhost:8000/admin
```

## ملاحظات مهمة

1. **الأمان**: تأكد من تشفير الـ tokens وبيانات الوصول
2. **Rate Limiting**: قم بتطبيق حدود على API requests
3. **Caching**: استخدم Cache للبيانات المستخدمة بكثرة
4. **Monitoring**: استخدم Laravel Telescope في التطوير وHorizon للإنتاج
5. **Backups**: قم بإعداد نظام backup تلقائي للقاعدة البيانات
6. **Logging**: استخدم Laravel Logging لتسجيل الأخطاء
7. **Testing**: اكتب Unit Tests و Feature Tests
8. **Documentation**: وثق جميع API endpoints

## الخطوات التالية

1. إنشاء جميع Migration files المطلوبة ✓
2. إنشاء Models مع العلاقات ✓
3. إعداد Filament Resources مع Forms و Tables مخصصة
4. إنشاء API Controllers مع Validation
5. إعداد Jobs و Queues
6. إضافة Widgets للـ Dashboard
7. إعداد Tests
8. توثيق الـ API

---

تم التوليد بواسطة Claude Code
