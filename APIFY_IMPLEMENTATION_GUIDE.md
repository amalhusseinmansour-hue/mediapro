# 🚀 دليل Apify - جلب بيانات أي حساب سوشال ميديا

## 🎯 ما هو Apify؟

**Apify** هي منصة قوية لـ web scraping والـ automation تسمح لك بجلب بيانات من أي موقع بدون الحاجة لـ OAuth.

### ✅ المزايا الرهيبة:

```
✅ جلب بيانات أي حساب (حتى بدون OAuth)
✅ حسابات المنافسين كاملة
✅ إحصائيات مفصلة وتاريخية
✅ بيانات الهاشتاقات والترندات
✅ حفظ البيانات محلياً في التطبيق
✅ لا حاجة لربط الحساب
```

### ❌ القيود:

```
❌ لا يمكن النشر (scraping فقط للقراءة)
❌ يحتاج اشتراك Apify ($49/شهر للبداية)
❌ قد يخالف Terms of Service لبعض المنصات
❌ أبطأ من OAuth (يحتاج 10-30 ثانية لكل scrape)
```

---

## 💰 الأسعار

### Free Plan (للتجربة):
```
✅ $5 free credits شهرياً
✅ حوالي 50-100 profile scrapes
✅ مثالي للاختبار
```

### Starter Plan ($49/شهر):
```
✅ $49 من Credits
✅ ~500-1000 profile scrapes
✅ مناسب للتطبيقات الصغيرة
```

### Team Plan ($149/شهر):
```
✅ $149 من Credits
✅ ~1500-3000 profile scrapes
✅ للتطبيقات المتوسطة
```

**💡 نصيحة:** ابدأ بـ Free Plan للتجربة!

---

## 🚀 خطوات البدء السريع

### الخطوة 1: التسجيل في Apify (5 دقائق)

1. اذهب إلى: https://apify.com
2. اضغط **"Sign Up"**
3. سجل بالإيميل أو Google
4. ستحصل على **$5 free credits** 🎉

### الخطوة 2: الحصول على API Token (2 دقيقة)

1. اذهب إلى: https://console.apify.com/account/integrations
2. انسخ **Personal API Token**
3. احفظه في مكان آمن

### الخطوة 3: إضافة Token في التطبيق

```dart
// في lib/services/apify_service.dart
static const String _apiToken = 'apify_api_YOUR_TOKEN_HERE';
```

### الخطوة 4: تسجيل السيرفس

```dart
// في main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Apify service
  Get.put(ApifyService());

  runApp(MyApp());
}
```

---

## 📖 أمثلة الاستخدام

### مثال 1: جلب ملف Instagram

```dart
import 'package:get/get.dart';
import '../services/apify_service.dart';

class ProfileAnalyzerScreen extends StatefulWidget {
  @override
  _ProfileAnalyzerScreenState createState() => _ProfileAnalyzerScreenState();
}

class _ProfileAnalyzerScreenState extends State<ProfileAnalyzerScreen> {
  final ApifyService _apify = Get.find<ApifyService>();
  final TextEditingController _usernameController = TextEditingController();

  InstagramProfileFull? _profile;
  bool _isLoading = false;

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();

    // جلب الملف من Apify (سيتم حفظه تلقائياً)
    final profile = await _apify.scrapeInstagramProfile(
      username,
      maxPosts: 50,
      saveLocally: true, // 💾 حفظ محلياً
    );

    setState(() {
      _profile = profile;
      _isLoading = false;
    });

    if (profile != null) {
      Get.snackbar(
        'نجح! ✅',
        'تم جلب ملف $username بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('محلل الملفات الشخصية')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // حقل إدخال Username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username (بدون @)',
                hintText: 'nike',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            SizedBox(height: 16),

            // زر الجلب
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchProfile,
              icon: Icon(Icons.download),
              label: _isLoading
                ? Text('جاري الجلب...')
                : Text('جلب البيانات'),
            ),

            SizedBox(height: 32),

            // عرض النتائج
            if (_profile != null) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الصورة الشخصية
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profile!.profilePicUrl != null
                            ? NetworkImage(_profile!.profilePicUrl!)
                            : null,
                          child: _profile!.profilePicUrl == null
                            ? Icon(Icons.person, size: 50)
                            : null,
                        ),
                      ),

                      SizedBox(height: 16),

                      // الاسم
                      Text(
                        _profile!.fullName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Username
                      Text(
                        '@${_profile!.username}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 16),

                      // الإحصائيات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat('المنشورات', _profile!.postsCount),
                          _buildStat('المتابعون', _profile!.followers),
                          _buildStat('يتابع', _profile!.following),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Bio
                      Text(
                        _profile!.bio,
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 16),

                      // معدل التفاعل
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'معدل التفاعل: ${_profile!.engagementRate.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // المنشورات الأخيرة
                      Text(
                        'المنشورات الأخيرة (${_profile!.latestPosts.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _profile!.latestPosts.length,
                          itemBuilder: (context, index) {
                            final post = _profile!.latestPosts[index];
                            return Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: post.imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(post.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    ),
                                    child: post.imageUrl == null
                                      ? Icon(Icons.image)
                                      : null,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '❤️ ${post.likesCount}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Loading indicator
            if (_isLoading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري جلب البيانات من Instagram...'),
                  Text(
                    'قد يستغرق 10-30 ثانية',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value >= 1000
            ? '${(value / 1000).toStringAsFixed(1)}K'
            : value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
}
```

