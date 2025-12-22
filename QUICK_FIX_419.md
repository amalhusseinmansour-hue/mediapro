# ⚡ حل خطأ 419 بسرعة

## 🔴 المشكلة:
```
Page Expired (419)
```

---

## ✅ الحل السريع:

### على الـ Server (عبر SSH):

```bash
ssh -p 65002 u126213189@82.25.83.217
cd public_html/backend
```

ثم شغّل هذا:

```bash
bash fix_419_automatic.sh
```

---

## 📝 أو يدوياً:

### 1. تحديث `.env`:

```bash
# تغيير SESSION_DRIVER
sed -i 's/SESSION_DRIVER=file/SESSION_DRIVER=cookie/g' .env

# تغيير SESSION_ENCRYPT
sed -i 's/SESSION_ENCRYPT=false/SESSION_ENCRYPT=true/g' .env

# تغيير CACHE_STORE
sed -i 's/CACHE_STORE=file/CACHE_STORE=database/g' .env
```

### 2. مسح الكاش:

```bash
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
```

### 3. إنشاء جدول Cache:

```bash
php artisan cache:table
php artisan migrate
```

### 4. إصلاح الأذونات:

```bash
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/
chmod -R 775 public/storage/
```

---

## ✅ بعدها مباشرة:

```
https://mediaprosocial.io/admin/login
admin@example.com
password
```

---

**هذا يجب أن يحل المشكلة! 🚀**
