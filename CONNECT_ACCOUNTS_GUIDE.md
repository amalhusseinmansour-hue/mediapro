# دليل ربط الحسابات في التطبيق

## 📱 كيفية ربط الحسابات (مثل https://dashboard.thestring.net)

التطبيق الخاص بك يحتوي على **نظام كامل لربط الحسابات** مشابه لموقع The String!

---

## 🎯 الميزات المتوفرة

### 1️⃣ **Quick Connect Bottom Sheet**
ملف: `lib/screens/accounts/quick_connect_bottom_sheet.dart`

**الميزات:**
- ✅ واجهة سريعة وسهلة لربط الحسابات
- ✅ 8 منصات مدعومة:
  - 📘 Facebook (صفحات ومجموعات)
  - 📷 Instagram (منشورات وقصص)
  - 🐦 X/Twitter (تغريدات وخيوط)
  - 📺 YouTube (فيديوهات وقصص)
  - 💼 LinkedIn (منشورات احترافية)
  - 🎵 TikTok (فيديوهات قصيرة)
  - 👻 Snapchat (قصص وعدسات)
  - 📌 Pinterest (لوحات وصور)
- ✅ بحث سريع في المنصات
- ✅ تصميم عصري مع animations

### 2️⃣ **Accounts Screen**
ملف: `lib/screens/accounts/accounts_screen.dart`

**الميزات:**
- ✅ عرض جميع الحسابات المتصلة
- ✅ عداد للحسابات النشطة
- ✅ Pull-to-refresh لتحديث الحسابات
- ✅ إدارة كاملة للحسابات

### 3️⃣ **Connect Accounts Screen**
ملف: `lib/screens/accounts/connect_accounts_screen.dart`

**الميزات:**
- ✅ شرح خطوات الربط
- ✅ معلومات عن كل منصة
- ✅ اتصال آمن ومشفر

---

## 🚀 كيفية استخدام ميزة ربط الحسابات

### **الطريقة 1: من شاشة الحسابات**

1. افتح التطبيق
2. اذهب إلى شاشة "**الحسابات**" (Accounts Screen)
3. اضغط على زر "**+ إضافة حساب**" أو "**ربط حساب جديد**"
4. ستظهر لك Bottom Sheet بجميع المنصات
5. اختر المنصة التي تريد ربطها
6. اتبع خطوات OAuth للمصادقة

### **الطريقة 2: من Dashboard**

1. في الصفحة الرئيسية (Dashboard)
2. اضغط على "**Connect Accounts**"
3. اختر المنصة
4. أكمل عملية المصادقة

---

## 🔧 كيف يعمل نظام الربط؟

### **OAuth Flow:**

```dart
// في quick_connect_bottom_sheet.dart
Future<void> _connectPlatform(String platformId) async {
  // 1. التحقق من الاشتراك
  if (!_subscriptionService.canAddMoreAccounts()) {
    // عرض رسالة للترقية
    return;
  }

  // 2. بدء OAuth
  switch (platformId) {
    case 'facebook':
      await _connectFacebook();
      break;
    case 'instagram':
      await _connectInstagram();
      break;
    case 'twitter':
      await _connectTwitter();
      break;
    // ... باقي المنصات
  }

  // 3. حفظ الحساب
  await _accountsService.addAccount(...);

  // 4. إغلاق Bottom Sheet
  Get.back();
}
```

### **Facebook Graph API Integration:**

يستخدم التطبيق `FacebookGraphApiService` لـ:
- ✅ الحصول على صفحات المستخدم
- ✅ النشر على Facebook
- ✅ إدارة الأذونات

---

## 📊 البيانات المحفوظة لكل حساب

```dart
class SocialAccountModel {
  String id;
  String platform;        // 'facebook', 'instagram', etc.
  String accountName;     // اسم الحساب
  String accountId;       // ID من المنصة
  String? profileImageUrl;
  String? accessToken;    // للمصادقة
  bool isActive;
  Map<String, dynamic>? platformData;  // بيانات إضافية
  DateTime createdAt;
  DateTime updatedAt;
}
```

---

## 🛠️ الخدمات المستخدمة

### 1. **SocialAccountsService**
`lib/services/social_accounts_service.dart`

- ✅ إضافة/حذف/تحديث الحسابات
- ✅ التحقق من صلاحية الـ tokens
- ✅ التزامن مع Backend
- ✅ تخزين محلي في Hive

### 2. **OAuthService**
`lib/services/oauth_service.dart`

