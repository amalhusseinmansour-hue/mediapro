# دليل الصفحات الإدارية - MediaPro Social

## نظرة عامة

تم إضافة نظام إدارة كامل للباك إند مع واجهة مستخدم ويب جميلة ومتجاوبة باستخدام Bootstrap 5 RTL.

---

## الملفات المُضافة

### Controllers (app/Http/Controllers/Admin/)
1. **DashboardController.php** - لوحة التحكم الرئيسية
2. **UserController.php** - إدارة المستخدمين
3. **RequestController.php** - إدارة جميع الطلبات

### Views (resources/views/admin/)
1. **layouts/app.blade.php** - القالب الأساسي مع القائمة الجانبية
2. **dashboard.blade.php** - لوحة التحكم الرئيسية
3. **users/index.blade.php** - قائمة المستخدمين
4. **requests/website.blade.php** - طلبات المواقع الإلكترونية
5. **requests/bank-transfers.blade.php** - طلبات الشحن البنكي

### Routes (routes/web.php)
- تم تحديث ملف الـ Routes لإضافة جميع المسارات الإدارية

---

## رابط الدخول للوحة التحكم

```
https://mediaprosocial.io/admin
```

---

## الصفحات المتاحة

### 1. لوحة التحكم الرئيسية
**الرابط:** `/admin`

تعرض:
- إحصائيات شاملة (المستخدمين، الاشتراكات، المحافظ، الإيرادات)
- الطلبات المعلقة
- إجراءات سريعة

### 2. إدارة المستخدمين
**الرابط:** `/admin/users`

المميزات:
- عرض قائمة جميع المستخدمين
- البحث في المستخدمين
- عرض تفاصيل كل مستخدم
- تفعيل/إلغاء تفعيل صلاحيات المشرف
- حذف المستخدمين

### 3. طلبات المواقع الإلكترونية
**الرابط:** `/admin/requests/website`

المميزات:
- عرض جميع طلبات المواقع
- التصفية حسب الحالة (معلقة، مقبولة، مكتملة)
- عرض تفاصيل كل طلب
- تحديث حالة الطلب
- إضافة ملاحظات الإدارة

### 4. طلبات الإعلانات الممولة
**الرابط:** `/admin/requests/ads`

المميزات:
- عرض جميع طلبات الإعلانات
- التصفية حسب الحالة
- تحديث حالة الطلب

### 5. تذاكر الدعم الفني
**الرابط:** `/admin/requests/support`

المميزات:
- عرض جميع التذاكر
- التصفية حسب الحالة والأولوية
- تعيين التذاكر للمشرفين
- تحديث حالة وأولوية التذاكر

### 6. طلبات الشحن البنكي ⭐
**الرابط:** `/admin/requests/bank-transfers`

المميزات:
- عرض جميع طلبات الشحن
- التصفية حسب الحالة (معلقة، مقبولة، مرفوضة)
- عرض صورة الإيصال البنكي
- الموافقة على الطلب (يتم شحن المحفظة تلقائياً)
- رفض الطلب مع إضافة سبب الرفض

---

## التصميم والواجهة

### الألوان والتصميم
- استخدام Bootstrap 5 RTL للدعم الكامل للعربية
- تدرج لوني أزرق احترافي للقائمة الجانبية
- بطاقات إحصائيات مع أيقونات Font Awesome
- جداول متجاوبة مع تنسيق جميل
- Modals للعمليات الحساسة

### القائمة الجانبية
تحتوي على:
- الرئيسية (Dashboard)
- المستخدمين
- قسم الطلبات:
  - طلبات المواقع
  - الإعلانات الممولة
  - تذاكر الدعم
  - الشحن البنكي
- الإعدادات
- تسجيل الخروج

---

## خطوات التثبيت

### 1. رفع الملفات

قم برفع محتويات `admin_pages.zip` إلى السيرفر:

```
public_html/
├── app/
│   └── Http/
│       └── Controllers/
│           └── Admin/
│               ├── DashboardController.php
│               ├── UserController.php
│               └── RequestController.php
├── resources/
│   └── views/
│       └── admin/
│           ├── layouts/
│           │   └── app.blade.php
│           ├── users/
│           │   └── index.blade.php
│           ├── requests/
│           │   ├── website.blade.php
│           │   └── bank-transfers.blade.php
│           └── dashboard.blade.php
└── routes/
    └── web.php (استبدل الملف القديم)
```

