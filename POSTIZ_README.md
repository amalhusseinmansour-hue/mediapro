# 🚀 التكامل مع Postiz - Social Media Scheduler

## ملخص سريع

تم استبدال **Ayrshare** بـ **Postiz** - حل مفتوح المصدر قوي ومرن للنشر على منصات التواصل الاجتماعي.

---

## 📋 الملفات المتوفرة

| الملف | الوصف |
|------|---------|
| **POSTIZ_QUICK_START.md** | 🚀 ابدأ بسرعة - الطريقة الأسهل للتشغيل |
| **POSTIZ_IMPLEMENTATION_GUIDE.md** | 📖 دليل التكامل الكامل والمفصل |
| **POSTIZ_SELF_HOSTING.md** | 🏠 دليل الاستضافة الذاتية على VPS |
| **MIGRATION_FROM_AYRSHARE.md** | 🔄 خطة الانتقال من Ayrshare |
| **POSTIZ_BACKEND_CONTROLLER.php** | 🔧 Laravel Controller جاهز |
| **POSTIZ_ROUTES.php** | 🛣️ API Routes جاهزة |
| **lib/services/postiz_service.dart** | 📱 Flutter Service جاهز |

---

## ⚡ البدء السريع (5 دقائق)

### 1. اختر طريقة الاستخدام

**الخيار A: استخدام النسخة المستضافة (الأسهل)**
- سجل في: https://postiz.com
- احصل على API Key من Settings
- تكلفة: $29/شهر (أو خطة مجانية محدودة)

**الخيار B: استضافة ذاتية (مجاني)**
- تحتاج VPS (4GB RAM)
- تكلفة: ~$6/شهر فقط للخادم
- راجع: `POSTIZ_SELF_HOSTING.md`

### 2. أضف API Key في `.env`

```env
POSTIZ_API_KEY=your_api_key_here
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
```

### 3. انسخ الملفات

```bash
# Backend
cp POSTIZ_BACKEND_CONTROLLER.php app/Http/Controllers/Api/PostizController.php

# Routes
cat POSTIZ_ROUTES.php >> routes/api.php
```

### 4. هيّئ في Flutter (`main.dart`)

```dart
import 'package:social_media_manager/services/postiz_service.dart';

void main() {
  PostizService().init(
    apiKey: 'YOUR_API_KEY',
    baseUrl: 'https://api.postiz.com/public/v1',
  );
  runApp(MyApp());
}
```

---

## 🎯 المزايا الرئيسية

### ✅ ما يجعل Postiz أفضل

| الميزة | Postiz | Ayrshare |
|--------|--------|----------|
| **السعر** | مجاني أو $29/شهر | $45+/شهر |
| **الاستضافة الذاتية** | ✅ متاح | ❌ غير متاح |
| **OAuth** | رسمي لكل منصة | API Keys فقط |
| **المنصات** | 13+ منصة | 8 منصات |
| **AI Video** | ✅ مدمج | ❌ غير متاح |
| **مفتوح المصدر** | ✅ نعم | ❌ لا |
| **Rate Limits** | لا حدود (self-hosted) | محدود |

### 📱 المنصات المدعومة

- ✅ Facebook
- ✅ Instagram
- ✅ Twitter/X
- ✅ LinkedIn
- ✅ TikTok
- ✅ YouTube
- ✅ Reddit
- ✅ Pinterest
- ✅ Threads
- ✅ Discord
- ✅ Slack
- ✅ Mastodon
- ✅ Bluesky

---

## 📚 الأدلة التفصيلية

### 🚀 للبدء السريع
اقرأ: **`POSTIZ_QUICK_START.md`**
- الحصول على API Key
- إعداد Backend و Frontend
- أول منشور تجريبي

### 📖 للتكامل الكامل
اقرأ: **`POSTIZ_IMPLEMENTATION_GUIDE.md`**
- شرح معماري كامل
- إعداد OAuth Apps
- جميع الوظائف والمزايا
- أمثلة كود مفصلة

### 🏠 للاستضافة الذاتية
اقرأ: **`POSTIZ_SELF_HOSTING.md`**
- خطوات التنصيب الكاملة
- إعداد Docker
- إعداد Nginx و SSL
- الصيانة والمراقبة

### 🔄 للانتقال من Ayrshare
اقرأ: **`MIGRATION_FROM_AYRSHARE.md`**
- خطة الانتقال خطوة بخطوة
- مقارنة التغييرات
- أرشفة الكود القديم
- خطة Rollback

---

## 🔧 الاستخدام الأساسي

### ربط حساب

```dart
final oauth = await PostizService().generateOAuthLink(
  platform: 'facebook',
  userId: currentUser.id,
);

await launchUrl(Uri.parse(oauth['url']));
```

### نشر منشور

```dart
final result = await PostizService().publishPost(
  integrationIds: ['integration_1', 'integration_2'],
  text: 'محتوى المنشور',
  mediaUrls: ['https://example.com/image.jpg'],
  scheduleDate: DateTime.now().add(Duration(hours: 2)),
);
```

### رفع صورة

```dart
final mediaUrl = await PostizService().uploadMedia(
  '/path/to/image.jpg',
);
```

### توليد فيديو بالذكاء الاصطناعي

```dart
final video = await PostizService().generateVideo(
  prompt: 'Create a promotional video',
  model: 'image-text-slides',
);
```

---

## 📊 مقارنة التكاليف

### الخيار 1: Postiz Hosted
- **التكلفة:** $29/شهر
- **المزايا:** لا إعداد، صيانة تلقائية
- **العيوب:** Rate limits (30 req/hour)

