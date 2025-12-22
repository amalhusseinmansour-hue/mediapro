# دليل الاستضافة الذاتية لـ Postiz

## نظرة عامة

هذا الدليل الكامل لاستضافة **Postiz** على خادمك الخاص **مجاناً** بدون أي تكاليف اشتراك.

---

## المتطلبات

### Hardware Requirements (الحد الأدنى)

- **CPU:** 2 Cores
- **RAM:** 4GB
- **Storage:** 20GB SSD
- **Bandwidth:** Unlimited (موصى به)

### Hardware Requirements (موصى به للإنتاج)

- **CPU:** 4 Cores
- **RAM:** 8GB
- **Storage:** 50GB SSD
- **Bandwidth:** Unlimited

### Software Requirements

- **OS:** Ubuntu 20.04+ أو Debian 11+
- **Docker:** v20.10+
- **Docker Compose:** v2.0+
- **Domain:** مع SSL Certificate (Let's Encrypt)

---

## خيارات الاستضافة

### الخيار 1: خادم VPS (موصى به)

**مزودي الخدمة الموصى بهم:**

| المزود | السعر/شهر | المواصفات | الرابط |
|--------|-----------|-----------|--------|
| **DigitalOcean** | $12 | 2vCPU, 4GB RAM | https://www.digitalocean.com |
| **Hetzner** | €4.5 | 2vCPU, 4GB RAM | https://www.hetzner.com |
| **Vultr** | $12 | 2vCPU, 4GB RAM | https://www.vultr.com |
| **Linode** | $12 | 2vCPU, 4GB RAM | https://www.linode.com |

**اختيارنا:** Hetzner (أرخص وأسرع)

### الخيار 2: خادمك الحالي

إذا كان لديك خادم Laravel بالفعل، يمكنك تنصيب Postiz عليه.

---

## خطوات التنصيب الكاملة

### الطريقة 1: التنصيب باستخدام Docker (الأسهل)

#### 1. إعداد الخادم الأساسي

```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تنصيب المتطلبات الأساسية
sudo apt install -y curl git wget vim

# إضافة swap (إذا كان RAM أقل من 4GB)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

#### 2. تنصيب Docker و Docker Compose

```bash
# تنصيب Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# إضافة المستخدم الحالي لمجموعة Docker
sudo usermod -aG docker $USER

# تنصيب Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# التحقق من التنصيب
docker --version
docker-compose --version

# إعادة تسجيل الدخول لتفعيل التغييرات
exit
# ثم سجل الدخول مرة أخرى
```

#### 3. استنساخ Postiz

```bash
# انتقل إلى المجلد المناسب
cd /opt

# استنساخ المشروع
sudo git clone https://github.com/gitroomhq/postiz-app.git
cd postiz-app

# منح الصلاحيات
sudo chown -R $USER:$USER /opt/postiz-app
```

#### 4. إعداد ملف البيئة

```bash
# نسخ ملف .env
cp .env.example .env

# تحرير الملف
nano .env
```

**محتوى `.env` المطلوب:**

```env
# ========== Database ==========
DATABASE_URL=postgresql://postiz:YOUR_DB_PASSWORD@postgres:5432/postiz
DATABASE_DIRECT_URL=postgresql://postiz:YOUR_DB_PASSWORD@postgres:5432/postiz

# ========== Redis ==========
REDIS_URL=redis://redis:6379

# ========== Application ==========
NODE_ENV=production
NEXT_PUBLIC_BACKEND_URL=https://postiz.yourdomain.com
FRONTEND_URL=https://postiz.yourdomain.com

# ========== Authentication ==========
NEXTAUTH_SECRET=YOUR_RANDOM_SECRET_HERE_GENERATE_WITH_openssl_rand_-base64_32
NEXTAUTH_URL=https://postiz.yourdomain.com

# ========== Email (Resend) ==========
# احصل على API Key من: https://resend.com
RESEND_API_KEY=re_your_api_key_here
EMAIL_FROM=noreply@yourdomain.com

# ========== Upload ==========
UPLOAD_DIRECTORY=/uploads
NEXT_PUBLIC_UPLOAD_DIRECTORY=/uploads

# ========== Facebook OAuth ==========
FACEBOOK_CLIENT_ID=your_facebook_app_id
FACEBOOK_CLIENT_SECRET=your_facebook_app_secret
FACEBOOK_REDIRECT_URI=https://postiz.yourdomain.com/api/auth/callback/facebook

# ========== Twitter OAuth 2.0 ==========
TWITTER_CLIENT_ID=your_twitter_client_id
TWITTER_CLIENT_SECRET=your_twitter_client_secret
TWITTER_REDIRECT_URI=https://postiz.yourdomain.com/api/auth/callback/twitter

# ========== LinkedIn OAuth ==========
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
LINKEDIN_REDIRECT_URI=https://postiz.yourdomain.com/api/auth/callback/linkedin

# ========== TikTok OAuth ==========
TIKTOK_CLIENT_KEY=your_tiktok_client_key
TIKTOK_CLIENT_SECRET=your_tiktok_client_secret
TIKTOK_REDIRECT_URI=https://postiz.yourdomain.com/api/auth/callback/tiktok

# ========== YouTube OAuth ==========
YOUTUBE_CLIENT_ID=your_youtube_client_id
YOUTUBE_CLIENT_SECRET=your_youtube_client_secret
YOUTUBE_REDIRECT_URI=https://postiz.yourdomain.com/api/auth/callback/youtube

# ========== AI Services (اختياري) ==========
OPENAI_API_KEY=your_openai_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key
```

**توليد Secret للأمان:**
```bash
openssl rand -base64 32
```

#### 5. تعديل docker-compose.yaml

أنشئ ملف `docker-compose.yaml` أو عدل الموجود:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: postiz_postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postiz
      POSTGRES_PASSWORD: YOUR_DB_PASSWORD
      POSTGRES_DB: postiz
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - postiz_network

  redis:
    image: redis:7-alpine
    container_name: postiz_redis
    restart: unless-stopped
    networks:
      - postiz_network
    volumes:
      - redis_data:/data

  backend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: postiz_backend
    restart: unless-stopped
    depends_on:
      - postgres
      - redis
    env_file:
      - .env
    ports:
      - "5000:5000"
    volumes:
      - uploads:/app/uploads
    networks:
      - postiz_network

networks:
  postiz_network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
  uploads:
```

#### 6. بناء وتشغيل Postiz

```bash
# بناء الصور (قد يستغرق 10-15 دقيقة)
docker-compose build

# تشغيل الخدمات
docker-compose up -d

# مراقبة Logs
docker-compose logs -f backend

# التحقق من تشغيل الخدمات
docker-compose ps
```

#### 7. تطبيق Database Migrations

```bash
# دخول container
docker exec -it postiz_backend sh

# تطبيق migrations
npx prisma migrate deploy

# إنشاء حساب أول (admin)
npm run seed

# الخروج
exit
```

#### 8. إعداد Nginx كـ Reverse Proxy

```bash
# تنصيب Nginx
sudo apt install -y nginx

# إنشاء ملف configuration
sudo nano /etc/nginx/sites-available/postiz
```

**محتوى ملف Nginx:**

```nginx
server {
    listen 80;
    server_name postiz.yourdomain.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name postiz.yourdomain.com;

    # SSL Configuration (سيتم إضافتها بواسطة Certbot)
    # ssl_certificate /etc/letsencrypt/live/postiz.yourdomain.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/postiz.yourdomain.com/privkey.pem;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# تفعيل الموقع
sudo ln -s /etc/nginx/sites-available/postiz /etc/nginx/sites-enabled/

# اختبار Configuration
sudo nginx -t

# إعادة تحميل Nginx
sudo systemctl reload nginx
```

#### 9. إعداد SSL باستخدام Let's Encrypt

```bash
# تنصيب Certbot
sudo apt install -y certbot python3-certbot-nginx

# الحصول على SSL Certificate
sudo certbot --nginx -d postiz.yourdomain.com

# تجديد تلقائي (Cron Job)
sudo crontab -e
# أضف هذا السطر:
0 3 * * * certbot renew --quiet
```

#### 10. التحقق من التنصيب

افتح المتصفح واذهب إلى:
```
https://postiz.yourdomain.com
```

يجب أن ترى واجهة Postiz!

---

### الطريقة 2: التنصيب اليدوي (بدون Docker)

إذا كنت لا تريد استخدام Docker:

#### 1. تنصيب Node.js

```bash
# تنصيب Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# التحقق
node --version
npm --version
```

#### 2. تنصيب PostgreSQL

```bash
sudo apt install -y postgresql postgresql-contrib

# إنشاء database
sudo -u postgres psql
```

في PostgreSQL:
```sql
CREATE DATABASE postiz;
CREATE USER postiz WITH PASSWORD 'YOUR_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE postiz TO postiz;
\q
```

#### 3. تنصيب Redis

```bash
sudo apt install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

#### 4. تنصيب Postiz

```bash
cd /opt
sudo git clone https://github.com/gitroomhq/postiz-app.git
cd postiz-app

# تنصيب dependencies
npm install

# بناء المشروع
npm run build

# تطبيق migrations
npx prisma migrate deploy

# إنشاء حساب admin
npm run seed
```

#### 5. تشغيل باستخدام PM2

```bash
# تنصيب PM2
sudo npm install -g pm2

# تشغيل التطبيق
pm2 start npm --name "postiz" -- start

# حفظ configuration
pm2 save

# تشغيل تلقائي عند الإقلاع
pm2 startup
```

---

## إنشاء API Key

بعد التنصيب:

1. سجل الدخول إلى: `https://postiz.yourdomain.com`
2. اذهب إلى **Settings** → **API Keys**
3. انقر **Generate New API Key**
4. انسخ الـ API Key
5. أضفه في `.env` لتطبيق Laravel:

```env
POSTIZ_API_KEY=your_api_key_here
POSTIZ_BASE_URL=https://postiz.yourdomain.com/public/v1
```

---

## الصيانة والمراقبة

### مراقبة Logs

```bash
# Docker logs
docker-compose logs -f backend

# PM2 logs
pm2 logs postiz

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Backup Database

```bash
# Backup (Docker)
docker exec postiz_postgres pg_dump -U postiz postiz > backup_$(date +%Y%m%d).sql

# Restore
cat backup_20250115.sql | docker exec -i postiz_postgres psql -U postiz postiz
```

### تحديث Postiz

```bash
cd /opt/postiz-app

# سحب آخر تحديثات
git pull origin main

# إعادة البناء (Docker)
docker-compose build
docker-compose up -d

# أو (PM2)
npm install
npm run build
pm2 restart postiz
```

---

## استكشاف الأخطاء

### مشكلة: Container لا يبدأ

```bash
# تحقق من logs
docker-compose logs backend

# تحقق من .env
cat .env | grep DATABASE_URL
```

### مشكلة: لا يمكن الاتصال بـ Database

```bash
# تحقق من تشغيل PostgreSQL
docker-compose ps

# اختبار الاتصال
docker exec -it postiz_postgres psql -U postiz -d postiz
```

### مشكلة: OAuth لا يعمل

1. تحقق من Redirect URIs في OAuth Apps
2. تحقق من `.env` → `*_REDIRECT_URI`
3. تأكد من HTTPS

---

## التكلفة الإجمالية

| البند | التكلفة |
|------|---------|
| **VPS (Hetzner)** | €4.5/شهر ($5) |
| **Domain (.com)** | $12/سنة (~$1/شهر) |
| **SSL (Let's Encrypt)** | مجاني |
| **Postiz License** | مجاني (مفتوح المصدر) |
| **المجموع** | **~$6/شهر** |

**مقارنة مع Ayrshare:** $45/شهر → **توفير 87%!**

---

## الأمان

### Firewall

```bash
# تنصيب UFW
sudo apt install -y ufw

# السماح بـ SSH, HTTP, HTTPS
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

# تفعيل Firewall
sudo ufw enable
```

### تحديثات أمنية تلقائية

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

---

## الخلاصة

الآن لديك **Postiz** يعمل على خادمك الخاص مع:

✅ **تحكم كامل**
✅ **لا حدود على الاستخدام**
✅ **تكلفة منخفضة جداً ($6/شهر)**
✅ **بياناتك آمنة على خادمك**
✅ **مفتوح المصدر**

---

## موارد إضافية

- **Postiz GitHub:** https://github.com/gitroomhq/postiz-app
- **Postiz Docs:** https://docs.postiz.com
- **Docker Docs:** https://docs.docker.com
- **Nginx Docs:** https://nginx.org/en/docs

---

**🎉 مبروك! الآن Postiz يعمل على خادمك!**
