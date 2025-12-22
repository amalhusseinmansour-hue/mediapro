# 🚀 خطوات التنفيذ الكاملة - Postiz + Direct OAuth

## ✅ الملفات الجاهزة

لقد أنشأت لك:

1. ✅ `SocialMediaPublisher.php` - للنشر على FB, Twitter, LinkedIn
2. ✅ `PostizService.php` - لميزات Postiz (AI Video, Upload, Analytics)
3. ✅ `PublishController.php` - Controller موحد
4. ✅ `API_ROUTES_COMPLETE.php` - كل الـ routes
5. ✅ `FACEBOOK_OAUTH_SETUP.md` - دليل Facebook
6. ✅ `TWITTER_OAUTH_SETUP.md` - دليل Twitter
7. ✅ `LINKEDIN_OAUTH_SETUP.md` - دليل LinkedIn

---

## 📋 خطة التنفيذ - 7 أيام

### ✅ Day 1: OAuth Apps Setup (1-2 ساعات)

#### الخطوة 1.1: إنشاء Facebook App
```
1. اذهب إلى: https://developers.facebook.com/apps
2. اضغط "Create App" → Business
3. أضف "Facebook Login" product
4. Settings → Basic:
   - App Domains: mediaprosocial.io
   - Privacy Policy: https://mediaprosocial.io/privacy
5. Facebook Login → Settings:
   - Redirect URI: https://mediaprosocial.io/api/auth/facebook/callback
6. App Review → Request:
   - pages_manage_posts
   - pages_read_engagement
7. انسخ:
   FACEBOOK_APP_ID=...
   FACEBOOK_APP_SECRET=...
```

راجع الدليل الكامل: `FACEBOOK_OAUTH_SETUP.md`

#### الخطوة 1.2: إنشاء Twitter App
```
1. اذهب إلى: https://developer.twitter.com/portal
2. Create Project → Create App
3. User authentication settings:
   - Type: Web App
   - Callback: https://mediaprosocial.io/api/auth/twitter/callback
   - Permissions: Read and write
4. انسخ:
   TWITTER_CLIENT_ID=...
   TWITTER_CLIENT_SECRET=...
```

راجع الدليل الكامل: `TWITTER_OAUTH_SETUP.md`

#### الخطوة 1.3: إنشاء LinkedIn App
```
1. اذهب إلى: https://www.linkedin.com/developers/apps
2. Create app → Verify app
3. Products → Request "Share on LinkedIn"
4. Auth → Redirect: https://mediaprosocial.io/api/auth/linkedin/callback
5. انسخ:
   LINKEDIN_CLIENT_ID=...
   LINKEDIN_CLIENT_SECRET=...
```

راجع الدليل الكامل: `LINKEDIN_OAUTH_SETUP.md`

---

### ✅ Day 2: Deploy Laravel Backend (2-3 ساعات)

#### الخطوة 2.1: رفع الملفات للسيرفر

```bash
# من Windows CMD/PowerShell

# 1. Upload SocialMediaPublisher.php
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" ^
  "C:\Users\HP\social_media_manager\SocialMediaPublisher.php" ^
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Services/SocialMediaPublisher.php

# 2. Upload PostizService.php
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" ^
  "C:\Users\HP\social_media_manager\PostizService.php" ^
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Services/PostizService.php

# 3. Upload PublishController.php
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" ^
  "C:\Users\HP\social_media_manager\PublishController.php" ^
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/Api/PublishController.php
```

#### الخطوة 2.2: تحديث `.env`

```bash
# SSH إلى السيرفر
ssh u126213189@82.25.83.217 -p 65002

# فتح .env
cd /home/u126213189/domains/mediaprosocial.io/public_html
nano .env
```

أضف في نهاية الملف:

```env
# ========== OAuth Credentials ==========
FACEBOOK_APP_ID=your_app_id_here
FACEBOOK_APP_SECRET=your_app_secret_here
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback

TWITTER_CLIENT_ID=your_client_id_here
TWITTER_CLIENT_SECRET=your_client_secret_here
TWITTER_REDIRECT_URI=https://mediaprosocial.io/api/auth/twitter/callback

LINKEDIN_CLIENT_ID=your_client_id_here
LINKEDIN_CLIENT_SECRET=your_client_secret_here
LINKEDIN_REDIRECT_URI=https://mediaprosocial.io/api/auth/linkedin/callback

# ========== Postiz (موجود بالفعل) ==========
POSTIZ_API_KEY=059d262b954bb8956a6a7166639ae222d65866bdd38d8ee96e5cf95cf479136d
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
```

احفظ: `Ctrl+O`, Enter, `Ctrl+X`

#### الخطوة 2.3: تحديث `config/services.php`

```bash
nano config/services.php
```

أضف:

```php
'postiz' => [
    'api_key' => env('POSTIZ_API_KEY'),
    'base_url' => env('POSTIZ_BASE_URL'),
],
```

احفظ واخرج.

#### الخطوة 2.4: تحديث Routes

