# 🏠 دليل التكامل الكامل مع Postiz Self-Hosted

## 🎯 نظرة عامة

أنت تستخدم **Postiz Self-Hosted** من: https://github.com/gitroomhq/postiz-app

**المزايا:**
✅ مجاني تماماً
✅ تحكم كامل في البيانات
✅ لا حدود على الاستخدام
✅ لا رسوم شهرية
✅ تخصيص كامل

---

## 📋 المتطلبات الأساسية

### Hardware (الحد الأدنى):
- **CPU:** 2 Cores
- **RAM:** 4GB
- **Storage:** 20GB SSD
- **الإنترنت:** سرعة جيدة

### Software:
- **OS:** Ubuntu 20.04+ أو Debian 11+
- **Docker:** v20.10+
- **Docker Compose:** v2.0+
- **Domain:** مع SSL (اختياري للتطوير، مطلوب للإنتاج)

---

## 🚀 الجزء الأول: تنصيب Postiz على الخادم

### الخطوة 1: تحضير الخادم

```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تنصيب المتطلبات الأساسية
sudo apt install -y curl git wget vim
```

### الخطوة 2: تنصيب Docker

```bash
# تنصيب Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# إضافة المستخدم لمجموعة Docker
sudo usermod -aG docker $USER

# تنصيب Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# التحقق
docker --version
docker-compose --version

# إعادة تسجيل الدخول لتفعيل التغييرات
exit
# ثم سجل الدخول مرة أخرى
```

### الخطوة 3: استنساخ Postiz

```bash
# انتقل إلى المجلد المناسب
cd /opt

# استنساخ المشروع
sudo git clone https://github.com/gitroomhq/postiz-app.git
cd postiz-app

# منح الصلاحيات
sudo chown -R $USER:$USER /opt/postiz-app
```

### الخطوة 4: إعداد ملف البيئة

```bash
# نسخ ملف .env
cp .env.example .env

# تحرير الملف
nano .env
```

**محتوى `.env` المطلوب للـ Self-Hosted:**

```env
# ==================== Database ====================
DATABASE_URL=postgresql://postiz:CHANGE_THIS_PASSWORD@postgres:5432/postiz
DATABASE_DIRECT_URL=postgresql://postiz:CHANGE_THIS_PASSWORD@postgres:5432/postiz

# ==================== Redis ====================
REDIS_URL=redis://redis:6379

# ==================== Application ====================
NODE_ENV=production
# غيّر هذا إلى IP الخادم أو Domain
NEXT_PUBLIC_BACKEND_URL=http://YOUR_SERVER_IP:5000
FRONTEND_URL=http://YOUR_SERVER_IP:5000

# ==================== Authentication ====================
# توليد secret عشوائي: openssl rand -base64 32
NEXTAUTH_SECRET=GENERATE_RANDOM_SECRET_HERE_WITH_openssl_rand_base64_32
NEXTAUTH_URL=http://YOUR_SERVER_IP:5000

# ==================== Email (Resend) - اختياري ====================
# للحصول على API Key: https://resend.com
RESEND_API_KEY=
EMAIL_FROM=noreply@yourdomain.com

# ==================== Upload ====================
UPLOAD_DIRECTORY=/uploads
NEXT_PUBLIC_UPLOAD_DIRECTORY=/uploads

# ==================== JWT Secret ====================
JWT_SECRET=GENERATE_ANOTHER_RANDOM_SECRET_HERE

# ==================== Backend Internal URL ====================
BACKEND_INTERNAL_URL=http://backend:3000

# ==================== Facebook OAuth ====================
FACEBOOK_CLIENT_ID=your_facebook_app_id
FACEBOOK_CLIENT_SECRET=your_facebook_app_secret
FACEBOOK_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/facebook/callback

# ==================== Twitter OAuth 2.0 ====================
TWITTER_CLIENT_ID=your_twitter_client_id
TWITTER_CLIENT_SECRET=your_twitter_client_secret
TWITTER_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/twitter/callback

# ==================== LinkedIn OAuth ====================
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
LINKEDIN_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/linkedin/callback

# ==================== TikTok OAuth ====================
TIKTOK_CLIENT_KEY=your_tiktok_client_key
TIKTOK_CLIENT_SECRET=your_tiktok_client_secret
TIKTOK_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/tiktok/callback

# ==================== YouTube OAuth ====================
YOUTUBE_CLIENT_ID=your_youtube_client_id
YOUTUBE_CLIENT_SECRET=your_youtube_client_secret
YOUTUBE_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/youtube/callback

# ==================== Instagram (via Facebook) ====================
# استخدم نفس بيانات Facebook

# ==================== Reddit OAuth ====================
REDDIT_CLIENT_ID=your_reddit_client_id
REDDIT_CLIENT_SECRET=your_reddit_client_secret
REDDIT_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/reddit/callback

# ==================== Pinterest OAuth ====================
PINTEREST_CLIENT_ID=your_pinterest_client_id
PINTEREST_CLIENT_SECRET=your_pinterest_client_secret
PINTEREST_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/pinterest/callback

# ==================== Threads (via Instagram) ====================
# استخدم نفس بيانات Facebook/Instagram
```

