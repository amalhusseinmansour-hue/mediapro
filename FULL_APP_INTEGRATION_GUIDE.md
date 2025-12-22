# التكامل الكامل للتطبيق - دليل التطبيق والفلاتر وحفظ البيانات

## 📋 نظرة عامة
هذا الدليل يوضح التكامل الكامل بين الواجهة الأمامية (Flutter Web) والواجهة الخلفية (Laravel API) مع تطبيق الفلاتر المتقدمة وحفظ البيانات في قاعدة البيانات.

---

## 🏗️ بنية المشروع

### المجلد الأمامي (Flutter)
```
lib/
├── models/
│   ├── analytics_filter.dart           # نموذج الفلاتر
│   ├── usage_stats.dart                 # نموذج إحصائيات الاستخدام
│   └── overview_stats.dart              # نموذج النظرة العامة
├── services/
│   ├── analytics_service.dart           # خدمة التحليلات مع دعم الفلاتر
│   └── auth_service.dart                # خدمة المصادقة
├── screens/
│   └── analytics/
│       └── analytics_screen.dart        # شاشة التحليلات مع واجهة الفلاتر
└── widgets/
    └── analytics_filter_dialog.dart    # نافذة اختيار الفلاتر
```

### المجلد الخلفي (Laravel)
```
backend/
├── app/
│   └── Http/
│       └── Controllers/
│           └── Api/
│               ├── AnalyticsController.php    # التحكم في التحليلات
│               └── AuthController.php         # التحكم في المصادقة
├── routes/
│   └── api.php                          # تعريفات مسارات API
└── database/
    └── migrations/                      # قاعدة البيانات
```

---

## 🔌 نقاط التكامل الرئيسية

### 1. تكوين API (Frontend → Backend)
**الملف:** `lib/core/config/api_config.dart`

```dart
static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://mediaprosocial.io',
);
```

