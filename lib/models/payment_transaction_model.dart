import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج معاملة الدفع
class PaymentTransactionModel {
  final String id;
  final String userId;
  final String orderId;
  final String? paymentKey;
  final double amount;
  final String currency;
  final String gateway; // paymob, stripe, paytabs, etc.
  final PaymentStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? billingData;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  PaymentTransactionModel({
    required this.id,
    required this.userId,
    required this.orderId,
    this.paymentKey,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.status,
    this.errorMessage,
    this.billingData,
    this.metadata,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  /// تحويل من Firestore
  factory PaymentTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentTransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      orderId: data['orderId'] ?? '',
      paymentKey: data['paymentKey'],
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'AED',
      gateway: data['gateway'] ?? 'paymob',
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => PaymentStatus.pending,
      ),
      errorMessage: data['errorMessage'],
      billingData: data['billingData'] as Map<String, dynamic>?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// تحويل إلى Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'orderId': orderId,
      'paymentKey': paymentKey,
      'amount': amount,
      'currency': currency,
      'gateway': gateway,
      'status': status.toString().split('.').last,
      'errorMessage': errorMessage,
      'billingData': billingData,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  /// نسخ مع تعديلات
  PaymentTransactionModel copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? paymentKey,
    double? amount,
    String? currency,
    String? gateway,
    PaymentStatus? status,
    String? errorMessage,
    Map<String, dynamic>? billingData,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return PaymentTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      paymentKey: paymentKey ?? this.paymentKey,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      gateway: gateway ?? this.gateway,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      billingData: billingData ?? this.billingData,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// الحصول على اسم الحالة بالعربية
  String get statusNameAr {
    switch (status) {
      case PaymentStatus.pending:
        return 'قيد الانتظار';
      case PaymentStatus.processing:
        return 'جاري المعالجة';
      case PaymentStatus.completed:
        return 'مكتملة';
      case PaymentStatus.failed:
        return 'فاشلة';
      case PaymentStatus.cancelled:
        return 'ملغاة';
      case PaymentStatus.refunded:
        return 'مستردة';
    }
  }

  /// الحصول على اسم البوابة بالعربية
  String get gatewayNameAr {
    switch (gateway.toLowerCase()) {
      case 'paymob':
        return 'باي موب';
      case 'stripe':
        return 'سترايب';
      case 'paytabs':
        return 'باي تابس';
      case 'checkout':
        return 'تشيك أوت';
      default:
        return gateway;
    }
  }
}

/// حالات الدفع
enum PaymentStatus {
  pending, // قيد الانتظار
  processing, // جاري المعالجة
  completed, // مكتملة
  failed, // فاشلة
  cancelled, // ملغاة
  refunded, // مستردة
}
