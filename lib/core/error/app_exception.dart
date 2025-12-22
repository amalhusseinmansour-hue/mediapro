/// الفئات الأساسية للاستثناءات في التطبيق
/// Base Exception Classes for App

/// استثناء أساسي للتطبيق
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// استثناء شبكة
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'NETWORK_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  factory NetworkException.timeout() =>
      NetworkException(message: 'انتهت مهلة الاتصال بالخادم', code: 'TIMEOUT');

  factory NetworkException.noInternet() =>
      NetworkException(message: 'لا يوجد اتصال بالإنترنت', code: 'NO_INTERNET');

  factory NetworkException.connectionError() => NetworkException(
    message: 'خطأ في الاتصال بالخادم',
    code: 'CONNECTION_ERROR',
  );
}

/// استثناء المصادقة
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'AUTH_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  factory AuthException.unauthorized() =>
      AuthException(message: 'بيانات المصادقة غير صحيحة', code: 'UNAUTHORIZED');

  factory AuthException.tokenExpired() =>
      AuthException(message: 'انتهت صلاحية الجلسة', code: 'TOKEN_EXPIRED');

  factory AuthException.tokenNotFound() => AuthException(
    message: 'لم يتم العثور على رمز المصادقة',
    code: 'TOKEN_NOT_FOUND',
  );

  factory AuthException.forbidden() =>
      AuthException(message: 'ليس لديك صلاحية للوصول', code: 'FORBIDDEN');
}

/// استثناء خادم
class ServerException extends AppException {
  ServerException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'SERVER_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  factory ServerException.internalError() =>
      ServerException(message: 'حدث خطأ في الخادم', code: 'INTERNAL_ERROR');

  factory ServerException.badRequest() =>
      ServerException(message: 'طلب غير صحيح', code: 'BAD_REQUEST');

  factory ServerException.notFound() =>
      ServerException(message: 'المورد غير موجود', code: 'NOT_FOUND');

  factory ServerException.rateLimited() => ServerException(
    message: 'تم تجاوز حد الطلبات. الرجاء المحاولة لاحقاً',
    code: 'RATE_LIMITED',
  );
}

/// استثناء البيانات المحلية
class CacheException extends AppException {
  CacheException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'CACHE_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  factory CacheException.notFound() =>
      CacheException(message: 'البيانات المخزنة غير موجودة', code: 'NOT_FOUND');

  factory CacheException.corruptedData() =>
      CacheException(message: 'البيانات المخزنة تالفة', code: 'CORRUPTED_DATA');
}

/// استثناء التحقق
class ValidationException extends AppException {
  final Map<String, String> errors;

  ValidationException({
    required String message,
    required this.errors,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'VALIDATION_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  factory ValidationException.fromMap(Map<String, String> errors) {
    final errorMessages = errors.values.join(', ');
    return ValidationException(
      message: 'خطأ في البيانات المدخلة: $errorMessages',
      errors: errors,
    );
  }
}

/// استثناء الدفع
class PaymentException extends AppException {
  PaymentException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'PAYMENT_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );

  factory PaymentException.failedTransaction() =>
      PaymentException(message: 'فشلت عملية الدفع', code: 'TRANSACTION_FAILED');

  factory PaymentException.insufficientFunds() =>
      PaymentException(message: 'الرصيد غير كافي', code: 'INSUFFICIENT_FUNDS');

  factory PaymentException.invalidCard() => PaymentException(
    message: 'بيانات البطاقة غير صحيحة',
    code: 'INVALID_CARD',
  );
}

/// استثناء غير متوقع
class UnexpectedException extends AppException {
  UnexpectedException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'UNEXPECTED_ERROR',
         originalError: originalError,
         stackTrace: stackTrace,
       );
}
