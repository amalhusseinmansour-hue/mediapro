import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'otp_service.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

// Temporary auth service with Firestore integration
class AuthService {
  final OTPService _otpService = OTPService();
  final _uuid = const Uuid();

  // Try to get Firestore service (may be null if Firebase not configured)
  FirestoreService? get _firestoreService {
    try {
      return Get.find<FirestoreService>();
    } catch (e) {
      print('⚠️ Firestore service not available: $e');
      return null;
    }
  }

  // Sign in with email/password
  Future<Map<String, dynamic>?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    // Simulate login delay
    await Future.delayed(const Duration(seconds: 1));

    // Get existing user data from local storage
    final localUser = await _otpService.getLocalUserData();

    if (localUser != null) {
      final userId = localUser['id'] ?? _uuid.v4();

      // Update login status in Firestore
      if (_firestoreService != null) {
        try {
          await _firestoreService!.updateUserLastLogin(userId);
          print('✅ تم تحديث آخر تسجيل دخول في Firestore');
        } catch (e) {
          print('⚠️ لم يتم التحديث في Firestore: $e');
        }
      }

      return localUser;
    }

    // Create new mock user if no local data
    final user = {
      'id': _uuid.v4(),
      'name': 'Test User',
      'email': email,
      'subscriptionType': 'individual',
    };

    // Save user data locally
    await _otpService.saveUserLocally(user);

    // Save to Firestore if available
    await _saveUserToFirestore(user);

    return user;
  }

  // Sign up with email/password
  Future<Map<String, dynamic>?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String subscriptionType,
  }) async {
    // Simulate signup delay
    await Future.delayed(const Duration(seconds: 1));

    // Create new user with unique ID
    final userId = _uuid.v4();
    final user = {
      'id': userId,
      'name': name,
      'email': email,
      'subscriptionType': subscriptionType,
      'createdAt': DateTime.now().toIso8601String(),
      'isLoggedIn': true,
    };

    // Save user data locally
    await _otpService.saveUserLocally(user);

    // Mark as first login
    await _otpService.setFirstLoginCompleted();

    // Save to Firestore if available
    await _saveUserToFirestore(user);

    return user;
  }

  // Save user to Firestore
  Future<void> _saveUserToFirestore(Map<String, dynamic> userData) async {
    if (_firestoreService == null) {
      print('⚠️ Firestore غير متاح - البيانات محفوظة محلياً فقط');
      return;
    }

    try {
      // Convert map to UserModel
      final userModel = UserModel(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'] ?? '',
        phoneNumber: '', // Email-based auth doesn't have phone
        subscriptionType: userData['subscriptionType'],
        subscriptionStartDate: DateTime.now(),
        subscriptionTier: userData['subscriptionType'] == 'individual'
            ? 'individual'
            : 'team',
        isLoggedIn: userData['isLoggedIn'] ?? true,
        isPhoneVerified: false,
      );

      // Save to Firestore
      final success = await _firestoreService!.createOrUpdateUser(userModel);

      if (success) {
        print('✅ تم حفظ بيانات المستخدم في Firestore بنجاح');
        print('📊 User ID: ${userModel.id}');
        print('📧 Email: ${userModel.email}');
        print('💼 Subscription: ${userModel.subscriptionType}');
      }
    } catch (e) {
      print('❌ خطأ في حفظ البيانات في Firestore: $e');
    }
  }

  // Sign in with OTP (for returning users)
  Future<String> signInWithOTP(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if user has local data
    final hasData = await _otpService.hasLocalUserData();
    if (!hasData) {
      throw Exception('لم يتم العثور على بيانات المستخدم. يرجى تسجيل الدخول أولاً.');
    }

    // Send OTP
    final result = await _otpService.sendOTP(email);

    // Return OTP code if test mode, otherwise return success message
    if (result['success'] == true) {
      if (result['isTestMode'] == true) {
        return result['otp'] ?? '12345678';
      }
      return 'تم إرسال رمز التحقق';
    } else {
      throw Exception(result['error'] ?? 'فشل إرسال رمز التحقق');
    }
  }

  // Get current user from local storage
  Future<Map<String, String>?> getCurrentUser() async {
    return await _otpService.getLocalUserData();
  }

  // Check if user is first time login
  Future<bool> isFirstLogin() async {
    return await _otpService.isFirstLogin();
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _otpService.clearUserData();
    await _otpService.clearOTP();
  }
}

