# 📊 تقرير حالة API Keys - منصات السوشال ميديا

## 🔍 الوضع الحالي

تم فحص السيرفر: `mediaprosocial.io`
التاريخ: **2025-11-16**

### ❌ جميع API Keys غير مُعدة حالياً

```
FACEBOOK_APP_ID: ❌ فارغ
INSTAGRAM_CLIENT_ID: ❌ فارغ
TWITTER_API_KEY: ❌ فارغ
LINKEDIN_CLIENT_ID: ❌ فارغ
YOUTUBE_CLIENT_ID: ❌ فارغ
TIKTOK_APP_ID: ❌ فارغ (placeholder)
SNAPCHAT_CLIENT_ID: ❌ فارغ (placeholder)
```

---

## 📝 الملفات التي تم إنشاؤها

### 1. **SOCIAL_MEDIA_API_GUIDE.md** - الدليل الشامل
- ✅ شرح تفصيلي لكل منصة
- ✅ خطوات الحصول على API Keys
- ✅ Screenshots و URLs
- ✅ Permissions المطلوبة
- ✅ Mobile configuration

### 2. **QUICK_API_SETUP.md** - الدليل السريع
- ✅ خطوات مختصرة (5-15 دقيقة لكل منصة)
- ✅ روابط مباشرة
- ✅ Checklist جاهز
- ✅ ملف .env كامل للنسخ

### 3. **test_api_keys.sh** - سكريبت الاختبار
- ✅ فحص سريع لجميع المتغيرات
- ✅ تقرير بنسبة الاكتمال

---

## 🎯 خطة العمل

### المرحلة 1: الإعداد الأساسي (30-45 دقيقة)

#### أولوية عالية ⭐⭐⭐
1. **Facebook** (5 دقائق)
   - [ ] https://developers.facebook.com
   - [ ] Create App
   - [ ] نسخ App ID & Secret
   - [ ] إعداد OAuth redirect

2. **Instagram** (3 دقائق)
   - [ ] استخدام نفس Facebook App
   - [ ] إضافة Instagram Basic Display
   - [ ] نسخ Credentials

3. **Twitter** (10 دقائق)
   - [ ] https://developer.twitter.com
   - [ ] Apply for developer account
   - [ ] Create project & app
   - [ ] نسخ جميع Keys (5 متغيرات)

4. **LinkedIn** (5 دقائق)
   - [ ] https://www.linkedin.com/developers
   - [ ] إنشاء LinkedIn Page أولاً
   - [ ] Create app
   - [ ] نسخ Client ID & Secret

5. **YouTube** (7 دقائق)
   - [ ] https://console.cloud.google.com
   - [ ] Create project
   - [ ] Enable YouTube Data API
   - [ ] OAuth credentials

### المرحلة 2: المنصات المتقدمة (تحتاج مراجعة)

#### أولوية متوسطة ⭐⭐
6. **TikTok** (15 دقيقة + 7-14 يوم مراجعة)
   - [ ] https://developers.tiktok.com
   - [ ] التسجيل كمطور
   - [ ] Create app
   - [ ] Submit for review

#### أولوية منخفضة ⭐
7. **Snapchat** (15 دقيقة + 2-4 أسابيع مراجعة)
   - [ ] https://kit.snapchat.com
   - [ ] Create app
   - [ ] Enable Login Kit
   - [ ] Submit for production
   - ⚠️ **محدود جداً - قد لا يكون مفيداً**

---

## 🚀 البدء السريع

### الخطوة 1: افتح الأدلة
```
1. افتح QUICK_API_SETUP.md
2. اتبع الخطوات لكل منصة
3. انسخ كل API Key في مكانه
```

### الخطوة 2: تحديث .env على السيرفر

```bash
# الاتصال بالسيرفر
ssh u126213189@82.25.83.217 -p 65002

# تعديل .env
cd /home/u126213189/domains/mediaprosocial.io/public_html
nano .env

# ابحث عن القسم:
# FACEBOOK_APP_ID=
# INSTAGRAM_CLIENT_ID=
# ...الخ

# الصق API Keys الجديدة

# احفظ (Ctrl+O, Enter, Ctrl+X)

# تنظيف الكاش
php artisan config:clear
php artisan cache:clear
```

### الخطوة 3: الاختبار

```bash
# اختبار Facebook OAuth
curl -X GET "https://mediaprosocial.io/api/auth/facebook/redirect?user_id=1"

# يجب أن يرجع:
# {"success":true,"platform":"facebook","redirect_url":"https://..."}
```

---

## 📋 Template ملف .env

نسخ هذا في `/home/u126213189/domains/mediaprosocial.io/public_html/.env`:

```env
# ==================================
# SOCIAL MEDIA API KEYS
# ==================================

# FACEBOOK
FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback

# INSTAGRAM
INSTAGRAM_CLIENT_ID=
INSTAGRAM_CLIENT_SECRET=

# TWITTER
TWITTER_API_KEY=
TWITTER_API_SECRET=
TWITTER_BEARER_TOKEN=
TWITTER_CLIENT_ID=
TWITTER_CLIENT_SECRET=

# LINKEDIN
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=

# YOUTUBE / GOOGLE
YOUTUBE_CLIENT_ID=
YOUTUBE_CLIENT_SECRET=
YOUTUBE_REDIRECT_URI=https://mediaprosocial.io/api/auth/youtube/callback

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=https://mediaprosocial.io/api/oauth/callback/google

# TIKTOK
TIKTOK_APP_ID=your_tiktok_app_id
TIKTOK_APP_SECRET=your_tiktok_app_secret

# SNAPCHAT
SNAPCHAT_CLIENT_ID=your_snapchat_client_id
SNAPCHAT_CLIENT_SECRET=your_snapchat_client_secret
```

---

## 🎓 المتطلبات الأساسية

### قبل البدء، تأكد من توفر:

1. **Privacy Policy** على الموقع
   - URL: `https://mediaprosocial.io/privacy-policy`
   - مطلوب لكل منصة

2. **Terms of Service**
   - URL: `https://mediaprosocial.io/terms-of-service`
   - مطلوب لبعض المنصات

3. **Data Deletion Instructions**
   - URL: `https://mediaprosocial.io/data-deletion`
   - مطلوب لـ Facebook/Instagram

4. **حسابات على كل منصة**
   - Facebook account
   - Instagram account
   - Twitter account
   - LinkedIn account (+ LinkedIn Page)
   - Google account
   - TikTok account (اختياري)
   - Snapchat account (اختياري)

---

## ⏱️ الوقت المتوقع

| المنصة | الوقت | الصعوبة | الأولوية |
|--------|------|---------|----------|
| Facebook | 5 دقائق | ⭐ سهل | ⭐⭐⭐ عالية |
| Instagram | 3 دقائق | ⭐ سهل | ⭐⭐⭐ عالية |
| Twitter | 10 دقائق | ⭐⭐ متوسط | ⭐⭐⭐ عالية |
| LinkedIn | 5 دقائق | ⭐ سهل | ⭐⭐⭐ عالية |
| YouTube | 7 دقائق | ⭐⭐ متوسط | ⭐⭐⭐ عالية |
| TikTok | 15 دقائق + مراجعة | ⭐⭐⭐ صعب | ⭐⭐ متوسطة |
| Snapchat | 15 دقائق + مراجعة | ⭐⭐⭐ صعب | ⭐ منخفضة |

**الوقت الإجمالي للمنصات الأساسية:** 30 دقيقة

---

## 🎯 التوصيات

### ابدأ بهذا الترتيب:
1. ✅ **Facebook** - أكثر منصة شعبية
2. ✅ **Instagram** - سهل (نفس Facebook app)
3. ✅ **Twitter** - منصة مهمة
4. ✅ **LinkedIn** - للمحتوى المهني
5. ✅ **YouTube** - للفيديوهات
6. ⏳ **TikTok** - اختياري (يحتاج مراجعة)
7. ⏳ **Snapchat** - اختياري (محدود جداً)

### يمكنك تأجيل:
- TikTok - حتى تكون جاهزاً للانتظار أسبوعين
- Snapchat - إذا لم يكن ضرورياً (محدود للمطورين)

---

## 📞 الدعم

### إذا واجهت مشاكل:

#### مشاكل عامة:
- راجع `SOCIAL_MEDIA_API_GUIDE.md` للتفاصيل الكاملة
- راجع `QUICK_API_SETUP.md` للخطوات السريعة

#### مشاكل تقنية:
- تأكد من HTTPS على mediaprosocial.io
- تأكد من Redirect URIs صحيحة
- تحقق من Domain verification
- راجع Laravel logs: `/home/u126213189/domains/mediaprosocial.io/public_html/storage/logs/laravel.log`

#### مشاكل الأذونات:
- اذهب لـ App Review في كل منصة
- اطلب Permissions المطلوبة
- قد تحتاج إثبات استخدامك للـ API

---

## ✅ Checklist النهائي

### بعد إعداد كل منصة:

- [ ] API Keys مضافة في .env
- [ ] `php artisan config:clear` executed
- [ ] Redirect URIs configured
- [ ] Permissions requested
- [ ] OAuth tested (curl command)
- [ ] Mobile app updated (Android/iOS)
- [ ] Error handling tested
- [ ] Documentation reviewed

---

## 🎉 الخطوات التالية

بعد إعداد API Keys:

1. ✅ اختبار OAuth flow على كل منصة
2. ✅ تحديث Mobile apps (Android/iOS)
3. ✅ اختبار النشر على كل منصة
4. ✅ مراقبة Rate limits
5. ✅ إعداد Webhooks (للتحديثات الفورية)

---

**📌 ملاحظة مهمة:**
- احتفظ بنسخة احتياطية من جميع API Keys
- لا تشارك API Secrets مع أي شخص
- راجع الـ Quotas والـ Limits على كل منصة
- بعض المنصات تحتاج تجديد Tokens بشكل دوري

---

**آخر تحديث:** 2025-11-16
**الحالة:** ⚠️ API Keys غير مُعدة - يجب البدء بالإعداد
**الأولوية:** 🔴 عالية جداً
