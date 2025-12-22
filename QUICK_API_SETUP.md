# ⚡ دليل سريع - API Keys لجميع المنصات

## 🎯 خطوات سريعة لكل منصة

### 1️⃣ Facebook (5 دقائق)
```
1. https://developers.facebook.com → Create App
2. Settings → Basic → نسخ App ID & App Secret
3. Add Product → Facebook Login
4. Valid OAuth Redirect: https://mediaprosocial.io/api/auth/facebook/callback
5. App Review → طلب: pages_manage_posts, pages_read_engagement
```

**المتغيرات:**
```env
FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback
```

---

### 2️⃣ Instagram (3 دقائق)
```
1. استخدم نفس Facebook App
2. Add Product → Instagram Basic Display
3. Create New App
4. Redirect URI: https://mediaprosocial.io/api/auth/instagram/callback
5. نسخ Instagram App ID & Secret
```

**المتغيرات:**
```env
INSTAGRAM_CLIENT_ID=
INSTAGRAM_CLIENT_SECRET=
```

---

### 3️⃣ Twitter/X (10 دقائق)
```
1. https://developer.twitter.com → Apply for developer account
2. Create Project → Create App
3. Keys → نسخ API Key, API Secret, Bearer Token
4. User authentication settings → Enable OAuth 2.0
5. Callback URI: https://mediaprosocial.io/api/auth/twitter/callback
6. نسخ Client ID & Client Secret
```

**المتغيرات:**
```env
TWITTER_API_KEY=
TWITTER_API_SECRET=
TWITTER_BEARER_TOKEN=
TWITTER_CLIENT_ID=
TWITTER_CLIENT_SECRET=
```

---

### 4️⃣ LinkedIn (5 دقائق)
```
1. https://www.linkedin.com/developers → Create app
2. أنشئ LinkedIn Page أولاً
3. Auth → نسخ Client ID & Client Secret
4. OAuth 2.0 → Redirect URL: https://mediaprosocial.io/api/auth/linkedin/callback
5. Products → طلب: Share on LinkedIn
```

**المتغيرات:**
```env
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=
```

---

### 5️⃣ YouTube (7 دقائق)
```
1. https://console.cloud.google.com → Create Project
2. Enable APIs → YouTube Data API v3
3. Credentials → Create OAuth client ID
4. Configure consent screen → External
5. Authorized redirect URIs: https://mediaprosocial.io/api/auth/youtube/callback
6. نسخ Client ID & Client Secret
```

**المتغيرات:**
```env
YOUTUBE_CLIENT_ID=
YOUTUBE_CLIENT_SECRET=
YOUTUBE_REDIRECT_URI=https://mediaprosocial.io/api/auth/youtube/callback
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=https://mediaprosocial.io/api/oauth/callback/google
```

---

### 6️⃣ TikTok (15+ دقيقة + مراجعة)
```
1. https://developers.tiktok.com → Register
2. My apps → Create an app
3. نسخ Client Key & Client Secret
4. Login Kit → Redirect URI: https://mediaprosocial.io/api/auth/tiktok/callback
5. Request permissions → user.info.basic, video.list
6. Submit for review (7-14 يوم)
```

**المتغيرات:**
```env
TIKTOK_APP_ID=
TIKTOK_APP_SECRET=
```

⚠️ **يحتاج مراجعة من TikTok**

---

### 7️⃣ Snapchat (15+ دقيقة + مراجعة)
```
1. https://kit.snapchat.com → Get Started
2. Create App
3. OAuth Settings → نسخ Client ID & Client Secret
4. Redirect URIs: https://mediaprosocial.io/api/auth/snapchat/callback
5. Enable Login Kit
6. Submit for Production (2-4 أسابيع)
```

**المتغيرات:**
```env
SNAPCHAT_CLIENT_ID=
SNAPCHAT_CLIENT_SECRET=
```

⚠️ **محدود جداً - يحتاج Business Account**

---

## 📋 ملف .env الكامل

انسخ هذا في: `/home/u126213189/domains/mediaprosocial.io/public_html/.env`