### الخيار 2: Postiz Self-Hosted
- **التكلفة:** ~$6/شهر (VPS فقط)
- **المزايا:** لا حدود، تحكم كامل
- **العيوب:** يتطلب إعداد وصيانة

### الخيار 3: Ayrshare (القديم)
- **التكلفة:** $45+/شهر
- **المزايا:** سهل الإعداد
- **العيوب:** مكلف، محدود، مغلق المصدر

**💰 التوفير:** استخدام Postiz Self-Hosted يوفر **87%** من تكلفة Ayrshare!

---

## 🛠️ إعداد OAuth Apps

لكي يعمل Postiz، يجب إعداد OAuth Apps للمنصات:

### Facebook
1. https://developers.facebook.com/apps
2. Create App → Business
3. Add Product: Facebook Login
4. Callback: `https://your-domain.com/api/postiz/oauth-callback`

### Twitter
1. https://developer.twitter.com/en/portal/dashboard
2. Create Project & App
3. User authentication → Web App
4. Callback: `https://your-domain.com/api/postiz/oauth-callback`

### LinkedIn
1. https://www.linkedin.com/developers/apps
2. Create App
3. Auth → Redirect URLs
4. Add: `https://your-domain.com/api/postiz/oauth-callback`

**التفاصيل الكاملة:** راجع `POSTIZ_IMPLEMENTATION_GUIDE.md`

---

## 🗂️ البنية التقنية

### Backend Stack
```
Laravel (API) ← → Postiz API ← → Social Media Platforms
     ↓
PostgreSQL
```

### Frontend Stack
```
Flutter App → PostizService → Backend API → Postiz
```

### Files Structure
```
social_media_manager/
├── lib/
│   └── services/
│       └── postiz_service.dart       # Flutter service
├── app/Http/Controllers/Api/
│   └── PostizController.php          # Laravel controller
├── routes/
│   └── api.php                        # Laravel routes
├── .env                                # Environment variables
└── [Documentation files]
```

---

## ⚙️ المتغيرات المطلوبة في `.env`

```env
# Postiz Configuration
POSTIZ_API_KEY=your_api_key
POSTIZ_BASE_URL=https://api.postiz.com/public/v1

# OAuth Apps
FACEBOOK_APP_ID=xxx
FACEBOOK_APP_SECRET=xxx

TWITTER_CLIENT_ID=xxx
TWITTER_CLIENT_SECRET=xxx

LINKEDIN_CLIENT_ID=xxx
LINKEDIN_CLIENT_SECRET=xxx

TIKTOK_CLIENT_KEY=xxx
TIKTOK_CLIENT_SECRET=xxx
```

---

## 📝 قائمة التحقق للتنفيذ

### Backend
- [ ] نسخ `PostizController.php`
- [ ] إضافة Routes من `POSTIZ_ROUTES.php`
- [ ] تحديث `.env` بـ API Keys
- [ ] إعداد OAuth Apps
- [ ] تحديث Database Schema (إضافة حقول)

### Frontend
- [ ] تهيئة `PostizService` في `main.dart`
- [ ] إنشاء شاشة OAuth
- [ ] إنشاء شاشة النشر
- [ ] تحديث UI للحسابات المربوطة

### Testing
- [ ] اختبار OAuth Flow
- [ ] اختبار النشر الفوري
- [ ] اختبار النشر المجدول
- [ ] اختبار رفع الصور
- [ ] اختبار حذف المنشورات

---

## 🆘 استكشاف الأخطاء

### مشكلة: OAuth لا يعمل
✅ تحقق من Redirect URI في OAuth App
✅ تأكد من استخدام HTTPS
✅ راجع `.env` للتأكد من Client ID/Secret

### مشكلة: API يرجع 401
✅ تحقق من صحة API Key
✅ تأكد من Header Authorization صحيح

### مشكلة: Rate Limit Error
✅ إذا كنت تستخدم Hosted: 30 req/hour
✅ الحل: استخدم Self-Hosted

---

## 📞 الدعم والموارد

### Documentation
- **Postiz API Docs:** https://docs.postiz.com/public-api
- **GitHub Repository:** https://github.com/gitroomhq/postiz-app
- **NodeJS SDK:** https://www.npmjs.com/package/@postiz/node

### Community
- **Discord:** (متاح من الموقع الرسمي)
- **GitHub Issues:** للإبلاغ عن مشاكل

---

## 🎓 الخطوات التالية

1. **اقرأ:** `POSTIZ_QUICK_START.md` للبدء الفوري
2. **قرر:** Hosted أم Self-Hosted؟
3. **نفّذ:** اتبع الدليل المناسب
4. **اختبر:** على حسابات تجريبية أولاً
5. **انشر:** للمستخدمين الحقيقيين

---

## 📄 License

- **Postiz:** Open Source (MIT License)
- **هذا التطبيق:** حسب license المشروع

---

## ✨ الخلاصة

الآن لديك كل ما تحتاجه للتكامل مع **Postiz**:

✅ **Documentations كاملة**
✅ **Code جاهز** (Backend & Frontend)
✅ **أدلة مفصلة** لكل سيناريو
✅ **أمثلة عملية** للاستخدام

**🚀 ابدأ الآن من:** `POSTIZ_QUICK_START.md`

---

**آخر تحديث:** 2025-11-15
**الإصدار:** 1.0.0

---

## 🙏 شكر خاص

- **Postiz Team** لصنع هذه الأداة المذهلة المفتوحة المصدر
- **Community** على الدعم المستمر

---

**💡 نصيحة أخيرة:**

إذا كنت مبتدئ → استخدم **Hosted version**
إذا كنت لديك خبرة → استخدم **Self-Hosted** ووفر المال!

**🎉 بالتوفيق في مشروعك!**
