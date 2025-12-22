# 🧪 كيف تختبر Apify في التطبيق

## 🎯 خطوات الاختبار السريع

### الطريقة 1: من Dashboard

1. افتح التطبيق
2. اذهب إلى **Dashboard** أو **القائمة الرئيسية**
3. ابحث عن زر أو أيقونة "Test" أو "Settings"
4. أو استخدم الكود أدناه لإضافة زر

---

### الطريقة 2: إضافة زر Test مؤقت

إذا تريد تجربة سريعة، أضف هذا في **DashboardScreen** أو أي شاشة:

```dart
import 'package:get/get.dart';
import '../test/apify_test_screen.dart';

// في أي مكان في الـ body:
FloatingActionButton(
  onPressed: () => Get.to(() => const ApifyTestScreen()),
  child: const Icon(Icons.rocket_launch),
  backgroundColor: Colors.orange,
)
```

---

### الطريقة 3: Test مباشر من الكود

افتح **lib/main.dart** وغير الـ home مؤقتاً:

```dart
// في MyApp class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Social Media Manager',
      theme: ThemeController.getTheme(),
      home: ApifyTestScreen(), // ← للتجربة فقط
      ...
    );
  }
}
```

**⚠️ ملاحظة:** ارجع الكود بعد الاختبار!

---

## 🧪 ماذا تفعل في شاشة الاختبار؟

### 1. أدخل Username
```
جرب واحد من هؤلاء:
- nike
- instagram
- cristiano
- adidas
- puma
- أي username تريده!
```

### 2. اضغط "جلب البيانات"

### 3. انتظر 10-30 ثانية

### 4. شاهد السحر! ✨

سترى:
```
✅ الصورة الشخصية
✅ الاسم الكامل
✅ @username
✅ عدد المتابعين (Followers)
✅ عدد المنشورات (Posts)
✅ من يتابع (Following)
✅ معدل التفاعل (Engagement Rate)
✅ Bio الكاملة
✅ آخر 20 منشور مع صورهم
✅ عدد اللايكات لكل منشور
```

---

## 📊 مراقبة الـ Console

شاهد الـ console في Android Studio/VS Code:

```
✅ ApifyService initialized
🌐 Starting scrape for: nike
🚀 Running actor: apify/instagram-scraper
⏳ Actor started, waiting for completion...
📊 Actor status: RUNNING
📊 Actor status: RUNNING
📊 Actor status: RUNNING
✅ Actor completed successfully
📥 Fetching dataset: abc123xyz
📥 Fetched 20 items
💾 Data saved locally for: nike
✅ Instagram scrape completed for: nike
```

---

## 🎉 إذا نجح!

ستشوف notification:
```
🎉 نجح!
تم جلب بيانات @nike بنجاح
```

والبيانات محفوظة في Hive! 💾

---

## 🆘 إذا حدث خطأ؟

### Error: "Actor timeout"
```
✅ الحل: انتظر أكثر، بعض الحسابات تأخذ وقت
```

### Error: "No data found"
```
✅ الحل:
   - تأكد Username صحيح (بدون @)
   - جرب حساب عام مثل "nike"
   - تجنب Private accounts
```

### Error: "API token invalid"
```
✅ الحل:
   - راجع lib/services/apify_service.dart
   - تأكد Token صحيح
```

---

## 🔥 جرب ميزات متقدمة!

### 1. جلب عدة حسابات:

```dart
final apify = Get.find<ApifyService>();

final results = await apify.scrapeMultipleAccounts(
  accounts: [
    {'platform': 'instagram', 'username': 'nike'},
    {'platform': 'instagram', 'username': 'adidas'},
    {'platform': 'instagram', 'username': 'puma'},
  ],
);

print('جلبت ${results.length} حسابات!');
```

### 2. جلب بيانات محفوظة:

```dart
final apify = Get.find<ApifyService>();

final cached = apify.getLocalAccountData(
  platform: 'instagram',
  username: 'nike',
);

if (cached != null) {
  print('Cached data found!');
  print('Last updated: ${cached['lastUpdated']}');
}
```

### 3. جلب من Twitter:

```dart
final twitter = await apify.scrapeTwitterProfile('elonmusk');
print('Followers: ${twitter?.followers}');
```

### 4. جلب من TikTok:

```dart
final tiktok = await apify.scrapeTikTokProfile('charlidamelio');
print('TikTok followers: ${tiktok?.followers}');
```

---

## 📊 مراقبة Credits

### راجع استهلاكك:
```
👉 https://console.apify.com/billing/usage
```

ستشوف:
```
Free credits: $5.00
Used: $0.05
Remaining: $4.95

Total scrapes: 5
```

---

## 🎯 بعد الاختبار

إذا كل شيء تمام:

1. ✅ احتفظ بـ ApifyTestScreen للاستخدام لاحقاً
2. ✅ اعمل Competitor Analysis screen
3. ✅ اعمل Auto-scraping يومي
4. ✅ اعمل Dashboard هجين (OAuth + Apify)

---

## 💡 نصائح مهمة

### ✅ افعل:
```
✅ استخدم Apify للمنافسين
✅ احفظ البيانات محلياً (Hive)
✅ استخدم caching للبيانات المكررة
✅ راقب Credits باستمرار
```

### ❌ لا تفعل:
```
❌ تحاول النشر عبر Apify (استخدم OAuth)
❌ تجلب نفس البيانات مرتين في يوم واحد
❌ ترسل requests كثيرة دفعة واحدة
❌ تنسى تراقب Credits
```

---

## 🎉 استمتع!

الآن عندك القدرة على:
- ✅ جلب بيانات **أي حساب** Instagram, Twitter, TikTok, Facebook
- ✅ تحليل **المنافسين** بدون إذنهم
- ✅ **حفظ** كل شيء محلياً
- ✅ **مقارنة** حسابك مع المنافسين

**🚀 استمتع بالميزات الجديدة!**
