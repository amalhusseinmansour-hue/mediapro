# ⚡ Apify - البدء السريع (10 دقائق)

## 🚀 الخطوة 1: التسجيل في Apify (3 دقائق)

### افتح الرابط:
```
👉 https://apify.com/sign-up
```

### اختر طريقة التسجيل:
- ✅ Google Account (الأسرع)
- ✅ GitHub Account
- ✅ Email + Password

### بعد التسجيل:
```
✅ ستحصل على $5 free credits تلقائياً
✅ حوالي 50-100 profile scrapes مجاناً
✅ لا حاجة لبطاقة ائتمان الآن
```

---

## 🔑 الخطوة 2: الحصول على API Token (2 دقيقة)

### 1. اذهب إلى:
```
👉 https://console.apify.com/account/integrations
```

### 2. ستجد قسم "Personal API tokens"

### 3. انسخ الـ Token الموجود:
```
apify_api_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 4. احفظه في Notepad مؤقتاً

---

## 💻 الخطوة 3: إضافة Token في التطبيق (1 دقيقة)

### افتح الملف:
```
lib/services/apify_service.dart
```

### ابحث عن السطر 15:
```dart
static const String _apiToken = 'YOUR_APIFY_API_TOKEN';
```

### غيره إلى:
```dart
static const String _apiToken = 'apify_api_XXXXXXX'; // ← الصق token هنا
```

### احفظ الملف ✅

---

## 🎯 الخطوة 4: تسجيل السيرفس (2 دقيقة)

### افتح `lib/main.dart`

### أضف Import:
```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'services/apify_service.dart';
```

### في `main()` function:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Hive للتخزين المحلي
  await Hive.initFlutter();

  // تسجيل Apify service
  Get.put(ApifyService());

  runApp(MyApp());
}
```

---

## 🧪 الخطوة 5: أول اختبار (2 دقيقة)

### أنشئ ملف test:
```
lib/screens/test/apify_test_screen.dart
```

### الصق هذا الكود:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/apify_service.dart';

class ApifyTestScreen extends StatefulWidget {
  @override
  _ApifyTestScreenState createState() => _ApifyTestScreenState();
}

class _ApifyTestScreenState extends State<ApifyTestScreen> {
  final ApifyService _apify = Get.find<ApifyService>();
  final TextEditingController _controller = TextEditingController(text: 'nike');

  InstagramProfileFull? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _test() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final username = _controller.text.trim();
      print('🌐 Starting scrape for: $username');

      final profile = await _apify.scrapeInstagramProfile(
        username,
        maxPosts: 20,
        saveLocally: true,
      );

      setState(() {
        _result = profile;
        _isLoading = false;
      });

      if (profile != null) {
        Get.snackbar(
          'نجح! 🎉',
          'تم جلب بيانات @$username بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        setState(() {
          _error = 'لم يتم العثور على بيانات';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      Get.snackbar(
        'خطأ ❌',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apify Test'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شعار Apify
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.rocket_launch, size: 60, color: Colors.orange),
                  SizedBox(height: 8),
                  Text(
                    'Apify Instagram Scraper',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'جرب جلب أي حساب Instagram!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // حقل الإدخال
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Instagram Username',
                hintText: 'nike',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'أدخل username بدون @',
              ),
            ),

            SizedBox(height: 16),

            // زر الاختبار
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _test,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.download),
              label: Text(
                _isLoading ? 'جاري الجلب...' : 'جلب البيانات',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Progress indicator
            if (_isLoading)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('جاري جلب البيانات من Instagram...'),
                    SizedBox(height: 4),
                    Text(
                      'قد يستغرق 10-30 ثانية ⏱️',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // Error message
            if (_error != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              ),

            // النتيجة
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 30),
                              SizedBox(width: 12),
                              Text(
                                'نجح! 🎉',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          Divider(height: 24),

                          // الصورة الشخصية
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _result!.profilePicUrl != null
                                  ? NetworkImage(_result!.profilePicUrl!)
                                  : null,
                              child: _result!.profilePicUrl == null
                                  ? Icon(Icons.person, size: 50)
                                  : null,
                            ),
                          ),

                          SizedBox(height: 16),

