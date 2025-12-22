import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

/// معالج أخطاء مركزي للتطبيق
class ErrorHandler {
  /// معالجة الأخطاء من API
  static String handleApiError(dynamic error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
          return 'انتهت مهلة الاتصال. تحقق من الإنترنت.';
        case dio.DioExceptionType.sendTimeout:
          return 'انتهت مهلة إرسال البيانات.';
        case dio.DioExceptionType.receiveTimeout:
          return 'انتهت مهلة استقبال البيانات.';
        case dio.DioExceptionType.badResponse:
          return _handleBadResponse(error.response);
        case dio.DioExceptionType.cancel:
          return 'تم إلغاء الطلب.';
        case dio.DioExceptionType.connectionError:
          return 'خطأ في الاتصال. تحقق من الإنترنت.';
        default:
          return 'حدث خطأ غير متوقع: ${error.message}';
      }
    }

    return error.toString();
  }

  static String _handleBadResponse(dio.Response? response) {
    if (response == null) return 'لا يوجد رد من الخادم';

    switch (response.statusCode) {
      case 400:
        return 'طلب غير صحيح: ${response.data['message'] ?? 'بيانات خاطئة'}';
      case 401:
        return 'غير مصرح. الرجاء تسجيل الدخول مرة أخرى.';
      case 403:
        return 'ليس لديك صلاحية للقيام بهذا الإجراء.';
      case 404:
        return 'المورد المطلوب غير موجود.';
      case 422:
        return 'خطأ في التحقق من البيانات: ${response.data['message'] ?? ''}';
      case 500:
        return 'خطأ في الخادم. الرجاء المحاولة لاحقاً.';
      case 503:
        return 'الخدمة غير متاحة حالياً.';
      default:
        return 'خطأ ${response.statusCode}: ${response.data['message'] ?? 'خطأ غير معروف'}';
    }
  }

  /// عرض رسالة خطأ للمستخدم
  static void showError(String message, {String title = 'خطأ'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  /// عرض رسالة نجاح
  static void showSuccess(String message, {String title = 'نجح!'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  /// عرض رسالة تحذير
  static void showWarning(String message, {String title = 'تحذير'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  /// عرض رسالة معلومات
  static void showInfo(String message, {String title = 'معلومة'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  /// معالجة الأخطاء مع logging
  static Future<T?> handleAsync<T>(
    Future<T> Function() action, {
    String? errorMessage,
    bool showSnackbar = true,
  }) async {
    try {
      return await action();
    } catch (e) {
      print('❌ Error in async operation: $e');

      final message = errorMessage ?? handleApiError(e);

      if (showSnackbar) {
        showError(message);
      }

      return null;
    }
  }

  /// معالجة الأخطاء الزامنة
  static T? handleSync<T>(
    T Function() action, {
    String? errorMessage,
    bool showSnackbar = true,
  }) {
    try {
      return action();
    } catch (e) {
      print('❌ Error in sync operation: $e');

      final message = errorMessage ?? e.toString();

      if (showSnackbar) {
        showError(message);
      }

      return null;
    }
  }
}
