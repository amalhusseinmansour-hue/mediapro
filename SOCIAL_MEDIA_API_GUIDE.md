# 🔑 دليل API Keys لجميع منصات السوشال ميديا

## 📋 جدول المحتويات
1. [Facebook](#1-facebook)
2. [Instagram](#2-instagram)
3. [Twitter (X)](#3-twitter-x)
4. [LinkedIn](#4-linkedin)
5. [YouTube](#5-youtube)
6. [TikTok](#6-tiktok)
7. [Snapchat](#7-snapchat)
8. [ملخص جميع المتغيرات](#-ملخص-جميع-المتغيرات-المطلوبة)

---

## 1. Facebook

### 📍 الحصول على API Keys:

**الخطوة 1: إنشاء Facebook App**
1. اذهب إلى: https://developers.facebook.com
2. اضغط على **"My Apps"** → **"Create App"**
3. اختر نوع التطبيق: **"Business"** أو **"Consumer"**
4. املأ التفاصيل:
   - **App Name**: Media Pro Social Manager
   - **Contact Email**: بريدك الإلكتروني
   - **Business Account**: حسابك (إن وجد)

**الخطوة 2: الحصول على Credentials**
1. من Dashboard، اذهب إلى **Settings** → **Basic**
2. انسخ:
   - **App ID** → `FACEBOOK_APP_ID`
   - **App Secret** (اضغط Show) → `FACEBOOK_APP_SECRET`

**الخطوة 3: تكوين OAuth Redirect**
1. اذهب إلى **Settings** → **Basic**
2. في **App Domains** أضف: `mediaprosocial.io`
3. في **Privacy Policy URL**: أضف رابط سياسة الخصوصية

**الخطوة 4: إضافة Facebook Login**
1. من Dashboard، اضغط **Add Product** → **Facebook Login**
2. في **Valid OAuth Redirect URIs** أضف:
   ```
   https://mediaprosocial.io/api/auth/facebook/callback
   ```
3. في **Client OAuth Settings**:
   - ✅ **Use Strict Mode for Redirect URIs**
   - ✅ **Enforce HTTPS**

**الخطوة 5: طلب Permissions**
1. اذهب إلى **App Review** → **Permissions and Features**
2. اطلب الأذونات التالية:
   - ✅ `pages_manage_posts` - لنشر المحتوى
   - ✅ `pages_read_engagement` - لقراءة التفاعل
   - ✅ `public_profile` - معلومات الملف الشخصي

**الخطوة 6: نشر التطبيق (Production)**
1. اذهب إلى **Settings** → **Basic**
2. غير **App Mode** من Development إلى **Live**

### 🔧 المتغيرات المطلوبة:
```env
FACEBOOK_APP_ID=xxxxxxxxxxxxxxxxx
FACEBOOK_APP_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback
```

### 📱 Mobile Configuration:

**Android** (`android/app/src/main/res/values/strings.xml`):
```xml
<string name="facebook_app_id">xxxxxxxxxxxxxxxxx</string>
<string name="fb_login_protocol_scheme">fbxxxxxxxxxxxxxxxxx</string>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbxxxxxxxxxxxxxxxxx</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>xxxxxxxxxxxxxxxxx</string>
```

---

## 2. Instagram

### 📍 الحصول على API Keys:

⚠️ **ملاحظة مهمة**: Instagram API يستخدم نفس Facebook App!

**الخطوة 1: استخدام نفس Facebook App**
- Instagram Basic Display API يحتاج Facebook App
- استخدم نفس `FACEBOOK_APP_ID` و `FACEBOOK_APP_SECRET`

**الخطوة 2: إضافة Instagram Product**
1. من Facebook App Dashboard
2. اضغط **Add Product** → **Instagram Basic Display**
3. اضغط **Create New App**
4. املأ التفاصيل:
   - **Display Name**: Media Pro
   - **Privacy Policy URL**: رابط سياسة الخصوصية
   - **User Data Deletion**: رابط حذف البيانات

**الخطوة 3: تكوين OAuth**
1. في Instagram Basic Display Settings
2. في **Valid OAuth Redirect URIs** أضف:
   ```
   https://mediaprosocial.io/api/auth/instagram/callback
   ```
3. في **Deauthorize Callback URL**: نفس URL السابق
4. في **Data Deletion Request URL**: نفس URL السابق

**الخطوة 4: Add Instagram Tester**
1. اذهب إلى **Roles** → **Instagram Testers**
2. أضف حسابك على Instagram
3. افتح Instagram → Settings → Apps and Websites
4. اقبل طلب Instagram Tester

**الخطوة 5: الحصول على Credentials**
1. من Instagram Basic Display Settings
2. انسخ:
   - **Instagram App ID** → `INSTAGRAM_CLIENT_ID`
   - **Instagram App Secret** → `INSTAGRAM_CLIENT_SECRET`

### 🔧 المتغيرات المطلوبة:
```env
INSTAGRAM_CLIENT_ID=xxxxxxxxxxxxxxxxx
INSTAGRAM_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 📊 Permissions المطلوبة:
- ✅ `user_profile` - معلومات الملف الشخصي
- ✅ `user_media` - الوصول للصور والفيديوهات

---

## 3. Twitter (X)

### 📍 الحصول على API Keys:

**الخطوة 1: إنشاء Twitter Developer Account**
1. اذهب إلى: https://developer.twitter.com
2. اضغط **Sign up** → **Apply for a developer account**
3. اختر **Purpose**: Building tools for Twitter users
4. املأ الاستبيان:
   - ما هو استخدامك للـ API؟
   - كيف ستستخدم بيانات Twitter؟
5. اقبل الشروط

**الخطوة 2: إنشاء Project & App**
1. من Dashboard، اضغط **Create Project**
2. املأ التفاصيل:
   - **Project Name**: Media Pro Social
   - **Use Case**: Making a bot
   - **Description**: Social media management tool
3. اضغط **Create App**:
   - **App Name**: MediaProApp

**الخطوة 3: الحصول على API Keys**
1. بعد إنشاء App، ستظهر لك:
   - **API Key** → `TWITTER_API_KEY`
   - **API Secret Key** → `TWITTER_API_SECRET`
   - **Bearer Token** → `TWITTER_BEARER_TOKEN`
2. ⚠️ **احفظها فوراً! لن تظهر مرة أخرى**

**الخطوة 4: Enable OAuth 2.0**
1. اذهب إلى **User authentication settings**
2. اضغط **Set up**
3. اختر:
   - ✅ **OAuth 2.0**
   - ✅ **OAuth 1.0a**
4. في **Type of App**: Web App
5. في **App info**:
   - **Callback URI**: `https://mediaprosocial.io/api/auth/twitter/callback`
   - **Website URL**: `https://mediaprosocial.io`
6. احفظ واحصل على:
   - **Client ID** → `TWITTER_CLIENT_ID`
   - **Client Secret** → `TWITTER_CLIENT_SECRET`

**الخطوة 5: طلب Elevated Access (اختياري)**
1. من Project Settings → **Access**
2. اطلب **Elevated** access للحصول على:
   - إمكانية نشر تغريدات
   - قراءة التفاعلات
   - Webhooks

### 🔧 المتغيرات المطلوبة:
```env
TWITTER_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxx
TWITTER_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWITTER_BEARER_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWITTER_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWITTER_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 📊 Scopes المطلوبة:
- ✅ `tweet.read` - قراءة التغريدات
- ✅ `tweet.write` - كتابة تغريدات
- ✅ `users.read` - قراءة معلومات المستخدم
- ✅ `offline.access` - Refresh token

---

## 4. LinkedIn

### 📍 الحصول على API Keys:

**الخطوة 1: إنشاء LinkedIn App**
1. اذهب إلى: https://www.linkedin.com/developers
2. اضغط **Create app**
3. املأ التفاصيل:
   - **App name**: Media Pro Social Manager
   - **LinkedIn Page**: أنشئ صفحة شركة أولاً
   - **Privacy policy URL**: رابط سياسة الخصوصية
   - **App logo**: شعار التطبيق (مقاس 100x100)
4. اقبل **Legal Agreement**

**الخطوة 2: الحصول على Credentials**
1. من App Settings → **Auth**
2. انسخ:
   - **Client ID** → `LINKEDIN_CLIENT_ID`
   - **Client Secret** (اضغط Show) → `LINKEDIN_CLIENT_SECRET`

**الخطوة 3: تكوين OAuth Redirect**
1. في **OAuth 2.0 settings**
2. في **Redirect URLs** أضف:
   ```
   https://mediaprosocial.io/api/auth/linkedin/callback
   ```

**الخطوة 4: طلب Products & Permissions**
1. اذهب إلى **Products**
2. اطلب:
   - ✅ **Share on LinkedIn** - للنشر
   - ✅ **Sign In with LinkedIn** - للمصادقة
3. اذهب إلى **Settings** → **App settings**
4. تحقق من **OAuth 2.0 scopes**:
   - ✅ `w_member_social` - النشر نيابة عن المستخدم
   - ✅ `r_basicprofile` - قراءة الملف الشخصي
   - ✅ `r_emailaddress` - قراءة البريد الإلكتروني

**الخطوة 5: Verify App**
1. قد تحتاج لإثبات ملكية Domain
2. اذهب إلى **Settings** → **Verification**
3. اتبع الخطوات لإثبات `mediaprosocial.io`

### 🔧 المتغيرات المطلوبة:
```env
LINKEDIN_CLIENT_ID=xxxxxxxxxxxxxx
LINKEDIN_CLIENT_SECRET=xxxxxxxxxxxxxxxx
```

### 📊 Scopes المطلوبة:
- ✅ `w_member_social` - النشر على LinkedIn
- ✅ `r_basicprofile` - قراءة المعلومات الأساسية

---

## 5. YouTube

### 📍 الحصول على API Keys:

**الخطوة 1: إنشاء Google Cloud Project**
1. اذهب إلى: https://console.cloud.google.com
2. اضغط **Create Project**
3. املأ التفاصيل:
   - **Project name**: Media Pro Social
   - **Organization**: (اختياري)
4. اضغط **Create**

**الخطوة 2: تفعيل YouTube Data API**
1. من Project Dashboard
2. اضغط **Enable APIs and Services**
3. ابحث عن **YouTube Data API v3**
4. اضغط **Enable**

**الخطوة 3: إنشاء OAuth Credentials**
1. اذهب إلى **APIs & Services** → **Credentials**
2. اضغط **Create Credentials** → **OAuth client ID**
3. إذا كانت أول مرة، ستحتاج **Configure consent screen**:
   - **User Type**: External
   - **App name**: Media Pro Social Manager
   - **User support email**: بريدك
   - **Developer contact**: بريدك
   - في **Scopes**، أضف:
     - `https://www.googleapis.com/auth/youtube.upload`
     - `https://www.googleapis.com/auth/youtube.readonly`
4. بعد تكوين Consent Screen، ارجع لـ **Create OAuth client ID**:
   - **Application type**: Web application
   - **Name**: Media Pro Web Client
   - **Authorized redirect URIs**:
     ```
     https://mediaprosocial.io/api/auth/youtube/callback
     ```
5. احفظ:
   - **Client ID** → `YOUTUBE_CLIENT_ID`
   - **Client Secret** → `YOUTUBE_CLIENT_SECRET`

**الخطوة 4: إضافة Test Users (Development)**
1. اذهب إلى **OAuth consent screen**
2. في **Test users** أضف حسابات Gmail للاختبار
3. فقط هذه الحسابات يمكنها تسجيل الدخول قبل النشر

**الخطوة 5: Publish App (للإنتاج)**
1. عندما تكون جاهزاً للنشر
2. اذهب إلى **OAuth consent screen**
3. اضغط **Publish App**
4. قد تحتاج **Verification** من Google (يستغرق أسابيع)

### 🔧 المتغيرات المطلوبة:
```env
YOUTUBE_CLIENT_ID=xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
YOUTUBE_CLIENT_SECRET=xxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx
YOUTUBE_REDIRECT_URI=https://mediaprosocial.io/api/auth/youtube/callback
```

### 🔑 يمكنك أيضاً استخدام نفس Google Client:
```env
GOOGLE_CLIENT_ID=xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx
GOOGLE_REDIRECT_URI=https://mediaprosocial.io/api/oauth/callback/google
```

### 📊 Scopes المطلوبة:
- ✅ `https://www.googleapis.com/auth/youtube.upload` - رفع فيديوهات
- ✅ `https://www.googleapis.com/auth/youtube.readonly` - قراءة البيانات
- ✅ `https://www.googleapis.com/auth/youtube.force-ssl` - الوصول الكامل

---

## 6. TikTok

### 📍 الحصول على API Keys:

**الخطوة 1: التسجيل في TikTok for Developers**
1. اذهب إلى: https://developers.tiktok.com
2. اضغط **Register**
3. سجل الدخول بحساب TikTok الخاص بك
4. املأ معلومات المطور:
   - **Full Name**: اسمك
   - **Email**: بريدك الإلكتروني
   - **Country/Region**: بلدك

**الخطوة 2: إنشاء TikTok App**
1. من Dashboard، اضغط **My apps** → **Create an app**
2. املأ التفاصيل:
   - **App name**: Media Pro Social Manager
   - **Company name**: اسم شركتك
   - **Category**: Social Media Management
   - **Description**: وصف تطبيقك

**الخطوة 3: الحصول على Credentials**
1. بعد إنشاء App، اذهب إلى **Basic Information**
2. انسخ:
   - **Client Key** → `TIKTOK_APP_ID`
   - **Client Secret** → `TIKTOK_APP_SECRET`

**الخطوة 4: تكوين Login Kit**
1. اذهب إلى **Login Kit** → **Settings**
2. في **Redirect URI** أضف:
   ```
   https://mediaprosocial.io/api/auth/tiktok/callback
   ```

**الخطوة 5: طلب Permissions**
1. في **Login Kit** → **Request additional permissions**
2. اطلب:
   - ✅ `user.info.basic` - معلومات المستخدم الأساسية
   - ✅ `video.list` - قراءة قائمة الفيديوهات
   - ✅ `video.upload` - رفع فيديوهات (يحتاج موافقة)

**الخطوة 6: Submit for Review**
1. TikTok API يتطلب مراجعة لمعظم الميزات
2. اذهب إلى **Submit for review**
3. قدم شرح مفصل عن استخدامك للـ API
4. قد يستغرق 7-14 يوم للموافقة

### 🔧 المتغيرات المطلوبة:
```env
TIKTOK_APP_ID=xxxxxxxxxxxxxxxx
TIKTOK_APP_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 📊 Scopes المطلوبة:
- ✅ `user.info.basic` - معلومات المستخدم
- ✅ `video.list` - قائمة الفيديوهات
- ⚠️ `video.upload` - يحتاج موافقة خاصة

### ⚠️ تحذير:
- TikTok API محدودة جداً للمطورين الجدد
- قد تحتاج Business Account
- بعض الميزات تتطلب موافقة من TikTok

---

## 7. Snapchat

### 📍 الحصول على API Keys:

**الخطوة 1: التسجيل في Snap Kit**
1. اذهب إلى: https://kit.snapchat.com
2. اضغط **Get Started**
3. سجل بحساب Snapchat الخاص بك

**الخطوة 2: إنشاء Snap App**
1. من Dashboard، اضغط **Create App**
2. املأ التفاصيل:
   - **App Name**: Media Pro Social Manager
   - **Description**: Social media management platform
   - **Category**: Social Networking
   - **Organization**: اسم شركتك

**الخطوة 3: الحصول على OAuth Credentials**
1. من App Dashboard، اذهب إلى **OAuth Settings**
2. انسخ:
   - **Client ID** → `SNAPCHAT_CLIENT_ID`
   - **Client Secret** → `SNAPCHAT_CLIENT_SECRET`

**الخطوة 4: تكوين Redirect URIs**
1. في **OAuth Settings** → **Redirect URIs**
2. أضف:
   ```
   https://mediaprosocial.io/api/auth/snapchat/callback
   ```

**الخطوة 5: Enable Snap Kit Components**
1. اذهب إلى **Kits**
2. فعّل:
   - ✅ **Login Kit** - للمصادقة
   - ✅ **Creative Kit** - للمشاركة (إن كنت تحتاجها)

**الخطوة 6: طلب Scopes**
1. في **OAuth Settings** → **Scopes**
2. طلب:
   - ✅ `https://auth.snapchat.com/oauth2/api/user.display_name`
   - ✅ `https://auth.snapchat.com/oauth2/api/user.bitmoji.avatar`

**الخطوة 7: Submit for Production**
1. عند الانتهاء من التطوير
2. اضغط **Submit for Review**
3. قدم:
   - Demo video
   - App screenshots
   - Privacy Policy
   - شرح استخدام البيانات
4. المراجعة قد تستغرق 2-4 أسابيع

### 🔧 المتغيرات المطلوبة:
```env
SNAPCHAT_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
SNAPCHAT_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 📊 Scopes المطلوبة:
- ✅ `snapchat-marketing-api` - Snapchat Marketing API
- ✅ User display name and avatar

### ⚠️ ملاحظات مهمة:
- Snapchat API محدودة للغاية
- معظم الميزات تتطلب **Business Account**
- النشر البرمجي غير متاح لمعظم المطورين
- قد تحتاج Snapchat Ads Account للوصول الكامل

---

## 📋 ملخص جميع المتغيرات المطلوبة

### Backend `.env` File:

```env
# ==========================================
# FACEBOOK
# ==========================================
FACEBOOK_APP_ID=your_facebook_app_id_here
FACEBOOK_APP_SECRET=your_facebook_app_secret_here
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback

# ==========================================
# INSTAGRAM (يستخدم نفس Facebook App)
# ==========================================
INSTAGRAM_CLIENT_ID=your_instagram_client_id_here
INSTAGRAM_CLIENT_SECRET=your_instagram_client_secret_here

# ==========================================
# TWITTER / X
# ==========================================
TWITTER_API_KEY=your_twitter_api_key_here
TWITTER_API_SECRET=your_twitter_api_secret_here
TWITTER_BEARER_TOKEN=your_twitter_bearer_token_here
TWITTER_CLIENT_ID=your_twitter_client_id_here
TWITTER_CLIENT_SECRET=your_twitter_client_secret_here

# ==========================================
# LINKEDIN
# ==========================================
LINKEDIN_CLIENT_ID=your_linkedin_client_id_here
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret_here

# ==========================================
# YOUTUBE / GOOGLE
# ==========================================
YOUTUBE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
YOUTUBE_CLIENT_SECRET=your_google_client_secret_here
YOUTUBE_REDIRECT_URI=https://mediaprosocial.io/api/auth/youtube/callback

GOOGLE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
GOOGLE_REDIRECT_URI=https://mediaprosocial.io/api/oauth/callback/google

# ==========================================
# TIKTOK
# ==========================================
TIKTOK_APP_ID=your_tiktok_client_key_here
TIKTOK_APP_SECRET=your_tiktok_client_secret_here

# ==========================================
# SNAPCHAT
# ==========================================
SNAPCHAT_CLIENT_ID=your_snapchat_client_id_here
SNAPCHAT_CLIENT_SECRET=your_snapchat_client_secret_here
```

---

## 🔗 روابط مفيدة

### Developer Portals:
- **Facebook**: https://developers.facebook.com
- **Instagram**: https://developers.facebook.com/products/instagram
- **Twitter**: https://developer.twitter.com
- **LinkedIn**: https://www.linkedin.com/developers
- **Google/YouTube**: https://console.cloud.google.com
- **TikTok**: https://developers.tiktok.com
- **Snapchat**: https://kit.snapchat.com

### Documentation:
- **Facebook Graph API**: https://developers.facebook.com/docs/graph-api
- **Instagram Basic Display**: https://developers.facebook.com/docs/instagram-basic-display-api
- **Twitter API v2**: https://developer.twitter.com/en/docs/twitter-api
- **LinkedIn API**: https://docs.microsoft.com/en-us/linkedin/
- **YouTube Data API**: https://developers.google.com/youtube/v3
- **TikTok for Developers**: https://developers.tiktok.com/doc
- **Snap Kit**: https://docs.snap.com/snap-kit

---

## ⚠️ ملاحظات مهمة

### 🔒 الأمان:
1. **لا تشارك API Secrets مع أحد**
2. استخدم `.env` ولا ترفعها على Git
3. استخدم HTTPS فقط في Production
4. راجع الأذونات بانتظام

### 📊 Quotas & Limits:
- **Facebook**: 200 calls/hour/user (Basic)
- **Instagram**: 200 calls/hour
- **Twitter**: 300 tweets/3 hours (Free tier)
- **LinkedIn**: 100,000 calls/day (with partnership)
- **YouTube**: 10,000 units/day (default)
- **TikTok**: يعتمد على نوع الحساب
- **Snapchat**: محدودة جداً

### 🌐 Webhooks (للتحديثات الفورية):
معظم المنصات تدعم Webhooks للحصول على تحديثات فورية. ستحتاج:
```
https://mediaprosocial.io/api/webhooks/{platform}
```

### 📱 Mobile Deep Links:
```
Android: mediaprosocial://oauth/callback/{platform}
iOS: mediaprosocial://oauth/callback/{platform}
```

---

## ✅ Checklist النشر

قبل نشر التطبيق للإنتاج، تأكد من:

- [ ] جميع API Keys مضافة في `.env`
- [ ] Redirect URIs صحيحة لكل منصة
- [ ] تم طلب جميع Permissions المطلوبة
- [ ] تم نشر التطبيقات (من Development إلى Production)
- [ ] Privacy Policy متوفرة على موقعك
- [ ] Terms of Service متوفرة
- [ ] Data Deletion instructions متوفرة
- [ ] Domain verified (إن كان مطلوباً)
- [ ] تم اختبار OAuth Flow على كل منصة
- [ ] Error handling جاهز
- [ ] Rate limiting implemented

---

## 🆘 المساعدة والدعم

إذا واجهت مشاكل:

1. **Facebook/Instagram**: https://developers.facebook.com/support
2. **Twitter**: https://twittercommunity.com
3. **LinkedIn**: https://www.linkedin.com/help/linkedin/ask/api
4. **Google/YouTube**: https://support.google.com/googleapi
5. **TikTok**: https://developers.tiktok.com/support
6. **Snapchat**: https://support.snapchat.com

---

**آخر تحديث:** 2025-11-16
**الحالة:** جاهز للتطبيق ✅