---

### مثال 2: جلب بيانات متعددة دفعة واحدة

```dart
class BulkAccountScraperScreen extends StatefulWidget {
  @override
  _BulkAccountScraperScreenState createState() => _BulkAccountScraperScreenState();
}

class _BulkAccountScraperScreenState extends State<BulkAccountScraperScreen> {
  final ApifyService _apify = Get.find<ApifyService>();

  List<Map<String, String>> _accountsToScrape = [
    {'platform': 'instagram', 'username': 'nike'},
    {'platform': 'instagram', 'username': 'adidas'},
    {'platform': 'instagram', 'username': 'puma'},
    {'platform': 'twitter', 'username': 'elonmusk'},
    {'platform': 'tiktok', 'username': 'charlidamelio'},
  ];

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  int _currentProgress = 0;
  int _totalAccounts = 0;

  Future<void> _scrapeAll() async {
    setState(() {
      _isLoading = true;
      _currentProgress = 0;
      _totalAccounts = _accountsToScrape.length;
      _results = [];
    });

    final results = await _apify.scrapeMultipleAccounts(
      accounts: _accountsToScrape,
      onProgress: (current, total) {
        setState(() {
          _currentProgress = current;
          _totalAccounts = total;
        });
      },
    );

    setState(() {
      _results = results;
      _isLoading = false;
    });

    final successful = results.where((r) => r['success'] == true).length;

    Get.snackbar(
      'اكتمل! ✅',
      'تم جلب $successful من ${results.length} حساب',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('جلب بيانات متعددة')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // قائمة الحسابات
            Text(
              'الحسابات المطلوبة (${_accountsToScrape.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _accountsToScrape.length,
                itemBuilder: (context, index) {
                  final account = _accountsToScrape[index];
                  final result = _results.length > index ? _results[index] : null;

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        _getPlatformIcon(account['platform']!),
                        color: _getPlatformColor(account['platform']!),
                      ),
                      title: Text('@${account['username']}'),
                      subtitle: Text(account['platform']!.toUpperCase()),
                      trailing: result != null
                        ? Icon(
                            result['success'] ? Icons.check_circle : Icons.error,
                            color: result['success'] ? Colors.green : Colors.red,
                          )
                        : (_isLoading && index < _currentProgress)
                          ? CircularProgressIndicator()
                          : null,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // Progress
            if (_isLoading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _totalAccounts > 0
                      ? _currentProgress / _totalAccounts
                      : 0,
                  ),
                  SizedBox(height: 8),
                  Text('جاري المعالجة: $_currentProgress / $_totalAccounts'),
                ],
              ),

            SizedBox(height: 16),

            // زر البدء
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _scrapeAll,
              icon: Icon(Icons.play_arrow),
              label: Text('جلب جميع الحسابات'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram': return Icons.camera_alt;
      case 'twitter': return Icons.comment;
      case 'tiktok': return Icons.music_note;
      case 'facebook': return Icons.facebook;
      default: return Icons.public;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram': return Color(0xFFE4405F);
      case 'twitter': return Color(0xFF1DA1F2);
      case 'tiktok': return Colors.black;
      case 'facebook': return Color(0xFF1877F2);
      default: return Colors.grey;
    }
  }
}
```

---

### مثال 3: عرض البيانات المحفوظة محلياً

