# دليل استخدام TikTok API باستخدام Apify

## نظرة عامة
تم دمج Apify API لجمع البيانات والإحصائيات من TikTok في تطبيقك. هذا يتيح لك الوصول إلى معلومات المستخدمين، المنشورات، التعليقات، والمزيد.

## الإعداد الأولي

### 1. الحصول على Apify API Token
1. قم بزيارة [Apify](https://apify.com)
2. قم بإنشاء حساب أو تسجيل الدخول
3. انتقل إلى Settings → Integrations → API tokens
4. انسخ API Token الخاص بك

### 2. إضافة API Token إلى ملف .env
```env
APIFY_API_TOKEN=apify_api_YOUR_TOKEN_HERE
```

### 3. رفع الملفات إلى السيرفر
قم برفع الملفات التالية إلى السيرفر:
- `backend/app/Services/ApifyTikTokService.php`
- `backend/app/Http/Controllers/Api/TikTokAnalyticsController.php`
- `backend/routes/api.php` (محدث)
- `backend/config/services.php` (محدث)
- `backend/.env` (محدث)

### 4. تنظيف الـ Cache
```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan config:cache
php artisan route:cache
```

## نقاط النهاية المتاحة (API Endpoints)

جميع النقاط التالية تتطلب مصادقة (Authentication) باستخدام Sanctum Token.

### الرابط الأساسي
```
https://www.mediapro.social/api/tiktok/
```

### 1. الحصول على ملف شخصي لمستخدم TikTok
```http
POST /api/tiktok/user/profile
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "username": "username_here"
}
```

**مثال باستخدام cURL:**
```bash
curl -X POST https://www.mediapro.social/api/tiktok/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SANCTUM_TOKEN" \
  -d '{"username": "tiktok_username"}'
```

**الرد:**
```json
{
  "success": true,
  "data": [
    {
      "user_id": "123456789",
      "sec_user_id": "MS4wLjABAAAA...",
      "username": "username",
      "nickname": "Display Name",
      "avatar": "https://...",
      "bio": "Bio description",
      "follower_count": 10000,
      "following_count": 500,
      "likes_count": 50000,
      "video_count": 100
    }
  ]
}
```

### 2. الحصول على منشورات المستخدم
```http
POST /api/tiktok/user/posts
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "user_id": "123456789",
  "sec_user_id": "MS4wLjABAAAA...",
  "count": 20
}
```

### 3. الحصول على متابعي المستخدم
```http
POST /api/tiktok/user/followers
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "user_id": "123456789",
  "sec_user_id": "MS4wLjABAAAA...",
  "count": 50
}
```

### 4. الحصول على من يتابعهم المستخدم
```http
POST /api/tiktok/user/following
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "user_id": "123456789",
  "sec_user_id": "MS4wLjABAAAA...",
  "count": 50
}
```

### 5. الحصول على تفاصيل منشور معين
```http
POST /api/tiktok/post/details
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "post_id": "7123456789012345678"
}
```

### 6. الحصول على تعليقات منشور
```http
POST /api/tiktok/post/comments
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "post_id": "7123456789012345678",
  "count": 100
}
```

### 7. البحث عن مستخدمين
```http
POST /api/tiktok/search/users
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "keyword": "search_term",
  "count": 20
}
```

### 8. البحث عن منشورات
```http
POST /api/tiktok/search/posts
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "keyword": "search_term",
  "count": 20
}
```

### 9. البحث عن هاشتاجات
```http
POST /api/tiktok/search/hashtags
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "keyword": "search_term",
  "count": 20
}
```

### 10. تحميل فيديو بدون علامة مائية
```http
POST /api/tiktok/video/download
Content-Type: application/json
Authorization: Bearer {sanctum_token}

{
  "post_id": "7123456789012345678"
}
```

## استخدام من تطبيق Flutter

### مثال على استدعاء API من Flutter:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class TikTokService {
  final String baseUrl = 'https://www.mediapro.social/api';
  final String token;

  TikTokService(this.token);

  Future<Map<String, dynamic>> getUserProfile(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tiktok/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<Map<String, dynamic>> searchPosts(String keyword, {int count = 10}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tiktok/search/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'keyword': keyword,
        'count': count,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search posts');
    }
  }

  Future<Map<String, dynamic>> downloadVideo(String postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tiktok/video/download'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'post_id': postId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to download video');
    }
  }
}

// استخدام:
void main() async {
  final tiktokService = TikTokService('YOUR_SANCTUM_TOKEN');

  // الحصول على ملف شخصي
  final profile = await tiktokService.getUserProfile('username');
  print(profile);

  // البحث عن منشورات
  final posts = await tiktokService.searchPosts('flutter', count: 20);
  print(posts);

  // تحميل فيديو
  final video = await tiktokService.downloadVideo('7123456789012345678');
  print(video);
}
```

## معلومات مهمة

### الأسعار والحدود
- Apify لديه خطة مجانية محدودة
- تحقق من [صفحة الأسعار](https://apify.com/pricing) لمعرفة الحدود
- يمكنك تتبع الاستخدام من لوحة تحكم Apify

### وقت المعالجة
- كل طلب قد يستغرق من 10 ثانية إلى 5 دقائق حسب حجم البيانات
- الخدمة تنتظر حتى تكتمل المعالجة قبل إرجاع النتائج

### معالجة الأخطاء
الردود في حالة الخطأ:
```json
{
  "success": false,
  "message": "Failed to fetch user profile"
}
```

أو في حالة خطأ في التحقق:
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "username": ["The username field is required."]
  }
}
```

## الأمان والخصوصية
- جميع الطلبات محمية بـ Sanctum Authentication
- يتم تسجيل جميع الأخطاء في ملفات الـ Logs
- يُنصح بتطبيق Rate Limiting إضافي حسب الحاجة

## الدعم والمساعدة
- وثائق Apify: https://docs.apify.com
- TikTok Scraper Actor: https://apify.com/naqsZgh7DhGajnD5z

## أمثلة عملية

### مثال 1: الحصول على إحصائيات مستخدم
```bash
curl -X POST https://www.mediapro.social/api/tiktok/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"username": "charlidamelio"}'
```

### مثال 2: البحث عن فيديوهات
```bash
curl -X POST https://www.mediapro.social/api/tiktok/search/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"keyword": "dubai", "count": 30}'
```

### مثال 3: تحليل هاشتاج معين
```bash
curl -X POST https://www.mediapro.social/api/tiktok/search/hashtags \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"keyword": "travel", "count": 20}'
```

## الملفات المضافة

1. **backend/app/Services/ApifyTikTokService.php**
   - خدمة PHP للتواصل مع Apify API
   - تحتوي على جميع الوظائف اللازمة لجمع بيانات TikTok

2. **backend/app/Http/Controllers/Api/TikTokAnalyticsController.php**
   - Controller للتعامل مع طلبات TikTok Analytics
   - يحتوي على جميع نقاط النهاية (Endpoints)

3. **backend/routes/api.php**
   - تم إضافة Routes جديدة لـ TikTok Analytics

4. **backend/config/services.php**
   - تم إضافة إعدادات Apify

5. **backend/.env**
   - تم إضافة APIFY_API_TOKEN

---

تم إنشاء هذا الدليل بواسطة Claude Code
التاريخ: 2025-11-18
