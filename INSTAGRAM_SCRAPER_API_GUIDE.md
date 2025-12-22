# Instagram Hashtag Scraper API - دليل الاستخدام

تم دمج **Instagram Hashtag Scraper** من Apify في التطبيق بنجاح! 🎉

## 📋 المميزات المتوفرة:

1. **البحث بالهاشتاج** - استخراج منشورات Instagram حسب هاشتاج معين
2. **البحث بالكلمة المفتاحية** - استخراج منشورات حسب كلمة مفتاحية
3. **تحليل الهاشتاجات الرائجة** - تحليل عدة هاشتاجات ومقارنتها
4. **اقتراحات الهاشتاجات** - الحصول على اقتراحات تلقائية
5. **آخر النتائج** - الحصول على آخر عملية استخراج

---

## 🔗 API Endpoints

### 1. استخراج منشورات بالهاشتاج
```
POST https://mediaprosocial.io/api/instagram/scrape/hashtag
```

**الـ Body (JSON):**
```json
{
    "hashtag": "webscraping",
    "max_posts": 20,
    "content_type": "posts"
}
```

**الاستجابة:**
```json
{
    "success": true,
    "message": "Instagram posts scraped successfully",
    "data": [
        {
            "id": "...",
            "caption": "...",
            "hashtags": ["#webscraping", "#coding"],
            "likesCount": 1500,
            "commentsCount": 120,
            "url": "https://instagram.com/p/...",
            "displayUrl": "...",
            "ownerUsername": "username",
            "timestamp": "2025-11-18T10:00:00Z"
        }
    ],
    "count": 20,
    "hashtag": "#webscraping"
}
```

---

### 2. استخراج منشورات بالكلمة المفتاحية
```
POST https://mediaprosocial.io/api/instagram/scrape/keyword
```

**الـ Body (JSON):**
```json
{
    "keyword": "social media",
    "max_posts": 15
}
```

---

### 3. تحليل الهاشتاجات الرائجة
```
POST https://mediaprosocial.io/api/instagram/analyze/hashtags
```

**الـ Body (JSON):**
```json
{
    "hashtags": ["webscraping", "coding", "programming"],
    "max_posts_per_hashtag": 10
}
```

**الاستجابة:**
```json
{
    "success": true,
    "message": "Hashtags analyzed successfully",
    "data": [
        {
            "hashtag": "webscraping",
            "total_posts": 10,
            "total_likes": 15000,
            "total_comments": 1200,
            "avg_likes": 1500,
            "avg_comments": 120,
            "engagement_rate": 1620,
            "posts": [...]
        }
    ],
    "analyzed_count": 3
}
```

---

### 4. الحصول على اقتراحات هاشتاجات
```
POST https://mediaprosocial.io/api/instagram/suggest/hashtags
```

**الـ Body (JSON):**
```json
{
    "content": "هذا منشور عن تطوير المواقع والبرمجة",
    "limit": 15
}
```

**الاستجابة:**
```json
{
    "success": true,
    "message": "Hashtag suggestions generated",
    "suggestions": [
        "#منشور", "#عن", "#تطوير", "#المواقع",
        "#البرمجة", "#instagood", "#photooftheday"
    ],
    "count": 15
}
```

---

### 5. الحصول على آخر النتائج
```
GET https://mediaprosocial.io/api/instagram/last-results
```

---

## 🔐 المصادقة (Authentication)

جميع الـ endpoints تتطلب Bearer Token:

```
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## 📊 البيانات المستخرجة لكل منشور:

- **id**: معرف المنشور
- **shortCode**: الكود المختصر
- **caption**: النص/التعليق
- **hashtags**: قائمة الهاشتاجات
- **mentions**: الإشارات
- **url**: رابط المنشور
- **commentsCount**: عدد التعليقات
- **likesCount**: عدد الإعجابات
- **timestamp**: وقت النشر
- **displayUrl**: رابط الصورة
- **images**: قائمة الصور
- **videoUrl**: رابط الفيديو (إن وجد)
- **videoPlayCount**: عدد المشاهدات للفيديو
- **isVideo**: هل هو فيديو
- **type**: نوع المنشور (post/reel)
- **ownerUsername**: اسم المستخدم للناشر
- **ownerFullName**: الاسم الكامل
- **locationName**: اسم الموقع
- **locationId**: معرف الموقع

---

## 💡 حالات الاستخدام:

### 1. البحث عن محتوى شائع
```bash
curl -X POST https://mediaprosocial.io/api/instagram/scrape/hashtag \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "hashtag": "travel",
    "max_posts": 50,
    "content_type": "posts"
  }'
```

### 2. تحليل المنافسين
```bash
curl -X POST https://mediaprosocial.io/api/instagram/analyze/hashtags \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "hashtags": ["mycompany", "competitor1", "competitor2"],
    "max_posts_per_hashtag": 20
  }'
```

### 3. اكتشاف الترندات
```bash
curl -X POST https://mediaprosocial.io/api/instagram/scrape/keyword \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "keyword": "2025 trends",
    "max_posts": 30
  }'
```

---

## ⚠️ ملاحظات مهمة:

1. **الحد الأقصى للمنشورات**: 100 منشور لكل طلب
2. **Rate Limiting**: يُنصح بعدم إرسال أكثر من 10 طلبات في الدقيقة
3. **النسخة المجانية**: تغطي فقط الصفحة الأولى من النتائج
4. **Apify Token**: تم تكوينه مسبقاً في الباك اند

---

## 🚀 أمثلة Flutter/Dart:

### استخراج منشورات بالهاشتاج
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> scrapeInstagramHashtag() async {
  final response = await http.post(
    Uri.parse('https://mediaprosocial.io/api/instagram/scrape/hashtag'),
    headers: {
      'Authorization': 'Bearer YOUR_TOKEN',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'hashtag': 'travel',
      'max_posts': 20,
      'content_type': 'posts',
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Success: ${data['message']}');
    print('Posts count: ${data['count']}');

    // عرض البيانات
    for (var post in data['data']) {
      print('Post: ${post['caption']}');
      print('Likes: ${post['likesCount']}');
      print('Comments: ${post['commentsCount']}');
    }
  }
}
```

### تحليل الهاشتاجات
```dart
Future<void> analyzeTrendingHashtags() async {
  final response = await http.post(
    Uri.parse('https://mediaprosocial.io/api/instagram/analyze/hashtags'),
    headers: {
      'Authorization': 'Bearer YOUR_TOKEN',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'hashtags': ['travel', 'photography', 'food'],
      'max_posts_per_hashtag': 10,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    for (var analysis in data['data']) {
      print('Hashtag: #${analysis['hashtag']}');
      print('Total Likes: ${analysis['total_likes']}');
      print('Avg Engagement: ${analysis['engagement_rate']}');
    }
  }
}
```

---

## 📝 التكلفة:

- **$2.30 لكل 1000 نتيجة** من Apify
- النسخة المجانية محدودة بالصفحة الأولى فقط

---

## ✅ التأكد من عمل API:

```bash
# اختبار اقتراحات الهاشتاجات (لا يحتاج Apify)
curl -X POST https://mediaprosocial.io/api/instagram/suggest/hashtags \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "This is a test post about web development",
    "limit": 10
  }'
```

---

## 🔧 استكشاف الأخطاء:

### خطأ 401 (Unauthorized)
- تأكد من Bearer Token صحيح

### خطأ 422 (Validation Error)
- تحقق من البيانات المُرسلة (hashtag مطلوب، max_posts بين 1-100)

### خطأ 500 (Server Error)
- تحقق من Apify API Token في .env
- تحقق من logs في `/storage/logs/laravel.log`

---

## 📞 الدعم:

- **API Token**: تم تكوينه مسبقاً
- **Base URL**: https://mediaprosocial.io/api
- **Documentation**: https://docs.apify.com/api/v2

---

**تم التطوير بنجاح! 🎉**
