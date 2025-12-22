# دليل الاستخدام السريع لـ TikTok API

## ما الذي تم إضافته؟
تم دمج Apify API في تطبيقك لجمع البيانات من TikTok بدون الحاجة إلى OAuth. يمكنك الآن:
- الحصول على معلومات أي مستخدم TikTok
- جمع المنشورات والفيديوهات
- الحصول على عدد المتابعين والتفاعلات
- البحث في TikTok عن مستخدمين ومنشورات
- تحميل الفيديوهات بدون علامة مائية

## خطوات التفعيل

### 1. احصل على API Token من Apify
1. افتح [Apify.com](https://apify.com) وسجل حساب مجاني
2. اذهب إلى Settings → Integrations → API tokens
3. انسخ الـ API Token

### 2. أضف Token في ملف .env
افتح ملف `.env` في الـ backend وأضف:
```
APIFY_API_TOKEN=apify_api_YOUR_TOKEN_HERE
```

### 3. ارفع الملفات للسيرفر
الملفات التي تم إنشاؤها:
- `backend/app/Services/ApifyTikTokService.php` ← خدمة الاتصال بـ Apify
- `backend/app/Http/Controllers/Api/TikTokAnalyticsController.php` ← المتحكم
- `backend/routes/api.php` ← تم تحديثه
- `backend/config/services.php` ← تم تحديثه

### 4. نظف الكاش على السيرفر
```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan config:cache
php artisan route:cache
```

## كيفية الاستخدام

### الوصول للـ API
الرابط الأساسي:
```
https://www.mediapro.social/api/tiktok/
```

### مثال: الحصول على ملف شخصي
```bash
curl -X POST https://www.mediapro.social/api/tiktok/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SANCTUM_TOKEN" \
  -d '{"username": "اسم_المستخدم"}'
```

### الوظائف المتاحة:
1. `/user/profile` - معلومات المستخدم
2. `/user/posts` - منشورات المستخدم
3. `/user/followers` - متابعو المستخدم
4. `/user/following` - من يتابعهم المستخدم
5. `/post/details` - تفاصيل منشور معين
6. `/post/comments` - تعليقات منشور
7. `/search/users` - البحث عن مستخدمين
8. `/search/posts` - البحث عن منشورات
9. `/search/hashtags` - البحث عن هاشتاجات
10. `/video/download` - تحميل فيديو بدون علامة

## الاستخدام في Flutter

```dart
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
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load profile');
  }
}
```

## ملاحظات مهمة

### الحساب المجاني
- Apify يوفر حساب مجاني محدود
- يمكنك ترقية الحساب لاحقاً إذا احتجت
- راقب استخدامك من لوحة تحكم Apify

### وقت الاستجابة
- كل طلب قد يستغرق من 10 ثواني إلى 5 دقائق
- البيانات الكبيرة تأخذ وقت أطول
- الخدمة تنتظر حتى تكتمل البيانات

### الأمان
- جميع الطلبات محمية بـ Authentication
- يجب إرسال Sanctum Token مع كل طلب
- البيانات يتم تسجيلها في Logs

## الدعم الفني
للمزيد من المعلومات:
- وثائق Apify: https://docs.apify.com
- دليل التفصيلي: راجع ملف `TIKTOK_APIFY_GUIDE.md`

---
تاريخ الإنشاء: 2025-11-18
