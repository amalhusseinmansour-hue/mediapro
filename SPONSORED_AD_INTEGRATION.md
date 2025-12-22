# ✅ تكامل طلبات الإعلانات الممولة

## 📌 نظرة عامة

تم إنشاء نظام كامل لإدارة طلبات الإعلانات الممولة مع تكامل تام بين تطبيق Flutter وباك إند Laravel.

---

## 🗄️ **قاعدة البيانات**

### جدول `sponsored_ad_requests`

| الحقل | النوع | الوصف |
|------|------|-------|
| `id` | bigint | معرف الطلب الفريد |
| `user_id` | bigint (nullable) | معرف المستخدم (مرتبط بجدول users) |
| `name` | string | اسم العميل |
| `email` | string | البريد الإلكتروني |
| `phone` | string | رقم الهاتف |
| `company_name` | string (nullable) | اسم الشركة |
| `ad_platform` | enum | منصة الإعلان (facebook, instagram, google, tiktok, twitter, linkedin, snapchat, multiple) |
| `ad_type` | enum | هدف الحملة (awareness, traffic, engagement, leads, sales, app_installs) |
| `target_audience` | text | وصف الجمهور المستهدف |
| `budget` | decimal(10,2) | الميزانية |
| `currency` | string(3) | العملة (AED, SAR, USD, EUR) |
| `duration_days` | int (nullable) | مدة الحملة بالأيام |
| `start_date` | date (nullable) | تاريخ بدء الحملة المطلوب |
| `ad_content` | text (nullable) | محتوى ووصف الإعلان |
| `targeting_options` | json (nullable) | خيارات الاستهداف التفصيلية |
| `status` | enum | حالة الطلب (pending, reviewing, accepted, rejected, running, completed) |
| `admin_notes` | text (nullable) | ملاحظات الإدارة |
| `created_at` | timestamp | تاريخ إنشاء الطلب |
| `updated_at` | timestamp | تاريخ آخر تحديث |
| `deleted_at` | timestamp (nullable) | Soft delete |

**Migrations:**
- `2025_11_08_000002_create_sponsored_ad_requests_table.php`
- `2025_01_09_000001_add_user_id_to_sponsored_ad_requests_table.php`

---

## 🔌 **Laravel Backend**

### **1. API Endpoints**

#### ✅ **POST** `/api/sponsored-ad-requests` (عام - لا يحتاج تسجيل دخول)

**الوصف:** إنشاء طلب إعلان ممول جديد

**Request Body:**
```json
{
  "name": "محمد أحمد",
  "email": "mohamed@example.com",
  "phone": "+971501234567",
  "company_name": "شركة ABC",
  "ad_platform": "facebook",
  "ad_type": "sales",
  "target_audience": "رجال ونساء، 25-45 سنة، مهتمون بالتسوق الإلكتروني",
  "budget": 5000,
  "currency": "AED",
  "duration_days": 30,
  "start_date": "2025-02-01",
  "ad_content": "إعلان عن منتجات جديدة بخصم 50%"
}
```

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "تم إرسال طلب الإعلان الممول بنجاح! سنتواصل معك قريباً.",
  "data": {
    "id": 1,
    "user_id": 5,
    "name": "محمد أحمد",
    "email": "mohamed@example.com",
    "phone": "+971501234567",
    "company_name": "شركة ABC",
    "ad_platform": "facebook",
    "ad_type": "sales",
    "target_audience": "رجال ونساء، 25-45 سنة...",
    "budget": "5000.00",
    "currency": "AED",
    "duration_days": 30,
    "start_date": "2025-02-01",
    "ad_content": "إعلان عن منتجات جديدة...",
    "status": "pending",
    "created_at": "2025-01-09T12:00:00.000000Z",
    "updated_at": "2025-01-09T12:00:00.000000Z",
    "user": {
      "id": 5,
      "name": "محمد أحمد",
      "email": "mohamed@example.com"
    }
  }
}
```

**Response (Validation Error - 422):**
```json
{
  "success": false,
  "message": "بيانات غير صحيحة",
  "errors": {
    "email": ["The email must be a valid email address."],
    "budget": ["The budget must be at least 1."]
  }
}
```

---

#### ✅ **GET** `/api/sponsored-ad-requests` (يحتاج تسجيل دخول)

**الوصف:** الحصول على جميع طلبات الإعلانات الممولة (للأدمن)

**Query Parameters:**
- `status` (optional): pending, reviewing, accepted, rejected, running, completed
- `ad_platform` (optional): facebook, instagram, google, etc.
- `ad_type` (optional): awareness, traffic, engagement, etc.
- `search` (optional): البحث في الاسم، البريد، اسم الشركة
- `per_page` (optional): عدد العناصر في الصفحة (default: 15)

**Response:**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "user_id": 5,
        "name": "محمد أحمد",
        "email": "mohamed@example.com",
        "ad_platform": "facebook",
        "budget": "5000.00",
        "status": "pending",
        "created_at": "2025-01-09T12:00:00.000000Z"
      }
    ],
    "total": 25,
    "per_page": 15,
    "last_page": 2
  }
}
```

