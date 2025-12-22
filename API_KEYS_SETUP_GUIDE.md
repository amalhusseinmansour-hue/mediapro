# دليل إعداد API Keys - Social Media Manager

## 📋 المحتويات

1. [OpenAI API](#1-openai-api)
2. [Google Gemini API](#2-google-gemini-api)
3. [Facebook Graph API](#3-facebook-graph-api)
4. [Instagram API](#4-instagram-api)
5. [Twitter API](#5-twitter-api)
6. [TikTok API](#6-tiktok-api)
7. [Paymob Payment Gateway](#7-paymob-payment-gateway)
8. [Firebase Setup](#8-firebase-setup)

---

## 1. OpenAI API

### 🎯 الاستخدام:
- مولد المحتوى الذكي
- مولد الصور (DALL-E)
- تحليل النصوص
- اقتراحات الهاشتاجات

### 📝 خطوات الحصول على API Key:

1. **إنشاء حساب:**
   - اذهب إلى: https://platform.openai.com
   - قم بالتسجيل/تسجيل الدخول

2. **الحصول على API Key:**
   - اذهب إلى: https://platform.openai.com/api-keys
   - اضغط "Create new secret key"
   - احفظ الـ Key (لن تظهر مرة أخرى)

3. **إضافة الـ Key للتطبيق:**
   ```dart
   // في lib/core/config/api_config.dart
   class APIConfig {
     static const String openAIKey = 'sk-proj-XXXXXXXXXXXXXXXX';
   }
   ```

### 💰 التسعير:
- **GPT-3.5 Turbo:** $0.0015 / 1K tokens (~750 كلمة)
- **GPT-4:** $0.03 / 1K tokens
- **DALL-E 3:** $0.04 / صورة (1024x1024)
- **رصيد مجاني:** $5 للمستخدمين الجدد

### 📊 الاستهلاك المتوقع:
- باقة الأفراد (100 طلب/شهر): ~$5-10/شهر
- باقة الشركات (غير محدود): ~$50-100/شهر

---

## 2. Google Gemini API

### 🎯 الاستخدام:
- بديل لـ OpenAI
- مولد محتوى
- تحليل ذكي

### 📝 خطوات الحصول على API Key:

1. **إنشاء مشروع:**
   - اذهب إلى: https://makersuite.google.com/app/apikey
   - أو: https://aistudio.google.com/app/apikey

2. **الحصول على API Key:**
   - اضغط "Get API Key"
   - اختر مشروع موجود أو أنشئ جديد
   - احفظ الـ Key

3. **إضافة الـ Key للتطبيق:**
   ```dart
   // في lib/core/config/api_config.dart
   class APIConfig {
     static const String geminiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXX';
   }
   ```

### 💰 التسعير:
- **Gemini Pro:** مجاني حتى 60 طلب/دقيقة
- **Gemini Pro Vision:** مجاني حتى 60 طلب/دقيقة

### ⭐ الميزة:
- **أرخص من OpenAI**
- **رصيد مجاني كبير**

---

## 3. Facebook Graph API

### 🎯 الاستخدام:
- جلب منشورات Facebook
- نشر على Facebook
- الحصول على الإحصائيات

### 📝 خطوات الحصول على Access Token:

1. **إنشاء تطبيق Facebook:**
   - اذهب إلى: https://developers.facebook.com/apps
   - اضغط "Create App"
   - اختر نوع: "Business"
   - املأ البيانات المطلوبة

2. **إضافة منتج Facebook Login:**
   - في لوحة التطبيق → Products
   - اضف "Facebook Login"

3. **الحصول على Access Token:**
   - اذهب إلى: Tools → Graph API Explorer
   - اختر تطبيقك
   - اختر الصلاحيات:
     - `pages_show_list`
     - `pages_read_engagement`
     - `pages_manage_posts`
     - `publish_to_groups`
   - اضغط "Generate Access Token"

4. **تحويل إلى Long-Lived Token:**
   ```bash
   https://graph.facebook.com/v18.0/oauth/access_token?
     grant_type=fb_exchange_token&
     client_id=YOUR_APP_ID&
     client_secret=YOUR_APP_SECRET&
     fb_exchange_token=SHORT_LIVED_TOKEN
   ```

5. **إضافة للتطبيق:**
   ```dart
   // في lib/core/config/api_config.dart
   class APIConfig {
     static const String facebookAccessToken = 'EAAXXXXXXXXXXX';
   }
   ```

### 💰 التسعير:
- **مجاني** للاستخدام الأساسي
- حدود: 200 calls/hour per user

---

## 4. Instagram API

### 🎯 الاستخدام:
- جلب منشورات Instagram
- نشر على Instagram
- الحصول على الإحصائيات

### 📝 خطوات الإعداد:

1. **استخدام Instagram Basic Display API:**
   - اذهب إلى: https://developers.facebook.com/apps
   - اختر تطبيقك (أو أنشئ جديد)
   - اضف "Instagram Basic Display"

2. **إعداد التطبيق:**
   - في Instagram Basic Display Settings:
   - اضف Valid OAuth Redirect URIs
   - احفظ Client ID و Client Secret

3. **الحصول على Access Token:**
   ```
   https://api.instagram.com/oauth/authorize?
     client_id=YOUR_CLIENT_ID&
     redirect_uri=YOUR_REDIRECT_URI&
     scope=user_profile,user_media&
     response_type=code
   ```

4. **تبديل Code بـ Token:**
   ```bash
   curl -X POST \
     https://api.instagram.com/oauth/access_token \
     -F client_id=YOUR_CLIENT_ID \
     -F client_secret=YOUR_CLIENT_SECRET \
     -F grant_type=authorization_code \
     -F redirect_uri=YOUR_REDIRECT_URI \
     -F code=CODE_FROM_STEP_3
   ```

5. **إضافة للتطبيق:**
   ```dart
   class APIConfig {
     static const String instagramAccessToken = 'IGQVXXXXXXXXXX';
   }
   ```

### 💰 التسعير:
- **مجاني** للاستخدام الأساسي
- حدود: 200 calls/hour

### ⚠️ ملاحظة:
لنشر المحتوى على Instagram Business/Creator accounts، استخدم Instagram Graph API

---

## 5. Twitter API

### 🎯 الاستخدام:
- جلب تغريدات
- نشر تغريدات
- الحصول على الإحصائيات

### 📝 خطوات الحصول على API Keys:

1. **التقديم لـ Developer Account:**
   - اذهب إلى: https://developer.twitter.com
   - قدم طلب Developer Access
   - املأ الاستبيان (سبب الاستخدام)
   - انتظر الموافقة (عادة فوري)

2. **إنشاء مشروع وتطبيق:**
   - بعد الموافقة → Projects & Apps
   - Create Project
   - Create App

3. **الحصول على Keys:**
   - في صفحة التطبيق → Keys and Tokens
   - احفظ:
     - API Key
     - API Key Secret
     - Bearer Token
     - Access Token & Secret

4. **إضافة للتطبيق:**
   ```dart
   class APIConfig {
     static const String twitterApiKey = 'XXXXXXXXXXXX';
     static const String twitterApiSecret = 'XXXXXXXXXXXX';
     static const String twitterBearerToken = 'AAAAAAAAAAXXXXXXXX';
     static const String twitterAccessToken = 'XXXXXXXXXXXX';
     static const String twitterAccessSecret = 'XXXXXXXXXXXX';
   }
   ```

### 💰 التسعير:
- **Free Tier:** 1,500 tweets/month (Read only)
- **Basic ($100/month):** 3,000 tweets/month + Write
- **Pro ($5,000/month):** 1M tweets/month

### ⚠️ تحديث 2024:
Twitter API أصبح مدفوع، استخدم Free tier للاختبار

---

## 6. TikTok API

### 🎯 الاستخدام:
- جلب فيديوهات TikTok
- نشر محتوى
- الحصول على الإحصائيات

### 📝 خطوات الإعداد:

1. **التقديم لـ TikTok Developers:**
   - اذهب إلى: https://developers.tiktok.com
   - قدم طلب Developer Access
   - املأ بيانات الشركة/التطبيق

2. **إنشاء تطبيق:**
   - بعد الموافقة → Manage Apps
   - Create New App
   - اختر TikTok Login/Display API

3. **الحصول على Keys:**
   - Client Key
   - Client Secret

4. **OAuth Flow:**
   ```
   https://www.tiktok.com/auth/authorize/?
     client_key=YOUR_CLIENT_KEY&
     scope=user.info.basic,video.list&
     response_type=code&
     redirect_uri=YOUR_REDIRECT_URI
   ```

5. **إضافة للتطبيق:**
   ```dart
   class APIConfig {
     static const String tiktokClientKey = 'XXXXXXXXXXXX';
     static const String tiktokClientSecret = 'XXXXXXXXXXXX';
   }
   ```

### 💰 التسعير:
- **مجاني** للاستخدام الأساسي
- حدود حسب نوع الحساب

### ⚠️ ملاحظة:
TikTok API محدود، قد تحتاج موافقة خاصة

---

## 7. Paymob Payment Gateway

### 🎯 الاستخدام:
- معالجة المدفوعات
- الاشتراكات الشهرية
- بطاقات الائتمان والمحافظ الإلكترونية

### 📝 خطوات الإعداد:

1. **إنشاء حساب Paymob:**
   - اذهب إلى: https://paymob.com
   - سجل كحساب تاجر (Merchant)
   - املأ بيانات الشركة/النشاط

2. **التحقق من الحساب:**
   - رفع المستندات المطلوبة
   - انتظر الموافقة (1-3 أيام)

3. **الحصول على API Keys:**
   - بعد الموافقة → Settings → API Keys
   - احفظ:
     - API Key
     - Integration ID (لكل طريقة دفع)
     - HMAC Secret

4. **إضافة للتطبيق:**
   ```dart
   // في lib/core/config/api_config.dart
   class APIConfig {
     static const String paymobApiKey = 'ZXlKXXXXXXXXXX';
     static const String paymobIntegrationIdCard = '12345'; // بطاقات
     static const String paymobIntegrationIdWallet = '12346'; // محافظ
     static const String paymobIframeId = '12347';
     static const String paymobHmacSecret = 'XXXXXXXXXX';
   }
   ```

5. **تفعيل Webhook:**
   - في لوحة Paymob → Settings → Webhooks
   - اضف URL الخاص بك:
   ```
   https://your-domain.com/api/paymob/webhook
   ```

### 💰 الرسوم:
- **بطاقات ائتمان:** 2.5% + 1 ج.م
- **محافظ إلكترونية:** 1.75% + 1 ج.م
- **فوري:** 7 ج.م ثابت
- **أقساط:** رسوم إضافية

### 📊 مثال التكلفة:
- اشتراك 129 ج.م:
  - الرسوم: ~4.2 ج.م
  - صافي الربح: 124.8 ج.م
- اشتراك 179 ج.م:
  - الرسوم: ~5.5 ج.م
  - صافي الربح: 173.5 ج.م

---

## 8. Firebase Setup

### 🎯 الاستخدام:
- المصادقة (Authentication)
- قاعدة البيانات (Firestore)
- التخزين (Storage)
- الإشعارات (Cloud Messaging)

### 📝 خطوات الإعداد:

#### لـ Android:

1. **إنشاء مشروع Firebase:**
   - اذهب إلى: https://console.firebase.google.com
   - اضغط "Add project"
   - املأ اسم المشروع
   - اختر خيارات Google Analytics (اختياري)

2. **إضافة تطبيق Android:**
   - في صفحة المشروع → Add app → Android
   - Package name: `com.mediaprosocial.app` (أو حسب تطبيقك)
   - Download `google-services.json`

3. **وضع الملف في المشروع:**
   ```
   android/app/google-services.json
   ```

4. **تفعيل الخدمات:**
   - في Firebase Console:
   - Authentication → Enable Email/Password & Phone
   - Firestore Database → Create Database (Start in production mode)
   - Storage → Get Started

5. **إعداد Firebase في Firestore:**
   - اذهب إلى Firestore → Rules
   - استخدم القواعد التالية:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users - يمكن للمستخدم قراءة/كتابة بياناته فقط
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }

       // Posts - يمكن للمستخدم قراءة/كتابة منشوراته فقط
       match /posts/{postId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == resource.data.userId;
       }

       // Payments - قراءة فقط للمستخدم نفسه
       match /payments/{paymentId} {
         allow read: if request.auth != null && request.auth.uid == resource.data.userId;
         allow write: if false; // الكتابة من الخادم فقط
       }
     }
   }
   ```

#### لـ iOS (اختياري):

1. **في Firebase Console:**
   - Add app → iOS
   - Bundle ID: `com.mediaprosocial.app`
   - Download `GoogleService-Info.plist`

2. **وضع الملف:**
   ```
   ios/Runner/GoogleService-Info.plist
   ```

### 💰 التسعير:
- **Spark (Free):**
  - 50K reads/day
  - 20K writes/day
  - 20K deletes/day
  - 1GB storage
  - **مناسب للبداية**

- **Blaze (Pay as you go):**
  - $0.06 / 100K reads
  - $0.18 / 100K writes
  - $0.02 / 100K deletes
  - $0.18/GB storage

### 📊 الاستهلاك المتوقع:
- **100 مستخدم نشط:**
  - ~200K operations/month
  - **يبقى مجاني**

- **1000 مستخدم نشط:**
  - ~2M operations/month
  - **التكلفة: ~$5-10/month**

---

## 🔐 أمان API Keys

### ⚠️ قواعد مهمة:

1. **لا ترفع API Keys على Git:**
   ```bash
   # اضف في .gitignore
   lib/core/config/api_config.dart
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```

2. **استخدم Environment Variables:**
   ```dart
   class APIConfig {
     static String get openAIKey =>
       const String.fromEnvironment('OPENAI_KEY', defaultValue: '');
   }
   ```

3. **استخدم Backend Proxy (موصى به للإنتاج):**
   - لا ترسل API Keys من التطبيق مباشرة
   - أنشئ Backend يحتفظ بالـ Keys
   - التطبيق يتصل بالـ Backend فقط

4. **راقب الاستخدام:**
   - تفقد Usage يومياً
   - اضبط حدود للاستخدام
   - فعّل التنبيهات

---

## 📋 ملخص التكاليف الشهرية:

### للبدء (100 مستخدم):
```
OpenAI GPT-3.5:     $10
Google Gemini:      $0 (مجاني)
Firebase:           $0 (مجاني)
Paymob:             2.5% من المبيعات
Social Media APIs:  $0 (مجاني)
-----------------------------------
الإجمالي:          ~$10-20/month
```

### عند النمو (1000 مستخدم):
```
OpenAI:             $50-100
Google Gemini:      $0-20
Firebase:           $5-10
Paymob:             2.5% من المبيعات
Twitter API:        $100 (اختياري)
-----------------------------------
الإجمالي:          ~$155-230/month
```

### 💡 نصائح لتقليل التكلفة:
1. استخدم **Google Gemini** بدلاً من OpenAI (أرخص/مجاني)
2. Cache النتائج المتكررة
3. استخدم Free Tiers في البداية
4. راقب الاستخدام وأوقف الميزات غير المستخدمة

---

## ✅ Checklist للإطلاق:

### الضروري:
- [ ] Firebase Setup (مجاني)
- [ ] Paymob API Keys (للمدفوعات)
- [ ] OpenAI أو Gemini (أحدهما على الأقل)

### موصى به:
- [ ] Facebook Graph API
- [ ] Instagram API

### اختياري (يمكن إضافته لاحقاً):
- [ ] Twitter API
- [ ] TikTok API
- [ ] خدمات إضافية

---

**آخر تحديث:** نوفمبر 2025
**الحالة:** ✅ دليل شامل جاهز
