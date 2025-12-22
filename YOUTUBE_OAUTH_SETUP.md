# YouTube OAuth Setup - MediaPro Social

## الخطوات الكاملة

### 1️⃣ إنشاء Google Cloud Project

1. اذهب إلى: https://console.cloud.google.com
2. سجل دخول بحساب Google
3. اضغط **Select a project** → **New Project**
4. املأ المعلومات:
   - **Project Name**: MediaPro Social YouTube
   - **Organization**: (اختياري)
5. اضغط **Create**

---

### 2️⃣ تفعيل YouTube Data API v3

1. من القائمة الجانبية → **APIs & Services** → **Library**
2. ابحث عن: **YouTube Data API v3**
3. اضغط عليها
4. اضغط **Enable**
5. انتظر 1-2 دقيقة حتى يتم التفعيل

---

### 3️⃣ إنشاء OAuth 2.0 Credentials

1. من القائمة الجانبية → **APIs & Services** → **Credentials**
2. اضغط **+ CREATE CREDENTIALS** → **OAuth client ID**
3. إذا ظهرت رسالة "Configure consent screen":
   - اضغط **CONFIGURE CONSENT SCREEN**
   - اختر **External** (للمستخدمين العامين)
   - اضغط **Create**

---

### 4️⃣ إعداد OAuth Consent Screen

#### App Information:
- **App name**: MediaPro Social
- **User support email**: بريدك الإلكتروني
- **App logo**: (اختياري) - ارفع شعار 120x120px

#### App domain:
- **Application home page**: https://mediaprosocial.io
- **Application privacy policy**: https://mediaprosocial.io/privacy
- **Application terms of service**: https://mediaprosocial.io/terms

#### Authorized domains:
```
mediaprosocial.io
```

#### Developer contact information:
- **Email addresses**: بريدك الإلكتروني

اضغط **SAVE AND CONTINUE**

---

### 5️⃣ إضافة Scopes

في صفحة **Scopes**:

1. اضغط **ADD OR REMOVE SCOPES**
2. ابحث واختر:
   - ✅ **YouTube Data API v3** → `.../auth/youtube.upload`
   - ✅ **YouTube Data API v3** → `.../auth/youtube`
   - ✅ **YouTube Data API v3** → `.../auth/youtube.readonly`

أو أضف يدوياً:
```
https://www.googleapis.com/auth/youtube.upload
https://www.googleapis.com/auth/youtube
https://www.googleapis.com/auth/youtube.readonly
```

3. اضغط **UPDATE** → **SAVE AND CONTINUE**

---

### 6️⃣ Test Users (اختياري للتطوير)

في صفحة **Test users**:
- اضغط **+ ADD USERS**
- أضف بريدك الإلكتروني
- اضغط **SAVE AND CONTINUE**

---

### 7️⃣ إنشاء OAuth Client ID

1. ارجع إلى **Credentials** → **+ CREATE CREDENTIALS** → **OAuth client ID**
2. اختر **Application type**: **Web application**
3. املأ المعلومات:

   **Name**:
   ```
   MediaPro Social Web
   ```

   **Authorized JavaScript origins**:
   ```
   https://mediaprosocial.io
   ```

   **Authorized redirect URIs**:
   ```
   https://mediaprosocial.io/api/auth/youtube/callback
   ```

4. اضغط **CREATE**

---

### 8️⃣ نسخ Credentials

ستظهر نافذة بـ:
- **Client ID**: `xxxxxx.apps.googleusercontent.com`
- **Client Secret**: `xxxxxxxxxxxxxxx`

**انسخهم وخزنهم بأمان!**

```
YOUTUBE_CLIENT_ID=your_client_id.apps.googleusercontent.com
YOUTUBE_CLIENT_SECRET=your_client_secret_here
YOUTUBE_REDIRECT_URI=https://mediaprosocial.io/api/auth/youtube/callback
```

---

### 9️⃣ نشر التطبيق (Production)

**مهم**: بعد الاختبار، يجب نشر التطبيق:

1. **OAuth consent screen** → **PUBLISH APP**
2. اقرأ التحذيرات
3. اضغط **CONFIRM**

**ملاحظة**:
- للاستخدام العام، قد تحتاج **Verification** من Google
- لكن يمكنك البدء بـ **Testing mode** (100 user max)

---

## ✅ اختبار OAuth

اختبر الرابط:
```
https://accounts.google.com/o/oauth2/v2/auth?
  client_id=YOUR_CLIENT_ID&
  redirect_uri=https://mediaprosocial.io/api/auth/youtube/callback&
  response_type=code&
  scope=https://www.googleapis.com/auth/youtube.upload&
  access_type=offline&
  prompt=consent
```

---

## 📌 API Publishing Example

```php
// Upload Video
POST https://www.googleapis.com/upload/youtube/v3/videos
Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Body:
{
  "snippet": {
    "title": "Video Title",
    "description": "Video Description",
    "categoryId": "22"
  },
  "status": {
    "privacyStatus": "public"
  }
}
```

---

## 🔧 Troubleshooting

### Error: "Access blocked: This app's request is invalid"
- تأكد أن redirect URI مضاف بالضبط في Credentials
- تأكد أن OAuth consent screen مكتمل

### Error: "Insufficient Permission"
- تأكد أن Scopes مضافة في OAuth consent screen
- تأكد أن User وافق على كل Scopes

### Upload Quota
- YouTube API لديه quota يومي
- Default: 10,000 units/day
- Video upload = 1,600 units
- يعني: ~6 videos/day
- للزيادة: اطلب quota increase

---

## ✅ الناتج النهائي

```env
YOUTUBE_CLIENT_ID=123456789.apps.googleusercontent.com
YOUTUBE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxx
YOUTUBE_REDIRECT_URI=https://mediaprosocial.io/api/auth/youtube/callback
```

جاهز! ✅
