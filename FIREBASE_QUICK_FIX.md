# 🔥 حل سريع - تحميل ملفات Firebase

## ✅ Firebase مُعد بالفعل!

المشروع: **mediapro-77297**

---

## 📥 الخطوة الوحيدة: تحميل الملفات المفقودة

### 1️⃣ افتح Firebase Console

اذهب إلى: https://console.firebase.google.com/

### 2️⃣ افتح المشروع

ابحث عن المشروع: **mediapro** أو **mediapro-77297**

اضغط عليه لفتحه

### 3️⃣ اذهب لإعدادات المشروع

اضغط على أيقونة ⚙️ في الأعلى → **Project settings**

### 4️⃣ تحميل ملف Android

1. انتقل إلى **Your apps** في الأسفل

2. ابحث عن **Android app** (🤖)

3. إذا لم تجد Android App، اضغط **Add app** → اختر Android:
   - **Package name:** `com.socialmedia.social_media_manager`
   - اضغط **Register app**

4. في صفحة Android App، اضغط **google-services.json** لتحميله

5. ضع الملف في:
   ```
   C:\Users\HP\social_media_manager\android\app\google-services.json
   ```

### 5️⃣ تحميل ملف iOS

1. ابحث عن **iOS app** (🍎)

2. إذا لم تجد iOS App، اضغط **Add app** → اختر iOS:
   - **Bundle ID:** `com.mediapro.socialMediaManager`
   - اضغط **Register app**

3. في صفحة iOS App، اضغط **GoogleService-Info.plist** لتحميله

4. ضع الملف في:
   ```
   C:\Users\HP\social_media_manager\ios\Runner\GoogleService-Info.plist
   ```

---

## 🔑 الخطوة الإضافية: SHA-1 (لـ Google Sign-in)

### 1. احصل على SHA-1

في Terminal/Command Prompt:

```bash
cd C:\Users\HP\social_media_manager\android
gradlew signingReport
```

انسخ SHA-1 الذي يظهر (سطر يبدأ بـ SHA1:)

### 2. أضف SHA-1 إلى Firebase

1. في Firebase Console → Project Settings
2. في **Your apps** → Android App
3. اضغط **Add fingerprint**
4. الصق SHA-1
5. اضغط **Save**
6. **حمّل google-services.json مرة أخرى** (مهم!)
7. استبدل الملف القديم

---

## 🧪 اختبار

بعد وضع الملفات:

```bash
cd C:\Users\HP\social_media_manager

flutter clean
flutter pub get
flutter run
```

### تحقق من Logs:

يجب أن تشاهد:
```
✅ [firebase_core] Successfully initialized Firebase!
```

---

## ✅ تأكيد

بعد الانتهاء، يجب أن يكون لديك:

```
social_media_manager/
├── android/
│   └── app/
│       └── google-services.json     ← ✅ موجود الآن
│
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist ← ✅ موجود الآن
│
└── lib/
    └── firebase_options.dart        ← ✅ موجود مسبقاً
```

---

## 🎯 الخدمات الجاهزة

بعد هذا الإعداد:

- ✅ **Firebase Core** - جاهز
- ✅ **Firebase Auth** - جاهز
- ✅ **Cloud Firestore** - جاهز
- ✅ **Cloud Messaging** - جاهز
- ✅ **Analytics** - جاهز

### تحتاج فقط تفعيل:

في Firebase Console:

#### 1. Authentication

Build → Authentication → Get Started

فعّل:
- ✅ Google
- ✅ Phone

#### 2. Firestore

Build → Firestore Database → Create Database

اختر:
- Location: **eur3 (europe-west)**
- Security: **Test mode**

---

**الوقت المتوقع:** 10 دقائق فقط! ⏱️

**بعدها Firebase جاهز 100%!** 🎉