```env
# ======================
# FACEBOOK
# ======================
FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback

# ======================
# INSTAGRAM
# ======================
INSTAGRAM_CLIENT_ID=
INSTAGRAM_CLIENT_SECRET=

# ======================
# TWITTER
# ======================
TWITTER_API_KEY=
TWITTER_API_SECRET=
TWITTER_BEARER_TOKEN=
TWITTER_CLIENT_ID=
TWITTER_CLIENT_SECRET=

# ======================
# LINKEDIN
# ======================
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=

# ======================
# YOUTUBE / GOOGLE
# ======================
YOUTUBE_CLIENT_ID=
YOUTUBE_CLIENT_SECRET=
YOUTUBE_REDIRECT_URI=https://mediaprosocial.io/api/auth/youtube/callback

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=https://mediaprosocial.io/api/oauth/callback/google

# ======================
# TIKTOK
# ======================
TIKTOK_APP_ID=
TIKTOK_APP_SECRET=

# ======================
# SNAPCHAT
# ======================
SNAPCHAT_CLIENT_ID=
SNAPCHAT_CLIENT_SECRET=
```

---

## 🔗 روابط سريعة

| المنصة | Developer Portal | وقت الإعداد | الصعوبة |
|--------|-----------------|-------------|---------|
| **Facebook** | [developers.facebook.com](https://developers.facebook.com) | 5 دقائق | ⭐ سهل |
| **Instagram** | [نفس Facebook](https://developers.facebook.com) | 3 دقائق | ⭐ سهل |
| **Twitter** | [developer.twitter.com](https://developer.twitter.com) | 10 دقائق | ⭐⭐ متوسط |
| **LinkedIn** | [linkedin.com/developers](https://www.linkedin.com/developers) | 5 دقائق | ⭐ سهل |
| **YouTube** | [console.cloud.google.com](https://console.cloud.google.com) | 7 دقائق | ⭐⭐ متوسط |
| **TikTok** | [developers.tiktok.com](https://developers.tiktok.com) | 15+ دقيقة | ⭐⭐⭐ صعب |
| **Snapchat** | [kit.snapchat.com](https://kit.snapchat.com) | 15+ دقيقة | ⭐⭐⭐ صعب |

---

## ⚡ أولويات التنفيذ

### المرحلة 1 (يمكن إعدادها الآن - 30 دقيقة):
1. ✅ Facebook
2. ✅ Instagram
3. ✅ LinkedIn
4. ✅ Twitter
5. ✅ YouTube

### المرحلة 2 (تحتاج مراجعة - أسابيع):
6. ⏳ TikTok (7-14 يوم مراجعة)
7. ⏳ Snapchat (2-4 أسابيع مراجعة)

---

## 🧪 اختبار بعد الإعداد

```bash
# على السيرفر
cd /home/u126213189/domains/mediaprosocial.io/public_html

# تحديث .env
nano .env
# الصق جميع API keys

# تنظيف الكاش
php artisan config:clear
php artisan cache:clear

# اختبار
curl https://mediaprosocial.io/api/auth/facebook/redirect?user_id=1
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "platform": "facebook",
  "redirect_url": "https://www.facebook.com/v18.0/dialog/oauth?..."
}
```

---

## 📱 Mobile Configuration

### Android (`android/app/src/main/res/values/strings.xml`):
```xml
<string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
<string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
```

### iOS (`ios/Runner/Info.plist`):
```xml
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR_FACEBOOK_APP_ID</string>
    </array>
  </dict>
</array>
```

---

## ✅ Checklist النهائي

**قبل البدء:**
- [ ] حساب مطور على كل منصة
- [ ] Privacy Policy URL جاهز
- [ ] Terms of Service URL جاهز
- [ ] Domain: mediaprosocial.io يعمل

**بعد الإعداد:**
- [ ] جميع API Keys في .env
- [ ] php artisan config:clear
- [ ] اختبار OAuth على كل منصة
- [ ] Mobile deep links configured
- [ ] Error handling tested

---

## 🆘 مشاكل شائعة

### "Invalid redirect_uri"
✅ **الحل:** تأكد أن الـ URL مطابق تماماً في Developer Console

### "App not approved"
✅ **الحل:** بعض المنصات (TikTok, Snapchat) تحتاج مراجعة - انتظر الموافقة

### "Missing permissions"
✅ **الحل:** اذهب لـ App Review واطلب الـ Scopes المطلوبة

### "CORS error"
✅ **الحل:** أضف mediaprosocial.io في App Domains على كل منصة

---

**آخر تحديث:** 2025-11-16
**الوقت الكلي المتوقع:** 45-60 دقيقة (بدون TikTok/Snapchat)
