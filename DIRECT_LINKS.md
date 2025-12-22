# 🔗 روابط مباشرة لصفحات الإدارة

## 📍 المسارات المباشرة:

### **1. لوحة التحكم الرئيسية:**
```
https://mediaprosocial.io/admin
```

### **2. طلبات المواقع الإلكترونية:**
```
https://mediaprosocial.io/admin/website-requests
```

**الإجراءات:**
- عرض جميع الطلبات: `https://mediaprosocial.io/admin/website-requests`
- إنشاء طلب جديد: `https://mediaprosocial.io/admin/website-requests/create`
- عرض طلب محدد: `https://mediaprosocial.io/admin/website-requests/[ID]`
- تعديل طلب: `https://mediaprosocial.io/admin/website-requests/[ID]/edit`

**مثال:**
```
عرض طلب #5:
https://mediaprosocial.io/admin/website-requests/5

تعديل طلب #5:
https://mediaprosocial.io/admin/website-requests/5/edit
```

---

### **3. طلبات الإعلانات الممولة:**
```
https://mediaprosocial.io/admin/sponsored-ad-requests
```

**الإجراءات:**
- عرض جميع الطلبات: `https://mediaprosocial.io/admin/sponsored-ad-requests`
- إنشاء طلب جديد: `https://mediaprosocial.io/admin/sponsored-ad-requests/create`
- عرض طلب محدد: `https://mediaprosocial.io/admin/sponsored-ad-requests/[ID]`
- تعديل طلب: `https://mediaprosocial.io/admin/sponsored-ad-requests/[ID]/edit`

**مثال:**
```
عرض طلب #10:
https://mediaprosocial.io/admin/sponsored-ad-requests/10

تعديل طلب #10:
https://mediaprosocial.io/admin/sponsored-ad-requests/10/edit
```

---

## 🛠️ إصلاح Sidebar (إذا لم تظهر الصفحات)

### **الطريقة 1: مسح الكاش (Windows)**

شغّل الملف:
```
backend\fix_sidebar.bat
```

أو يدوياً:
```bash
cd backend
php artisan optimize:clear
php artisan filament:optimize-clear
composer dump-autoload
```

---

### **الطريقة 2: تحديث يدوي**

1. **افتح:** `backend/app/Providers/Filament/AdminPanelProvider.php`

2. **تأكد من وجود:**
```php
->discoverResources(
    in: app_path('Filament/Resources'),
    for: 'App\\Filament\\Resources'
)
```

3. **تأكد من وجود المجموعة:**
```php
->navigationGroups([
    ...
    'إدارة الطلبات',
    ...
]);
```

4. **احفظ الملف وشغّل:**
```bash
php artisan optimize:clear
```

---

## 🔍 التحقق من التسجيل

### **اختبار 1: تحقق من Routes**

```bash
cd backend
php artisan route:list | grep "website-requests"
```

يجب أن تظهر:
```
GET       admin/website-requests
GET       admin/website-requests/create
POST      admin/website-requests
GET       admin/website-requests/{record}
GET       admin/website-requests/{record}/edit
PUT       admin/website-requests/{record}
DELETE    admin/website-requests/{record}
```

---

### **اختبار 2: تحقق من Resources**

```bash
php artisan tinker
```

```php
// يجب أن يرجع true
class_exists(\App\Filament\Resources\WebsiteRequestResource::class);
class_exists(\App\Filament\Resources\SponsoredAdRequestResource::class);

exit;
```

---

### **اختبار 3: زيارة المسار مباشرة**

افتح في المتصفح:
```
https://mediaprosocial.io/admin/website-requests
```

**إذا ظهرت الصفحة:**
✅ Resource مسجل بشكل صحيح، لكن قد لا يظهر في Sidebar

**إذا ظهر 404:**
❌ Resource غير مسجل، قم بمسح الكاش

---

## 🎨 إظهار في Sidebar يدوياً

إذا استمرت المشكلة، أضف هذا الكود في `AdminPanelProvider.php`:

```php
use App\Filament\Resources\WebsiteRequestResource;
use App\Filament\Resources\SponsoredAdRequestResource;

public function panel(Panel $panel): Panel
{
    return $panel
        ->default()
        ->id('admin')
        ->path('admin')
        ->login()

        // ... باقي الإعدادات ...

        ->resources([
            WebsiteRequestResource::class,           // ← أضف هذا
            SponsoredAdRequestResource::class,      // ← وهذا
        ])

        ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')

        // ... باقي الإعدادات ...
```

ثم:
```bash
php artisan optimize:clear
```

---

## 📱 Bookmark للمسارات

احفظ هذه المسارات في Bookmarks المتصفح:

| الاسم | الرابط |
|------|--------|
| 📊 Dashboard | https://mediaprosocial.io/admin |
| 🌐 طلبات المواقع | https://mediaprosocial.io/admin/website-requests |
| 📢 طلبات الإعلانات | https://mediaprosocial.io/admin/sponsored-ad-requests |
| 👥 المستخدمين | https://mediaprosocial.io/admin/users |
| 💰 المدفوعات | https://mediaprosocial.io/admin/payments |

---

## 🔐 تسجيل الدخول

**رابط تسجيل الدخول:**
```
https://mediaprosocial.io/admin/login
```

**تسجيل الخروج:**
```
https://mediaprosocial.io/admin/logout
```

---

## ✅ Checklist

- [ ] مسح الكاش (`php artisan optimize:clear`)
- [ ] زيارة المسار المباشر (`/admin/website-requests`)
- [ ] التحقق من Routes (`php artisan route:list`)
- [ ] المستخدم Admin (`is_admin = true`)
- [ ] تسجيل الدخول بنجاح

---

## 📞 إذا استمرت المشكلة

شارك هذه المعلومات:

```bash
# 1. إصدار Laravel
php artisan --version

# 2. إصدار Filament
composer show filament/filament

# 3. Routes المسجلة
php artisan route:list | grep admin

# 4. Resources الموجودة
ls -la app/Filament/Resources/
```

---

**تاريخ الإنشاء:** 2025-01-09
**الحالة:** ✅ جاهز للاستخدام
