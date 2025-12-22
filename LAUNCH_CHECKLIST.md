# ✅ قائمة التحقق قبل الإطلاق

## قبل أن تشغّل التطبيق، يجب عليك:

### ⬜ الخطوة 1: تنصيب Postiz (إلزامي!)
**الوقت:** 30 دقيقة
**الحالة:** ❌ **لم يتم بعد**

```bash
# على VPS أو جهازك المحلي
git clone https://github.com/gitroomhq/postiz-app.git
cd postiz-app
cp .env.example .env
# عدّل .env
docker-compose up -d
```

**التحقق:**
```bash
curl http://localhost:5000
# يجب أن يفتح Postiz Dashboard
```

---

### ⬜ الخطوة 2: إنشاء OAuth Apps (إلزامي!)
**الوقت:** 45 دقيقة
**الحالة:** ❌ **لم يتم بعد**

#### Facebook App
1. https://developers.facebook.com/apps
2. Create App → Business
3. أضف Facebook Login
4. Callback: `http://YOUR_IP:5000/integrations/social/facebook/callback`
5. احصل على **App ID** & **App Secret**

#### Twitter App
1. https://developer.twitter.com/portal
2. Create Project & App
3. User authentication → Web App
4. Callback: `http://YOUR_IP:5000/integrations/social/twitter/callback`
5. احصل على **Client ID** & **Client Secret**

#### LinkedIn App
1. https://www.linkedin.com/developers/apps
2. Create app
3. Redirect URL: `http://YOUR_IP:5000/integrations/social/linkedin/callback`
4. احصل على **Client ID** & **Client Secret**

**أضف في Postiz `.env`:**
```env
FACEBOOK_CLIENT_ID=your_facebook_app_id
FACEBOOK_CLIENT_SECRET=your_facebook_app_secret
TWITTER_CLIENT_ID=your_twitter_client_id
TWITTER_CLIENT_SECRET=your_twitter_client_secret
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
```

**ثم:**
```bash
cd postiz-app
docker-compose restart
```

---

### ⬜ الخطوة 3: احصل على Postiz API Key (إلزامي!)
**الوقت:** 2 دقيقة
**الحالة:** ❌ **لم يتم بعد**

```
1. افتح Postiz Dashboard: http://YOUR_IP:5000
2. سجل حساب جديد
3. اذهب إلى: Settings → API Keys
4. اضغط "Create API Key"
5. انسخ الـ API Key
```

---

### ⬜ الخطوة 4: تحديث Laravel Backend (إلزامي!)
**الوقت:** 20 دقيقة
**الحالة:** ❌ **لم يتم بعد**

```bash
# 1. نسخ Controller
cp COMPLETE_POSTIZ_CONTROLLER.php app/Http/Controllers/Api/PostizController.php

# 2. إضافة Routes
# افتح routes/api.php وانسخ محتوى POSTIZ_ROUTES.php

# 3. Database Migrations
mysql -u root -p your_database < DATABASE_MIGRATIONS.sql

# 4. تحديث Laravel .env
nano .env
```

**أضف في Laravel `.env`:**
```env
POSTIZ_API_KEY=YOUR_API_KEY_FROM_STEP_3
POSTIZ_BASE_URL=http://YOUR_POSTIZ_IP:5000/api/v1

FACEBOOK_APP_ID=same_as_postiz
FACEBOOK_APP_SECRET=same_as_postiz
TWITTER_CLIENT_ID=same_as_postiz
TWITTER_CLIENT_SECRET=same_as_postiz
```

**ثم:**
```bash
php artisan config:clear
php artisan route:clear
php artisan cache:clear
```

**التحقق:**
```bash
curl http://your-laravel-domain.com/api/postiz/status
# يجب أن يرجع: {"success":true}
```

---

### ⬜ الخطوة 5: تحديث Flutter .env (إلزامي!)
**الوقت:** 2 دقيقة
**الحالة:** ❌ **لم يتم بعد**

**افتح:** `C:\Users\HP\social_media_manager\.env`

**عدّل:**
```env
# غيّر من:
POSTIZ_API_KEY=your_api_key_here_from_postiz_dashboard
POSTIZ_BASE_URL=http://localhost:5000/api/v1
BACKEND_SERVER_URL=http://192.168.1.100:8000

# إلى (القيم الحقيقية):
POSTIZ_API_KEY=pk_live_abc123xyz...  ← من الخطوة 3
POSTIZ_BASE_URL=http://82.25.83.217:5000/api/v1  ← IP خادمك
BACKEND_SERVER_URL=https://mediaprosocial.io  ← Laravel الخاص بك
```

---

