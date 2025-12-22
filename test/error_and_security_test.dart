import 'package:flutter_test/flutter_test.dart';
import '../lib/core/error/app_exception.dart';
import '../lib/core/error/error_handler.dart';
import '../lib/core/security/security_manager.dart';

void main() {
  group('Exception Handling Tests', () {
    test('NetworkException.timeout() creates correct exception', () {
      final exception = NetworkException.timeout();
      expect(exception.message, 'انتهت مهلة الاتصال بالخادم');
      expect(exception.code, 'TIMEOUT');
    });

    test('AuthException.unauthorized() creates correct exception', () {
      final exception = AuthException.unauthorized();
      expect(exception.message, 'بيانات المصادقة غير صحيحة');
      expect(exception.code, 'UNAUTHORIZED');
    });

    test('PaymentException.failedTransaction() creates correct exception', () {
      final exception = PaymentException.failedTransaction();
      expect(exception.message, 'فشلت عملية الدفع');
      expect(exception.code, 'TRANSACTION_FAILED');
    });

    test('ValidationException.fromMap() creates correct exception', () {
      final errors = {
        'email': 'البريد غير صحيح',
        'password': 'كلمة المرور ضعيفة',
      };
      final exception = ValidationException.fromMap(errors);
      expect(exception.errors, errors);
      expect(exception.message.contains('خطأ في البيانات المدخلة'), true);
    });
  });

  group('Error Handler Tests', () {
    final errorHandler = ErrorHandler();

    test('handleError returns AppException for known exceptions', () {
      final networkError = NetworkException.timeout();
      final result = errorHandler.handleError(networkError);
      expect(result, isA<NetworkException>());
    });

    test('handleError converts string to UnexpectedException', () {
      const errorMessage = 'Some error';
      final result = errorHandler.handleError(errorMessage);
      expect(result, isA<UnexpectedException>());
      expect(result.message, errorMessage);
    });
  });

  group('Security Manager Tests', () {
    final securityManager = SecurityManager();

    test('hashSHA256 produces consistent results', () {
      const input = 'test@example.com';
      final hash1 = securityManager.hashSHA256(input);
      final hash2 = securityManager.hashSHA256(input);
      expect(hash1, hash2);
    });

    test('encodeBase64 and decodeBase64 are inverse operations', () {
      const original = 'Hello World';
      final encoded = securityManager.encodeBase64(original);
      final decoded = securityManager.decodeBase64(encoded);
      expect(decoded, original);
    });

    test('isValidEmail validates correct emails', () {
      expect(securityManager.isValidEmail('user@example.com'), true);
      expect(securityManager.isValidEmail('invalid.email@'), false);
      expect(securityManager.isValidEmail('no-at-sign.com'), false);
    });

    test('validatePassword checks password strength', () {
      final weakPassword = securityManager.validatePassword('123');
      expect(weakPassword, PasswordStrength.veryWeak);

      final strongPassword = securityManager.validatePassword('SecurePass123!');
      expect(strongPassword.index >= PasswordStrength.strong.index, true);
    });

    test('isValidPhoneNumber validates phone numbers', () {
      expect(securityManager.isValidPhoneNumber('+1(555)123-4567'), true);
      expect(securityManager.isValidPhoneNumber('123'), false);
    });

    test('isValidURL validates URLs', () {
      expect(securityManager.isValidURL('https://www.example.com'), true);
      expect(securityManager.isValidURL('not-a-url'), false);
    });

    test('sanitizeInput removes HTML tags', () {
      const input = '<script>alert("XSS")</script>Hello';
      final sanitized = securityManager.sanitizeInput(input);
      expect(sanitized.contains('<script>'), false);
      expect(sanitized.contains('</script>'), false);
    });
  });

  group('Result Tests', () {
    test('Result.success() creates success result', () {
      final result = Result<String>.success('test data');
      expect(result.isSuccess, true);
      expect(result.data, 'test data');
      expect(result.error, null);
    });

    test('Result.error() creates error result', () {
      final exception = NetworkException.timeout();
      final result = Result<String>.error(exception);
      expect(result.isSuccess, false);
      expect(result.data, null);
      expect(result.error, exception);
    });

    test('Result.when() executes correct branch', () {
      final successResult = Result<int>.success(42);
      final output = successResult.when(
        onSuccess: (data) => 'success: $data',
        onError: (error) => 'error: ${error.message}',
      );
      expect(output, 'success: 42');

      final errorResult = Result<int>.error(AuthException.unauthorized());
      final errorOutput = errorResult.when(
        onSuccess: (data) => 'success: $data',
        onError: (error) => 'error: ${error.message}',
      );
      expect(errorOutput.contains('error:'), true);
    });

    test('Result.getOrThrow() returns data or throws', () {
      final successResult = Result<String>.success('data');
      expect(successResult.getOrThrow(), 'data');

      final errorResult = Result<String>.error(NetworkException.timeout());
      expect(() => errorResult.getOrThrow(), throwsA(isA<NetworkException>()));
    });
  });

  group('PIN Generator Tests', () {
    test('generatePIN() creates correct length PIN', () {
      final pin4 = PINGenerator.generatePIN(4);
      final pin6 = PINGenerator.generatePIN(6);
      expect(pin4.length, 4);
      expect(pin6.length, 6);
    });

    test('validatePIN() checks PIN format', () {
      expect(PINGenerator.validatePIN('1234', 4), true);
      expect(PINGenerator.validatePIN('123', 4), false);
      expect(PINGenerator.validatePIN('12ab', 4), false);
    });
  });
}
