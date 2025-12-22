import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing SharedPreferences data
class SharedPreferencesService {
  static final SharedPreferencesService _instance = SharedPreferencesService._internal();
  factory SharedPreferencesService() => _instance;
  SharedPreferencesService._internal();

  SharedPreferences? _prefs;

  // Keys
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ SharedPreferences initialized');
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ========== Auth Token ==========

  /// Save auth token
  Future<bool> saveAuthToken(String token) async {
    final prefs = await _preferences;
    final result = await prefs.setString(_authTokenKey, token);
    if (result) {
      print('✅ Auth token saved to SharedPreferences');
    }
    return result;
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    final prefs = await _preferences;
    return prefs.getString(_authTokenKey);
  }

  /// Clear auth token
  Future<bool> clearAuthToken() async {
    final prefs = await _preferences;
    return await prefs.remove(_authTokenKey);
  }

  // ========== User Data ==========

  /// Save user ID
  Future<bool> saveUserId(String userId) async {
    final prefs = await _preferences;
    return await prefs.setString(_userIdKey, userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(_userIdKey);
  }

  /// Save user email
  Future<bool> saveUserEmail(String email) async {
    final prefs = await _preferences;
    return await prefs.setString(_userEmailKey, email);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    final prefs = await _preferences;
    return prefs.getString(_userEmailKey);
  }

  /// Save user name
  Future<bool> saveUserName(String name) async {
    final prefs = await _preferences;
    return await prefs.setString(_userNameKey, name);
  }

  /// Get user name
  Future<String?> getUserName() async {
    final prefs = await _preferences;
    return prefs.getString(_userNameKey);
  }

  /// Save user phone
  Future<bool> saveUserPhone(String phone) async {
    final prefs = await _preferences;
    return await prefs.setString(_userPhoneKey, phone);
  }

  /// Get user phone
  Future<String?> getUserPhone() async {
    final prefs = await _preferences;
    return prefs.getString(_userPhoneKey);
  }

  /// Save login status
  Future<bool> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await _preferences;
    return await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// Get login status
  Future<bool> getLoginStatus() async {
    final prefs = await _preferences;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Save complete user data
  Future<bool> saveUserData({
    required String userId,
    required String token,
    String? email,
    String? name,
    String? phone,
  }) async {
    try {
      await saveUserId(userId);
      await saveAuthToken(token);
      if (email != null) await saveUserEmail(email);
      if (name != null) await saveUserName(name);
      if (phone != null) await saveUserPhone(phone);
      await saveLoginStatus(true);

      print('✅ Complete user data saved to SharedPreferences');
      print('   - User ID: $userId');
      print('   - Token: ${token.substring(0, 20)}...');
      print('   - Email: $email');
      print('   - Name: $name');
      print('   - Phone: $phone');

      return true;
    } catch (e) {
      print('❌ Error saving user data: $e');
      return false;
    }
  }

  /// Clear all user data
  Future<bool> clearUserData() async {
    try {
      await clearAuthToken();
      final prefs = await _preferences;
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_isLoggedInKey);

      print('✅ All user data cleared from SharedPreferences');
      return true;
    } catch (e) {
      print('❌ Error clearing user data: $e');
      return false;
    }
  }

  /// Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final token = await getAuthToken();
    final isLoggedIn = await getLoginStatus();
    return token != null && token.isNotEmpty && isLoggedIn;
  }

  // ========== Generic Methods ==========

  /// Save string value
  Future<bool> saveString(String key, String value) async {
    final prefs = await _preferences;
    return await prefs.setString(key, value);
  }

  /// Get string value
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  /// Save int value
  Future<bool> saveInt(String key, int value) async {
    final prefs = await _preferences;
    return await prefs.setInt(key, value);
  }

  /// Get int value
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  /// Save bool value
  Future<bool> saveBool(String key, bool value) async {
    final prefs = await _preferences;
    return await prefs.setBool(key, value);
  }

  /// Get bool value
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  /// Remove value
  Future<bool> remove(String key) async {
    final prefs = await _preferences;
    return await prefs.remove(key);
  }

  /// Clear all data
  Future<bool> clear() async {
    final prefs = await _preferences;
    return await prefs.clear();
  }
}
