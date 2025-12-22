# دليل n8n للأتمتة الكاملة

## 🚀 التثبيت السريع

### الطريقة 1: استخدام السكريبت التلقائي
```bash
# تشغيل سكريبت التثبيت
n8n_setup.bat

# بعد التثبيت، تشغيل n8n
n8n_start.bat
```

### الطريقة 2: التثبيت اليدوي
```bash
# تثبيت n8n عالمياً
npm install -g n8n

# تشغيل n8n
n8n start
```

### الوصول إلى n8n
- URL: http://localhost:5678
- Username: `admin`
- Password: `mediapro2025`

---

## 📋 Workflows الجاهزة للمشروع

### Workflow 1: النشر التلقائي على السوشيال ميديا

```json
{
  "name": "Auto Post to Social Media",
  "nodes": [
    {
      "name": "Laravel Webhook",
      "type": "n8n-nodes-base.webhook",
      "position": [250, 300],
      "webhookId": "auto-post"
    },
    {
      "name": "Upload-Post API",
      "type": "n8n-nodes-base.httpRequest",
      "position": [450, 300]
    }
  ]
}
```

### Workflow 2: إنشاء محتوى بالذكاء الاصطناعي

هذا workflow يقوم بـ:
1. استقبال طلب إنشاء محتوى من Laravel
2. توليد صورة/فيديو عبر Kie.ai
3. حفظ المحتوى وإرساله للنشر

### Workflow 3: الأتمتة الكاملة

هذا workflow الرئيسي يدمج كل شيء:
1. جدولة المحتوى من Laravel
2. إنشاء محتوى AI تلقائياً (Kie.ai)
3. تحسين وتنسيق المحتوى
4. النشر على جميع المنصات (Upload-Post)
5. تتبع النتائج والإحصائيات

---

## 🔗 التكامل مع Laravel

### 1. إعداد Webhooks في Laravel

```php
// routes/api.php
Route::post('/n8n/webhook/{workflow}', [N8nWebhookController::class, 'handle']);
```

### 2. إرسال البيانات إلى n8n

```php
// app/Services/N8nService.php
use Illuminate\Support\Facades\Http;

class N8nService
{
    protected string $baseUrl = 'http://localhost:5678';

    public function triggerWorkflow(string $webhookId, array $data): array
    {
        $response = Http::post("{$this->baseUrl}/webhook/{$webhookId}", $data);

        return $response->json();
    }

    public function createPost(array $postData): array
    {
        return $this->triggerWorkflow('auto-post', [
            'content' => $postData['content'],
            'platforms' => $postData['platforms'],
            'schedule_time' => $postData['schedule_time'],
            'media' => $postData['media'] ?? null,
        ]);
    }

    public function generateContent(string $prompt, string $type = 'image'): array
    {
        return $this->triggerWorkflow('generate-content', [
            'prompt' => $prompt,
            'type' => $type, // 'image' or 'video'
        ]);
    }
}
```

---

## 📝 أمثلة Workflows

### مثال 1: نشر تلقائي بسيط

**الخطوات:**
1. Webhook تستقبل بيانات المنشور من Laravel
2. HTTP Request إلى Upload-Post API للنشر
3. إرجاع النتيجة إلى Laravel

**الكود في n8n:**
```javascript
// في node "Process Data"
const post = {
  content: $json.content,
  platforms: $json.platforms || ['facebook', 'instagram', 'twitter'],
  schedule_time: $json.schedule_time || 'now',
  media_urls: $json.media || []
};

return {
  json: post
};
```

### مثال 2: إنشاء محتوى + نشر

**الخطوات:**
1. استقبال موضوع المحتوى من Laravel
2. إنشاء صورة عبر Kie.ai
3. إنشاء نص تلقائي (يمكن استخدام ChatGPT)
4. النشر عبر Upload-Post
5. حفظ النتيجة في Laravel

---

## 🛠️ Nodes المهمة في n8n

### 1. HTTP Request Node
لإرسال طلبات إلى APIs الخارجية:
- Upload-Post API
- Kie.ai API
- Laravel API

### 2. Webhook Node
لاستقبال البيانات من Laravel

### 3. Function Node
لمعالجة البيانات بـ JavaScript

