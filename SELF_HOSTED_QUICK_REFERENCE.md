# 🚀 مرجع سريع - Postiz Self-Hosted

## ⚡ الأوامر الأساسية

### إدارة Postiz

```bash
# الانتقال إلى مجلد Postiz
cd /opt/postiz-app

# تشغيل Postiz
docker-compose up -d

# إيقاف Postiz
docker-compose down

# إعادة تشغيل
docker-compose restart

# مشاهدة Logs
docker-compose logs -f

# مشاهدة Logs لخدمة معينة
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f redis

# حالة الخدمات
docker-compose ps

# تحديث Postiz لآخر إصدار
git pull origin main
docker-compose build
docker-compose up -d
```

### إدارة Database

```bash
# الدخول إلى PostgreSQL
docker exec -it postiz-postgres psql -U postiz -d postiz

# عمل Backup
docker exec postiz-postgres pg_dump -U postiz postiz > backup_$(date +%Y%m%d).sql

# استعادة Backup
cat backup_20250115.sql | docker exec -i postiz-postgres psql -U postiz postiz

# تطبيق Migrations جديدة
docker exec -it postiz-backend npx prisma migrate deploy
```

### تنظيف وصيانة

```bash
# حذف Containers القديمة
docker-compose down -v

# حذف Images غير المستخدمة
docker image prune -a

# مساحة القرص
df -h

# حجم Docker
docker system df
```

---

## 🔑 المعلومات المهمة

### URLs

| الخدمة | URL |
|--------|-----|
| **Postiz Dashboard** | `http://YOUR_SERVER_IP:5000` |
| **Postiz API** | `http://YOUR_SERVER_IP:5000/api/v1` |
| **Database** | `localhost:5432` (داخل Docker) |
| **Redis** | `localhost:6379` (داخل Docker) |

### Credentials الافتراضية

```env
# Database
Username: postiz
Password: (من .env - DATABASE_URL)
Database: postiz

# Admin Account
(يتم إنشاؤه عند التسجيل الأول)
```

### Ports المستخدمة

| Port | الخدمة |
|------|--------|
| 5000 | Postiz Frontend & Backend |
| 5432 | PostgreSQL (داخلي) |
| 6379 | Redis (داخلي) |

---

## 📝 ملفات الإعداد المهمة

### في Postiz (`/opt/postiz-app/`)

```bash
.env                    # متغيرات البيئة الرئيسية
docker-compose.yaml     # تكوين Docker
prisma/schema.prisma    # Database Schema
```

### في Laravel

```bash
.env                                        # متغيرات Laravel
app/Http/Controllers/Api/PostizController.php  # Controller
routes/api.php                              # Routes
```

### في Flutter

```bash
lib/services/postiz_manager.dart            # Service Manager
lib/screens/social_media/                   # UI Screens
```

---

## 🔧 إعدادات `.env` المهمة

### Postiz `.env`

```env
# الأساسية (يجب تغييرها)
DATABASE_URL=postgresql://postiz:PASSWORD@postgres:5432/postiz
NEXTAUTH_SECRET=random_secret_here
JWT_SECRET=another_random_secret_here

# URLs (حسب الخادم)
NEXT_PUBLIC_BACKEND_URL=http://YOUR_IP:5000
FRONTEND_URL=http://YOUR_IP:5000
NEXTAUTH_URL=http://YOUR_IP:5000

# OAuth (من Developer Portals)
FACEBOOK_CLIENT_ID=xxx
FACEBOOK_CLIENT_SECRET=xxx
TWITTER_CLIENT_ID=xxx
TWITTER_CLIENT_SECRET=xxx
LINKEDIN_CLIENT_ID=xxx
LINKEDIN_CLIENT_SECRET=xxx
```

### Laravel `.env`

```env
# الاتصال بـ Postiz
POSTIZ_API_KEY=from_postiz_dashboard
POSTIZ_BASE_URL=http://YOUR_SERVER_IP:5000/api/v1

# OAuth (نفس بيانات Postiz)
FACEBOOK_APP_ID=xxx
FACEBOOK_APP_SECRET=xxx
TWITTER_CLIENT_ID=xxx
TWITTER_CLIENT_SECRET=xxx
```

