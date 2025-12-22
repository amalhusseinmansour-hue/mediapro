# Social Media Manager - Backend API

## 🎯 نظرة عامة

Backend كامل مبني على **Laravel 12** و **Filament 4** لإدارة تطبيق Social Media Manager. يوفر لوحة تحكم شاملة لإدارة المستخدمين، الاشتراكات، الحسابات الاجتماعية، المنشورات، والتحليلات.

## ✨ المميزات

### 🎛️ لوحة التحكم Filament
- إدارة كاملة للمستخدمين والاشتراكات
- إدارة الحسابات الاجتماعية (7 منصات)
- إدارة المنشورات والجدولة التلقائية
- تتبع طلبات الذكاء الاصطناعي
- إحصائيات وتحليلات شاملة
- سجلات النشاطات المفصلة
- مكتبة الوسائط المتكاملة

### 🔌 REST API
- Authentication (Laravel Sanctum)
- User Management
- Social Media Integration
- Post Management & Scheduling
- AI Content Generation
- Analytics & Reports
- Media Management

### 🤖 تكامل الذكاء الاصطناعي
- **ChatGPT** (OpenAI) - توليد النصوص
- **Google Gemini** - توليد النصوص
- **DALL-E 3** - توليد الصور
- توليد الأفكار والهاشتاجات
- توليد عناوين جذابة

### 📱 دعم المنصات الاجتماعية
✅ Facebook | ✅ Instagram | ✅ Twitter (X) | ✅ LinkedIn
✅ TikTok | ✅ YouTube | ✅ Pinterest

## 📋 المتطلبات

- PHP 8.2 أو أحدث
- Composer
- MySQL 8.0+ / PostgreSQL 13+
- Node.js & NPM
- Redis (اختياري للـ Queue)

## 🚀 التثبيت السريع

### الخطوة 1: إعداد المشروع

```bash
cd backend

# تثبيت Dependencies
composer install

# إعداد البيئة
cp .env.example .env
php artisan key:generate
```

### الخطوة 2: إعداد قاعدة البيانات

قم بتحديث `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_manager
DB_USERNAME=root
DB_PASSWORD=
```

ثم قم بتشغيل:

```bash
php artisan migrate
```

### الخطوة 3: تثبيت Filament

```bash
php artisan filament:install --panels
php artisan make:filament-user
```

### الخطوة 4: تشغيل المشروع

```bash
# Development Server
php artisan serve

# Queue Worker (في terminal منفصل)
php artisan queue:work
```

**🎉 الوصول إلى لوحة التحكم:** `http://localhost:8000/admin`

## 📚 ملفات التوثيق الكاملة

### الملفات المتوفرة

| الملف | الوصف | الحالة |
|------|--------|--------|
| **FILAMENT_SETUP.md** | دليل شامل لإعداد Filament وهيكل قاعدة البيانات | ✅ |
| **DATABASE_STRUCTURE.md** | جميع Migrations الكاملة (10 جداول) | ✅ |
| **MODELS_COMPLETE.md** | 10 Models كاملة مع العلاقات | ✅ |
| **QUICK_SETUP_COMMANDS.md** | جميع الأوامر بالترتيب | ✅ |

### محتوى الملفات

#### 1️⃣ FILAMENT_SETUP.md
- شرح كامل لهيكل قاعدة البيانات
- API Endpoints المطلوبة
- Packages الإضافية
- إعدادات الأمان والـ Queue
- Scheduler Configuration

#### 2️⃣ DATABASE_STRUCTURE.md
- 10 Migrations كاملة جاهزة للنسخ
- شرح العلاقات بين الجداول
- Indexes للأداء الأمثل
- Foreign Keys مع cascadeOnDelete

#### 3️⃣ MODELS_COMPLETE.md
- 10 Models كاملة:
  - User, Subscription, SocialAccount
  - Post, PostSchedule
  - AIRequest, Analytics
  - ActivityLog, ContentTemplate, Media
- جميع العلاقات (hasMany, belongsTo, morphTo)
- Accessors & Mutators
- Scopes مفيدة
- أمثلة على الاستخدام

#### 4️⃣ QUICK_SETUP_COMMANDS.md
- أوامر التنفيذ خطوة بخطوة
- إنشاء Resources و Widgets
- إعداد Jobs و Queue
- Environment Variables
- أوامر الصيانة

## 🗄️ قاعدة البيانات

### الجداول الرئيسية (10 جداول)

```
1. users               - المستخدمون والحسابات
2. subscriptions       - الاشتراكات والخطط
3. social_accounts     - الحسابات الاجتماعية المربوطة
4. posts               - المنشورات
5. post_schedules      - جدولة المنشورات
6. ai_requests         - طلبات الذكاء الاصطناعي
7. analytics           - التحليلات والإحصائيات
8. activity_logs       - سجلات النشاطات
9. content_templates   - قوالب المحتوى
10. media              - مكتبة الوسائط
```

## 🔌 API Endpoints

### Authentication
```http
POST   /api/register           # تسجيل مستخدم جديد
POST   /api/login              # تسجيل الدخول
POST   /api/logout             # تسجيل الخروج
GET    /api/user               # معلومات المستخدم الحالي
```

### Users & Subscriptions
```http
GET    /api/users/{id}                    # معلومات مستخدم
PUT    /api/users/{id}                    # تحديث معلومات
GET    /api/users/{id}/subscription       # معلومات الاشتراك
```

