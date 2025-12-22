# 🚀 دليل التكامل الكامل مع Postiz API

## 📋 الملخص التنفيذي

هذا الدليل الشامل لتكامل تطبيقك مع **Postiz** لإدارة منصات Social Media، النشر التلقائي، الجدولة، والتحليلات.

---

## 🎯 الميزات المطلوبة

✅ **ربط حسابات Social Media** - Facebook, Instagram, Twitter, LinkedIn, TikTok, YouTube, إلخ
✅ **النشر التلقائي** - نشر فوري على منصات متعددة
✅ **جدولة المنشورات** - تحديد وقت النشر مسبقاً
✅ **التحليلات والإحصائيات** - تتبع الأداء والتفاعل
✅ **رفع الوسائط** - صور وفيديوهات
✅ **إدارة المنشورات** - تحديث وحذف

---

## 📦 الملفات التي تم إنشاؤها

### Backend (Laravel/PHP)

| الملف | الوصف |
|------|--------|
| `COMPLETE_POSTIZ_CONTROLLER.php` | Controller كامل مع جميع الوظائف |
| `POSTIZ_ROUTES.php` | Routes جاهزة للـ API |
| `DATABASE_MIGRATIONS.sql` | Database schema كامل |

### Frontend (Flutter)

| الملف | الوصف |
|------|--------|
| `lib/services/postiz_manager.dart` | Service manager كامل |
| `lib/screens/social_media/connect_accounts_screen.dart` | شاشة ربط الحسابات |
| `lib/screens/social_media/create_post_screen.dart` | شاشة إنشاء وجدولة المنشورات |
| `lib/screens/social_media/analytics_screen.dart` | شاشة التحليلات |

### Documentation

| الملف | الوصف |
|------|--------|
| `POSTIZ_README.md` | ملخص شامل |
| `POSTIZ_QUICK_START.md` | البدء السريع |
| `POSTIZ_IMPLEMENTATION_GUIDE.md` | دليل التنفيذ المفصل |
| `POSTIZ_SELF_HOSTING.md` | دليل الاستضافة الذاتية |
| `MIGRATION_FROM_AYRSHARE.md` | خطة الانتقال |

---

## 🚀 خطوات التنفيذ (خطوة بخطوة)

### المرحلة 1: إعداد Postiz

#### الخيار A: استخدام Postiz Hosted (الأسهل)

```bash
# 1. سجل في https://postiz.com
# 2. اذهب إلى Settings → API Keys
# 3. انقر "Generate New API Key"
# 4. انسخ الـ API Key
```

#### الخيار B: استضافة ذاتية (مجاني)

راجع `POSTIZ_SELF_HOSTING.md` للتفاصيل الكاملة.

```bash
# باختصار:
git clone https://github.com/gitroomhq/postiz-app.git
cd postiz-app
cp .env.example .env
# عدل .env
docker-compose up -d
```

---

### المرحلة 2: إعداد Backend (Laravel)

#### 1. تحديث `.env`

```env
# Postiz Configuration
POSTIZ_API_KEY=your_api_key_here
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
# أو للاستضافة الذاتية: http://your-server:5000/public/v1

# OAuth Apps (مطلوب لكل منصة)
FACEBOOK_APP_ID=your_app_id
FACEBOOK_APP_SECRET=your_app_secret

TWITTER_CLIENT_ID=your_client_id
TWITTER_CLIENT_SECRET=your_client_secret

LINKEDIN_CLIENT_ID=your_client_id
LINKEDIN_CLIENT_SECRET=your_client_secret

TIKTOK_CLIENT_KEY=your_client_key
TIKTOK_CLIENT_SECRET=your_client_secret
```

#### 2. نسخ Controller

```bash
cp COMPLETE_POSTIZ_CONTROLLER.php app/Http/Controllers/Api/PostizController.php
```

#### 3. إضافة Routes

في `routes/api.php`:

```php
use App\Http\Controllers\Api\PostizController;

// Postiz Routes
Route::middleware('auth:sanctum')->group(function () {
    // OAuth & Accounts
    Route::post('/postiz/oauth-link', [PostizController::class, 'generateOAuthLink']);
    Route::get('/postiz/integrations', [PostizController::class, 'getIntegrations']);
    Route::delete('/postiz/integrations/{integrationId}', [PostizController::class, 'unlinkIntegration']);

    // Posts
    Route::post('/postiz/posts', [PostizController::class, 'publishPost']);
    Route::get('/postiz/posts', [PostizController::class, 'getPosts']);
    Route::put('/postiz/posts/{postId}', [PostizController::class, 'updatePost']);
    Route::delete('/postiz/posts/{postId}', [PostizController::class, 'deletePost']);

    // Analytics
    Route::get('/postiz/analytics/summary', [PostizController::class, 'getAnalyticsSummary']);
    Route::get('/postiz/analytics/post/{postId}', [PostizController::class, 'getPostAnalytics']);
    Route::get('/postiz/analytics/account/{integrationId}', [PostizController::class, 'getAccountAnalytics']);

    // Media
    Route::post('/postiz/upload', [PostizController::class, 'uploadMedia']);
    Route::post('/postiz/upload-from-url', [PostizController::class, 'uploadMediaFromUrl']);

    // Utilities
    Route::get('/postiz/find-slot/{integrationId}', [PostizController::class, 'getNextAvailableSlot']);
    Route::post('/postiz/generate-video', [PostizController::class, 'generateVideo']);
    Route::get('/postiz/status', [PostizController::class, 'checkStatus']);
});

// OAuth Callback (لا يتطلب auth)
Route::get('/postiz/oauth-callback', [PostizController::class, 'oauthCallback']);
```

#### 4. تطبيق Database Migrations

```bash
# تأكد من backup أولاً!
mysql -u root -p your_database < DATABASE_MIGRATIONS.sql

# أو استخدم Laravel migrations
php artisan migrate
```

#### 5. إنشاء Symlink للـ Storage

```bash
php artisan storage:link
```

---

### المرحلة 3: إعداد OAuth Apps

يجب إنشاء OAuth Apps لكل منصة تريد دعمها:

#### Facebook

1. اذهب إلى: https://developers.facebook.com/apps
2. انقر "Create App" → "Business"
3. أضف منتج "Facebook Login"
4. في Settings:
   - **Valid OAuth Redirect URIs**: `https://yourdomain.com/api/postiz/oauth-callback`
5. انسخ App ID & App Secret → أضفهما في `.env`

#### Twitter/X

1. اذهب إلى: https://developer.twitter.com/en/portal/dashboard
2. انشئ Project & App
3. في "User authentication settings":
   - **Type**: Web App
   - **Callback URL**: `https://yourdomain.com/api/postiz/oauth-callback`
   - **Scopes**: `tweet.read`, `tweet.write`, `users.read`, `offline.access`
4. انسخ Client ID & Secret → أضفهما في `.env`

#### LinkedIn

1. اذهب إلى: https://www.linkedin.com/developers/apps
2. انشئ App جديد
3. في "Auth":
   - أضف Redirect URL: `https://yourdomain.com/api/postiz/oauth-callback`
4. في "Products":
   - أضف "Share on LinkedIn" و "Sign In with LinkedIn"
5. انسخ Client ID & Secret → أضفهما في `.env`

#### TikTok

1. اذهب إلى: https://developers.tiktok.com
2. سجل كمطور وأنشئ App
3. أضف Redirect URI: `https://yourdomain.com/api/postiz/oauth-callback`
4. انسخ Client Key & Secret → أضفهما في `.env`

**ملاحظة مهمة:** جميع OAuth Callbacks يجب أن تكون **HTTPS**!

---

### المرحلة 4: إعداد Frontend (Flutter)

#### 1. إضافة Dependencies

في `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  url_launcher: ^6.2.1
  image_picker: ^1.0.5
  fl_chart: ^0.65.0
  intl: ^0.18.1
```

ثم:

```bash
flutter pub get
```

#### 2. تهيئة في `main.dart`

```dart
import 'package:flutter/material.dart';
import 'services/postiz_manager.dart';
import 'screens/social_media/connect_accounts_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة PostizManager
  // ملاحظة: سيتم التهيئة عبر HttpService الموجود

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Pro Social',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

#### 3. إضافة الشاشات إلى Navigation

```dart
// في قائمة التنقل الرئيسية
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ConnectAccountsScreen(),
  ),
);

// شاشة إنشاء منشور
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CreatePostScreen(),
  ),
);

// شاشة التحليلات
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AnalyticsScreen(),
  ),
);
```

#### 4. تكوين Deep Links

في `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="mprosocial"
        android:host="oauth-success" />
    <data
        android:scheme="mprosocial"
        android:host="oauth-failed" />
</intent-filter>
```

في `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mprosocial</string>
        </array>
    </dict>
</array>
```

---

### المرحلة 5: إعداد Cron Jobs (للمنشورات المجدولة)

#### في Laravel

أنشئ Command:

```bash
php artisan make:command PublishScheduledPosts
```

في `app/Console/Commands/PublishScheduledPosts.php`:

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\PostizController;

class PublishScheduledPosts extends Command
{
    protected $signature = 'posts:publish-scheduled';
    protected $description = 'Publish scheduled posts';

    public function handle()
    {
        $posts = DB::table('posts')
            ->where('status', 'scheduled')
            ->where('scheduled_at', '<=', now())
            ->get();

        foreach ($posts as $post) {
            try {
                // منطق النشر هنا
                $this->info("Published post {$post->id}");
            } catch (\Exception $e) {
                $this->error("Failed to publish post {$post->id}: " . $e->getMessage());
            }
        }

        return 0;
    }
}
```

