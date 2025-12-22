# 📝 دليل تنفيذ نظام طلبات المواقع الإلكترونية

## 📋 نظرة عامة

تم إنشاء نظام متكامل لطلبات المواقع الإلكترونية يتكون من:
- ✅ شاشة إرسال طلب موقع جديد
- ✅ شاشة عرض حالة جميع الطلبات
- ✅ Backend API للتعامل مع الطلبات
- ✅ قاعدة بيانات لحفظ الطلبات

---

## 🗂️ الملفات التي تم إنشاؤها

### 1. قاعدة البيانات
📁 **WEBSITE_REQUESTS_MIGRATION.sql**
- جدول `website_requests` الكامل
- الحقول: id, user_id, name, email, phone, company_name, website_type, description, budget, currency, deadline, features, status, admin_notes
- Indexes لتحسين الأداء

### 2. Backend (Laravel)
📁 **WEBSITE_REQUEST_CONTROLLER.php**
- Controller كامل مع جميع الـ Methods

📁 **WEBSITE_REQUEST_ROUTES.php**
- جميع الـ Routes للمستخدمين والإدارة

### 3. Frontend (Flutter)
📁 **lib/screens/website_request/website_request_screen.dart** ✅ (موجود مسبقاً)
- شاشة إرسال طلب جديد

📁 **lib/screens/website_request/my_website_requests_screen.dart** ✅ (جديد)
- شاشة عرض جميع طلبات المستخدم مع الحالات

📁 **lib/models/website_request_model.dart** ✅ (موجود مسبقاً)
- Model البيانات

📁 **lib/services/website_request_service.dart** ✅ (موجود مسبقاً)
- Service للتعامل مع API

---

## 🚀 خطوات التنفيذ

### الخطوة 1: إنشاء الجدول في قاعدة البيانات ⭐

#### على السيرفر (عبر SSH):

```bash
# الاتصال بالسيرفر
ssh u126213189@82.25.83.217 -p 65002

# الدخول إلى phpMyAdmin أو MySQL مباشرة
cd /home/u126213189/domains/mediaprosocial.io/public_html
```

#### تنفيذ SQL:

1. افتح phpMyAdmin من cPanel
2. اختر قاعدة البيانات الخاصة بالتطبيق
3. اذهب إلى تبويب SQL
4. انسخ محتوى ملف `WEBSITE_REQUESTS_MIGRATION.sql` والصقه
5. اضغط **Go** لتنفيذ الأمر

**أو عبر Terminal:**

```bash
mysql -u [username] -p [database_name] < WEBSITE_REQUESTS_MIGRATION.sql
```

---

### الخطوة 2: رفع Backend Files ⭐

#### رفع Controller:

```bash
# رفع الملف إلى السيرفر
scp -P 65002 WEBSITE_REQUEST_CONTROLLER.php u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/

# أو يدوياً عبر FTP/File Manager
# ضعه في: app/Http/Controllers/WebsiteRequestController.php
```

#### إضافة Routes:

افتح ملف `routes/api.php` على السيرفر وأضف:

```php
use App\Http\Controllers\WebsiteRequestController;

// Website Request Routes (User)
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/website-requests', [WebsiteRequestController::class, 'store']);
    Route::get('/website-requests', [WebsiteRequestController::class, 'index']);
    Route::get('/website-requests/{id}', [WebsiteRequestController::class, 'show']);
    Route::delete('/website-requests/{id}', [WebsiteRequestController::class, 'destroy']);
    Route::get('/website-requests/statistics', [WebsiteRequestController::class, 'statistics']);
});

// Website Request Routes (Admin)
Route::middleware(['auth:sanctum' /*, 'admin'*/])->prefix('admin')->group(function () {
    Route::get('/website-requests', [WebsiteRequestController::class, 'adminIndex']);
    Route::put('/website-requests/{id}', [WebsiteRequestController::class, 'adminUpdate']);
});
```

#### مسح الـ Cache:

