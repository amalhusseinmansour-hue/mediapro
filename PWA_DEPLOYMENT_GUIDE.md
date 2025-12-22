# 🚀 PWA Deployment Guide

## مراحل النشر

### المرحلة 1: التحضير المحلي

#### 1.1 بناء التطبيق

```bash
# التنظيف
flutter clean

# الحصول على الحزم
flutter pub get

# بناء للويب
flutter build web --release --base-href=/
```

#### 1.2 التحقق من الملفات

```bash
# تحقق من وجود:
ls -la build/web/
ls -la web/manifest.json
ls -la web/sw.js
ls -la web/pwa-setup.js
```

#### 1.3 الاختبار المحلي

```bash
# تشغيل الخادم
flutter run -d web

# أو استخدم Python
cd build/web
python -m http.server 8000

# ثم افتح: http://localhost:8000
```

---

### المرحلة 2: النشر على الخادم

#### الخيار A: النشر اليدوي

##### 1. إعداد الخادم

```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تثبيت Nginx
sudo apt install nginx -y

# تثبيت SSL (Let's Encrypt)
sudo apt install certbot python3-certbot-nginx -y

# توليد شهادة SSL
sudo certbot certonly --standalone -d yourdomain.com
```

##### 2. رفع الملفات

```bash
# إنشاء مجلد التطبيق
sudo mkdir -p /var/www/media-pro
sudo chown -R $USER:$USER /var/www/media-pro

# رفع الملفات
scp -r build/web/* user@yourdomain.com:/var/www/media-pro/
scp web/sw.js user@yourdomain.com:/var/www/media-pro/
scp web/pwa-setup.js user@yourdomain.com:/var/www/media-pro/
```

##### 3. إعدادات Nginx

```bash
# انسخ ملف الإعدادات
sudo cp nginx.conf /etc/nginx/sites-available/media-pro

# فعّل الموقع
sudo ln -s /etc/nginx/sites-available/media-pro /etc/nginx/sites-enabled/

# اختبر الإعدادات
sudo nginx -t

# أعد تشغيل Nginx
sudo systemctl restart nginx
```

##### 4. إعدادات SSL

```bash
# في ملف Nginx، فعّل HTTPS
sudo nano /etc/nginx/sites-available/media-pro

# أضف:
listen 443 ssl http2;
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

# أعد التشغيل
sudo systemctl restart nginx
```

#### الخيار B: النشر عبر Docker

##### 1. بناء الصور

```bash
# بناء صورة PWA
docker build -f Dockerfile.pwa -t media-pro-web:latest .

# بناء صورة API (إذا لزم الأمر)
docker build -f backend/Dockerfile -t media-pro-api:latest backend/
```

##### 2. تشغيل الحاويات

```bash
# إنشاء ملف .env
cat > .env << EOF
DB_PASSWORD=your_secure_password
DB_ROOT_PASSWORD=your_root_password
REDIS_PASSWORD=your_redis_password
GRAFANA_PASSWORD=your_grafana_password
EOF

# تشغيل جميع الخدمات
docker-compose -f docker-compose.pwa.yml up -d
```

##### 3. المراقبة

```bash
# عرض السجلات
docker-compose -f docker-compose.pwa.yml logs -f

# عرض حالة الحاويات
docker-compose -f docker-compose.pwa.yml ps

# دخول حاوية
docker exec -it media-pro-web sh
```

#### الخيار C: النشر على Vercel/Netlify

##### Vercel

```bash
# تثبيت Vercel CLI
npm install -g vercel

# النشر
vercel

# متابعة النشر
vercel --prod
```

**ملف vercel.json:**
```json
{
  "buildCommand": "flutter build web --release --base-href=/",
  "outputDirectory": "build/web",
  "routes": [
    {
      "src": "^/(?!api).*",
      "destination": "/index.html"
    },
    {
      "src": "/api/(.*)",
      "destination": "https://api.yourdomain.com/api/$1"
    }
  ]
}
```

##### Netlify

```bash
# تثبيت Netlify CLI
npm install -g netlify-cli

# النشر
netlify deploy

# النشر للإنتاج
netlify deploy --prod
```

**ملف netlify.toml:**
```toml
[build]
  command = "flutter build web --release --base-href=/"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/manifest.json"
  [headers.values]
    Cache-Control = "public, max-age=0, must-revalidate"

[[headers]]
  for = "/sw.js"
  [headers.values]
    Cache-Control = "public, max-age=0, must-revalidate"
    Service-Worker-Allowed = "/"
```

---

### المرحلة 3: الاختبار بعد النشر

