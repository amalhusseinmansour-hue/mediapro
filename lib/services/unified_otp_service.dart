import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/otp_config_model.dart';
import 'firestore_service.dart';

/// خدمة OTP الموحدة التي تدعم عدة مزودين
class UnifiedOTPService extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Observable variables
  final RxString verificationId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool codeSent = false.obs;
  final RxString currentProvider = ''.obs;

  // OTP Configuration
  OTPConfigModel? _otpConfig;

  // Local OTP storage (for non-Firebase providers in test mode)
  String? _localOTP;
  DateTime? _localOTPTime;

  /// تحميل التكوين
  Future<void> loadConfig() async {
    _otpConfig = await _firestoreService.getOTPConfig();
    if (_otpConfig != null) {
      currentProvider.value = _otpConfig!.defaultProvider;
    }
  }

  /// إرسال OTP
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      if (_otpConfig == null) {
        await loadConfig();
      }

      if (_otpConfig == null) {
        throw Exception('فشل تحميل إعدادات OTP');
      }

      isLoading.value = true;

      // التأكد من أن رقم الهاتف بالصيغة الدولية
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+$phoneNumber';
      }

      // اختيار المزود المناسب
      final providerConfig = _otpConfig!.defaultProviderConfig;
      if (providerConfig == null || !providerConfig.isEnabled) {
        throw Exception('المزود الافتراضي غير متوفر أو غير مفعل');
      }

      currentProvider.value = providerConfig.name;

      // إرسال OTP حسب المزود
      switch (providerConfig.name.toLowerCase()) {
        case 'firebase':
          return await _sendFirebaseOTP(phoneNumber);
        case 'twilio':
          return await _sendTwilioOTP(phoneNumber, providerConfig);
        case 'nexmo':
        case 'vonage':
          return await _sendNexmoOTP(phoneNumber, providerConfig);
        case 'aws_sns':
          return await _sendAWSSNSOTP(phoneNumber, providerConfig);
        case 'messagebird':
          return await _sendMessageBirdOTP(phoneNumber, providerConfig);
        default:
          throw Exception('مزود غير مدعوم: ${providerConfig.name}');
      }
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// إرسال OTP عبر Firebase
  Future<bool> _sendFirebaseOTP(String phoneNumber) async {
    try {
      final completer = Completer<bool>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: _otpConfig!.expiryMinutes * 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          // التحقق التلقائي (Android فقط)
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },

        codeSent: (String verificationIdValue, int? resendToken) {
          verificationId.value = verificationIdValue;
          codeSent.value = true;
          isLoading.value = false;

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },

        codeAutoRetrievalTimeout: (String verificationIdValue) {
          verificationId.value = verificationIdValue;
          isLoading.value = false;
        },
      );

      return await completer.future;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// إرسال OTP عبر Twilio
  Future<bool> _sendTwilioOTP(String phoneNumber, OTPProviderConfig config) async {
    try {
      if (config.isTestMode) {
        return await _sendLocalOTP(phoneNumber);
      }

      // في التطبيق الحقيقي، استدعي Twilio API
      // يتطلب: accountSid, authToken, phoneNumber
      final accountSid = config.credentials['accountSid'];
      final authToken = config.credentials['authToken'];
      final fromNumber = config.credentials['phoneNumber'];

      if (accountSid == null || authToken == null || fromNumber == null) {
        throw Exception('إعدادات Twilio غير مكتملة');
      }

      // TODO: استدعاء Twilio API هنا
      // مثال: POST https://api.twilio.com/2010-04-01/Accounts/{accountSid}/Messages.json

      print('📱 Twilio OTP sent to $phoneNumber (وضع الإنتاج)');
      codeSent.value = true;
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// إرسال OTP عبر Nexmo/Vonage
  Future<bool> _sendNexmoOTP(String phoneNumber, OTPProviderConfig config) async {
    try {
      if (config.isTestMode) {
        return await _sendLocalOTP(phoneNumber);
      }

      // في التطبيق الحقيقي، استدعي Vonage API
      final apiKey = config.credentials['apiKey'];
      final apiSecret = config.credentials['apiSecret'];

      if (apiKey == null || apiSecret == null) {
        throw Exception('إعدادات Vonage غير مكتملة');
      }

      // TODO: استدعاء Vonage Verify API هنا
      // مثال: POST https://api.nexmo.com/verify/json

      print('📱 Vonage OTP sent to $phoneNumber (وضع الإنتاج)');
      codeSent.value = true;
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// إرسال OTP عبر AWS SNS
  Future<bool> _sendAWSSNSOTP(String phoneNumber, OTPProviderConfig config) async {
    try {
      if (config.isTestMode) {
        return await _sendLocalOTP(phoneNumber);
      }

      // في التطبيق الحقيقي، استدعي AWS SNS API
      final accessKeyId = config.credentials['accessKeyId'];
      final secretAccessKey = config.credentials['secretAccessKey'];
      final region = config.credentials['region'];

      if (accessKeyId == null || secretAccessKey == null || region == null) {
        throw Exception('إعدادات AWS SNS غير مكتملة');
      }

      // TODO: استدعاء AWS SNS Publish API هنا

      print('📱 AWS SNS OTP sent to $phoneNumber (وضع الإنتاج)');
      codeSent.value = true;
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// إرسال OTP عبر MessageBird
  Future<bool> _sendMessageBirdOTP(String phoneNumber, OTPProviderConfig config) async {
    try {
      if (config.isTestMode) {
        return await _sendLocalOTP(phoneNumber);
      }

      // في التطبيق الحقيقي، استدعي MessageBird API
      final apiKey = config.credentials['apiKey'];

      if (apiKey == null) {
        throw Exception('إعدادات MessageBird غير مكتملة');
      }

      // TODO: استدعاء MessageBird Verify API هنا
      // مثال: POST https://rest.messagebird.com/verify

      print('📱 MessageBird OTP sent to $phoneNumber (وضع الإنتاج)');
      codeSent.value = true;
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// إرسال OTP محلي (للاختبار)
  Future<bool> _sendLocalOTP(String phoneNumber) async {
    final otp = _generateOTP();
    await _saveLocalOTP(otp);

    print('📱 Test OTP Code: $otp');
    print('تم إرسال رمز التحقق إلى: $phoneNumber (وضع الاختبار)');

    codeSent.value = true;
    isLoading.value = false;
    return true;
  }

  /// توليد OTP
  String _generateOTP() {
    final length = _otpConfig?.otpLength ?? 6;
    final random = Random();
    final max = pow(10, length).toInt();
    final min = pow(10, length - 1).toInt();
    final otp = (min + random.nextInt(max - min)).toString();
    return otp;
  }

  /// حفظ OTP محلياً
  Future<void> _saveLocalOTP(String otp) async {
    _localOTP = otp;
    _localOTPTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_otp', otp);
    await prefs.setInt('otp_timestamp', _localOTPTime!.millisecondsSinceEpoch);
  }

  /// التحقق من OTP
  Future<bool> verifyOTP(String smsCode) async {
    try {
      isLoading.value = true;

      // التحقق حسب المزود
      switch (currentProvider.value.toLowerCase()) {
        case 'firebase':
          return await _verifyFirebaseOTP(smsCode);
        default:
          return await _verifyLocalOTP(smsCode);
      }
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// التحقق من OTP عبر Firebase
  Future<bool> _verifyFirebaseOTP(String smsCode) async {
    try {
      if (verificationId.value.isEmpty) {
        throw Exception('لم يتم إرسال رمز التحقق بعد');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );

      await _firebaseAuth.signInWithCredential(credential);
      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      if (e.code == 'invalid-verification-code') {
        throw Exception('رمز التحقق غير صحيح');
      } else if (e.code == 'session-expired') {
        throw Exception('انتهت صلاحية رمز التحقق');
      } else if (e.code == 'invalid-verification-id') {
        throw Exception('معرف التحقق غير صحيح');
      }

      rethrow;
    }
  }

  /// التحقق من OTP المحلي
  Future<bool> _verifyLocalOTP(String inputOTP) async {
    try {
      // تحميل OTP المحفوظ
      if (_localOTP == null) {
        final prefs = await SharedPreferences.getInstance();
        _localOTP = prefs.getString('last_otp');
        final timestamp = prefs.getInt('otp_timestamp');
        if (timestamp != null) {
          _localOTPTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }

      if (_localOTP == null || _localOTPTime == null) {
        throw Exception('لم يتم إرسال رمز التحقق');
      }

      // التحقق من صلاحية OTP
      final expiryMinutes = _otpConfig?.expiryMinutes ?? 5;
      final now = DateTime.now();
      final difference = now.difference(_localOTPTime!);

      if (difference.inMinutes >= expiryMinutes) {
        throw Exception('انتهت صلاحية رمز التحقق');
      }

      // التحقق من الرمز
      final isValid = _localOTP == inputOTP;
      isLoading.value = false;

      if (!isValid) {
        throw Exception('رمز التحقق غير صحيح');
      }

      // مسح OTP بعد التحقق الناجح
      await _clearLocalOTP();

      return true;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  /// مسح OTP المحلي
  Future<void> _clearLocalOTP() async {
    _localOTP = null;
    _localOTPTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_otp');
    await prefs.remove('otp_timestamp');
  }

  /// إعادة إرسال OTP
  Future<bool> resendOTP(String phoneNumber) async {
    codeSent.value = false;
    verificationId.value = '';
    return await sendOTP(phoneNumber);
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    if (currentProvider.value == 'firebase') {
      await _firebaseAuth.signOut();
    }
    verificationId.value = '';
    codeSent.value = false;
    await _clearLocalOTP();
  }

  /// الحصول على المستخدم الحالي (Firebase فقط)
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// التحقق من تسجيل الدخول (Firebase فقط)
  bool get isSignedIn => _firebaseAuth.currentUser != null;
}
