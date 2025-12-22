# Telegram Bot Setup - MediaPro Social

## ⚠️ ملاحظة مهمة

Telegram **لا يستخدم OAuth** التقليدي!

بدلاً من ذلك، يستخدم **Bot API** مع Bot Token

---

## الخطوات الكاملة

### 1️⃣ إنشاء Telegram Bot

1. افتح Telegram
2. ابحث عن: **@BotFather**
3. ابدأ محادثة → `/start`
4. أرسل: `/newbot`

---

### 2️⃣ إعداد Bot

**BotFather سيسألك**:

**Bot Name** (الاسم الظاهر):
```
MediaPro Social
```

**Bot Username** (يجب أن ينتهي بـ bot):
```
mediaprosocial_bot
```

---

### 3️⃣ نسخ Bot Token

**BotFather سيرسل لك رسالة تحتوي على**:
```
Done! Congratulations on your new bot...
Use this token to access the HTTP API:
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567

Keep your token secure and store it safely...
```

**انسخ Token**:
```
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567
```

---

### 4️⃣ إعداد Bot Commands (اختياري)

أرسل لـ BotFather:
```
/setcommands
```

اختر البوت الخاص بك، ثم أرسل:
```
start - Start using the bot
help - Get help
connect - Connect your channel
post - Create a new post
```

---

### 5️⃣ تفعيل Inline Mode (اختياري)

أرسل لـ BotFather:
```
/setinline
```

اختر البوت، ثم أرسل:
```
Search posts...
```

---

## 🔄 كيف يعمل Telegram Publishing؟

### طريقتان للنشر:

### 1. النشر إلى Channel (الأفضل)

**المستخدم يجب**:
1. إنشاء Telegram Channel
2. إضافة البوت كـ Admin للـ Channel
3. إعطاء البوت صلاحية "Post messages"

**الحصول على Channel ID**:
```php
// User يرسل رسالة للبوت مع Channel username
GET https://api.telegram.org/bot{BOT_TOKEN}/getUpdates

// أو يضيف البوت للـ Channel، ثم:
GET https://api.telegram.org/bot{BOT_TOKEN}/getChat?chat_id=@channel_username
```

**النشر**:
```php
POST https://api.telegram.org/bot{BOT_TOKEN}/sendMessage

Body (JSON):
{
  "chat_id": "@channel_username",
  "text": "Your post content here",
  "parse_mode": "HTML"
}
```

---

### 2. النشر إلى Group

نفس الطريقة مثل Channel

---

## 📝 Telegram API Methods

### Send Text Message
```php
POST https://api.telegram.org/bot{BOT_TOKEN}/sendMessage

Body:
{
  "chat_id": "@channel_username",
  "text": "Post content",
  "parse_mode": "Markdown"
}
```

### Send Photo
```php
POST https://api.telegram.org/bot{BOT_TOKEN}/sendPhoto

Body:
{
  "chat_id": "@channel_username",
  "photo": "https://example.com/image.jpg",
  "caption": "Photo caption"
}
```

### Send Video
```php
POST https://api.telegram.org/bot{BOT_TOKEN}/sendVideo

Body:
{
  "chat_id": "@channel_username",
  "video": "https://example.com/video.mp4",
  "caption": "Video caption"
}
```

### Send Multiple Media (Album)
```php
POST https://api.telegram.org/bot{BOT_TOKEN}/sendMediaGroup

Body:
{
  "chat_id": "@channel_username",
  "media": [
    {
      "type": "photo",
      "media": "https://example.com/image1.jpg",
      "caption": "First photo"
    },
    {
      "type": "photo",
      "media": "https://example.com/image2.jpg"
    }
  ]
}
```

---

## 🎯 OAuth-like Flow للتطبيق

بما أن Telegram لا يستخدم OAuth، يمكنك استخدام:

### Telegram Login Widget

**Step 1**: إعداد Login Widget

أرسل لـ BotFather:
```
/setdomain
```

أدخل:
```
mediaprosocial.io
```

**Step 2**: استخدم Telegram Login في Flutter

```html
<script async src="https://telegram.org/js/telegram-widget.js?22"
  data-telegram-login="mediaprosocial_bot"
  data-size="large"
  data-auth-url="https://mediaprosocial.io/api/auth/telegram/callback"
  data-request-access="write">
</script>
```

**Step 3**: Verify Data

```php
public function telegramCallback(Request $request)
{
    $checkHash = $request->input('hash');
    $dataCheckArr = [];

    foreach ($request->except('hash') as $key => $value) {
        $dataCheckArr[] = $key . '=' . $value;
    }

    sort($dataCheckArr);
    $dataCheckString = implode("\n", $dataCheckArr);
    $secretKey = hash('sha256', env('TELEGRAM_BOT_TOKEN'), true);
    $hash = hash_hmac('sha256', $dataCheckString, $secretKey);

    if (strcmp($hash, $checkHash) !== 0) {
        return response()->json(['error' => 'Invalid hash'], 401);
    }

    // User verified! Store telegram_id
    $user = Auth::user();
    $user->telegram_id = $request->input('id');
    $user->save();
}
```

---

## 📊 API Limits

- **Rate Limit**: 30 messages/second
- **Group messages**: 20 messages/minute
- **No daily limits**
- **No OAuth quotas** - مباشر!

---

## 🔧 Get Channel Info

```php
GET https://api.telegram.org/bot{BOT_TOKEN}/getChat?chat_id=@channel_username

Response:
{
  "ok": true,
  "result": {
    "id": -1001234567890,
    "title": "Channel Name",
    "username": "channel_username",
    "type": "channel",
    "description": "Channel description"
  }
}
```

---

## ✅ الناتج النهائي

```env
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567
TELEGRAM_BOT_USERNAME=mediaprosocial_bot
```

---

## 🎯 كيف يربط المستخدم حسابه؟

### في التطبيق:

1. **User يضغط "Connect Telegram"**
2. **App يعرض تعليمات**:
   ```
   لربط Telegram:
   1. افتح قناتك في Telegram
   2. اذهب إلى Channel Settings → Administrators
   3. اضغط Add Administrator
   4. ابحث عن: @mediaprosocial_bot
   5. اختر البوت وأعطه صلاحية "Post Messages"
   6. ارجع للتطبيق وأدخل username القناة
   ```
3. **User يدخل**: `@my_channel`
4. **App يختبر الوصول**:
   ```php
   GET https://api.telegram.org/bot{BOT_TOKEN}/getChat?chat_id=@my_channel
   ```
5. **إذا نجح** → Channel متصل! ✅

---

## 💡 ميزات إضافية

### Bot Commands في Channel

يمكنك إضافة أوامر تفاعلية:
```
/post - نشر منشور جديد
/schedule - جدولة منشور
/stats - إحصائيات القناة
```

### Webhooks (للردود الفورية)

```php
POST https://api.telegram.org/bot{BOT_TOKEN}/setWebhook

Body:
{
  "url": "https://mediaprosocial.io/api/telegram/webhook"
}
```

---

**الوقت**: 5 دقائق ⏱️

جاهز! ✅