```dart
class LocalAccountsScreen extends StatefulWidget {
  @override
  _LocalAccountsScreenState createState() => _LocalAccountsScreenState();
}

class _LocalAccountsScreenState extends State<LocalAccountsScreen> {
  final ApifyService _apify = Get.find<ApifyService>();
  String _selectedPlatform = 'instagram';
  List<Map<String, dynamic>> _localAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadLocalAccounts();
  }

  void _loadLocalAccounts() {
    final accounts = _apify.getLocalAccountsByPlatform(_selectedPlatform);
    setState(() {
      _localAccounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الحسابات المحفوظة'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () async {
              await _apify.clearAllLocalData();
              _loadLocalAccounts();
              Get.snackbar('تم!', 'تم حذف جميع البيانات المحلية');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Platform selector
          Padding(
            padding: EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: _selectedPlatform,
              isExpanded: true,
              items: ['instagram', 'twitter', 'tiktok', 'facebook']
                .map((platform) => DropdownMenuItem(
                  value: platform,
                  child: Text(platform.toUpperCase()),
                ))
                .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlatform = value!;
                });
                _loadLocalAccounts();
              },
            ),
          ),

          // Accounts list
          Expanded(
            child: _localAccounts.isEmpty
              ? Center(
                  child: Text('لا توجد حسابات محفوظة لـ $_selectedPlatform'),
                )
              : ListView.builder(
                  itemCount: _localAccounts.length,
                  itemBuilder: (context, index) {
                    final account = _localAccounts[index];
                    final data = account['data'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: data['profilePicUrl'] != null
                            ? NetworkImage(data['profilePicUrl'])
                            : null,
                          child: data['profilePicUrl'] == null
                            ? Icon(Icons.person)
                            : null,
                        ),
                        title: Text(data['fullName'] ?? data['username']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${account['username']}'),
                            Text(
                              'Followers: ${data['followersCount'] ?? data['followers'] ?? 0}',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'آخر تحديث: ${_formatDate(account['lastUpdated'])}',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _apify.deleteLocalAccountData(
                              platform: _selectedPlatform,
                              username: account['username'],
                            );
                            _loadLocalAccounts();
                          },
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'غير معروف';
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
```

---

## 🔄 الدمج مع OAuth

### الحل الهجين المثالي:

```dart
class HybridSocialMediaService extends GetxController {
  final ApifyService _apify = Get.find<ApifyService>();
  final SocialAccountsService _oauth = Get.find<SocialAccountsService>();

  /// جلب بيانات حساب - يستخدم OAuth إذا متصل، وإلا Apify
  Future<dynamic> getAccountData({
    required String platform,
    required String username,
  }) async {
    // تحقق إذا المستخدم ربط حسابه بـ OAuth
    final connectedAccount = _oauth.getConnectedAccount(platform, username);

    if (connectedAccount != null) {
      // ✅ استخدم OAuth API (أسرع وأدق)
      print('📡 Using OAuth for $username');
      return await _fetchViaOAuth(platform, username);
    } else {
      // ✅ استخدم Apify (بدون OAuth)
      print('🕷️ Using Apify for $username');
      return await _apify.scrapeAccount(
        platform: platform,
        username: username,
      );
    }
  }

  /// النشر - يتطلب OAuth دائماً
  Future<bool> postContent({
    required String platform,
    required String content,
  }) async {
    final account = _oauth.getConnectedAccount(platform, null);

    if (account == null) {
      Get.snackbar(
        'خطأ ❌',
        'يجب ربط حسابك أولاً للنشر',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // النشر عبر OAuth فقط
    return await _oauth.post(platform: platform, content: content);
  }

  Future<dynamic> _fetchViaOAuth(String platform, String username) async {
    // منطق OAuth...
    return {};
  }
}
```

### متى تستخدم OAuth vs Apify؟

| الميزة | OAuth | Apify |
|--------|-------|-------|
| **النشر** | ✅ نعم | ❌ لا |
| **جلب بيانات حسابك** | ✅ أسرع | ✅ يعمل |
| **جلب بيانات المنافسين** | ❌ لا | ✅ نعم |
| **الإحصائيات التفصيلية** | ✅ محدودة | ✅ شاملة |
| **التكلفة** | 🆓 مجاني | 💰 $49+/شهر |
| **السرعة** | ⚡ فوري | 🐌 10-30 ثانية |

**💡 التوصية:**
```
OAuth → للنشر والتفاعل (حسابات المستخدم)
Apify → للتحليلات والمنافسين (بدون ربط)
```

---

## 📊 حساب التكلفة

```dart
// مثال: كم تكلفة جلب 100 حساب Instagram؟
final cost = _apify.estimateCost(
  platform: 'instagram',
  accounts: 100,
  contentPerAccount: 50,
);

print('التكلفة التقديرية: \$$cost'); // ~$1.00
```

### تقدير التكاليف:

