# 🔥 دليل إعداد Firebase - خطوة بخطوة

**الوقت المتوقع:** 30 دقيقة
**المتطلبات:** حساب Google

---

## 📋 الخدمات التي سنفعلها:

- ✅ Firebase Authentication (Google Sign-in, Phone Auth)
- ✅ Cloud Firestore (قاعدة بيانات)
- ✅ Cloud Messaging (الإشعارات Push)
- ✅ Firebase Analytics (التحليلات)

---

## 🚀 الخطوة 1: إنشاء مشروع Firebase

### 1. افتح Firebase Console

اذهب إلى: **https://console.firebase.google.com/**

### 2. أنشئ مشروع جديد

1. اضغط على **"Add project"** (إضافة مشروع)

2. **اسم المشروع:**
   ```
   Social Media Manager
   ```
   أو
   ```
   ميديا برو
   ```

3. اضغط **Continue**

4. **Google Analytics:**
   - فعّل Google Analytics ✅
   - اضغط **Continue**

5. **حساب Analytics:**
   - اختر **Default Account for Firebase**
   - اضغط **Create project**

6. انتظر حتى يكتمل الإنشاء (30 ثانية)

7. اضغط **Continue**

---

## 📱 الخطوة 2: إضافة Android App

### 1. في صفحة المشروع

اضغط على أيقونة **Android** (🤖)

### 2. تسجيل التطبيق

**Android package name:**
```
com.socialmedia.social_media_manager
```

**App nickname (اختياري):**
```
Media Pro Android
```

**Debug signing certificate SHA-1 (اختياري - سنحتاجه لاحقاً):**

اتركه فارغاً الآن، سنضيفه لاحقاً لـ Google Sign-in

اضغط **Register app**

### 3. تحميل google-services.json

1. اضغط **Download google-services.json**

2. **مهم جداً:** ضع الملف في المكان الصحيح:
   ```
   C:\Users\HP\social_media_manager\android\app\google-services.json
   ```

   **المسار يجب أن يكون:**
   ```
   social_media_manager/
   └── android/
       └── app/
           └── google-services.json  ← هنا بالضبط!
   ```

3. اضغط **Next**

### 4. إضافة Firebase SDK

**لا تقلق!** الإعدادات موجودة بالفعل في المشروع.

فقط **تحقق** من وجودها:

#### في `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // ✅ موجود
    }
}
```

#### في `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'  // ✅ موجود

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

اضغط **Next**

### 5. اختبار التطبيق

اضغط **Continue to console**

---

## 🍎 الخطوة 3: إضافة iOS App

### 1. في صفحة المشروع

اضغط على أيقونة **iOS** (🍎)

### 2. تسجيل التطبيق

**iOS bundle ID:**
```
com.socialmedia.socialMediaManager
```

**App nickname (اختياري):**
```
Media Pro iOS
```

**App Store ID (اختياري):**

اتركه فارغاً الآن

اضغط **Register app**

### 3. تحميل GoogleService-Info.plist

1. اضغط **Download GoogleService-Info.plist**

2. **مهم جداً:** ضع الملف في المكان الصحيح:
   ```
   C:\Users\HP\social_media_manager\ios\Runner\GoogleService-Info.plist
   ```

   **المسار يجب أن يكون:**
   ```
   social_media_manager/
   └── ios/
       └── Runner/
           └── GoogleService-Info.plist  ← هنا بالضبط!
   ```

3. اضغط **Next**

### 4. إضافة Firebase SDK

**لا تقلق!** الإعدادات موجودة بالفعل في `pubspec.yaml`

فقط تأكد من وجود:
```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  firebase_messaging: ^15.1.5
  firebase_analytics: ^11.3.5
```

اضغط **Next**

### 5. تهيئة Firebase

اضغط **Continue to console**

---

## 🔧 الخطوة 4: تفعيل Firebase Services

### 1. تفعيل Authentication

1. في القائمة الجانبية، اضغط **Build** → **Authentication**

2. اضغط **Get Started**

3. **تفعيل Google Sign-in:**
   - اضغط على **Google**
   - فعّل الزر (Enable)
   - **Project support email:** اختر بريدك الإلكتروني
   - اضغط **Save**

4. **تفعيل Phone Authentication:**
   - اضغط على **Phone**
   - فعّل الزر (Enable)
   - اضغط **Save**

5. **تفعيل Email/Password (اختياري):**
   - اضغط على **Email/Password**
   - فعّل الزر (Enable)
   - اضغط **Save**

### 2. تفعيل Cloud Firestore

1. في القائمة الجانبية، اضغط **Build** → **Firestore Database**

2. اضغط **Create database**

3. **الموقع:**
   - اختر **eur3 (europe-west)** أو الأقرب لك
   - اضغط **Next**

4. **Security rules:**
   - اختر **Start in test mode** (للتطوير)
   - اضغط **Create**

5. ستبدأ قاعدة البيانات في الإنشاء (دقيقة واحدة)

### 3. تفعيل Cloud Messaging

1. في القائمة الجانبية، اضغط **Build** → **Cloud Messaging**

2. اضغط **Get Started** (إذا ظهر)

3. **لا يوجد إعدادات إضافية الآن**

### 4. تفعيل Analytics

**Analytics مفعل تلقائياً!** ✅

---

## 🔑 الخطوة 5: الحصول على SHA-1 (لـ Google Sign-in)

### لماذا نحتاج SHA-1؟

