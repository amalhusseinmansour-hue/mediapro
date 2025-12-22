# خطة الانتقال من Ayrshare إلى Postiz

## نظرة عامة على التغييرات

هذا الدليل يساعدك على الانتقال من **Ayrshare** إلى **Postiz** بشكل سلس.

---

## الفروقات الرئيسية

| الميزة | Ayrshare | Postiz |
|--------|----------|--------|
| **الربط** | Profile Key + JWT | OAuth مباشر لكل منصة |
| **API Endpoint** | `/api/ayrshare/*` | `/api/postiz/*` |
| **Service Class** | `AyrshareService()` | `PostizService()` |
| **المنشورات** | `publishPost(userId, platforms, text)` | `publishPost(integrationIds, text)` |
| **الحسابات** | `getConnectedProfiles()` | `getConnectedIntegrations()` |

---

## خطوات الانتقال

### 1. تحديث Backend (Laravel)

#### أ. إضافة Controller الجديد

```bash
cp POSTIZ_BACKEND_CONTROLLER.php app/Http/Controllers/Api/PostizController.php
```

#### ب. إضافة Routes

في `routes/api.php`، أضف:

```php
// Postiz Routes
require __DIR__ . '/../POSTIZ_ROUTES.php';
```

أو انسخ محتوى `POSTIZ_ROUTES.php` مباشرة.

#### ج. تحديث Database

أضف حقول جديدة لجدول `social_accounts`:

```sql
ALTER TABLE social_accounts
ADD COLUMN IF NOT EXISTS integration_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS provider_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS access_token TEXT;

-- Index للبحث السريع
CREATE INDEX idx_integration_id ON social_accounts(integration_id);
CREATE INDEX idx_user_provider ON social_accounts(user_id, provider_type);
```

#### د. Migration للبيانات القديمة (اختياري)

إذا كنت تريد نقل البيانات من Ayrshare:

```php
// database/migrations/xxxx_migrate_ayrshare_to_postiz.php
public function up()
{
    // قم بنقل البيانات من Ayrshare Profiles إلى Postiz Integrations
    DB::table('users')
        ->whereNotNull('ayrshare_profile_key')
        ->chunk(100, function ($users) {
            foreach ($users as $user) {
                // قم بإنشاء سجلات في social_accounts
                // ملاحظة: ستحتاج لإعادة ربط الحسابات عبر OAuth
            }
        });
}
```

---

### 2. تحديث Frontend (Flutter)

#### أ. الملفات الجاهزة

الملفات التالية تم إنشاؤها بالفعل:
- ✅ `lib/services/postiz_service.dart`

#### ب. تحديث `main.dart`

**قبل (Ayrshare):**
```dart
import 'package:social_media_manager/services/ayrshare_service.dart';

void main() {
  AyrshareService().init('API_KEY');
  runApp(MyApp());
}
```

**بعد (Postiz):**
```dart
import 'package:social_media_manager/services/postiz_service.dart';

void main() {
  PostizService().init(
    apiKey: 'API_KEY',
    baseUrl: 'https://api.postiz.com/public/v1',
  );
  runApp(MyApp());
}
```

#### ج. تحديث شاشات الربط

**قبل (Ayrshare):**
```dart
// في lib/screens/accounts/ayrshare_connect_screen.dart
final jwt = await AyrshareService().generateJWT(userId: user.id);
launchUrl(Uri.parse(jwt['url']));
```

**بعد (Postiz):**
```dart
// أنشئ شاشة جديدة: lib/screens/accounts/postiz_connect_screen.dart
final oauth = await PostizService().generateOAuthLink(
  platform: 'facebook',
  userId: user.id,
);
launchUrl(Uri.parse(oauth['url']));
```

#### د. تحديث شاشة النشر

**قبل (Ayrshare):**
```dart
// lib/screens/create_post/ayrshare_post_screen.dart
await AyrshareService().publishPost(
  userId: user.id,
  platforms: ['facebook', 'twitter'],
  text: postText,
  mediaUrls: mediaUrls,
);
```

**بعد (Postiz):**
```dart
// أنشئ شاشة جديدة: lib/screens/create_post/postiz_post_screen.dart
await PostizService().publishPost(
  integrationIds: selectedIntegrationIds,
  text: postText,
  mediaUrls: mediaUrls,
);
```

---

### 3. تحديث `.env`

**قبل (Ayrshare):**
```env
AYRSHARE_API_KEY=xxx
AYRSHARE_PLAN=business
AYRSHARE_BASE_URL=https://app.ayrshare.com/api
```

**بعد (Postiz):**
```env
POSTIZ_API_KEY=xxx
POSTIZ_BASE_URL=https://api.postiz.com/public/v1

# OAuth Apps
FACEBOOK_APP_ID=xxx
FACEBOOK_APP_SECRET=xxx

TWITTER_CLIENT_ID=xxx
TWITTER_CLIENT_SECRET=xxx

LINKEDIN_CLIENT_ID=xxx
LINKEDIN_CLIENT_SECRET=xxx
```

---

### 4. إعداد OAuth Apps

الآن يجب إعداد OAuth Apps لكل منصة (راجع `POSTIZ_IMPLEMENTATION_GUIDE.md` للتفاصيل):

- [ ] Facebook App
- [ ] Twitter App
- [ ] LinkedIn App
- [ ] TikTok App (إن أردت)
- [ ] YouTube App (إن أردت)

