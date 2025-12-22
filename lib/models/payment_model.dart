import 'package:hive/hive.dart';

part 'payment_model.g.dart';

/// نموذج بيانات الدفع
@HiveType(typeId: 9)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id; // معرف المدفوعة

  @HiveField(1)
  final String userId; // معرف المستخدم

  @HiveField(2)
  final int paymobOrderId; // معرف الطلب في Paymob

  @HiveField(3)
  final int? paymobTransactionId; // معرف المعاملة في Paymob

  @HiveField(4)
  final String subscriptionTier; // نوع الخطة

  @HiveField(5)
  final double amount; // المبلغ

  @HiveField(6)
  final String currency; // العملة

  @HiveField(7)
  final PaymentStatusEnum status; // حالة الدفع

  @HiveField(8)
  final DateTime createdAt; // تاريخ الإنشاء

  @HiveField(9)
  final DateTime? paidAt; // تاريخ الدفع

  @HiveField(10)
  final String paymentMethod; // طريقة الدفع (card, wallet, fawry, etc.)

  @HiveField(11)
  final bool isYearly; // اشتراك سنوي أم شهري

  @HiveField(12)
  final DateTime? expiresAt; // تاريخ انتهاء الاشتراك

  @HiveField(13)
  final Map<String, dynamic>? metadata; // بيانات إضافية

  PaymentModel({
    required this.id,
    required this.userId,
    required this.paymobOrderId,
    this.paymobTransactionId,
    required this.subscriptionTier,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.paidAt,
    required this.paymentMethod,
    this.isYearly = false,
    this.expiresAt,
    this.metadata,
  });

  /// تحويل إلى JSON للحفظ في Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'paymobOrderId': paymobOrderId,
      'paymobTransactionId': paymobTransactionId,
      'subscriptionTier': subscriptionTier,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isYearly': isYearly,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// إنشاء من JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      userId: json['userId'],
      paymobOrderId: json['paymobOrderId'],
      paymobTransactionId: json['paymobTransactionId'],
      subscriptionTier: json['subscriptionTier'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: PaymentStatusEnum.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatusEnum.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      paymentMethod: json['paymentMethod'],
      isYearly: json['isYearly'] ?? false,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      metadata: json['metadata'],
    );
  }

  /// نسخ مع تعديل
  PaymentModel copyWith({
    String? id,
    String? userId,
    int? paymobOrderId,
    int? paymobTransactionId,
    String? subscriptionTier,
    double? amount,
    String? currency,
    PaymentStatusEnum? status,
    DateTime? createdAt,
    DateTime? paidAt,
    String? paymentMethod,
    bool? isYearly,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      paymobOrderId: paymobOrderId ?? this.paymobOrderId,
      paymobTransactionId: paymobTransactionId ?? this.paymobTransactionId,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isYearly: isYearly ?? this.isYearly,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// هل الدفع تم بنجاح؟
  bool get isSuccessful => status == PaymentStatusEnum.success;

  /// هل الدفع فشل؟
  bool get isFailed => status == PaymentStatusEnum.failed;

  /// هل الدفع قيد الانتظار؟
  bool get isPending => status == PaymentStatusEnum.pending;

  /// هل الاشتراك نشط؟
  bool get isActive {
    if (!isSuccessful) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// الأيام المتبقية للاشتراك
  int get daysRemaining {
    if (expiresAt == null) return -1;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  /// اسم الحالة بالعربي
  String get statusArabic {
    switch (status) {
      case PaymentStatusEnum.pending:
        return 'قيد الانتظار';
      case PaymentStatusEnum.processing:
        return 'جاري المعالجة';
      case PaymentStatusEnum.success:
        return 'تم بنجاح';
      case PaymentStatusEnum.failed:
        return 'فشل';
      case PaymentStatusEnum.refunded:
        return 'تم الاسترجاع';
      case PaymentStatusEnum.cancelled:
        return 'ملغي';
    }
  }
}

/// حالات الدفع
@HiveType(typeId: 10)
enum PaymentStatusEnum {
  @HiveField(0)
  pending, // قيد الانتظار

  @HiveField(1)
  processing, // جاري المعالجة

  @HiveField(2)
  success, // تم بنجاح

  @HiveField(3)
  failed, // فشل

  @HiveField(4)
  refunded, // تم الاسترجاع

  @HiveField(5)
  cancelled, // ملغي
}