**توليد Secrets العشوائية:**
```bash
# توليد NEXTAUTH_SECRET
openssl rand -base64 32

# توليد JWT_SECRET
openssl rand -base64 32

# توليد DATABASE PASSWORD
openssl rand -base64 16
```

### الخطوة 5: تشغيل Postiz

```bash
# بناء وتشغيل الخدمات
docker-compose up -d

# مراقبة Logs
docker-compose logs -f

# للتحقق من تشغيل الخدمات
docker-compose ps
```

يجب أن ترى:
```
NAME                COMMAND             STATUS          PORTS
postiz-postgres     "postgres"          Up              5432/tcp
postiz-redis        "redis-server"      Up              6379/tcp
postiz-backend      "npm start"         Up              0.0.0.0:5000->3000/tcp
```

### الخطوة 6: تطبيق Database Migrations

```bash
# دخول container الخاص بالـ backend
docker exec -it postiz-backend sh

# تطبيق migrations
npx prisma migrate deploy

# إنشاء حساب admin أول (اختياري)
npm run seed

# الخروج
exit
```

### الخطوة 7: الوصول إلى Postiz

افتح المتصفح واذهب إلى:
```
http://YOUR_SERVER_IP:5000
```

يجب أن ترى واجهة Postiz!

**إنشاء حساب:**
1. سجل حساب جديد
2. سجل الدخول
3. اذهب إلى Settings → API Keys
4. أنشئ API Key جديد
5. **احفظ هذا الـ API Key** - ستحتاجه في Laravel

---

## 🔧 الجزء الثاني: تكوين OAuth Apps

### 1. Facebook App

**الخطوات:**
1. اذهب إلى: https://developers.facebook.com/apps
2. انقر "Create App" → "Business"
3. أدخل اسم التطبيق
4. أضف منتج "Facebook Login"
5. في Settings → Basic:
   - احصل على `App ID` و `App Secret`
6. في Facebook Login → Settings:
   - **Valid OAuth Redirect URIs**: `http://YOUR_SERVER_IP:5000/integrations/social/facebook/callback`
7. أضف في `.env` الخاص بـ Postiz:
```env
FACEBOOK_CLIENT_ID=your_app_id
FACEBOOK_CLIENT_SECRET=your_app_secret
```

### 2. Twitter/X App

**الخطوات:**
1. اذهب إلى: https://developer.twitter.com/en/portal/dashboard
2. أنشئ Project جديد
3. أنشئ App داخل الـ Project
4. في App Settings → User authentication settings:
   - **Type of App**: Web App
   - **Callback URI**: `http://YOUR_SERVER_IP:5000/integrations/social/twitter/callback`
   - **Website URL**: `http://YOUR_SERVER_IP:5000`
5. احصل على `Client ID` و `Client Secret`
6. أضف في `.env`:
```env
TWITTER_CLIENT_ID=your_client_id
TWITTER_CLIENT_SECRET=your_client_secret
```

### 3. LinkedIn App