```bash
nano routes/api.php
```

أضف في نهاية الملف محتوى ملف `API_ROUTES_COMPLETE.php`

أو يمكنك استخدام:

```bash
cat >> routes/api.php << 'ROUTES_EOF'

use App\Http\Controllers\Api\PublishController;

// ========== Social Media Publishing Routes ==========
Route::middleware('auth:sanctum')->prefix('social')->group(function () {
    Route::get('/accounts', [PublishController::class, 'getAccounts']);
    Route::delete('/accounts/{id}', [PublishController::class, 'disconnect']);
    Route::post('/publish', [PublishController::class, 'publish']);
    Route::post('/generate-video', [PublishController::class, 'generateVideo']);
    Route::post('/upload-media', [PublishController::class, 'uploadMedia']);
    Route::get('/analytics', [PublishController::class, 'getAnalytics']);
});
ROUTES_EOF
```

#### الخطوة 2.5: Clear Cache

```bash
php artisan config:clear
php artisan route:clear
php artisan cache:clear
php artisan route:list | grep social
```

يجب أن ترى:
```
GET|HEAD  api/auth/{platform}/redirect
GET|HEAD  api/auth/{platform}/callback
GET|HEAD  api/auth/connected-accounts
GET|HEAD  api/social/accounts
DELETE    api/social/accounts/{id}
POST      api/social/publish
POST      api/social/generate-video
POST      api/social/upload-media
GET|HEAD  api/social/analytics
```

---

### ✅ Day 3: اختبار Backend API (2-3 ساعات)

#### اختبار 3.1: OAuth Flow

```bash
# Test Facebook OAuth URL generation
curl -X GET "https://mediaprosocial.io/api/auth/facebook/redirect" \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Accept: application/json"

# يجب أن يرجع:
{
  "success": true,
  "url": "https://www.facebook.com/v18.0/dialog/oauth?..."
}
```

#### اختبار 3.2: Get Accounts

```bash
curl -X GET "https://mediaprosocial.io/api/social/accounts" \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Accept: application/json"
```

#### اختبار 3.3: Postiz AI Video

```bash
curl -X POST "https://mediaprosocial.io/api/social/generate-video" \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Test video content",
    "platform": "tiktok"
  }'
```

---

### ✅ Day 4-5: Flutter Integration (6-8 ساعات)

#### ملف 1: `lib/services/social_media_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../core/config/backend_config.dart';
import '../controllers/auth_controller.dart';

class SocialMediaService extends GetxService {
  final String baseUrl = BackendConfig.baseUrl;

  String get _token => Get.find<AuthController>().token ?? '';

