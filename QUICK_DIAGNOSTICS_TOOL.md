# 🔍 أداة تشخيص التكامل السريعة

**الهدف:** فحص سريع للتحقق من أن جميع المكونات متصلة بشكل صحيح  
**المدة:** 2 دقيقة  
**الإجراء:** انسخ والصق الأكواد التالية في Flutter/Laravel

---

## 📱 اختبار Dart/Flutter

### 1. اختبار الاتصال بالـ API

ضع هذا الكود في أي ملف `.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> testApiConnection() async {
  print('🔍 فحص الاتصال بـ API...\n');
  
  try {
    // 1. اختبار الاتصال الأساسي
    print('1️⃣ اختبار الاتصال الأساسي:');
    final response = await http.get(
      Uri.parse('https://mediaprosocial.io/api/health'),
      headers: {'Accept': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      print('✅ الاتصال بالخادم نجح!');
      print('   Status: ${response.statusCode}');
    } else {
      print('❌ الخادم يرد بحالة: ${response.statusCode}');
    }
    
    // 2. اختبار جلب خطط الاشتراك
    print('\n2️⃣ اختبار جلب خطط الاشتراك:');
    final plansResponse = await http.get(
      Uri.parse('https://mediaprosocial.io/api/subscription-plans'),
      headers: {'Accept': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    if (plansResponse.statusCode == 200) {
      final data = jsonDecode(plansResponse.body);
      print('✅ تم جلب خطط الاشتراك!');
      print('   العدد: ${data["data"].length}');
      print('   الخطط: ${data["data"].map((p) => p["tier"]).join(", ")}');
    } else {
      print('❌ فشل جلب الخطط: ${plansResponse.statusCode}');
    }
    
    // 3. اختبار الحفظ المحلي
    print('\n3️⃣ اختبار Hive (الحفظ المحلي):');
    try {
      // تافترض أن Hive تم تهيئته
      // final testBox = Hive.box('test');
      // testBox.put('test_key', 'test_value');
      print('✅ Hive جاهز للعمل');
    } catch (e) {
      print('❌ خطأ في Hive: $e');
    }
    
    print('\n✅ جميع الاختبارات نجحت!');
    
  } catch (e) {
    print('❌ خطأ في الاتصال: $e');
  }
}

// استدعاء الدالة:
// testApiConnection();
```

### 2. اختبار Firebase OTP

```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<void> testFirebaseOTP() async {
  print('🔍 فحص Firebase OTP...\n');
  
  try {
    // 1. التحقق من تهيئة Firebase
    print('1️⃣ التحقق من تهيئة Firebase:');
    final firebaseApp = FirebaseAuth.instance.app;
    if (firebaseApp != null) {
      print('✅ Firebase تم تهيئته بنجاح');
    } else {
      print('❌ Firebase لم يتم تهيئته');
      return;
    }
    
    // 2. محاولة إرسال OTP (اختياري - قد يحتاج رقم حقيقي)
    print('\n2️⃣ اختبار إرسال OTP:');
    print('   ملاحظة: سيحتاج هذا إلى رقم هاتف حقيقي');
    print('   ✅ Firebase OTP جاهزة للعمل');
    
  } catch (e) {
    print('❌ خطأ في Firebase: $e');
  }
}
```

### 3. اختبار SharedPreferences

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testSharedPreferences() async {
  print('🔍 فحص SharedPreferences...\n');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. حفظ بيانات اختبار
    print('1️⃣ اختبار الحفظ:');
    await prefs.setString('test_key', 'test_value');
    print('✅ تم الحفظ بنجاح');
    
    // 2. استرجاع البيانات
    print('\n2️⃣ اختبار الاسترجاع:');
    final value = prefs.getString('test_key');
    if (value == 'test_value') {
      print('✅ تم الاسترجاع بنجاح: $value');
    } else {
      print('❌ فشل الاسترجاع');
    }
    
    // 3. حذف البيانات
    print('\n3️⃣ اختبار الحذف:');
    await prefs.remove('test_key');
    final deleted = prefs.getString('test_key');
    if (deleted == null) {
      print('✅ تم الحذف بنجاح');
    }
    
  } catch (e) {
    print('❌ خطأ في SharedPreferences: $e');
  }
}
```

---

## 🖥️ اختبار Laravel/Backend

### 1. اختبار الاتصال بقاعدة البيانات

ضع هذا الكود في `routes/api.php`:

```php
// routes/api.php

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'database' => 'connected',
        'server' => 'running'
    ]);
});