---

### 5. اختبار النظام الجديد

#### أ. اختبار Backend

```bash
# اختبار API status
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://your-domain.com/api/postiz/status
```

#### ب. اختبار OAuth Flow

1. افتح التطبيق
2. اذهب إلى شاشة "ربط الحسابات"
3. اضغط على أحد المنصات (مثلاً Facebook)
4. تأكد من فتح OAuth وإعادة التوجيه بنجاح

#### ج. اختبار النشر

1. قم بربط حساب تجريبي
2. حاول نشر منشور تجريبي
3. تحقق من ظهوره على المنصة

---

## الملفات القديمة (Ayrshare)

### يمكن حذفها أو أرشفتها:

```bash
# Backend
- AYRSHARE_BACKEND_CONTROLLER.php
- AYRSHARE_ROUTES.php
- AYRSHARE_IMPLEMENTATION_GUIDE.md
- AYRSHARE_FREE_TESTING.md
- AYRSHARE_BUSINESS_SETUP.md
- AYRSHARE_BACKEND_ROUTES.md

# Frontend
- lib/services/ayrshare_service.dart
- lib/screens/accounts/ayrshare_connect_screen.dart
- lib/screens/create_post/ayrshare_post_screen.dart
```

### خيارات:

**1. الأرشفة (موصى به):**
```bash
mkdir old_ayrshare
mv AYRSHARE_* old_ayrshare/
mv lib/services/ayrshare_service.dart lib/services/old/
```

**2. الحذف (إذا كنت متأكد):**
```bash
rm AYRSHARE_*
rm lib/services/ayrshare_service.dart
rm -rf lib/screens/accounts/ayrshare_connect_screen.dart
```

---

## الجدول الزمني المقترح

| الأسبوع | المهام |
|---------|--------|
| **الأسبوع 1** | • إعداد Postiz (hosted أو self-hosted)<br>• إعداد OAuth Apps<br>• تحديث Backend |
| **الأسبوع 2** | • تحديث Frontend<br>• الاختبار الداخلي<br>• إصلاح الأخطاء |
| **الأسبوع 3** | • اختبار Beta مع مستخدمين محددين<br>• جمع الملاحظات |
| **الأسبوع 4** | • النشر للجميع<br>• مراقبة الأداء<br>• أرشفة كود Ayrshare |

---

## خطة Rollback (إذا حدثت مشاكل)

في حالة حدوث مشاكل، يمكن العودة لـ Ayrshare:

1. أعد تفعيل Ayrshare Routes
2. أعد تفعيل `AyrshareService` في Flutter
3. أرجع `.env` للإعدادات القديمة
4. أعد نشر التطبيق

**لذلك من المهم عدم حذف ملفات Ayrshare فوراً!**

---

## مزايا إضافية في Postiz

بعد الانتقال، يمكنك الاستفادة من:

### 1. توليد فيديو بالذكاء الاصطناعي

```dart
final video = await PostizService().generateVideo(
  prompt: 'Create a promotional video for our app',
  model: 'image-text-slides',
);
```

### 2. رفع Media من URL مباشرة

```dart
final mediaUrl = await PostizService().uploadMediaFromUrl(
  'https://example.com/image.jpg',
);
```

### 3. الحصول على أفضل وقت للنشر

```dart
final bestTime = await PostizService().getNextAvailableSlot(
  integrationId,
);
```

---

## الأسئلة الشائعة

**س: هل يمكن استخدام Ayrshare و Postiz معاً؟**
ج: نعم، يمكنك ذلك خلال فترة الانتقال.

**س: هل سأفقد المنشورات القديمة؟**
ج: لا، المنشورات على المنصات ستبقى. فقط معلومات التتبع المحلية قد تحتاج إلى مزامنة.

**س: هل Postiz يدعم جميع مزايا Ayrshare؟**
ج: نعم، ويدعم مزايا إضافية مثل توليد الفيديو بالذكاء الاصطناعي.

**س: كم تكلفة Postiz؟**
ج: مجاني للاستضافة الذاتية، أو $29/شهر للنسخة المستضافة.

---

## الدعم

إذا واجهت أي مشاكل:

1. راجع التوثيق: `POSTIZ_IMPLEMENTATION_GUIDE.md`
2. راجع البدء السريع: `POSTIZ_QUICK_START.md`
3. تحقق من Logs في Laravel: `storage/logs/laravel.log`
4. تحقق من Console في Flutter
5. راجع Postiz Docs: https://docs.postiz.com

---

## الخلاصة

✅ **الملفات الجديدة:**
- `lib/services/postiz_service.dart`
- `POSTIZ_BACKEND_CONTROLLER.php`
- `POSTIZ_ROUTES.php`
- `POSTIZ_IMPLEMENTATION_GUIDE.md`
- `POSTIZ_QUICK_START.md`

✅ **التحديثات المطلوبة:**
- `main.dart` - تهيئة PostizService
- `.env` - إضافة متغيرات Postiz
- Database - إضافة حقول جديدة
- Routes - إضافة Postiz routes

✅ **الملفات القديمة للأرشفة:**
- جميع ملفات `AYRSHARE_*`
- `lib/services/ayrshare_service.dart`
- شاشات Ayrshare

---

**🎉 بالتوفيق في الانتقال إلى Postiz!**
