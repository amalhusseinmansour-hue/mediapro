# TikTok OAuth Setup - MediaPro Social

## ⚠️ تحذير مهم

TikTok API **معقد** ويحتاج:
- تقديم طلب للحصول على Developer Access
- الموافقة تأخذ 1-2 أسابيع
- محدود لـ **Business accounts** فقط
- يحتاج **Business verification**

---

## الخطوات الكاملة

### 1️⃣ إنشاء TikTok Developer Account

1. اذهب إلى: https://developers.tiktok.com/
2. سجل دخول بحساب TikTok الخاص بك
3. اضغط **Register** (أعلى يمين)
4. املأ النموذج:
   - **Email**: بريدك الإلكتروني
   - **Password**: كلمة مرور قوية
   - **Verification Code**: من بريدك
5. وافق على الشروط
6. اضغط **Register**

---

### 2️⃣ إنشاء App

1. من Dashboard → **Manage apps**
2. اضغط **Create an app** أو **Connect an app**
3. املأ المعلومات:

   **App name**:
   ```
   MediaPro Social
   ```

   **App description**:
   ```
   Social media management platform for scheduling and publishing content to TikTok
   ```

   **App website**:
   ```
   https://mediaprosocial.io
   ```

   **Category**:
   ```
   Social & Communication
   ```

   **Platform**:
   - ✅ Web

4. اضغط **Submit**

---

### 3️⃣ طلب API Access

**مهم جداً**: TikTok API محدود

1. من App Dashboard → **Apply for permissions**
2. اختر Products:
   - ✅ **Login Kit** (للـ OAuth)
   - ✅ **Content Posting API** (للنشر)

3. **Application Form**:
   - **Use case**: Social media management platform
   - **Number of users**: Expected 100-1000 users
   - **Description**: Detailed description of how you'll use the API

4. **Submit** واجتظر الموافقة (1-2 أسابيع)

---

### 4️⃣ إعداد OAuth (بعد الموافقة)

1. من App Settings → **OAuth**
2. أضف **Redirect URI**:
   ```
   https://mediaprosocial.io/api/auth/tiktok/callback
   ```

3. **Scopes** المطلوبة:
   ```
   user.info.basic
   user.info.profile
   user.info.stats
   video.upload
   video.publish
   ```

---

### 5️⃣ نسخ Credentials

من App Settings:
```
TIKTOK_CLIENT_KEY=your_client_key
TIKTOK_CLIENT_SECRET=your_client_secret
TIKTOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/tiktok/callback
```

---

## 🔄 OAuth Flow

### Step 1: Authorization URL
```
https://www.tiktok.com/v2/auth/authorize?
  client_key={CLIENT_KEY}&
  scope=user.info.basic,video.upload,video.publish&
  response_type=code&
  redirect_uri=https://mediaprosocial.io/api/auth/tiktok/callback&
  state={RANDOM_STATE}
```

### Step 2: Exchange Code for Token
```php
POST https://open.tiktokapis.com/v2/oauth/token/

Headers:
  Content-Type: application/x-www-form-urlencoded

Body:
  client_key={CLIENT_KEY}
  client_secret={CLIENT_SECRET}
  code={AUTHORIZATION_CODE}
  grant_type=authorization_code
  redirect_uri=https://mediaprosocial.io/api/auth/tiktok/callback
```

Response:
```json
{
  "access_token": "act.xxx",
  "expires_in": 86400,
  "refresh_token": "rft.xxx",
  "refresh_expires_in": 31536000,
  "token_type": "Bearer"
}
```

---

## 📹 Publishing Video

### Step 1: Initialize Upload
```php
POST https://open.tiktokapis.com/v2/post/publish/inbox/video/init/

Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Body:
{
  "post_info": {
    "title": "Video title",
    "description": "Video description",
    "privacy_level": "PUBLIC_TO_EVERYONE",
    "disable_duet": false,
    "disable_comment": false,
    "disable_stitch": false
  },
  "source_info": {
    "source": "FILE_UPLOAD",
    "video_size": 1234567,
    "chunk_size": 10000000,
    "total_chunk_count": 1
  }
}
```

Response:
```json
{
  "data": {
    "publish_id": "v_pub_xxxx",
    "upload_url": "https://upload.tiktok.com/..."
  }
}
```

### Step 2: Upload Video
```php
PUT {upload_url}

Headers:
  Content-Range: bytes 0-{chunk_size-1}/{total_size}
  Content-Length: {chunk_size}
  Content-Type: video/mp4

Body: {video_binary_data}
```

### Step 3: Complete Upload
```php
POST https://open.tiktokapis.com/v2/post/publish/status/fetch/

Body:
{
  "publish_id": "v_pub_xxxx"
}
```

---

## ⚠️ القيود والحدود

### API Quotas:
- **Video uploads**: 10 videos/day (default)
- **API calls**: 100 calls/day
- **Rate limit**: 5 requests/second

### Video Requirements:
- **Format**: MP4, MOV, MPEG, AVI, FLV, WEBM
- **Size**: Max 4GB
- **Duration**: 3 seconds - 10 minutes
- **Resolution**: Minimum 720x720, Maximum 4096x4096
- **Aspect Ratio**: 9:16, 16:9, 1:1

### Account Requirements:
- ✅ TikTok **Business Account** only
- ✅ Account must be verified
- ✅ Account must have minimum followers (usually 1000+)

---

## 🎯 البدائل (أسهل)

### Option 1: استخدم Ayrshare
```
- TikTok OAuth جاهز
- لا تحتاج موافقة TikTok
- يدير كل شيء
- التكلفة: $499/month
```

### Option 2: انتظر الموافقة
```
- قدم طلب API access
- انتظر 1-2 أسابيع
- ابدأ بالمنصات الأخرى أولاً
- أضف TikTok لاحقاً
```

---

## 📝 التوصية

**للبداية السريعة:**
1. ✅ ابدأ بـ 9 منصات الأخرى (Facebook, Instagram, Twitter, etc.)
2. ✅ قدم طلب TikTok API في نفس الوقت
3. ✅ عند موافقة TikTok → أضفه

**أو:**
- استخدم Ayrshare للـ TikTok فقط ($499/mo)
- أو انتظر حتى يكون عندك 100+ users ثم قدم الطلب

---

## ✅ الناتج (بعد الموافقة)

```env
TIKTOK_CLIENT_KEY=your_client_key
TIKTOK_CLIENT_SECRET=your_client_secret
TIKTOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/tiktok/callback
```

---

## 🔗 روابط مفيدة

- Developer Portal: https://developers.tiktok.com/
- API Documentation: https://developers.tiktok.com/doc/
- Content Posting API: https://developers.tiktok.com/doc/content-posting-api-get-started/
- Support: https://developers.tiktok.com/support/

---

**ملاحظة**: TikTok API معقد. إذا أردت سرعة، استخدم Ayrshare أو ابدأ بالمنصات الأخرى أولاً! 🚀