#### 1. الاختبار الأساسي

```bash
# التحقق من الموقع
curl -I https://yourdomain.com

# التحقق من manifest.json
curl https://yourdomain.com/manifest.json | jq

# التحقق من sw.js
curl https://yourdomain.com/sw.js | head -20
```

#### 2. اختبار PWA

```bash
# فتح موقعك في Chrome
# افتح DevTools (F12)

# اذهب إلى: Application > Manifest
# يجب أن تظهر البيانات

# اذهب إلى: Application > Service Workers
# يجب أن يظهر: sw.js (activated and running)

# اذهب إلى: Application > Storage > Cache Storage
# يجب أن ترى الملفات المخزنة
```

#### 3. اختبار التثبيت

```
على Android:
1. انتظر 5 ثوانٍ
2. يجب أن يظهر: "تثبيت التطبيق 📱"
3. اضغط على الزر
4. تحقق من الشاشة الرئيسية

على iOS:
1. اضغط على المشاركة ↗️
2. اختر "إضافة إلى الشاشة الرئيسية"
3. اختر الاسم وأضفه
```

#### 4. Lighthouse Audit

```bash
# تثبيت Lighthouse
npm install -g lighthouse

# تشغيل الاختبار
lighthouse https://yourdomain.com --view

# النتائج المتوقعة:
- PWA: 90+
- Performance: 85+
- Accessibility: 90+
- Best Practices: 95+
- SEO: 95+
```

---

### المرحلة 4: المراقبة والصيانة

#### 1. المراقبة

```bash
# استخدم Prometheus + Grafana
docker exec -it media-pro-grafana grafana-cli admin reset-admin-password

# الوصول إلى Grafana
http://localhost:3000
```

#### 2. النسخ الاحتياطية

```bash
# نسخ احتياطي من قاعدة البيانات
docker exec media-pro-db mysqldump -u media_user -p media_pro > backup.sql

# استعادة من نسخة احتياطية
docker exec -i media-pro-db mysql -u media_user -p media_pro < backup.sql
```

#### 3. التحديثات

```bash
# بناء نسخة جديدة
flutter build web --release --base-href=/

# رفع النسخة الجديدة
scp -r build/web/* user@yourdomain.com:/var/www/media-pro/

# أو باستخدام Docker
docker-compose -f docker-compose.pwa.yml down
docker build -f Dockerfile.pwa -t media-pro-web:latest .
docker-compose -f docker-compose.pwa.yml up -d
```

---

## ✅ Deployment Checklist

- [ ] HTTPS مفعّل
- [ ] manifest.json صحيح
- [ ] Service Worker مسجّل
- [ ] Icons موجودة (192x192, 512x512)
- [ ] PWA ثبت بنجاح
- [ ] الوضع بدون إنترنت يعمل
- [ ] Lighthouse PWA score 90+
- [ ] جميع API endpoints تعمل
- [ ] قاعدة البيانات متصلة
- [ ] النسخ الاحتياطية مفعّلة
- [ ] المراقبة مفعّلة
- [ ] SSL certificate صحيح (لا تنبيهات)

---

## 🆘 استكشاف الأخطاء

### المشكلة: HTTPS لا يعمل

```bash
# تجديد شهادة SSL
sudo certbot renew

# بدء تشغيل Nginx
sudo systemctl start nginx

# عرض السجلات
sudo journalctl -u nginx -n 20
```

### المشكلة: Service Worker لا يثبت

```bash
# تنظيف الذاكرة المحلية
# في Chrome DevTools:
# Application > Clear site data

# أعد تحميل الصفحة (Ctrl+Shift+R)
```

### المشكلة: API لا تعمل

```bash
# تحقق من الاتصال
curl https://yourdomain.com/api/health

# اعرض السجلات
docker logs media-pro-api

# أعد تشغيل الحاوية
docker restart media-pro-api
```

---

## 📞 الدعم والمساعدة

- **التوثيق**: [PWA_IMPLEMENTATION_GUIDE.md](PWA_IMPLEMENTATION_GUIDE.md)
- **البدء السريع**: [PWA_QUICK_START.md](PWA_QUICK_START.md)
- **الاختبار**: `./test-pwa.sh`

---

## 🎉 تم النشر بنجاح!

تهانينا! 🚀 تطبيقك الآن في الإنتاج ويعمل كـ PWA كامل الميزات!

**الخطوات التالية:**
1. مراقبة حركة المستخدمين
2. جمع التعليقات
3. تطبيق التحسينات
4. التخطيط للميزات الجديدة
