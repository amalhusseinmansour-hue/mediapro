# دليل التكامل مع Postiz

## نظرة عامة

تم استبدال **Ayrshare** بـ **Postiz**، وهو حل مفتوح المصدر للنشر على منصات التواصل الاجتماعي.

### لماذا Postiz؟

✅ **مفتوح المصدر** - يمكن استضافته ذاتياً
✅ **OAuth رسمي** - يستخدم OAuth الرسمي لكل منصة
✅ **تكلفة أقل** - مجاني للاستضافة الذاتية
✅ **مزايا متقدمة** - توليد فيديو بالذكاء الاصطناعي
✅ **منصات أكثر** - يدعم 13+ منصة

### المنصات المدعومة

- Facebook
- Instagram
- Twitter/X
- LinkedIn
- TikTok
- YouTube
- Reddit
- Pinterest
- Threads
- Discord
- Slack
- Mastodon
- Bluesky

---

## خيارات التنصيب

### الخيار 1: استخدام النسخة المستضافة (Hosted)

**الأسهل والأسرع** - لا يتطلب إعداد خادم

1. قم بالتسجيل في: https://postiz.com
2. انتقل إلى الإعدادات واحصل على API Key
3. أضف API Key في ملف `.env`:
```env
POSTIZ_API_KEY=your_api_key_here
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
```

**التكلفة:**
- الخطة المجانية: محدودة
- الخطة المدفوعة: تبدأ من $29/شهر

---

### الخيار 2: الاستضافة الذاتية (Self-Hosted)

**مجاني تماماً** - يتطلب خادم VPS

#### المتطلبات:
- خادم VPS (4GB RAM على الأقل)
- Docker و Docker Compose
- PostgreSQL
- Redis

#### خطوات التنصيب:

**1. استنساخ المشروع:**
```bash
git clone https://github.com/gitroomhq/postiz-app.git
cd postiz-app
```

**2. إعداد متغيرات البيئة:**
```bash
cp .env.example .env
```

**3. تحديث ملف `.env`:**
```env
DATABASE_URL=postgresql://user:password@localhost:5432/postiz
REDIS_URL=redis://localhost:6379
NEXT_PUBLIC_BACKEND_URL=https://your-domain.com
NEXTAUTH_SECRET=your_random_secret_here

# OAuth Apps (سنشرح كيفية إعدادها لاحقاً)
FACEBOOK_CLIENT_ID=your_facebook_app_id
FACEBOOK_CLIENT_SECRET=your_facebook_app_secret

TWITTER_CLIENT_ID=your_twitter_client_id
TWITTER_CLIENT_SECRET=your_twitter_client_secret

LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
```

**4. تشغيل المشروع باستخدام Docker:**
```bash
docker-compose -f docker-compose.dev.yaml up -d
```

**5. تطبيق Migration:**
```bash
docker exec -it postiz_backend npx prisma migrate deploy
```

**6. إنشاء حساب إداري:**
```bash
docker exec -it postiz_backend npm run seed
```

الآن يجب أن يكون Postiz متاحاً على: http://localhost:5000

**7. تحديث `.env` في تطبيقك:**
```env
POSTIZ_API_KEY=your_generated_api_key
POSTIZ_BASE_URL=http://your-server-ip:5000/public/v1
```

---

## إعداد OAuth Apps

لكي يعمل Postiz بشكل صحيح، يجب إنشاء OAuth Apps لكل منصة:

### 1. Facebook OAuth App

1. انتقل إلى: https://developers.facebook.com/apps
2. انقر "Create App" → "Business"
3. املأ التفاصيل الأساسية
4. أضف منتج "Facebook Login"
5. في إعدادات Facebook Login:
   - أضف Redirect URI: `https://your-domain.com/api/postiz/oauth-callback`
6. في إعدادات App:
   - احصل على `App ID` و `App Secret`
7. أضفهما في `.env`:
```env
FACEBOOK_APP_ID=your_app_id
FACEBOOK_APP_SECRET=your_app_secret
```

### 2. Twitter OAuth 2.0

1. انتقل إلى: https://developer.twitter.com/en/portal/dashboard
2. انشئ مشروع جديد وأضف App
3. في إعدادات App → User authentication settings:
   - Type: Web App, Automated App or Bot
   - Callback URI: `https://your-domain.com/api/postiz/oauth-callback`
   - Website URL: `https://your-domain.com`
4. احصل على `Client ID` و `Client Secret`
5. أضفهما في `.env`:
```env
TWITTER_CLIENT_ID=your_client_id
TWITTER_CLIENT_SECRET=your_client_secret
```

### 3. LinkedIn OAuth App

1. انتقل إلى: https://www.linkedin.com/developers/apps
2. انقر "Create app"
3. املأ التفاصيل المطلوبة
4. في قسم "Auth":
   - أضف Redirect URL: `https://your-domain.com/api/postiz/oauth-callback`
5. في قسم "Products":
   - أضف "Share on LinkedIn" و "Sign In with LinkedIn"
6. احصل على `Client ID` و `Client Secret`
7. أضفهما في `.env`:
```env
LINKEDIN_CLIENT_ID=your_client_id
LINKEDIN_CLIENT_SECRET=your_client_secret
```

### 4. TikTok OAuth App

1. انتقل إلى: https://developers.tiktok.com
2. سجل كمطور
3. انشئ تطبيق جديد
4. أضف Redirect URI: `https://your-domain.com/api/postiz/oauth-callback`
5. احصل على `Client Key` و `Client Secret`
6. أضفهما في `.env`:
```env
TIKTOK_CLIENT_KEY=your_client_key
TIKTOK_CLIENT_SECRET=your_client_secret
```

---

## التكامل مع التطبيق

### 1. إضافة Controller في Laravel

