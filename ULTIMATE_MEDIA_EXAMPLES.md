# 📋 أمثلة الاستخدام - Ultimate Media Integration

## 🎬 توليد الفيديوهات

### 1. توليد فيديو من النص (Text-to-Video)

#### مثال بسيط
```bash
curl -X POST https://your-domain.com/api/video-generation/text-to-video \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "prompt": "A serene mountain lake at sunrise with mist rising from the water",
    "title": "Mountain Lake",
    "aspect_ratio": "9:16"
  }'
```

#### مثال متقدم
```bash
curl -X POST https://your-domain.com/api/video-generation/text-to-video \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "prompt": "A bustling city street at night with neon lights reflecting on wet pavement",
    "title": "Neon City Night",
    "aspect_ratio": "16:9",
    "duration": 8,
    "model": "veo3_standard",
    "provider": "kie_ai"
  }'
```

### 2. توليد فيديو من صورة (Image-to-Video)

```bash
curl -X POST https://your-domain.com/api/video-generation/image-to-video \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "image_url": "https://example.com/beach-photo.jpg",
    "video_prompt": "Gentle waves washing over the shore, seagulls flying overhead",
    "image_name": "Beach Scene",
    "aspect_ratio": "9:16"
  }'
```

### 3. فحص حالة التوليد

```bash
curl -X POST https://your-domain.com/api/video-generation/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "task_id": "abc123xyz789",
    "provider": "kie_ai"
  }'
```

## 🤖 Telegram Bot

### رسائل نصية
- `أنشئ فيديو: منظر طبيعي خلاب مع شلال`
- `إنشاء فيديو: قطة لطيفة تلعب في الحديقة`
- `create video: beautiful sunset over the ocean`
- `فيديو عن السفر في اليابان`

### مع الصور
1. أرسل صورة للبوت
2. اكتب: `حول إلى فيديو: اجعل الأمواج تتحرك بلطف`
3. أو: `أضف حركة: رياح خفيفة تحرك الأشجار`

## 🔌 تكامل n8n

### 1. استبدال عقدة Generate Video

**القديم (Kie AI مباشرة):**
```json
{
  "method": "POST",
  "url": "https://api.kie.ai/api/v1/veo/generate",
  "headers": {
    "Authorization": "Bearer {{ $vars.kieApiKey }}",
    "Content-Type": "application/json"
  },
  "body": {
    "prompt": "{{ $json.prompt }}",
    "model": "veo3_fast",
    "aspectRatio": "9:16"
  }
}
```

**الجديد (عبر Ultimate Media):**
```json
{
  "method": "POST",
  "url": "https://your-domain.com/api/video-generation/webhook/n8n",
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

### 2. Image to Video Tool

```json
{
  "method": "POST",
  "url": "https://your-domain.com/api/video-generation/webhook/n8n",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "action": "image_to_video",
    "prompt": "{{ $json.videoPrompt }}",
    "image_url": "{{ $json.fileID }}",
    "video_title": "{{ $json.image }}",
    "aspect_ratio": "9:16",
    "chat_id": "{{ $json.chatID }}"
  }
}
```

### 3. فحص الحالة

```json
{
  "method": "POST",
  "url": "https://your-domain.com/api/video-generation/webhook/n8n",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "action": "check_status",
    "task_id": "{{ $json.taskId }}"
  }
}
```

## 💻 JavaScript/Frontend

### توليد فيديو
```javascript
async function generateVideo(prompt, title = 'Generated Video') {
  try {
    const response = await fetch('/api/video-generation/text-to-video', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        prompt: prompt,
        title: title,
        aspect_ratio: '9:16'
      })
    });

    const data = await response.json();
    
    if (data.success) {
      console.log('Video generation started:', data.data.task_id);
      return data.data.task_id;
    } else {
      console.error('Generation failed:', data.error);
      return null;
    }
  } catch (error) {
    console.error('API call failed:', error);
    return null;
  }
}

// الاستخدام
const taskId = await generateVideo('Beautiful landscape with mountains');
```

### متابعة الحالة
```javascript
async function checkVideoStatus(taskId) {
  try {
    const response = await fetch('/api/video-generation/status', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        task_id: taskId,
        provider: 'kie_ai'
      })
    });

    const data = await response.json();
    return data.data;
  } catch (error) {
    console.error('Status check failed:', error);
    return null;
  }
}

// مراقبة التقدم
async function monitorVideoGeneration(taskId) {
  const checkInterval = setInterval(async () => {
    const status = await checkVideoStatus(taskId);
    
    if (status) {
      console.log('Status:', status.status);
      
      if (status.status === 'completed') {
        console.log('Video ready:', status.video_url);
        clearInterval(checkInterval);
      } else if (status.status === 'failed') {
        console.log('Generation failed');
        clearInterval(checkInterval);
      }
    }
  }, 30000); // فحص كل 30 ثانية
}
```

## 🐍 Python

```python
import requests
import time
import json