### 4. Schedule Trigger
لتشغيل workflows في أوقات محددة

### 5. IF Node
لإضافة شروط منطقية

---

## 📊 سيناريوهات الأتمتة الكاملة

### السيناريو 1: نشر يومي تلقائي
```
[Schedule: 9 AM Daily]
  → [Generate Topic Ideas]
  → [Create Image with Kie.ai]
  → [Generate Caption]
  → [Post to All Platforms]
  → [Save to Database]
```

### السيناريو 2: محتوى تفاعلي
```
[Webhook: New Trend Topic]
  → [Fetch Trending Data]
  → [Generate Relevant Content]
  → [Get Hashtags]
  → [Create & Post]
  → [Track Performance]
```

### السيناريو 3: حملة متعددة المنصات
```
[Webhook: New Campaign]
  → [Split by Platform]
    → [Customize for Facebook]
    → [Customize for Instagram]
    → [Customize for Twitter]
  → [Schedule Posts]
  → [Monitor Results]
```

---

## 🔐 الأمان والإعدادات

### تأمين Webhooks
```javascript
// في n8n Function Node
const expectedToken = 'your-secret-token';
const receivedToken = $json.headers['x-webhook-token'];

if (receivedToken !== expectedToken) {
  throw new Error('Unauthorized');
}

return { json: $json };
```

### في Laravel:
```php
// config/n8n.php
return [
    'webhook_token' => env('N8N_WEBHOOK_TOKEN'),
    'base_url' => env('N8N_BASE_URL', 'http://localhost:5678'),
];

// في Controller
$response = Http::withHeaders([
    'X-Webhook-Token' => config('n8n.webhook_token'),
])->post($url, $data);
```

---

## 📈 مراقبة الأداء

### تتبع التنفيذ في n8n
- Dashboard → Executions
- فلترة حسب الحالة (Success/Error)
- عرض تفاصيل كل تنفيذ

### Logging في Laravel
```php
// app/Services/N8nService.php
use Illuminate\Support\Facades\Log;

public function triggerWorkflow(string $webhookId, array $data): array
{
    Log::info('N8N Workflow Triggered', [
        'webhook' => $webhookId,
        'data' => $data
    ]);

    $response = Http::post("{$this->baseUrl}/webhook/{$webhookId}", $data);

    Log::info('N8N Workflow Response', [
        'status' => $response->status(),
        'body' => $response->json()
    ]);

    return $response->json();
}
```

---

## 🆘 استكشاف الأخطاء

### مشكلة: n8n لا يعمل
```bash
# تحقق من التثبيت
n8n --version

# تشغيل مع logs مفصلة
n8n start --tunnel

# إعادة التثبيت
npm uninstall -g n8n
npm install -g n8n
```

### مشكلة: Webhooks لا تستجيب
1. تأكد من n8n يعمل
2. تحقق من URL الصحيح
3. فعّل "Test Webhook" في n8n
4. تحقق من الـ firewall

### مشكلة: Workflows بطيئة
1. قلل عدد HTTP requests المتزامنة
2. استخدم Caching عند الإمكان
3. راقب execution times

---

## 📚 موارد إضافية

- الوثائق الرسمية: https://docs.n8n.io/
- أمثلة Workflows: https://n8n.io/workflows
- المجتمع: https://community.n8n.io/
- YouTube Tutorials: البحث عن "n8n tutorials"

---

## 🎯 الخطوات التالية

1. ✅ تثبيت n8n محلياً
2. ✅ إعداد Webhooks الأساسية
3. ⏳ بناء أول workflow للاختبار
4. ⏳ التكامل مع Laravel
5. ⏳ إضافة Upload-Post و Kie.ai
6. ⏳ اختبار الأتمتة الكاملة

---

## 💡 نصائح مهمة

1. **ابدأ بسيط**: اختبر workflow بسيط أولاً قبل التعقيد
2. **استخدم Test Execution**: دائماً اختبر قبل التفعيل
3. **احفظ Workflows**: اعمل backup لـ workflows المهمة
4. **راقب الأخطاء**: تحقق من execution logs بانتظام
5. **وثّق كل شيء**: اكتب ملاحظات لكل workflow

