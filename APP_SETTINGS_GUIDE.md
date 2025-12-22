# دليل إعدادات التطبيق (App Settings Guide)

## نظرة عامة
تم إضافة نظام شامل لإدارة إعدادات تطبيق الموبايل من Backend Admin Panel (Filament).

## 🎯 الميزات الرئيسية

### 1. إدارة مركزية للإعدادات
- جميع إعدادات التطبيق قابلة للتحكم من Admin Panel
- لا حاجة لتحديث التطبيق لتغيير الإعدادات
- نظام cache ذكي لتحسين الأداء

### 2. إعدادات متعددة المجموعات
تنقسم الإعدادات إلى مجموعات منطقية:

#### 🔹 `app` - إعدادات التطبيق
- `app_name` - اسم التطبيق (عربي)
- `app_name_en` - اسم التطبيق (إنجليزي)
- `app_version` - رقم الإصدار الحالي
- `min_supported_version` - أقل إصدار مدعوم
- `force_update` - إجبار التحديث
- `maintenance_mode` - وضع الصيانة
- `maintenance_message` - رسالة الصيانة
- `app_logo` - شعار التطبيق (URL)
- `splash_screen_duration` - مدة شاشة البداية
- `default_theme` - المظهر الافتراضي (dark/light)
- `enable_onboarding` - تفعيل شاشات التعريف

#### 🔹 `general` - إعدادات عامة
- `currency` - العملة (AED, USD, etc.)
- `default_language` - اللغة الافتراضية
- `supported_languages` - اللغات المدعومة
- `rtl_enabled` - دعم RTL
- `support_email` - بريد الدعم
- `support_phone` - هاتف الدعم
- `support_whatsapp` - واتساب الدعم
- `terms_url` - رابط الشروط والأحكام
- `privacy_url` - رابط سياسة الخصوصية
- `help_center_url` - رابط مركز المساعدة

#### 🔹 `social` - روابط السوشال ميديا
- `facebook_page_url`
- `instagram_url`
- `twitter_url`
- `linkedin_url`
- `youtube_url`

#### 🔹 `features` - تفعيل الميزات
- `payment_enabled` - نظام الدفع
- `ai_enabled` - الذكاء الاصطناعي
- `sms_enabled` - الرسائل النصية
- `firebase_enabled` - Firebase
- `analytics_enabled` - التحليلات
- `notifications_enabled` - الإشعارات

#### 🔹 `app_limits` - قيود التطبيق
- `max_upload_size_mb` - حجم الملف الأقصى
- `max_post_images` - عدد الصور في المنشور
- `max_video_duration_seconds` - مدة الفيديو القصوى
- `rate_limit_per_minute` - عدد الطلبات المسموح بها

#### 🔹 `colors` - الألوان والـ Branding
- `primary_color` - اللون الأساسي
- `secondary_color` - اللون الثانوي
- `accent_color` - لون التمييز

#### 🔹 `ai` - إعدادات الذكاء الاصطناعي
- `ai_default_model` - النموذج الافتراضي
- `ai_max_tokens` - الحد الأقصى للتوكنز

## 📡 API Endpoints

### 1. الحصول على جميع إعدادات التطبيق
```
GET https://mediaprosocial.io/api/settings/app-config
```

**Response:**
```json
{
  "success": true,
  "data": {
    "app": {
      "name": "ميديا برو",
      "name_en": "Media Pro Social",
      "version": "1.0.0",
      "force_update": false,
      "maintenance_mode": false,
      ...
    },
    "support": {
      "email": "support@mediaprosocial.io",
      "phone": "+971 50 123 4567"
    },
    "localization": {
      "currency": "AED",
      "default_language": "ar",
      "supported_languages": ["ar", "en"]
    },
    "links": { ... },
    "features": { ... },
    "ai": { ... }
  }
}
```

### 2. الحصول على جميع الإعدادات العامة
```
GET https://mediaprosocial.io/api/settings/
```

### 3. الحصول على إعدادات مجموعة معينة
```
GET https://mediaprosocial.io/api/settings/group/{group}
```
مثال: `GET /api/settings/group/app`

### 4. الحصول على إعداد محدد
```
GET https://mediaprosocial.io/api/settings/{key}
```
مثال: `GET /api/settings/app_name`

### 5. الحصول على قائمة المجموعات
```
GET https://mediaprosocial.io/api/settings/groups
```

## 🔐 الأمان

### Public vs Private Settings
- الإعدادات التي `is_public = true` يمكن الوصول إليها من API بدون authentication
- الإعدادات الحساسة (API Keys, Secrets) يجب أن تكون `is_public = false`
- لا تعرض أبداً:
  - API Keys
  - Passwords
  - Secret Keys
  - Internal URLs

## 🎨 استخدام الإعدادات في Flutter App

### 1. تحديث SettingsService
الـ `SettingsService` موجود في:
```
lib/services/settings_service.dart
```

### 2. جلب الإعدادات عند بدء التطبيق
في `main.dart`:
```dart
final settingsService = Get.put(SettingsService());
final settingsLoaded = await settingsService.fetchAppConfig();
if (settingsLoaded) {
  print('✅ App settings loaded successfully');
}
```

