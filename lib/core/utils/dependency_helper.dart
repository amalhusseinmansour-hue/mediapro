import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Helper class للتعامل مع GetX dependencies بشكل آمن
class DependencyHelper {
  /// محاولة الحصول على dependency مع معالجة الأخطاء
  static T? tryFind<T>() {
    try {
      return Get.find<T>();
    } catch (e) {
      print('⚠️ Failed to find dependency: $T - $e');
      return null;
    }
  }

  /// الحصول على dependency أو إنشاء واحد جديد
  static T findOrPut<T>(T Function() builder) {
    try {
      return Get.find<T>();
    } catch (e) {
      print('⚠️ Dependency $T not found, creating new instance');
      return Get.put<T>(builder());
    }
  }

  /// الحصول على dependency مع fallback
  static T findOrDefault<T>(T defaultValue) {
    try {
      return Get.find<T>();
    } catch (e) {
      print('⚠️ Using default value for $T');
      return defaultValue;
    }
  }

  /// فحص إذا كان dependency موجود
  static bool isRegistered<T>() {
    try {
      Get.find<T>();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// عرض رسالة خطأ للمستخدم
  static void showDependencyError(String serviceName) {
    Get.snackbar(
      'خطأ في النظام',
      'فشل تحميل $serviceName. الرجاء إعادة تشغيل التطبيق.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
