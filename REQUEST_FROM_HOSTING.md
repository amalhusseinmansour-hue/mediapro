# 📞 اطلب من Hosting Provider

## بيانات Database المطلوبة

اطلب من Hosting Provider (cPanel/Plesk):

```
1. Database Host الصحيح:
   الخيارات الممكنة:
   - localhost
   - localhost.
   - 127.0.0.1
   - sql.mediaprosocial.io
   - mysql.hostinger.com
   - [server-name].hosting.com
   
   اسم Host الصحيح: ________________

2. Database Name:
   u126213189_socialmedia_ma ✓

3. Username:
   u126213189 ✓

4. Password:
   Alenwanapp33510421@ 
   (تأكد من صحتها - هل تحتوي أحرف خاصة تحتاج escape?)

5. هل MySQL مفعّل على الحساب؟
   ☐ نعم
   ☐ لا
```

---

## كيفية الحصول على البيانات:

### إذا كان cPanel:
1. ادخل: cPanel
2. اذهب إلى: MySQL Databases
3. اختر database: `u126213189_socialmedia_ma`
4. شاهد: Database Users

### إذا كان Plesk:
1. ادخل: Plesk
2. اذهب إلى: Databases
3. اختر database
4. انقر: MySQL Management

### إذا كان SSH:
```bash
ssh user@your-server
mysql -u u126213189 -p
SHOW DATABASES;
USE u126213189_socialmedia_ma;
SHOW TABLES;
```

---

## بعد الحصول على البيانات:

حدّث `.env`:

```dotenv
DB_HOST=[HOST-من-HOSTING]
DB_PORT=3306
DB_DATABASE=u126213189_socialmedia_ma
DB_USERNAME=u126213189
DB_PASSWORD=Alenwanapp33510421@
```

ثم شغّل:
```bash
php artisan config:clear
.\test_db_connection.ps1
```
