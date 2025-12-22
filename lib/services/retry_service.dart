/// خدمة إعادة محاولة العمليات مع Exponential Backoff
class RetryService {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 1);

  /// تنفيذ عملية مع إعادة محاولة تلقائية
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int retries = maxRetries,
    Duration delay = initialDelay,
    void Function(int attemptNumber, dynamic error)? onRetry,
  }) async {
    int attemptNumber = 1;

    while (true) {
      try {
        print('🔵 محاولة #$attemptNumber');
        return await operation();
      } catch (e) {
        if (retries > 0) {
          print('⚠️  فشل المحاولة #$attemptNumber: $e');
          print('⏳ انتظار ${delay.inSeconds} ثانية قبل إعادة المحاولة...');

          if (onRetry != null) {
            onRetry(attemptNumber, e);
          }

          await Future.delayed(delay);
          retries--;
          attemptNumber++;

          // مضاعفة التأخير (Exponential Backoff)
          delay = Duration(seconds: delay.inSeconds * 2);
        } else {
          print('❌ فشلت جميع المحاولات ($maxRetries)');
          rethrow;
        }
      }
    }
  }

  /// تنفيذ بعدة محاولات مع معالجة الأخطاء
  static Future<T?> tryMultiple<T>(
    List<Future<T> Function()> operations, {
    Duration delayBetween = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < operations.length; i++) {
      try {
        print('🔵 محاولة المصدر #${i + 1}');
        return await operations[i]();
      } catch (e) {
        print('⚠️  فشل المصدر #${i + 1}: $e');

        if (i < operations.length - 1) {
          await Future.delayed(delayBetween);
        }
      }
    }

    print('❌ فشلت جميع المصادر');
    return null;
  }
}