### 3. استخدام الإعدادات في التطبيق
```dart
// Get settings service
final settings = Get.find<SettingsService>();

// Check if feature is enabled
if (settings.paymentEnabled) {
  // Show payment option
}

// Get app name
Text(settings.appName)

// Check maintenance mode
if (settings.maintenanceMode) {
  // Show maintenance screen
}

// Check if update is required
if (settings.forceUpdate) {
  // Show update dialog
}
```

## 🔄 Cache Management

### Auto Cache
- تخزين مؤقت تلقائي لمدة ساعة
- يتم تحديث الإعدادات تلقائياً

### Manual Cache Clear
من Admin Panel:
```
Settings -> Clear Cache
```

من API:
```
GET /api/settings/clear-cache
```

## 💻 إدارة الإعدادات من Admin Panel

### الوصول
1. افتح: `https://mediaprosocial.io/admin`
2. سجل دخول كـ Admin
3. اذهب إلى: `Settings -> الإعدادات العامة`

### إضافة إعداد جديد
1. اضغط `New Setting`
2. املأ البيانات:
   - Key: مفتاح فريد (مثل: `app_tagline`)
   - Group: المجموعة (app, general, etc.)
   - Type: نوع البيانات (string, boolean, integer, json)
   - Value: القيمة
   - Description: وصف الإعداد
   - Is Public: هل يمكن الوصول إليه من API

### تعديل إعداد
1. اضغط على الإعداد المطلوب
2. عدل القيمة
3. احفظ

### حذف Cache بعد التعديل
بعد أي تعديل، امسح الـ cache:
```bash
php artisan cache:clear
```

## 📋 أمثلة عملية

### مثال 1: تفعيل وضع الصيانة
```
Admin Panel:
1. اذهب إلى Settings
2. ابحث عن `maintenance_mode`
3. غير القيمة إلى `true`
4. عدل `maintenance_message` حسب الحاجة
5. احفظ

App Result:
- التطبيق سيعرض شاشة صيانة تلقائياً
```

### مثال 2: إجبار المستخدمين على التحديث
```
Admin Panel:
1. حدث `app_version` إلى "2.0.0"
2. حدث `min_supported_version` إلى "2.0.0"
3. فعل `force_update` = true
4. احفظ

App Result:
- المستخدمون الذين لديهم v1.x سيُطلب منهم التحديث
```

### مثال 3: تغيير عملة التطبيق
```
Admin Panel:
1. ابحث عن `currency`
2. غير من "AED" إلى "USD"
3. احفظ

App Result:
- جميع الأسعار ستعرض بـ USD
```

## 🚀 Best Practices

### 1. Version Management
- استخدم Semantic Versioning (x.y.z)
- حدث `app_version` مع كل إصدار جديد
- حافظ على `min_supported_version` محدثاً

### 2. Maintenance Mode
- استخدم وضع الصيانة للتحديثات الكبيرة
- اكتب رسالة واضحة للمستخدمين
- حدد وقت تقريبي للعودة

### 3. Feature Flags
- استخدم feature flags لاختبار الميزات الجديدة
- يمكنك تفعيل/تعطيل ميزات بدون تحديث التطبيق

### 4. Colors & Branding
- احفظ الألوان الرئيسية في الإعدادات
- يمكنك تغيير الألوان بدون تحديث

### 5. Limits & Restrictions
- ضع حدود معقولة للـ uploads
- راقب الـ rate limits

## 🔧 Troubleshooting

### المشكلة: الإعدادات لا تتحدث في التطبيق
**الحل:**
1. امسح cache: `php artisan cache:clear`
2. أعد تشغيل التطبيق
3. تأكد من أن `is_public = true`

### المشكلة: API تعيد 404
**الحل:**
1. تأكد من الـ routes: `php artisan route:list`
2. امسح route cache: `php artisan route:clear`

### المشكلة: الإعداد لا يظهر في API
**الحل:**
1. تأكد من `is_public = true`
2. امسح الـ cache
3. تحقق من الـ key name

## 📊 Database Structure

### Table: `settings`
```sql
- id (bigint)
- key (varchar) - unique
- value (text)
- type (varchar) - string/integer/boolean/json/array
- group (varchar) - app/general/social/etc
- description (text)
- is_public (boolean)
- created_at (timestamp)
- updated_at (timestamp)
```

## 🎉 ملخص

تم إنشاء نظام إعدادات شامل يسمح لك بـ:

✅ التحكم الكامل في إعدادات التطبيق من Admin Panel
✅ تحديث الإعدادات بدون الحاجة لتحديث التطبيق
✅ إدارة وضع الصيانة و Force Update
✅ تخصيص الألوان والـ Branding
✅ تفعيل/تعطيل الميزات ديناميكياً
✅ API سريع مع cache ذكي
✅ أمان عالي للبيانات الحساسة

---

**ملاحظة:** جميع التغييرات في الإعدادات تأخذ مفعولها مباشرة بعد مسح الـ cache!
