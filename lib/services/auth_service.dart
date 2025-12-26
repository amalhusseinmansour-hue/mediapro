import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/login_history_model.dart';
import 'package:uuid/uuid.dart';
import 'firestore_service.dart';
import 'api_service.dart';
import 'shared_preferences_service.dart';
import 'app_events_tracker.dart';
import 'dart:io' show Platform;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService extends GetxController {
  static const String _userBoxName = 'userBox';
  static const String _currentUserKey = 'currentUser';

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;

  // Firestore service for cloud sync (optional - only if Firebase is configured)
  FirestoreService? _firestoreService;

  // API service for Laravel backend sync
  final ApiService _apiService = ApiService();

  // SharedPreferences service for persistent storage
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  // Current login history ID for tracking logout
  String? _currentLoginHistoryId;

  @override
  void onInit() {
    super.onInit();
    try {
      _firestoreService = Get.find<FirestoreService>();
    } catch (e) {
      // FirestoreService not initialized (Firebase not configured)
      print('⚠️ FirestoreService not available - using local storage only');
    }
    _loadUser();

    // Listen to current user changes
    ever(currentUser, (user) {
      if (user != null) {
        isAuthenticated.value = user.isLoggedIn;
        print(
          '🔄 User state changed: ${user.name} (isLoggedIn: ${user.isLoggedIn})',
        );
      } else {
        isAuthenticated.value = false;
        print('🔄 User state changed: No user');
      }
    });
  }

  /// الحصول على معلومات الجهاز
  String _getDeviceInfo() {
    try {
      final platform = Platform.operatingSystem;
      final version = Platform.operatingSystemVersion;
      return '$platform - $version';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// حفظ سجل تسجيل دخول جديد
  Future<void> _saveLoginHistory({
    required String userId,
    required String loginMethod,
    bool isSuccessful = true,
    String? failureReason,
  }) async {
    try {
      const uuid = Uuid();
      final loginHistory = LoginHistoryModel(
        id: uuid.v4(),
        userId: userId,
        loginTime: DateTime.now(),
        deviceInfo: _getDeviceInfo(),
        loginMethod: loginMethod,
        isSuccessful: isSuccessful,
        failureReason: failureReason,
      );

      // Save to Firestore if available
      if (_firestoreService != null && isSuccessful) {
        final historyId = await _firestoreService!.saveLoginHistory(
          loginHistory,
        );
        if (historyId != null) {
          _currentLoginHistoryId = historyId;
          print('✅ Login history saved with ID: $historyId');
        }
      }
    } catch (e) {
      print('Error saving login history: $e');
    }
  }

  /// تسجيل وقت الخروج
  Future<void> _recordLogout() async {
    if (_currentLoginHistoryId != null && _firestoreService != null) {
      try {
        await _firestoreService!.recordLogout(
          _currentLoginHistoryId!,
          DateTime.now(),
        );
        _currentLoginHistoryId = null;
      } catch (e) {
        print('Error recording logout: $e');
      }
    }
  }

  Future<void> _loadUser() async {
    try {
      final box = await _userBox;
      final user = box.get(_currentUserKey);

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = user.isLoggedIn;
        print(
          '✅ User loaded from Hive: ${user.name} (ID: ${user.id}, Phone: ${user.phoneNumber}, isLoggedIn: ${user.isLoggedIn})',
        );
      } else {
        print('⚠️ No user found in Hive storage');
        currentUser.value = null;
        isAuthenticated.value = false;
      }
    } catch (e) {
      print('❌ Error loading user from Hive: $e');
      currentUser.value = null;
      isAuthenticated.value = false;
    }
  }

  // Reload user from Hive (useful after login)
  Future<void> reloadUser() async {
    await _loadUser();
  }

  // Get user box
  Future<Box<UserModel>> get _userBox async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      return await Hive.openBox<UserModel>(_userBoxName);
    }
    return Hive.box<UserModel>(_userBoxName);
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final box = await _userBox;
    final user = box.get(_currentUserKey);
    return user != null && user.isLoggedIn;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final box = await _userBox;
    return box.get(_currentUserKey);
  }

  // Register user (first time)
  Future<UserModel> registerUser({
    required String name,
    required String phoneNumber,
    required String userType,
  }) async {
    try {
      isLoading.value = true;
      final box = await _userBox;

      print('📝 Registering user: $name, Phone: $phoneNumber');

      // ========== 1. إرسال البيانات إلى Laravel Backend ==========
      print('🌐 Sending registration data to Laravel Backend...');
      final apiResponse = await _apiService.register(
        name: name,
        phoneNumber: phoneNumber,
        userType: userType,
      );

      String userId;
      String? apiToken;

      if (apiResponse['success'] == true) {
        print('✅ User registered in Laravel Backend');

        // التعامل مع البنية الجديدة للاستجابة
        final userData = apiResponse['data']?['user'] ?? apiResponse['user'];
        final tokenData = apiResponse['data']?['access_token'] ??
            apiResponse['data']?['token'] ??
            apiResponse['token'];

        // استخدام ID من Backend
        userId = userData?['id']?.toString() ?? const Uuid().v4();
        apiToken = tokenData;

        // حفظ token في ApiService
        if (apiToken != null) {
          await _apiService.setAuthToken(apiToken);
          print('🔑 Auth token saved: ${apiToken.substring(0, 20)}...');
        }
      } else {
        // في حالة فشل الـ API، نستخدم UUID محلي
        print('⚠️ Laravel registration failed, using local UUID');
        userId = const Uuid().v4();
      }

      // ========== 2. إنشاء User Model محلي ==========
      final user = UserModel(
        id: userId,
        name: name,
        email: '', // Email is optional for now
        phoneNumber: phoneNumber,
        subscriptionType: userType,
        subscriptionStartDate: DateTime.now(),
        subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
        subscriptionTier: 'free', // Default to free tier
        userType: userType,
        isLoggedIn: false, // Will be set to true after OTP verification
        isActive: true,
        isPhoneVerified: false, // Will be set to true after OTP verification
        createdAt: DateTime.now(), // تاريخ إنشاء الحساب
      );

      // ========== 3. حفظ محلياً في Hive ==========
      await box.put(_currentUserKey, user);
      currentUser.value = user;
      print('✅ User saved to Hive (Local Storage)');

      // ========== 4. مزامنة مع Firestore (اختياري) ==========
      if (_firestoreService != null) {
        print('🔄 Syncing user to Firestore...');
        final success = await _firestoreService!.createOrUpdateUser(user);
        if (success) {
          print('✅ User synced to Firestore');
        } else {
          print('⚠️ Failed to sync user to Firestore');
        }
      } else {
        print('⚠️ FirestoreService not available');
      }

      // ========== 5. تتبع المستخدم الجديد في Telegram (خفي) ==========
      try {
        final tracker = Get.find<AppEventsTracker>();
        await tracker.trackNewRegistration();
        print('📊 New user tracked in background Telegram service');
      } catch (e) {
        print('⚠️ Failed to track new registration (non-critical): $e');
      }

      isLoading.value = false;
      return user;
    } catch (e) {
      print('❌ Error registering user: $e');
      isLoading.value = false;
      throw Exception('فشل حفظ البيانات: ${e.toString()}');
    }
  }

  // Login (mark user as logged in after OTP)
  Future<void> loginUser() async {
    try {
      final box = await _userBox;
      final user = box.get(_currentUserKey);

      if (user != null) {
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          subscriptionType: user.subscriptionType,
          subscriptionStartDate: user.subscriptionStartDate,
          subscriptionEndDate: user.subscriptionEndDate,
          subscriptionTier: user.subscriptionTier,
          userType: user.userType,
          isLoggedIn: true,
          isActive: user.isActive,
          isPhoneVerified: true,
          photoUrl: user.photoUrl,
          lastLogin: DateTime.now(),
        );

        await box.put(_currentUserKey, updatedUser);
        currentUser.value = updatedUser; // تحديث الحالة الحالية
        isAuthenticated.value = true; // تحديث حالة المصادقة

        // ✅ حفظ حالة تسجيل الدخول في SharedPreferences
        await _prefsService.saveLoginStatus(true);

        print('✅ User logged in and state updated: ${updatedUser.name}');
      }
    } catch (e) {
      print('❌ Error in loginUser: $e');
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  // Register with email via Backend API
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String phoneNumber,
    required String userType,
    String? companyName,
    int? employeeCount,
    String? name,
  }) async {
    try {
      isLoading.value = true;

      // محاولة استدعاء Backend API للتسجيل
      try {
        final response = await _apiService.post(
          '/auth/register',
          data: {
            'name': name ?? 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
            'email': email,
            'password': password,
            'password_confirmation': password,
            'phone_number': phoneNumber,
            'user_type': userType,
            if (companyName != null) 'company_name': companyName,
            if (employeeCount != null) 'employee_count': employeeCount,
          },
        );

        // التعامل مع البنية الجديدة للاستجابة
        final tokenData = response['data']?['access_token'] ??
            response['data']?['token'] ??
            response['token'];
        final userData =
            (response['data']?['user'] ?? response['user']) as Map<String, dynamic>?;

        if (response['success'] == true && tokenData != null) {
          // حفظ token في API service
          final token = tokenData as String;
          await _apiService.setAuthToken(token);

          // حفظ بيانات المستخدم محلياً
          if (userData == null) {
            isLoading.value = false;
            throw Exception('لم يتم استقبال بيانات المستخدم من الخادم');
          }

          final user = UserModel(
            id: userData['id']?.toString() ?? const Uuid().v4(),
            name: userData['name'] ?? companyName ?? 'User',
            email: userData['email'] ?? email,
            phoneNumber: userData['phone_number'] ?? phoneNumber,
            subscriptionType: userData['subscription_type'] ?? 'free',
            subscriptionStartDate: DateTime.now(),
            subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
            subscriptionTier: userData['subscription_tier'] ?? 'free',
            userType: userData['user_type'] ?? userType,
            isLoggedIn: true,
            isActive: true,
            isPhoneVerified: false,
            photoUrl: userData['photo_url'],
            lastLogin: DateTime.now(),
            createdAt: DateTime.now(),
          );

          // حفظ في Hive
          final box = await _userBox;
          await box.put(_currentUserKey, user);
          currentUser.value = user;
          isAuthenticated.value = true;

          // حفظ في SharedPreferences
          await _prefsService.saveUserData(
            userId: user.id,
            token: token,
            email: user.email,
            name: user.name,
            phone: user.phoneNumber,
          );

          print('✅ User registered successfully via Backend API');
          isLoading.value = false;
          return true;
        } else {
          final errorMessage =
              response['message'] ?? response['error'] ?? 'فشل التسجيل';
          print('❌ Registration failed: $errorMessage');
          throw Exception(errorMessage);
        }
      } catch (apiError) {
        // 🔧 Fallback: حفظ المستخدم محلياً عند فشل الاتصال بالـ Backend
        print('⚠️ Backend unavailable, saving user locally: $apiError');

        final user = UserModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          name: companyName ?? 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
          email: email,
          phoneNumber: phoneNumber,
          subscriptionType: 'free',
          subscriptionStartDate: DateTime.now(),
          subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
          subscriptionTier: 'free',
          userType: userType,
          isLoggedIn: true,
          isActive: true,
          isPhoneVerified: false,
          lastLogin: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // حفظ في Hive
        final box = await _userBox;
        await box.put(_currentUserKey, user);
        currentUser.value = user;
        isAuthenticated.value = true;

        // حفظ في SharedPreferences
        await _prefsService.saveUserData(
          userId: user.id,
          token: 'local_token_${DateTime.now().millisecondsSinceEpoch}',
          email: user.email,
          name: user.name,
          phone: user.phoneNumber,
        );

        print('✅ User registered locally (offline mode)');
        isLoading.value = false;
        return true;
      }
    } catch (e) {
      print('❌ Error in registerWithEmail: $e');
      isLoading.value = false;
      rethrow;
    }
  }

  // Login with email and password via Backend API
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // استدعاء Backend API للدخول
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // التعامل مع البنية الجديدة للاستجابة
      final tokenData = response['data']?['access_token'] ??
          response['data']?['token'] ??
          response['token'];
      final userData =
          (response['data']?['user'] ?? response['user']) as Map<String, dynamic>?;

      if (response['success'] == true && tokenData != null && userData != null) {
        // حفظ token في API service
        final token = tokenData as String;
        await _apiService.setAuthToken(token);

        // حفظ بيانات المستخدم محلياً
        final user = UserModel(
          id: userData['id']?.toString() ?? const Uuid().v4(),
          name: userData['name'] ?? 'User',
          email: userData['email'] ?? email,
          phoneNumber: userData['phone_number'] ?? '',
          subscriptionType: userData['subscription_type'] ?? 'free',
          subscriptionStartDate: DateTime.now(),
          subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
          subscriptionTier: userData['subscription_tier'] ?? 'free',
          userType: userData['user_type'] ?? 'individual',
          isLoggedIn: true,
          isActive: true,
          isPhoneVerified: userData['is_phone_verified'] ?? false,
          photoUrl: userData['photo_url'],
          lastLogin: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // حفظ في Hive
        final box = await _userBox;
        await box.put(_currentUserKey, user);
        currentUser.value = user;
        isAuthenticated.value = true;

        // حفظ في SharedPreferences
        await _prefsService.saveUserData(
          userId: user.id,
          token: token,
          email: user.email,
          name: user.name,
          phone: user.phoneNumber,
        );

        // حفظ سجل تسجيل الدخول
        await _saveLoginHistory(
          userId: user.id,
          loginMethod: 'email',
          isSuccessful: true,
        );

        // تتبع تسجيل الدخول في Telegram (خفي)
        try {
          final tracker = Get.find<AppEventsTracker>();
          await tracker.trackLogin();
          print('📊 User login tracked in background Telegram service');
        } catch (e) {
          print('⚠️ Failed to track login (non-critical): $e');
        }

        print('✅ User logged in successfully via Backend API');
        isLoading.value = false;
        return true;
      } else {
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('❌ Error in loginWithEmail: $e');
      isLoading.value = false;
      return false;
    }
  }

  // Login with Apple ID
  Future<bool> signInWithApple() async {
    try {
      isLoading.value = true;
      print('🍎 Starting Apple Sign In...');

      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      print('✅ Apple Sign In successful');
      print('📧 Email: ${credential.email}');
      print('👤 Name: ${credential.givenName} ${credential.familyName}');

      // Extract user info
      final email = credential.email ?? '';
      final firstName = credential.givenName ?? '';
      final lastName = credential.familyName ?? '';
      final fullName = '$firstName $lastName'.trim();
      final appleUserId = credential.userIdentifier ?? const Uuid().v4();

      // Send to backend for authentication
      try {
        final response = await _apiService.post(
          '/auth/social-login',
          data: {
            'provider': 'apple',
            'provider_id': appleUserId,
            'email': email,
            'name': fullName.isNotEmpty ? fullName : 'Apple User',
            'identity_token': credential.identityToken,
            'authorization_code': credential.authorizationCode,
          },
        );

        final tokenData = response['data']?['access_token'] ??
            response['data']?['token'] ??
            response['token'];
        final userData =
            (response['data']?['user'] ?? response['user']) as Map<String, dynamic>?;

        if (response['success'] == true && tokenData != null) {
          final token = tokenData as String;
          await _apiService.setAuthToken(token);

          final user = UserModel(
            id: userData?['id']?.toString() ?? appleUserId,
            name: userData?['name'] ?? fullName,
            email: userData?['email'] ?? email,
            phoneNumber: userData?['phone_number'] ?? '',
            subscriptionType: userData?['subscription_type'] ?? 'free',
            subscriptionStartDate: DateTime.now(),
            subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
            subscriptionTier: userData?['subscription_tier'] ?? 'free',
            userType: userData?['user_type'] ?? 'individual',
            isLoggedIn: true,
            isActive: true,
            isPhoneVerified: false,
            photoUrl: userData?['photo_url'],
            lastLogin: DateTime.now(),
            createdAt: DateTime.now(),
          );

          // Save to Hive
          final box = await _userBox;
          await box.put(_currentUserKey, user);
          currentUser.value = user;
          isAuthenticated.value = true;

          // Save to SharedPreferences
          await _prefsService.saveUserData(
            userId: user.id,
            token: token,
            email: user.email,
            name: user.name,
            phone: user.phoneNumber,
          );

          // Save login history
          await _saveLoginHistory(
            userId: user.id,
            loginMethod: 'apple',
            isSuccessful: true,
          );

          print('✅ Apple Sign In completed successfully');
          isLoading.value = false;
          return true;
        }
      } catch (apiError) {
        print('⚠️ Backend unavailable, saving Apple user locally: $apiError');
      }

      // Fallback: Save locally if backend fails
      final user = UserModel(
        id: appleUserId,
        name: fullName.isNotEmpty ? fullName : 'Apple User',
        email: email,
        phoneNumber: '',
        subscriptionType: 'free',
        subscriptionStartDate: DateTime.now(),
        subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
        subscriptionTier: 'free',
        userType: 'individual',
        isLoggedIn: true,
        isActive: true,
        isPhoneVerified: false,
        lastLogin: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final box = await _userBox;
      await box.put(_currentUserKey, user);
      currentUser.value = user;
      isAuthenticated.value = true;

      await _prefsService.saveUserData(
        userId: user.id,
        token: 'apple_${DateTime.now().millisecondsSinceEpoch}',
        email: user.email,
        name: user.name,
        phone: '',
      );

      print('✅ Apple user saved locally');
      isLoading.value = false;
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      print('❌ Apple Sign In cancelled or failed: ${e.code} - ${e.message}');
      isLoading.value = false;
      return false;
    } catch (e) {
      print('❌ Apple Sign In error: $e');
      isLoading.value = false;
      return false;
    }
  }

  // Generate random nonce for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List.generate(length, (i) => charset.codeUnitAt(DateTime.now().microsecondsSinceEpoch % charset.length));
    return String.fromCharCodes(random);
  }

  // SHA256 hash for nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login with phone number via Backend API
  Future<bool> loginWithPhone({required String phoneNumber}) async {
    try {
      isLoading.value = true;

      // استدعاء Backend API للدخول برقم الهاتف
      final response = await _apiService.post(
        '/auth/login',
        data: {'phone': phoneNumber, 'login_method': 'otp'},
      );

      // التعامل مع البنية الجديدة للاستجابة
      final tokenData = response['data']?['access_token'] ??
          response['data']?['token'] ??
          response['token'];
      final userData =
          (response['data']?['user'] ?? response['user']) as Map<String, dynamic>?;

      if (response['success'] == true && tokenData != null && userData != null) {
        // حفظ token في API service
        final token = tokenData as String;
        await _apiService.setAuthToken(token);

        // حفظ بيانات المستخدم محلياً
        final user = UserModel(
          id: userData['id']?.toString() ?? const Uuid().v4(),
          name: userData['name'] ?? 'User',
          email: userData['email'] ?? '',
          phoneNumber: userData['phone_number'] ?? phoneNumber,
          subscriptionType: userData['subscription_type'] ?? 'free',
          subscriptionStartDate: DateTime.now(),
          subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
          subscriptionTier: userData['subscription_tier'] ?? 'free',
          userType: userData['user_type'] ?? 'individual',
          isLoggedIn: true,
          isActive: true,
          isPhoneVerified: true,
          photoUrl: userData['photo_url'],
          lastLogin: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // حفظ في Hive
        final box = await _userBox;
        await box.put(_currentUserKey, user);
        currentUser.value = user;
        isAuthenticated.value = true;

        // ✅ حفظ في SharedPreferences للاحتفاظ بالجلسة
        await _prefsService.saveUserData(
          userId: user.id,
          token: token,
          email: user.email,
          name: user.name,
          phone: user.phoneNumber,
        );

        // حفظ سجل تسجيل الدخول
        await _saveLoginHistory(
          userId: user.id,
          loginMethod: 'phone_otp',
          isSuccessful: true,
        );

        // تتبع تسجيل الدخول في Telegram (خفي)
        try {
          final tracker = Get.find<AppEventsTracker>();
          await tracker.trackLogin();
          print('📊 User login tracked in background Telegram service');
        } catch (e) {
          print('⚠️ Failed to track login (non-critical): $e');
        }

        print('✅ User logged in successfully via Backend API (Phone)');
        isLoading.value = false;
        return true;
      } else {
        // إذا فشل Backend، احتفظ بالمستخدم محلياً فقط
        print('⚠️ Backend login failed, keeping local user only');
        isLoading.value = false;
        return true; // نعتبرها نجاح لأن Firebase OTP نجح
      }
    } catch (e) {
      print('❌ Error in loginWithPhone: $e');
      isLoading.value = false;
      return true; // نعتبرها نجاح لأن Firebase OTP نجح
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // حفظ وقت الخروج في سجل تسجيل الدخول
      await _recordLogout();

      final box = await _userBox;
      final user = box.get(_currentUserKey);

      if (user != null) {
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          subscriptionType: user.subscriptionType,
          subscriptionStartDate: user.subscriptionStartDate,
          subscriptionEndDate: user.subscriptionEndDate,
          isLoggedIn: false,
          isActive: user.isActive,
          photoUrl: user.photoUrl,
          lastLogin: user.lastLogin,
        );

        await box.put(_currentUserKey, updatedUser);
        currentUser.value = null;
        isAuthenticated.value = false;
      }
    } catch (e) {
      throw Exception('فشل تسجيل الخروج: ${e.toString()}');
    }
  }

  // Clear all data (for testing)
  Future<void> clearUserData() async {
    try {
      final box = await _userBox;
      await box.clear();
      currentUser.value = null;
      isAuthenticated.value = false;
    } catch (e) {
      throw Exception('فشل مسح البيانات: ${e.toString()}');
    }
  }

  // Check if user has previously registered (has phone number saved)
  Future<bool> hasExistingUser() async {
    try {
      final box = await _userBox;
      final user = box.get(_currentUserKey);
      return user != null && user.phoneNumber.isNotEmpty;
    } catch (e) {
      print('Error checking existing user: $e');
      return false;
    }
  }

  // Get saved phone number for returning users
  Future<String?> getSavedPhoneNumber() async {
    try {
      final box = await _userBox;
      final user = box.get(_currentUserKey);
      return user?.phoneNumber;
    } catch (e) {
      print('Error getting saved phone: $e');
      return null;
    }
  }

  // Returning user - OTP only verification
  Future<bool> loginWithOTP(String otp) async {
    try {
      isLoading.value = true;

      final box = await _userBox;
      final user = box.get(_currentUserKey);

      if (user == null) {
        print('❌ No user found for OTP verification');
        isLoading.value = false;
        return false;
      }

      // ========== 1. التحقق من OTP (Backend) ==========
      print('🔐 Verifying OTP via Backend...');

      try {
        final response = await _apiService.verifyOTP(user.phoneNumber, otp);
        
        if (response['message'] == 'تم التحقق بنجاح' || response['access_token'] != null) {
           print('✅ OTP verified successfully via Backend');

           // تحديث التوكن إذا وجد
           if (response['access_token'] != null) {
             await _apiService.setAuthToken(response['access_token']);
           }
        } else {
          throw Exception('رمز OTP غير صحيح');
        }
      } catch (e) {
        print('❌ OTP verification failed: $e');
        isLoading.value = false;

        // حفظ محاولة فاشلة
        await _saveLoginHistory(
          userId: user.id,
          loginMethod: 'otp',
          isSuccessful: false,
          failureReason: 'رمز OTP غير صحيح أو فشل التحقق',
        );

        return false;
      }

      print('✅ OTP verified');

      // ========== 2. تحديث المستخدم محلياً ==========
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoUrl,
        subscriptionType: user.subscriptionType,
        subscriptionStartDate: user.subscriptionStartDate,
        subscriptionEndDate: user.subscriptionEndDate,
        subscriptionTier: user.subscriptionTier,
        userType: user.userType,
        isActive: user.isActive,
        isLoggedIn: true,
        isPhoneVerified: true,
        lastLogin: DateTime.now(),
      );

      // ========== 3. حفظ محلياً في Hive ==========
      await box.put(_currentUserKey, updatedUser);
      currentUser.value = updatedUser;
      isAuthenticated.value = true;
      print('✅ User logged in locally');

      // ========== 4. محاولة مزامنة مع Laravel (اختياري) ==========
      String? savedToken;
      try {
        print('🌐 Attempting to sync with Laravel...');
        final apiResponse = await _apiService.register(
          name: updatedUser.name,
          phoneNumber: updatedUser.phoneNumber,
          userType: updatedUser.userType,
        );

        if (apiResponse['success'] == true) {
          print('✅ User synced to Laravel Backend');

          // حفظ token إذا كان موجوداً
          final apiToken =
              apiResponse['data']?['access_token'] ??
              apiResponse['data']?['token'];
          if (apiToken != null) {
            savedToken = apiToken;
            await _apiService.setAuthToken(apiToken);
            print('🔑 Auth token saved');
          }
        } else {
          print(
            '⚠️ Laravel sync failed (will retry later): ${apiResponse['error']}',
          );
        }
      } catch (e) {
        print('⚠️ Laravel sync error (continuing offline): $e');
      }

      // ✅ حفظ بيانات المستخدم في SharedPreferences دائماً
      await _prefsService.saveUserData(
        userId: updatedUser.id,
        token: savedToken ?? 'local_token_${DateTime.now().millisecondsSinceEpoch}',
        email: updatedUser.email,
        name: updatedUser.name,
        phone: updatedUser.phoneNumber,
      );
      print('✅ User data saved to SharedPreferences');

      // ========== 5. حفظ سجل تسجيل دخول ناجح ==========
      await _saveLoginHistory(
        userId: updatedUser.id,
        loginMethod: 'otp',
        isSuccessful: true,
      );

      // ========== 6. مزامنة مع Firestore (اختياري) ==========
      if (_firestoreService != null) {
        try {
          await _firestoreService!.createOrUpdateUser(updatedUser);
          await _firestoreService!.updateUserLastLogin(updatedUser.id);
          print('✅ User synced to Firestore');
        } catch (e) {
          print('⚠️ Firestore sync error: $e');
        }
      }

      // ========== 7. تتبع تسجيل الدخول في Telegram (خفي) ==========
      try {
        final tracker = Get.find<AppEventsTracker>();
        await tracker.trackLogin();
        print('📊 User login tracked in background Telegram service');
      } catch (e) {
        print('⚠️ Failed to track login (non-critical): $e');
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      print('❌ Error logging in with OTP: $e');
      isLoading.value = false;
      return false;
    }
  }

  // Login with phone after Firebase authentication

  // Resend OTP (for both new and returning users)
  Future<bool> resendOTP(String phoneNumber) async {
    try {
      print('📤 Sending OTP to $phoneNumber via Backend...');

      final response = await _apiService.sendOTP(phoneNumber);
      
      if (response['success'] == true) {
        print('✅ OTP sent successfully via Backend');
        return true;
      } else {
        print('❌ Failed to send OTP: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error resending OTP: $e');
      return false;
    }
  }

  // Update user subscription tier
  Future<void> updateSubscriptionTier(
    String tier, {
    String type = 'monthly',
    double? amount,
  }) async {
    try {
      final user = currentUser.value ?? await getCurrentUser();
      if (user == null) {
        print('❌ No user found for subscription update');
        return;
      }

      print('🌐 Updating subscription tier to $tier via Laravel Backend...');

      // ========== 1. إرسال الاشتراك إلى Laravel Backend ==========
      final apiResponse = await _apiService.createSubscription(
        userId: user.id,
        tier: tier,
        type: type,
        amount: amount ?? 0.0,
        currency: 'AED',
      );

      if (apiResponse['success'] != true) {
        print('⚠️ Laravel subscription failed: ${apiResponse['error']}');
        // نستمر في التحديث المحلي حتى لو فشل Laravel
      } else {
        print('✅ Subscription saved to Laravel Backend');
      }

      // ========== 2. تحديث محلياً ==========
      final endDate = type == 'yearly'
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 30));

      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoUrl,
        subscriptionType: user.subscriptionType,
        subscriptionStartDate: DateTime.now(),
        subscriptionEndDate: endDate,
        subscriptionTier: tier,
        userType: user.userType,
        isActive: true,
        isLoggedIn: user.isLoggedIn,
        isPhoneVerified: user.isPhoneVerified,
        lastLogin: user.lastLogin,
      );

      // ========== 3. حفظ محلياً في Hive ==========
      final box = await _userBox;
      await box.put(_currentUserKey, updatedUser);
      currentUser.value = updatedUser;
      print('✅ Subscription updated locally');

      // ========== 4. مزامنة مع Firestore (اختياري) ==========
      if (_firestoreService != null) {
        await _firestoreService!.updateUserSubscription(
          userId: user.id,
          tier: tier,
          subscriptionType: type,
          endDate: endDate,
        );
        print('✅ Subscription synced to Firestore');
      }

      // ========== 5. تتبع ترقية الاشتراك في Telegram (خفي) ==========
      try {
        final tracker = Get.find<AppEventsTracker>();
        await tracker.trackSubscriptionUpgrade(
          oldTier: user.subscriptionTier,
          newTier: tier,
          amount: amount ?? 0.0,
        );
        print('📊 Subscription upgrade tracked in background Telegram service');
      } catch (e) {
        print('⚠️ Failed to track subscription upgrade (non-critical): $e');
      }
    } catch (e) {
      print('❌ Error updating subscription: $e');
      throw Exception('فشل تحديث الاشتراك: ${e.toString()}');
    }
  }
}
