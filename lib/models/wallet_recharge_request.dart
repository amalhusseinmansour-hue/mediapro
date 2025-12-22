class WalletRechargeRequest {
  final int id;
  final String? referenceNumber;
  final String userId;
  final double amount;
  final String currency;
  final String? receiptUrl;
  final String? receiptImagePath; // Local path for receipt image
  final String? paymentMethod;
  final String? bankName;
  final String? transactionReference;
  final String? notes;
  final String status;
  final String statusText;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? processedAt;

  WalletRechargeRequest({
    required this.id,
    this.referenceNumber,
    required this.userId,
    required this.amount,
    required this.currency,
    this.receiptUrl,
    this.receiptImagePath,
    this.paymentMethod,
    this.bankName,
    this.transactionReference,
    this.notes,
    required this.status,
    String? statusText,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
    this.processedAt,
  }) : statusText = statusText ?? _getStatusText(status);

  static String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  factory WalletRechargeRequest.fromJson(Map<String, dynamic> json) {
    return WalletRechargeRequest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      referenceNumber: json['reference_number'] as String?,
      userId: json['user_id'] as String? ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'SAR',
      receiptUrl: json['receipt_url'] as String?,
      receiptImagePath: json['receipt_image_path'] as String?,
      paymentMethod: json['payment_method'] as String?,
      bankName: json['bank_name'] as String?,
      transactionReference: json['transaction_reference'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      statusText: json['status_text'] as String?,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_number': referenceNumber,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'receipt_url': receiptUrl,
      'receipt_image_path': receiptImagePath,
      'payment_method': paymentMethod,
      'bank_name': bankName,
      'transaction_reference': transactionReference,
      'notes': notes,
      'status': status,
      'status_text': statusText,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get formattedAmount => '${amount.toStringAsFixed(2)} $currency';
}