- **Instagram profile:** ~$0.01 لكل حساب
- **Twitter profile:** ~$0.40 لكل 1000 تغريدة
- **TikTok profile:** ~$0.02 لكل حساب
- **Facebook page:** ~$0.015 لكل صفحة

**مثال واقعي:**
- 50 حساب Instagram/شهر = ~$0.50
- 20 حساب TikTok/شهر = ~$0.40
- 30 حساب Twitter/شهر = ~$0.50

**الإجمالي: ~$1.40/شهر** (يمكن استخدام Free Plan!)

---

## ⚡ تحسين الأداء

### 1. Caching الذكي

```dart
Future<InstagramProfileFull?> getInstagramProfile(String username) async {
  // تحقق من البيانات المحلية أولاً
  final cached = _apify.getLocalAccountData(
    platform: 'instagram',
    username: username,
  );

  if (cached != null) {
    final lastUpdated = DateTime.parse(cached['lastUpdated']);
    final hoursSinceUpdate = DateTime.now().difference(lastUpdated).inHours;

    // إذا البيانات أحدث من 24 ساعة، استخدمها
    if (hoursSinceUpdate < 24) {
      print('💾 Using cached data');
      return InstagramProfileFull.fromApify(cached['data']);
    }
  }

  // وإلا، جلب جديد
  print('🌐 Fetching fresh data');
  return await _apify.scrapeInstagramProfile(username);
}
```

### 2. Background Processing

```dart
// جلب البيانات في الخلفية بدون تعطيل UI
void fetchInBackground(String username) {
  compute(_fetchProfile, username).then((profile) {
    // تحديث UI بعد الانتهاء
    setState(() {
      _profile = profile;
    });
  });
}

static Future<InstagramProfileFull?> _fetchProfile(String username) async {
  final apify = Get.find<ApifyService>();
  return await apify.scrapeInstagramProfile(username);
}
```

### 3. Batch Processing الذكي

```dart
// معالجة دفعات صغيرة لتجنب timeout
Future<void> scrapeLargeList(List<String> usernames) async {
  const batchSize = 5;

  for (int i = 0; i < usernames.length; i += batchSize) {
    final batch = usernames.skip(i).take(batchSize).toList();

    await Future.wait(
      batch.map((username) => _apify.scrapeInstagramProfile(username))
    );

    // راحة بين الدفعات
    if (i + batchSize < usernames.length) {
      await Future.delayed(Duration(seconds: 5));
    }
  }
}
```

---

## 🎯 أفضل الممارسات

### ✅ افعل:

```
✅ احفظ البيانات محلياً (Hive)
✅ استخدم caching للبيانات المكررة
✅ أضف تأخير بين الطلبات (3-5 ثوان)
✅ استخدم OAuth للنشر دائماً
✅ راقب استهلاك Credits
✅ عالج الأخطاء بشكل صحيح
```

### ❌ لا تفعل:

```
❌ تجلب نفس البيانات مرتين في يوم واحد
❌ ترسل طلبات كثيرة دفعة واحدة
❌ تحاول النشر عبر Apify
❌ تخزن بيانات حساسة
❌ تتجاوز الـ Rate Limits
```

---

## 🆘 حل المشاكل

### مشكلة: "Actor timeout"
**الحل:**
```dart
// زد الـ timeout
final runData = await _runActor(
  actorId: 'apify/instagram-scraper',
  input: input,
  timeout: Duration(minutes: 10), // بدلاً من 5
);
```

### مشكلة: "No credits remaining"
**الحل:**
- راجع استهلاكك: https://console.apify.com/billing
- اشترِ credits إضافية
- استخدم caching أكثر

### مشكلة: "Empty results"
**الحل:**
```dart
// تحقق من Username صحيح
// بعض الحسابات Private لا تعطي بيانات
// حاول مع حساب عام أولاً
```

---

## 📚 موارد إضافية

- **Apify Docs:** https://docs.apify.com
- **Actors Store:** https://apify.com/store
- **Pricing:** https://apify.com/pricing
- **API Reference:** https://docs.apify.com/api/v2

---

## ✅ Checklist قبل البدء

- [ ] سجلت في Apify
- [ ] حصلت على API Token
- [ ] أضفت Token في ApifyService
- [ ] سجلت السيرفس في main.dart
- [ ] فهمت الفرق بين OAuth و Apify
- [ ] حددت الاستخدامات المناسبة لكل واحد
- [ ] جهزت Hive للتخزين المحلي

---

**آخر تحديث:** 2025-11-16
**الحالة:** ✅ جاهز للاستخدام
**التكلفة:** $0-49/شهر

🚀 **ابدأ الآن مع Free Plan!**
