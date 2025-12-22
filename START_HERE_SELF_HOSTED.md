# 🎯 ابدأ من هنا - Postiz Self-Hosted

## مرحباً! 👋

أنت تستخدم **Postiz Self-Hosted**، وهذا خيار ممتاز! 🎉

هذا الملف هو دليلك للبدء **الآن مباشرة**.

---

## ⏱️ الوقت المتوقع

- **الإعداد الأساسي:** 30-45 دقيقة
- **OAuth Apps:** 30-45 دقيقة
- **التكامل الكامل:** 1-2 ساعة
- **المجموع:** 2-3 ساعات

---

## 📋 ما تحتاجه

### أساسيات:

✅ **خادم/VPS** (يمكن استخدام جهازك المحلي للتجربة)
- Ubuntu 20.04+ أو مشابه
- 4GB RAM على الأقل
- 20GB مساحة

✅ **Docker & Docker Compose**
- سنقوم بتنصيبهما معاً

✅ **حسابات Developer**
- Facebook Developer Account
- Twitter Developer Account
- LinkedIn Developer Account

✅ **Domain** (اختياري للتطوير، مطلوب للإنتاج)

---

## 🚀 الجزء الأول: تنصيب Postiz (30 دقيقة)

### الخطوة 1: تحضير الخادم (5 دقائق)

```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تنصيب المتطلبات
sudo apt install -y curl git wget vim
```

### الخطوة 2: تنصيب Docker (5 دقائق)

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

# ⚠️ مهم: إعادة تسجيل الدخول
exit
# ثم سجل الدخول مرة أخرى
```

### الخطوة 3: تنزيل Postiz (2 دقيقة)

```bash
# الانتقال إلى /opt
cd /opt

# استنساخ Postiz
sudo git clone https://github.com/gitroomhq/postiz-app.git
cd postiz-app

# منح الصلاحيات
sudo chown -R $USER:$USER /opt/postiz-app
```

### الخطوة 4: إعداد `.env` (10 دقائق)

```bash
# نسخ ملف .env
cp .env.example .env

# تحرير الملف
nano .env
```

**الإعدادات الأساسية المطلوبة:**

```env
# ========== Database ==========
# غيّر PASSWORD بكلمة سر قوية
DATABASE_URL=postgresql://postiz:YOUR_STRONG_PASSWORD@postgres:5432/postiz
DATABASE_DIRECT_URL=postgresql://postiz:YOUR_STRONG_PASSWORD@postgres:5432/postiz

# ========== Redis ==========
REDIS_URL=redis://redis:6379

# ========== Application ==========
NODE_ENV=production

# ⚠️ مهم: غيّر YOUR_SERVER_IP بـ IP الخادم أو localhost للتجربة
NEXT_PUBLIC_BACKEND_URL=http://YOUR_SERVER_IP:5000
FRONTEND_URL=http://YOUR_SERVER_IP:5000
NEXTAUTH_URL=http://YOUR_SERVER_IP:5000

# ========== Secrets ==========
# توليد secrets عشوائية:
# في Terminal: openssl rand -base64 32

# ضع الناتج هنا:
NEXTAUTH_SECRET=PASTE_RANDOM_SECRET_HERE
JWT_SECRET=PASTE_ANOTHER_RANDOM_SECRET_HERE

# ========== Upload ==========
UPLOAD_DIRECTORY=/uploads
NEXT_PUBLIC_UPLOAD_DIRECTORY=/uploads

# ========== OAuth Apps ==========
# سنملؤها لاحقاً في الخطوة التالية
FACEBOOK_CLIENT_ID=
FACEBOOK_CLIENT_SECRET=
FACEBOOK_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/facebook/callback

TWITTER_CLIENT_ID=
TWITTER_CLIENT_SECRET=
TWITTER_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/twitter/callback

LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=
LINKEDIN_REDIRECT_URI=http://YOUR_SERVER_IP:5000/integrations/social/linkedin/callback
```

**توليد Secrets:**
```bash
# في Terminal آخر
openssl rand -base64 32  # NEXTAUTH_SECRET
openssl rand -base64 32  # JWT_SECRET
openssl rand -base64 16  # DATABASE PASSWORD
```

**احفظ الملف:** `Ctrl + X` ثم `Y` ثم `Enter`

### الخطوة 5: تشغيل Postiz (8 دقائق)

```bash
# بناء وتشغيل
docker-compose up -d

