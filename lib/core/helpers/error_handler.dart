import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// مساعد معالجة الأخطاء بشكل شامل
class ErrorHandler {
  /// معالجة الخطأ وعرض رسالة للمستخدم
  static void handle(
    dynamic error, {
    String? context,
    bool showSnackbar = true,
    VoidCallback? onRetry,
  }) {
    final message = getUserFriendlyMessage(error, context: context);

    // طباعة الخطأ للتطوير
    _logError(error, context);

    // عرض رسالة للمستخدم
    if (showSnackbar) {
      Get.snackbar(
        'خطأ',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        mainButton: onRetry != null
            ? TextButton(
                onPressed: onRetry,
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
      );
    }
  }

  /// الحصول على رسالة مفهومة للمستخدم
  static String getUserFriendlyMessage(dynamic error, {String? context}) {
    // أخطاء الشبكة
    if (error is SocketException) {
      return 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }

    if (error is HttpException) {
      return 'حدث خطأ في الاتصال بالخادم. حاول مرة أخرى لاحقاً.';
    }

    // أخطاء Firebase
    if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error);
    }

    // أخطاء Firestore
    if (error.toString().contains('permission-denied')) {
      return 'ليس لديك صلاحية للوصول إلى هذا المحتوى.';
    }

    if (error.toString().contains('unavailable')) {
      return 'الخدمة غير متاحة حالياً. حاول مرة أخرى لاحقاً.';
    }

    if (error.toString().contains('deadline-exceeded')) {
      return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.';
    }

    // أخطاء API Keys
    if (error.toString().contains('API key') ||
        error.toString().contains('401') ||
        error.toString().contains('Unauthorized')) {
      return 'مفتاح API غير صالح أو منتهي الصلاحية. تواصل مع الدعم الفني.';
    }

    // أخطاء الحصة المستهلكة
    if (error.toString().contains('quota') ||
        error.toString().contains('limit exceeded')) {
      return 'تم تجاوز الحد المسموح. حاول لاحقاً أو ترقية اشتراكك.';
    }

    // أخطاء المدخلات
    if (error.toString().contains('invalid') ||
        error.toString().contains('validation')) {
      return 'بيانات غير صحيحة. تحقق من المدخلات وحاول مرة أخرى.';
    }

    // أخطاء الدفع
    if (error.toString().contains('payment') ||
        error.toString().contains('transaction')) {
      return 'فشلت عملية الدفع. تحقق من بياناتك وحاول مرة أخرى.';
    }

    // رسالة عامة مع السياق
    if (context != null) {
      return 'حدث خطأ أثناء $context. حاول مرة أخرى لاحقاً.';
    }

    return 'حدث خطأ غير متوقع. حاول مرة أخرى لاحقاً.';
  }

  /// الحصول على رسالة خطأ Firebase محددة
  static String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      // أخطاء المصادقة
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. تواصل مع الدعم الفني.';
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة. استخدم كلمة مرور أقوى.';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة. تواصل مع الدعم الفني.';
      case 'too-many-requests':
        return 'تم حظر هذا الجهاز مؤقتاً بسبب كثرة المحاولات الفاشلة.';

      // أخطاء رقم الهاتف
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح.';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح.';
      case 'invalid-verification-id':
        return 'انتهت صلاحية رمز التحقق. اطلب رمز جديد.';

      // أخطاء Firestore
      case 'permission-denied':
        return 'ليس لديك صلاحية للوصول إلى هذا المحتوى.';
      case 'not-found':
        return 'لم يتم العثور على البيانات المطلوبة.';
      case 'already-exists':
        return 'البيانات موجودة بالفعل.';
      case 'resource-exhausted':
        return 'تم تجاوز الحد المسموح. حاول لاحقاً.';
      case 'cancelled':
        return 'تم إلغاء العملية.';
      case 'data-loss':
        return 'حدث فقدان في البيانات. حاول مرة أخرى.';
      case 'unauthenticated':
        return 'يجب تسجيل الدخول أولاً.';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً. حاول لاحقاً.';

      default:
        return 'حدث خطأ: ${error.message ?? "غير معروف"}';
    }
  }

  /// طباعة الخطأ للتطوير
  static void _logError(dynamic error, String? context) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('❌ ERROR OCCURRED');
    if (context != null) print('📍 Context: $context');
    print('🔴 Error: $error');
    if (error is Error) {
      print('📚 Stack Trace:\n${error.stackTrace}');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// إعادة محاولة عملية مع عدد محدد من المحاولات
  static Future<T?> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
    String? context,
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= maxAttempts) {
          handle(e, context: context);
          return null;
        }

        print('⚠️ Attempt $attempts failed. Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }

    return null;
  }

  /// إعادة محاولة عملية مع تأخير تصاعدي
  static Future<T?> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    String? context,
  }) async {
    int attempts = 0;
    Duration currentDelay = initialDelay;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= maxAttempts) {
          handle(e, context: context);
          return null;
        }

        print('⚠️ Attempt $attempts failed. Retrying in ${currentDelay.inSeconds}s...');
        await Future.delayed(currentDelay);
        currentDelay *= backoffMultiplier;
      }
    }

    return null;
  }

  /// معالجة أخطاء async/await بشكل آمن
  static Future<T?> tryCatch<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (showError) {
        handle(e, context: context);
      }
      return defaultValue;
    }
  }

  /// التحقق من حالة الاتصال بالإنترنت
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// عرض حوار خطأ مخصص
  static Future<void> showErrorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    return Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF3B30), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 16,
          ),
        ),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                Get.back();
                onCancel();
              },
              child: const Text('إلغاء'),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: const Color(0xFF0A0A0A),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          if (onRetry == null && onCancel == null)
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: const Color(0xFF0A0A0A),
              ),
              child: const Text('حسناً'),
            ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// عرض رسالة نجاح
  static void showSuccess(String message) {
    Get.snackbar(
      'نجح',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF34C759),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  /// عرض رسالة تحذير
  static void showWarning(String message) {
    Get.snackbar(
      'تحذير',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFF9500),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
    );
  }

  /// عرض رسالة معلومات
  static void showInfo(String message) {
    Get.snackbar(
      'معلومة',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF007AFF),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }
}