---

#### ✅ **GET** `/api/sponsored-ad-requests/{id}` (يحتاج تسجيل دخول)

**الوصف:** الحصول على طلب محدد

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": 5,
    "name": "محمد أحمد",
    "email": "mohamed@example.com",
    ...
  }
}
```

---

#### ✅ **PUT** `/api/sponsored-ad-requests/{id}` (Admin only)

**الوصف:** تحديث حالة الطلب وملاحظات الأدمن

**Request Body:**
```json
{
  "status": "accepted",
  "admin_notes": "تم قبول الحملة، سيتم البدء يوم 2025-02-01"
}
```

---

#### ✅ **DELETE** `/api/sponsored-ad-requests/{id}` (Admin only)

**الوصف:** حذف طلب (Soft Delete)

---

#### ✅ **GET** `/api/sponsored-ad-requests/statistics` (Admin only)

**الوصف:** الحصول على إحصائيات الطلبات

**Response:**
```json
{
  "success": true,
  "data": {
    "total": 150,
    "pending": 45,
    "reviewing": 20,
    "accepted": 50,
    "rejected": 10,
    "running": 15,
    "completed": 10,
    "by_platform": {
      "facebook": 60,
      "instagram": 50,
      "google": 30,
      "tiktok": 10
    }
  }
}
```

---

### **2. Controller**

**الملف:** `backend/app/Http/Controllers/Api/SponsoredAdRequestController.php`

**الميزات:**
- ✅ Validation كامل للبيانات
- ✅ ربط الطلب بالمستخدم تلقائياً (`user_id`)
- ✅ فلترة بحسب الحالة، المنصة، النوع
- ✅ البحث في الاسم، البريد، الشركة
- ✅ Pagination
- ✅ Soft Deletes
- ✅ إحصائيات شاملة

---

### **3. Model**

**الملف:** `backend/app/Models/SponsoredAdRequest.php`

**الميزات:**
- ✅ العلاقة مع User Model
- ✅ Scopes للفلترة
- ✅ Accessors للترجمة العربية
- ✅ JSON Casting لـ `targeting_options`
- ✅ Date Casting لـ `start_date`
- ✅ Soft Deletes

---

## 📱 **Flutter Application**

### **1. Service**

**الملف:** `lib/services/sponsored_ad_service.dart`

**الوظائف:**
- ✅ `submitRequest()` - إرسال طلب جديد
- ✅ `getMyRequests()` - جلب طلبات المستخدم
- ✅ `getRequest(id)` - جلب طلب محدد
- ✅ `deleteRequest(id)` - حذف طلب
- ✅ `getStatistics()` - جلب الإحصائيات

**مثال الاستخدام:**
```dart
final service = Get.put(SponsoredAdService());
final request = SponsoredAdRequestModel(...);
final success = await service.submitRequest(request);
```

---

### **2. Model**

**الملف:** `lib/models/sponsored_ad_request_model.dart`

**الميزات:**
- ✅ `toJson()` / `fromJson()` للتحويل
- ✅ `copyWith()` للنسخ مع تعديلات
- ✅ Helper methods للترجمة العربية:
  - `getPlatformArabic()`
  - `getAdTypeArabic()`
  - `getStatusArabic()`

---

### **3. UI Screen**

**الملف:** `lib/screens/sponsored_ad/sponsored_ad_request_screen.dart`

**الحقول:**
1. **معلومات العميل:**
   - الاسم الكامل (مطلوب)
   - البريد الإلكتروني (مطلوب)
   - رقم الهاتف (مطلوب)
   - اسم الشركة (اختياري)

2. **تفاصيل الحملة:**
   - منصة الإعلان (Dropdown) - مطلوب
   - هدف الحملة (Dropdown) - مطلوب
   - الجمهور المستهدف (نص) - مطلوب

3. **الميزانية والمدة:**
   - الميزانية (رقم) - مطلوب
   - العملة (Dropdown: AED, SAR, USD, EUR)
   - مدة الحملة بالأيام (اختياري)
   - تاريخ البدء (Date Picker - اختياري)

4. **محتوى الإعلان:**
   - وصف ومحتوى الإعلان (اختياري)

**الميزات:**
- ✅ تصميم عصري مع gradients و neon colors
- ✅ Auto-fill من بيانات المستخدم
- ✅ Validation كامل
- ✅ Loading state أثناء الإرسال
- ✅ Success/Error snackbars
- ✅ Date picker لاختيار تاريخ البدء
- ✅ Responsive design

---

## 🔄 **تدفق البيانات**

### عند إنشاء طلب إعلان ممول:

```
1. المستخدم يملأ الفورم في Flutter
   ↓
