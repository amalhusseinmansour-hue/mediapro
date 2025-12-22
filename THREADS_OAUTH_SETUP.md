# Threads OAuth Setup - MediaPro Social

## 🎯 ملاحظة مهمة

Threads (ثريدز) من Meta يستخدم **نفس Facebook App** الذي أنشأته!

**لا تحتاج إنشاء app جديد** - فقط إضافة Threads API.

---

## الخطوات الكاملة

### 1️⃣ استخدم Facebook App الموجود

1. اذهب إلى: https://developers.facebook.com/apps
2. افتح التطبيق الذي أنشأته: **MediaPro Social**
3. من القائمة الجانبية → **Add Product**

---

### 2️⃣ إضافة Threads API

**ملاحظة مهمة**: Threads API **جديد** (أطلق في يونيو 2023)

1. ابحث عن **Threads API**
2. اضغط **Set Up**

**إذا لم تجد Threads API**:
- قد يكون محدوداً بالدول
- قد يحتاج تقديم طلب للوصول
- تحقق من: https://developers.facebook.com/docs/threads

---

### 3️⃣ طلب Permissions

الـ Permissions المطلوبة:

```
threads_basic
threads_content_publish
threads_manage_insights
threads_manage_replies
threads_read_replies
```

**كيفية الطلب**:
1. اذهب إلى **App Review** → **Permissions and Features**
2. ابحث عن Threads permissions
3. اضغط **Request** لكل واحدة
4. املأ نموذج Use Case

---

### 4️⃣ استخدام نفس Credentials

```env
# نفس Facebook credentials!
THREADS_APP_ID=same_as_FACEBOOK_APP_ID
THREADS_APP_SECRET=same_as_FACEBOOK_APP_SECRET
THREADS_REDIRECT_URI=https://mediaprosocial.io/api/auth/threads/callback
```

---

## 🔄 OAuth Flow

### Step 1: Authorization URL

```
https://threads.net/oauth/authorize?
  client_id={FACEBOOK_APP_ID}&
  redirect_uri=https://mediaprosocial.io/api/auth/threads/callback&
  scope=threads_basic,threads_content_publish&
  response_type=code&
  state={RANDOM_STATE}
```

### Step 2: Exchange Code for Token

```php
POST https://graph.threads.net/oauth/access_token

Headers:
  Content-Type: application/x-www-form-urlencoded

Body:
  client_id={FACEBOOK_APP_ID}
  client_secret={FACEBOOK_APP_SECRET}
  grant_type=authorization_code
  redirect_uri=https://mediaprosocial.io/api/auth/threads/callback
  code={AUTHORIZATION_CODE}
```

Response:
```json
{
  "access_token": "THREADS_ACCESS_TOKEN",
  "token_type": "bearer",
  "expires_in": 5184000
}
```

**ملاحظة**: Token صالح لـ 60 يوماً (5184000 ثانية)

---

### Step 3: Get Long-Lived Token

```php
GET https://graph.threads.net/access_token?
  grant_type=th_exchange_token&
  client_secret={FACEBOOK_APP_SECRET}&
  access_token={SHORT_LIVED_TOKEN}
```

Response:
```json
{
  "access_token": "LONG_LIVED_TOKEN",
  "token_type": "bearer",
  "expires_in": 5184000
}
```

---

## 📝 Publishing to Threads

### Step 1: Create Media Container

```php
POST https://graph.threads.net/v1.0/{threads_user_id}/threads

Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Body:
{
  "media_type": "TEXT",
  "text": "Hello from MediaPro Social! 🚀"
}
```

**للمنشورات مع صور**:
```php
{
  "media_type": "IMAGE",
  "image_url": "https://example.com/image.jpg",
  "text": "Check this out! 📸"
}
```

**للمنشورات مع فيديو**:
```php
{
  "media_type": "VIDEO",
  "video_url": "https://example.com/video.mp4",
  "text": "Watch this! 🎥"
}
```

Response:
```json
{
  "id": "container_id_123456"
}
```

---

### Step 2: Publish the Container

```php
POST https://graph.threads.net/v1.0/{threads_user_id}/threads_publish

Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Body:
{
  "creation_id": "container_id_123456"
}
```

Response:
```json
{
  "id": "thread_id_789012"
}
```

---

## 🎯 Get User Profile

```php
GET https://graph.threads.net/v1.0/me?
  fields=id,username,name,threads_profile_picture_url,threads_biography&
  access_token={access_token}
```

Response:
```json
{
  "id": "123456789",
  "username": "username",
  "name": "Display Name",
  "threads_profile_picture_url": "https://...",
  "threads_biography": "Bio text"
}
```

---

## 📊 Get Thread Insights

```php
GET https://graph.threads.net/v1.0/{thread_id}/insights?
  metric=views,likes,replies,reposts,quotes&
  access_token={access_token}
```

Response:
```json
{
  "data": [
    {
      "name": "views",
      "period": "lifetime",
      "values": [{"value": 1234}]
    },
    {
      "name": "likes",
      "period": "lifetime",
      "values": [{"value": 56}]
    }
  ]
}
```

---

## 📸 Media Requirements

### Images:
- **Format**: JPG, PNG
- **Size**: Max 8MB
- **Ratio**: 1:1 recommended
- **Resolution**: Min 600x600, Max 1440x1440

