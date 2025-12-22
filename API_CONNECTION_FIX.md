# إصلاح مشكلة الاتصال بالـ Backend API

## 📋 المشكلة الأصلية

```
GET Request: https://mediaprosocial.io/api/social-accounts
❌ Error: فشل الاتصال بالخادم. تحقق من اتصالك بالإنترنت
```

## ✅ الحلول المنفذة

### 1️⃣ إضافة Connectivity Checker Service

**الملف الجديد:** `lib/core/services/connectivity_service.dart`

**المميزات:**
- مراقبة حالة الاتصال بالإنترنت في الوقت الفعلي
- دعم جميع أنواع الاتصالات (WiFi, Mobile Data, Ethernet, etc.)
- إمكانية الانتظار لحين توفر الاتصال مع timeout
- Observable state باستخدام GetX

**الاستخدام:**
```dart
final connectivity = ConnectivityService();

// التحقق من وجود اتصال
bool hasConnection = await connectivity.hasConnection();

// الاستماع لتغييرات الاتصال
connectivity.isConnected.listen((connected) {
  if (connected) {
    print('متصل بالإنترنت');
  } else {
    print('غير متصل بالإنترنت');
  }
});

// الانتظار لحين توفر الاتصال (مع timeout)
bool connected = await connectivity.waitForConnection(
  timeout: Duration(seconds: 10),
);
```

---

### 2️⃣ تحسين HTTP Service بـ Retry Logic

**الملف المحدث:** `lib/services/http_service.dart`

**التحسينات:**
- ✅ **Automatic Retry with Exponential Backoff**
  - عدد المحاولات: 3 (قابل للتعديل)
  - التأخير الأولي: 1 ثانية
  - مضاعف التأخير: 2x (1s → 2s → 4s)

- ✅ **Connectivity Check قبل كل Request**
  - يتحقق من وجود اتصال بالإنترنت قبل إرسال الطلب
  - رسالة خطأ واضحة في حالة عدم وجود اتصال

- ✅ **Better Error Handling**
  - معالجة `SocketException` (مشاكل الشبكة)
  - معالجة `TimeoutException` (انتهاء المهلة)
  - معالجة `HandshakeException` (مشاكل SSL/TLS)
  - معالجة `HttpException` (أخطاء HTTP)

- ✅ **Smart Retry Strategy**
  - يعيد المحاولة تلقائياً للأخطاء الشبكية (5xx, timeouts)
  - لا يعيد المحاولة لأخطاء العميل (4xx)
  - رسائل تفصيلية في console لكل محاولة

**مثال على السلوك الجديد:**
```
GET Request: https://mediaprosocial.io/api/social-accounts
Network error on attempt 1. Retrying in 1s...
Network error on attempt 2. Retrying in 2s...
Network error on attempt 3. Retrying in 4s...
Max retries reached. Last error: ...
❌ Error: فشل الاتصال بالخادم. تحقق من اتصالك بالإنترنت.
```

---

### 3️⃣ API Diagnostics Utility

**الملف الجديد:** `lib/core/utils/api_diagnostics.dart`

أداة شاملة لتشخيص مشاكل الاتصال بالـ API.

**الفحوصات:**
1. ✅ Internet Connectivity
2. ✅ DNS Resolution
3. ✅ Server Reachability (Ping)
4. ✅ SSL/TLS Certificate Validation
5. ✅ API Endpoint Health Check

**الاستخدام:**
```dart
import 'package:social_media_manager/core/utils/api_diagnostics.dart';

// تشغيل الفحص الشامل
final diagnostics = ApiDiagnostics();
final report = await diagnostics.runDiagnostics();

// طباعة الملخص
ApiDiagnostics.printReport(report);

// الحصول على النتيجة
if (report.isHealthy) {
  print('✅ جميع الاختبارات نجحت');
} else {
  print(report.getSummary());
}

// فحص سريع
bool isOk = await diagnostics.quickCheck();
```

**مثال على المخرجات:**
```
========== API Diagnostics Started ==========
1️⃣ Checking internet connectivity...
   Result: ✅ Connected
   Type: WiFi

2️⃣ Testing DNS resolution...
   Result: ✅ DNS resolved successfully
   Host: mediaprosocial.io
   IPs: 82.25.83.217

3️⃣ Testing server reachability...
   Result: ✅ Server reachable
   Status Code: 200
   Response Time: 234ms

4️⃣ Checking SSL/TLS certificate...
   Result: ✅ SSL certificate valid
   Subject: CN=mediaprosocial.io

5️⃣ Testing API endpoint...
   Result: ✅ API responded
   Status Code: 200

========== Diagnostics Completed ==========

📊 Diagnostic Report Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 Internet: ✅ (WiFi)
🔍 DNS: ✅
   IPs: 82.25.83.217
📡 Server: ✅
   Response Time: 234ms
🔒 SSL: ✅
🔌 API: ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 📦 Dependencies المضافة

تم إضافة package واحد فقط إلى `pubspec.yaml`:

```yaml
dependencies:
  connectivity_plus: ^6.0.5  # للتحقق من حالة الاتصال بالإنترنت
