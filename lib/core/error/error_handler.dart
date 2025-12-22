import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'app_exception.dart';
import 'app_logger.dart';

/// معالج الأخطاء المركزي
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();

  factory ErrorHandler() {
    return _instance;
  }

  ErrorHandler._internal();

  final _logger = AppLogger();

  /// تحويل الخطأ إلى AppException
  AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    _logger.error('Error caught: ${error.toString()}', error, stackTrace);

    // معالجة DioException (الأخطاء المتعلقة بالشبكة)
    if (error is DioException) {
      return _handleDioException(error);
    }

    // معالجة AppException
    if (error is AppException) {
      return error;
    }

    // معالجة الأخطاء الأخرى
    return UnexpectedException(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// معالجة DioException
  AppException _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException.timeout();

      case DioExceptionType.badResponse:
        return _handleBadResponse(exception.response!);

      case DioExceptionType.connectionError:
        return NetworkException.noInternet();

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'شهادة الأمان غير صحيحة',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        if (exception.message?.contains('SocketException') ?? false) {
          return NetworkException.noInternet();
        }
        return UnexpectedException(
          message: exception.message ?? 'خطأ غير معروف',
          originalError: exception,
        );

      case DioExceptionType.cancel:
        return UnexpectedException(
          message: 'تم إلغاء الطلب',
          code: 'REQUEST_CANCELLED',
        );
    }
  }

  /// معالجة استجابة الخطأ من الخادم
  AppException _handleBadResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final responseData = response.data;

    String errorMessage = 'حدث خطأ: $statusCode';
    String? errorCode;

    // محاولة استخراج رسالة الخطأ من الاستجابة
    if (responseData is Map) {
      errorMessage =
          responseData['message'] ??
          responseData['error'] ??
          responseData['error_message'] ??
          errorMessage;
      errorCode = responseData['code']?.toString();
    }

    switch (statusCode) {
      case 400:
        return ServerException.badRequest();

      case 401:
        return AuthException.unauthorized();

      case 403:
        return AuthException.forbidden();

      case 404:
        return ServerException.notFound();

      case 429:
        return ServerException.rateLimited();

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException.internalError();

      default:
        return ServerException(message: errorMessage, code: errorCode);
    }
  }

  /// عرض رسالة خطأ للمستخدم
  void showErrorSnackBar(
    AppException exception, {
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    _logger.warning('Showing error snackbar: ${exception.message}');

    Get.snackbar(
      'خطأ',
      exception.message,
      snackPosition: position,
      duration: duration,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error, color: Colors.white),
      isDismissible: true,
    );
  }

  /// عرض حوار خطأ
  void showErrorDialog(
    AppException exception, {
    VoidCallback? onRetry,
    String? retryButtonText = 'إعادة محاولة',
    String? cancelButtonText = 'إلغاء',
  }) {
    _logger.warning('Showing error dialog: ${exception.message}');

    Get.dialog(
      AlertDialog(
        title: const Text('خطأ'),
        content: Text(exception.message),
        actions: [
          if (cancelButtonText != null)
            TextButton(onPressed: Get.back, child: Text(cancelButtonText)),
          if (onRetry != null && retryButtonText != null)
            TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: Text(retryButtonText),
            ),
        ],
      ),
    );
  }

  /// تسجيل الخطأ وإرساله للـ Crash Reporting
  Future<void> reportError(
    AppException exception, {
    bool isFatal = false,
  }) async {
    _logger.error(
      'Reporting error: ${exception.message}',
      exception.originalError,
      exception.stackTrace,
    );

    if (isFatal) {
      _logger.critical('Fatal error: ${exception.message}');
    }

    // TODO: إرسال الخطأ إلى Firebase Crashlytics أو خدمة أخرى
    // await FirebaseCrashlytics.instance.recordError(
    //   exception.originalError,
    //   exception.stackTrace,
    //   reason: exception.message,
    //   fatal: isFatal,
    // );
  }

  /// معالجة خطأ في try-catch مع إعادة رفع إذا لزم
  Future<T> safeTry<T>(
    Future<T> Function() operation, {
    bool showError = true,
    bool shouldRethrow = false,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final appException = handleError(error, stackTrace);

      if (showError) {
        showErrorSnackBar(appException);
      }

      if (shouldRethrow) {
        throw appException;
      }

      if (defaultValue != null) {
        return defaultValue;
      }

      throw appException;
    }
  }
}

/// امتداد للـ GetX Controller لمعالجة الأخطاء
extension GetXErrorHandling on GetxController {
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    bool showSnackBar = true,
  }) {
    final exception = ErrorHandler().handleError(error, stackTrace);

    if (showSnackBar) {
      ErrorHandler().showErrorSnackBar(exception);
    }
  }
}

/// wrapper للعمليات غير المتزامنة مع معالجة الأخطاء
class AsyncOperation<T> {
  final Future<T> Function() operation;
  final String? errorMessage;

  AsyncOperation({required this.operation, this.errorMessage});

  Future<Result<T>> execute() async {
    try {
      final result = await operation();
      return Result<T>.success(result);
    } catch (error, stackTrace) {
      final exception = ErrorHandler().handleError(error, stackTrace);
      return Result<T>.error(exception);
    }
  }
}

/// نتيجة العملية (Success أو Error)
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;

  Result._({required this.isSuccess, this.data, this.error});

  factory Result.success(T data) {
    return Result._(isSuccess: true, data: data);
  }

  factory Result.error(AppException error) {
    return Result._(isSuccess: false, error: error);
  }

  /// تنفيذ دالة حسب النتيجة
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onError,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onError(error!);
    }
  }

  /// الحصول على البيانات أو رفع الاستثناء
  T getOrThrow() {
    if (isSuccess) {
      return data as T;
    }
    throw error!;
  }
}