**الخطوات:**
1. اذهب إلى: https://www.linkedin.com/developers/apps
2. انقر "Create app"
3. املأ التفاصيل المطلوبة
4. في Auth → OAuth 2.0 settings:
   - **Redirect URLs**: `http://YOUR_SERVER_IP:5000/integrations/social/linkedin/callback`
5. في Products:
   - أضف "Share on LinkedIn"
   - أضف "Sign In with LinkedIn using OpenID Connect"
6. احصل على `Client ID` و `Client Secret`
7. أضف في `.env`:
```env
LINKEDIN_CLIENT_ID=your_client_id
LINKEDIN_CLIENT_SECRET=your_client_secret
```

### 4. TikTok App (اختياري)

**الخطوات:**
1. اذهب إلى: https://developers.tiktok.com
2. سجل كمطور
3. أنشئ App جديد
4. في App Settings:
   - **Redirect URI**: `http://YOUR_SERVER_IP:5000/integrations/social/tiktok/callback`
5. احصل على `Client Key` و `Client Secret`
6. أضف في `.env`:
```env
TIKTOK_CLIENT_KEY=your_client_key
TIKTOK_CLIENT_SECRET=your_client_secret
```

**بعد تحديث `.env`:**
```bash
# إعادة تشغيل Postiz
cd /opt/postiz-app
docker-compose restart
```

---

## 🔗 الجزء الثالث: ربط التطبيق بـ Postiz

### 1. تحديث `.env` في Laravel

```env
# ==================== Postiz Self-Hosted Configuration ====================
# استخدم IP الخادم أو Domain الخاص بـ Postiz
POSTIZ_API_KEY=YOUR_API_KEY_FROM_POSTIZ_DASHBOARD
POSTIZ_BASE_URL=http://YOUR_SERVER_IP:5000/api/v1

# ملاحظة: إذا كان Laravel والـ Postiz على نفس الخادم:
# يمكنك استخدام: http://localhost:5000/api/v1

# ==================== OAuth Apps (نفس البيانات المستخدمة في Postiz) ====================
FACEBOOK_APP_ID=same_as_postiz
FACEBOOK_APP_SECRET=same_as_postiz

TWITTER_CLIENT_ID=same_as_postiz
TWITTER_CLIENT_SECRET=same_as_postiz

LINKEDIN_CLIENT_ID=same_as_postiz
LINKEDIN_CLIENT_SECRET=same_as_postiz

# ==================== Callback URLs ====================
# يجب أن تكون Laravel callback مختلفة عن Postiz callback
APP_URL=https://yourdomain.com
# Laravel OAuth Callback: https://yourdomain.com/api/postiz/oauth-callback
# Postiz OAuth Callback: http://YOUR_SERVER_IP:5000/integrations/social/{platform}/callback
```

### 2. تحديث PostizController

في `app/Http/Controllers/Api/PostizController.php`, حدّث الـ `baseUrl`:

```php
public function __construct()
{
    $this->apiKey = env('POSTIZ_API_KEY');
    // للـ Self-Hosted
    $this->baseUrl = env('POSTIZ_BASE_URL', 'http://YOUR_SERVER_IP:5000/api/v1');
}
```

### 3. طريقة بديلة: استخدام Postiz مباشرة

بما أنك تستخدم Self-Hosted، يمكنك الربط بطريقتين:

**الطريقة A: عبر Postiz API (موصى به)**
- المستخدمون يربطون حساباتهم عبر Postiz UI
- تطبيقك يستخدم Postiz API للنشر
- جميع البيانات مخزنة في Postiz

**الطريقة B: Direct Integration**
- تطبيقك يربط مباشرة مع APIs المنصات
- لا حاجة لـ Postiz API
- تحكم كامل لكن أكثر تعقيداً

**سنستخدم الطريقة A (موصى به)**

---

## 🎨 الجزء الرابع: تكامل Flutter مع Postiz Self-Hosted

### تحديث `lib/core/config/backend_config.dart`

```dart
class BackendConfig {
  // Laravel Backend URL
  static const String baseUrl = 'https://yourdomain.com/api';

  // Postiz Self-Hosted URL (للربط المباشر إذا لزم الأمر)
  static const String postizUrl = 'http://YOUR_SERVER_IP:5000';
  static const String postizApiUrl = 'http://YOUR_SERVER_IP:5000/api/v1';
}
```

