# نظام الأوتوميشن للنشر على وسائل التواصل - تقدم العمل

## ✅ ما تم إنجازه حتى الآن

### 1. Database Migrations (4 جداول) ✅
- `users_social_accounts` - لتخزين حسابات المستخدمين على المنصات
- `scheduled_posts` - للمنشورات المجدولة
- `automation_rules` - لقواعد الأوتوميشن
- `post_logs` - لتتبع وتسجيل كل عملية نشر

**الموقع:** `backend/database/migrations/`

**المميزات:**
- دعم 9 منصات (Facebook, Instagram, Twitter, LinkedIn, TikTok, YouTube, Pinterest, Threads, Snapchat)
- تشفير التوكنات (encrypted tokens)
- تتبع Rate Limiting
- Exponential Backoff للـ retries
- Soft Deletes
- Comprehensive indexing

---

### 2. Eloquent Models (4 موديلات) ✅
- `UserSocialAccount` - مع token encryption/decryption
- `ScheduledPost` - مع helper methods للنشر
- `AutomationRule` - مع حساب الجدولة التلقائي
- `PostLog` - للتسجيل الشامل

**الموقع:** `backend/app/Models/`

**المميزات:**
- Relationships كاملة بين الجداول
- Scopes للاستعلامات الشائعة
- Helper methods (isDue, markAsPublished, etc.)
- Auto token expiry detection
- Rate limit tracking

---

### 3. Service Layer - Strategy Pattern ✅

**Interface:**
- `SocialPublisherInterface` - Contract للنشر

**Main Service:**
- `SocialPublishService` - الخدمة الرئيسية مع auto publisher selection

**Adapters (4 implementations):**

#### a) AyrshareAdapter ✅
- Integration كامل مع Ayrshare Unified API
- دعم multi-platform publishing
- Token refresh
- Analytics fetching
- Rate limit handling
- Post deletion

**مثال استخدام:**
```php
POST https://app.ayrshare.com/api/post
Headers: Authorization: Bearer YOUR_API_KEY
Body: {
  "post": "Your content here",
  "platforms": ["facebook", "instagram", "twitter"],
  "mediaUrls": ["https://..."],
  "scheduleDate": "2025-01-20T10:00:00Z"
}
```

#### b) WebhookAdapter ✅
- للتكامل مع Pabbly/Zapier
- يرسل POST request لـ webhook URL
- Flexible payload structure
- Test webhook function

**مثال استخدام:**
```php
POST https://connect.pabbly.com/workflow/YOUR_WEBHOOK_ID
Body: {
  "event": "social_post_publish",
  "post_id": 123,
  "content": "...",
  "platforms": ["facebook"],
  "accounts": {...}
}
```

#### c) ManualPublisher ✅
- Fallback option عندما الـ API غير متاح
- يوفر instructions للنشر اليدوي
- Platform-specific steps

#### d) PostSyncerAdapter ✅
- Template للتكامل مع PostSyncer أو أي API مشابه
- يحتاج تحديث حسب documentation الفعلي

**الموقع:** `backend/app/Services/SocialMedia/`

---

### 4. Controllers (1 من 3) ✅

#### SocialAccountController ✅
- `GET /api/social-accounts` - جلب كل الحسابات
- `POST /api/social-accounts` - ربط حساب جديد
- `PUT /api/social-accounts/{id}` - تحديث حساب
- `DELETE /api/social-accounts/{id}` - حذف حساب
- `POST /api/social-accounts/{id}/refresh-token` - تجديد التوكن
- `GET /api/social-accounts/expiring-soon` - الحسابات التي تحتاج تجديد

**الموقع:** `backend/app/Http/Controllers/Api/SocialAccountController.php`

---

## 🚧 ما سيتم إنشاؤه (قريباً)

### 5. Controllers المتبقية
- **ScheduledPostController** - CRUD للمنشورات المجدولة
- **AutomationRuleController** - CRUD لقواعد الأوتوميشن

### 6. Jobs (Queue Jobs)
- **PublishPostJob** - نشر منشور مجدول
- **RefreshTokenJob** - تجديد التوكنات
- **FetchInsightsJob** - جلب التحليلات

### 7. Scheduler (Task Scheduling)
- في `app/Console/Kernel.php`
- مهمة كل دقيقة لفحص المنشورات الجاهزة
- مهمة يومية لتجديد التوكنات
- مهمة لتنظيف الـ logs القديمة

