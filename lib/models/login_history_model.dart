import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'login_history_model.g.dart';

/// نموذج سجل تسجيل الدخول
@HiveType(typeId: 30)
class LoginHistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime loginTime;

  @HiveField(3)
  final String? deviceInfo; // معلومات الجهاز (نوع الجهاز، نظام التشغيل، إلخ)

  @HiveField(4)
  final String? ipAddress; // عنوان IP

  @HiveField(5)
  final String? location; // الموقع الجغرافي

  @HiveField(6)
  final String loginMethod; // طريقة تسجيل الدخول (phone, email, otp)

  @HiveField(7)
  final bool isSuccessful; // نجاح تسجيل الدخول

  @HiveField(8)
  final String? failureReason; // سبب الفشل (إذا فشل تسجيل الدخول)

  @HiveField(9)
  final DateTime? logoutTime; // وقت تسجيل الخروج

  @HiveField(10)
  final int? sessionDuration; // مدة الجلسة بالدقائق

  LoginHistoryModel({
    required this.id,
    required this.userId,
    required this.loginTime,
    this.deviceInfo,
    this.ipAddress,
    this.location,
    required this.loginMethod,
    this.isSuccessful = true,
    this.failureReason,
    this.logoutTime,
    this.sessionDuration,
  });

  /// تحويل من JSON
  factory LoginHistoryModel.fromJson(Map<String, dynamic> json) {
    return LoginHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      loginTime: json['loginTime'] != null
          ? DateTime.parse(json['loginTime'])
          : DateTime.now(),
      deviceInfo: json['deviceInfo'],
      ipAddress: json['ipAddress'],
      location: json['location'],
      loginMethod: json['loginMethod'] ?? 'unknown',
      isSuccessful: json['isSuccessful'] ?? true,
      failureReason: json['failureReason'],
      logoutTime:
          json['logoutTime'] != null ? DateTime.parse(json['logoutTime']) : null,
      sessionDuration: json['sessionDuration'],
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'loginTime': loginTime.toIso8601String(),
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'location': location,
      'loginMethod': loginMethod,
      'isSuccessful': isSuccessful,
      'failureReason': failureReason,
      'logoutTime': logoutTime?.toIso8601String(),
      'sessionDuration': sessionDuration,
    };
  }

  /// تحويل من Firestore
  factory LoginHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoginHistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      loginTime: (data['loginTime'] as Timestamp).toDate(),
      deviceInfo: data['deviceInfo'],
      ipAddress: data['ipAddress'],
      location: data['location'],
      loginMethod: data['loginMethod'] ?? 'unknown',
      isSuccessful: data['isSuccessful'] ?? true,
      failureReason: data['failureReason'],
      logoutTime: data['logoutTime'] != null
          ? (data['logoutTime'] as Timestamp).toDate()
          : null,
      sessionDuration: data['sessionDuration'],
    );
  }

  /// تحويل إلى Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'loginTime': Timestamp.fromDate(loginTime),
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'location': location,
      'loginMethod': loginMethod,
      'isSuccessful': isSuccessful,
      'failureReason': failureReason,
      'logoutTime': logoutTime != null ? Timestamp.fromDate(logoutTime!) : null,
      'sessionDuration': sessionDuration,
    };
  }

  /// نسخ مع تعديلات
  LoginHistoryModel copyWith({
    String? id,
    String? userId,
    DateTime? loginTime,
    String? deviceInfo,
    String? ipAddress,
    String? location,
    String? loginMethod,
    bool? isSuccessful,
    String? failureReason,
    DateTime? logoutTime,
    int? sessionDuration,
  }) {
    return LoginHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loginTime: loginTime ?? this.loginTime,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      loginMethod: loginMethod ?? this.loginMethod,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      failureReason: failureReason ?? this.failureReason,
      logoutTime: logoutTime ?? this.logoutTime,
      sessionDuration: sessionDuration ?? this.sessionDuration,
    );
  }

  /// الحصول على اسم طريقة تسجيل الدخول بالعربية
  String get loginMethodName {
    switch (loginMethod) {
      case 'phone':
        return 'رقم الهاتف';
      case 'email':
        return 'البريد الإلكتروني';
      case 'otp':
        return 'رمز OTP';
      case 'firebase':
        return 'Firebase';
      default:
        return 'غير معروف';
    }
  }

  /// الحصول على حالة تسجيل الدخول بالعربية
  String get statusText {
    return isSuccessful ? 'ناجح' : 'فاشل';
  }

  /// حساب مدة الجلسة من وقت تسجيل الدخول والخروج
  int? calculateSessionDuration() {
    if (logoutTime != null) {
      return logoutTime!.difference(loginTime).inMinutes;
    }
    return null;
  }
}
