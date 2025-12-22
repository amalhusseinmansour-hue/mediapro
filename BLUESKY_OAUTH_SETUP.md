# Bluesky Setup - MediaPro Social

## ⚠️ ملاحظة مهمة

Bluesky **لا يستخدم OAuth** التقليدي حالياً!

بدلاً من ذلك، يستخدم **App Passwords** (كلمات مرور التطبيقات)

---

## الخطوات الكاملة

### 1️⃣ إنشاء Bluesky Account

1. اذهب إلى: https://bsky.app
2. سجل حساب جديد أو سجل دخول
3. أكمل الملف الشخصي

---

### 2️⃣ إنشاء App Password

1. اذهب إلى: **Settings** → **Privacy and Security**
2. أو مباشرة: https://bsky.app/settings/app-passwords
3. اضغط **Add App Password**
4. املأ المعلومات:

   **App Name**:
   ```
   MediaPro Social
   ```

5. اضغط **Create App Password**

---

### 3️⃣ نسخ App Password

ستظهر نافذة بـ App Password (مثل):
```
xxxx-xxxx-xxxx-xxxx
```

**⚠️ مهم جداً**: انسخه فوراً! لن يظهر مرة أخرى!

```
BLUESKY_APP_PASSWORD=xxxx-xxxx-xxxx-xxxx
```

---

## 🔄 Authentication Flow

### بدون OAuth - استخدم App Password مباشرة

**Step 1: Create Session**
```php
POST https://bsky.social/xrpc/com.atproto.server.createSession

Headers:
  Content-Type: application/json

Body:
{
  "identifier": "username.bsky.social",
  "password": "xxxx-xxxx-xxxx-xxxx"
}
```

Response:
```json
{
  "did": "did:plc:xxxxxxxxxxxxx",
  "handle": "username.bsky.social",
  "email": "user@example.com",
  "accessJwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshJwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Step 2: استخدم accessJwt في كل request**

---

## 📝 Create Post

### Simple Text Post
```php
POST https://bsky.social/xrpc/com.atproto.repo.createRecord

Headers:
  Authorization: Bearer {accessJwt}
  Content-Type: application/json

Body:
{
  "repo": "username.bsky.social",
  "collection": "app.bsky.feed.post",
  "record": {
    "$type": "app.bsky.feed.post",
    "text": "Hello from MediaPro Social!",
    "createdAt": "2025-01-15T12:00:00Z"
  }
}
```

### Post with Image
```php
# Step 1: Upload Image
POST https://bsky.social/xrpc/com.atproto.repo.uploadBlob

Headers:
  Authorization: Bearer {accessJwt}
  Content-Type: image/jpeg

Body: {binary_image_data}

Response:
{
  "blob": {
    "$type": "blob",
    "ref": {
      "$link": "bafkreixxx..."
    },
    "mimeType": "image/jpeg",
    "size": 123456
  }
}

# Step 2: Create Post with Image
POST https://bsky.social/xrpc/com.atproto.repo.createRecord

Body:
{
  "repo": "username.bsky.social",
  "collection": "app.bsky.feed.post",
  "record": {
    "$type": "app.bsky.feed.post",
    "text": "Post with image!",
    "createdAt": "2025-01-15T12:00:00Z",
    "embed": {
      "$type": "app.bsky.embed.images",
      "images": [
        {
          "alt": "Image description",
          "image": {
            "$type": "blob",
            "ref": {
              "$link": "bafkreixxx..."
            },
            "mimeType": "image/jpeg",
            "size": 123456
          }
        }
      ]
    }
  }
}
```

---

## 🎯 كيف يربط المستخدم حسابه؟

### في التطبيق:

1. **User يضغط "Connect Bluesky"**
2. **App يعرض نموذج**:
   - Username: `username.bsky.social`
   - App Password: `xxxx-xxxx-xxxx-xxxx`
3. **User يدخل بياناته**
4. **App يختبر الاتصال**:
   ```php
   POST https://bsky.social/xrpc/com.atproto.server.createSession
   ```
5. **إذا نجح** → يحفظ:
   - `did` (Decentralized Identifier)
   - `handle` (username)
   - `accessJwt`
   - `refreshJwt`

---

## 🔄 Refresh Access Token

**Access tokens تنتهي بعد ساعتين**:

```php
POST https://bsky.social/xrpc/com.atproto.server.refreshSession

Headers:
  Authorization: Bearer {refreshJwt}
```

Response:
```json
{
  "did": "did:plc:xxxxxxxxxxxxx",
  "handle": "username.bsky.social",
  "accessJwt": "new_access_token...",
  "refreshJwt": "new_refresh_token..."
}
```

---

## 📊 Get User Profile

```php
GET https://bsky.social/xrpc/app.bsky.actor.getProfile?actor=username.bsky.social

Headers:
  Authorization: Bearer {accessJwt}
```

Response:
```json
{
  "did": "did:plc:xxxxxxxxxxxxx",
  "handle": "username.bsky.social",
  "displayName": "Display Name",
  "description": "Bio text",
  "avatar": "https://cdn.bsky.app/...",
  "followersCount": 123,
  "followsCount": 456,
  "postsCount": 789
}
```

---

## 📌 Post Features

### With Links
```json
{
  "text": "Check this out! https://example.com",
  "facets": [
    {
      "index": {
        "byteStart": 16,
        "byteEnd": 36
      },
      "features": [
        {
          "$type": "app.bsky.richtext.facet#link",
          "uri": "https://example.com"
        }
      ]
    }
  ]
}
```

### With Mentions
```json
{
  "text": "Hey @username check this!",
  "facets": [
    {
      "index": {
        "byteStart": 4,
        "byteEnd": 13
      },
      "features": [
        {
          "$type": "app.bsky.richtext.facet#mention",
          "did": "did:plc:xxxxxxxxxxxxx"
        }
      ]
    }
  ]
}
```

---

## 🖼️ Image Requirements

- **Format**: JPG, PNG, GIF, WEBP
- **Max Size**: 1MB per image
- **Max Images**: 4 per post
- **Recommended Size**: 1000x1000 pixels
- **Aspect Ratio**: 1:1 to 3:1

---

## ⚠️ API Limits

- **Rate Limit**: 3000 requests/5 minutes (generous!)
- **Post Creation**: 300 posts/day (currently)
- **Image Upload**: Limited by size (1MB)

---

## 📱 User Flow في التطبيق

### UI Mockup:

```dart
// Connect Bluesky Screen
TextField(
  decoration: InputDecoration(
    labelText: 'Bluesky Username',
    hintText: 'username.bsky.social'
  ),
  controller: usernameController,
)

TextField(
  decoration: InputDecoration(
    labelText: 'App Password',
    hintText: 'xxxx-xxxx-xxxx-xxxx'
  ),
  obscureText: true,
  controller: passwordController,
)

ElevatedButton(
  onPressed: () async {
    // Create session
    final result = await connectBluesky(
      username: usernameController.text,
      password: passwordController.text
    );

    if (result['success']) {
      // Save account
      Navigator.pop(context);
      showSnackBar('Bluesky connected!');
    }
  },
  child: Text('Connect Account'),
)
```

---

## 🔗 روابط مفيدة

- Bluesky: https://bsky.app
- API Documentation: https://docs.bsky.app
- AT Protocol: https://atproto.com/

---

## ✅ الناتج النهائي

```env
# لا يوجد OAuth Apps - استخدم App Passwords فقط
BLUESKY_SERVICE_URL=https://bsky.social
```

**ملاحظة**: كل user يحتاج App Password منفصل من حسابه الخاص

**الوقت**: 5 دقائق ⏱️

جاهز! ✅
