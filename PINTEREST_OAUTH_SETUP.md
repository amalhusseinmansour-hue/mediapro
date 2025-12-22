# Pinterest OAuth Setup - MediaPro Social

## الخطوات الكاملة

### 1️⃣ إنشاء Pinterest Developer Account

1. اذهب إلى: https://developers.pinterest.com/
2. سجل دخول بحساب Pinterest
3. اضغط **My Apps** (أعلى يمين)
4. اضغط **Create app**

---

### 2️⃣ إنشاء App

املأ المعلومات:

**App name**:
```
MediaPro Social
```

**App description**:
```
Social media management platform for scheduling and publishing content to Pinterest
```

**App website**:
```
https://mediaprosocial.io
```

**Privacy Policy URL**:
```
https://mediaprosocial.io/privacy
```

**Terms of Service URL**:
```
https://mediaprosocial.io/terms
```

**Redirect URIs**:
```
https://mediaprosocial.io/api/auth/pinterest/callback
```

اضغط **Create**

---

### 3️⃣ نسخ Credentials

من App Settings:

1. **App ID**: انسخه
2. **App secret**: اضغط **Show** → انسخه

```
PINTEREST_CLIENT_ID=your_app_id_here
PINTEREST_CLIENT_SECRET=your_app_secret_here
PINTEREST_REDIRECT_URI=https://mediaprosocial.io/api/auth/pinterest/callback
```

---

### 4️⃣ اختيار Scopes

من **OAuth scopes** → اختر:
- ✅ **boards:read** - قراءة اللوحات
- ✅ **boards:write** - إنشاء وتحديث اللوحات
- ✅ **pins:read** - قراءة الدبابيس
- ✅ **pins:write** - إنشاء وتحديث الدبابيس

اضغط **Save**

---

## 🔄 OAuth Flow

### Step 1: Authorization URL
```
https://www.pinterest.com/oauth/?
  client_id={CLIENT_ID}&
  redirect_uri=https://mediaprosocial.io/api/auth/pinterest/callback&
  response_type=code&
  scope=boards:read,boards:write,pins:read,pins:write&
  state={RANDOM_STATE}
```

### Step 2: Exchange Code for Token
```php
POST https://api.pinterest.com/v5/oauth/token

Headers:
  Content-Type: application/x-www-form-urlencoded
  Authorization: Basic {base64(CLIENT_ID:CLIENT_SECRET)}

Body:
  grant_type=authorization_code
  code={AUTHORIZATION_CODE}
  redirect_uri=https://mediaprosocial.io/api/auth/pinterest/callback
```

Response:
```json
{
  "access_token": "pina_xxxxx",
  "token_type": "bearer",
  "expires_in": 2592000,
  "refresh_token": "xxxxx",
  "refresh_token_expires_in": 31536000,
  "scope": "boards:read,boards:write,pins:read,pins:write"
}
```

---

## 📌 Publishing Pin

### Create Pin
```php
POST https://api.pinterest.com/v5/pins

Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Body:
{
  "board_id": "board_id_here",
  "title": "Pin title",
  "description": "Pin description",
  "link": "https://your-website.com",
  "media_source": {
    "source_type": "image_url",
    "url": "https://cdn.example.com/image.jpg"
  }
}
```

Response:
```json
{
  "id": "pin_id",
  "created_at": "2025-01-15T12:00:00",
  "link": "https://www.pinterest.com/pin/xxxxx/",
  "title": "Pin title",
  "description": "Pin description"
}
```

---

## 📊 Image Requirements

- **Format**: JPG, PNG
- **Size**:
  - Minimum: 600x900 pixels
  - Recommended: 1000x1500 pixels (2:3 aspect ratio)
  - Maximum: 10MB
- **Aspect Ratio**: Best 2:3 (vertical)

---

## ⚠️ API Limits

- **Rate Limit**: 10 requests/second per user
- **Daily Limit**: 250,000 requests/day (generous!)
- **Pin Creation**: 500 pins/day

---

## 🎯 Get User Boards

قبل النشر، تحتاج لجلب boards المستخدم:

```php
GET https://api.pinterest.com/v5/boards

Headers:
  Authorization: Bearer {access_token}
```

Response:
```json
{
  "items": [
    {
      "id": "board_id_1",
      "name": "Board Name",
      "description": "Board description",
      "privacy": "PUBLIC"
    }
  ]
}
```

---

## ✅ الناتج النهائي

```env
PINTEREST_CLIENT_ID=1234567890
PINTEREST_CLIENT_SECRET=abcdef1234567890
PINTEREST_REDIRECT_URI=https://mediaprosocial.io/api/auth/pinterest/callback
```

**الوقت**: 15 دقيقة ⏱️

جاهز! ✅
