import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'laravel_api_service.dart';

class OTPService {
  static const String _otpKey = 'last_otp';
  static const String _otpTimeKey = 'otp_timestamp';
  static const String _isFirstLoginKey = 'is_first_login';
  static const String _testOTP = '12345678'; // رمز تجريبي ثابت
  static const String _defaultCountryCode = '+971'; // UAE default

  // الحصول على LaravelApiService
  LaravelApiService get _apiService => Get.find<LaravelApiService>();

  /// Format phone number with country code
  String formatPhoneNumber(String phoneNumber) {
    // Remove all spaces, dashes, and parentheses
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // If number already starts with +, return as is
    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    // If number starts with 00, replace with +
    if (cleaned.startsWith('00')) {
      return '+${cleaned.substring(2)}';
    }

    // If number starts with 0, remove it and add country code
    if (cleaned.startsWith('0')) {
      return '$_defaultCountryCode${cleaned.substring(1)}';
    }

    // If number doesn't have country code, add default
    if (!cleaned.startsWith('+')) {
      return '$_defaultCountryCode$cleaned';
    }

    return cleaned;
  }

  // توليد OTP عشوائي من 8 أرقام
  String generateOTP() {
    final random = Random();
    final otp = (10000000 + random.nextInt(90000000)).toString();
    return otp;
  }

  // حفظ OTP
  Future<void> saveOTP(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_otpKey, otp);
    await prefs.setInt(_otpTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // التحقق من OTP
  Future<bool> verifyOTP(String inputOTP) async {
    final prefs = await SharedPreferences.getInstance();
    final savedOTP = prefs.getString(_otpKey);
    final timestamp = prefs.getInt(_otpTimeKey);

    // قبول الرمز التجريبي الثابت دائماً
    if (inputOTP == _testOTP) {
      print('🧪 Test OTP verified: $inputOTP');
      return true;
    }

    if (savedOTP == null || timestamp == null) {
      return false;
    }

    // التحقق من صلاحية OTP (5 دقائق)
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - timestamp;
    final fiveMinutesInMillis = 5 * 60 * 1000;

    if (difference > fiveMinutesInMillis) {
      return false; // OTP منتهي الصلاحية
    }

    return savedOTP == inputOTP;
  }

  // إرسال OTP عبر Backend API
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      // تنسيق رقم الهاتف مع مقدمة الدولة
      final formattedPhone = formatPhoneNumber(phoneNumber);

      print('📱 Original phone: $phoneNumber');
      print('📱 Formatted phone: $formattedPhone');

      // استدعاء API الباك إند
      final result = await _apiService.post('/otp/send', {
        'phone_number': formattedPhone, // إرسال الرقم المنسق
      });

      if (result['success'] == true) {
        // حفظ OTP محلياً (في وضع التجربة، الباك إند يرجع OTP)
        if (result['otp'] != null) {
          await saveOTP(result['otp']);
        }

        print('✅ OTP sent successfully via backend');
        print('📱 Phone (formatted): $formattedPhone');
        if (result['test_mode'] == true) {
          print('🧪 Test OTP: ${result['otp']}');
        }
      } else {
        print('❌ Failed to send OTP: ${result['error']}');
      }

      return result;
    } catch (e) {
      print('❌ Error in sendOTP: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // التحقق من تسجيل الدخول الأول
  Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLoginKey) ?? true;
  }

  // تعيين تسجيل الدخول الأول كمكتمل
  Future<void> setFirstLoginCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLoginKey, false);
  }

  // حذف بيانات OTP
  Future<void> clearOTP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpKey);
    await prefs.remove(_otpTimeKey);
  }

  // حفظ بيانات المستخدم محلياً
  Future<void> saveUserLocally(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['id'].toString());
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_email', userData['email']);
    await prefs.setString('user_subscription', userData['subscriptionType']);
  }

  // التحقق من وجود بيانات محفوظة
  Future<bool> hasLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }

  // جلب بيانات المستخدم المحفوظة
  Future<Map<String, String>?> getLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!await hasLocalUserData()) {
      return null;
    }

    return {
      'id': prefs.getString('user_id') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'subscriptionType': prefs.getString('user_subscription') ?? 'individual',
    };
  }

  // حذف بيانات المستخدم المحفوظة
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_subscription');
  }
}
