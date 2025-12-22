# 🔧 إعداد لوحة تحكم Filament - دليل سريع

## ✅ التحقق من التثبيت

### 1. التأكد من تثبيت Filament:

```bash
cd backend
composer show filament/filament
```

إذا لم يكن مثبتاً:
```bash
composer require filament/filament:"^3.0"
```

---

## 🚀 خطوات التشغيل

### 1. تشغيل Migrations:

```bash
cd backend
php artisan migrate
```

هذا سيُنشئ/يُحدّث الجداول:
- `website_requests`
- `sponsored_ad_requests`
- `users` (مع user_id في الجداول)

---

### 2. إنشاء مستخدم أدمن:

#### الطريقة 1: باستخدام Tinker
```bash
php artisan tinker
```

ثم:
```php
$admin = \App\Models\User::create([
    'name' => 'Admin',
    'email' => 'admin@mediapro.social',
    'password' => bcrypt('password123'),
    'is_admin' => true,
    'is_active' => true,
]);

echo "✅ Admin created: " . $admin->email;
exit;
```

#### الطريقة 2: تحديث مستخدم موجود
```bash
php artisan tinker
```

```php
$user = \App\Models\User::where('email', 'your@email.com')->first();
$user->is_admin = true;
$user->save();
echo "✅ User is now admin";
exit;
```

---

### 3. مسح الكاش:

```bash
php artisan optimize:clear
php artisan filament:optimize-clear
```

---

### 4. فتح لوحة التحكم:

```
https://mediaprosocial.io/admin
```

أو في البيئة المحلية:
```
http://localhost/admin
```

**تسجيل الدخول:**
- Email: `admin@mediapro.social`
- Password: `password123`

---

## 📊 الوصول للصفحات

بعد تسجيل الدخول، ستجد في القائمة الجانبية:

```
📁 إدارة الطلبات
   ├── 🌐 طلبات المواقع
   └── 📢 الإعلانات الممولة
```

---

## 🧪 اختبار النظام

### اختبار 1: إنشاء طلب موقع من التطبيق

1. افتح التطبيق
2. سجل دخول
3. اذهب إلى "طلب موقع إلكتروني"
4. املأ البيانات
5. أرسل الطلب
6. افتح لوحة Filament → طلبات المواقع
7. ✅ يجب أن تشاهد الطلب الجديد

### اختبار 2: قبول طلب

1. في لوحة التحكم، افتح طلبات المواقع
2. اضغط على القائمة (⋮) بجانب طلب
3. اختر "قبول"
4. أكد العملية
5. ✅ يجب أن تتغير الحالة إلى "مقبول" باللون الأخضر

### اختبار 3: رفض طلب مع ملاحظات

1. اختر طلب pending
2. اضغط على القائمة (⋮)
3. اختر "رفض"
4. اكتب السبب: "الميزانية غير كافية"
5. أكد العملية
6. ✅ الحالة تتغير إلى "مرفوض" ويتم حفظ السبب

### اختبار 4: Bulk Actions

1. حدد عدة طلبات (☑️)
2. من قائمة Bulk Actions، اختر "قبول المحدد"
3. أكد العملية
4. ✅ جميع الطلبات المحددة يجب أن تصبح "مقبولة"

---

## 🔍 التحقق من البيانات

### عرض البيانات من Tinker:

```bash
php artisan tinker
```

```php
// عرض آخر 5 طلبات مواقع
\App\Models\WebsiteRequest::latest()->take(5)->get();

// عرض آخر 5 طلبات إعلانات
\App\Models\SponsoredAdRequest::latest()->take(5)->get();

// عرض الطلبات pending فقط
\App\Models\WebsiteRequest::where('status', 'pending')->get();

// إحصائيات
echo "Websites: " . \App\Models\WebsiteRequest::count() . "\n";
echo "Sponsored Ads: " . \App\Models\SponsoredAdRequest::count() . "\n";
```

---

## 🎨 تخصيص الألوان والأيقونات

### في ملف الـ Resource، يمكنك تغيير:

```php
// الأيقونة في القائمة
protected static ?string $navigationIcon = 'heroicon-o-globe-alt';

// المجموعة في القائمة
protected static ?string $navigationGroup = 'إدارة الطلبات';

// ترتيب العنصر
protected static ?int $navigationSort = 1;

// Badge (عدد الطلبات الجديدة)
public static function getNavigationBadge(): ?string
{
    return static::getModel()::where('status', 'pending')->count() ?: null;
}
```

---

## 🛠️ استكشاف الأخطاء الشائعة

### خطأ: "Class 'Filament' not found"

**الحل:**
```bash
composer require filament/filament:"^3.0"
php artisan filament:install --panels
```

### خطأ: "Unable to locate class"

**الحل:**
```bash
composer dump-autoload
php artisan optimize:clear
```

### خطأ: "SQLSTATE[42S02]: Base table or view not found"

**الحل:**
```bash
php artisan migrate:fresh
# ⚠️ تحذير: هذا سيحذف جميع البيانات!
```

أو:
```bash
php artisan migrate
```

### خطأ: "Access denied for user"

**الحل:**
1. تحقق من ملف `.env`:
   ```
   DB_CONNECTION=mysql
   DB_HOST=localhost
   DB_PORT=3306
   DB_DATABASE=your_database
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   ```

2. أعد تشغيل:
   ```bash
   php artisan config:clear
   ```

### الصفحات لا تظهر في القائمة

**الحل:**
```bash
php artisan filament:optimize-clear
php artisan cache:clear
```

### لا يمكن الوصول لـ /admin

**الحل:**

1. تأكد من أن Filament مثبت:
   ```bash
   php artisan about
   ```

2. تحقق من Routes:
   ```bash
   php artisan route:list | grep admin
   ```

3. إعادة تثبيت Panel:
   ```bash
   php artisan filament:install --panels
   ```

---

## 📱 الاستخدام على الهاتف

لوحة Filament responsive وتعمل على الهاتف:

1. افتح المتصفح على الهاتف
2. اذهب إلى: `https://mediaprosocial.io/admin`
3. سجل دخول
4. ✅ جميع الميزات تعمل

---

## 🔐 الأمان

### تأمين لوحة التحكم:

1. **استخدام HTTPS فقط:**
   ```php
   // في AppServiceProvider
   if (app()->environment('production')) {
       URL::forceScheme('https');
   }
   ```

2. **Two-Factor Authentication:**
   ```bash
   composer require filament/filament-2fa
   ```

3. **IP Whitelisting:**
   ```php
   // في Middleware
   if (!in_array($request->ip(), ['your.ip.address'])) {
       abort(403);
   }
   ```

---

## 📊 إضافة Widgets (اختياري)

### Widget للإحصائيات:

```bash
php artisan make:filament-widget StatsOverview
```

في `app/Filament/Widgets/StatsOverview.php`:
```php
protected function getCards(): array
{
    return [
        Card::make('إجمالي طلبات المواقع', WebsiteRequest::count()),
        Card::make('طلبات قيد الانتظار', WebsiteRequest::where('status', 'pending')->count()),
        Card::make('طلبات مقبولة', WebsiteRequest::where('status', 'accepted')->count()),
    ];
}
```

---

## 📞 الدعم الفني

إذا واجهت مشاكل:

1. تحقق من Laravel logs:
   ```bash
   tail -f storage/logs/laravel.log
   ```

2. راجع Filament docs:
   https://filamentphp.com/docs

3. تحقق من GitHub issues:
   https://github.com/filamentphp/filament/issues

---

## ✅ Checklist النهائي

قبل الانتقال للإنتاج:

- [ ] Migrations تم تشغيلها
- [ ] مستخدم Admin تم إنشاؤه
- [ ] يمكن الوصول لـ /admin
- [ ] الصفحتان تظهران في القائمة
- [ ] يمكن إنشاء/عرض/تعديل الطلبات
- [ ] Filters تعمل
- [ ] Bulk Actions تعمل
- [ ] Custom Actions تعمل
- [ ] البيانات تُحفظ في قاعدة البيانات
- [ ] Responsive على الهاتف

---

**تاريخ الإنشاء:** 2025-01-09
**الإصدار:** v1.0

🎉 **الآن لوحة التحكم جاهزة للاستخدام!**