class UltimateMediaAPI:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url.rstrip('/')
        self.headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {auth_token}'
        }
    
    def generate_video_from_text(self, prompt, title=None, aspect_ratio='9:16'):
        """توليد فيديو من نص"""
        url = f'{self.base_url}/api/video-generation/text-to-video'
        data = {
            'prompt': prompt,
            'aspect_ratio': aspect_ratio
        }
        if title:
            data['title'] = title
            
        response = requests.post(url, headers=self.headers, json=data)
        return response.json()
    
    def generate_video_from_image(self, image_url, video_prompt, image_name=None):
        """توليد فيديو من صورة"""
        url = f'{self.base_url}/api/video-generation/image-to-video'
        data = {
            'image_url': image_url,
            'video_prompt': video_prompt,
            'aspect_ratio': '9:16'
        }
        if image_name:
            data['image_name'] = image_name
            
        response = requests.post(url, headers=self.headers, json=data)
        return response.json()
    
    def check_status(self, task_id, provider='kie_ai'):
        """فحص حالة التوليد"""
        url = f'{self.base_url}/api/video-generation/status'
        data = {
            'task_id': task_id,
            'provider': provider
        }
        response = requests.post(url, headers=self.headers, json=data)
        return response.json()
    
    def wait_for_completion(self, task_id, max_wait=600, check_interval=30):
        """انتظار اكتمال التوليد"""
        start_time = time.time()
        
        while time.time() - start_time < max_wait:
            result = self.check_status(task_id)
            
            if result.get('success') and result.get('data'):
                status = result['data'].get('status')
                
                if status == 'completed':
                    return result['data']
                elif status == 'failed':
                    raise Exception('Video generation failed')
            
            time.sleep(check_interval)
        
        raise TimeoutError('Video generation timed out')

# مثال للاستخدام
api = UltimateMediaAPI('https://your-domain.com', 'your_auth_token')

# توليد فيديو
result = api.generate_video_from_text(
    prompt='Beautiful sunset over mountain peaks',
    title='Mountain Sunset'
)

if result.get('success'):
    task_id = result['data']['task_id']
    print(f'Generation started: {task_id}')
    
    # انتظار الاكتمال
    try:
        final_result = api.wait_for_completion(task_id)
        print(f'Video ready: {final_result["video_url"]}')
    except Exception as e:
        print(f'Error: {e}')
```

## 📱 PHP (للمطورين)

```php
<?php

class UltimateMediaClient
{
    private $baseUrl;
    private $authToken;
    
    public function __construct($baseUrl, $authToken)
    {
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->authToken = $authToken;
    }
    
    public function generateVideoFromText($prompt, $title = null, $aspectRatio = '9:16')
    {
        $data = [
            'prompt' => $prompt,
            'aspect_ratio' => $aspectRatio
        ];
        
        if ($title) {
            $data['title'] = $title;
        }
        
        return $this->makeRequest('/api/video-generation/text-to-video', 'POST', $data);
    }
    
    public function checkStatus($taskId, $provider = 'kie_ai')
    {
        return $this->makeRequest('/api/video-generation/status', 'POST', [
            'task_id' => $taskId,
            'provider' => $provider
        ]);
    }
    
    private function makeRequest($endpoint, $method = 'GET', $data = null)
    {
        $url = $this->baseUrl . $endpoint;
        
        $options = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . $this->authToken
            ]
        ];
        
        if ($method === 'POST' && $data) {
            $options[CURLOPT_POST] = true;
            $options[CURLOPT_POSTFIELDS] = json_encode($data);
        }
        
        $curl = curl_init();
        curl_setopt_array($curl, $options);
        $response = curl_exec($curl);
        curl_close($curl);
        
        return json_decode($response, true);
    }
}

// الاستخدام
$client = new UltimateMediaClient('https://your-domain.com', 'your_auth_token');

$result = $client->generateVideoFromText('Beautiful ocean waves at sunset');

if ($result['success']) {
    $taskId = $result['data']['task_id'];
    echo "Generation started: $taskId\n";
    
    // فحص دوري للحالة
    do {
        sleep(30);
        $status = $client->checkStatus($taskId);
        echo "Status: " . $status['data']['status'] . "\n";
    } while ($status['data']['status'] === 'processing');
    
    if ($status['data']['status'] === 'completed') {
        echo "Video ready: " . $status['data']['video_url'] . "\n";
    }
}
?>
```

## 🧪 اختبار الوظائف

### 1. اختبار سريع
```bash
# فحص أن الخدمة تعمل
curl https://your-domain.com/api/health

# فحص providers المتاحة
curl https://your-domain.com/api/video-generation/providers
```

### 2. اختبار Telegram Bot
```bash
# اختبار البوت
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-domain.com/api/telegram/test

# فحص webhook
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-domain.com/api/telegram/webhook-info
```

### 3. اختبار توليد الفيديو
```bash
# توليد فيديو بسيط
curl -X POST https://your-domain.com/api/video-generation/text-to-video \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"prompt": "test video", "title": "Test"}'
```

---

## 🎯 نصائح للحصول على أفضل النتائج

### للنصوص (Prompts):
- استخدم وصفاً واضحاً ومفصلاً
- اذكر الحركة المطلوبة
- حدد الإضاءة والمزاج
- تجنب النصوص الطويلة جداً (> 500 حرف)

### للصور:
- استخدم صوراً عالية الجودة
- تأكد من وضوح الكائن الرئيسي
- فكر في نوع الحركة المطلوبة

### الأداء:
- استخدم aspect_ratio مناسب للمنصة المستهدفة
- veo3_fast للسرعة، veo3_standard للجودة
- راقب استهلاك الـ API quota