```

**التثبيت:**
```bash
flutter pub get
```

---

## 🔧 إعدادات Android

تم التحقق من جميع الـ permissions المطلوبة في `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

✅ جميع الإعدادات موجودة بالفعل ولا حاجة لتعديلات إضافية.

---

## 🧪 كيفية اختبار الإصلاحات

### الطريقة 1: من داخل التطبيق

أضف هذا الكود في أي شاشة أو controller:

```dart
import 'package:social_media_manager/core/utils/api_diagnostics.dart';
import 'package:social_media_manager/services/api_service.dart';

// 1. تشغيل الفحص الشامل
Future<void> testConnection() async {
  final diagnostics = ApiDiagnostics();
  final report = await diagnostics.runDiagnostics();
  ApiDiagnostics.printReport(report);

  // 2. اختبار API endpoint فعلي
  try {
    final apiService = ApiService();
    final accounts = await apiService.getSocialAccounts();
    print('✅ نجح الاتصال بالـ API!');
    print('عدد الحسابات: ${accounts['data']?.length ?? 0}');
  } catch (e) {
    print('❌ فشل الاتصال: $e');
  }
}
```

### الطريقة 2: من خلال التطبيق المباشر

عند تشغيل التطبيق، راقب console logs. ستجد رسائل تفصيلية عن كل request:

```
GET Request: https://mediaprosocial.io/api/social-accounts
Response Status: 200
Response Body: {...}
✅ Success!
```

في حالة وجود مشكلة:
```
GET Request: https://mediaprosocial.io/api/social-accounts
Network error on attempt 1. Retrying in 1s...
Network error on attempt 2. Retrying in 2s...
...
```

---

## 🚀 ماذا تفعل في حالة استمرار المشكلة؟

### 1. قم بتشغيل API Diagnostics

```dart
final diagnostics = ApiDiagnostics();
final report = await diagnostics.runDiagnostics();
print(report.getSummary());
```

### 2. تحقق من النتائج

**إذا كانت المشكلة في DNS:**
- تحقق من إعدادات DNS على الهاتف
- جرب استخدام DNS عام (8.8.8.8, 1.1.1.1)

**إذا كانت المشكلة في SSL:**
- تحقق من صلاحية شهادة SSL للدومين
- تأكد من أن التاريخ والوقت على الهاتف صحيحان
- للتطوير فقط: يمكنك تعطيل SSL verification (غير مستحسن)

**إذا كانت المشكلة في Server:**
- تحقق من أن الخادم يعمل بشكل صحيح
- اختبر الـ endpoint من Postman أو curl
- تحقق من CORS settings على Laravel backend

**إذا كانت المشكلة في Internet:**
- تحقق من اتصال الهاتف بالإنترنت
- جرب شبكة أخرى (WiFi → Mobile Data)

### 3. تفعيل وضع Development للمزيد من التفاصيل

في `lib/core/config/backend_config.dart`:

```dart
// تغيير إلى development للاختبار المحلي
static const bool isProduction = false;
static const String developmentBaseUrl = 'http://YOUR_LOCAL_IP:8000/api';
```

---

## 📝 ملاحظات مهمة

### التعامل مع Offline Mode

التطبيق يدعم **Offline-First Architecture**:
- ✅ يحفظ البيانات محلياً في Hive
- ✅ يعمل بدون اتصال
- ✅ يزامن تلقائياً عند توفر الاتصال

### Retry Configuration

يمكنك تعديل إعدادات الـ retry في `http_service.dart`:

```dart
class HttpService {
  static const int maxRetries = 3;              // عدد المحاولات
  static const Duration initialRetryDelay = Duration(seconds: 1);  // التأخير الأولي
  static const double retryDelayMultiplier = 2.0;  // مضاعف التأخير
}
```

### Timeout Configuration

يمكنك تعديل timeout durations في `backend_config.dart`:

```dart
class BackendConfig {
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
```

---

## 🎉 الخلاصة

تم إصلاح مشكلة الاتصال بالـ Backend من خلال:

1. ✅ إضافة connectivity checking قبل كل request
2. ✅ تنفيذ retry mechanism مع exponential backoff
3. ✅ معالجة أفضل لجميع أنواع الأخطاء (Network, Timeout, SSL)
4. ✅ إضافة أداة تشخيص شاملة للمساعدة في debugging
5. ✅ التحقق من جميع إعدادات Android

**النتيجة:**
- التطبيق الآن أكثر مرونة في التعامل مع مشاكل الشبكة
- رسائل خطأ واضحة ومفيدة للمستخدم
- إعادة محاولة تلقائية عند فشل الاتصال
- أدوات تشخيص قوية للمطورين

---

## 📞 الدعم

إذا واجهتك أي مشاكل:
1. قم بتشغيل API Diagnostics وشارك النتائج
2. راجع console logs للحصول على تفاصيل الخطأ
3. تأكد من أن الخادم يعمل بشكل صحيح
4. جرب الاتصال من Postman للتأكد من صحة الـ API

---

**آخر تحديث:** 2025-11-13
**الإصدار:** 1.0.0
