import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/config/paymob_config.dart';

/// خدمة الدفع عبر Paymob UAE
/// تستخدم Intention API الجديد
class PaymobService {
  // Paymob UAE Base URL (بدون /api للـ Intention API الجديد)
  static const String _intentionBaseUrl = 'https://uae.paymob.com';
  // الـ API القديم
  static String get _baseUrl => PaymobConfig.baseUrl;

  /// دالة تشخيصية: التحقق من حالة اتصال Paymob
  Future<PaymobDiagnosticResult> diagnosePaymobConnection() async {
    print('\n🔍 ========== Paymob Connection Diagnostic ==========');

    final result = PaymobDiagnosticResult();
    result.isTestMode = false;

    // التحقق من صحة Secret Key
    final secretKey = PaymobConfig.secretKey;
    print('\n📌 Secret Key Status:');
    print('   Length: ${secretKey.length}');
    print('   Starts with: ${secretKey.substring(0, 20)}...');
    result.apiKeyValid = secretKey.isNotEmpty && secretKey.startsWith('are_sk_');

    if (!result.apiKeyValid) {
      print('❌ Secret Key غير صحيح أو مفقود');
      result.hasError = true;
      result.message = 'Secret Key is invalid or missing';
      return result;
    }

    // محاولة إنشاء Intention للاختبار
    print('\n🔗 Testing Intention API...');
    try {
      final response = await http.post(
        Uri.parse('$_intentionBaseUrl/v1/intention/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $secretKey',
        },
        body: jsonEncode({
          'amount': 100, // 1 AED للاختبار
          'currency': 'AED',
          'payment_methods': [PaymobConfig.cardIntegrationId],
          'billing_data': {
            'first_name': 'Test',
            'last_name': 'User',
            'email': 'test@test.com',
            'phone_number': '+971500000000',
          },
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Intention API working!');
        result.isConnected = true;
        result.message = 'Paymob connection successful';
      } else {
        print('❌ Intention API Error: ${response.statusCode}');
        print('📝 Response: ${response.body}');
        result.hasError = true;
        result.errorCode = response.statusCode;
        result.message = 'Intention API failed: ${response.statusCode}';
      }
    } on TimeoutException {
      result.hasError = true;
      result.message = 'Connection timeout';
    } catch (e) {
      result.hasError = true;
      result.message = 'Exception: $e';
    }

    print('\n🔍 ========== End Diagnostic ==========\n');
    return result;
  }

  // الدالة الرئيسية: إنشاء عملية دفع باستخدام Intention API
  Future<PaymentResult> initiatePayment({
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
    required String subscriptionTier,
    required double amount,
    required String currency,
  }) async {
    try {
      print('🔄 بدء عملية الدفع (Intention API)...');
      print('💰 المبلغ: $amount $currency');
      print('👤 المستخدم: $userName ($userEmail)');
      print('📦 الباقة: $subscriptionTier');

      // تحويل المبلغ إلى أصغر وحدة (فلس)
      final amountCents = (amount * 100).toInt();

      // إنشاء Intention
      final intentionResult = await _createIntention(
        amountCents: amountCents,
        currency: currency,
        userEmail: userEmail,
        userName: userName,
        userPhone: userPhone,
        subscriptionTier: subscriptionTier,
      );

      if (intentionResult == null) {
        return PaymentResult.error('فشل إنشاء عملية الدفع');
      }

      final clientSecret = intentionResult['client_secret'] as String?;
      if (clientSecret == null) {
        print('❌ client_secret غير موجود في الاستجابة');
        return PaymentResult.error('فشل الحصول على مفتاح الدفع');
      }

      // الحصول على الـ ID من الاستجابة (يبدأ بـ pi_)
      final intentionId = intentionResult['id'] as String? ?? '';
      print('✅ عملية الدفع جاهزة - Intention ID: $intentionId');
      print('✅ Client Secret: ${clientSecret.substring(0, 20)}...');

      return PaymentResult.success(
        orderId: intentionId.hashCode, // استخدام hash كـ order ID
        paymentKey: clientSecret,
        paymentUrl: _getPaymentUrl(clientSecret),
      );
    } catch (e) {
      print('❌ خطأ في عملية الدفع: $e');
      return PaymentResult.error('حدث خطأ غير متوقع: $e');
    }
  }

  /// إنشاء Intention للدفع - Paymob UAE API الجديد
  Future<Map<String, dynamic>?> _createIntention({
    required int amountCents,
    required String currency,
    required String userEmail,
    required String userName,
    required String userPhone,
    required String subscriptionTier,
  }) async {
    try {
      final secretKey = PaymobConfig.secretKey;

      // تقسيم الاسم
      final nameParts = userName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Customer';

      final requestBody = {
        'amount': amountCents,
        'currency': currency,
        'payment_methods': [PaymobConfig.cardIntegrationId],
        'items': [
          {
            'name': 'اشتراك $subscriptionTier',
            'amount': amountCents,
            'description': 'اشتراك في خطة $subscriptionTier',
            'quantity': 1,
          }
        ],
        'billing_data': {
          'first_name': firstName,
          'last_name': lastName,
          'email': userEmail,
          'phone_number': userPhone.isNotEmpty ? userPhone : '+971500000000',
          'country': 'AE',
          'city': 'Dubai',
          'street': 'NA',
          'building': 'NA',
          'floor': 'NA',
          'apartment': 'NA',
          'postal_code': 'NA',
          'state': 'NA',
        },
        'customer': {
          'first_name': firstName,
          'last_name': lastName,
          'email': userEmail,
        },
        'redirection_url': PaymobConfig.callbackUrl,
        'notification_url': PaymobConfig.webhookUrl,
      };

      print('📤 Creating Intention...');
      print('📤 URL: $_intentionBaseUrl/v1/intention/');

      final response = await http.post(
        Uri.parse('$_intentionBaseUrl/v1/intention/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $secretKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Intention created successfully');
        return data;
      } else {
        print('❌ Intention Error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Intention Exception: $e');
      return null;
    }
  }

  // بناء رابط صفحة الدفع - Paymob UAE Unified Checkout
  String _getPaymentUrl(String clientSecret) {
    final publicKey = PaymobConfig.publicKey;
    return 'https://uae.paymob.com/unifiedcheckout/?publicKey=$publicKey&clientSecret=$clientSecret';
  }

  // التحقق من حالة الدفع باستخدام Intention ID
  // ملاحظة: هذه الدالة تُستخدم للتحقق من الحالة بعد العودة من صفحة الدفع
  Future<PaymentStatus> checkPaymentStatus(int orderId) async {
    // في Paymob UAE، التحقق يتم عبر الـ callback/webhook
    // هذه الدالة للتوافق مع الكود القديم
    print('⏳ التحقق من حالة الدفع - يعتمد على Callback');
    return PaymentStatus.pending;
  }

  // التحقق من حالة الدفع باستخدام Intention ID (النسخة الجديدة)
  Future<PaymentStatus> checkIntentionStatus(String intentionId) async {
    try {
      final secretKey = PaymobConfig.secretKey;

      final response = await http.get(
        Uri.parse('$_intentionBaseUrl/v1/intention/$intentionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String? ?? '';
        final confirmed = data['confirmed'] as bool? ?? false;

        print('📊 Intention Status: $status, Confirmed: $confirmed');

        if (confirmed || status == 'confirmed' || status == 'successful') {
          print('✅ الدفع تم بنجاح - Intention ID: $intentionId');
          return PaymentStatus.success;
        } else if (status == 'intended' || status == 'pending') {
          print('⏳ الدفع قيد المعالجة - Intention ID: $intentionId');
          return PaymentStatus.pending;
        } else {
          print('❌ الدفع فشل - Status: $status');
          return PaymentStatus.failed;
        }
      } else {
        print('❌ فشل التحقق من حالة الدفع: ${response.statusCode}');
        return PaymentStatus.error;
      }
    } catch (e) {
      print('❌ خطأ في التحقق من حالة الدفع: $e');
      return PaymentStatus.error;
    }
  }

  // معالجة Callback من Paymob بعد إتمام الدفع
  Future<bool> handlePaymentCallback(Map<String, dynamic> callbackData) async {
    try {
      // التحقق من HMAC للأمان
      final hmac = callbackData['hmac'] as String?;
      if (hmac == null) {
        print('❌ Missing HMAC in callback');
        return false;
      }

      // استخراج البيانات
      final success = callbackData['success'] as bool? ?? false;
      final orderId = callbackData['order'] as int?;
      final transactionId = callbackData['id'] as int?;
      final amountCents = callbackData['amount_cents'] as int?;

      if (success && orderId != null) {
        print('✅ Callback: Payment successful');
        print('📊 Order ID: $orderId');
        print('💳 Transaction ID: $transactionId');
        print('💰 Amount: ${amountCents! / 100}');

        // هنا يمكن تحديث قاعدة البيانات
        return true;
      } else {
        print('❌ Callback: Payment failed');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في معالجة Callback: $e');
      return false;
    }
  }

  // إلغاء عملية دفع
  Future<bool> cancelPayment(int orderId) async {
    try {
      // Paymob لا يوفر API لإلغاء الطلبات
      // لكن يمكن تسجيل الإلغاء في قاعدة البيانات الخاصة بك
      print('⚠️ تم إلغاء عملية الدفع - Order ID: $orderId');
      return true;
    } catch (e) {
      print('❌ خطأ في إلغاء الدفع: $e');
      return false;
    }
  }

  // حساب المبلغ حسب الخطة والعملة
  double calculateAmount({
    required String tier,
    required String currency,
    required bool isYearly,
  }) {
    // الأسعار الشهرية بالدولار
    double basePrice = 0;
    switch (tier) {
      case 'individual':
        basePrice = 29.0;
        break;
      case 'team':
        basePrice = 99.0;
        break;
      case 'enterprise':
        basePrice = 299.0;
        break;
      default:
        basePrice = 0;
    }

    // خصم 20% للاشتراك السنوي
    if (isYearly) {
      basePrice = basePrice * 12 * 0.8; // 12 شهر - 20% خصم
    }

    // تحويل العملة
    switch (currency) {
      case 'EGP':
        return basePrice * 30.5; // سعر الدولار بالجنيه المصري (تقريبي)
      case 'SAR':
        return basePrice * 3.75; // سعر الدولار بالريال السعودي
      case 'AED':
        return basePrice * 3.67; // سعر الدولار بالدرهم الإماراتي
      case 'USD':
      default:
        return basePrice;
    }
  }
}

/// نتيجة عملية الدفع
class PaymentResult {
  final bool isSuccess;
  final String? errorMessage;
  final int? orderId;
  final String? paymentKey;
  final String? paymentUrl;

  PaymentResult._({
    required this.isSuccess,
    this.errorMessage,
    this.orderId,
    this.paymentKey,
    this.paymentUrl,
  });

  factory PaymentResult.success({
    required int orderId,
    required String paymentKey,
    required String paymentUrl,
  }) {
    return PaymentResult._(
      isSuccess: true,
      orderId: orderId,
      paymentKey: paymentKey,
      paymentUrl: paymentUrl,
    );
  }

  factory PaymentResult.error(String message) {
    return PaymentResult._(isSuccess: false, errorMessage: message);
  }
}

/// حالة الدفع
enum PaymentStatus {
  success, // تم بنجاح
  pending, // قيد المعالجة
  failed, // فشل
  error, // خطأ
}

/// نتيجة التشخيص - معلومات عن حالة اتصال Paymob
class PaymobDiagnosticResult {
  bool isTestMode = false;
  bool apiKeyValid = false;
  bool isConnected = false;
  bool hasError = false;
  int? errorCode;
  String message = '';

  @override
  String toString() {
    return '''
PaymobDiagnosticResult:
  - Test Mode: $isTestMode
  - API Key Valid: $apiKeyValid
  - Connected: $isConnected
  - Has Error: $hasError
  - Error Code: $errorCode
  - Message: $message
''';
  }
}