### Videos:
- **Format**: MP4, MOV
- **Size**: Max 1GB
- **Duration**: Max 5 minutes
- **Ratio**: 9:16, 16:9, 1:1
- **Resolution**: Max 1920x1080

### Text:
- **Max Length**: 500 characters

---

## ⚠️ API Limits

- **Rate Limit**:
  - User Token: 250 calls/hour
  - App Token: 1000 calls/hour
- **Publishing**: 250 posts/day per user
- **Media Upload**: Max 10MB per file

---

## 🔄 Refresh Long-Lived Token

Long-lived tokens expire بعد 60 يوماً:

```php
GET https://graph.threads.net/refresh_access_token?
  grant_type=th_refresh_token&
  access_token={LONG_LIVED_TOKEN}
```

Response:
```json
{
  "access_token": "NEW_LONG_LIVED_TOKEN",
  "token_type": "bearer",
  "expires_in": 5184000
}
```

**يُنصح بتحديث Token كل 30 يوماً**

---

## 🎯 كيف يربط المستخدم حسابه؟

### Flow في Flutter App:

1. **User يضغط "Connect Threads"**
2. **App يفتح OAuth URL**:
   ```
   https://threads.net/oauth/authorize?client_id=...
   ```
3. **User يسجل دخول بحساب Instagram**
4. **User يختار حساب Threads**
5. **Threads redirects back** مع code
6. **App يبادل code بـ access token**
7. **App يحصل على long-lived token**
8. **App يحفظ token في database** ✅

---

## 💡 ملاحظات مهمة

### 1. Threads User ID

- كل user له Threads User ID منفصل
- **ليس** نفس Facebook User ID
- **ليس** نفس Instagram User ID
- تحصل عليه من `/me` endpoint

### 2. Rate Limits صارمة

```
250 calls/hour per user
250 posts/day per user
```

خطط للـ rate limiting في الكود!

### 3. Token Management

```php
// Check if token will expire soon
if (Carbon::parse($account->expires_at)->subDays(30)->isPast()) {
    // Refresh token
    $newToken = $this->refreshThreadsToken($account->access_token);
    $account->update(['access_token' => encrypt($newToken)]);
}
```

---

## 🔧 Publishing Code Example

```php
public function publishToThreads($accessToken, $userId, $content, $mediaUrl = null)
{
    // Step 1: Create container
    $containerData = [
        'media_type' => $mediaUrl ? 'IMAGE' : 'TEXT',
        'text' => $content
    ];

    if ($mediaUrl) {
        $containerData['image_url'] = $mediaUrl;
    }

    $containerResponse = Http::withToken($accessToken)
        ->post("https://graph.threads.net/v1.0/{$userId}/threads", $containerData);

    if (!$containerResponse->successful()) {
        return ['success' => false, 'error' => $containerResponse->json()];
    }

    $containerId = $containerResponse->json()['id'];

    // Step 2: Publish
    $publishResponse = Http::withToken($accessToken)
        ->post("https://graph.threads.net/v1.0/{$userId}/threads_publish", [
            'creation_id' => $containerId
        ]);

    if ($publishResponse->successful()) {
        return [
            'success' => true,
            'thread_id' => $publishResponse->json()['id']
        ];
    }

    return ['success' => false, 'error' => $publishResponse->json()];
}
```

---

## ⚠️ الحالة الحالية للـ API

**Threads API** لا يزال **جديداً** (أطلق في يونيو 2023):

### ✅ ما يعمل:
- OAuth
- Publishing (text, images, videos)
- Basic insights
- User profile info

### ❌ ما لا يعمل حالياً:
- Commenting programmatically (قريباً)
- Direct messages (غير متوفر)
- Stories (غير متوفر)
- Advanced analytics (محدودة)

### 🔄 قد يحتاج:
- App Review من Meta
- Business verification
- قد تكون الميزات محدودة بالدول

---

## 🔗 روابط مفيدة

- Threads API Docs: https://developers.facebook.com/docs/threads
- API Reference: https://developers.facebook.com/docs/threads/reference
- Getting Started: https://developers.facebook.com/docs/threads/get-started

---

## ✅ الناتج النهائي

```env
# استخدم نفس Facebook credentials
THREADS_APP_ID=same_as_FACEBOOK_APP_ID
THREADS_APP_SECRET=same_as_FACEBOOK_APP_SECRET
THREADS_REDIRECT_URI=https://mediaprosocial.io/api/auth/threads/callback
```

---

## 🚨 تحذير مهم

**Threads API** قد لا يكون متاحاً في جميع الدول!

**قبل البدء**:
1. تحقق من توفر Threads في بلدك
2. تحقق من توفر Threads API لتطبيقك
3. قد تحتاج انتظار موافقة من Meta

**إذا لم يكن متاحاً**:
- ركز على المنصات الأخرى (9 منصات)
- أضف Threads لاحقاً عند توفره
- أو استخدم Ayrshare ($499/mo) الذي يدعم Threads

---

**الوقت**: 10 دقائق (بعد Facebook OAuth) ⏱️

**ملاحظة**: نفس Facebook App، فقط إضافة Threads API! ✅
