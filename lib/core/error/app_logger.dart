import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// نظام تسجيل المعلومات المركزي
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 5,
        errorMethodCount: 8,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  late final Logger _logger;
  final List<LogRecord> _logs = [];
  final int _maxLogs = 1000;

  /// تسجيل رسالة معلومات
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message);
    _addLog('INFO', message, error, stackTrace);
  }

  /// تسجيل رسالة تصحيح (Debug)
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message);
      _addLog('DEBUG', message, error, stackTrace);
    }
  }

  /// تسجيل رسالة تحذير
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _addLog('WARNING', message, error, stackTrace);
  }

  /// تسجيل رسالة خطأ
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _addLog('ERROR', message, error, stackTrace);
  }

  /// تسجيل رسالة حرجة
  void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('🔴 CRITICAL: $message', error: error, stackTrace: stackTrace);
    _addLog('CRITICAL', message, error, stackTrace);
  }

  /// إضافة سجل
  void _addLog(
    String level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final record = LogRecord(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );

    _logs.add(record);

    // الحفاظ على حد أقصى من السجلات
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
  }

  /// الحصول على جميع السجلات
  List<LogRecord> getLogs() => List.unmodifiable(_logs);

  /// الحصول على السجلات حسب المستوى
  List<LogRecord> getLogsByLevel(String level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// مسح جميع السجلات
  void clearLogs() {
    _logs.clear();
  }

  /// تصدير السجلات كـ نصوص
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('=== Application Logs Export ===');
    buffer.writeln('Exported at: ${DateTime.now()}');
    buffer.writeln('Total logs: ${_logs.length}');
    buffer.writeln('');

    for (final log in _logs) {
      buffer.writeln('[${log.timestamp}] ${log.level}');
      buffer.writeln('  Message: ${log.message}');
      if (log.error != null) {
        buffer.writeln('  Error: ${log.error}');
      }
      if (log.stackTrace != null) {
        buffer.writeln('  Stack Trace:');
        buffer.writeln(log.stackTrace);
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// تصدير السجلات كـ JSON
  List<Map<String, dynamic>> exportLogsAsJson() {
    return _logs
        .map(
          (log) => {
            'timestamp': log.timestamp.toIso8601String(),
            'level': log.level,
            'message': log.message,
            'error': log.error,
            'stackTrace': log.stackTrace,
          },
        )
        .toList();
  }
}

/// نموذج سجل
class LogRecord {
  final String level;
  final String message;
  final DateTime timestamp;
  final String? error;
  final String? stackTrace;

  LogRecord({
    required this.level,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
    'level': level,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'error': error,
    'stackTrace': stackTrace,
  };
}

/// مساعد للتعامل مع Global Error Handler
void setupGlobalErrorHandler() {
  // معالجة الأخطاء غير المعالجة في Dart
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger().error(
      'Flutter Error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  // معالجة الأخطاء غير المعالجة في Futures
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger().error('Platform Error: $error', error, stack);
    return true;
  };
}