### 2. مسح Cache (إذا لزم الأمر)

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan route:clear
php artisan view:clear
php artisan config:clear
```

### 3. الوصول للوحة التحكم

افتح المتصفح وانتقل إلى:
```
https://mediaprosocial.io/admin
```

---

## الأمان

**⚠️ مهم جداً:**

حالياً، الصفحات الإدارية **غير محمية** بنظام تسجيل دخول. لتأمينها:

### الخطوة 1: إضافة Middleware للتحقق من المشرف

أنشئ Middleware جديد:

```bash
php artisan make:middleware IsAdmin
```

في `app/Http/Middleware/IsAdmin.php`:

```php
public function handle($request, Closure $next)
{
    if (!auth()->check() || !auth()->user()->is_admin) {
        return redirect('/')->with('error', 'غير مصرح لك بالدخول');
    }

    return $next($request);
}
```

### الخطوة 2: تسجيل Middleware

في `bootstrap/app.php` أو `app/Http/Kernel.php`:

```php
protected $routeMiddleware = [
    // ...
    'admin' => \App\Http\Middleware\IsAdmin::class,
];
```

### الخطوة 3: تطبيق Middleware على Routes

في `routes/web.php`، قم بتحديث:

```php
Route::prefix('admin')->name('admin.')->middleware(['auth', 'admin'])->group(function () {
    // ... Routes
});
```

---

## استخدام الصفحات

### إدارة المستخدمين

1. انتقل إلى `/admin/users`
2. استخدم البحث للعثور على مستخدم محدد
3. انقر على أيقونة العين لعرض التفاصيل
4. انقر على أيقونة الدرع لتفعيل/إلغاء صلاحيات المشرف
5. انقر على أيقونة القمامة لحذف المستخدم

### معالجة طلبات الشحن البنكي

1. انتقل إلى `/admin/requests/bank-transfers`
2. انقر على "عرض" لرؤية تفاصيل الطلب وصورة الإيصال
3. انقر على "موافقة" للموافقة على الطلب:
   - يمكنك إضافة ملاحظات اختيارية
   - سيتم شحن المحفظة تلقائياً عند الموافقة
4. انقر على "رفض" لرفض الطلب:
   - يجب إضافة سبب الرفض

### معالجة طلبات المواقع

1. انتقل إلى `/admin/requests/website`
2. استخدم الفلاتر لعرض طلبات محددة
3. انقر على أيقونة العين لعرض تفاصيل الطلب
4. انقر على أيقونة القلم لتحديث حالة الطلب:
   - قيد الانتظار
   - قيد المراجعة
   - مقبول
   - مرفوض
   - مكتمل

---

## التخصيص

### تغيير ألوان القائمة الجانبية

في `resources/views/admin/layouts/app.blade.php`:

```css
.sidebar {
    background: linear-gradient(180deg, #1e3c72 0%, #2a5298 100%);
}
```

غيّر الألوان حسب رغبتك.

### إضافة صفحة جديدة

1. أنشئ Controller جديد في `app/Http/Controllers/Admin/`
2. أنشئ View في `resources/views/admin/`
3. أضف Route في `routes/web.php`
4. أضف رابط في القائمة الجانبية في `layouts/app.blade.php`

---

## المشاكل الشائعة

### 404 Not Found
- تأكد من رفع جميع الملفات في المواقع الصحيحة
- نفذ `php artisan route:clear`

### الصفحة تظهر بدون تنسيق
- تأكد من اتصال الإنترنت (يستخدم CDN للـ Bootstrap)
- تحقق من إعدادات firewall

### البيانات لا تظهر
- تأكد من تنفيذ Migrations الخاصة بالجداول الجديدة
- تحقق من الاتصال بقاعدة البيانات

---

## الدعم

للمساعدة أو الاستفسارات، يرجى التواصل مع فريق التطوير.

---

**تاريخ الإنشاء:** 8 نوفمبر 2025
**الإصدار:** 1.0.0