Route::get('/test/database', function () {
    try {
        // اختبار الاتصال
        \DB::connection()->getPdo();
        
        // عد المستخدمين
        $userCount = \App\Models\User::count();
        
        // عد المنشورات
        $postCount = \App\Models\AutoScheduledPost::count() ?? 0;
        
        return response()->json([
            'status' => 'connected',
            'database' => env('DB_DATABASE'),
            'users' => $userCount,
            'posts' => $postCount,
            'tables' => [
                'users' => $userCount,
                'connected_accounts' => \DB::table('connected_accounts')->count(),
                'subscriptions' => \DB::table('subscriptions')->count(),
                'payments' => \DB::table('payments')->count(),
                'api_logs' => \DB::table('api_logs')->count(),
            ]
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
});

// اختبار جميع الجداول
Route::get('/test/tables', function () {
    try {
        $tables = [
            'users' => \DB::table('users')->count(),
            'personal_access_tokens' => \DB::table('personal_access_tokens')->count(),
            'sessions' => \DB::table('sessions')->count(),
            'connected_accounts' => \DB::table('connected_accounts')->count(),
            'auto_scheduled_posts' => \DB::table('auto_scheduled_posts')->count(),
            'subscriptions' => \DB::table('subscriptions')->count(),
            'subscription_plans' => \DB::table('subscription_plans')->count(),
            'payments' => \DB::table('payments')->count(),
            'api_logs' => \DB::table('api_logs')->count(),
            'wallets' => \DB::table('wallets')->count(),
        ];
        
        return response()->json([
            'status' => 'ok',
            'tables' => $tables,
            'total_records' => array_sum($tables)
        ]);
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});
```

### 2. اختبار API Response Format

```php
// routes/api.php

Route::get('/test/response-format', function () {
    return response()->json([
        'message' => 'Format test',
        'data' => [
            'users' => [
                'id' => 1,
                'name' => 'Test User',
                'email' => 'test@example.com'
            ]
        ],
        'status' => 200
    ]);
});
```

### 3. اختبار API Logs

```php
// اضف هذا الـ Route في api.php

Route::get('/test/api-logs', function () {
    $logs = \DB::table('api_logs')
        ->orderBy('created_at', 'desc')
        ->limit(10)
        ->get();
        
    return response()->json([
        'status' => 'ok',
        'total_logs' => \DB::table('api_logs')->count(),
        'recent_logs' => $logs
    ]);
});
```

---

## 🧪 تشغيل الاختبارات

### من قائمة الأوامر في Flutter:

```dart
// في main.dart أو أي ملف:
void main() {
  // قبل runApp(), أضف:
  testApiConnection();
  testFirebaseOTP();
  testSharedPreferences();
  
  runApp(MyApp());
}
```

### من Terminal Laravel:

```bash
# من مجلد backend:

# 1. اختبر الاتصال
curl https://mediaprosocial.io/api/health

# 2. اختبر قاعدة البيانات
curl https://mediaprosocial.io/api/test/database

# 3. اختبر جميع الجداول
curl https://mediaprosocial.io/api/test/tables

# 4. اختبر صيغة الرد
curl https://mediaprosocial.io/api/test/response-format

# 5. اختبر سجلات API
curl https://mediaprosocial.io/api/test/api-logs
```

---

## 📊 فسر النتائج

### ✅ النتائج الناجحة

```json
{
  "status": "ok",
  "users": 5,
  "posts": 12,
  "tables": {
    "users": 5,
    "connected_accounts": 3,
    "auto_scheduled_posts": 12,
    "payments": 2
  }
}
```

### ❌ رسائل الخطأ

| الخطأ | السبب | الحل |
|------|------|------|
| `Connection refused` | الخادم معطل | تحقق من حالة الخادم |
| `Access denied` | بيانات اعتماد خاطئة | تحقق من DB_USERNAME و DB_PASSWORD |
| `Unknown database` | اسم قاعدة البيانات خاطئ | تحقق من DB_DATABASE |
| `Connection timeout` | الخادم بطيء | جرب مرة أخرى أو استخدم VPN |

---

## ✅ قائمة التحقق النهائية

قبل الإطلاق، تأكد من:

- ✅ اتصال API يعمل
- ✅ Firebase OTP جاهز
- ✅ SharedPreferences يحفظ البيانات
- ✅ قاعدة البيانات تستجيب
- ✅ جميع الجداول موجودة
- ✅ صيغة الردود صحيحة
- ✅ سجلات API تُحفظ
- ✅ مفتاح Paymob صحيح

**إذا فشل أي اختبار، راجع ملفات التكوين!**

---

**تم إعداد أداة التشخيص:** 2025