---

## 🎯 OAuth Redirect URIs

### للـ Postiz (في OAuth Apps)

```
Facebook:  http://YOUR_SERVER_IP:5000/integrations/social/facebook/callback
Twitter:   http://YOUR_SERVER_IP:5000/integrations/social/twitter/callback
LinkedIn:  http://YOUR_SERVER_IP:5000/integrations/social/linkedin/callback
TikTok:    http://YOUR_SERVER_IP:5000/integrations/social/tiktok/callback
YouTube:   http://YOUR_SERVER_IP:5000/integrations/social/youtube/callback
```

### للـ Laravel (اختياري - إذا كنت تربط مباشرة)

```
https://yourdomain.com/api/postiz/oauth-callback
```

---

## 🧪 اختبارات سريعة

### اختبار Postiz يعمل

```bash
curl http://YOUR_SERVER_IP:5000
# يجب أن يرجع HTML للـ Dashboard
```

### اختبار Database

```bash
docker exec -it postiz-postgres psql -U postiz -d postiz -c "SELECT COUNT(*) FROM users;"
```

### اختبار API

```bash
# من Postiz Dashboard → Settings → API Keys
# أنشئ API Key ثم:

curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://YOUR_SERVER_IP:5000/api/v1/integrations
```

### اختبار Laravel API

```bash
curl http://your-laravel-domain.com/api/postiz/status
```

---

## 🔥 حل المشاكل الشائعة

### مشكلة: Postiz لا يشتغل

```bash
# 1. تحقق من Logs
docker-compose logs backend

# 2. تحقق من .env
cat .env | grep DATABASE_URL

# 3. أعد البناء
docker-compose down
docker-compose up -d --build
```

### مشكلة: Database Connection Error

```bash
# 1. تحقق من PostgreSQL
docker-compose ps | grep postgres

# 2. أعد تشغيل Database
docker-compose restart postgres

# 3. تحقق من Password في .env
```

### مشكلة: OAuth لا يعمل

```bash
# 1. تحقق من Redirect URIs في OAuth Apps
# 2. تحقق من .env
cat .env | grep FACEBOOK_CLIENT
cat .env | grep TWITTER_CLIENT

# 3. أعد تشغيل Postiz
docker-compose restart
```

### مشكلة: Migrations فشلت

```bash
# حذف كل شيء وإعادة البناء
docker-compose down -v
docker-compose up -d
sleep 10
docker exec -it postiz-backend npx prisma migrate deploy
```

### مشكلة: Port 5000 مستخدم

```bash
# تحقق من ما يستخدم Port 5000
sudo lsof -i :5000

# غيّر Port في docker-compose.yaml
# ports:
#   - "5001:3000"  # بدلاً من 5000

docker-compose down
docker-compose up -d
```

---

## 📊 مراقبة الأداء

### استخدام الموارد

```bash
# مراقبة Docker
docker stats

# استخدام القرص
docker system df

# Logs حجم
du -sh /opt/postiz-app/logs/

# Database حجم
docker exec postiz-postgres psql -U postiz -d postiz -c "SELECT pg_size_pretty(pg_database_size('postiz'));"
```

### تنظيف Logs

```bash
# حذف Logs القديمة
docker-compose logs --tail=0 -f > /dev/null

# أو يدوياً
rm -rf /opt/postiz-app/logs/*.log
```

---

## 🔄 التحديثات والنسخ الاحتياطي

### تحديث Postiz

```bash
cd /opt/postiz-app

# Backup أولاً
docker exec postiz-postgres pg_dump -U postiz postiz > backup_before_update.sql

# التحديث
git pull origin main
docker-compose build
docker-compose up -d

# تطبيق Migrations الجديدة
docker exec -it postiz-backend npx prisma migrate deploy
```

### Backup كامل

