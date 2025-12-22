# 🎥 دليل إعداد نظام توليد الفيديوهات بالذكاء الاصطناعي

**التاريخ:** 19 نوفمبر 2025  
**البديل المثالي لـ:** Meta AI Movie Gen (غير متاح حالياً)  
**الهدف:** إضافة نظام توليد فيديوهات AI متكامل  

---

## 🌟 نظرة عامة

تم إنشاء نظام AI Video Generation متكامل يدعم **4 مقدمي خدمة مختلفين**:

### 🏆 المقدمين المدعومين:

1. **🚀 Runway ML Gen-2** (الأفضل حالياً)
   - **التكلفة:** $0.05 لكل ثانية
   - **الجودة:** ممتازة جداً
   - **المدة القصوى:** 16 ثانية
   - **المميزات:** text-to-video عالي الجودة

2. **🎨 Pika Labs** 
   - **التكلفة:** $0.30 لكل فيديو
   - **الجودة:** ممتازة
   - **المدة القصوى:** 8 ثوانِ
   - **المميزات:** إبداعي، أساليب متنوعة

3. **👤 D-ID** (للفيديوهات الناطقة)
   - **التكلفة:** $0.30 لكل فيديو
   - **الجودة:** جيدة
   - **المدة القصوى:** 120 ثانية
   - **المميزات:** talking head videos، متعدد اللغات

4. **⚡ Stability AI** 
   - **التكلفة:** $0.02 لكل إطار
   - **الجودة:** جيدة جداً
   - **المدة القصوى:** 10 ثوانِ
   - **المميزات:** مفتوح المصدر، قابل للتخصيص

---

## 📁 الملفات المُنشأة

### 1. Database Migration ✅
```
📁 database/migrations/
  └── 2025_11_19_120000_create_ai_generated_videos_table.php
```

**الخصائص:**
- تتبع كامل للمستخدم والفيديو
- حالات متعددة (pending, processing, completed, failed)
- حفظ التكلفة والوقت
- metadata مرن لكل مقدم خدمة

### 2. Model ✅
```
📁 app/Models/
  └── AiGeneratedVideo.php
```

**المميزات:**
- Relations مع User
- Helper methods للحالات
- حساب تكلفة تقديرية
- تتبع الوقت والتقدم

### 3. Service Layer ✅
```
📁 app/Services/
  └── AIVideoGeneratorService.php
```

**يتضمن:**
- `AIVideoGeneratorService` (الرئيسي)
- `RunwayMLService` 
- `PikaLabsService`
- `DIDService`
- `StabilityAIService`

### 4. Jobs ✅
```
📁 app/Jobs/
  ├── GenerateAIVideoJob.php
  └── CheckVideoGenerationStatusJob.php
```

**المميزات:**
- معالجة غير متزامنة
- تتبع دوري للحالة
- إعادة المحاولة التلقائية
- إشعارات للمستخدم

### 5. Controller ✅
```
📁 app/Http/Controllers/Api/
  └── AIVideoController.php
```

**Endpoints:**
- `GET /api/ai-videos` - قائمة الفيديوهات
- `POST /api/ai-videos` - إنشاء فيديو جديد  
- `GET /api/ai-videos/{id}` - تفاصيل فيديو
- `DELETE /api/ai-videos/{id}` - حذف فيديو
- `GET /api/ai-videos/providers` - قائمة المقدمين
- `GET /api/ai-videos/stats` - إحصائيات المستخدم
- `GET /api/ai-videos/{id}/download` - تحميل فيديو
- `POST /api/ai-videos/{id}/retry` - إعادة المحاولة

---

## 🔧 خطوات التثبيت والإعداد

### الخطوة 1: رفع الملفات على السيرفر

#### باستخدام FileZilla أو WinSCP:

```bash
# رفع Migration
المسار المحلي: C:\Users\HP\social_media_manager\backend\database\migrations\2025_11_19_120000_create_ai_generated_videos_table.php
مسار السيرفر: /var/www/html/mediaprosocial.io/database/migrations/

# رفع Model  
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Models\AiGeneratedVideo.php
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Models/

# رفع Service
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Services\AIVideoGeneratorService.php
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Services/

# رفع Jobs
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Jobs\GenerateAIVideoJob.php
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Jobs/

المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Jobs\CheckVideoGenerationStatusJob.php  
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Jobs/

# رفع Controller
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\AIVideoController.php
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Http/Controllers/Api/
```

### الخطوة 2: تشغيل Migration

```bash
ssh root@82.25.83.217
cd /var/www/html/mediaprosocial.io
php artisan migrate
```

### الخطوة 3: إضافة Routes

