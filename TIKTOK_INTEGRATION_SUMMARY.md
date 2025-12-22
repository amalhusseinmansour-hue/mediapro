# ملخص دمج TikTok API باستخدام Apify

## ما تم إنجازه؟

تم دمج Apify API في تطبيق Social Media Manager لجمع البيانات والإحصائيات من TikTok. هذا يوفر لك إمكانية الوصول إلى معلومات TikTok بدون الحاجة لـ OAuth المعقد.

## الملفات المضافة/المحدثة

### 1. ملفات جديدة:
- ✅ `backend/app/Services/ApifyTikTokService.php`
  - خدمة PHP للتواصل مع Apify API
  - تحتوي على 10 وظائف رئيسية لجمع بيانات TikTok

- ✅ `backend/app/Http/Controllers/Api/TikTokAnalyticsController.php`
  - Controller يحتوي على 10 endpoints لـ TikTok Analytics
  - معالجة طلبات HTTP والتحقق من البيانات

### 2. ملفات محدثة:
- ✅ `backend/routes/api.php`
  - إضافة 10 routes جديدة تحت `/api/tiktok/`

- ✅ `backend/config/services.php`
  - إضافة إعدادات Apify

- ✅ `backend/.env`
  - إضافة متغير `APIFY_API_TOKEN`

### 3. ملفات دليل الاستخدام:
- 📄 `TIKTOK_APIFY_GUIDE.md` - دليل شامل بالإنجليزية
- 📄 `دليل_استخدام_TikTok_Apify.md` - دليل سريع بالعربية
- 📄 `deploy_tiktok_api.bat` - سكريبت الرفع للسيرفر

## الوظائف المتاحة

### 1. معلومات المستخدم
- `POST /api/tiktok/user/profile` - الحصول على ملف شخصي
- `POST /api/tiktok/user/posts` - منشورات المستخدم
- `POST /api/tiktok/user/followers` - متابعو المستخدم
- `POST /api/tiktok/user/following` - من يتابعهم المستخدم

### 2. معلومات المنشورات
- `POST /api/tiktok/post/details` - تفاصيل منشور معين
- `POST /api/tiktok/post/comments` - تعليقات المنشور

### 3. البحث
- `POST /api/tiktok/search/users` - البحث عن مستخدمين
- `POST /api/tiktok/search/posts` - البحث عن منشورات
- `POST /api/tiktok/search/hashtags` - البحث عن هاشتاجات

### 4. تحميل
- `POST /api/tiktok/video/download` - تحميل فيديو بدون علامة مائية

## خطوات التفعيل

### الخطوة 1: احصل على Apify API Token
```
1. اذهب إلى https://apify.com
2. سجل حساب مجاني
3. Settings → Integrations → API tokens
4. انسخ الـ Token
```

### الخطوة 2: ارفع الملفات للسيرفر
```bash
# شغّل السكريبت:
deploy_tiktok_api.bat
```

أو يدوياً:
```bash
# رفع الخدمة
pscp backend/app/Services/ApifyTikTokService.php server:/path/to/app/Services/

# رفع Controller
pscp backend/app/Http/Controllers/Api/TikTokAnalyticsController.php server:/path/to/app/Http/Controllers/Api/

# رفع Routes
pscp backend/routes/api.php server:/path/to/routes/

# رفع Config
pscp backend/config/services.php server:/path/to/config/
```

### الخطوة 3: أضف API Token في .env
```env
APIFY_API_TOKEN=apify_api_YOUR_TOKEN_HERE
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

## أمثلة الاستخدام

### من cURL:
```bash
curl -X POST https://www.mediapro.social/api/tiktok/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SANCTUM_TOKEN" \
  -d '{"username": "charlidamelio"}'
```

### من Flutter:
```dart
final response = await http.post(
  Uri.parse('https://www.mediapro.social/api/tiktok/user/profile'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({'username': 'username'}),
);
```

### من JavaScript (Node.js):
```javascript
// بدلاً من استخدام apify-client مباشرة
// استخدم Laravel API:
const response = await fetch('https://www.mediapro.social/api/tiktok/user/profile', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_TOKEN'
  },
  body: JSON.stringify({ username: 'username' })
});

const data = await response.json();
console.log(data);
```

## المميزات

✅ **بدون OAuth** - لا حاجة لتسجيل تطبيق TikTok
✅ **سهل الاستخدام** - API بسيط ومباشر
✅ **متعدد الوظائف** - 10 وظائف مختلفة
✅ **آمن** - محمي بـ Sanctum Authentication
✅ **مدمج بالكامل** - جاهز للاستخدام مباشرة

## الحدود والقيود

⚠️ **الخطة المجانية محدودة**
- تحقق من حدود Apify Free Plan
- قد تحتاج للترقية للاستخدام المكثف

⚠️ **وقت المعالجة**
- كل طلب قد يستغرق 10 ثواني - 5 دقائق
- يعتمد على حجم البيانات المطلوبة

⚠️ **Rate Limiting**
- Apify له حدود على عدد الطلبات
- راجع لوحة تحكم Apify لمراقبة الاستخدام

## الأمان

🔒 جميع الطلبات تتطلب Sanctum Authentication
🔒 تسجيل الأخطاء في Laravel Logs
🔒 التحقق من المدخلات باستخدام Laravel Validation
🔒 معالجة الأخطاء بشكل آمن

## الدعم والموارد

- 📚 [وثائق Apify](https://docs.apify.com)
- 📚 [TikTok Scraper Actor](https://apify.com/naqsZgh7DhGajnD5z)
- 📄 راجع `TIKTOK_APIFY_GUIDE.md` للتفاصيل الكاملة
- 📄 راجع `دليل_استخدام_TikTok_Apify.md` للدليل العربي

## البنية التقنية

```
Laravel Backend (PHP)
    ↓
ApifyTikTokService.php (يتصل بـ Apify API)
    ↓
TikTokAnalyticsController.php (معالجة الطلبات)
    ↓
Routes (api.php) - /api/tiktok/*
    ↓
Flutter App (يستدعي Laravel API)
```

## الخلاصة

تم دمج Apify بنجاح في تطبيقك! الآن يمكنك جمع بيانات TikTok بسهولة من خلال API بسيط ومباشر. ما عليك سوى:

1. ✅ الحصول على Apify API Token
2. ✅ رفع الملفات للسيرفر
3. ✅ إضافة Token في .env
4. ✅ البدء في استخدام API

---

**تاريخ الإنشاء:** 2025-11-18
**النسخة:** 1.0
**الحالة:** ✅ جاهز للاستخدام

لأي استفسارات أو مشاكل، راجع الأدلة المرفقة أو تواصل معنا.