# سيأخذ بضع دقائق لأول مرة...
# مراقبة التقدم
docker-compose logs -f
```

انتظر حتى ترى:
```
backend    | Server is running on port 3000
```

اضغط `Ctrl + C` للخروج من Logs.

### الخطوة 6: تطبيق Database Migrations (2 دقيقة)

```bash
# دخول container
docker exec -it postiz-backend sh

# تطبيق migrations
npx prisma migrate deploy

# الخروج
exit
```

### الخطوة 7: اختبار Postiz (1 دقيقة)

افتح المتصفح واذهب إلى:
```
http://YOUR_SERVER_IP:5000
```

أو إذا كنت على نفس الجهاز:
```
http://localhost:5000
```

يجب أن ترى صفحة Postiz! 🎉

**سجل حساب جديد:**
1. انقر "Sign Up"
2. أدخل Email و Password
3. سجل الدخول

---

## 🔑 الجزء الثاني: إنشاء OAuth Apps (45 دقيقة)

الآن يجب إنشاء Apps في كل منصة.

### 1. Facebook App (15 دقيقة)

**الخطوات:**

1. اذهب إلى: https://developers.facebook.com/apps
2. انقر "Create App"
3. اختر "Business" → Next
4. App Name: "My Social Manager" (أو أي اسم)
5. App Contact Email: بريدك
6. انقر "Create App"

**إضافة Facebook Login:**

7. في Dashboard، ابحث عن "Facebook Login" → Set Up
8. اختر "Web"
9. Site URL: `http://YOUR_SERVER_IP:5000`

**إعداد Redirect URI:**

10. من القائمة اليسرى: Facebook Login → Settings
11. في "Valid OAuth Redirect URIs" أضف:
    ```
    http://YOUR_SERVER_IP:5000/integrations/social/facebook/callback
    ```
12. Save Changes

**الحصول على Credentials:**

13. من القائمة اليسرى: Settings → Basic
14. انسخ:
    - **App ID**
    - **App Secret** (اضغط Show)

**إضافتها في Postiz `.env`:**

```bash
cd /opt/postiz-app
nano .env
```

ابحث عن:
```env
FACEBOOK_CLIENT_ID=
FACEBOOK_CLIENT_SECRET=
```

وضع القيم:
```env
FACEBOOK_CLIENT_ID=your_app_id_here
FACEBOOK_CLIENT_SECRET=your_app_secret_here
```

احفظ: `Ctrl + X` → `Y` → `Enter`

### 2. Twitter/X App (15 دقيقة)

**الخطوات:**

1. اذهب إلى: https://developer.twitter.com/en/portal/dashboard
2. إذا لم يكن لديك حساب Developer، سجل واحد (مجاني)
3. انقر "Create Project"
4. Project Name: "Social Media Manager"
5. Use Case: اختر ما يناسبك
6. Project Description: اكتب وصف بسيط

**إنشاء App:**

7. في Project، انقر "Create App"
8. App Name: "MySocialApp" (فريد)
9. انقر "Complete"

**إعداد OAuth:**

10. في App Settings، اذهب إلى "User authentication settings"
11. انقر "Set up"
12. Type of App: "Web App, Automated App or Bot"
13. App Info:
    - Callback URI: `http://YOUR_SERVER_IP:5000/integrations/social/twitter/callback`
    - Website URL: `http://YOUR_SERVER_IP:5000`
14. انقر "Save"

**الحصول على Credentials:**

15. في "Keys and tokens" tab
16. انسخ:
    - **Client ID**
    - **Client Secret**

**إضافتها في Postiz `.env`:**

```bash
nano /opt/postiz-app/.env
```

```env
TWITTER_CLIENT_ID=your_client_id_here
TWITTER_CLIENT_SECRET=your_client_secret_here
```

### 3. LinkedIn App (15 دقيقة)

**الخطوات:**

1. اذهب إلى: https://www.linkedin.com/developers/apps
2. انقر "Create app"
3. App Name: "Social Media Manager"
4. LinkedIn Page: (اختر صفحتك أو أنشئ واحدة)
5. Privacy Policy URL: يمكن وضع أي URL مؤقتاً
6. App Logo: ارفع أي صورة (72x72 px على الأقل)
7. Legal Agreement: وافق
8. انقر "Create app"