إضافة في `/var/www/html/mediaprosocial.io/routes/api.php`:

```php
// AI Video Generation Routes
Route::middleware('auth:sanctum')->prefix('ai-videos')->group(function () {
    Route::get('/', [AIVideoController::class, 'index']);
    Route::post('/', [AIVideoController::class, 'store']);
    Route::get('/providers', [AIVideoController::class, 'providers']);
    Route::get('/stats', [AIVideoController::class, 'stats']);
    Route::get('/{id}', [AIVideoController::class, 'show']);
    Route::delete('/{id}', [AIVideoController::class, 'destroy']);
    Route::get('/{id}/download', [AIVideoController::class, 'download']);
    Route::post('/{id}/retry', [AIVideoController::class, 'retry']);
});
```

### الخطوة 4: إضافة API Keys في .env

```env
# AI Video Generation APIs
RUNWAY_API_KEY=your_runway_api_key_here
PIKA_API_KEY=your_pika_api_key_here  
DID_API_KEY=your_d_id_api_key_here
STABILITY_API_KEY=your_stability_api_key_here

# Queue settings (if not already set)
QUEUE_CONNECTION=database
```

### الخطوة 5: إعداد Services في config/services.php

```php
// Add to config/services.php
'runway' => [
    'api_key' => env('RUNWAY_API_KEY'),
],
'pika' => [
    'api_key' => env('PIKA_API_KEY'),
],
'd_id' => [
    'api_key' => env('DID_API_KEY'),
],
'stability' => [
    'api_key' => env('STABILITY_API_KEY'),
],
```

---

## 🔑 الحصول على API Keys

### 1. Runway ML (موصى به أولاً) 🚀

**الموقع:** https://runwayml.com/  
**الخطوات:**
1. إنشاء حساب في Runway ML
2. الانتقال إلى API Section
3. إنشاء API Key جديد
4. النسخ والإدراج في .env

**التكلفة:** $0.05 لكل ثانية (~$0.20 لفيديو 4 ثوانِ)
**الحد الأدنى:** $10 رصيد أولي

### 2. Pika Labs 🎨

**الموقع:** https://pika.art/  
**الخطوات:**
1. التسجيل في Pika Labs  
2. الاشتراك في خطة API
3. الحصول على API Token
4. الإضافة في .env

**التكلفة:** اشتراك شهري (~$30/شهر)

### 3. D-ID (للفيديوهات الناطقة) 👤

**الموقع:** https://www.d-id.com/  
**الخطوات:**
1. إنشاء حساب D-ID
2. الانتقال إلى Developer API
3. إنشاء API Key
4. الإضافة في .env

**التكلفة:** $0.30 لكل فيديو
**Free Tier:** 5 فيديوهات مجانية

### 4. Stability AI ⚡

**الموقع:** https://platform.stability.ai/  
**الخطوات:**
1. التسجيل في Stability AI
2. إنشاء API Key
3. إضافة رصيد ($10 حد أدنى)
4. الإضافة في .env

**التكلفة:** متغيرة حسب الجودة

---

## 🧪 اختبار النظام

### 1. اختبار API Endpoint

```bash
# Test video generation
curl -X POST http://82.25.83.217/api/ai-videos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "prompt": "A cat playing piano in a sunny room",
    "provider": "runway",
    "duration": 4,
    "aspect_ratio": "16:9"
  }'
```

### 2. اختبار من خلال Postman

**Request:**
- Method: `POST`
- URL: `http://82.25.83.217/api/ai-videos`
- Headers: 
  - `Authorization: Bearer YOUR_TOKEN`
  - `Content-Type: application/json`
- Body:
```json
{
    "prompt": "قط لطيف يلعب البيانو في غرفة مشمسة",
    "provider": "runway",
    "duration": 4,
    "aspect_ratio": "16:9",
    "options": {
        "quality": "high",
        "motion": "medium"
    }
}
```

### 3. مراقبة Queue

```bash
# Check queue status
php artisan queue:work --once

# Check logs
tail -f storage/logs/laravel.log
```

---

## 📱 التكامل مع Flutter App

### إضافة Model في Flutter

```dart
class AiGeneratedVideo {
  final int id;
  final String prompt;
  final String provider;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String status;
  final int duration;
  final String aspectRatio;
  final double cost;
  final DateTime createdAt;

  AiGeneratedVideo({
    required this.id,
    required this.prompt,
    required this.provider,
    this.videoUrl,
    this.thumbnailUrl,
    required this.status,
    required this.duration,
    required this.aspectRatio,
    required this.cost,
    required this.createdAt,
  });

  factory AiGeneratedVideo.fromJson(Map<String, dynamic> json) {
    return AiGeneratedVideo(
      id: json['id'],
      prompt: json['prompt'],
      provider: json['provider'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      status: json['status'],
      duration: json['duration'],
      aspectRatio: json['aspect_ratio'],
      cost: double.parse(json['cost'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

### إضافة Service في Flutter

```dart
class AIVideoService {
  static const String baseUrl = 'http://82.25.83.217/api/ai-videos';