### استخدام الـ OAuth Flow

عندما يضغط المستخدم على "ربط حساب":

```dart
// في ConnectAccountsScreen
Future<void> _connectAccount(SocialPlatform platform) async {
  try {
    // الحصول على OAuth URL من Laravel Backend
    final result = await PostizManager().connectSocialAccount(
      platform: platform.name,
      userId: currentUser.id,
    );

    if (result['success'] == true) {
      final url = result['oauth_url'];

      // فتح الرابط في المتصفح الخارجي
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

**Flow الكامل:**
```
1. User clicks "Connect Facebook"
   ↓
2. App calls: Laravel API → /api/postiz/oauth-link
   ↓
3. Laravel generates OAuth URL (Facebook OAuth)
   ↓
4. App opens URL in browser
   ↓
5. User approves on Facebook
   ↓
6. Facebook redirects to: Laravel /api/postiz/oauth-callback
   ↓
7. Laravel exchanges code for token
   ↓
8. Laravel saves account in DB
   ↓
9. Laravel redirects to: mprosocial://oauth-success
   ↓
10. App shows success message
```

---

## 🔒 الجزء الخامس: إعداد HTTPS (للإنتاج)

### استخدام Nginx + Let's Encrypt

```bash
# تنصيب Nginx
sudo apt install -y nginx

# إنشاء config
sudo nano /etc/nginx/sites-available/postiz
```

**محتوى الملف:**
```nginx
server {
    listen 80;
    server_name postiz.yourdomain.com;

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

    client_max_body_size 100M;
}
```

```bash
# تفعيل الموقع
sudo ln -s /etc/nginx/sites-available/postiz /etc/nginx/sites-enabled/

# اختبار
sudo nginx -t

# إعادة تحميل
sudo systemctl reload nginx

# تنصيب SSL
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d postiz.yourdomain.com
```

بعد ذلك حدّث `.env` في Postiz:
```env
NEXT_PUBLIC_BACKEND_URL=https://postiz.yourdomain.com
FRONTEND_URL=https://postiz.yourdomain.com
NEXTAUTH_URL=https://postiz.yourdomain.com
```

---

## 📊 الجزء السادس: إنشاء API Key من Postiz

### في Postiz Dashboard:

1. سجل الدخول إلى: `http://YOUR_SERVER_IP:5000`
2. اذهب إلى: **Settings** → **API Keys**
3. انقر: **Generate New API Key**
4. أدخل اسم: "Laravel Integration"
5. **انسخ الـ API Key** (سيظهر مرة واحدة فقط!)
6. أضفه في Laravel `.env`:
```env
POSTIZ_API_KEY=the_generated_api_key_here
```

---

## 🧪 الجزء السابع: الاختبار الشامل

### اختبار 1: Postiz Dashboard

```bash
# تأكد من تشغيل Postiz
docker-compose ps

# افتح المتصفح
http://YOUR_SERVER_IP:5000
```

يجب أن ترى Dashboard.

### اختبار 2: Laravel API

```bash
# اختبار الاتصال
curl http://your-laravel-domain.com/api/postiz/status
```

يجب أن يرجع:
```json
{"success":true,"message":"API يعمل بشكل صحيح"}
```

### اختبار 3: OAuth في Postiz

1. في Postiz Dashboard
2. اذهب إلى: Integrations
3. اضغط على منصة (مثلاً Facebook)
4. يجب أن يفتح OAuth
5. وافق على الربط
6. يجب أن يظهر الحساب في Integrations

### اختبار 4: النشر من Postiz

1. في Postiz Dashboard
2. أنشئ منشور جديد
3. اختر الحسابات
4. انشر
5. تحقق من ظهوره على المنصة

### اختبار 5: النشر من التطبيق

1. افتح Flutter App
2. اذهب إلى "إنشاء منشور"
3. اكتب محتوى
4. اختر حساب
5. انشر
6. تحقق من ظهوره

---