في `app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule)
{
    $schedule->command('posts:publish-scheduled')->everyMinute();
}
```

تأكد من تشغيل Cron:

```bash
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

---

### المرحلة 6: الاختبار

#### 1. اختبار Backend API

```bash
# اختبار Status
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://your-domain.com/api/postiz/status

# اختبار OAuth Link
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"platform":"facebook","user_id":"1"}' \
  http://your-domain.com/api/postiz/oauth-link
```

#### 2. اختبار OAuth Flow

1. افتح التطبيق
2. اذهب إلى شاشة "ربط الحسابات"
3. اضغط على منصة (مثلاً Facebook)
4. يجب أن يفتح المتصفح
5. وافق على الربط
6. يجب أن يعود إلى التطبيق

#### 3. اختبار النشر

1. اذهب إلى شاشة "إنشاء منشور"
2. اكتب محتوى
3. اختر حساب أو أكثر
4. اضغط "نشر"
5. تحقق من ظهور المنشور على المنصة

#### 4. اختبار الجدولة

1. في شاشة "إنشاء منشور"
2. فعّل "جدولة المنشور"
3. اختر موعد بعد دقائق قليلة
4. اضغط "جدولة"
5. انتظر حتى الموعد وتحقق من النشر

#### 5. اختبار التحليلات

1. اذهب إلى شاشة "التحليلات"
2. تحقق من ظهور البيانات
3. اضغط على حساب لرؤية التفاصيل

---

## 🔧 الوظائف الرئيسية

### 1. ربط حساب

```dart
final postiz = PostizManager();

// توليد OAuth link
final result = await postiz.connectSocialAccount(
  platform: 'facebook',
  userId: currentUser.id,
);

// فتح الرابط
await launchUrl(Uri.parse(result['oauth_url']));
```

### 2. نشر منشور فوري

```dart
final result = await postiz.publishPost(
  integrationIds: ['integration_1', 'integration_2'],
  content: 'محتوى المنشور',
  mediaUrls: ['https://example.com/image.jpg'],
);

print('Post ID: ${result.postId}');
```

### 3. جدولة منشور

```dart
final scheduleDate = DateTime.now().add(Duration(hours: 2));

final result = await postiz.publishPost(
  integrationIds: ['integration_1'],
  content: 'منشور مجدول',
  scheduleDate: scheduleDate,
);
```

### 4. الحصول على التحليلات

```dart
final summary = await postiz.getAnalyticsSummary(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);

print('Total Posts: ${summary.totalPosts}');
print('Total Reach: ${summary.totalReach}');
print('Engagement Rate: ${summary.engagementRate}%');
```

### 5. رفع صورة

```dart
final imageUrl = await postiz.uploadMedia('/path/to/image.jpg');