#### المتغيرات المطلوبة:
- `BACKEND_BASE_URL`: عنوان الخادم الخلفي (مثال: https://mediaprosocial.io)
- `PAYMOB_API_KEY`: مفتاح Paymob
- `PAYMOB_HMAC_SECRET`: سر HMAC للتحقق من التوقيع
- `PAYMOB_INTEGRATION_ID`: معرف التكامل (81249 أو 81250)

### 2. خدمة التحليلات (Frontend)
**الملف:** `lib/services/analytics_service.dart`

#### المزايا الرئيسية:
```dart
// 📍 دعم الفلاتر الكاملة
Future<void> fetchUsageStatsFiltered(AnalyticsFilter filter) async
Future<void> fetchOverviewStatsFiltered(AnalyticsFilter filter) async

// 📍 تطبيق الفلاتر على جميع البيانات
Future<void> applyFilters(AnalyticsFilter filter) async

// 📍 إزالة الفلاتر والعودة للبيانات الكاملة
Future<void> clearFilters() async

// 📍 تحديث تلقائي لجميع البيانات
Future<void> refreshAll() async
```

#### نموذج استخدام:
```dart
final analyticsService = Get.find<AnalyticsService>();

// تطبيق فلاتر متقدمة
final filter = AnalyticsFilter(
  dateFrom: DateTime(2025, 1, 1),
  dateTo: DateTime.now(),
  platforms: ['twitter', 'facebook', 'instagram'],
  metrics: ['views', 'engagements', 'likes'],
  periodType: 'weekly',
  isActive: true,
);

await analyticsService.applyFilters(filter);
```

### 3. نموذج الفلاتر (Frontend)
**الملف:** `lib/models/analytics_filter.dart`

#### المعاملات المدعومة:
```dart
class AnalyticsFilter {
  DateTime? dateFrom;        // تاريخ البداية
  DateTime? dateTo;          // تاريخ النهاية
  List<String>? platforms;   // المنصات المراد فلترتها
  List<String>? metrics;     // المقاييس المراد عرضها
  String? periodType;        // نوع الفترة (daily/weekly/monthly)
  bool isActive;             // هل الفلتر مفعل
}
```

#### المنصات المدعومة:
- `twitter` - تويتر
- `facebook` - فيسبوك
- `instagram` - إنستغرام
- `linkedin` - لينكد إن
- `tiktok` - تيك توك
- `bluesky` - بلو سكاي
- `threads` - ثريدز
- `pinterest` - بينترست

#### المقاييس المدعومة:
- `views` - مشاهدات
- `engagements` - تفاعلات
- `shares` - مشاركات
- `comments` - تعليقات
- `likes` - إعجابات

### 4. واجهة الفلاتر (Frontend)
**الملف:** `lib/widgets/analytics_filter_dialog.dart`

#### المكونات:
- 📅 منتقي نطاق التاريخ (Date Range Picker)
- 🏷️ منتخب نوع الفترة (Period Type Selector)
- 📱 منتخب المنصات (Platform Selector)
- 📊 منتخب المقاييس (Metrics Selector)
- 🔘 أزرار التطبيق والإعادة (Apply/Reset Buttons)

#### طريقة الاستخدام:
```dart
showDialog(
  context: context,
  builder: (context) => AnalyticsFilterDialog(
    initialFilter: analyticsService.activeFilter.value,
    onApply: (filter) async {
      await analyticsService.applyFilters(filter);
    },
  ),
);
```

### 5. شاشة التحليلات (Frontend)
**الملف:** `lib/screens/analytics/analytics_screen.dart`

#### المزايا الجديدة:
1. ✅ زر الفلاتر في شريط التطبيق (AppBar)
2. ✅ مؤشر الفلاتر النشطة (Active Filter Indicator)
3. ✅ زر إعادة تعيين الفلاتر
4. ✅ ثلاث تبويبات للبيانات (Overview/Performance/Audience)

#### البيانات المعروضة:
- 📊 إحصائيات الاستخدام (Usage Stats)
- 📈 النظرة العامة (Overview)
- 📉 بيانات المنشورات (Posts Analytics)
- 🌐 بيانات المنصات (Platforms Analytics)

---

## 🔄 API Endpoints (Backend)

### 1. جلب إحصائيات الاستخدام
**GET** `/api/analytics/usage`

#### معاملات الاستعلام (Query Parameters):
```bash
GET /api/analytics/usage?date_from=2025-01-01&date_to=2025-12-31&platforms=twitter,facebook&metrics=views,engagements&period_type=weekly
```

| المعامل | النوع | الوصف | مثال |
|-------|------|-------|------|
| `date_from` | string | تاريخ البداية (YYYY-MM-DD) | 2025-01-01 |
| `date_to` | string | تاريخ النهاية (YYYY-MM-DD) | 2025-12-31 |
| `platforms` | string/array | المنصات (فاصل بينها فاصلة) | twitter,facebook |
| `metrics` | string/array | المقاييس (فاصل بينها فاصلة) | views,engagements |
| `period_type` | string | نوع الفترة | daily/weekly/monthly |

#### الاستجابة الناجحة (200 OK):
```json
{
  "success": true,
  "usage": {
    "posts": {
      "current": 25,
      "limit": 100,
      "is_unlimited": false,
      "percentage": 25,
      "remaining": 75,
      "reset_date": "2025-02-01T00:00:00Z",
      "filtered_count": 12
    },
    "ai_requests": {
      "current": 150,
      "limit": 500,
      "is_unlimited": false,
      "is_available": true,
      "percentage": 30,
      "remaining": 350,
      "reset_date": "2025-02-01T00:00:00Z"
    },
    "connected_accounts": {
      "current": 5,
      "limit": 10,
      "percentage": 50,
      "remaining": 5
    }
  },
  "filters": {
    "date_from": "2025-01-01T00:00:00Z",
    "date_to": "2025-12-31T23:59:59Z",
    "platforms": ["twitter", "facebook"],
    "metrics": ["views", "engagements"]
  }
}
```

### 2. جلب النظرة العامة
**GET** `/api/analytics/overview`

#### معاملات الاستعلام:
```bash
GET /api/analytics/overview?date_from=2025-01-01&date_to=2025-12-31&platforms=twitter,instagram
```

#### الاستجابة الناجحة (200 OK):
```json
{
  "success": true,
  "overview": {
    "total_followers": 15250,
    "total_posts": 342,
    "total_engagement": 8540,
    "total_reach": 125000,
    "engagement_rate": 6.83,
    "followers_growth": 12.5,
    "followers_growth_percentage": "+12.5%"
  },
  "filters": {
    "date_from": "2025-01-01T00:00:00Z",
    "date_to": "2025-12-31T23:59:59Z",
    "platforms": ["twitter", "instagram"]
  }
}
```

### 3. التحقق من الحد
**GET** `/api/analytics/check-limit/{type}`

#### الأنواع المدعومة:
- `post` - التحقق من حد المنشورات
- `ai` - التحقق من حد طلبات AI
- `account` - التحقق من حد الحسابات المربوطة

#### الاستجابة الناجحة (200 OK):
```json
{
  "success": true,
  "can_proceed": true,
  "message": "يمكنك إنشاء منشور جديد",
  "usage": {
    "current": 25,
    "limit": 100,
    "remaining": 75,
    "percentage": 25
  }
}
```

---

## 💾 حفظ البيانات في قاعدة البيانات

### جداول قاعدة البيانات الرئيسية

#### 1. جدول المستخدمين (users)
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    subscription_id BIGINT UNSIGNED,
    connected_accounts_count INT DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

#### 2. جدول الحسابات المربوطة (connected_accounts)
```sql
CREATE TABLE connected_accounts (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED,
    platform VARCHAR(50),
    account_id VARCHAR(255),
    followers_count INT DEFAULT 0,
    previous_month_followers INT DEFAULT 0,
    is_connected BOOLEAN DEFAULT true,
    last_sync_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX (user_id, platform),
    INDEX (user_id, created_at)
);
```

#### 3. جدول المنشورات (posts)
```sql
CREATE TABLE posts (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED,
    platform VARCHAR(50),
    content TEXT,
    engagement_count INT DEFAULT 0,
    reach_count INT DEFAULT 0,
    shares_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    likes_count INT DEFAULT 0,
    views_count INT DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX (user_id, platform),
    INDEX (user_id, created_at),
    INDEX (created_at),
    INDEX (platform)
);
```

#### 4. جدول الاشتراكات (subscriptions)
```sql
CREATE TABLE subscriptions (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED UNIQUE,
    plan_id BIGINT UNSIGNED,
    current_posts_count INT DEFAULT 0,
    current_ai_requests_count INT DEFAULT 0,
    max_posts INT,
    custom_max_posts INT,
    custom_max_ai_requests INT,
    posts_reset_date TIMESTAMP,
    ai_requests_reset_date TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id),
    INDEX (user_id),
    INDEX (is_active)
);
```

### أمثلة على الاستعلامات

#### 1. جلب البيانات المفلترة حسب التاريخ والمنصات
```sql
SELECT 
    p.platform,
    COUNT(*) as posts_count,
    SUM(p.engagement_count) as total_engagement,
    SUM(p.reach_count) as total_reach,
    AVG(p.engagement_count) as avg_engagement
FROM posts p
WHERE p.user_id = ? 
  AND p.created_at BETWEEN ? AND ?
  AND p.platform IN (?, ?, ?)
GROUP BY p.platform;
```

#### 2. جلب إحصائيات الاستخدام
```sql
SELECT 
    s.current_posts_count,
    s.max_posts,
    s.current_ai_requests_count,
    COUNT(ca.id) as connected_accounts
FROM subscriptions s
LEFT JOIN connected_accounts ca ON ca.user_id = s.user_id
WHERE s.user_id = ?
GROUP BY s.id;
```

#### 3. جلب المنشورات الأعلى أداءً
```sql
SELECT 
    id,
    platform,
    content,
    engagement_count,
    reach_count,
    created_at
FROM posts
WHERE user_id = ? 
  AND created_at >= ? 
  AND created_at <= ?
  AND platform IN (?, ?, ?)
ORDER BY engagement_count DESC
LIMIT 10;
```

---

## 🔐 المصادقة والأمان

### 1. معاملات المصادقة (Authentication)
```dart
// الطلب يتضمن توكن المصادقة تلقائياً
headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
}
```

### 2. معايير الأمان المطبقة
- ✅ HTTPS/TLS 1.3
- ✅ HMAC-SHA512 للتوقيع
- ✅ Rate Limiting (60 طلب/دقيقة)
- ✅ SQL Injection Prevention
- ✅ CORS Protection

### 3. معالجة الأخطاء
```dart
try {
    // API Call
} on DioException catch (e) {
    // معالجة أخطاء HTTP
    final message = e.response?.data['message'] ?? 'فشل الطلب';
} catch (e) {
    // معالجة الأخطاء الأخرى
}
```

---

## 📱 حالات الاستخدام العملية

### 1️⃣ عرض تحليلات شهرية لمنصة محددة
```dart
final filter = AnalyticsFilter(
  dateFrom: DateTime(2025, 1, 1),
  dateTo: DateTime(2025, 1, 31),
  platforms: ['instagram'],
  periodType: 'monthly',
  isActive: true,
);
await analyticsService.applyFilters(filter);
```

### 2️⃣ مقارنة الأداء بين منصات متعددة
```dart
final filter = AnalyticsFilter(
  dateFrom: DateTime.now().subtract(Duration(days: 7)),
  dateTo: DateTime.now(),
  platforms: ['twitter', 'facebook', 'instagram'],
  metrics: ['engagements', 'reach'],
  periodType: 'daily',
  isActive: true,
);
await analyticsService.applyFilters(filter);
```

### 3️⃣ فحص الحدود المتبقية
```dart
final canPost = await analyticsService.canCreatePost();
final canUseAI = await analyticsService.canUseAI();
final canConnect = await analyticsService.canConnectAccount();

if (!canPost) {
  analyticsService.showLimitReachedDialog('post');
}
```

---

## 🚀 الخطوات التالية

### 1. بناء وتشغيل الخادم الخلفي
```bash
cd backend
php artisan migrate
php artisan serve
```

### 2. تكوين متغيرات البيئة
```bash
# backend/.env
BACKEND_BASE_URL=https://mediaprosocial.io
PAYMOB_MODE=live
PAYMOB_API_KEY=...
PAYMOB_INTEGRATION_ID=81249
```

### 3. بناء التطبيق الأمامي
```bash
flutter pub get
flutter run -d chrome
```

### 4. اختبار المزايا
- ✅ تحديث البيانات
- ✅ تطبيق الفلاتر
- ✅ إعادة تعيين الفلاتر
- ✅ التحقق من الحدود

---

## 📞 الدعم والمراجع

### ملفات مهمة
- `lib/services/analytics_service.dart` - الخدمة الرئيسية
- `lib/models/analytics_filter.dart` - نموذج الفلاتر
- `lib/widgets/analytics_filter_dialog.dart` - واجهة الفلاتر
- `backend/app/Http/Controllers/Api/AnalyticsController.php` - API التحكم

### API Documentation
- [Laravel API](https://laravel.com/docs)
- [Dio HTTP Client](https://github.com/flutterchina/dio)
- [GetX State Management](https://github.com/jonataslaw/getx)

---

**✅ تم إكمال التكامل الكامل للتطبيق مع دعم الفلاتر وحفظ البيانات!**

**آخر تحديث:** 26 يناير 2025  
**الحالة:** 🟢 جاهز للإنتاج