Google Sign-in يتطلب SHA-1 للتحقق من هوية التطبيق.

### كيفية الحصول عليه:

#### الطريقة 1: من Android Studio

```bash
# في Terminal:
cd C:\Users\HP\social_media_manager\android

# شغل الأمر:
gradlew signingReport
```

ابحث عن:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

#### الطريقة 2: من Java Keytool

```bash
keytool -list -v -keystore "C:\Users\HP\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### إضافة SHA-1 إلى Firebase:

1. في Firebase Console، اذهب إلى **Project Settings** (⚙️)

2. في قسم **Your apps**، اختر Android App

3. في **SHA certificate fingerprints**، اضغط **Add fingerprint**

4. الصق SHA-1 الذي حصلت عليه

5. اضغط **Save**

6. **حمّل google-services.json الجديد** واستبدل القديم

---

## 📂 الخطوة 6: التحقق من الملفات

### تأكد من وجود الملفات في المكان الصحيح:

```
social_media_manager/
├── android/
│   └── app/
│       └── google-services.json     ← ✅ يجب أن يكون هنا
│
└── ios/
    └── Runner/
        └── GoogleService-Info.plist  ← ✅ يجب أن يكون هنا
```

### حجم الملفات المتوقع:

- **google-services.json:** ~1-2 KB
- **GoogleService-Info.plist:** ~1-2 KB

---

## 🧪 الخطوة 7: اختبار Firebase

### 1. نظف المشروع

```bash
cd C:\Users\HP\social_media_manager

flutter clean
flutter pub get
```

### 2. شغّل التطبيق

```bash
# Android
flutter run

# iOS (على Mac فقط)
flutter run -d ios
```

### 3. تحقق من الاتصال

عند تشغيل التطبيق، تحقق من Logs:

```
✅ [firebase_core] Successfully initialized Firebase!
✅ [firebase_auth] Firebase Auth initialized
```

### 4. اختبر Google Sign-in

1. افتح التطبيق
2. اذهب لشاشة تسجيل الدخول
3. اضغط "تسجيل الدخول بـ Google"
4. اختر حساب Google
5. يجب أن يعمل! ✅

---

## 🛡️ الخطوة 8: إعداد Security Rules (مهم!)

### Firestore Security Rules

في Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Other collections (customize as needed)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

اضغط **Publish**

### Storage Security Rules (إذا استخدمت Storage)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 📊 الخطوة 9: مراقبة Firebase

### في Firebase Console:

1. **Authentication:**
   - شاهد المستخدمين المسجلين
   - تتبع طرق التسجيل

2. **Firestore:**
   - شاهد البيانات المحفوظة
   - راقب عدد القراءات/الكتابات

3. **Cloud Messaging:**
   - أرسل إشعارات تجريبية
   - شاهد الإحصائيات

4. **Analytics:**
   - تتبع المستخدمين النشطين
   - شاهد الأحداث والتحويلات

---

## 🔧 استكشاف الأخطاء الشائعة

### مشكلة 1: Google Sign-in لا يعمل

**الحل:**
1. تأكد من إضافة SHA-1
2. حمّل google-services.json الجديد
3. نفذ `flutter clean && flutter pub get`
4. أعد تشغيل التطبيق

### مشكلة 2: الإشعارات لا تعمل

**الحل:**
1. تأكد من تفعيل Cloud Messaging
2. تأكد من طلب Permissions في الكود
3. اختبر على جهاز حقيقي (ليس Emulator)

### مشكلة 3: Firestore لا يحفظ البيانات

**الحل:**
1. تحقق من Security Rules
2. تأكد من المصادقة (Authentication)
3. تحقق من الـ Logs

### مشكلة 4: "No Firebase App"

**الحل:**
1. تأكد من استدعاء `Firebase.initializeApp()`
2. تحقق من وجود الملفات في المكان الصحيح
3. نفذ `flutter clean`

---

## ✅ Checklist النهائي

قبل الانتقال للخطوة التالية، تأكد من:

- [ ] أنشأت مشروع Firebase
- [ ] أضفت Android App
- [ ] حملت google-services.json ووضعته في المكان الصحيح
- [ ] أضفت iOS App
- [ ] حملت GoogleService-Info.plist ووضعته في المكان الصحيح
- [ ] فعّلت Authentication (Google, Phone)
- [ ] فعّلت Cloud Firestore
- [ ] أضفت SHA-1 Fingerprint
- [ ] حملت google-services.json الجديد
- [ ] نفذت flutter clean && flutter pub get
- [ ] اختبرت Google Sign-in
- [ ] أعددت Security Rules
- [ ] راجعت Analytics Dashboard

---

## 📚 روابط مفيدة

- **Firebase Console:** https://console.firebase.google.com/
- **Firebase Docs:** https://firebase.google.com/docs
- **Flutter Fire:** https://firebase.flutter.dev/
- **SHA-1 Generator:** https://developers.google.com/android/guides/client-auth

---

## 🎉 انتهيت؟

بعد إكمال جميع الخطوات:

1. **Firebase جاهز!** ✅
2. **Google Sign-in يعمل!** ✅
3. **الإشعارات جاهزة!** ✅
4. **قاعدة البيانات جاهزة!** ✅

### الخطوة التالية:

إعداد OAuth للمنصات الأخرى (Facebook, Twitter)

---

**تاريخ الإعداد:** 2025-01-09
**الحالة:** جاهز للتطبيق ✅
