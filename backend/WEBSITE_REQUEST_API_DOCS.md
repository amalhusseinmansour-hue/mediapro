# حل مشكلة ApiService not found - طلب موقع إلكتروني

## المشكلة
عند محاولة إرسال طلب موقع إلكتروني من التطبيق، يظهر خطأ: `ApiService not found - you need to call...`

## السبب
هذا الخطأ يحدث في تطبيق Flutter عندما لا يتم تهيئة `ApiService` بشكل صحيح، أو عندما يتم استدعاؤه قبل تهيئته.

## الحل

### الطريقة 1: التأكد من تهيئة ApiService في main.dart

تأكد من أن `ApiService` يتم تهيئته في ملف `main.dart` قبل تشغيل التطبيق:

```dart
import 'package:get_it/get_it.dart';
import 'package:your_app/services/api_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<ApiService>(() => ApiService());
}

void main() {
  setupServiceLocator(); // يجب استدعاء هذا قبل runApp
  runApp(MyApp());
}
```

### الطريقة 2: استخدام Provider

إذا كنت تستخدم Provider، تأكد من تهيئة ApiService في root widget:

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: MyApp(),
    ),
  );
}
```

### الطريقة 3: استخدام Singleton Pattern

يمكنك جعل `ApiService` singleton:

```dart
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // الكود الخاص بك هنا
}
```

## API Documentation - طلب موقع إلكتروني

### Endpoint
```
POST https://mediaprosocial.io/api/website-requests
```

### Headers
```
Content-Type: application/json
Accept: application/json
```

### Request Body
```json
{
  "name": "اسم العميل",
  "email": "email@example.com",
  "phone": "+966501234567",
  "company_name": "اسم الشركة (اختياري)",
  "website_type": "corporate", // corporate, ecommerce, blog, portfolio, custom
  "description": "وصف المشروع",
  "budget": 5000,
  "currency": "SAR",
  "deadline": "2025-12-19",
  "features": ["responsive", "cms", "seo"]
}
```

### Response (Success - 201)
```json
{
  "success": true,
  "message": "تم إرسال طلبك بنجاح! سنتواصل معك قريباً.",
  "data": {
    "id": 1,
    "name": "اسم العميل",
    "email": "email@example.com",
    "phone": "+966501234567",
    "company_name": "اسم الشركة",
    "website_type": "corporate",
    "description": "وصف المشروع",
    "budget": "5000.00",
    "currency": "SAR",
    "deadline": "2025-12-19T00:00:00.000000Z",
    "features": ["responsive", "cms", "seo"],
    "status": "pending",
    "created_at": "2025-11-19T03:24:26.000000Z",
    "updated_at": "2025-11-19T03:24:26.000000Z"
  }
}
```

### Response (Validation Error - 422)
```json
{
  "success": false,
  "message": "بيانات غير صحيحة",
  "errors": {
    "email": ["The email field is required."],
    "phone": ["The phone field is required."]
  }
}
```

## مثال على كود Flutter

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = 'https://mediaprosocial.io/api';

  Future<Map<String, dynamic>> submitWebsiteRequest({
    required String name,
    required String email,
    required String phone,
    String? companyName,
    required String websiteType,
    required String description,
    double? budget,
    String? currency,
    String? deadline,
    List<String>? features,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/website-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'company_name': companyName,
          'website_type': websiteType,
          'description': description,
          'budget': budget,
          'currency': currency,
          'deadline': deadline,
          'features': features,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل إرسال الطلب: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}
```

## استخدام ApiService في Widget

```dart
class WebsiteRequestForm extends StatefulWidget {
  @override
  _WebsiteRequestFormState createState() => _WebsiteRequestFormState();
}

class _WebsiteRequestFormState extends State<WebsiteRequestForm> {
  final ApiService apiService = ApiService(); // استخدام الـ Singleton

  Future<void> submitRequest() async {
    try {
      final result = await apiService.submitWebsiteRequest(
        name: 'أحمد محمد',
        email: 'ahmed@example.com',
        phone: '+966501234567',
        websiteType: 'corporate',
        description: 'نريد موقع احترافي',
        budget: 5000,
        currency: 'SAR',
      );

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    } catch (e) {
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: submitRequest,
      child: Text('إرسال الطلب'),
    );
  }
}
```

## ملاحظات هامة

1. **Rate Limiting**: الـ API محمي بـ rate limiting (5 طلبات في الدقيقة)
2. **Validation**: جميع الحقول المطلوبة يجب إرسالها
3. **Website Types**: الأنواع المسموحة هي: `corporate`, `ecommerce`, `blog`, `portfolio`, `custom`
4. **Deadline**: يجب أن يكون التاريخ في المستقبل
5. **Budget**: يجب أن يكون رقم موجب

## اختبار API

تم اختبار الـ API وهو يعمل بشكل صحيح:
✓ HTTP Status: 201
✓ Response: Success
✓ Data saved to database

## الدعم الفني

إذا واجهت أي مشاكل، تأكد من:
- تهيئة ApiService قبل استخدامه
- استخدام الـ headers الصحيحة
- إرسال جميع الحقول المطلوبة
- التحقق من اتصال الإنترنت
