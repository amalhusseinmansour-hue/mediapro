# أوامر التنفيذ السريعة - Quick Setup Commands

## 1. إعداد المشروع الأساسي

```bash
cd backend

# نسخ ملف البيئة
cp .env.example .env

# توليد مفتاح التطبيق
php artisan key:generate

# إعداد قاعدة البيانات في .env
# ثم تشغيل التعليمات التالية
```

## 2. تثبيت Packages الإضافية

```bash
# Laravel Sanctum للـ API Authentication
composer require laravel/sanctum

# Spatie Media Library
composer require spatie/laravel-medialibrary

# Laravel Horizon
composer require laravel/horizon

# Laravel Telescope (للتطوير فقط)
composer require laravel/telescope --dev

# Laravel Excel
composer require maatwebsite/excel

# نشر ملفات التكوين
php artisan vendor:publish --tag=sanctum-config
php artisan vendor:publish --tag=horizon-config
php artisan vendor:publish --tag=telescope-config
```

## 3. تثبيت Filament

```bash
# تثبيت Filament Panel
php artisan filament:install --panels

# إنشاء مستخدم Admin
php artisan make:filament-user
```

## 4. إنشاء Migrations

```bash
# إنشاء كل الـ Migrations
php artisan make:migration create_subscriptions_table
php artisan make:migration add_subscription_fields_to_users_table
php artisan make:migration create_social_accounts_table
php artisan make:migration create_posts_table
php artisan make:migration create_post_schedules_table
php artisan make:migration create_ai_requests_table
php artisan make:migration create_analytics_table
php artisan make:migration create_activity_logs_table
php artisan make:migration create_content_templates_table
php artisan make:migration create_media_table

# تشغيل Migrations
php artisan migrate
```

**ملاحظة**: انسخ محتوى كل migration من ملف `DATABASE_STRUCTURE.md`

## 5. إنشاء Models

```bash
php artisan make:model Subscription
php artisan make:model SocialAccount
php artisan make:model Post
php artisan make:model PostSchedule
php artisan make:model AIRequest
php artisan make:model Analytics
php artisan make:model ActivityLog
php artisan make:model ContentTemplate
php artisan make:model Media
```

**ملاحظة**: انسخ محتوى كل model من ملف `MODELS_COMPLETE.md`

## 6. إنشاء Filament Resources

```bash
# Resources الأساسية
php artisan make:filament-resource User --generate
php artisan make:filament-resource Subscription --generate
php artisan make:filament-resource SocialAccount --generate
php artisan make:filament-resource Post --generate
php artisan make:filament-resource PostSchedule --generate
php artisan make:filament-resource AIRequest --generate
php artisan make:filament-resource Analytics --generate
php artisan make:filament-resource ActivityLog --generate
php artisan make:filament-resource ContentTemplate --generate
php artisan make:filament-resource Media --generate
```

## 7. إنشاء Widgets للـ Dashboard

```bash
php artisan make:filament-widget StatsOverview --stats-overview
php artisan make:filament-widget LatestPosts --table-widget
php artisan make:filament-widget EngagementChart --chart-widget
php artisan make:filament-widget PlatformDistribution --chart-widget
php artisan make:filament-widget RecentActivity --table-widget
```

## 8. إنشاء API Controllers

```bash
php artisan make:controller Api/AuthController
php artisan make:controller Api/UserController
php artisan make:controller Api/PostController
php artisan make:controller Api/SocialAccountController
php artisan make:controller Api/AIController
php artisan make:controller Api/AnalyticsController
php artisan make:controller Api/MediaController
```

## 9. إنشاء Jobs

```bash
php artisan make:job PublishPostJob
php artisan make:job PublishScheduledPostsJob
php artisan make:job SyncSocialAccountJob
php artisan make:job SyncSocialAccountsJob
php artisan make:job GenerateAIContentJob
php artisan make:job CollectAnalyticsJob
php artisan make:job SyncAnalyticsJob
```

## 10. إنشاء Requests للـ Validation

```bash
php artisan make:request Auth/RegisterRequest
php artisan make:request Auth/LoginRequest
php artisan make:request Post/StorePostRequest
php artisan make:request Post/UpdatePostRequest
php artisan make:request SocialAccount/StoreSocialAccountRequest
php artisan make:request AI/GenerateContentRequest
```

## 11. إنشاء Resources للـ API

```bash
php artisan make:resource UserResource
php artisan make:resource PostResource
php artisan make:resource SocialAccountResource
php artisan make:resource AIRequestResource
php artisan make:resource AnalyticsResource
```

