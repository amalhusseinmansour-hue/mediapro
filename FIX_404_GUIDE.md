# 🔧 حل مشكلة 404 في صفحات Admin

## المشكلة:
- `https://mediaprosocial.io/admin/website-requests` → 404 Not Found
- `https://mediaprosocial.io/admin/sponsored-ad-requests` → 404 Not Found

## السبب:
الـ Routes موجودة، لكن جداول قاعدة البيانات غير موجودة (Migrations لم تُشغَّل).

---

## ✅ الحل السريع (3 خطوات)

### الخطوة 1: فحص الجداول

1. ارفع ملف `check-tables.php` إلى `/public_html` على cPanel
2. افتح في المتصفح:
   ```
   https://mediaprosocial.io/check-tables.php
   ```
3. سيظهر لك:
   - ✅ الجداول الموجودة
   - ❌ الجداول المفقودة

---

### الخطوة 2: تشغيل Migrations (إذا كانت الجداول مفقودة)

1. ارفع ملف `run-migrations.php` إلى `/public_html` على cPanel
2. افتح في المتصفح:
   ```
   https://mediaprosocial.io/run-migrations.php
   ```
3. انتظر حتى تظهر رسالة "✅ تم تشغيل Migrations بنجاح!"
4. **احذف الملف فوراً!** (من cPanel File Manager)

---

### الخطوة 3: مسح Cache

افتح Terminal في cPanel (أو استخدم ملف clear-cache.php):

```bash
cd domains/mediaprosocial.io/public_html
php artisan optimize:clear
php artisan filament:optimize-clear
php artisan route:clear
php artisan config:clear
```

**أو** ارفع `clear-cache.php` واستخدمه:
```
https://mediaprosocial.io/clear-cache.php
```
ثم احذفه فوراً!

---

## 🧪 اختبار النتيجة

افتح في المتصفح:

```
https://mediaprosocial.io/admin/website-requests
```

يجب أن تظهر الصفحة بدون 404!

---

## 📁 الملفات الجاهزة للرفع

```
C:\Users\HP\social_media_manager\
├── check-tables.php       ← لفحص الجداول
├── run-migrations.php     ← لتشغيل Migrations
└── clear-cache.php        ← لمسح Cache
```

---

## ⚠️ ملاحظات مهمة

1. **احذف ملفات PHP فوراً** بعد الاستخدام (خطر أمني!)
2. إذا استمرت المشكلة، تحقق من:
   - المستخدم لديه صلاحيات Admin (`is_admin = true`)
   - تسجيل الدخول صحيح
3. افتح `/public_html/storage/logs/laravel.log` للأخطاء

---

## 🎯 الخلاصة

المشكلة: **Migrations لم تُشغَّل**

الحل:
1. ✅ تشغيل `run-migrations.php`
2. ✅ مسح Cache
3. ✅ تحديث الصفحة

---

**تاريخ الإنشاء:** 2025-01-09
**الحالة:** جاهز للتطبيق