```bash
# Database
docker exec postiz-postgres pg_dump -U postiz postiz > postiz_db_$(date +%Y%m%d).sql

# Files
tar -czf postiz_files_$(date +%Y%m%d).tar.gz /opt/postiz-app/uploads/

# .env
cp /opt/postiz-app/.env /backup/postiz_env_$(date +%Y%m%d).env
```

### Restore

```bash
# Database
cat postiz_db_20250115.sql | docker exec -i postiz-postgres psql -U postiz postiz

# Files
tar -xzf postiz_files_20250115.tar.gz -C /
```

---

## 🚨 نصائح الأمان

### 1. تغيير Passwords الافتراضية

```bash
# في .env
DATABASE_URL=postgresql://postiz:STRONG_PASSWORD_HERE@postgres:5432/postiz
```

### 2. تفعيل Firewall

```bash
# السماح فقط بـ Port 5000 و SSH
sudo ufw allow 22
sudo ufw allow 5000
sudo ufw enable
```

### 3. استخدام HTTPS (Nginx + SSL)

راجع: `SELF_HOSTED_SETUP_COMPLETE.md` - الجزء الخامس

### 4. Backups منتظمة

```bash
# Cron Job للـ Backup اليومي
crontab -e

# أضف:
0 2 * * * docker exec postiz-postgres pg_dump -U postiz postiz > /backup/postiz_$(date +\%Y\%m\%d).sql
```

---

## 📱 التكامل مع التطبيق

### من Flutter إلى Postiz

```
Flutter App
    ↓
Laravel Backend (/api/postiz/*)
    ↓
Postiz API (http://SERVER_IP:5000/api/v1)
    ↓
Social Media Platforms
```

### المسار الكامل للنشر

```
1. User creates post in Flutter App
2. App sends to: Laravel /api/postiz/posts
3. Laravel calls: Postiz API /api/v1/posts
4. Postiz publishes to: Facebook/Twitter/etc
5. Postiz returns: post IDs
6. Laravel saves in DB
7. Laravel returns: success to App
```

---

## 🎓 موارد مفيدة

### Documentation

- **Postiz GitHub**: https://github.com/gitroomhq/postiz-app
- **Postiz Docs**: https://docs.postiz.com
- **Docker Docs**: https://docs.docker.com

### OAuth Platforms

- **Facebook**: https://developers.facebook.com/docs
- **Twitter**: https://developer.twitter.com/en/docs
- **LinkedIn**: https://docs.microsoft.com/linkedin

### ملفات المشروع

- `SELF_HOSTED_SETUP_COMPLETE.md` - دليل التنصيب الكامل
- `COMPLETE_INTEGRATION_GUIDE.md` - دليل التكامل
- `READY_TO_RUN_CHECKLIST.md` - قائمة التحقق

---

## ✅ Checklist سريع

### Postiz Setup
- [ ] Docker يعمل: `docker --version`
- [ ] Postiz مستنسخ: `ls /opt/postiz-app`
- [ ] `.env` محدّث
- [ ] `docker-compose up -d` يعمل
- [ ] Dashboard يفتح: `http://IP:5000`
- [ ] API Key تم إنشاؤه

### OAuth Setup
- [ ] Facebook App جاهز
- [ ] Twitter App جاهز
- [ ] LinkedIn App جاهز
- [ ] Redirect URIs صحيحة
- [ ] Credentials في `.env`

### Laravel Setup
- [ ] Controller منسوخ
- [ ] Routes مضافة
- [ ] `.env` محدّث
- [ ] `/api/postiz/status` يعمل

### Testing
- [ ] OAuth من Postiz ✓
- [ ] نشر من Postiz ✓
- [ ] OAuth من App ✓
- [ ] نشر من App ✓

---

## 🎉 النتيجة النهائية

عندما تنتهي من كل شيء، ستحصل على:

✅ Postiz Self-Hosted يعمل 24/7
✅ ربط مع 10+ منصات Social Media
✅ نشر تلقائي وجدولة
✅ تحليلات شاملة
✅ تطبيق Flutter متكامل
✅ **تكلفة: ~$6/شهر فقط!**

---

**🚀 حظاً موفقاً!**

**آخر تحديث:** 2025-11-15
