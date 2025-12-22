# TikTok API Integration - دليل الاستخدام الشامل

<div dir="rtl">

## 🎯 نظرة سريعة

تم دمج Apify API في تطبيق Social Media Manager لجمع البيانات من TikTok بدون الحاجة لـ OAuth. يمكنك الآن الوصول إلى:

- ✅ معلومات أي مستخدم TikTok
- ✅ منشورات وفيديوهات المستخدمين
- ✅ عدد المتابعين والتفاعلات
- ✅ البحث في TikTok (مستخدمين، منشورات، هاشتاجات)
- ✅ تحميل الفيديوهات بدون علامة مائية
- ✅ التعليقات والإحصائيات التفصيلية

---

## 📦 الملفات المضافة

### ملفات النظام الأساسية:
```
backend/
├── app/
│   ├── Services/
│   │   └── ApifyTikTokService.php          ← الخدمة الأساسية
│   └── Http/Controllers/Api/
│       └── TikTokAnalyticsController.php   ← المتحكم
├── routes/
│   └── api.php                             ← محدث (Routes جديدة)
├── config/
│   └── services.php                        ← محدث (إعدادات Apify)
└── .env                                    ← محدث (APIFY_API_TOKEN)
```

### ملفات التوثيق والدعم:
```
├── TIKTOK_APIFY_GUIDE.md              ← دليل شامل (EN)
├── دليل_استخدام_TikTok_Apify.md       ← دليل سريع (AR)
├── TIKTOK_INTEGRATION_SUMMARY.md      ← ملخص التكامل
├── test_tiktok_api.md                 ← أمثلة اختبار
├── deploy_tiktok_api.bat              ← سكريبت الرفع
└── README_TIKTOK_API.md               ← هذا الملف
```

---

## ⚡ البدء السريع (5 دقائق)

### الخطوة 1: احصل على Apify Token
```
1. اذهب إلى: https://apify.com/sign-up
2. سجل حساب مجاني
3. انتقل إلى: Settings → Integrations → API tokens
4. انسخ Token وقم بحفظه
```

### الخطوة 2: ارفع الملفات
```batch
# شغّل هذا السكريبت:
deploy_tiktok_api.bat
```

أو يدوياً باستخدام الأوامر التالية:
```bash
# ملاحظة: تم إنشاء السكريبت تلقائياً
# فقط قم بتشغيله وسيرفع جميع الملفات
```

### الخطوة 3: أضف Token في .env
```bash
# على السيرفر:
ssh u126213189@82.25.83.217 -p 65002

# حرر ملف .env:
nano /home/u126213189/domains/mediaprosocial.io/public_html/.env

# أضف في نهاية الملف:
APIFY_API_TOKEN=apify_api_YOUR_TOKEN_HERE

# احفظ واخرج (Ctrl+X ثم Y)
```

### الخطوة 4: نظف الكاش
```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan config:cache
php artisan route:cache
```

### الخطوة 5: اختبر!
```bash
curl -X POST https://www.mediapro.social/api/tiktok/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SANCTUM_TOKEN" \
  -d '{"username": "khaby.lame"}'
```

---

## 🔌 نقاط النهاية (API Endpoints)

### الرابط الأساسي:
```
https://www.mediapro.social/api/tiktok/
```

### جميع Endpoints تحتاج:
- ✅ Sanctum Authentication Token
- ✅ Content-Type: application/json

### القائمة الكاملة:

| Endpoint | الوصف | المعاملات |
|---------|-------|-----------|
| `POST /user/profile` | معلومات المستخدم | `username` |
| `POST /user/posts` | منشورات المستخدم | `user_id`, `sec_user_id`, `count` |
| `POST /user/followers` | المتابعون | `user_id`, `sec_user_id`, `count` |
| `POST /user/following` | من يتابع | `user_id`, `sec_user_id`, `count` |
| `POST /post/details` | تفاصيل منشور | `post_id` |
| `POST /post/comments` | تعليقات منشور | `post_id`, `count` |
| `POST /search/users` | بحث مستخدمين | `keyword`, `count` |
| `POST /search/posts` | بحث منشورات | `keyword`, `count` |
| `POST /search/hashtags` | بحث هاشتاجات | `keyword`, `count` |
| `POST /video/download` | تحميل فيديو | `post_id` |

---

## 💡 أمثلة الاستخدام

### من cURL:
```bash
# مثال 1: الحصول على ملف شخصي
curl -X POST https://www.mediapro.social/api/tiktok/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"username": "charlidamelio"}'

# مثال 2: البحث عن منشورات
curl -X POST https://www.mediapro.social/api/tiktok/search/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"keyword": "dubai", "count": 20}'
```

### من Flutter:
```dart
class TikTokService {
  final String baseUrl = 'https://www.mediapro.social/api';
  final String token;

  TikTokService(this.token);

  // الحصول على ملف شخصي
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

  // البحث عن منشورات
  Future<List<dynamic>> searchPosts(String keyword, {int count = 10}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tiktok/search/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'keyword': keyword, 'count': count}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    }
    throw Exception('Failed to search posts');
  }

  // تحميل فيديو بدون علامة مائية
  Future<String> downloadVideo(String postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tiktok/video/download'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'post_id': postId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['download_url'];
    }
    throw Exception('Failed to download video');
  }
}

// الاستخدام:
void main() async {
  final tiktok = TikTokService('YOUR_SANCTUM_TOKEN');

  // مثال 1
  final profile = await tiktok.getUserProfile('khaby.lame');
  print('Followers: ${profile['data'][0]['follower_count']}');

  // مثال 2
  final posts = await tiktok.searchPosts('travel', count: 20);
  print('Found ${posts.length} posts');

  // مثال 3
  final videoUrl = await tiktok.downloadVideo('7123456789012345678');
  print('Download URL: $videoUrl');
}
```

