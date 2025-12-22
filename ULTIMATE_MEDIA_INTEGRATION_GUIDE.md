# دليل التكامل مع Ultimate Media Agent

## نظرة عامة
تم تطوير نظام متكامل لربط تطبيق Ultimate Media الخاص بك مع workflow n8n "Ultimate Media Agent". يدعم النظام الآن توليد الفيديوهات من النص والصور باستخدام Kie AI API.

## الميزات المضافة

### 1. خدمة Kie AI للفيديوهات
- **موقع الملف**: `backend/app/Services/KieAIVideoService.php`
- **الوظائف**:
  - توليد فيديو من نص (Text-to-Video)
  - توليد فيديو من صورة (Image-to-Video)
  - متابعة حالة التوليد
  - تحميل وحفظ الفيديوهات المولدة
  - إعادة المحاولة التلقائية

### 2. مُتحكم توليد الفيديوهات
- **موقع الملف**: `backend/app/Http/Controllers/Api/VideoGenerationController.php`
- **النقاط المتاحة (Endpoints)**:
  ```
  POST /api/video-generation/text-to-video
  POST /api/video-generation/image-to-video
  POST /api/video-generation/status
  POST /api/video-generation/download
  GET  /api/video-generation/history
  POST /api/video-generation/n8n-style
  POST /api/video-generation/webhook/n8n
  GET  /api/video-generation/providers
  ```

## طرق الاستخدام

### 1. توليد فيديو من النص
```bash
curl -X POST http://your-domain.com/api/video-generation/text-to-video \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "prompt": "A beautiful sunset over the ocean",
    "title": "Ocean Sunset",
    "aspect_ratio": "9:16",
    "duration": 5,
    "model": "veo3_fast"
  }'
```

### 2. توليد فيديو من صورة
```bash
curl -X POST http://your-domain.com/api/video-generation/image-to-video \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "image_url": "https://example.com/image.jpg",
    "video_prompt": "Make the waves move gently",
    "image_name": "Ocean Picture",
    "aspect_ratio": "9:16"
  }'
```

### 3. فحص حالة التوليد
```bash
curl -X POST http://your-domain.com/api/video-generation/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "task_id": "YOUR_TASK_ID",
    "provider": "kie_ai"
  }'
```

## التكامل مع n8n

### 1. استخدام Webhook
استخدم هذا الرابط في workflow n8n الخاص بك:
```
http://your-domain.com/api/video-generation/webhook/n8n
```

### 2. طريقة N8N المتوافقة
```bash
curl -X POST http://your-domain.com/api/video-generation/n8n-style \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "A beautiful sunset over the ocean",
    "video_title": "Ocean Sunset",
    "aspect_ratio": "9:16",
    "chat_id": "12345",
    "image_url": "https://example.com/image.jpg"
  }'
```

### 3. Webhook Data Format
```json
{
  "action": "create_video",
  "prompt": "Your video prompt here",
  "video_title": "Video Title",
  "aspect_ratio": "9:16",
  "chat_id": "telegram_chat_id",
  "user_id": "user_id"
}
```

## إعداد التكوين

### 1. متغيرات البيئة المطلوبة
أضف هذه المتغيرات إلى ملف `.env`:

```bash
# Kie AI Configuration
KIE_AI_API_KEY=your_kie_ai_api_key_here
KIE_AI_SECRET_KEY=your_kie_ai_secret_key_here
KIE_AI_ENDPOINT=https://api.kie.ai/v1

# N8N Configuration (اختياري)
N8N_BASE_URL=http://localhost:5678
N8N_API_KEY=
N8N_WEBHOOK_TOKEN=your_secure_webhook_token

# خدمات إضافية (اختيارية)
RUNWAY_API_KEY=
PIKA_API_KEY=
DID_API_KEY=
STABILITY_API_KEY=
```

### 2. إنشاء مجلدات التخزين
```bash
mkdir -p storage/app/public/videos/generated
php artisan storage:link
```

## تعديل n8n Workflow

### 1. استبدال عقدة Kie AI
بدلاً من استخدام HTTP Request مباشرة في n8n، يمكنك استخدام:

```javascript
// في عقدة HTTP Request
{
  "method": "POST",
  "url": "http://your-domain.com/api/video-generation/webhook/n8n",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "action": "create_video",
    "prompt": "{{ $json.prompt }}",
    "video_title": "{{ $json.videoTitle }}",
    "aspect_ratio": "{{ $json.aspectRatio }}",
    "chat_id": "{{ $('Telegram Trigger').item.json.message.chat.id }}"
  }
}
```

### 2. لتوليد فيديو من صورة
```javascript
{
  "method": "POST",
  "url": "http://your-domain.com/api/video-generation/webhook/n8n",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "action": "image_to_video",
    "prompt": "{{ $json.videoPrompt }}",
    "image_url": "{{ $json.imageUrl }}",
    "video_title": "{{ $json.image }}",
    "aspect_ratio": "9:16",
    "chat_id": "{{ $('Telegram Trigger').item.json.message.chat.id }}"
  }
}
```

## المعايير المدعومة

### 1. نسب العرض إلى الارتفاع
- `16:9` - للفيديوهات الأفقية (YouTube)
- `9:16` - للفيديوهات العمودية (TikTok, Instagram Stories)
- `1:1` - للفيديوهات المربعة (Instagram, Facebook)

### 2. النماذج المدعومة
- `veo3_fast` - سريع وبجودة جيدة (افتراضي)
- `veo3_standard` - بطيء أكثر وبجودة عالية

### 3. المدة القصوى
- حتى 10 ثوانٍ لكل فيديو
- وقت المعالجة: حوالي 3 دقائق

## رسائل الاستجابة

### نجح التوليد
```json
{
  "success": true,
  "message": "Video generation started successfully",
  "data": {
    "task_id": "abc123",
    "status": "processing",
    "estimated_time": 180,
    "video_title": "Generated Video"
  }
}
```

### فشل التوليد
```json
{
  "success": false,
  "error": "Error message here",
  "provider": "kie_ai"
}
```

### الفيديو جاهز
```json
{
  "success": true,
  "data": {
    "task_id": "abc123",
    "status": "completed",
    "video_url": "https://api.kie.ai/video/download/...",
    "download_url": "https://api.kie.ai/video/download/..."
  }
}
```

## الدعم والصيانة

### 1. ملفات السجل
- جميع العمليات تُسجل في: `storage/logs/laravel.log`
- فلترة حسب: `'AI Video Generation'`

### 2. معالجة الأخطاء
- إعادة المحاولة التلقائية (حتى 3 مرات)
- رسائل خطأ واضحة ومفصلة
- تسجيل مفصل لجميع العمليات

### 3. الأداء
- التحميل التلقائي للفيديوهات المولدة
- دعم الصور من Google Drive
- متوافق مع Telegram Bot

## أمثلة للاستخدام

### 1. مع Postman
1. إنشاء Collection جديد
2. إضافة Authorization: Bearer Token
3. استخدام الـ endpoints أعلاه
4. تتبع task_id للحصول على النتيجة

### 2. مع JavaScript
```javascript
// توليد فيديو من نص
const response = await fetch('/api/video-generation/text-to-video', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + token
  },
  body: JSON.stringify({
    prompt: 'Beautiful sunset over mountains',
    aspect_ratio: '9:16',
    title: 'Mountain Sunset'
  })
});

const data = await response.json();
console.log('Task ID:', data.data.task_id);

// فحص الحالة كل 30 ثانية
const checkStatus = setInterval(async () => {
  const statusResponse = await fetch('/api/video-generation/status', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    },
    body: JSON.stringify({
      task_id: data.data.task_id,
      provider: 'kie_ai'
    })
  });
  
  const statusData = await statusResponse.json();
  if (statusData.data.status === 'completed') {
    console.log('Video URL:', statusData.data.video_url);
    clearInterval(checkStatus);
  }
}, 30000);
```

## الخلاصة
تم تطوير نظام شامل ومتكامل يدعم:
- توليد الفيديوهات بأنواعها المختلفة
- التكامل المباشر مع n8n workflow
- دعم جميع providers الرئيسية لتوليد الفيديو
- واجهة برمجية متطورة ومتوافقة مع النظام الحالي
- نظام متابعة وإدارة شامل

النظام جاهز للاستخدام ويمكن البدء بالتجربة فوراً عبر إضافة API key الخاص بـ Kie AI.