  static Future<Map<String, dynamic>> generateVideo({
    required String prompt,
    String provider = 'runway',
    int duration = 4,
    String aspectRatio = '16:9',
    Map<String, dynamic>? options,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.getToken()}',
      },
      body: json.encode({
        'prompt': prompt,
        'provider': provider,
        'duration': duration,
        'aspect_ratio': aspectRatio,
        'options': options ?? {},
      }),
    );

    return json.decode(response.body);
  }

  static Future<List<AiGeneratedVideo>> getVideos() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${AuthService.getToken()}',
      },
    );

    final data = json.decode(response.body);
    if (data['success']) {
      return (data['data']['data'] as List)
          .map((video) => AiGeneratedVideo.fromJson(video))
          .toList();
    }
    return [];
  }
}
```

---

## 🎯 مميزات النظام

### ✅ للمطورين:
- **4 مقدمي خدمة** في نظام واحد
- **معالجة غير متزامنة** مع Queue
- **تتبع دقيق** للحالة والتكلفة
- **إعادة محاولة تلقائية** في حالة الفشل
- **API شامل** مع Validation كامل
- **إحصائيات مفصلة** لكل مستخدم

### ✅ للمستخدمين:
- **توليد فيديوهات بالذكاء الاصطناعي** من النص
- **4 خيارات جودة** مختلفة
- **فيديوهات ناطقة** مع D-ID
- **تحميل مباشر** للفيديوهات
- **تتبع التقدم** في الوقت الفعلي
- **حدود ذكية** حسب نوع الاشتراك

---

## 📊 حدود الاستخدام

### المستخدم العادي (Free):
- **5 فيديوهات يومياً**
- **50 فيديو شهرياً**
- **مدة قصوى:** 4 ثوانِ
- **جودة:** عادية

### المستخدم Premium:
- **50 فيديو يومياً**
- **500 فيديو شهرياً**  
- **مدة قصوى:** 16 ثانية
- **جودة:** عالية
- **أولوية في المعالجة**

---

## 💰 التكلفة المتوقعة

### لـ 100 فيديو (4 ثوانِ لكل فيديو):

| المقدم | التكلفة |
|--------|---------|
| Runway ML | $20 (100 × 4 × $0.05) |
| Pika Labs | $30 (subscription) |
| D-ID | $30 (100 × $0.30) |  
| Stability AI | متغيرة (~$10-25) |

**توصية:** ابدأ بـ **Runway ML** أو **D-ID** (أسهل في الإعداد)

---

## 🚨 استكشاف الأخطاء

### مشكلة: API Key لا يعمل
```bash
# تحقق من .env
cat /var/www/html/mediaprosocial.io/.env | grep API_KEY

# إعادة تحميل config
php artisan config:clear
php artisan config:cache
```

### مشكلة: Queue لا يعمل
```bash
# تحقق من status
php artisan queue:work --once

# إعادة تشغيل queue
php artisan queue:restart
```

### مشكلة: Job فاشل
```bash
# فحص failed jobs
php artisan queue:failed

# إعادة تشغيل failed job
php artisan queue:retry all
```

---

## 🎉 النتائج المتوقعة

بعد إتمام الإعداد:

✅ **إنتاج فيديوهات AI عالية الجودة** من النص  
✅ **4 خيارات مختلفة** للجودة والسعر  
✅ **تكامل كامل** مع Flutter App  
✅ **معالجة سريعة وموثوقة** مع Queue  
✅ **تتبع دقيق** للاستخدام والتكلفة  
✅ **بديل قوي** لـ Meta AI Movie Gen  

**وقت الإعداد:** 1-2 ساعة  
**الاختبار:** 15-30 دقيقة  
**النتيجة:** نظام AI Video متكامل وجاهز! 🚀

---

## 📝 خطوات ما بعد التثبيت

1. ✅ **احصل على API Key** من أي مقدم خدمة
2. ✅ **اختبر توليد فيديو واحد** للتأكد
3. ✅ **أضف الـ Routes** في Flutter App
4. ✅ **اختبر التكامل** الكامل
5. ✅ **حدد الأسعار** للمستخدمين النهائيين

**الوضع النهائي:** ميزة AI Video generation احترافية جاهزة للإنتاج! 🎬✨