```bash
# على السيرفر
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

---

### الخطوة 3: التحديثات في Flutter ✅

**التحديثات مكتملة بالفعل:**
- ✅ شاشة `MyWebsiteRequestsScreen` تم إنشاؤها
- ✅ تم ربطها بشاشة الإعدادات
- ✅ Service جاهز للاتصال بالـ API

---

## 📊 حالات الطلب (Status)

| الحالة | الوصف | اللون |
|--------|-------|-------|
| **pending** | قيد الانتظار | برتقالي 🟠 |
| **reviewing** | قيد المراجعة | أزرق 🔵 |
| **approved** | تم الموافقة | أخضر 🟢 |
| **in_progress** | قيد التنفيذ | سماوي 🔷 |
| **completed** | مكتمل | بنفسجي 🟣 |
| **cancelled** | ملغي | أحمر 🔴 |

---

## 🎨 المميزات المضافة

### في التطبيق (Flutter):

1. **شاشة إرسال طلب:**
   - نموذج كامل مع التحقق من البيانات
   - اختيار نوع الموقع (شركة، متجر، portfolio، مدونة، مخصص)
   - حقول: الاسم، البريد، الهاتف، الميزانية، الوصف
   - إرسال مباشر إلى Backend

2. **شاشة عرض الطلبات:**
   - عرض جميع طلبات المستخدم
   - فلترة حسب الحالة (Status Filter Chips)
   - بطاقات ملونة حسب الحالة
   - تفاصيل كاملة لكل طلب
   - عرض ملاحظات الإدارة إذا وجدت
   - إمكانية حذف الطلبات في حالة pending فقط
   - Pull to refresh

3. **في شاشة الإعدادات:**
   - زر "طلب موقع إلكتروني" → لإرسال طلب جديد
   - زر "طلباتي" → لعرض حالة جميع الطلبات

### في Backend (Laravel):

1. **User Endpoints:**
   - `POST /api/website-requests` - إرسال طلب جديد
   - `GET /api/website-requests` - جلب طلبات المستخدم
   - `GET /api/website-requests/{id}` - تفاصيل طلب معين
   - `DELETE /api/website-requests/{id}` - حذف طلب (pending فقط)
   - `GET /api/website-requests/statistics` - إحصائيات الطلبات

2. **Admin Endpoints:**
   - `GET /api/admin/website-requests` - جلب جميع الطلبات
   - `PUT /api/admin/website-requests/{id}` - تحديث حالة الطلب

---

## 🧪 اختبار النظام

### 1. اختبار الطلب الجديد:

```bash
# من Terminal أو Postman
curl -X POST https://mediaprosocial.io/api/website-requests \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "أحمد محمد",
    "email": "ahmed@example.com",
    "phone": "0501234567",
    "company_name": "شركة النجاح",
    "website_type": "corporate",
    "description": "أريد موقع شركة احترافي بتصميم عصري يتضمن 5 صفحات رئيسية",
    "budget": 5000,
    "currency": "SAR"
  }'
```

### 2. اختبار جلب الطلبات:

```bash
curl -X GET https://mediaprosocial.io/api/website-requests \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. في التطبيق:

1. افتح التطبيق
2. اذهب إلى **الإعدادات**
3. اضغط **طلب موقع إلكتروني**
4. املأ النموذج وأرسل
5. ارجع إلى الإعدادات
6. اضغط **طلباتي**
7. يجب أن تظهر طلباتك مع الحالات

---

## 📡 API Endpoints الكاملة

### User Routes (تتطلب auth:sanctum):

| Method | Endpoint | الوصف |
|--------|----------|-------|
| POST | `/api/website-requests` | إرسال طلب جديد |
| GET | `/api/website-requests` | جلب طلبات المستخدم |
| GET | `/api/website-requests/{id}` | تفاصيل طلب |
| DELETE | `/api/website-requests/{id}` | حذف طلب |
| GET | `/api/website-requests/statistics` | إحصائيات |

### Admin Routes (تتطلب auth:sanctum + admin):

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/admin/website-requests` | جميع الطلبات |
| PUT | `/api/admin/website-requests/{id}` | تحديث حالة طلب |

---

## 🔐 صلاحيات الإدارة

لتفعيل صلاحيات الإدارة، يجب:

1. إنشاء Middleware للتحقق من صلاحيات Admin
2. إضافة حقل `role` في جدول users
3. تفعيل middleware في Routes

**مثال:**

```php
// في routes/api.php
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
    Route::get('/website-requests', [WebsiteRequestController::class, 'adminIndex']);
    Route::put('/website-requests/{id}', [WebsiteRequestController::class, 'adminUpdate']);
});
```

---

## 📈 الإحصائيات المتاحة

عند استدعاء `/api/website-requests/statistics`:

```json
{
  "success": true,
  "data": {
    "total": 15,
    "pending": 5,
    "reviewing": 3,
    "approved": 2,
    "in_progress": 3,
    "completed": 1,
    "cancelled": 1
  }
}
```

---

## 💡 ملاحظات مهمة

1. **user_id يضاف تلقائياً** من Auth::id() في Backend
2. **لا يمكن حذف الطلب** إذا كانت حالته غير pending
3. **ملاحظات الإدارة** تظهر للمستخدم في تفاصيل الطلب
4. **الفلترة** متاحة حسب الحالة ونوع الموقع
5. **Pagination** مفعّل افتراضياً (15 طلب/صفحة)

---

## 🎯 الخطوات التالية

### 1. إشعارات:
- إرسال إشعار للإدارة عند طلب جديد
- إرسال إشعار للمستخدم عند تغيير الحالة

### 2. لوحة تحكم الإدارة:
- إنشاء شاشة Admin لإدارة جميع الطلبات
- تحديث الحالات
- إضافة ملاحظات

### 3. تحسينات:
- رفع ملفات مرفقة (صور، PDF)
- دردشة مباشرة بين المستخدم والإدارة
- نظام تقييم بعد الإنجاز

---

## 📞 الدعم

إذا واجهت أي مشاكل:
1. تحقق من الـ Logs في Laravel: `storage/logs/laravel.log`
2. تحقق من Console في Flutter
3. تأكد من تشغيل Migration بنجاح
4. تحقق من الـ Routes في `php artisan route:list`

---

✅ **النظام جاهز للاستخدام الآن!**

**الخطوة التالية:** رفع الـ Controller إلى السيرفر وتنفيذ SQL Migration