  // Generate OAuth URL
  Future<String?> generateOAuthUrl(String platform) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/$platform/redirect'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('Error generating OAuth URL: $e');
      return null;
    }
  }

  // Get connected accounts
  Future<List<dynamic>> getConnectedAccounts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/social/accounts'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['accounts'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  // Disconnect account
  Future<bool> disconnectAccount(int accountId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/social/accounts/$accountId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error disconnecting account: $e');
      return false;
    }
  }

  // Publish post
  Future<Map<String, dynamic>> publishPost({
    required List<int> accountIds,
    required String content,
    List<String>? mediaUrls,
    String? scheduleAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/social/publish'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'account_ids': accountIds,
          'content': content,
          if (mediaUrls != null) 'media_urls': mediaUrls,
          if (scheduleAt != null) 'schedule_at': scheduleAt,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to publish'};
    } catch (e) {
      print('Error publishing post: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Generate AI Video
  Future<Map<String, dynamic>> generateVideo({
    required String content,
    String platform = 'tiktok',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/social/generate-video'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'content': content,
          'platform': platform,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to generate video'};
    } catch (e) {
      print('Error generating video: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
```

#### ملف 2: تحديث `lib/screens/social_media/connect_accounts_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/social_media_service.dart';

class ConnectAccountsScreen extends StatefulWidget {
  @override
  _ConnectAccountsScreenState createState() => _ConnectAccountsScreenState();
}

class _ConnectAccountsScreenState extends State<ConnectAccountsScreen> {
  final SocialMediaService _socialService = Get.find<SocialMediaService>();
  List<dynamic> _accounts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    _accounts = await _socialService.getConnectedAccounts();
    setState(() => _isLoading = false);
  }

  Future<void> _connectAccount(String platform) async {
    try {
      setState(() => _isLoading = true);

      // 1. Get OAuth URL
      final oauthUrl = await _socialService.generateOAuthUrl(platform);

      if (oauthUrl == null) {
        Get.snackbar('خطأ', 'فشل في الحصول على رابط المصادقة');
        return;
      }

      // 2. Open OAuth URL in browser
      if (await canLaunchUrl(Uri.parse(oauthUrl))) {
        await launchUrl(
          Uri.parse(oauthUrl),
          mode: LaunchMode.externalApplication,
        );

        Get.snackbar(
          'جاري الربط',
          'سيتم فتح المتصفح لإكمال عملية الربط',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في ربط الحساب: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disconnectAccount(int accountId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الفصل'),
        content: Text('هل أنت متأكد من فصل هذا الحساب؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('فصل'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _socialService.disconnectAccount(accountId);
      if (success) {
        Get.snackbar('تم', 'تم فصل الحساب بنجاح');
        _loadAccounts();
      } else {
        Get.snackbar('خطأ', 'فشل في فصل الحساب');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ربط الحسابات'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAccounts,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildPlatformCard('facebook', 'Facebook', Icons.facebook, Colors.blue),
                  SizedBox(height: 12),
                  _buildPlatformCard('twitter', 'Twitter', Icons.flutter_dash, Colors.lightBlue),
                  SizedBox(height: 12),
                  _buildPlatformCard('linkedin', 'LinkedIn', Icons.business, Color(0xFF0077B5)),
                ],
              ),
            ),
    );
  }

  Widget _buildPlatformCard(String platform, String name, IconData icon, Color color) {
    final account = _accounts.firstWhere(
      (acc) => acc['platform'] == platform,
      orElse: () => null,
    );

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: account != null
            ? Text('مربوط: ${account['account_name'] ?? ''}')
            : Text('غير مربوط'),
        trailing: account != null
            ? IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _disconnectAccount(account['id']),
              )
            : ElevatedButton(
                onPressed: () => _connectAccount(platform),
                child: Text('ربط'),
              ),
      ),
    );
  }
}
```

---

### ✅ Day 6: Deep Link Setup (2-3 ساعات)

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<activity
    android:name=".MainActivity"
    ...>

    <!-- Deep Links -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="mprosocial"
            android:host="oauth-callback" />
    </intent-filter>
</activity>
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mprosocial</string>
        </array>
    </dict>
</array>
```

#### Deep Link Handler (`lib/main.dart`)

```dart
import 'package:uni_links/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize deep link handler
  _initDeepLinks();

  runApp(MyApp());
}

void _initDeepLinks() {
  // Listen to initial link
  getInitialLink().then((link) {
    if (link != null) {
      _handleDeepLink(link);
    }
  });

  // Listen to link stream
  linkStream.listen((link) {
    if (link != null) {
      _handleDeepLink(link);
    }
  });
}

void _handleDeepLink(String link) {
  final uri = Uri.parse(link);

  // mprosocial://oauth-callback?success=true&platform=facebook
  if (uri.scheme == 'mprosocial' && uri.host == 'oauth-callback') {
    final success = uri.queryParameters['success'] == 'true';
    final platform = uri.queryParameters['platform'];

    if (success) {
      Get.snackbar(
        'نجح الربط ✅',
        'تم ربط حساب $platform بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh accounts list
      // You can use GetX or EventBus here
    } else {
      final error = uri.queryParameters['error'];
      Get.snackbar(
        'فشل الربط ❌',
        'خطأ: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
```

---

### ✅ Day 7: اختبار كامل (4-6 ساعات)

#### Test 1: OAuth Flow
1. افتح التطبيق
2. اذهب لـ "ربط الحسابات"
3. اضغط "ربط Facebook"
4. يجب أن يفتح المتصفح
5. سجل دخول Facebook ووافق
6. يجب أن يرجع للتطبيق مع رسالة نجاح

#### Test 2: Publishing
1. اذهب لـ "نشر بوست"
2. اختر الحسابات المربوطة
3. اكتب محتوى
4. اضغط "نشر"
5. تحقق من Facebook/Twitter/LinkedIn

#### Test 3: AI Video
1. اذهب لـ "إنشاء فيديو AI"
2. اكتب نص
3. اضغط "توليد"
4. يجب أن يعرض الفيديو المولد

---

## 📝 Checklist النهائي

### Backend ✅
- [ ] OAuth Apps created (Facebook, Twitter, LinkedIn)
- [ ] `.env` updated with credentials
- [ ] Services uploaded (SocialMediaPublisher, PostizService)
- [ ] Controllers uploaded (PublishController)
- [ ] Routes added
- [ ] Cache cleared
- [ ] API tested with Postman/curl

### Flutter ✅
- [ ] SocialMediaService created
- [ ] ConnectAccountsScreen updated
- [ ] Deep links configured (Android + iOS)
- [ ] Deep link handler implemented
- [ ] UI tested

### Testing ✅
- [ ] OAuth flow tested (all 3 platforms)
- [ ] Publishing tested
- [ ] AI Video tested
- [ ] Analytics tested
- [ ] Disconnecting accounts tested

---

## 🎉 جاهز للإطلاق!

بعد إكمال كل الخطوات، تطبيقك سيكون:
- ✅ Multi-tenant SaaS
- ✅ OAuth للربط (Facebook, Twitter, LinkedIn)
- ✅ نشر مباشر على المنصات
- ✅ AI Video من Postiz
- ✅ Analytics من Postiz
- ✅ تكلفة $99/month فقط!

---

**تحتاج مساعدة في أي خطوة؟ أخبرني! 🚀**