انسخ ملف `POSTIZ_BACKEND_CONTROLLER.php` إلى:
```
app/Http/Controllers/Api/PostizController.php
```

### 2. إضافة Routes

أضف محتوى `POSTIZ_ROUTES.php` إلى `routes/api.php`:
```php
require __DIR__ . '/../POSTIZ_ROUTES.php';
```

أو انسخ المحتوى مباشرة.

### 3. تحديث Database Schema

أضف الحقول التالية إلى جدول `social_accounts`:
```sql
ALTER TABLE social_accounts ADD COLUMN IF NOT EXISTS integration_id VARCHAR(255);
ALTER TABLE social_accounts ADD COLUMN IF NOT EXISTS provider_type VARCHAR(50);
ALTER TABLE social_accounts ADD COLUMN IF NOT EXISTS access_token TEXT;
```

### 4. إضافة Postiz Service في Flutter

الملف موجود في: `lib/services/postiz_service.dart`

### 5. تهيئة الخدمة في `main.dart`

```dart
import 'package:social_media_manager/services/postiz_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Postiz Service
  PostizService().init(
    apiKey: 'YOUR_API_KEY',
    baseUrl: 'https://api.postiz.com/public/v1',
  );

  runApp(MyApp());
}
```

---

## الاستخدام في التطبيق

### 1. ربط حساب جديد

```dart
final postizService = PostizService();

// توليد رابط OAuth
final result = await postizService.generateOAuthLink(
  platform: 'facebook',
  userId: currentUser.id,
);

// فتح الرابط في متصفح
await launchUrl(Uri.parse(result['url']));
```

### 2. نشر منشور

```dart
final postizService = PostizService();

final result = await postizService.publishPost(
  integrationIds: ['integration_id_1', 'integration_id_2'],
  text: 'محتوى المنشور هنا',
  mediaUrls: ['https://example.com/image.jpg'],
  scheduleDate: DateTime.now().add(Duration(hours: 2)),
);

print('Post ID: ${result['post_id']}');
```

### 3. الحصول على القنوات المربوطة

```dart
final integrations = await PostizService().getConnectedIntegrations();

for (var integration in integrations) {
  print('Platform: ${integration['provider']}');
  print('Name: ${integration['name']}');
}
```

### 4. رفع صورة

```dart
final mediaUrl = await PostizService().uploadMedia('/path/to/image.jpg');
print('Media URL: $mediaUrl');
```

### 5. توليد فيديو بالذكاء الاصطناعي

```dart
final result = await PostizService().generateVideo(
  prompt: 'Create a promotional video about our new product',
  model: 'image-text-slides',
);

print('Video URL: ${result['video_url']}');
```

---

## المقارنة: Ayrshare vs Postiz

| الميزة | Ayrshare | Postiz |
|--------|----------|--------|
| **السعر** | $45+/شهر | مجاني (استضافة ذاتية) أو $29/شهر |
| **OAuth** | يستخدم API Keys | OAuth رسمي لكل منصة ✅ |
| **الاستضافة الذاتية** | ❌ غير متاح | ✅ متاح |
| **المنصات المدعومة** | 8 منصات | 13+ منصة |
| **توليد الفيديو بالـ AI** | ❌ | ✅ |
| **المصدر** | مغلق | مفتوح المصدر ✅ |
| **التحكم الكامل** | ❌ | ✅ |

---

## API Rate Limits

### النسخة المستضافة:
- **30 طلب/ساعة** للـ API Key الواحد

### الاستضافة الذاتية:
- **لا حدود** - يمكنك التحكم الكامل

---

## دعم إضافي

- **توثيق API الرسمي:** https://docs.postiz.com/public-api
- **GitHub Repository:** https://github.com/gitroomhq/postiz-app
- **NodeJS SDK:** https://www.npmjs.com/package/@postiz/node
- **Discord Community:** يمكن الحصول على الرابط من الموقع الرسمي

---

## خطوات الانتقال من Ayrshare إلى Postiz

### ✅ تم إكمال:
1. إنشاء `PostizService` في Flutter
2. إنشاء `PostizController` في Laravel
3. إنشاء Routes للـ API
4. تحديث `.env` بمتغيرات Postiz

### 🔄 الخطوات المتبقية:
1. حذف أو تعطيل كود Ayrshare القديم
2. تحديث Database Schema
3. تحديث UI للتطبيق لاستخدام Postiz
4. اختبار التكامل الكامل

---

## ملاحظات مهمة

⚠️ **الأمان:**
- لا ترفع ملف `.env` إلى Git
- استخدم HTTPS للـ OAuth Callbacks
- قم بتشفير Access Tokens في قاعدة البيانات

⚠️ **الأداء:**
- استخدم Queue للمنشورات المجدولة
- قم بتخزين Tokens في Cache (Redis)
- راقب معدل الطلبات (Rate Limiting)

⚠️ **الاختبار:**
- اختبر OAuth Flow لكل منصة قبل الإنتاج
- اختبر النشر على حسابات تجريبية أولاً
- راقب الأخطاء والسجلات (Logs)

---

## الخلاصة

الآن لديك نظام متكامل للنشر على منصات التواصل الاجتماعي باستخدام **Postiz** بدلاً من **Ayrshare**.

**المزايا الرئيسية:**
- ✅ تكلفة أقل (أو مجاني)
- ✅ تحكم كامل (استضافة ذاتية)
- ✅ OAuth رسمي
- ✅ مفتوح المصدر
- ✅ مزايا متقدمة (AI Video Generation)

**للبدء فوراً:**
اختر أحد الخيارين:
1. **سريع:** استخدم النسخة المستضافة من postiz.com
2. **كامل التحكم:** نصب Postiz على خادمك الخاص

تمت كتابة هذا الدليل بتاريخ: 2025-11-15
