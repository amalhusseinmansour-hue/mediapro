import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../core/error/app_logger.dart';
import '../models/user_model.dart';
import 'laravel_api_service.dart';
import 'api_service.dart';

/// خدمة Firebase Phone Authentication المتقدمة
/// تتعامل مع OTP عبر Firebase Phone Auth
class FirebasePhoneAuthService extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  // Get Laravel API Service
  LaravelApiService? get _laravelApiService {
    try {
      return Get.find<LaravelApiService>();
    } catch (e) {
      print('⚠️ LaravelApiService not available: $e');
      return null;
    }
  }

  // Observable variables
  final RxString verificationId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool codeSent = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt resendToken = 0.obs;
  final RxInt remainingSeconds = 0.obs;
  final RxBool isCodeExpired = false.obs;

  // OTP Configuration
  static const int OTP_TIMEOUT_SECONDS = 120; // 2 دقائق
  static const int MAX_RETRIES = 5;
  static const int RESEND_COOLDOWN_SECONDS = 60;

  Timer? _countdownTimer;
  int _otpAttempts = 0;
  DateTime? _lastSendTime;

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  /// ✅ إرسال OTP إلى رقم الهاتف
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      // التحقق من صيغة الرقم
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+$phoneNumber';
      }

      // التحقق من محاولات الإرسال المتكررة
      if (!_canResendOTP()) {
        final secondsLeft =
            RESEND_COOLDOWN_SECONDS -
            DateTime.now().difference(_lastSendTime!).inSeconds;
        throw Exception('الرجاء الانتظار $secondsLeft ثانية قبل إعادة الإرسال');
      }

      isLoading.value = true;
      errorMessage.value = '';
      codeSent.value = false;
      _otpAttempts = 0;

      _logger.info('📱 جاري إرسال OTP إلى: $phoneNumber');

      final completer = Completer<bool>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: OTP_TIMEOUT_SECONDS),
        verificationCompleted: (PhoneAuthCredential credential) async {
          /// التحقق التلقائي (Android فقط)
          _logger.info('✅ تم التحقق التلقائي من الهاتف');
          await _handleAutoVerification(credential);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ خطأ في التحقق: ${e.message}');
          errorMessage.value = _mapFirebaseError(e.code, e.message);
          isLoading.value = false;
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (String verificationIdValue, int? resendTokenValue) {
          /// تم إرسال الرمز بنجاح
          _logger.info('✅ تم إرسال رمز التحقق بنجاح');
          verificationId.value = verificationIdValue;
          codeSent.value = true;
          isLoading.value = false;
          _lastSendTime = DateTime.now();

          if (resendTokenValue != null) {
            resendToken.value = resendTokenValue;
          }

          _startCountdown();

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        codeAutoRetrievalTimeout: (String verificationIdValue) {
          /// انتهاء وقت استرجاع الرمز التلقائي
          _logger.info('⏰ انتهى وقت استرجاع الرمز التلقائي');
          verificationId.value = verificationIdValue;
          isCodeExpired.value = true;
          isLoading.value = false;
        },
      );

      return await completer.future;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      _logger.error('خطأ في إرسال OTP', e);
      rethrow;
    }
  }

  /// ✅ التحقق من رمز OTP
  Future<UserCredential?> verifyOTP(String otp) async {
    try {
      if (verificationId.isEmpty) {
        throw Exception(
          'معرف التحقق غير موجود. الرجاء محاولة الإرسال مرة أخرى',
        );
      }

      if (otp.isEmpty || otp.length != 6) {
        throw Exception('الرجاء إدخال رمز من 6 أرقام');
      }

      isLoading.value = true;
      errorMessage.value = '';

      _logger.info('🔐 جاري التحقق من رمز OTP...');

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      _logger.info('✅ تم التحقق من OTP بنجاح');
      _logger.debug('👤 UID: ${userCredential.user?.uid}');
      _logger.debug('📱 الهاتف: ${userCredential.user?.phoneNumber}');

      // حفظ البيانات في Firestore
      await _savePhoneAuthData(userCredential.user!);

      // حفظ البيانات في Laravel
      await _saveUserToLaravel(userCredential.user!);

      _otpAttempts = 0;
      isLoading.value = false;
      _countdownTimer?.cancel();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _otpAttempts++;
      isLoading.value = false;
      errorMessage.value = _mapFirebaseError(e.code, e.message);

      _logger.warning('خطأ في التحقق من OTP', e);

      if (_otpAttempts >= MAX_RETRIES) {
        throw Exception(
          'تم تجاوز عدد المحاولات المسموحة. الرجاء إعادة الإرسال',
        );
      }

      rethrow;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      _logger.error('خطأ غير متوقع في التحقق من OTP', e);
      rethrow;
    }
  }

  /// ✅ إعادة إرسال OTP
  Future<bool> resendOTP(String phoneNumber) async {
    try {
      _countdownTimer?.cancel();
      remainingSeconds.value = 0;
      return await sendOTP(phoneNumber);
    } catch (e) {
      _logger.error('خطأ في إعادة الإرسال', e);
      rethrow;
    }
  }

  /// ✅ معالجة التحقق التلقائي
  Future<void> _handleAutoVerification(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      await _savePhoneAuthData(userCredential.user!);
      await _saveUserToLaravel(userCredential.user!);
    } catch (e) {
      _logger.error('خطأ في التحقق التلقائي', e);
    }
  }

  /// ✅ حفظ بيانات المصادقة عبر الهاتف
  Future<void> _savePhoneAuthData(User firebaseUser) async {
    try {
      final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
      final userSnapshot = await userDoc.get();

      final userData = {
        'uid': firebaseUser.uid,
        'phoneNumber': firebaseUser.phoneNumber,
        'lastPhoneAuthTime': FieldValue.serverTimestamp(),
        'phoneVerified': true,
        'authMethod': 'phone',
        if (!userSnapshot.exists) ...{
          'createdAt': FieldValue.serverTimestamp(),
          'name': firebaseUser.phoneNumber?.replaceAll('+', ''),
          'email': '',
          'profileImage': '',
          'isActive': true,
        },
      };

      await userDoc.set(userData, SetOptions(merge: true));
      _logger.info(
        '✅ تم حفظ بيانات المصادقة في Firestore for user ${firebaseUser.uid}',
      );
    } catch (e) {
      _logger.error('خطأ في حفظ بيانات المصادقة في Firestore', e);
    }
  }

  /// ✅ بدء العد العكسي
  void _startCountdown() {
    remainingSeconds.value = OTP_TIMEOUT_SECONDS;
    isCodeExpired.value = false;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        isCodeExpired.value = true;
        timer.cancel();
      }
    });
  }

  /// ✅ التحقق من إمكانية إعادة الإرسال
  bool _canResendOTP() {
    if (_lastSendTime == null) {
      return true;
    }

    final secondsElapsed = DateTime.now().difference(_lastSendTime!).inSeconds;
    return secondsElapsed >= RESEND_COOLDOWN_SECONDS;
  }

  /// ✅ تعيين أخطاء Firebase إلى رسائل عربية
  String _mapFirebaseError(String code, [String? originalMessage]) {
    switch (code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'missing-phone-number':
        return 'الرجاء إدخال رقم الهاتف';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'session-expired':
        return 'انتهت جلسة التحقق. الرجاء إعادة المحاولة';
      case 'too-many-requests':
        return 'عدد محاولات كثير جداً. الرجاء المحاولة لاحقاً';
      case 'operation-not-allowed':
        return 'المصادقة عبر الهاتف غير مفعلة';
      case 'network-request-failed':
        return 'خطأ في الاتصال بالإنترنت';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      default:
        return originalMessage ??
            'حدث خطأ غير معروف. الرجاء المحاولة مرة أخرى.';
    }
  }

  /// ✅ الحصول على بيانات المستخدم الحالي
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// ✅ تسجيل الخروج
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _countdownTimer?.cancel();
      verificationId.value = '';
      codeSent.value = false;
      _otpAttempts = 0;
      _logger.info('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      _logger.error('خطأ في تسجيل الخروج', e);
      rethrow;
    }
  }

  /// ✅ الحصول على حالة المصادقة
  Stream<User?> getAuthStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// ✅ التحقق من تسجيل الدخول
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// ✅ حفظ بيانات المستخدم في Laravel Backend
  Future<void> _saveUserToLaravel(User firebaseUser) async {
    try {
      if (_laravelApiService == null) return;

      final user = UserModel(
        id: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        name: firebaseUser.displayName ?? firebaseUser.phoneNumber?.replaceAll('+', '') ?? 'User',
        email: firebaseUser.email ?? '',
        isLoggedIn: true,
        isPhoneVerified: true,
        subscriptionType: 'individual',
        subscriptionStartDate: DateTime.now(),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      final success = await _laravelApiService!.registerUser(user);
      if (success) {
        // تحديث وقت آخر تسجيل دخول
        await _laravelApiService!.updateUserLastLogin(user.id);

        // تمرير Auth Token للـ ApiService
        final token = _laravelApiService!.authToken.value;
        if (token.isNotEmpty) {
          try {
            final apiService = Get.find<ApiService>();
            apiService.setAuthToken(token);
            _logger.info('✅ Auth token set in ApiService');
          } catch (e) {
            _logger.warning('⚠️ ApiService not found, token not set');
          }
        }
        _logger.info('✅ تم حفظ بيانات المستخدم في Laravel Backend');
      } else {
        _logger.warning('⚠️ فشل حفظ بيانات المستخدم في Laravel Backend');
      }
    } catch (e) {
      _logger.error('خطأ في حفظ بيانات المستخدم في Laravel', e);
    }
  }

  /// ✅ الحصول على معلومات OTP الحالية
  Map<String, dynamic> getOTPStatus() {
    return {
      'codeSent': codeSent.value,
      'isLoading': isLoading.value,
      'remainingSeconds': remainingSeconds.value,
      'isCodeExpired': isCodeExpired.value,
      'attempts': _otpAttempts,
      'maxAttempts': MAX_RETRIES,
      'canResend': _canResendOTP(),
      'errorMessage': errorMessage.value,
    };
  }
}