**إعداد OAuth:**

9. في App، اذهب إلى "Auth" tab
10. في "OAuth 2.0 settings"
11. Redirect URLs: أضف
    ```
    http://YOUR_SERVER_IP:5000/integrations/social/linkedin/callback
    ```
12. انقر "Update"

**إضافة Products:**

13. اذهب إلى "Products" tab
14. اطلب الوصول لـ:
    - "Share on LinkedIn"
    - "Sign In with LinkedIn using OpenID Connect"
15. انتظر الموافقة (عادة فورية)

**الحصول على Credentials:**

16. في "Auth" tab
17. انسخ:
    - **Client ID**
    - **Client Secret**

**إضافتها في Postiz `.env`:**

```bash
nano /opt/postiz-app/.env
```

```env
LINKEDIN_CLIENT_ID=your_client_id_here
LINKEDIN_CLIENT_SECRET=your_client_secret_here
```

### إعادة تشغيل Postiz

```bash
cd /opt/postiz-app
docker-compose restart
```

انتظر 30 ثانية، ثم تحقق:
```bash
docker-compose ps
```

يجب أن ترى كل الخدمات "Up".

---

## 🔗 الجزء الثالث: اختبار OAuth (10 دقائق)

### اختبار الربط من Postiz

1. افتح Postiz Dashboard: `http://YOUR_SERVER_IP:5000`
2. سجل الدخول
3. اذهب إلى: **Channels** أو **Integrations**
4. اضغط على **Facebook**
5. يجب أن يفتح نافذة OAuth
6. سجل الدخول ووافق
7. يجب أن تُحوّل لـ Postiz ويظهر حسابك مربوط ✅

**كرر نفس الخطوات لـ:**
- Twitter
- LinkedIn

إذا عملت كلها، تهانينا! 🎉

---

## 🎨 الجزء الرابع: إنشاء API Key (2 دقيقة)

### في Postiz Dashboard:

1. سجل الدخول
2. اذهب إلى: **Settings** (الترس أعلى اليمين)
3. في القائمة الجانبية: **API Keys**
4. انقر: **Generate New API Key**
5. Name: "Laravel Integration"
6. انقر **Generate**
7. **⚠️ مهم جداً:** انسخ الـ API Key فوراً (سيظهر مرة واحدة فقط!)
8. احفظه في مكان آمن

---

## 💻 الجزء الخامس: ربط Laravel (20 دقيقة)

### الخطوة 1: تحديث Laravel `.env`

```bash
# في مجلد Laravel
nano .env
```

أضف/حدّث:

```env
# ==================== Postiz Self-Hosted ====================
POSTIZ_API_KEY=API_KEY_FROM_STEP_4
POSTIZ_BASE_URL=http://YOUR_SERVER_IP:5000/api/v1

# إذا كان Laravel والـ Postiz على نفس الخادم:
# POSTIZ_BASE_URL=http://localhost:5000/api/v1

# ==================== OAuth (نفس بيانات Postiz) ====================
FACEBOOK_APP_ID=same_as_postiz
FACEBOOK_APP_SECRET=same_as_postiz

TWITTER_CLIENT_ID=same_as_postiz
TWITTER_CLIENT_SECRET=same_as_postiz

LINKEDIN_CLIENT_ID=same_as_postiz
LINKEDIN_CLIENT_SECRET=same_as_postiz
```

### الخطوة 2: نسخ Controller

```bash
# في مجلد Laravel
cp COMPLETE_POSTIZ_CONTROLLER.php app/Http/Controllers/Api/PostizController.php
```

### الخطوة 3: إضافة Routes

افتح `routes/api.php`:

```bash
nano routes/api.php
```

أضف في الأسفل:

```php
use App\Http\Controllers\Api\PostizController;

Route::middleware('auth:sanctum')->group(function () {
    // Postiz Routes
    Route::post('/postiz/oauth-link', [PostizController::class, 'generateOAuthLink']);
    Route::get('/postiz/integrations', [PostizController::class, 'getIntegrations']);
    Route::delete('/postiz/integrations/{integrationId}', [PostizController::class, 'unlinkIntegration']);

    Route::post('/postiz/posts', [PostizController::class, 'publishPost']);
    Route::get('/postiz/posts', [PostizController::class, 'getPosts']);
    Route::put('/postiz/posts/{postId}', [PostizController::class, 'updatePost']);
    Route::delete('/postiz/posts/{postId}', [PostizController::class, 'deletePost']);

    Route::get('/postiz/analytics/summary', [PostizController::class, 'getAnalyticsSummary']);
    Route::get('/postiz/analytics/post/{postId}', [PostizController::class, 'getPostAnalytics']);
    Route::get('/postiz/analytics/account/{integrationId}', [PostizController::class, 'getAccountAnalytics']);

    Route::post('/postiz/upload', [PostizController::class, 'uploadMedia']);
    Route::post('/postiz/upload-from-url', [PostizController::class, 'uploadMediaFromUrl']);

    Route::get('/postiz/find-slot/{integrationId}', [PostizController::class, 'getNextAvailableSlot']);
    Route::post('/postiz/generate-video', [PostizController::class, 'generateVideo']);
    Route::get('/postiz/status', [PostizController::class, 'checkStatus']);
});

Route::get('/postiz/oauth-callback', [PostizController::class, 'oauthCallback']);
```

### الخطوة 4: تطبيق Database Migrations

```bash
mysql -u root -p your_database < DATABASE_MIGRATIONS.sql
```

أو:
```bash
php artisan migrate
```

### الخطوة 5: Clear Cache

```bash
php artisan config:clear
php artisan route:clear
php artisan cache:clear
```

### الخطوة 6: Storage Link

```bash
php artisan storage:link
```

### الخطوة 7: اختبار

```bash
curl http://your-domain.com/api/postiz/status
```

يجب أن يرجع:
```json
{"success":true,"message":"API يعمل بشكل صحيح"}
```

---

## 📱 الجزء السادس: Flutter Setup (15 دقيقة)

### الخطوة 1: Dependencies

في `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  url_launcher: ^6.2.1
  image_picker: ^1.0.5
  fl_chart: ^0.65.0
```

```bash
flutter pub get
```

### الخطوة 2: Deep Links

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="mprosocial" android:host="oauth-success" />
    <data android:scheme="mprosocial" android:host="oauth-failed" />
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mprosocial</string>
        </array>
    </dict>
</array>
```

### الخطوة 3: Test Run

```bash
flutter run
```

---

## ✅ قائمة التحقق النهائية

- [ ] Postiz يعمل على `http://IP:5000`
- [ ] Facebook OAuth يعمل من Postiz
- [ ] Twitter OAuth يعمل من Postiz
- [ ] LinkedIn OAuth يعمل من Postiz
- [ ] API Key تم إنشاؤه
- [ ] Laravel `.env` محدّث
- [ ] PostizController منسوخ
- [ ] Routes مضافة
- [ ] Database migrations مطبّقة
- [ ] `/api/postiz/status` يرجع success
- [ ] Flutter dependencies مضافة
- [ ] Deep Links مكوّنة

---

## 🎉 تهانينا!

إذا أكملت كل الخطوات، الآن لديك:

✅ Postiz Self-Hosted يعمل
✅ OAuth جاهز لـ 3 منصات
✅ Laravel Backend متصل
✅ Flutter App جاهز

---

## 📚 الخطوات التالية

1. **اختبر النشر** من Postiz Dashboard
2. **اختبر النشر** من Flutter App
3. **أضف المزيد من المنصات** (TikTok, YouTube, إلخ)
4. **فعّل HTTPS** للإنتاج
5. **أعد Cron Jobs** للجدولة

---

## 📖 المراجع

- `SELF_HOSTED_SETUP_COMPLETE.md` - الدليل الكامل
- `SELF_HOSTED_QUICK_REFERENCE.md` - مرجع سريع
- `COMPLETE_INTEGRATION_GUIDE.md` - دليل التكامل الشامل

---

## ❓ مشاكل؟

راجع:
- `SELF_HOSTED_QUICK_REFERENCE.md` - قسم "حل المشاكل"
- Postiz Logs: `docker-compose logs -f`
- Laravel Logs: `storage/logs/laravel.log`

---

**🚀 حظاً موفقاً ومبروك الإنجاز!**

**آخر تحديث:** 2025-11-15
