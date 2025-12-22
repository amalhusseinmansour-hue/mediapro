# دليل الرفع السريع للسيرفر

## الحل السريع - رفع الملفات يدوياً عبر cPanel

### الخطوة 1: تسجيل الدخول لـ cPanel

افتح المتصفح واذهب إلى:
```
https://mediaprosocial.io:2083
```

أو استخدم رابط cPanel المباشر من لوحة تحكم الاستضافة.

**بيانات الدخول:**
- Username: u126213189
- Password: (كلمة المرور الخاصة بك)

---

### الخطوة 2: فتح File Manager

1. ابحث عن أيقونة **File Manager** في cPanel
2. انقر عليها
3. ستفتح نافذة جديدة

---

### الخطوة 3: رفع الملفات

#### أ. رفع Admin Controllers

1. في File Manager، انتقل إلى:
   ```
   public_html/app/Http/Controllers/
   ```

2. انقر على **New Folder** واكتب اسم المجلد:
   ```
   Admin
   ```

3. افتح المجلد `Admin` الذي أنشأته

4. انقر على **Upload** في الأعلى

5. ارفع الملفات التالية من جهازك:
   ```
   C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Admin\DashboardController.php
   C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Admin\UserController.php
   C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Admin\RequestController.php
   ```

#### ب. رفع Admin Views

1. في File Manager، انتقل إلى:
   ```
   public_html/resources/views/
   ```

2. أنشئ مجلد جديد اسمه:
   ```
   admin
   ```

3. افتح مجلد `admin`

4. أنشئ المجلدات التالية داخله:
   - `layouts`
   - `users`
   - `requests`

5. ارفع الملفات:

   **في مجلد `layouts`:**
   ```
   C:\Users\HP\social_media_manager\backend\resources\views\admin\layouts\app.blade.php
   ```

   **في مجلد `admin` الرئيسي:**
   ```
   C:\Users\HP\social_media_manager\backend\resources\views\admin\dashboard.blade.php
   ```

   **في مجلد `users`:**
   ```
   C:\Users\HP\social_media_manager\backend\resources\views\admin\users\index.blade.php
   ```

   **في مجلد `requests`:**
   ```
   C:\Users\HP\social_media_manager\backend\resources\views\admin\requests\website.blade.php
   C:\Users\HP\social_media_manager\backend\resources\views\admin\requests\bank-transfers.blade.php
   ```

#### ج. تحديث ملف Routes

1. في File Manager، انتقل إلى:
   ```
   public_html/routes/
   ```

2. ابحث عن ملف `web.php`

3. انقر بزر الفأرة الأيمن واختر **Edit**

4. احذف المحتوى القديم وانسخ المحتوى الجديد من:
   ```
   C:\Users\HP\social_media_manager\backend\routes\web.php
   ```

5. احفظ التغييرات

---

### الخطوة 4: مسح Cache

1. في cPanel، ابحث عن **Terminal** (إذا كان متوفراً)

2. إذا لم يكن Terminal متاحاً، استخدم **SSH Client** مثل PuTTY

3. نفذ الأوامر التالية:

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html

php artisan route:clear
php artisan view:clear
php artisan config:clear
php artisan cache:clear
```

---

### الخطوة 5: اختبار الصفحات

افتح المتصفح واذهب إلى:

```
https://mediaprosocial.io/admin
```

يجب أن تظهر لوحة التحكم الآن!

---

## الحل البديل - رفع ملف ZIP

إذا كان الرفع الفردي صعباً:

### 1. رفع ملف admin_pages.zip

1. في File Manager، انتقل إلى المجلد الرئيسي:
   ```
   public_html/
   ```

2. انقر على **Upload**

3. ارفع ملف:
   ```
   C:\Users\HP\social_media_manager\admin_pages.zip
   ```

4. بعد اكتمال الرفع، انقر بزر الفأرة الأيمن على الملف

5. اختر **Extract**

6. سيتم استخراج الملفات في المواقع الصحيحة

### 2. مسح Cache

نفذ نفس أوامر مسح Cache من الخطوة 4 أعلاه

---

## إذا لم يعمل Terminal في cPanel

يمكنك إنشاء ملف PHP صغير لمسح Cache:

### 1. أنشئ ملف جديد

في File Manager، أنشئ ملف جديد:
```
public_html/clear-cache.php
```

### 2. أضف هذا الكود

```php
<?php
echo "Clearing cache...\n";

// Run artisan commands
exec('cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan route:clear 2>&1', $output1);
exec('cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan view:clear 2>&1', $output2);
exec('cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan config:clear 2>&1', $output3);
exec('cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan cache:clear 2>&1', $output4);

echo "Route clear: " . implode("\n", $output1) . "\n";
echo "View clear: " . implode("\n", $output2) . "\n";
echo "Config clear: " . implode("\n", $output3) . "\n";
echo "Cache clear: " . implode("\n", $output4) . "\n";

echo "\nDone!";
?>
```

### 3. قم بزيارة الملف

افتح في المتصفح:
```
https://mediaprosocial.io/clear-cache.php
```

### 4. احذف الملف بعد الاستخدام

**مهم:** احذف `clear-cache.php` بعد الانتهاء لأسباب أمنية!

---

## استكشاف الأخطاء

### خطأ 404 مستمر

1. تأكد من رفع جميع الملفات في المواقع الصحيحة
2. تأكد من مسح Route Cache
3. تحقق من صلاحيات الملفات (يجب أن تكون 644)

### خطأ Permission Denied

قم بضبط الصلاحيات:
- المجلدات: 755
- الملفات: 644

في File Manager:
1. حدد الملف/المجلد
2. انقر بزر الفأرة الأيمن
3. اختر **Change Permissions**

---

## الدعم

إذا واجهت أي مشكلة:
1. تحقق من `storage/logs/laravel.log`
2. راجع Error Log في cPanel
3. تواصل مع الدعم الفني

---

**ملاحظة مهمة:**
بعد رفع جميع الملفات ومسح Cache، يجب أن تعمل جميع الصفحات:
- `/admin` - لوحة التحكم
- `/admin/users` - المستخدمين
- `/admin/requests/website` - طلبات المواقع
- `/admin/requests/ads` - الإعلانات
- `/admin/requests/support` - الدعم الفني
- `/admin/requests/bank-transfers` - الشحن البنكي