## 12. إنشاء Policies

```bash
php artisan make:policy UserPolicy --model=User
php artisan make:policy PostPolicy --model=Post
php artisan make:policy SocialAccountPolicy --model=SocialAccount
```

## 13. إعداد Queue

```bash
# إنشاء جداول Queue
php artisan queue:table
php artisan queue:failed-table
php artisan migrate

# في .env أضف
QUEUE_CONNECTION=database
```

## 14. إعداد Storage

```bash
# إنشاء symbolic link للـ storage
php artisan storage:link
```

## 15. تشغيل المشروع

### Development

```bash
# تشغيل Development Server
php artisan serve

# تشغيل Queue Worker (في terminal منفصل)
php artisan queue:work

# تشغيل Scheduler (إضافة إلى crontab في الإنتاج)
# * * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
```

### Production

```bash
# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# تشغيل Horizon (بدلاً من queue:work)
php artisan horizon

# تشغيل Supervisor لـ Queue Workers
# راجع Laravel Documentation
```

## 16. Seeds (اختياري)

```bash
# إنشاء Seeders
php artisan make:seeder UserSeeder
php artisan make:seeder SubscriptionPlanSeeder

# تشغيل Seeders
php artisan db:seed
```

## 17. Tests (اختياري)

```bash
# إنشاء Tests
php artisan make:test Api/AuthTest
php artisan make:test Api/PostTest
php artisan make:test Api/SocialAccountTest

# تشغيل Tests
php artisan test
```

## الوصول للـ Admin Panel

```
URL: http://localhost:8000/admin
```

## API Base URL

```
Base URL: http://localhost:8000/api
```

## أوامر مساعدة

```bash
# عرض جميع Routes
php artisan route:list

# عرض جميع Commands
php artisan list

# تنظيف Cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# إعادة تشغيل Queue Workers
php artisan queue:restart

# عرض حالة Horizon
php artisan horizon:status

# عرض Failed Jobs
php artisan queue:failed

# إعادة محاولة Failed Job
php artisan queue:retry {id}

# حذف Failed Job
php artisan queue:forget {id}
```

## Git Setup (اختياري)

```bash
git init
git add .
git commit -m "Initial commit: Laravel + Filament Backend Setup"
```

## Environment Variables المطلوبة

في ملف `.env`:

```env
APP_NAME="Social Media Manager Backend"
APP_ENV=local
APP_KEY=base64:...
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_manager
DB_USERNAME=root
DB_PASSWORD=

QUEUE_CONNECTION=database

# API Configuration
API_RATE_LIMIT=60

# Social Media API Keys
FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=
INSTAGRAM_APP_ID=
INSTAGRAM_APP_SECRET=
TWITTER_API_KEY=
TWITTER_API_SECRET=
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=

# AI Services
OPENAI_API_KEY=
GOOGLE_AI_API_KEY=

# Mail Configuration (for notifications)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@social-media-manager.com
MAIL_FROM_NAME="${APP_NAME}"

# AWS S3 (if using for media storage)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=

# Session & Security
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=false

# Sanctum
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,localhost:8000
```

## ملاحظات مهمة

1. **أمان البيانات**: تأكد من تشفير الـ tokens في SocialAccount model
2. **Rate Limiting**: قم بتطبيق rate limiting على API endpoints
3. **Validation**: أضف validation قوية لجميع الـ requests
4. **Error Handling**: استخدم try-catch وسجل الأخطاء
5. **Testing**: اكتب tests للـ features الأساسية
6. **Documentation**: وثق جميع API endpoints
7. **Monitoring**: استخدم Telescope في التطوير وHorizon للإنتاج
8. **Backups**: قم بإعداد نظام backup تلقائي
9. **CORS**: قم بإعداد CORS للسماح للتطبيق بالوصول للـ API
10. **SSL**: استخدم HTTPS في الإنتاج

## الخطوة التالية

بعد تنفيذ جميع الأوامر أعلاه، يمكنك:

1. الدخول إلى Admin Panel والتأكد من عمل Filament
2. إنشاء Users وSubscriptions للاختبار
3. اختبار API Endpoints باستخدام Postman/Insomnia
4. إضافة Customizations للـ Filament Resources
5. تطوير الـ Frontend Integration

---

**تم إنشاؤه بواسطة Claude Code**
**جميع الملفات والكود جاهزة للاستخدام!**
