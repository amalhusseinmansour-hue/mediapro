# 🚀 دليل البدء السريع - Ultimate Media Agent

## ✅ ما تحتاجه (10 دقائق)

### الخطوة 1: إنشاء Telegram Bot (دقيقتان)

```
1. افتح Telegram وابحث عن: @BotFather
2. أرسل: /newbot
3. اسم البوت: MediaPro Social Bot
4. معرف البوت: mediaprosocial_bot (أو أي اسم متاح)
5. احفظ الـ TOKEN الذي يعطيك إياه
```

### الخطوة 2: إعداد Google Cloud APIs (5 دقائق)

```
1. https://console.cloud.google.com/
2. أنشئ مشروع جديد: "MediaPro Agent"
3. فعّل APIs:
   ✅ Google Drive API
   ✅ Gmail API
   ✅ Google Calendar API
4. OAuth consent screen → External
5. Credentials → Create OAuth 2.0 Client ID
6. Redirect URL: http://localhost:5678/rest/oauth2-credential/callback
7. احفظ Client ID و Client Secret
```

### الخطوة 3: استيراد في n8n (دقيقة واحدة)

```bash
# تأكد أن n8n يعمل
n8n start

# افتح: http://localhost:5678

# Workflows → Import from File
# اختر الملف JSON الذي شاركته
```

### الخطوة 4: إعداد Credentials في n8n (دقيقتان)

```
1. Credentials → Add Credential

أضف:
- Telegram API → الصق Bot Token
- Google Drive OAuth2 → الصق Client ID & Secret
- Gmail OAuth2 → نفس البيانات
- Google Calendar OAuth2 → نفس البيانات
- OpenAI API → API key من OpenAI
```

---

## 🎯 اختبار سريع

### اختبار 1: إرسال رسالة للبوت

```
1. افتح Telegram
2. ابحث عن البوت: @mediaprosocial_bot
3. أرسل: /start
4. البوت يجب أن يرد!
```

### اختبار 2: إنشاء صورة

```
أرسل للبوت:
"Create an image of a beautiful sunset over mountains"

البوت سيقوم بـ:
1. إنشاء صورة بالذكاء الاصطناعي
2. حفظها في Google Drive
3. إرسالها لك على Telegram
```

### اختبار 3: النشر على Instagram

```
أرسل للبوت:
"Post the last image to Instagram with caption: Beautiful sunset 🌅"

البوت سيقوم بـ:
1. البحث عن آخر صورة في Google Drive
2. نشرها على Instagram
3. إرسال تأكيد لك
```

---

## 🔧 الدمج مع Laravel (5 دقائق)

### 1. أضف TelegramService

```bash
# انسخ الملف
cp docs/TelegramService.example.php backend/app/Services/TelegramService.php
```

### 2. أضف المتغيرات البيئية

```env
# backend/.env
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_WEBHOOK_URL=https://mediaprosocial.io/api/webhooks/telegram
```

### 3. اختبر من Laravel

```php
php artisan tinker

>>> app(\App\Services\TelegramService::class)->sendMessage(
    'YOUR_CHAT_ID',
    'Hello from MediaPro Social! 👋'
);
```

---

## 📱 أمثلة الاستخدام

### مثال 1: إنشاء حملة كاملة

```
# من Telegram، أرسل:
Create a marketing campaign about "Social Media Tips"
with 3 images and 1 video,
then post them to Instagram, TikTok, and YouTube

# البوت سيفعل كل شيء تلقائياً! 🤖
```

### مثال 2: جدولة محتوى

```
# أرسل:
Create an image about productivity tips
and schedule it for Instagram tomorrow at 9 AM

# البوت سيجدول المنشور 📅
```

### مثال 3: البحث والنشر

```
# أرسل:
Search for trending topics about digital marketing,
create an image about the top trend,
and post it to all platforms

# البوت سيبحث + ينشئ + ينشر 🚀
```

---

## 🆘 استكشاف الأخطاء

### مشكلة: البوت لا يرد

```bash
# تحقق من n8n
n8n start

# تحقق من الـ workflow مفعّل
# n8n → Ultimate Media Agent → Active (تأكد أنه ON)

# اختبر البوت
curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe
```

### مشكلة: Google Drive لا يعمل

```
1. تأكد من تفعيل Google Drive API
2. تحقق من OAuth Credentials صحيح
3. في n8n → Test Connection
4. أعد المصادقة إذا لزم الأمر
```

### مشكلة: الصور لا تُنشأ

```
1. تحقق من OpenAI API Key
2. تأكد من رصيد كافٍ في حساب OpenAI
3. شاهد execution logs في n8n
```

---

## 💡 نصائح مهمة

### للحصول على أفضل النتائج:

1. **كن محدداً في الأوامر**
   ```
   ❌ "Create image"
   ✅ "Create a professional image about social media marketing with blue colors"
   ```

2. **استخدم الذاكرة**
   ```
   البوت يتذكر المحادثة السابقة:
   "Create an image of a cat"
   ثم: "Make it blue"  ← البوت يفهم أنك تقصد القطة
   ```

3. **جرب الأوامر المعقدة**
   ```
   "Create 5 images about different marketing strategies,
    edit the 3rd one to add text,
    convert the 2nd to video,
    and post them all to Instagram with creative captions"
   ```

---

## 📊 الإحصائيات المتاحة

البوت يمكنه تقديم تقارير:

```
# أرسل:
"Show me stats for last week's posts"

# أو:
"How many images did I create this month?"

# أو:
"What's my most engaged post on Instagram?"
```

---

## 🎓 موارد التعلم

### وثائق n8n:
- https://docs.n8n.io/

### APIs المستخدمة:
- Telegram Bot API: https://core.telegram.org/bots/api
- OpenAI API: https://platform.openai.com/docs/api-reference
- Google Drive API: https://developers.google.com/drive/api/guides/about-sdk

### فيديوهات مفيدة:
- n8n Basics: https://www.youtube.com/n8n
- Telegram Bots: https://www.youtube.com/telegram

---

## ✨ ماذا بعد؟

بعد نجاح الإعداد الأساسي:

1. ✅ أضف المزيد من المنصات (Facebook, Twitter, LinkedIn)
2. ✅ ربط مع CRM (Airtable, HubSpot)
3. ✅ إضافة تحليلات متقدمة
4. ✅ أتمتة الردود على التعليقات
5. ✅ إنشاء chatbot للعملاء

---

**🎉 تهانينا! البوت جاهز للعمل!**

**استمتع بقوة الذكاء الاصطناعي والأتمتة!** 🤖✨
