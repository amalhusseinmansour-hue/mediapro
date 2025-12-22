import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
// import 'package:pointycastle/export.dart'; // Commented out - not needed
import '../error/app_logger.dart';

/// مدير الأمان والتشفير
class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  late final FlutterSecureStorage _secureStorage;

  factory SecurityManager() {
    return _instance;
  }

  SecurityManager._internal() {
    _secureStorage = const FlutterSecureStorage();
  }

  final _logger = AppLogger();

  // ==================== Storage الآمن ====================

  /// حفظ بيانات حساسة بشكل آمن
  Future<void> saveSecure(String key, String value) async {
    try {
      _logger.debug('Saving secure data for key: $key');
      await _secureStorage.write(
        key: key,
        value: value,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      _logger.error('Error saving secure data: $e');
      rethrow;
    }
  }

  /// قراءة بيانات حساسة
  Future<String?> readSecure(String key) async {
    try {
      _logger.debug('Reading secure data for key: $key');
      return await _secureStorage.read(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      _logger.error('Error reading secure data: $e');
      return null;
    }
  }

  /// حذف بيانات حساسة
  Future<void> deleteSecure(String key) async {
    try {
      _logger.debug('Deleting secure data for key: $key');
      await _secureStorage.delete(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      _logger.error('Error deleting secure data: $e');
      rethrow;
    }
  }

  /// مسح جميع البيانات الآمنة
  Future<void> clearAllSecure() async {
    try {
      _logger.info('Clearing all secure data');
      await _secureStorage.deleteAll(
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      _logger.error('Error clearing secure data: $e');
      rethrow;
    }
  }

  // ==================== التشفير والفك ====================

  /// تشفير البيانات باستخدام SHA-256
  String hashSHA256(String data) {
    try {
      _logger.debug('Hashing data with SHA-256');
      return sha256.convert(utf8.encode(data)).toString();
    } catch (e) {
      _logger.error('Error hashing data: $e');
      rethrow;
    }
  }

  /// تشفير البيانات باستخدام MD5 (للملفات)
  String hashMD5(String data) {
    try {
      _logger.debug('Hashing data with MD5');
      return md5.convert(utf8.encode(data)).toString();
    } catch (e) {
      _logger.error('Error hashing data: $e');
      rethrow;
    }
  }

  /// تشفير Base64
  String encodeBase64(String data) {
    try {
      _logger.debug('Encoding data to Base64');
      return base64Encode(utf8.encode(data));
    } catch (e) {
      _logger.error('Error encoding data: $e');
      rethrow;
    }
  }

  /// فك تشفير Base64
  String decodeBase64(String encoded) {
    try {
      _logger.debug('Decoding Base64 data');
      return utf8.decode(base64Decode(encoded));
    } catch (e) {
      _logger.error('Error decoding data: $e');
      rethrow;
    }
  }

  /// إنشاء HMAC-SHA256 للتوقيع
  String generateHMAC(String data, String secret) {
    try {
      _logger.debug('Generating HMAC-SHA256');
      final bytes = utf8.encode(data);
      final key = utf8.encode(secret);
      final hmacSha256 = Hmac(sha256, key);
      return hmacSha256.convert(bytes).toString();
    } catch (e) {
      _logger.error('Error generating HMAC: $e');
      rethrow;
    }
  }

  // ==================== التحقق من صحة البيانات ====================

  /// التحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    try {
      final pattern =
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      return RegExp(pattern).hasMatch(email);
    } catch (e) {
      _logger.error('Error validating email: $e');
      return false;
    }
  }

  /// التحقق من قوة كلمة المرور
  PasswordStrength validatePassword(String password) {
    try {
      _logger.debug('Validating password strength');

      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasDigits = password.contains(RegExp(r'\d'));
      bool hasSpecialChars =
          password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:",.<>?]'));
      bool isLongEnough = password.length >= 8;

      int strength = 0;
      if (hasLowercase) strength++;
      if (hasUppercase) strength++;
      if (hasDigits) strength++;
      if (hasSpecialChars) strength++;
      if (isLongEnough) strength++;

      return PasswordStrength.fromScore(strength);
    } catch (e) {
      _logger.error('Error validating password: $e');
      return PasswordStrength.weak;
    }
  }

  /// التحقق من رقم الهاتف
  bool isValidPhoneNumber(String phone) {
    try {
      final pattern = r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$';
      return RegExp(pattern).hasMatch(phone);
    } catch (e) {
      _logger.error('Error validating phone: $e');
      return false;
    }
  }

  /// التحقق من صحة URL
  bool isValidURL(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      _logger.error('Error validating URL: $e');
      return false;
    }
  }

  /// تنظيف البيانات (Remove HTML، XSS)
  String sanitizeInput(String input) {
    try {
      _logger.debug('Sanitizing input');
      // إزالة الوسوم HTML
      String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
      // إزالة أحرف خاصة قد تسبب مشاكل
      sanitized = sanitized.replaceAll(RegExp(r'''['";\]'''), '');
      return sanitized.trim();
    } catch (e) {
      _logger.error('Error sanitizing input: $e');
      return input;
    }
  }

  // ==================== خيارات المنصات ====================

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(
      encryptedSharedPreferences: true,
    );
  }

  IOSOptions _getIOSOptions() {
    return const IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    );
  }
}

/// مستويات قوة كلمة المرور
enum PasswordStrength {
  veryWeak('ضعيفة جداً', 0xFF8B0000),
  weak('ضعيفة', 0xFFFF4500),
  fair('متوسطة', 0xFFFFD700),
  strong('قوية', 0xFF90EE90),
  veryStrong('قوية جداً', 0xFF228B22);

  final String label;
  final int color;

  const PasswordStrength(this.label, this.color);

  factory PasswordStrength.fromScore(int score) {
    return switch (score) {
      0 => PasswordStrength.veryWeak,
      1 => PasswordStrength.weak,
      2 => PasswordStrength.fair,
      3 => PasswordStrength.strong,
      _ => PasswordStrength.veryStrong,
    };
  }
}

/// رقم PIN Generator
class PINGenerator {
  /// إنشاء PIN عشوائي
  static String generatePIN(int length) {
    const String digits = '0123456789';
    String pin = '';
    for (int i = 0; i < length; i++) {
      pin += digits[DateTime.now().millisecond % digits.length];
    }
    return pin;
  }

  /// التحقق من صحة PIN
  static bool validatePIN(String pin, int expectedLength) {
    return pin.length == expectedLength && RegExp(r'^\d+$').hasMatch(pin);
  }
}