- ✅ معالجة OAuth flow لجميع المنصات
- ✅ إدارة الـ tokens
- ✅ تجديد الـ tokens المنتهية

### 3. **FacebookGraphApiService**
`lib/services/facebook_graph_api_service.dart`

- ✅ Graph API Integration
- ✅ الحصول على Pages
- ✅ النشر والجدولة

---

## 🔐 الأمان والخصوصية

1. **Tokens مشفرة:**
   - يتم تخزين الـ access tokens بشكل آمن
   - استخدام `flutter_secure_storage`

2. **OAuth 2.0:**
   - جميع المنصات تستخدم OAuth 2.0
   - لا يتم حفظ كلمات المرور

3. **HTTPS:**
   - جميع الاتصالات مشفرة

---

## 🎨 تحسينات مقترحة (لجعلها مثل The String)

### 1. **إضافة Multi-Account Support لنفس المنصة**

```dart
// السماح بربط أكثر من حساب فيسبوك
List<SocialAccountModel> getFacebookAccounts() {
  return accounts.where((acc) => acc.platform == 'facebook').toList();
}
```

### 2. **Team Collaboration**

```dart
// مشاركة الحسابات مع الفريق
class TeamMember {
  String userId;
  String role; // 'admin', 'editor', 'viewer'
  List<String> allowedAccounts;
}
```

### 3. **Account Groups**

```dart
// تجميع الحسابات
class AccountGroup {
  String id;
  String name;
  List<String> accountIds;
  Color color;
}
```

### 4. **Publishing Scheduler**

```dart
// جدولة النشر على حسابات متعددة
class ScheduledPost {
  String content;
  List<String> targetAccounts;
  DateTime scheduledTime;
  PostType type; // 'post', 'story', 'reel'
}
```

---

## 🚧 المشاكل الحالية والحلول

### ❌ مشكلة: لا يوجد اتصال بالإنترنت

**الحل:**
1. تأكد من اتصال الهاتف بالإنترنت (WiFi أو Mobile Data)
2. جرب فتح متصفح وزيارة أي موقع للتأكد
3. أعد تشغيل التطبيق

### ❌ مشكلة: فشل OAuth

**الحل:**
1. تأكد من إعدادات Facebook App:
   - Valid OAuth Redirect URIs
   - App في وضع Development أو Live
2. تحقق من Facebook App ID في `AndroidManifest.xml`

### ❌ مشكلة: Token منتهي الصلاحية

**الحل:**
التطبيق يتعامل مع هذا تلقائياً عبر:
```dart
// في oauth_service.dart
Future<String?> refreshToken(String platform) async {
  // تجديد التوكن تلقائياً
}
```

---

## 📝 TODO List لتحسين نظام الربط

- [ ] إضافة Bulk Connect (ربط عدة حسابات دفعة واحدة)
- [ ] إضافة Account Health Check (فحص صحة الاتصال)
- [ ] إضافة Connection History (سجل الاتصالات)
- [ ] إضافة Auto-Reconnect (إعادة اتصال تلقائي)
- [ ] إضافة Account Analytics (إحصائيات لكل حساب)
- [ ] دعم Threads من Meta
- [ ] دعم Telegram Channels

---

## 🎯 الخطوات التالية

### 1. اختبار الربط الحالي:

```dart
// أضف هذا في accounts_screen.dart
FloatingActionButton(
  onPressed: () {
    QuickConnectBottomSheet.show(context);
  },
  child: Icon(Icons.add),
)
```

### 2. تفعيل Demo Accounts للتجربة:

```dart
// في social_accounts_service.dart
void addDemoAccounts() {
  addAccount(
    platform: 'facebook',
    accountName: 'Demo Facebook Page',
    accountId: 'demo_123',
  );
  // ... add more demo accounts
}
```

### 3. اختبار مع الإنترنت الحقيقي:

```bash
# تأكد من الاتصال
flutter run

# راقب الـ logs
# ستجد رسائل مثل:
# ✅ Account connected successfully
# ❌ OAuth failed: ...
```

---

## 🔗 روابط مفيدة

- [Facebook Graph API Docs](https://developers.facebook.com/docs/graph-api)
- [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api)
- [Twitter API v2](https://developer.twitter.com/en/docs/twitter-api)
- [YouTube Data API](https://developers.google.com/youtube/v3)
- [LinkedIn API](https://docs.microsoft.com/en-us/linkedin/)

---

**ملاحظة مهمة:** تأكد من وجود اتصال إنترنت قوي عند ربط الحسابات لأول مرة!
