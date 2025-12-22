# 🚀 دليل البدء السريع - Ultimate Media Integration

## ⚡ الإعداد السريع

### 1. إضافة API Keys
```bash
# أضف هذه المتغيرات في .env
KIE_AI_API_KEY=your_api_key_here
TELEGRAM_BOT_TOKEN=your_bot_token_here
```

### 2. إنشاء Telegram Bot
1. تحدث مع [@BotFather](https://t.me/botfather) في Telegram
2. استخدم `/newbot` لإنشاء bot جديد
3. احفظ الـ token المعطى

### 3. تفعيل Webhook
```bash
curl -X POST https://your-domain.com/api/telegram/set-webhook \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"webhook_url": "https://your-domain.com/api/telegram/webhook"}'
```

## 🎬 اختبار توليد الفيديوهات

### عبر API مباشرة:
```bash
curl -X POST https://your-domain.com/api/video-generation/text-to-video \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "prompt": "Beautiful sunset over ocean waves",
    "aspect_ratio": "9:16",
    "title": "Ocean Sunset"
  }'
```

### عبر Telegram Bot:
1. ابحث عن البوت باستخدام username
2. ابدأ محادثة مع `/start`
3. اكتب: `أنشئ فيديو: منظر غروب جميل فوق المحيط`

## 🔗 تعديل n8n Workflow

استبدل عقدة HTTP Request في n8n بـ:

**URL**: `https://your-domain.com/api/video-generation/webhook/n8n`

**Body**:
```json
{
  "action": "create_video",
  "prompt": "{{ $json.prompt }}",
  "video_title": "{{ $json.videoTitle }}",
  "aspect_ratio": "{{ $json.aspectRatio }}",
  "chat_id": "{{ $('Telegram Trigger').item.json.message.chat.id }}"
}
```

## 🛠️ روابط مفيدة

| الوظيفة | الرابط | الطريقة |
|---------|-------|---------|
| إنشاء فيديو من نص | `/api/video-generation/text-to-video` | POST |
| إنشاء فيديو من صورة | `/api/video-generation/image-to-video` | POST |
| فحص الحالة | `/api/video-generation/status` | POST |
| n8n Webhook | `/api/video-generation/webhook/n8n` | POST |
| Telegram Webhook | `/api/telegram/webhook` | POST |
| اختبار البوت | `/api/telegram/test` | GET |

## 🔍 فحص التشغيل

### 1. تأكد من API
```bash
curl https://your-domain.com/api/video-generation/providers
```

### 2. تأكد من Telegram Bot
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-domain.com/api/telegram/test
```

### 3. تأكد من Webhook
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-domain.com/api/telegram/webhook-info
```

## 📱 أوامر Telegram Bot

| الأمر | الوظيفة |
|-------|---------|
| `أنشئ فيديو: [وصف]` | توليد فيديو من النص |
| إرسال صورة + `حول إلى فيديو: [وصف]` | تحويل صورة لفيديو |
| `/start` | بدء المحادثة |
| `/help` | عرض المساعدة |

## 🐛 حل المشاكل الشائعة

### مشكلة: "API Key invalid"
```bash
# تأكد من صحة الـ API key
echo $KIE_AI_API_KEY
```

### مشكلة: "Telegram webhook failed"
```bash
# تأكد من إعداد الـ webhook
curl -X POST https://your-domain.com/api/telegram/set-webhook \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"webhook_url": "https://your-domain.com/api/telegram/webhook"}'
```

### مشكلة: "Video generation timeout"
```bash
# فحص حالة المهمة
curl -X POST https://your-domain.com/api/video-generation/status \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"task_id": "YOUR_TASK_ID", "provider": "kie_ai"}'
```

## 📊 مراقبة النظام

### السجلات (Logs)
```bash
tail -f storage/logs/laravel.log | grep "AI Video"
```

### فحص الأداء
```bash
# إحصائيات الذاكرة
free -h

# إحصائيات المعالج
top -p $(pgrep php)
```

## 🔄 التحديثات

### تحديث التطبيق
```bash
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
```

### إعادة تشغيل الخدمات
```bash
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm  # حسب إصدار PHP
```

## 📞 الدعم

- 📧 للمساكل التقنية: تحقق من `storage/logs/laravel.log`
- 🤖 لاختبار البوت: استخدم `/api/telegram/test`
- 🎬 لاختبار الفيديوهات: استخدم `/api/video-generation/providers`

---

## ✅ Checklist للتشغيل

- [ ] إضافة `KIE_AI_API_KEY` في .env
- [ ] إنشاء Telegram Bot وإضافة `TELEGRAM_BOT_TOKEN`
- [ ] تفعيل Telegram Webhook
- [ ] اختبار توليد فيديو عبر API
- [ ] اختبار Telegram Bot
- [ ] تحديث n8n workflow (اختياري)
- [ ] فحص السجلات والأخطاء

🎉 **مبروك! النظام جاهز للعمل**