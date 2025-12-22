import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج رسالة SMS
class SMSMessageModel {
  final String id;
  final String userId;
  final String phoneNumber;
  final String message;
  final String provider; // firebase, twilio, nexmo, aws_sns, etc.
  final SMSStatus status;
  final String? messageId; // معرف من المزود
  final String? errorMessage;
  final double? cost; // التكلفة
  final String? countryCode;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;

  SMSMessageModel({
    required this.id,
    required this.userId,
    required this.phoneNumber,
    required this.message,
    required this.provider,
    required this.status,
    this.messageId,
    this.errorMessage,
    this.cost,
    this.countryCode,
    this.metadata,
    required this.createdAt,
    this.sentAt,
    this.deliveredAt,
  });

  /// تحويل من Firestore
  factory SMSMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SMSMessageModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      message: data['message'] ?? '',
      provider: data['provider'] ?? 'firebase',
      status: SMSStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => SMSStatus.pending,
      ),
      messageId: data['messageId'],
      errorMessage: data['errorMessage'],
      cost: data['cost']?.toDouble(),
      countryCode: data['countryCode'],
      metadata: data['metadata'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      sentAt: data['sentAt'] != null
          ? (data['sentAt'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// تحويل إلى Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'message': message,
      'provider': provider,
      'status': status.toString().split('.').last,
      'messageId': messageId,
      'errorMessage': errorMessage,
      'cost': cost,
      'countryCode': countryCode,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'deliveredAt':
          deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }

  /// نسخ مع تعديلات
  SMSMessageModel copyWith({
    String? id,
    String? userId,
    String? phoneNumber,
    String? message,
    String? provider,
    SMSStatus? status,
    String? messageId,
    String? errorMessage,
    double? cost,
    String? countryCode,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
  }) {
    return SMSMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      messageId: messageId ?? this.messageId,
      errorMessage: errorMessage ?? this.errorMessage,
      cost: cost ?? this.cost,
      countryCode: countryCode ?? this.countryCode,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  /// الحصول على اسم الحالة بالعربية
  String get statusNameAr {
    switch (status) {
      case SMSStatus.pending:
        return 'قيد الانتظار';
      case SMSStatus.sending:
        return 'جاري الإرسال';
      case SMSStatus.sent:
        return 'تم الإرسال';
      case SMSStatus.delivered:
        return 'تم التسليم';
      case SMSStatus.failed:
        return 'فشل';
      case SMSStatus.cancelled:
        return 'ملغي';
    }
  }

  /// الحصول على اسم المزود بالعربية
  String get providerNameAr {
    switch (provider.toLowerCase()) {
      case 'firebase':
        return 'فايربيز';
      case 'twilio':
        return 'توليو';
      case 'nexmo':
      case 'vonage':
        return 'نيكسمو (فونج)';
      case 'aws_sns':
        return 'أمازون SNS';
      case 'messagebird':
        return 'ميسج بيرد';
      default:
        return provider;
    }
  }

  /// الحصول على عدد الأحرف
  int get messageLength => message.length;

  /// الحصول على عدد الرسائل (كل 160 حرف = رسالة)
  int get segmentCount => (messageLength / 160).ceil();
}

/// حالات رسالة SMS
enum SMSStatus {
  pending, // قيد الانتظار
  sending, // جاري الإرسال
  sent, // تم الإرسال
  delivered, // تم التسليم
  failed, // فشل
  cancelled, // ملغي
}
