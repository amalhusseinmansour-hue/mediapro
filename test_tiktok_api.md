# اختبار TikTok API - أمثلة سريعة

## المتطلبات
- Sanctum Token (من تسجيل دخول المستخدم)
- Apify API Token (مضاف في .env)

## الحصول على Sanctum Token

### 1. تسجيل دخول للحصول على Token:
```bash
curl -X POST https://www.mediapro.social/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+971501234567",
    "password": "your_password"
  }'
```

**الرد:**
```json
{
  "success": true,
  "token": "1|abc123def456...",
  "user": {...}
}
```

استخدم الـ `token` في جميع الطلبات التالية.

---

## اختبار الوظائف

### 1. اختبار: الحصول على ملف شخصي

```bash
curl -X POST https://www.mediapro.social/api/tiktok/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1|abc123def456..." \
  -d '{
    "username": "khaby.lame"
  }'
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "data": [
    {
      "user_id": "...",
      "sec_user_id": "...",
      "username": "khaby.lame",
      "nickname": "Khabane lame",
      "follower_count": 162000000,
      "following_count": 50,
      "likes_count": 2500000000,
      "video_count": 500
    }
  ]
}
```

---

### 2. اختبار: البحث عن منشورات

```bash
curl -X POST https://www.mediapro.social/api/tiktok/search/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1|abc123def456..." \
  -d '{
    "keyword": "dubai",
    "count": 5
  }'
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "data": [
    {
      "aweme_id": "...",
      "desc": "Amazing Dubai!",
      "author": {...},
      "statistics": {
        "play_count": 1000000,
        "share_count": 5000,
        "comment_count": 2000,
        "digg_count": 50000
      },
      "video": {...}
    },
    ...
  ]
}
```

---

### 3. اختبار: البحث عن هاشتاج

```bash
curl -X POST https://www.mediapro.social/api/tiktok/search/hashtags \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1|abc123def456..." \
  -d '{
    "keyword": "travel",
    "count": 10
  }'
```

---

### 4. اختبار: تحميل فيديو بدون علامة مائية

```bash
curl -X POST https://www.mediapro.social/api/tiktok/video/download \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1|abc123def456..." \
  -d '{
    "post_id": "7123456789012345678"
  }'
```

---

### 5. اختبار: الحصول على تعليقات منشور

```bash
curl -X POST https://www.mediapro.social/api/tiktok/post/comments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1|abc123def456..." \
  -d '{
    "post_id": "7123456789012345678",
    "count": 20
  }'
```

---

## اختبار في Postman

### الإعداد:
1. افتح Postman
2. أنشئ Collection جديد باسم "TikTok API"
3. أضف متغير `base_url` = `https://www.mediapro.social/api`
4. أضف متغير `token` = Sanctum Token الخاص بك

### طلب جديد:
- **Method:** POST
- **URL:** `{{base_url}}/tiktok/user/profile`
- **Headers:**
  - Content-Type: application/json
  - Authorization: Bearer {{token}}
- **Body (raw JSON):**
```json
{
  "username": "khaby.lame"
}
```

---

## اختبار في Flutter

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // استبدل بـ Token الخاص بك
  final token = '1|abc123def456...';
  final baseUrl = 'https://www.mediapro.social/api';

  // اختبار 1: الحصول على ملف شخصي
  print('Test 1: Get User Profile');
  final profileResponse = await http.post(
    Uri.parse('$baseUrl/tiktok/user/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'username': 'khaby.lame'}),
  );
  print('Status: ${profileResponse.statusCode}');
  print('Body: ${profileResponse.body}');
  print('---\n');

  // اختبار 2: البحث عن منشورات
  print('Test 2: Search Posts');
  final searchResponse = await http.post(
    Uri.parse('$baseUrl/tiktok/search/posts'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'keyword': 'dubai', 'count': 5}),
  );
  print('Status: ${searchResponse.statusCode}');
  print('Body: ${searchResponse.body}');
  print('---\n');

  // اختبار 3: البحث عن مستخدمين
  print('Test 3: Search Users');
  final usersResponse = await http.post(
    Uri.parse('$baseUrl/tiktok/search/users'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'keyword': 'comedy', 'count': 10}),
  );
  print('Status: ${usersResponse.statusCode}');
  print('Body: ${usersResponse.body}');
  print('---\n');
}
```

---

## حالات الأخطاء المحتملة

### خطأ 401: Unauthorized
```json
{
  "message": "Unauthenticated."
}
```
**الحل:** تحقق من Sanctum Token

### خطأ 422: Validation Error
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "username": ["The username field is required."]
  }
}
```
**الحل:** تحقق من البيانات المرسلة

### خطأ 500: Server Error
```json
{
  "success": false,
  "message": "Failed to fetch user profile"
}
```
**الحل:**
- تحقق من Apify API Token في .env
- راجع Laravel logs على السيرفر
- تحقق من رصيد Apify

---

## فحص الـ Routes

```bash
# تحقق من أن Routes مسجلة
curl -X GET https://www.mediapro.social/api/health
```

إذا كانت الاستجابة:
```json
{
  "status": "ok",
  "timestamp": "2025-11-18T..."
}
```
فهذا يعني أن Laravel يعمل بشكل صحيح.

---

## نصائح الاختبار

1. **ابدأ بـ Health Check:**
   ```bash
   curl https://www.mediapro.social/api/health
   ```

2. **احصل على Token صالح:**
   استخدم `/api/auth/login` للحصول على token

3. **اختبر بمستخدم مشهور أولاً:**
   - khaby.lame
   - charlidamelio
   - addisonre

4. **راقب وقت الاستجابة:**
   - الطلبات قد تستغرق وقتاً (10 ثواني - 5 دقائق)
   - استخدم timeout مناسب في تطبيقك

5. **راجع Logs:**
   ```bash
   # على السيرفر:
   tail -f /path/to/laravel/storage/logs/laravel.log
   ```

---

## Checklist قبل الاختبار

- [ ] Apify API Token مضاف في .env
- [ ] تم رفع جميع الملفات للسيرفر
- [ ] تم تنظيف الكاش (config:clear, route:clear)
- [ ] تم إعادة بناء الكاش (config:cache, route:cache)
- [ ] لديك Sanctum Token صالح
- [ ] الخادم متصل بالإنترنت ويمكنه الوصول لـ Apify API

---

## موارد إضافية

- راجع `TIKTOK_APIFY_GUIDE.md` للتفاصيل الكاملة
- راجع `دليل_استخدام_TikTok_Apify.md` للدليل العربي
- وثائق Apify: https://docs.apify.com
- TikTok Scraper: https://apify.com/naqsZgh7DhGajnD5z

---

**نجاح الاختبار يعتمد على:**
1. ✅ Apify Token صحيح ولديه رصيد كافي
2. ✅ Laravel يعمل بشكل صحيح
3. ✅ Routes مسجلة بشكل صحيح
4. ✅ Authentication يعمل (Sanctum)

بالتوفيق في الاختبار! 🚀