2. Flutter يتحقق من Validation
   ↓
3. إنشاء SponsoredAdRequestModel
   ↓
4. SponsoredAdService.submitRequest()
   ↓
5. HttpService.post('sponsored-ad-requests')
   ↓
6. Laravel API: POST /api/sponsored-ad-requests
   ↓
7. SponsoredAdRequestController.store()
   ↓
8. Validation في Laravel
   ↓
9. إضافة user_id تلقائياً (إذا مسجل دخول)
   ↓
10. حفظ في جدول sponsored_ad_requests
    ↓
11. إرجاع Response: {success: true, data: {...}}
    ↓
12. Flutter يعرض Success Snackbar
    ↓
13. العودة للشاشة السابقة
```

---

## 🧪 **الاختبار**

### **1. من التطبيق:**
```dart
// الانتقال لشاشة طلب إعلان ممول
Get.to(() => const SponsoredAdRequestScreen());
```

### **2. من Laravel Tinker:**
```bash
cd backend
php artisan tinker

# عرض آخر طلب
SponsoredAdRequest::latest()->first()

# عرض جميع الطلبات
SponsoredAdRequest::all()

# عرض طلبات pending
SponsoredAdRequest::pending()->get()

# عرض طلبات Facebook
SponsoredAdRequest::byPlatform('facebook')->get()

# عرض الإحصائيات
SponsoredAdRequest::count()
```

### **3. من Postman/Insomnia:**
```
POST https://mediaprosocial.io/api/sponsored-ad-requests
Content-Type: application/json

{
  "name": "محمد أحمد",
  "email": "test@example.com",
  "phone": "+971501234567",
  "ad_platform": "facebook",
  "ad_type": "sales",
  "target_audience": "رجال ونساء، 25-45 سنة",
  "budget": 5000,
  "currency": "AED"
}
```

---

## 📊 **حالات الطلب (Status)**

| Status | بالعربية | الوصف |
|--------|---------|-------|
| `pending` | قيد الانتظار | طلب جديد لم يتم مراجعته |
| `reviewing` | قيد المراجعة | الأدمن يراجع الطلب |
| `accepted` | مقبول | تم قبول الطلب |
| `rejected` | مرفوض | تم رفض الطلب |
| `running` | قيد التنفيذ | الحملة نشطة الآن |
| `completed` | مكتمل | انتهت الحملة |

---

## 📁 **الملفات المُنشأة**

### **Backend (Laravel):**
```
backend/
├── app/
│   ├── Http/Controllers/Api/
│   │   └── SponsoredAdRequestController.php         ✏️ مُحدّث
│   └── Models/
│       └── SponsoredAdRequest.php                   ✏️ مُحدّث
└── database/migrations/
    ├── 2025_11_08_000002_create_sponsored_ad_requests_table.php  ✅ موجود
    └── 2025_01_09_000001_add_user_id_to_sponsored_ad_requests_table.php  ✨ جديد
```

### **Frontend (Flutter):**
```
lib/
├── models/
│   └── sponsored_ad_request_model.dart              ✨ جديد
├── services/
│   └── sponsored_ad_service.dart                    ✨ جديد
└── screens/
    └── sponsored_ad/
        └── sponsored_ad_request_screen.dart         ✨ جديد
```

### **Documentation:**
```
SPONSORED_AD_INTEGRATION.md                          ✨ جديد
```

---

## ✅ **الخلاصة**

### ما تم إنجازه:

1. ✅ **قاعدة البيانات:**
   - جدول `sponsored_ad_requests` كامل
   - علاقة `user_id` مع جدول `users`
   - Soft deletes مُفعّل

2. ✅ **Laravel Backend:**
   - API endpoints كاملة
   - Controller مع validation
   - Model مع relationships و scopes
   - ربط تلقائي بالمستخدم

3. ✅ **Flutter App:**
   - Service كامل للتواصل مع API
   - Model مع JSON serialization
   - شاشة UI جميلة وسهلة الاستخدام
   - Auto-fill من بيانات المستخدم

4. ✅ **التكامل:**
   - عند إنشاء طلب من Flutter → يُحفظ في Laravel DB ✅
   - يرتبط الطلب بالمستخدم تلقائياً ✅
   - إرسال إشعار نجاح للمستخدم ✅

---

## 🚀 **الخطوات التالية (اختيارية):**

1. إضافة Email Notification عند إنشاء طلب جديد
2. إضافة SMS Notification للعميل
3. لوحة تحكم الأدمن لإدارة الطلبات
4. تقارير وإحصائيات تفصيلية
5. نظام تتبع الحملات الإعلانية

---

**تاريخ الإنشاء:** 2025-01-09
**الإصدار:** v1.0

🎉 **الآن النظام جاهز! عند إنشاء طلب إعلان ممول من التطبيق، سيتم حفظه في قاعدة البيانات تلقائياً.**
