import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج إعدادات OTP
class OTPConfigModel {
  final String id;
  final String defaultProvider; // firebase, twilio, nexmo, aws_sns, messagebird
  final int otpLength; // 4, 6, or 8 digits
  final int expiryMinutes; // Default: 5 minutes
  final int maxRetries; // Default: 3
  final bool isTestMode; // Test mode or production
  final Map<String, OTPProviderConfig> providers; // Provider configurations
  final DateTime createdAt;
  final DateTime updatedAt;

  OTPConfigModel({
    required this.id,
    required this.defaultProvider,
    required this.otpLength,
    required this.expiryMinutes,
    required this.maxRetries,
    required this.isTestMode,
    required this.providers,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من Firestore
  factory OTPConfigModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final providersMap = <String, OTPProviderConfig>{};
    final providersData = data['providers'] as Map<String, dynamic>? ?? {};

    providersData.forEach((key, value) {
      providersMap[key] = OTPProviderConfig.fromMap(value as Map<String, dynamic>);
    });

    return OTPConfigModel(
      id: doc.id,
      defaultProvider: data['defaultProvider'] ?? 'firebase',
      otpLength: data['otpLength'] ?? 6,
      expiryMinutes: data['expiryMinutes'] ?? 5,
      maxRetries: data['maxRetries'] ?? 3,
      isTestMode: data['isTestMode'] ?? true,
      providers: providersMap,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// تحويل إلى Firestore
  Map<String, dynamic> toFirestore() {
    final providersMap = <String, dynamic>{};
    providers.forEach((key, value) {
      providersMap[key] = value.toMap();
    });

    return {
      'defaultProvider': defaultProvider,
      'otpLength': otpLength,
      'expiryMinutes': expiryMinutes,
      'maxRetries': maxRetries,
      'isTestMode': isTestMode,
      'providers': providersMap,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// نسخ مع تعديلات
  OTPConfigModel copyWith({
    String? id,
    String? defaultProvider,
    int? otpLength,
    int? expiryMinutes,
    int? maxRetries,
    bool? isTestMode,
    Map<String, OTPProviderConfig>? providers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OTPConfigModel(
      id: id ?? this.id,
      defaultProvider: defaultProvider ?? this.defaultProvider,
      otpLength: otpLength ?? this.otpLength,
      expiryMinutes: expiryMinutes ?? this.expiryMinutes,
      maxRetries: maxRetries ?? this.maxRetries,
      isTestMode: isTestMode ?? this.isTestMode,
      providers: providers ?? this.providers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// الحصول على الإعدادات الافتراضية
  static OTPConfigModel getDefault() {
    final now = DateTime.now();
    return OTPConfigModel(
      id: 'default',
      defaultProvider: 'firebase',
      otpLength: 6,
      expiryMinutes: 5,
      maxRetries: 3,
      isTestMode: true,
      providers: {
        'firebase': OTPProviderConfig(
          name: 'firebase',
          displayName: 'Firebase Phone Auth',
          isEnabled: true,
          isTestMode: true,
          credentials: {},
          priority: 1,
        ),
        'twilio': OTPProviderConfig(
          name: 'twilio',
          displayName: 'Twilio SMS',
          isEnabled: false,
          isTestMode: true,
          credentials: {},
          priority: 2,
        ),
        'nexmo': OTPProviderConfig(
          name: 'nexmo',
          displayName: 'Vonage (Nexmo)',
          isEnabled: false,
          isTestMode: true,
          credentials: {},
          priority: 3,
        ),
        'aws_sns': OTPProviderConfig(
          name: 'aws_sns',
          displayName: 'AWS SNS',
          isEnabled: false,
          isTestMode: true,
          credentials: {},
          priority: 4,
        ),
        'messagebird': OTPProviderConfig(
          name: 'messagebird',
          displayName: 'MessageBird',
          isEnabled: false,
          isTestMode: true,
          credentials: {},
          priority: 5,
        ),
      },
      createdAt: now,
      updatedAt: now,
    );
  }

  /// الحصول على المزود الافتراضي
  OTPProviderConfig? get defaultProviderConfig => providers[defaultProvider];

  /// الحصول على جميع المزودين المفعلين
  List<OTPProviderConfig> get enabledProviders {
    return providers.values
        .where((p) => p.isEnabled)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }
}

/// إعدادات مزود OTP
class OTPProviderConfig {
  final String name; // firebase, twilio, nexmo, aws_sns, messagebird
  final String displayName;
  final bool isEnabled;
  final bool isTestMode;
  final Map<String, String> credentials;
  final int priority;

  OTPProviderConfig({
    required this.name,
    required this.displayName,
    required this.isEnabled,
    required this.isTestMode,
    required this.credentials,
    required this.priority,
  });

  /// تحويل من Map
  factory OTPProviderConfig.fromMap(Map<String, dynamic> map) {
    return OTPProviderConfig(
      name: map['name'] ?? '',
      displayName: map['displayName'] ?? '',
      isEnabled: map['isEnabled'] ?? false,
      isTestMode: map['isTestMode'] ?? true,
      credentials: Map<String, String>.from(map['credentials'] ?? {}),
      priority: map['priority'] ?? 0,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'isEnabled': isEnabled,
      'isTestMode': isTestMode,
      'credentials': credentials,
      'priority': priority,
    };
  }

  /// نسخ مع تعديلات
  OTPProviderConfig copyWith({
    String? name,
    String? displayName,
    bool? isEnabled,
    bool? isTestMode,
    Map<String, String>? credentials,
    int? priority,
  }) {
    return OTPProviderConfig(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      isEnabled: isEnabled ?? this.isEnabled,
      isTestMode: isTestMode ?? this.isTestMode,
      credentials: credentials ?? this.credentials,
      priority: priority ?? this.priority,
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
  static List<OTPProviderField> getRequiredFields(String provider) {
    switch (provider.toLowerCase()) {
      case 'firebase':
        return [
          OTPProviderField(
            key: 'info',
            label: 'معلومات',
            description: 'Firebase Phone Auth يعمل تلقائياً مع Firebase Authentication',
            isRequired: false,
          ),
        ];
      case 'twilio':
        return [
          OTPProviderField(
            key: 'accountSid',
            label: 'Account SID',
            description: 'معرف الحساب من Twilio Console',
            isRequired: true,
          ),
          OTPProviderField(
            key: 'authToken',
            label: 'Auth Token',
            description: 'رمز المصادقة',
            isRequired: true,
            isSecret: true,
          ),
          OTPProviderField(
            key: 'phoneNumber',
            label: 'Phone Number',
            description: 'رقم الهاتف المسجل (+1234567890)',
            isRequired: true,
          ),
        ];
      case 'nexmo':
      case 'vonage':
        return [
          OTPProviderField(
            key: 'apiKey',
            label: 'API Key',
            description: 'مفتاح API من Vonage Dashboard',
            isRequired: true,
          ),
          OTPProviderField(
            key: 'apiSecret',
            label: 'API Secret',
            description: 'المفتاح السري',
            isRequired: true,
            isSecret: true,
          ),
        ];
      case 'aws_sns':
        return [
          OTPProviderField(
            key: 'accessKeyId',
            label: 'Access Key ID',
            description: 'معرف مفتاح الوصول من AWS IAM',
            isRequired: true,
          ),
          OTPProviderField(
            key: 'secretAccessKey',
            label: 'Secret Access Key',
            description: 'المفتاح السري',
            isRequired: true,
            isSecret: true,
          ),
          OTPProviderField(
            key: 'region',
            label: 'Region',
            description: 'المنطقة (مثل: us-east-1)',
            isRequired: true,
          ),
        ];
      case 'messagebird':
        return [
          OTPProviderField(
            key: 'apiKey',
            label: 'API Key',
            description: 'مفتاح API من MessageBird Dashboard',
            isRequired: true,
            isSecret: true,
          ),
          OTPProviderField(
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
}

/// حقل مزود OTP
class OTPProviderField {
  final String key;
  final String label;
  final String description;
  final bool isRequired;
  final bool isSecret;

  OTPProviderField({
    required this.key,
    required this.label,
    required this.description,
    required this.isRequired,
    this.isSecret = false,
  });
}