                          // الاسم
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _result!.fullName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '@${_result!.username}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_result!.isVerified)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, color: Colors.blue, size: 16),
                                        SizedBox(width: 4),
                                        Text('Verified', style: TextStyle(color: Colors.blue)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // الإحصائيات
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple[50]!, Colors.pink[50]!],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat('Posts', _result!.postsCount),
                                _buildDivider(),
                                _buildStat('Followers', _result!.followers),
                                _buildDivider(),
                                _buildStat('Following', _result!.following),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // Bio
                          if (_result!.bio.isNotEmpty) ...[
                            Text(
                              'Bio:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(_result!.bio),
                            SizedBox(height: 16),
                          ],

                          // معدل التفاعل
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, color: Colors.green),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Engagement Rate',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[900],
                                        ),
                                      ),
                                      Text(
                                        '${_result!.engagementRate.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // المنشورات الأخيرة
                          if (_result!.latestPosts.isNotEmpty) ...[
                            Text(
                              'Latest Posts (${_result!.latestPosts.length}):',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _result!.latestPosts.length,
                                itemBuilder: (context, index) {
                                  final post = _result!.latestPosts[index];
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: post.imageUrl != null
                                                ? DecorationImage(
                                                    image: NetworkImage(post.imageUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                            color: Colors.grey[300],
                                          ),
                                          child: post.imageUrl == null
                                              ? Icon(Icons.image, size: 40)
                                              : null,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.favorite, size: 12, color: Colors.red),
                                            SizedBox(width: 4),
                                            Text(
                                              '${post.likesCount}',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          SizedBox(height: 16),

                          // معلومات إضافية
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      'تم حفظ البيانات محلياً! ✅',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'يمكنك الوصول للبيانات لاحقاً بدون scraping جديد',
                                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    String displayValue;
    if (value >= 1000000) {
      displayValue = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      displayValue = '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      displayValue = value.toString();
    }

    return Column(
      children: [
        Text(
          displayValue,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[300],
    );
  }
}
```

---

## 🎯 الخطوة 6: فتح الشاشة للاختبار

### في `lib/main.dart` أو أي شاشة:

```dart
import 'screens/test/apify_test_screen.dart';

// افتح الشاشة:
Get.to(() => ApifyTestScreen());

// أو اضغط زر:
ElevatedButton(
  onPressed: () => Get.to(() => ApifyTestScreen()),
  child: Text('Test Apify'),
)
```

---

## ✅ الخطوة 7: اختبر!

### 1. شغل التطبيق:
```bash
flutter run
```

### 2. افتح ApifyTestScreen

### 3. جرب usernames مختلفة:
```
nike ✅ (متابعين كثير)
instagram ✅ (حساب رسمي)
cristiano ✅ (أكثر حساب متابعة)
YourUsername ✅ (حسابك الشخصي)
```

### 4. اضغط "جلب البيانات"

### 5. انتظر 10-30 ثانية...

### 6. ستظهر النتيجة! 🎉

---

## 🎉 ماذا سيحدث؟

```
1. ⏱️ يبدأ Scraping (10-30 ثانية)
2. 📥 يجلب البيانات من Instagram
3. 💾 يحفظ في Hive تلقائياً
4. 📊 يعرض النتيجة بشكل جميل:
   - الصورة الشخصية ✅
   - الاسم الكامل ✅
   - Followers, Following, Posts ✅
   - Engagement Rate ✅
   - Bio ✅
   - آخر 20 منشور ✅
```

---

## 💾 البيانات المحفوظة

البيانات تُحفظ تلقائياً في Hive! للوصول إليها:

```dart
final apify = Get.find<ApifyService>();

// جلب بيانات محفوظة
final cached = apify.getLocalAccountData(
  platform: 'instagram',
  username: 'nike',
);

if (cached != null) {
  print('Last updated: ${cached['lastUpdated']}');
  print('Data: ${cached['data']}');
}
```

---

## 📊 مراقبة الاستهلاك

### راقب Credits المتبقية:

```
👉 https://console.apify.com/billing/usage
```

ستجد:
- ✅ Credits المتبقية
- ✅ عدد Scrapes المستخدمة
- ✅ التكلفة لكل actor

---

## 🆘 حل المشاكل

### مشكلة 1: "Actor timeout"
```
✅ الحل: انتظر أكثر، بعض الحسابات تحتاج وقت أطول
✅ أو حاول مع حساب أصغر
```

### مشكلة 2: "No data found"
```
✅ الحل:
   - تأكد Username صحيح
   - بعض الحسابات Private لا تعمل
   - جرب حساب عام مثل 'nike'
```

### مشكلة 3: "API token invalid"
```
✅ الحل:
   - تأكد نسخت Token كامل
   - راجع https://console.apify.com/account/integrations
   - أعد نسخه مرة أخرى
```

### مشكلة 4: "Credits exceeded"
```
✅ الحل:
   - استخدمت الـ $5 free credits
   - اشترِ credits إضافية
   - أو انتظر الشهر القادم
```

---

## 🎯 التالي: ماذا بعد؟

بعد ما تجرب أول scrape ناجح:

### 1. جرب منصات أخرى:
```dart
// Twitter
final twitter = await apify.scrapeTwitterProfile('elonmusk');

// TikTok
final tiktok = await apify.scrapeTikTokProfile('charlidamelio');

// Facebook
final fb = await apify.scrapeFacebookPage('https://facebook.com/nike');
```

### 2. جرب Bulk Scraping:
```dart
final results = await apify.scrapeMultipleAccounts(
  accounts: [
    {'platform': 'instagram', 'username': 'nike'},
    {'platform': 'instagram', 'username': 'adidas'},
    {'platform': 'instagram', 'username': 'puma'},
  ],
);
```

### 3. اعمل Competitor Analysis Screen

### 4. اعمل Auto-scraping يومي

### 5. اعمل Dashboard هجين (OAuth + Apify)

---

## 📚 الموارد

- **Apify Console:** https://console.apify.com
- **Instagram Scraper Docs:** https://apify.com/apify/instagram-scraper
- **Twitter Scraper Docs:** https://apify.com/apidojo/tweet-scraper
- **TikTok Scraper Docs:** https://apify.com/clockworks/tiktok-scraper

---

## ✅ Checklist

- [ ] سجلت في Apify
- [ ] حصلت على API Token
- [ ] أضفت Token في apify_service.dart
- [ ] سجلت ApifyService في main.dart
- [ ] أنشأت ApifyTestScreen
- [ ] شغلت التطبيق
- [ ] جربت أول scrape
- [ ] شفت النتيجة 🎉
- [ ] تحققت من البيانات المحفوظة
- [ ] راجعت Credits المتبقية

---

**🎉 مبروك! أول Apify scrape جاهز!**

الآن لديك القدرة على جلب بيانات **أي حساب** من Instagram, Twitter, TikTok, Facebook بدون OAuth!

**🚀 استمتع!**
