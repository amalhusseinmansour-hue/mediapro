# Reddit OAuth Setup - MediaPro Social

## الخطوات الكاملة

### 1️⃣ إنشاء Reddit App

1. اذهب إلى: https://www.reddit.com/prefs/apps
2. سجل دخول بحساب Reddit
3. اضغط **create another app...** (أسفل الصفحة)

---

### 2️⃣ ملء معلومات App

**اختر نوع التطبيق**:
- ✅ **web app**

**املأ المعلومات**:

**name**:
```
MediaPro Social
```

**description** (اختياري):
```
Social media management platform
```

**about url** (اختياري):
```
https://mediaprosocial.io
```

**redirect uri**:
```
https://mediaprosocial.io/api/auth/reddit/callback
```

اضغط **create app**

---

### 3️⃣ نسخ Credentials

ستظهر معلومات App:

```
MediaPro Social
  personal use script
  [CLIENT_ID هنا - سلسلة من الأحرف تحت اسم التطبيق]

  secret: [CLIENT_SECRET هنا]
```

انسخ:
- **Client ID**: السلسلة الموجودة تحت اسم التطبيق مباشرة
- **Client Secret**: الموجودة بجانب "secret:"

```
REDDIT_CLIENT_ID=your_client_id_here
REDDIT_CLIENT_SECRET=your_client_secret_here
REDDIT_REDIRECT_URI=https://mediaprosocial.io/api/auth/reddit/callback
```

---

## 🔄 OAuth Flow

### Step 1: Authorization URL
```
https://www.reddit.com/api/v1/authorize?
  client_id={CLIENT_ID}&
  response_type=code&
  state={RANDOM_STATE}&
  redirect_uri=https://mediaprosocial.io/api/auth/reddit/callback&
  duration=permanent&
  scope=identity,submit,read
```

**Scopes المطلوبة**:
- `identity` - معرفة هوية المستخدم
- `submit` - نشر المحتوى
- `read` - قراءة المحتوى
- `edit` - تعديل المحتوى
- `subscribe` - الاشتراك في subreddits

---

### Step 2: Exchange Code for Token

**Important**: Reddit API يتطلب Basic Authentication

```php
POST https://www.reddit.com/api/v1/access_token

Headers:
  Authorization: Basic {base64(CLIENT_ID:CLIENT_SECRET)}
  Content-Type: application/x-www-form-urlencoded
  User-Agent: MediaPro Social v1.0

Body:
  grant_type=authorization_code
  code={AUTHORIZATION_CODE}
  redirect_uri=https://mediaprosocial.io/api/auth/reddit/callback
```

Response:
```json
{
  "access_token": "xxxxx-xxxxxxxxxxxxxx",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "xxxxx-xxxxxxxxxxxxxx",
  "scope": "identity submit read"
}
```

---

## 📝 Submit Post to Reddit

### Submit Link Post
```php
POST https://oauth.reddit.com/api/submit

Headers:
  Authorization: Bearer {access_token}
  User-Agent: MediaPro Social v1.0
  Content-Type: application/x-www-form-urlencoded

Body:
  sr=subreddit_name
  kind=link
  title=Post Title Here
  url=https://example.com/content
  resubmit=true
```

### Submit Text Post
```php
POST https://oauth.reddit.com/api/submit

Headers:
  Authorization: Bearer {access_token}
  User-Agent: MediaPro Social v1.0
  Content-Type: application/x-www-form-urlencoded

Body:
  sr=subreddit_name
  kind=self
  title=Post Title Here
  text=Post content here in markdown format
  resubmit=true
```

### Submit Image Post
```php
# Step 1: Upload image to Reddit's media upload
POST https://oauth.reddit.com/api/media/asset.json

Headers:
  Authorization: Bearer {access_token}
  User-Agent: MediaPro Social v1.0
  Content-Type: application/x-www-form-urlencoded

Body:
  filepath=image.jpg
  mimetype=image/jpeg

# Response contains upload URL

# Step 2: Upload to S3 URL provided

# Step 3: Submit post
POST https://oauth.reddit.com/api/submit

Body:
  sr=subreddit_name
  kind=image
  title=Post Title
  url={media_url_from_step_1}
```

---

## ⚠️ مهم جداً: User-Agent

Reddit API **يتطلب** User-Agent صحيح في كل request!

**الشكل الصحيح**:
```
User-Agent: platform:app_name:version (by /u/your_reddit_username)
```

**مثال**:
```
User-Agent: web:mediaprosocial:v1.0 (by /u/mediaprosocial)
```

**بدون User-Agent صحيح → 429 Too Many Requests**

---

## 📊 API Limits

- **Rate Limit**: 60 requests/minute
- **OAuth Rate**: 600 requests/10 minutes
- **Important**: استخدم User-Agent صحيح دائماً!

---

## 🎯 Get User Subreddits

```php
GET https://oauth.reddit.com/subreddits/mine/subscriber

Headers:
  Authorization: Bearer {access_token}
  User-Agent: MediaPro Social v1.0
```

Response:
```json
{
  "data": {
    "children": [
      {
        "data": {
          "display_name": "subreddit_name",
          "title": "Subreddit Title",
          "subscribers": 123456
        }
      }
    ]
  }
}
```

---

## 🔄 Refresh Token

Reddit access tokens expire بعد ساعة واحدة:

```php
POST https://www.reddit.com/api/v1/access_token

Headers:
  Authorization: Basic {base64(CLIENT_ID:CLIENT_SECRET)}
  User-Agent: MediaPro Social v1.0
  Content-Type: application/x-www-form-urlencoded

Body:
  grant_type=refresh_token
  refresh_token={REFRESH_TOKEN}
```

---

## ✅ الناتج النهائي

```env
REDDIT_CLIENT_ID=your_client_id
REDDIT_CLIENT_SECRET=your_client_secret
REDDIT_REDIRECT_URI=https://mediaprosocial.io/api/auth/reddit/callback
REDDIT_USER_AGENT=web:mediaprosocial:v1.0 (by /u/yourusername)
```

**الوقت**: 10 دقائق ⏱️

جاهز! ✅
