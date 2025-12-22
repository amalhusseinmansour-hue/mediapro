# إرشادات الإعداد - Setup Instructions

## 1. إعداد Firebase

### الخطوة 1: إنشاء مشروع Firebase
1. افتح [Firebase Console](https://console.firebase.google.com/)
2. انقر على "Add project"
3. أدخل اسم المشروع: `social-media-manager`
4. اتبع الخطوات لإنشاء المشروع

### الخطوة 2: إضافة تطبيق Android
1. في Firebase Console، انقر على أيقونة Android
2. أدخل Package name: `com.socialmedia.social_media_manager`
3. قم بتنزيل `google-services.json`
4. ضع الملف في: `android/app/google-services.json`

### الخطوة 3: تفعيل Authentication
1. في Firebase Console، اذهب إلى Authentication
2. انقر على "Get started"
3. فعّل Email/Password
4. (اختياري) فعّل Facebook, Google, Twitter

### الخطوة 4: إعداد Firestore Database
1. في Firebase Console، اذهب إلى Firestore Database
2. انقر على "Create database"
3. اختر "Start in test mode"
4. اختر المنطقة الأقرب لك

### الخطوة 5: تحديث firebase_options.dart
1. افتح `lib/firebase_options.dart`
2. استبدل القيم التالية من Firebase Console:
   - `YOUR_WEB_API_KEY`
   - `YOUR_WEB_APP_ID`
   - `YOUR_MESSAGING_SENDER_ID`
   - `YOUR_PROJECT_ID`
   - وغيرها...

## 2. إعداد API Keys

### ChatGPT (OpenAI)
1. افتح [OpenAI Platform](https://platform.openai.com/)
2. سجل الدخول أو أنشئ حساب
3. اذهب إلى API Keys
4. انقر على "Create new secret key"
5. انسخ المفتاح

### Google Gemini
1. افتح [Google AI Studio](https://makersuite.google.com/)
2. سجل الدخول بحساب Google
3. انقر على "Get API Key"
4. انسخ المفتاح

### تحديث API Keys
افتح `lib/core/constants/app_constants.dart` وحدّث:
```dart
static const String openAIApiKey = 'sk-...'; // مفتاح OpenAI
static const String geminiApiKey = 'AI...';  // مفتاح Gemini
```

## 3. إعداد Social Media APIs (اختياري)

### Facebook
1. افتح [Facebook Developers](https://developers.facebook.com/)
2. أنشئ تطبيق جديد
3. أضف Facebook Login
4. احصل على App ID و App Secret

### Twitter
1. افتح [Twitter Developer Portal](https://developer.twitter.com/)
2. أنشئ مشروع جديد
3. احصل على API Key و API Secret

## 4. تشغيل التطبيق

### التحقق من التثبيت
```bash
flutter doctor
```

### تثبيت المكتبات
```bash
cd social_media_manager
flutter pub get
```

### تشغيل على محاكي/جهاز
```bash
flutter run
```

## 5. اختبار التطبيق

### إنشاء حساب تجريبي
1. شغل التطبيق
2. انقر على "سجل الآن"
3. اختر نوع الاشتراك
4. أدخل البيانات:
   - الاسم: Test User
   - البريد: test@example.com
   - كلمة المرور: test123

### اختبار الذكاء الاصطناعي
1. اذهب إلى "الذكاء الاصطناعي"
2. اختر "توليد النصوص"
3. أدخل وصف: "اكتب منشور عن التسويق الرقمي"
4. انقر على "توليد المحتوى"

## 6. حل المشاكل الشائعة

### خطأ: Firebase not initialized
**الحل:**
- تأكد من وجود ملف `google-services.json`
- تأكد من تحديث `firebase_options.dart`

### خطأ: API Key invalid
**الحل:**
- تحقق من صحة API Keys في `app_constants.dart`
- تأكد من عدم وجود مسافات إضافية

### خطأ: Build failed
**الحل:**
```bash
flutter clean
flutter pub get
flutter run
```

## 7. نصائح مهمة

### الأمان
- **لا تشارك** API Keys على GitHub
- استخدم `.gitignore` لإخفاء الملفات الحساسة
- قم بإنشاء ملف `.env` للمفاتيح (في الإنتاج)

### الأداء
- استخدم `flutter build apk --release` للنشر
- فعّل ProGuard لتقليل حجم التطبيق
- استخدم الصور المضغوطة

### التطوير
- استخدم Hot Reload: اضغط `r` في Terminal
- استخدم Hot Restart: اضغط `R` في Terminal
- استخدم DevTools للتحليل

## 8. الخطوات التالية

### تحسينات مقترحة
1. إضافة نظام OTP
2. تفعيل Push Notifications
3. إضافة وضع Offline
4. تحسين الأمان
5. إضافة تحليلات متقدمة

### الانتقال للإنتاج
1. إنشاء حساب Google Play Developer
2. إعداد App Signing
3. إنشاء Store Listing
4. رفع التطبيق للمراجعة

## 9. الدعم

### الموارد
- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Docs](https://firebase.google.com/docs)
- [OpenAI Docs](https://platform.openai.com/docs)

### الاستفسارات
إذا واجهت أي مشاكل، تواصل معنا:
- GitHub Issues
- Email: support@socialmediamanager.com

---
**ملاحظة**: هذا التطبيق تعليمي. للاستخدام التجاري، يجب مراجعة شروط استخدام جميع الخدمات المستخدمة.