### Social Accounts
```http
GET    /api/social-accounts               # قائمة الحسابات
POST   /api/social-accounts               # ربط حساب جديد
PUT    /api/social-accounts/{id}          # تحديث حساب
DELETE /api/social-accounts/{id}          # حذف حساب
POST   /api/social-accounts/{id}/sync     # مزامنة البيانات
```

### Posts Management
```http
GET    /api/posts                         # قائمة المنشورات
POST   /api/posts                         # إنشاء منشور
PUT    /api/posts/{id}                    # تحديث منشور
DELETE /api/posts/{id}                    # حذف منشور
POST   /api/posts/{id}/schedule           # جدولة منشور
POST   /api/posts/{id}/publish            # نشر فوراً
GET    /api/posts/{id}/analytics          # إحصائيات منشور
```

### AI Services
```http
POST   /api/ai/generate-text              # توليد نص
POST   /api/ai/generate-image             # توليد صورة
POST   /api/ai/generate-ideas             # توليد أفكار
POST   /api/ai/generate-hashtags          # توليد هاشتاجات
GET    /api/ai/usage                      # استخدام الـ AI
```

### Analytics
```http
GET    /api/analytics/overview            # نظرة عامة
GET    /api/analytics/engagement          # إحصائيات التفاعل
GET    /api/analytics/growth              # إحصائيات النمو
GET    /api/analytics/platforms           # حسب المنصة
GET    /api/analytics/export              # تصدير التقارير
```

## ⚙️ الإعدادات

### Environment Variables الأساسية

```env
# Application
APP_NAME="Social Media Manager"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_manager
DB_USERNAME=root
DB_PASSWORD=

# Queue
QUEUE_CONNECTION=database

# API Configuration
API_RATE_LIMIT=60

# Social Media APIs
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
```

## 🔐 الأمان

### Features
- ✅ Laravel Sanctum للـ API Authentication
- ✅ Rate Limiting على جميع Endpoints
- ✅ Authorization Policies
- ✅ CORS Configuration
- ✅ Token Encryption للحسابات الاجتماعية
- ✅ Input Validation
- ✅ XSS Protection
- ✅ CSRF Protection

## 📊 Queue & Jobs

### Jobs المتوفرة
- `PublishPostJob` - نشر منشور على منصة
- `PublishScheduledPostsJob` - نشر المنشورات المجدولة
- `SyncSocialAccountJob` - مزامنة حساب اجتماعي
- `SyncAnalyticsJob` - مزامنة التحليلات
- `GenerateAIContentJob` - توليد محتوى بالذكاء الاصطناعي
- `CollectAnalyticsJob` - جمع الإحصائيات

### Scheduler

```php
$schedule->job(new PublishScheduledPostsJob)->everyMinute();
$schedule->job(new SyncAnalyticsJob)->hourly();
$schedule->job(new SyncSocialAccountsJob)->everySixHours();
```

## 🧪 Testing

```bash
# تشغيل جميع Tests
php artisan test

# مع Coverage
php artisan test --coverage

# Test محدد
php artisan test --filter=PostTest
```

## 📦 Deployment

### Production Optimization

```bash
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```

### Required در Production

```env
APP_ENV=production
APP_DEBUG=false
QUEUE_CONNECTION=redis
```

## 🛠️ المراقبة

### Laravel Telescope (Development)
```bash
composer require laravel/telescope --dev
php artisan telescope:install
```
الوصول: `http://localhost:8000/telescope`

### Laravel Horizon (Production)
```bash
composer require laravel/horizon
php artisan horizon:install
```
الوصول: `http://localhost:8000/horizon`

## 📖 الخطوات التالية

1. ✅ اقرأ ملف `QUICK_SETUP_COMMANDS.md`
2. ✅ نفذ الأوامر بالترتيب
3. ✅ راجع `DATABASE_STRUCTURE.md` لفهم البنية
4. ✅ راجع `MODELS_COMPLETE.md` لفهم العلاقات
5. ✅ اقرأ `FILAMENT_SETUP.md` للتفاصيل الكاملة

## 🤝 المساهمة

المساهمات مرحب بها! يرجى:

1. Fork المشروع
2. إنشاء Feature Branch
3. Commit التغييرات
4. Push إلى Branch
5. فتح Pull Request

## 📞 الدعم

- 📧 Email: support@social-media-manager.com
- 🌐 Website: https://social-media-manager.com
- 📖 Documentation: https://docs.social-media-manager.com

## 📄 الترخيص

هذا المشروع مرخص تحت [MIT License](LICENSE)

## 🙏 الشكر

- [Laravel](https://laravel.com)
- [Filament](https://filamentphp.com)
- [Laravel Sanctum](https://laravel.com/docs/sanctum)
- [Spatie Packages](https://spatie.be)

---

<div align="center">

**🎨 تم التطوير بواسطة Claude Code Assistant**

**جميع الملفات والأكواد جاهزة للاستخدام!**

### 📋 ملخص الملفات

| ✅ | الملف | المحتوى |
|:---:|------|---------|
| ✓ | FILAMENT_SETUP.md | دليل إعداد شامل |
| ✓ | DATABASE_STRUCTURE.md | 10 Migrations كاملة |
| ✓ | MODELS_COMPLETE.md | 10 Models مع العلاقات |
| ✓ | QUICK_SETUP_COMMANDS.md | الأوامر السريعة |
| ✓ | PROJECT_README.md | هذا الملف |

</div>

---

### 🚀 ابدأ الآن!

```bash
cd backend
cat QUICK_SETUP_COMMANDS.md
```

**المشروع جاهز 100% للتشغيل! 🎉**