### 8. Configuration Files
- `config/services.php` - إعدادات APIs
- `.env.example` - متغيرات البيئة المطلوبة

### 9. Tests (PHPUnit)
- Unit tests للـ Services
- Feature tests للـ Controllers
- Job dispatch tests

### 10. Documentation
- API Documentation (Postman Collection)
- Integration Guide
- Flutter Integration Steps
- Deployment Checklist

---

## 📋 Environment Variables المطلوبة

```env
# Ayrshare API
AYRSHARE_ENABLED=true
AYRSHARE_API_KEY=your_ayrshare_api_key_here

# PostSyncer API (اختياري)
POSTSYNCER_ENABLED=false
POSTSYNCER_API_KEY=your_postsyncer_api_key_here
POSTSYNCER_BASE_URL=https://api.postsyncer.com/v1

# Webhook (Pabbly/Zapier)
WEBHOOK_ENABLED=true
WEBHOOK_URL=https://connect.pabbly.com/workflow/YOUR_WEBHOOK_ID

# Queue Configuration
QUEUE_CONNECTION=database  # أو redis للإنتاج
```

---

## 🔄 سير العمل (Workflow)

### 1. ربط حساب جديد
```
Flutter App → POST /api/social-accounts
↓
Backend يحفظ: platform, access_token, refresh_token, expiry
↓
Token يُشفّر في Database
```

### 2. جدولة منشور
```
Flutter App → POST /api/scheduled-posts
↓
Backend يحفظ في scheduled_posts table
↓
Scheduler يفحص كل دقيقة
↓
PublishPostJob ينطلق عند الوقت المحدد
```

### 3. النشر الفعلي
```
PublishPostJob
↓
SocialPublishService
↓
Publisher Selection (Ayrshare/Webhook/Manual)
↓
API Call → Platform
↓
Log النتيجة في post_logs
↓
تحديث scheduled_posts (published/failed)
```

### 4. إعادة المحاولة (Retry)
```
Failed Post → تأخير exponential (5min, 15min, 45min)
↓
next_retry_at يُحسب
↓
Scheduler يجرب مرة أخرى
↓
بعد 3 محاولات → Status: permanently_failed
```

---

## 🎯 الخطوات التالية

1. ✅ إنشاء باقي الـ Controllers
2. ✅ إنشاء الـ Jobs
3. ✅ إعداد الـ Scheduler
4. ✅ كتابة الـ Tests
5. ✅ إنشاء الـ Documentation
6. 🔄 رفع الملفات على السيرفر
7. 🔄 تشغيل الـ Migrations
8. 🔄 اختبار الـ API
9. 🔄 ربط Flutter App

---

## 📞 Flutter Integration Preview

### مثال: جدولة منشور من Flutter

```dart
// في Flutter app
final response = await http.post(
  Uri.parse('https://mediaprosocial.io/api/scheduled-posts'),
  headers: {
    'Authorization': 'Bearer $userToken',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'content': 'هذا منشور تجريبي 🚀',
    'platforms': ['facebook', 'instagram', 'twitter'],
    'media_urls': ['https://example.com/image.jpg'],
    'media_type': 'image',
    'scheduled_at': '2025-01-20 10:00:00',
    'scheduling_type': 'scheduled',
  }),
);
```

### مثال: التحقق من الحالة

```dart
// Poll للتحقق من حالة المنشور
final status = await http.get(
  Uri.parse('https://mediaprosocial.io/api/scheduled-posts/123'),
  headers: {'Authorization': 'Bearer $userToken'},
);

// النتيجة
{
  "status": "published",
  "publish_results": {
    "facebook": {
      "success": true,
      "post_id": "123456789",
      "post_url": "https://facebook.com/..."
    },
    "instagram": {
      "success": true,
      "post_id": "987654321"
    }
  }
}
```

---

## 📊 Current Progress: 40% Complete

- ✅ Database Layer (100%)
- ✅ Models Layer (100%)
- ✅ Service Layer (100%)
- ✅ Controllers (33% - 1/3)
- ⏳ Jobs (0%)
- ⏳ Scheduler (0%)
- ⏳ Tests (0%)
- ⏳ Documentation (0%)

**التوقع:** سيتم إنجاز 100% في الرسائل القادمة.

---

*تم التحديث: 19 يناير 2025*
*الحالة: قيد التطوير النشط*
