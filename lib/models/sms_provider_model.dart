import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج مزود SMS
class SMSProviderModel {
  final String id;
  final String name; // firebase, twilio, nexmo, aws_sns, messagebird
  final String displayName;
  final bool isEnabled;
  final bool isTestMode;
  final Map<String, String> credentials;
  final Map<String, dynamic> settings;
  final List<String> supportedCountries;
  final double? costPerMessage; // التكلفة لكل رسالة
  final int priority; // الأولوية
  final DateTime createdAt;
  final DateTime updatedAt;

  SMSProviderModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.isEnabled,
    required this.isTestMode,
    required this.credentials,
    required this.settings,
    required this.supportedCountries,
    this.costPerMessage,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من Firestore
  factory SMSProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SMSProviderModel(
      id: doc.id,
      name: data['name'] ?? '',
      displayName: data['displayName'] ?? '',
      isEnabled: data['isEnabled'] ?? false,
      isTestMode: data['isTestMode'] ?? true,
      credentials: Map<String, String>.from(data['credentials'] ?? {}),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      supportedCountries:
          List<String>.from(data['supportedCountries'] ?? ['AE']),
      costPerMessage: data['costPerMessage']?.toDouble(),
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
      'supportedCountries': supportedCountries,
      'costPerMessage': costPerMessage,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// نسخ مع تعديلات
  SMSProviderModel copyWith({
    String? id,
    String? name,
    String? displayName,
    bool? isEnabled,
    bool? isTestMode,
    Map<String, String>? credentials,
    Map<String, dynamic>? settings,
    List<String>? supportedCountries,
    double? costPerMessage,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SMSProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      isEnabled: isEnabled ?? this.isEnabled,
      isTestMode: isTestMode ?? this.isTestMode,
      credentials: credentials ?? this.credentials,
      settings: settings ?? this.settings,
      supportedCountries: supportedCountries ?? this.supportedCountries,
      costPerMessage: costPerMessage ?? this.costPerMessage,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// التحقق من صحة الإعدادات
  bool get isValid {
    switch (name.toLowerCase()) {
      case 'firebase':
        return true; // Firebase لا يحتاج مفاتيح إضافية
      case 'twilio':
        return credentials.containsKey('accountSid') &&
            credentials.containsKey('authToken') &&
            credentials.containsKey('phoneNumber');
      case 'nexmo':
      case 'vonage':
        return credentials.containsKey('apiKey') &&
            credentials.containsKey('apiSecret');
      case 'aws_sns':
        return credentials.containsKey('accessKeyId') &&
            credentials.containsKey('secretAccessKey') &&
            credentials.containsKey('region');
      case 'messagebird':
        return credentials.containsKey('apiKey');
      default:
        return credentials.isNotEmpty;
    }
  }

  /// الحصول على الحقول المطلوبة حسب المزود
  static List<SMSProviderField> getRequiredFields(String provider) {
    switch (provider.toLowerCase()) {
      case 'firebase':
        return [
          SMSProviderField(
            key: 'info',
            label: 'معلومات',
            description: 'Firebase SMS يعمل تلقائياً مع Firebase Authentication',
            isRequired: false,
          ),
        ];
      case 'twilio':
        return [
          SMSProviderField(
            key: 'accountSid',
            label: 'Account SID',
            description: 'معرف الحساب من Twilio Console',
            isRequired: true,
          ),
          SMSProviderField(
            key: 'authToken',
            label: 'Auth Token',
            description: 'رمز المصادقة',
            isRequired: true,
            isSecret: true,
          ),
          SMSProviderField(
            key: 'phoneNumber',
            label: 'Phone Number',
            description: 'رقم الهاتف المسجل (+1234567890)',
            isRequired: true,
          ),
        ];
      case 'nexmo':
      case 'vonage':
        return [
          SMSProviderField(
            key: 'apiKey',
            label: 'API Key',
            description: 'مفتاح API من Vonage Dashboard',
            isRequired: true,
          ),
          SMSProviderField(
            key: 'apiSecret',
            label: 'API Secret',
            description: 'المفتاح السري',
            isRequired: true,
            isSecret: true,
          ),
        ];
      case 'aws_sns':
        return [
          SMSProviderField(
            key: 'accessKeyId',
            label: 'Access Key ID',
            description: 'معرف مفتاح الوصول من AWS IAM',
            isRequired: true,
          ),
          SMSProviderField(
            key: 'secretAccessKey',
            label: 'Secret Access Key',
            description: 'المفتاح السري',
            isRequired: true,
            isSecret: true,
          ),
          SMSProviderField(
            key: 'region',
            label: 'Region',
            description: 'المنطقة (مثل: us-east-1)',
            isRequired: true,
          ),
        ];
      case 'messagebird':
        return [
          SMSProviderField(
            key: 'apiKey',
            label: 'API Key',
            description: 'مفتاح API من MessageBird Dashboard',
            isRequired: true,
            isSecret: true,
          ),
          SMSProviderField(
            key: 'originator',
            label: 'Originator',
            description: 'اسم المرسل (11 حرف كحد أقصى)',
            isRequired: false,
          ),
        ];
      default:
        return [];
    }
  }

  /// الحصول على المزودين الافتراضيين
  static List<SMSProviderModel> getDefaultProviders() {
    final now = DateTime.now();
    return [
      SMSProviderModel(
        id: 'firebase',
        name: 'firebase',
        displayName: 'Firebase SMS',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCountries: ['AE', 'SA', 'EG', 'US', 'GB'],
        costPerMessage: 0.01,
        priority: 1,
        createdAt: now,
        updatedAt: now,
      ),
      SMSProviderModel(
        id: 'twilio',
        name: 'twilio',
        displayName: 'Twilio',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCountries: ['AE', 'SA', 'EG', 'US', 'GB'],
        costPerMessage: 0.0075,
        priority: 2,
        createdAt: now,
        updatedAt: now,
      ),
      SMSProviderModel(
        id: 'nexmo',
        name: 'nexmo',
        displayName: 'Vonage (Nexmo)',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCountries: ['AE', 'SA', 'EG', 'US', 'GB'],
        costPerMessage: 0.006,
        priority: 3,
        createdAt: now,
        updatedAt: now,
      ),
      SMSProviderModel(
        id: 'aws_sns',
        name: 'aws_sns',
        displayName: 'AWS SNS',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCountries: ['AE', 'SA', 'EG', 'US', 'GB'],
        costPerMessage: 0.00645,
        priority: 4,
        createdAt: now,
        updatedAt: now,
      ),
      SMSProviderModel(
        id: 'messagebird',
        name: 'messagebird',
        displayName: 'MessageBird',
        isEnabled: false,
        isTestMode: true,
        credentials: {},
        settings: {},
        supportedCountries: ['AE', 'SA', 'EG', 'US', 'GB'],
        costPerMessage: 0.007,
        priority: 5,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

/// حقل مزود SMS
class SMSProviderField {
  final String key;
  final String label;
  final String description;
  final bool isRequired;
  final bool isSecret;

  SMSProviderField({
    required this.key,
    required this.label,
    required this.description,
    required this.isRequired,
    this.isSecret = false,
  });
}