### ⬜ الخطوة 6: تحديث backend_config.dart (إلزامي!)
**الوقت:** 1 دقيقة
**الحالة:** ❌ **لم يتم بعد**

**افتح:** `lib/core/config/backend_config.dart`

**عدّل السطر 10:**
```dart
// من:
static const String productionBaseUrl = 'https://mediaprosocial.io/api';

// إلى (تأكد أنه صحيح):
static const String productionBaseUrl = 'https://mediaprosocial.io/api';
```

**عدّل السطر 68:**
```dart
// من:
static const String postizBaseUrl = 'http://localhost:5000/api/v1';

// إلى:
static const String postizBaseUrl = 'http://82.25.83.217:5000/api/v1';
// ↑ استبدل بـ IP خادم Postiz الخاص بك
```

---

### ⬜ الخطوة 7: إضافة Navigation للـ Dashboard (إلزامي!)
**الوقت:** 5 دقائق
**الحالة:** ❌ **لم يتم بعد**

**ابحث عن ملف الـ Home Screen أو Main Menu**

**أضف:**
```dart
import 'package:social_media_manager/screens/social_media/social_media_dashboard.dart';

// في القائمة:
ListTile(
  leading: Icon(Icons.share, color: Colors.blue),
  title: Text('إدارة Social Media'),
  onTap: () {
    Get.to(() => SocialMediaDashboard());
  },
),
```

---

### ⬜ الخطوة 8: Build التطبيق
**الوقت:** 5 دقيقة

```bash
cd C:\Users\HP\social_media_manager
flutter pub get
flutter run
```

---

## 🧪 الاختبار

### بعد الانتهاء من كل الخطوات:

**اختبار 1: Postiz Dashboard**
```
افتح: http://YOUR_IP:5000
✅ يجب أن يفتح Dashboard
```

**اختبار 2: Laravel API**
```bash
curl https://mediaprosocial.io/api/postiz/status
✅ يجب أن يرجع: {"success":true}
```

**اختبار 3: من Postiz - ربط حساب**
```
1. في Postiz Dashboard
2. Integrations → Facebook
3. اضغط Connect
✅ يجب أن يفتح OAuth ويربط بنجاح
```

**اختبار 4: من Flutter App - ربط حساب**
```
1. افتح التطبيق
2. اذهب "إدارة Social Media"
3. اضغط "ربط حساب"
4. اختر Facebook
✅ يجب أن يفتح OAuth في المتصفح
✅ بعد الموافقة، يعود للتطبيق مع رسالة نجاح
```

**اختبار 5: نشر منشور**
```
1. في التطبيق
2. "إنشاء منشور"
3. اكتب نص
4. اختر الحساب المربوط
5. اضغط "نشر"
✅ يجب أن ينشر على Facebook مباشرة
```

---

## 📊 التقدم الحالي

```
الكود (Flutter + Laravel):  ████████████████████ 100% ✅
الإعدادات:                  ░░░░░░░░░░░░░░░░░░░░   0% ❌
تنصيب Postiz:               ░░░░░░░░░░░░░░░░░░░░   0% ❌
OAuth Apps:                  ░░░░░░░░░░░░░░░░░░░░   0% ❌
```

**الحالة الحالية:** 🔴 **غير جاهز للعمل** - يحتاج إعدادات

**بعد الخطوات أعلاه:** 🟢 **جاهز للعمل 100%**

---

## ⏱️ الوقت المطلوب

| الخطوة | الوقت |
|--------|-------|
| 1. تنصيب Postiz | 30 دقيقة |
| 2. OAuth Apps | 45 دقيقة |
| 3. Postiz API Key | 2 دقيقة |
| 4. Laravel Backend | 20 دقيقة |
| 5. Flutter .env | 2 دقيقة |
| 6. backend_config | 1 دقيقة |
| 7. Navigation | 5 دقيقة |
| 8. Build | 5 دقيقة |
| **المجموع** | **~2 ساعة** ⏱️ |

---

## 🎯 الخلاصة

### ❌ لو شغّلت التطبيق الآن:
```
❌ خطأ اتصال بـ Postiz
❌ OAuth Apps غير موجودة
❌ Laravel Routes مفقودة
❌ API Keys غير صحيحة
```

### ✅ بعد الخطوات أعلاه:
```
✅ Postiz يعمل
✅ OAuth يربط بنجاح
✅ المنشورات تُنشر
✅ التحليلات تظهر
✅ الجدولة تعمل
```

---

## 🚀 ابدأ الآن!

**الخطوة التالية:** افتح `START_HERE_SELF_HOSTED.md` واتبع التعليمات خطوة بخطوة.

**بعد ساعتين، كل شيء سيعمل! 🎉**
