import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج إعدادات بوابة الدفع
class PaymentGatewayConfigModel {
  final String id;
  final String name; // paymob, stripe, paytabs, checkout
  final String displayName; // الاسم المعروض
  final bool isEnabled; // هل البوابة مفعلة؟
  final bool isTestMode; // وضع الاختبار
  final Map<String, String> credentials; // المفاتيح والبيانات السرية
  final Map<String, dynamic> settings; // إعدادات إضافية
  final List<String> supportedCurrencies; // العملات المدعومة
  final double? feePercentage; // نسبة العمولة
  final double? fixedFee; // الرسوم الثابتة
  final int priority; // الأولوية (للترتيب)
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentGatewayConfigModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.isEnabled,
    required this.isTestMode,
    required this.credentials,
    required this.settings,
    required this.supportedCurrencies,
    this.feePercentage,
    this.fixedFee,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من Firestore
  factory PaymentGatewayConfigModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentGatewayConfigModel(
      id: doc.id,
      name: data['name'] ?? '',
      displayName: data['displayName'] ?? '',
      isEnabled: data['isEnabled'] ?? false,
      isTestMode: data['isTestMode'] ?? true,
      credentials: Map<String, String>.from(data['credentials'] ?? {}),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      supportedCurrencies: List<String>.from(data['supportedCurrencies'] ?? ['AED']),
      feePercentage: data['feePercentage']?.toDouble(),
      fixedFee: data['fixedFee']?.toDouble(),
      priority: data['priority'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// تحويل إلى Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'displayName': displayName,
      'isEnabled': isEnabled,
      'isTestMode': isTestMode,
      'credentials': credentials,
      'settings': settings,
      'supportedCurrencies': supportedCurrencies,
      'feePercentage': feePercentage,
      'fixedFee': fixedFee,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// نسخ مع تعديلات
  PaymentGatewayConfigModel copyWith({
    String? id,
    String? name,
    String? displayName,
    bool? isEnabled,
    bool? isTestMode,
    Map<String, String>? credentials,
    Map<String, dynamic>? settings,
    List<String>? supportedCurrencies,
    double? feePercentage,
    double? fixedFee,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentGatewayConfigModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      isEnabled: isEnabled ?? this.isEnabled,
      isTestMode: isTestMode ?? this.isTestMode,
      credentials: credentials ?? this.credentials,
      settings: settings ?? this.settings,
      supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
      feePercentage: feePercentage ?? this.feePercentage,
      fixedFee: fixedFee ?? this.fixedFee,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// التحقق من صحة الإعدادات
  bool get isValid {
    // التحقق من وجود المفاتيح المطلوبة
    switch (name.toLowerCase()) {
      case 'paymob':
        return credentials.containsKey('apiKey') &&
            credentials.containsKey('integrationId') &&
            credentials.containsKey('iframeId');
      case 'stripe':
        return credentials.containsKey('publishableKey') &&
            credentials.containsKey('secretKey');
      case 'paytabs':
        return credentials.containsKey('serverKey') &&
            credentials.containsKey('profileId');
      case 'checkout':
        return credentials.containsKey('publicKey') &&
            credentials.containsKey('secretKey');
      default:
        return credentials.isNotEmpty;
    }
  }

  /// حساب الرسوم الكلية
  double calculateFees(double amount) {
    double fees = 0.0;
    if (feePercentage != null) {
      fees += amount * (feePercentage! / 100);
    }
    if (fixedFee != null) {
      fees += fixedFee!;
    }
    return fees;
  }

  /// الحصول على الإجمالي بعد الرسوم
  double getTotalWithFees(double amount) {
    return amount + calculateFees(amount);
  }

  /// الحصول على الحقول المطلوبة حسب البوابة
  static List<PaymentGatewayField> getRequiredFields(String gateway) {
    switch (gateway.toLowerCase()) {
      case 'paymob':
        return [
          PaymentGatewayField(
            key: 'apiKey',
            label: 'API Key',
            description: 'مفتاح API من لوحة تحكم Paymob',
            isRequired: true,
            isSecret: true,
          ),
          PaymentGatewayField(
            key: 'integrationId',
            label: 'Integration ID',
            description: 'معرف التكامل الخاص بك',
            isRequired: true,
          ),
          PaymentGatewayField(
            key: 'iframeId',
            label: 'iFrame ID',
            description: 'معرف iFrame للدفع',
            isRequired: true,
          ),
        ];
      case 'stripe':
        return [
          PaymentGatewayField(
            key: 'publishableKey',
            label: 'Publishable Key',
            description: 'المفتاح العام من Stripe',
            isRequired: true,
          ),
          PaymentGatewayField(
            key: 'secretKey',
            label: 'Secret Key',
            description: 'المفتاح السري من Stripe',
            isRequired: true,
            isSecret: true,
          ),
          PaymentGatewayField(
            key: 'webhookSecret',
            label: 'Webhook Secret',
            description: 'مفتاح Webhook للإشعارات',
            isRequired: false,
            isSecret: true,
          ),
        ];
      case 'paytabs':
        return [
          PaymentGatewayField(
            key: 'serverKey',
            label: 'Server Key',
            description: 'مفتاح الخادم من PayTabs',
            isRequired: true,
            isSecret: true,
          ),
          PaymentGatewayField(
            key: 'profileId',
            label: 'Profile ID',
            description: 'معرف الملف الشخصي',
            isRequired: true,
          ),
          PaymentGatewayField(
            key: 'merchantEmail',
            label: 'Merchant Email',
            description: 'البريد الإلكتروني للتاجر',
            isRequired: true,
          ),
        ];
      case 'checkout':
        return [
          PaymentGatewayField(
            key: 'publicKey',
            label: 'Public Key',
            description: 'المفتاح العام من Checkout.com',
            isRequired: true,
          ),
          PaymentGatewayField(
            key: 'secretKey',
            label: 'Secret Key',
            description: 'المفتاح السري من Checkout.com',
            isRequired: true,
            isSecret: true,
          ),
        ];
      default:
        return [];
    }
  }

  /// الحصول على البوابات الافتراضية
  static List<PaymentGatewayConfigModel> getDefaultGateways() {
    final now = DateTime.now();
    return [
      PaymentGatewayConfigModel(
        id: 'paymob',
        name: 'paymob',
        displayName: 'Paymob',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCurrencies: ['AED', 'EGP', 'USD', 'SAR'],
        feePercentage: 2.9,
        fixedFee: 1.0,
        priority: 1,
        createdAt: now,
        updatedAt: now,
      ),
      PaymentGatewayConfigModel(
        id: 'stripe',
        name: 'stripe',
        displayName: 'Stripe',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCurrencies: ['AED', 'USD', 'EUR', 'GBP', 'SAR'],
        feePercentage: 2.9,
        fixedFee: 1.0,
        priority: 2,
        createdAt: now,
        updatedAt: now,
      ),
      PaymentGatewayConfigModel(
        id: 'paytabs',
        name: 'paytabs',
        displayName: 'PayTabs',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCurrencies: ['AED', 'SAR', 'USD', 'EGP'],
        feePercentage: 2.85,
        fixedFee: 0.5,
        priority: 3,
        createdAt: now,
        updatedAt: now,
      ),
      PaymentGatewayConfigModel(
        id: 'checkout',
        name: 'checkout',
        displayName: 'Checkout.com',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCurrencies: ['AED', 'USD', 'EUR', 'GBP'],
        feePercentage: 2.5,
        fixedFee: 0.0,
        priority: 4,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

/// حقل بوابة الدفع
class PaymentGatewayField {
  final String key;
  final String label;
  final String description;
  final bool isRequired;
  final bool isSecret;

  PaymentGatewayField({
    required this.key,
    required this.label,
    required this.description,
    required this.isRequired,
    this.isSecret = false,
  });
}
