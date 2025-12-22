# دليل تكوين Twitter/X API

## الخطوة 1: إنشاء تطبيق Twitter

1. **اذهب إلى Twitter Developer Portal**:
   - افتح: https://developer.twitter.com/en/portal/dashboard
   - سجل الدخول بحسابك في Twitter/X

2. **إنشاء مشروع جديد**:
   - اضغط على "+ Create Project"
   - أدخل اسم المشروع (مثلاً: "Social Media Manager")
   - اختر Use Case: "Making a bot" أو "Exploring the API"
   - أدخل وصف المشروع

3. **إنشاء App داخل المشروع**:
   - اضغط على "+ Create App"
   - أدخل اسم التطبيق (مثلاً: "MediaPro")
   - احفظ **API Key** و **API Secret Key** فوراً!

## الخطوة 2: تكوين OAuth 1.0a

1. **في صفحة التطبيق، اذهب إلى "Settings"**

2. **فعّل OAuth 1.0a**:
   - User authentication settings → Set up
   - OAuth Type: **OAuth 1.0a**
   - App permissions: **Read and Write**

3. **أضف Callback URL**:
   ```
   social-media-manager://callback
   ```

4. **أضف Website URL** (أي URL صحيح):
   ```
   https://mediaprosocial.io
   ```

5. **احفظ التغييرات**

## الخطوة 3: الحصول على المفاتيح

بعد إنشاء التطبيق، ستحصل على:
- **API Key** (Consumer Key)
- **API Secret Key** (Consumer Secret)

**مهم**: احفظ هذه المفاتيح في مكان آمن!

## الخطوة 4: إضافة المفاتيح للتطبيق

### الطريقة 1: استخدام Environment Variables (موصى به)

قم بتشغيل التطبيق مع المتغيرات:
```bash
flutter run -d R9KY902X3HW --dart-define=TWITTER_API_KEY=your_api_key_here --dart-define=TWITTER_API_SECRET=your_api_secret_here
```

### الطريقة 2: تحديث api_config.dart مباشرة (للتطوير فقط)

افتح الملف:
```
lib/core/config/api_config.dart
```

ابحث عن:
```dart
static const String twitterApiKey = String.fromEnvironment(
  'TWITTER_API_KEY',
  defaultValue: '',
);

static const String twitterApiSecret = String.fromEnvironment(
  'TWITTER_API_SECRET',
  defaultValue: '',
);
```

استبدله بـ:
```dart
static const String twitterApiKey = String.fromEnvironment(
  'TWITTER_API_KEY',
  defaultValue: 'YOUR_API_KEY_HERE', // ضع API Key هنا
);

static const String twitterApiSecret = String.fromEnvironment(
  'TWITTER_API_SECRET',
  defaultValue: 'YOUR_API_SECRET_HERE', // ضع API Secret هنا
);
```

**⚠️ تحذير أمني**: لا تضع المفاتيح الحقيقية في الكود المصدري إذا كنت ستشاركه أو ترفعه على GitHub!

## الخطوة 5: البناء والتشغيل

بعد إضافة المفاتيح:

```bash
# نظف المشروع
flutter clean

# احصل على الحزم
flutter pub get

# شغّل التطبيق
flutter run -d R9KY902X3HW
```

## الخطوة 6: اختبار الربط

1. افتح التطبيق
2. اذهب إلى "الحسابات"
3. اضغط على "ربط حساب Twitter/X"
4. يجب أن تظهر صفحة تسجيل دخول Twitter
5. أدخل بيانات الدخول
6. اسمح للتطبيق بالوصول
7. سيتم حفظ الحساب تلقائياً

## استكشاف الأخطاء

### خطأ: "يجب تكوين Twitter API Keys أولاً"
- **الحل**: تأكد من وضع API Keys في api_config.dart أو تشغيل التطبيق مع --dart-define

### خطأ: "Callback URL mismatch"
- **الحل**: تأكد من إضافة `social-media-manager://callback` في إعدادات التطبيق على Twitter

### خطأ: "App is in development mode"
- **الحل**: هذا طبيعي. Twitter Apps في Development Mode تعمل مع 15 مستخدم فقط
- للرفع للإنتاج، قدّم طلب "Elevated Access" في Developer Portal

### خطأ: "403 Forbidden"
- **الحل**: تأكد من تفعيل OAuth 1.0a في إعدادات التطبيق
- تحقق من صلاحيات التطبيق (Read and Write)

## ملاحظات مهمة

1. **حدود Twitter API**:
   - في Developer Access العادي، يمكنك 500,000 تغريدة/شهر
   - للحصول على حدود أعلى، قدّم طلب Elevated Access

2. **الخصوصية**:
   - لا تشارك API Keys مع أي شخص
   - لا ترفعها على GitHub
   - استخدم Environment Variables في الإنتاج

3. **التجديد**:
   - API Keys لا تنتهي صلاحيتها
   - يمكنك تجديدها في أي وقت من Developer Portal

## روابط مفيدة

- Twitter Developer Portal: https://developer.twitter.com/en/portal/dashboard
- Twitter API Documentation: https://developer.twitter.com/en/docs/twitter-api
- OAuth 1.0a Guide: https://developer.twitter.com/en/docs/authentication/oauth-1-0a

---

💡 **نصيحة**: احفظ API Keys في مدير كلمات مرور آمن!