## 🔧 استكشاف الأخطاء

### مشكلة: Postiz لا يشتغل

```bash
# تحقق من Logs
docker-compose logs backend

# تحقق من Database
docker-compose logs postgres

# إعادة التشغيل
docker-compose restart
```

### مشكلة: OAuth لا يعمل

```bash
# تحقق من Redirect URIs في OAuth Apps
# يجب أن تكون:
# http://YOUR_SERVER_IP:5000/integrations/social/{platform}/callback

# تحقق من .env
cat .env | grep FACEBOOK
cat .env | grep TWITTER
```

### مشكلة: API Key لا يعمل

```bash
# تحقق من API Key في Postiz Dashboard
# Settings → API Keys

# تأكد من نسخه بشكل صحيح في Laravel .env
```

### مشكلة: Database Connection Failed

```bash
# تحقق من Database
docker exec -it postiz-postgres psql -U postiz -d postiz

# إذا لم يعمل، أعد إنشاء Database
docker-compose down -v
docker-compose up -d
docker exec -it postiz-backend npx prisma migrate deploy
```

---

## 📝 قائمة التحقق النهائية

### Postiz Setup
- [ ] Docker و Docker Compose مُنصّبين
- [ ] Postiz مستنسخ في `/opt/postiz-app`
- [ ] `.env` محدّث بجميع المتغيرات
- [ ] Secrets عشوائية تم توليدها
- [ ] `docker-compose up -d` يعمل بنجاح
- [ ] Database migrations مطبّقة
- [ ] Postiz Dashboard يفتح على `http://IP:5000`
- [ ] حساب Admin تم إنشاؤه
- [ ] API Key تم إنشاؤه من Dashboard

### OAuth Apps
- [ ] Facebook App تم إنشاؤه
- [ ] Twitter App تم إنشاؤه
- [ ] LinkedIn App تم إنشاؤه
- [ ] Redirect URIs صحيحة لكل منصة
- [ ] Client IDs & Secrets تم إضافتها في Postiz `.env`
- [ ] Postiz تم إعادة تشغيله بعد التحديث

### Laravel Integration
- [ ] `POSTIZ_API_KEY` تم إضافته في Laravel `.env`
- [ ] `POSTIZ_BASE_URL` صحيح
- [ ] PostizController تم نسخه
- [ ] Routes تم إضافتها
- [ ] Database migrations تم تطبيقها
- [ ] Storage link تم إنشاؤه
- [ ] `/api/postiz/status` يعمل

### Flutter Integration
- [ ] Dependencies تم إضافتها
- [ ] Screens تم نسخها
- [ ] Deep Links تم تكوينها
- [ ] Backend URL صحيح في config

### Testing
- [ ] OAuth يعمل من Postiz Dashboard
- [ ] النشر يعمل من Postiz Dashboard
- [ ] OAuth يعمل من التطبيق
- [ ] النشر يعمل من التطبيق
- [ ] الجدولة تعمل
- [ ] التحليلات تظهر

---

## 🎯 الخلاصة

الآن لديك:

✅ **Postiz Self-Hosted** يعمل على خادمك
✅ **OAuth Apps** جاهزة لجميع المنصات
✅ **Laravel Backend** متصل بـ Postiz
✅ **Flutter App** جاهز للربط والنشر
✅ **لا تكاليف شهرية** - كل شيء مجاني!

**التكلفة الإجمالية:**
- VPS: ~$6/شهر فقط
- كل شيء آخر: مجاني! 🎉

**الوقت المتوقع للإعداد الكامل:** 2-3 ساعات

---

## 📞 الدعم

**Postiz Resources:**
- GitHub: https://github.com/gitroomhq/postiz-app
- Docs: https://docs.postiz.com
- Discord: (متاح من الموقع)

**ملفاتك:**
- `COMPLETE_INTEGRATION_GUIDE.md` - الدليل الشامل
- `READY_TO_RUN_CHECKLIST.md` - قائمة التحقق

---

**🚀 ابدأ الآن وستكون جاهزاً في بضع ساعات!**

**آخر تحديث:** 2025-11-15
**النوع:** Self-Hosted Setup
