import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'laravel_api_service.dart';
import 'firestore_service.dart';
import 'api_service.dart';

class PhoneAuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userBoxName = 'userBox';
  static const String _currentUserKey = 'currentUser';

  // 🔧 وضع التجربة - استخدام OTP ثابت للتطوير
  static const bool _testMode = false;
  static const String _testOTP = '123456';
  String? _testPhoneNumber; // تخزين رقم الهاتف لوضع التجربة

  // Get AuthService to reload user
  AuthService? get _authService {
    try {
      return Get.find<AuthService>();
    } catch (e) {
      return null;
    }
  }

  // Get Laravel API Service
  LaravelApiService? get _laravelApiService {
    try {
      return Get.find<LaravelApiService>();
    } catch (e) {
      print('⚠️ LaravelApiService not available: $e');
      return null;
    }
  }

  // TODO: SocialAccountsService integration reserved for future account linking
  /*
  // Get SocialAccountsService
  SocialAccountsService? get _socialAccountsService {
    try {
      return Get.find<SocialAccountsService>();
    } catch (e) {
      print('⚠️ SocialAccountsService not available: $e');
      return null;
    }
  }
  */

  // Get FirestoreService
  FirestoreService? get _firestoreService {
    try {
      return Get.find<FirestoreService>();
    } catch (e) {
      print('⚠️ FirestoreService not available: $e');
      return null;
    }
  }

  // Observable variables
  final RxString verificationId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool codeSent = false.obs;
  final RxInt resendToken = 0.obs;

  // Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      isLoading.value = true;

      // Make sure phone number is in international format
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+$phoneNumber';
      }

      // 🔧 Test mode: Skip Firebase and simulate OTP sent
      if (_testMode) {
        _testPhoneNumber = phoneNumber;
        print('🧪 Test mode: Stored phone number: $_testPhoneNumber');
        print('🧪 Test mode: Use OTP code "123456" to verify');

        // Simulate successful OTP sent
        codeSent.value = true;
        isLoading.value = false;

        Get.snackbar(
          'وضع الاختبار',
          'استخدم الرمز 123456 للتحقق',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.2),
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 5),
        );

        return true;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // When verification is completed automatically (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _auth.signInWithCredential(credential);

          // Save user to Hive
          if (userCredential.user != null) {
            await _saveUserToHive(userCredential.user!);
          }

          Get.snackbar(
            'تم التحقق',
            'تم التحقق من رقم الهاتف تلقائياً',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.2),
            colorText: Get.theme.colorScheme.onPrimary,
          );
        },

        // When verification fails
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;

          String errorMessage = 'حدث خطأ في التحقق';

          if (e.code == 'invalid-phone-number') {
            errorMessage = 'رقم الهاتف غير صحيح';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'تم إرسال عدد كبير من الطلبات، يرجى المحاولة لاحقاً';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'تم تجاوز الحد المسموح من الرسائل';
          }

          Get.snackbar(
            'خطأ',
            errorMessage,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.2),
            colorText: Get.theme.colorScheme.onError,
            duration: const Duration(seconds: 4),
          );
        },

        // When code is sent successfully
        codeSent: (String verificationIdValue, int? resendTokenValue) {
          verificationId.value = verificationIdValue;
          resendToken.value = resendTokenValue ?? 0;
          codeSent.value = true;
          isLoading.value = false;

          Get.snackbar(
            'تم الإرسال',
            'تم إرسال رمز التحقق إلى رقم الهاتف',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.2),
            colorText: Get.theme.colorScheme.onPrimary,
          );
        },

        // When code sending times out
        codeAutoRetrievalTimeout: (String verificationIdValue) {
          verificationId.value = verificationIdValue;
          isLoading.value = false;
        },
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.2),
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  // Get user box
  Future<Box<UserModel>> get _userBox async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      return await Hive.openBox<UserModel>(_userBoxName);
    }
    return Hive.box<UserModel>(_userBoxName);
  }

  // Observable variables for user data
  final RxString userEmail = ''.obs;
  final RxString userName = ''.obs;

  // Save user to Hive after successful login
  Future<void> _saveUserToHive(User firebaseUser) async {
    try {
      // Use test phone number if in test mode and Firebase user has no phone
      String? phoneNumber = firebaseUser.phoneNumber;
      if (_testMode && (phoneNumber?.isEmpty ?? true) && _testPhoneNumber != null) {
        phoneNumber = _testPhoneNumber;
        print('🧪 Test mode: Using stored phone number: $phoneNumber');
      }

      print('📱 _saveUserToHive called for user: $phoneNumber');
      final box = await _userBox;
      print('✅ Hive box opened successfully');

      // Check if user already exists
      UserModel? existingUser = box.get(_currentUserKey);
      print('🔍 Existing user: ${existingUser?.phoneNumber ?? "None"}');

      // Get email from observable or generate from phone
      String email = userEmail.value.isNotEmpty
          ? userEmail.value
          : '${phoneNumber?.replaceAll('+', '').replaceAll(' ', '')}@socialmedia.app';

      // Get name from observable or use default
      String name = userName.value.isNotEmpty
          ? userName.value
          : firebaseUser.displayName ?? 'مستخدم';

      UserModel user;

      // Update existing user login status or create new user
      if (existingUser != null) {
        print('🔄 Updating existing user...');
        user = existingUser.copyWith(
          isLoggedIn: true,
          isPhoneVerified: true,
          phoneNumber: phoneNumber ?? existingUser.phoneNumber,
          name: userName.value.isNotEmpty ? userName.value : existingUser.name,
          email: userEmail.value.isNotEmpty
              ? userEmail.value
              : existingUser.email,
          lastLogin: DateTime.now(),
        );
      } else {
        print('🆕 Creating new user...');
        user = UserModel(
          id: firebaseUser.uid,
          phoneNumber: phoneNumber ?? '',
          name: name,
          email: email,
          isLoggedIn: true,
          isPhoneVerified: true,
          subscriptionType: 'individual',
          subscriptionStartDate: DateTime.now(),
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
      }
      await box.put(_currentUserKey, user);
      print(
        '✅ User login status updated in Hive: ${user.phoneNumber} (Name: ${user.name}, Email: ${user.email})',
      );

      // حفظ البيانات في Laravel API (silent - no user notifications)
      if (_laravelApiService != null) {
        final success = await _laravelApiService!.registerUser(user);
        if (success) {
          // تحديث وقت آخر تسجيل دخول
          await _laravelApiService!.updateUserLastLogin(user.id);

          // تمرير Auth Token للـ ApiService لاستخدامه في جميع API Requests
          final token = _laravelApiService!.authToken.value;
          if (token.isNotEmpty) {
            try {
              final apiService = Get.find<ApiService>();
              apiService.setAuthToken(token);
              print(
                '✅ Auth token set in ApiService: ${token.substring(0, 20)}...',
              );
            } catch (e) {
              print('⚠️ ApiService not found, token not set: $e');
            }
          }
        }
        // No error messages shown to user - data is saved locally in Hive
      }

      // حفظ البيانات في Firebase Firestore (silent - no user notifications)
      if (_firestoreService != null) {
        final firestoreSuccess = await _firestoreService!.createOrUpdateUser(
          user,
        );
        if (firestoreSuccess) {
          print('✅ User data saved to Firestore');
        } else {
          print('ℹ️ User data saved locally only (Firestore not available)');
        }
        // No error messages shown to user - data is saved locally in Hive
      }

      // Reload user in AuthService
      print('🔄 Reloading AuthService...');
      await _authService?.reloadUser();
      print('✅ AuthService reloaded with updated user data');

      // ملاحظة: تم إزالة إضافة الحسابات التجريبية
      // المستخدم سيقوم بربط الحسابات الحقيقية من شاشة الإعدادات
    } catch (e) {
      print('❌ Error saving user to Hive: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // 🔧 حفظ مستخدم تجريبي في Hive (بدون Firebase)
  Future<void> _saveTestUserToHive() async {
    try {
      print('📱 _saveTestUserToHive called for test user');
      final box = await _userBox;
      print('✅ Hive box opened successfully');

      // إنشاء معرف فريد للمستخدم التجريبي
      final testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';

      // إنشاء البريد الإلكتروني من رقم الهاتف
      String email = _testPhoneNumber != null
          ? '${_testPhoneNumber!.replaceAll('+', '').replaceAll(' ', '')}@socialmedia.app'
          : 'testuser@socialmedia.app';

      UserModel user = UserModel(
        id: testUserId,
        phoneNumber: _testPhoneNumber ?? '+966500000000',
        name: 'مستخدم تجريبي',
        email: email,
        isLoggedIn: true,
        isPhoneVerified: true,
        subscriptionType: 'individual',
        subscriptionStartDate: DateTime.now(),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await box.put(_currentUserKey, user);
      print('✅ Test user saved to Hive: ${user.phoneNumber}');

      // Reload user in AuthService
      print('🔄 Reloading AuthService...');
      await _authService?.reloadUser();
      print('✅ AuthService reloaded with test user data');
    } catch (e) {
      print('❌ Error saving test user to Hive: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Verify OTP code
  Future<UserCredential?> verifyOTP(String smsCode) async {
    try {
      print('📲 verifyOTP called with code: $smsCode');
      isLoading.value = true;

      // 🔧 Test Mode: Accept fixed OTP
      if (_testMode && smsCode == _testOTP) {
        print('🧪 Test mode activated with OTP: $smsCode');
        print('📱 Test phone number: $_testPhoneNumber');

        // حفظ المستخدم مباشرة في Hive بدون Firebase
        await _saveTestUserToHive();
        print('✅ Test user saved directly to Hive');

        isLoading.value = false;

        Get.snackbar(
          'نجح التحقق',
          'تم التحقق باستخدام رمز الاختبار (123456)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.2),
          colorText: Get.theme.colorScheme.onPrimary,
        );

        print('✅ Test mode verification completed');

        // إرجاع null لأننا لا نستخدم Firebase في وضع الاختبار
        return null;
      }

      if (verificationId.value.isEmpty) {
        print('❌ Verification ID is empty!');
        throw Exception('لم يتم إرسال رمز التحقق بعد');
      }

      print('✅ Verification ID: ${verificationId.value}');

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );
      print('✅ Credential created');

      // Sign in with credential
      print('🔐 Signing in with credential...');
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      print('✅ Sign in successful! User: ${userCredential.user?.phoneNumber}');

      // Save user to Hive
      if (userCredential.user != null) {
        print('💾 Calling _saveUserToHive...');
        await _saveUserToHive(userCredential.user!);
        print('✅ _saveUserToHive completed');
      } else {
        print('⚠️ userCredential.user is null!');
      }

      isLoading.value = false;

      Get.snackbar(
        'نجح التحقق',
        'تم التحقق من رقم الهاتف بنجاح',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.2),
        colorText: Get.theme.colorScheme.onPrimary,
      );

      print('✅ verifyOTP completed successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String errorMessage = 'رمز التحقق غير صحيح';

      if (e.code == 'invalid-verification-code') {
        errorMessage = 'رمز التحقق غير صحيح';
      } else if (e.code == 'session-expired') {
        errorMessage = 'انتهت صلاحية رمز التحقق، يرجى المحاولة مرة أخرى';
      } else if (e.code == 'invalid-verification-id') {
        errorMessage = 'معرف التحقق غير صحيح';
      }

      Get.snackbar(
        'خطأ في التحقق',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.2),
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );

      return null;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.2),
        colorText: Get.theme.colorScheme.onError,
      );
      return null;
    }
  }

  // Resend OTP
  Future<bool> resendOTP(String phoneNumber) async {
    codeSent.value = false;
    return await sendOTP(phoneNumber);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Update user login status in Hive
      final box = await _userBox;
      UserModel? user = box.get(_currentUserKey);
      if (user != null) {
        final updatedUser = user.copyWith(isLoggedIn: false);
        await box.put(_currentUserKey, updatedUser);
        print('✅ User logged out from Hive');
      }

      await _auth.signOut();
      verificationId.value = '';
      codeSent.value = false;
      resendToken.value = 0;
    } catch (e) {
      print('❌ Error during sign out: $e');
    }
  }

  // Get current user
  User? get currentFirebaseUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}