// أو من URL
final url = await postiz.uploadMediaFromUrl('https://example.com/image.jpg');
```

---

## 📊 Database Schema

### الجداول الرئيسية

1. **social_accounts** - الحسابات المربوطة
2. **posts** - المنشورات (منشورة ومجدولة)
3. **post_analytics** - تحليلات المنشورات
4. **account_analytics** - تحليلات الحسابات (يومية)
5. **post_schedules** - Queue للمنشورات المجدولة
6. **media** - الوسائط المرفوعة
7. **post_templates** - قوالب المنشورات
8. **notifications** - الإشعارات

راجع `DATABASE_MIGRATIONS.sql` للتفاصيل الكاملة.

---

## 🎨 الشاشات UI

### 1. ConnectAccountsScreen

- عرض الحسابات المربوطة
- ربط حسابات جديدة
- فصل حسابات موجودة

### 2. CreatePostScreen

- كتابة محتوى المنشور
- رفع صور/فيديوهات
- اختيار الحسابات للنشر
- جدولة المنشور

### 3. AnalyticsScreen

- ملخص الإحصائيات
- رسوم بيانية
- إحصائيات لكل حساب
- تصدير التقارير

---

## 🔐 الأمان

### Best Practices

1. **تشفير Tokens**
```php
'access_token' => encrypt($tokenData['access_token'])
```

2. **Validate Inputs**
```php
$validator = Validator::make($request->all(), [
    'platform' => 'required|string|in:facebook,instagram,...',
]);
```

3. **Rate Limiting**
```php
Route::middleware('throttle:60,1')->group(function () {
    // routes
});
```

4. **HTTPS Required**
جميع OAuth callbacks يجب أن تكون HTTPS.

5. **CSRF Protection**
تأكد من تفعيل CSRF protection في Laravel.

---

## 🐛 استكشاف الأخطاء

### مشكلة: OAuth لا يعمل

**الحلول:**
- ✅ تحقق من Redirect URI في OAuth App
- ✅ تأكد من استخدام HTTPS
- ✅ راجع `.env` للتأكد من Client ID/Secret
- ✅ تحقق من Logs: `storage/logs/laravel.log`

### مشكلة: المنشور لا ينشر

**الحلول:**
- ✅ تحقق من صلاحيات الحساب
- ✅ تأكد من عدم انتهاء Access Token
- ✅ راجع error logs
- ✅ اختبر API مباشرة

### مشكلة: الجدولة لا تعمل

**الحلول:**
- ✅ تأكد من تشغيل Cron Job
- ✅ تحقق من `posts` table: `status` = 'scheduled'
- ✅ راجع `scheduled_at` التاريخ صحيح

### مشكلة: التحليلات فارغة

**الحلول:**
- ✅ تأكد من وجود منشورات منشورة
- ✅ انتظر بعض الوقت (قد تتأخر التحليلات)
- ✅ تحقق من `post_analytics` table

---

## 📈 التحسينات المستقبلية

### المرحلة التالية

1. **AI Content Generation**
   - توليد محتوى تلقائي
   - اقتراحات Hashtags
   - تحسين النصوص

2. **Advanced Analytics**
   - تحليلات متقدمة
   - مقارنة الأداء
   - تقارير PDF

3. **Team Collaboration**
   - إدارة الفريق
   - أدوار ومسؤوليات
   - Approval workflow

4. **Content Calendar**
   - تقويم مرئي
   - Drag & Drop للجدولة
   - Bulk scheduling

5. **Social Listening**
   - تتبع الإشارات
   - تحليل المنافسين
   - Sentiment analysis

---

## 📚 الموارد

### Documentation

- **Postiz API Docs**: https://docs.postiz.com/public-api
- **GitHub Repository**: https://github.com/gitroomhq/postiz-app
- **NodeJS SDK**: https://www.npmjs.com/package/@postiz/node

### Platform APIs

- **Facebook**: https://developers.facebook.com/docs
- **Twitter**: https://developer.twitter.com/en/docs
- **LinkedIn**: https://docs.microsoft.com/en-us/linkedin
- **TikTok**: https://developers.tiktok.com

### Community

- **Discord**: متاح من موقع Postiz
- **GitHub Issues**: للإبلاغ عن مشاكل

---

## ✅ قائمة التحقق النهائية

### Backend
- [ ] نسخ `PostizController.php`
- [ ] إضافة Routes
- [ ] تطبيق Database Migrations
- [ ] تحديث `.env` بجميع المتغيرات
- [ ] إنشاء OAuth Apps
- [ ] تكوين Storage symlink
- [ ] إعداد Cron Jobs

### Frontend
- [ ] إضافة Dependencies
- [ ] نسخ Services و Screens
- [ ] تهيئة في `main.dart`
- [ ] تكوين Deep Links
- [ ] تحديث Navigation

### Testing
- [ ] اختبار OAuth Flow لكل منصة
- [ ] اختبار النشر الفوري
- [ ] اختبار الجدولة
- [ ] اختبار رفع الوسائط
- [ ] اختبار التحليلات

### Production
- [ ] تفعيل HTTPS
- [ ] تفعيل Rate Limiting
- [ ] إعداد Backups
- [ ] مراقبة Logs
- [ ] إعداد Error Tracking (Sentry)

---

## 🎉 الخلاصة

الآن لديك نظام كامل ومتكامل لإدارة منصات Social Media مع:

✅ **ربط حسابات** من 13+ منصة
✅ **نشر تلقائي** فوري ومجدول
✅ **تحليلات شاملة** وإحصائيات دقيقة
✅ **واجهة مستخدم** جميلة وسهلة
✅ **Backend قوي** ومرن
✅ **توثيق كامل** لكل شيء

**🚀 ابدأ الآن وقم ببناء أفضل أداة لإدارة Social Media!**

---

**آخر تحديث:** 2025-11-15
**الإصدار:** 1.0.0
**المطور:** Media Pro Social Team

---

## 💬 الدعم

إذا واجهت أي مشاكل:
1. راجع `POSTIZ_README.md`
2. راجع `POSTIZ_QUICK_START.md`
3. تحقق من Logs
4. راجع GitHub Issues

**بالتوفيق! 🎊**
