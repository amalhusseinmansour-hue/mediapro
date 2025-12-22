# البدء السريع مع Postiz

## الطريقة الأسهل: استخدام النسخة المستضافة

### 1️⃣ الحصول على API Key

1. سجل في: https://postiz.com
2. اذهب إلى Settings → API Keys
3. انقر "Generate New API Key"
4. انسخ الـ API Key

### 2️⃣ تحديث `.env`

```env
POSTIZ_API_KEY=your_api_key_here
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
```

### 3️⃣ نسخ الملفات

**Backend (Laravel):**
```bash
# انسخ Controller
cp POSTIZ_BACKEND_CONTROLLER.php app/Http/Controllers/Api/PostizController.php

# أضف Routes إلى routes/api.php
cat POSTIZ_ROUTES.php >> routes/api.php
```

**Frontend (Flutter):**
الملف موجود بالفعل في: `lib/services/postiz_service.dart`

### 4️⃣ تهيئة الخدمة في `main.dart`

أضف هذا الكود في `lib/main.dart`:

```dart
import 'package:social_media_manager/services/postiz_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Postiz
  PostizService().init(
    apiKey: 'YOUR_API_KEY',
    baseUrl: 'https://api.postiz.com/public/v1',
  );

  runApp(MyApp());
}
```

### 5️⃣ اختبار التكامل

```dart
// في أي شاشة في التطبيق
final status = await PostizService().checkApiStatus();
print('Postiz Status: $status');

if (status) {
  print('✅ Postiz connected successfully!');
} else {
  print('❌ Postiz connection failed');
}
```

---

## ربط حسابات Social Media

### في التطبيق، قم بإنشاء شاشة OAuth:

```dart
class ConnectSocialScreen extends StatelessWidget {
  Future<void> connectPlatform(String platform) async {
    try {
      // توليد OAuth link
      final result = await PostizService().generateOAuthLink(
        platform: platform,
        userId: currentUser.id,
      );

      // فتح المتصفح
      await launchUrl(
        Uri.parse(result['url']),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ربط الحسابات')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.facebook),
            title: Text('Facebook'),
            onTap: () => connectPlatform('facebook'),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Instagram'),
            onTap: () => connectPlatform('instagram'),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Twitter/X'),
            onTap: () => connectPlatform('twitter'),
          ),
          // أضف باقي المنصات...
        ],
      ),
    );
  }
}
```

---

## نشر منشور

```dart
Future<void> publishToSocialMedia() async {
  try {
    final result = await PostizService().publishPost(
      integrationIds: ['integration_1', 'integration_2'],
      text: 'هذا منشور تجريبي من التطبيق!',
      mediaUrls: ['https://example.com/image.jpg'],
    );

    print('✅ Post published! ID: ${result['post_id']}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## إعداد OAuth Apps (مطلوب)

للربط مع المنصات، يجب إعداد OAuth Apps:

### Facebook:
1. https://developers.facebook.com/apps
2. Create App → Business
3. Add Product: Facebook Login
4. Callback URL: `https://your-domain.com/api/postiz/oauth-callback`
5. Copy App ID & Secret → أضفهما في `.env`

### Twitter:
1. https://developer.twitter.com/en/portal/dashboard
2. Create Project & App
3. User authentication settings → Web App
4. Callback URL: `https://your-domain.com/api/postiz/oauth-callback`
5. Copy Client ID & Secret → أضفهما في `.env`

### LinkedIn:
1. https://www.linkedin.com/developers/apps
2. Create App
3. Auth → Redirect URLs
4. Add: `https://your-domain.com/api/postiz/oauth-callback`
5. Copy Client ID & Secret → أضفهما في `.env`

---

## ملاحظات مهمة

⚠️ **Rate Limits:**
النسخة المستضافة: 30 طلب/ساعة

⚠️ **OAuth Callbacks:**
يجب أن يكون Domain الخاص بك يدعم HTTPS

⚠️ **Testing:**
استخدم حسابات تجريبية في البداية

---

## الدعم والمساعدة

📖 **Documentation:** https://docs.postiz.com
🐙 **GitHub:** https://github.com/gitroomhq/postiz-app
📦 **NPM Package:** @postiz/node

---

## ✅ قائمة التحقق

- [ ] الحصول على API Key من postiz.com
- [ ] إضافة API Key في `.env`
- [ ] نسخ `PostizController.php` إلى Laravel
- [ ] إضافة Routes في `routes/api.php`
- [ ] تهيئة `PostizService` في Flutter
- [ ] إعداد OAuth Apps للمنصات المطلوبة
- [ ] اختبار الاتصال بـ API
- [ ] اختبار OAuth Flow
- [ ] اختبار النشر

---

**🎉 مبروك! الآن أنت جاهز لاستخدام Postiz!**