---

## 🎨 حالات الاستخدام

### 1. لوحة إحصائيات TikTok
```dart
class TikTokAnalyticsDashboard extends StatelessWidget {
  final TikTokService tiktokService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tiktokService.getUserProfile('username'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data['data'][0];
          return Column(
            children: [
              StatCard(
                title: 'المتابعون',
                value: data['follower_count'],
              ),
              StatCard(
                title: 'الإعجابات',
                value: data['likes_count'],
              ),
              StatCard(
                title: 'الفيديوهات',
                value: data['video_count'],
              ),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### 2. البحث والاستكشاف
```dart
class TikTokSearchScreen extends StatefulWidget {
  @override
  _TikTokSearchScreenState createState() => _TikTokSearchScreenState();
}

class _TikTokSearchScreenState extends State<TikTokSearchScreen> {
  final TikTokService tiktokService = TikTokService('TOKEN');
  List<dynamic> searchResults = [];

  void searchPosts(String keyword) async {
    final results = await tiktokService.searchPosts(keyword, count: 30);
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onSubmitted: searchPosts,
          decoration: InputDecoration(
            hintText: 'ابحث في TikTok...',
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final post = searchResults[index];
              return VideoCard(post: post);
            },
          ),
        ),
      ],
    );
  }
}
```

### 3. تحليل المنافسين
```dart
class CompetitorAnalysis {
  final TikTokService tiktokService;

  CompetitorAnalysis(this.tiktokService);

  Future<Map<String, dynamic>> analyzeCompetitor(String username) async {
    // الحصول على الملف الشخصي
    final profile = await tiktokService.getUserProfile(username);

    // الحصول على آخر المنشورات
    final posts = await tiktokService.getUserPosts(
      profile['data'][0]['user_id'],
      profile['data'][0]['sec_user_id'],
      count: 50,
    );

    // تحليل البيانات
    return {
      'username': username,
      'total_followers': profile['data'][0]['follower_count'],
      'engagement_rate': calculateEngagement(posts),
      'posting_frequency': calculateFrequency(posts),
      'top_performing_posts': getTopPosts(posts),
    };
  }
}
```

---

## ⚠️ ملاحظات هامة

### الحدود والقيود:
1. **Apify Free Plan:**
   - محدود بعدد معين من الطلبات شهرياً
   - راجع [Apify Pricing](https://apify.com/pricing)

2. **وقت المعالجة:**
   - 10 ثواني - 5 دقائق لكل طلب
   - يعتمد على حجم البيانات

3. **Rate Limiting:**
   - لا تفرط في الطلبات
   - استخدم Caching عند الإمكان

### الأمان:
- 🔒 جميع الطلبات محمية بـ Authentication
- 🔒 لا تشارك Apify Token
- 🔒 راجع Laravel Logs بانتظام

---

## 🐛 استكشاف الأخطاء

### خطأ: "Unauthenticated"
**الحل:**
```bash
# تحقق من Sanctum Token
# تأكد من إرساله في Header:
# Authorization: Bearer YOUR_TOKEN
```

### خطأ: "Failed to fetch user profile"
**الحل:**
```bash
# 1. تحقق من Apify Token في .env
# 2. تحقق من رصيد Apify
# 3. راجع Laravel logs:
tail -f storage/logs/laravel.log
```

### الطلب يستغرق وقتاً طويلاً
**طبيعي!** Apify يجمع البيانات من TikTok وهذا يستغرق وقتاً.
- استخدم Loading Indicators في تطبيقك
- اضبط Timeout المناسب (5 دقائق على الأقل)

---

## 📚 الموارد الإضافية

### الوثائق:
- 📖 [دليل شامل (EN)](TIKTOK_APIFY_GUIDE.md)
- 📖 [دليل سريع (AR)](دليل_استخدام_TikTok_Apify.md)
- 📖 [ملخص التكامل](TIKTOK_INTEGRATION_SUMMARY.md)
- 📖 [أمثلة الاختبار](test_tiktok_api.md)

### روابط مفيدة:
- 🌐 [Apify Docs](https://docs.apify.com)
- 🌐 [TikTok Scraper Actor](https://apify.com/naqsZgh7DhGajnD5z)
- 🌐 [Laravel Docs](https://laravel.com/docs)

---

## ✅ Checklist النشر

قبل استخدام API تأكد من:

- [ ] حصلت على Apify API Token
- [ ] رفعت جميع الملفات للسيرفر
- [ ] أضفت Token في .env
- [ ] نظفت الكاش (config:clear, cache:clear)
- [ ] أعدت بناء الكاش (config:cache, route:cache)
- [ ] اختبرت API endpoint واحد على الأقل
- [ ] تحققت من Laravel logs

---

## 🚀 الخلاصة

تم دمج Apify بنجاح! الآن لديك:
- ✅ 10 Endpoints جاهزة للاستخدام
- ✅ وثائق شاملة بالعربية والإنجليزية
- ✅ أمثلة عملية للاستخدام
- ✅ سكريبت رفع تلقائي

**ما عليك سوى:**
1. الحصول على Apify Token
2. رفع الملفات
3. البدء في الاستخدام!

---

## 📞 الدعم

إذا واجهت أي مشاكل:
1. راجع [استكشاف الأخطاء](#-استكشاف-الأخطاء)
2. راجع Laravel Logs على السيرفر
3. تحقق من Apify Dashboard للتأكد من الرصيد
4. راجع الوثائق المرفقة

---

**تم بواسطة:** Claude Code
**التاريخ:** 2025-11-18
**الإصدار:** 1.0
**الحالة:** ✅ جاهز للإنتاج

بالتوفيق! 🎉

</div>
