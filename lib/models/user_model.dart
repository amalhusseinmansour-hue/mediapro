import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 24)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final String subscriptionType; // 'individual' or 'business'

  @HiveField(5)
  final DateTime subscriptionStartDate;

  @HiveField(6)
  final DateTime? subscriptionEndDate;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final String phoneNumber;

  @HiveField(9)
  final bool isLoggedIn;

  @HiveField(10)
  final DateTime? lastLogin;

  @HiveField(11)
  String subscriptionTier; // 'free', 'individual', 'team', 'enterprise'

  @HiveField(12)
  final String userType; // 'individual' or 'business'

  @HiveField(13)
  final bool isPhoneVerified; // Phone verification status

  @HiveField(14)
  final bool isAdmin; // Admin permissions for managing sponsored ads

  @HiveField(15)
  final DateTime createdAt;

  // Business Documents (للشركات فقط)
  @HiveField(16)
  final String? commercialRegistration; // صورة السجل التجاري

  @HiveField(17)
  final String? tradeLicense; // صورة الرخصة التجارية

  @HiveField(18)
  final String? companyName; // اسم الشركة

  @HiveField(19)
  final String businessVerificationStatus; // 'pending', 'approved', 'rejected'

  @HiveField(20)
  final String? verificationRejectionReason; // سبب الرفض إن وجد

  // Account Activation (يتم من Filament Admin Panel)
  @HiveField(21)
  final String accountStatus; // 'pending', 'active', 'suspended', 'rejected'

  @HiveField(22)
  final String? accountRejectionReason; // سبب رفض أو تعليق الحساب

  @HiveField(23)
  final DateTime? accountActivatedAt; // تاريخ تفعيل الحساب

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.subscriptionType,
    required this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isActive = true,
    required this.phoneNumber,
    this.isLoggedIn = false,
    this.lastLogin,
    this.subscriptionTier = 'free',
    this.userType = 'individual',
    this.isPhoneVerified = false,
    this.isAdmin = false,
    DateTime? createdAt,
    this.commercialRegistration,
    this.tradeLicense,
    this.companyName,
    this.businessVerificationStatus = 'none', // 'none', 'pending', 'approved', 'rejected'
    this.verificationRejectionReason,
    this.accountStatus = 'pending', // 'pending', 'active', 'suspended', 'rejected'
    this.accountRejectionReason,
    this.accountActivatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      subscriptionType: json['subscriptionType'] ?? 'individual',
      subscriptionStartDate: json['subscriptionStartDate'] != null
          ? DateTime.parse(json['subscriptionStartDate'])
          : DateTime.now(),
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.parse(json['subscriptionEndDate'])
          : null,
      isActive: json['isActive'] ?? true,
      phoneNumber: json['phoneNumber'] ?? '',
      isLoggedIn: json['isLoggedIn'] ?? false,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      subscriptionTier: json['subscriptionTier'] ?? 'free',
      userType: json['userType'] ?? 'individual',
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      commercialRegistration: json['commercialRegistration'] ?? json['commercial_registration'],
      tradeLicense: json['tradeLicense'] ?? json['trade_license'],
      companyName: json['companyName'] ?? json['company_name'],
      businessVerificationStatus: json['businessVerificationStatus'] ?? json['business_verification_status'] ?? 'none',
      verificationRejectionReason: json['verificationRejectionReason'] ?? json['verification_rejection_reason'],
      accountStatus: json['accountStatus'] ?? json['account_status'] ?? 'pending',
      accountRejectionReason: json['accountRejectionReason'] ?? json['account_rejection_reason'],
      accountActivatedAt: json['accountActivatedAt'] != null
          ? DateTime.parse(json['accountActivatedAt'])
          : (json['account_activated_at'] != null
              ? DateTime.parse(json['account_activated_at'])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'subscriptionType': subscriptionType,
      'subscriptionStartDate': subscriptionStartDate.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'isLoggedIn': isLoggedIn,
      'lastLogin': lastLogin?.toIso8601String(),
      'subscriptionTier': subscriptionTier,
      'userType': userType,
      'isPhoneVerified': isPhoneVerified,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'commercialRegistration': commercialRegistration,
      'tradeLicense': tradeLicense,
      'companyName': companyName,
      'businessVerificationStatus': businessVerificationStatus,
      'verificationRejectionReason': verificationRejectionReason,
      'accountStatus': accountStatus,
      'accountRejectionReason': accountRejectionReason,
      'accountActivatedAt': accountActivatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? subscriptionType,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isActive,
    String? phoneNumber,
    bool? isLoggedIn,
    DateTime? lastLogin,
    String? subscriptionTier,
    String? userType,
    bool? isPhoneVerified,
    bool? isAdmin,
    DateTime? createdAt,
    String? commercialRegistration,
    String? tradeLicense,
    String? companyName,
    String? businessVerificationStatus,
    String? verificationRejectionReason,
    String? accountStatus,
    String? accountRejectionReason,
    DateTime? accountActivatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      lastLogin: lastLogin ?? this.lastLogin,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      userType: userType ?? this.userType,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      commercialRegistration: commercialRegistration ?? this.commercialRegistration,
      tradeLicense: tradeLicense ?? this.tradeLicense,
      companyName: companyName ?? this.companyName,
      businessVerificationStatus: businessVerificationStatus ?? this.businessVerificationStatus,
      verificationRejectionReason: verificationRejectionReason ?? this.verificationRejectionReason,
      accountStatus: accountStatus ?? this.accountStatus,
      accountRejectionReason: accountRejectionReason ?? this.accountRejectionReason,
      accountActivatedAt: accountActivatedAt ?? this.accountActivatedAt,
    );
  }

  bool get isIndividual => subscriptionType == 'individual';
  bool get isBusiness => subscriptionType == 'business';

  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return isActive;
    return isActive && DateTime.now().isBefore(subscriptionEndDate!);
  }

  // Subscription tier getters - باقتين فقط
  bool get isFree => subscriptionTier == 'free';
  bool get isIndividualTier => subscriptionTier == 'individual'; // باقة 129 جنيه
  bool get isBusinessTier => subscriptionTier == 'business'; // باقة 179 جنيه

  // For backward compatibility
  bool get isTeamTier => subscriptionTier == 'business';
  bool get isEnterpriseTier => subscriptionTier == 'business';

  // Feature limits based on subscription tier
  int get maxAccounts {
    switch (subscriptionTier) {
      case 'free':
        return 1; // حساب واحد
      case 'individual':
        return 3; // 3 حسابات للأفراد (129 جنيه)
      case 'business':
        return 10; // 10 حسابات للشركات (179 جنيه)
      default:
        return 1;
    }
  }

  int get maxPostsPerMonth {
    switch (subscriptionTier) {
      case 'free':
        return 10; // 10 منشورات مجاناً
      case 'individual':
        return 100; // 100 منشور للأفراد (129 جنيه)
      case 'business':
        return 999999; // منشورات غير محدودة للشركات (179 جنيه)
      default:
        return 10;
    }
  }

  int get maxAIRequestsPerMonth {
    switch (subscriptionTier) {
      case 'free':
        return 0; // بدون ذكاء اصطناعي
      case 'individual':
        return 100; // 100 طلب AI للأفراد (129 جنيه)
      case 'business':
        return 999999; // طلبات AI غير محدودة للشركات (179 جنيه)
      default:
        return 0;
    }
  }

  // Telegram bot limits
  int get maxTelegramBots {
    switch (subscriptionTier) {
      case 'free':
        return 0; // بدون بوتات تليجرام
      case 'individual':
        return 1; // بوت واحد للأفراد (129 جنيه)
      case 'business':
        return 3; // 3 بوتات للشركات (179 جنيه)
      default:
        return 0;
    }
  }

  // Automation (N8N Workflows) limits
  int get maxAutomationWorkflows {
    switch (subscriptionTier) {
      case 'free':
        return 0; // بدون أتمتة
      case 'individual':
        return 5; // 5 workflows للأفراد (129 جنيه)
      case 'business':
        return 999999; // workflows غير محدودة للشركات (179 جنيه)
      default:
        return 0;
    }
  }

  // Feature availability
  bool get canUseAI => !isFree; // متاح للباقتين المدفوعتين
  bool get canUseAnalytics => !isFree; // متاح للباقتين المدفوعتين
  bool get canUseAdvancedScheduling => !isFree; // متاح للباقتين المدفوعتين
  bool get canUseTelegram => !isFree; // ربط تليجرام للباقتين المدفوعتين
  bool get canUseAutomation => !isFree; // الأتمتة للباقتين المدفوعتين
  bool get canUseTeamCollaboration => isBusinessTier; // متاح فقط للشركات
  bool get hasPrioritySupport => isBusinessTier; // دعم أولوية للشركات فقط
  bool get hasAPIAccess => isBusinessTier; // API للشركات فقط
  bool get hasWhiteLabel => isBusinessTier; // علامة بيضاء للشركات فقط
  bool get hasCustomBranding => isBusinessTier; // علامة تجارية مخصصة للشركات فقط
  bool get canExportReports => !isFree; // تصدير التقارير للباقتين المدفوعتين
  bool get canAutoPost => !isFree; // نشر تلقائي للباقتين المدفوعتين
  bool get canUseTrendAnalysis => !isFree; // تحليل الاتجاهات للباقتين المدفوعتين
  bool get canUseHashtagGenerator => !isFree; // مولد الهاشتاج للباقتين المدفوعتين

  String get tierDisplayName {
    switch (subscriptionTier) {
      case 'free':
        return 'مجانية';
      case 'individual':
        return 'باقة الأفراد'; // 129 جنيه
      case 'business':
        return 'باقة الشركات'; // 179 جنيه
      default:
        return 'مجانية';
    }
  }

  // Business verification getters
  bool get isBusinessVerified => businessVerificationStatus == 'approved';
  bool get isBusinessPending => businessVerificationStatus == 'pending';
  bool get isBusinessRejected => businessVerificationStatus == 'rejected';
  bool get needsBusinessVerification => isBusiness && businessVerificationStatus == 'none';
  bool get hasBusinessDocuments => commercialRegistration != null && tradeLicense != null;

  String get verificationStatusDisplayName {
    switch (businessVerificationStatus) {
      case 'none':
        return 'لم يتم التقديم';
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'مُفعَّل';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  // Account Status getters (يتم التحكم بها من Filament Admin Panel)
  bool get isAccountActive => accountStatus == 'active';
  bool get isAccountPending => accountStatus == 'pending';
  bool get isAccountSuspended => accountStatus == 'suspended';
  bool get isAccountRejected => accountStatus == 'rejected';

  /// هل الحساب مفعل بالكامل؟
  /// - للأفراد: يجب أن يكون الحساب active
  /// - للشركات: يجب أن يكون الحساب active + التحقق من المستندات approved
  bool get isFullyActivated {
    if (!isAccountActive) return false;
    if (isBusiness && !isBusinessVerified) return false;
    return true;
  }

  String get accountStatusDisplayName {
    switch (accountStatus) {
      case 'pending':
        return 'قيد المراجعة';
      case 'active':
        return 'مُفعَّل';
      case 'suspended':
        return 'موقوف';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  /// رسالة حالة الحساب للعرض
  String get accountStatusMessage {
    if (isAccountPending) {
      if (isBusiness) {
        if (businessVerificationStatus == 'none') {
          return 'يرجى رفع المستندات التجارية لتفعيل حسابك';
        } else if (isBusinessPending) {
          return 'جاري مراجعة حسابك ومستنداتك من قبل الإدارة';
        }
      }
      return 'جاري مراجعة حسابك من قبل الإدارة';
    } else if (isAccountSuspended) {
      return accountRejectionReason ?? 'تم تعليق حسابك. تواصل مع الدعم للمزيد من المعلومات';
    } else if (isAccountRejected) {
      return accountRejectionReason ?? 'تم رفض حسابك. تواصل مع الدعم للمزيد من المعلومات';
    } else if (isAccountActive) {
      if (isBusiness && !isBusinessVerified) {
        if (businessVerificationStatus == 'none') {
          return 'حسابك مفعل. يرجى رفع المستندات التجارية للاستفادة من مميزات الشركات';
        } else if (isBusinessPending) {
          return 'حسابك مفعل. جاري مراجعة المستندات التجارية';
        } else if (isBusinessRejected) {
          return 'حسابك مفعل. تم رفض المستندات: ${verificationRejectionReason ?? "يرجى إعادة الرفع"}';
        }
      }
      return 'حسابك مفعل ويعمل بشكل طبيعي';
    }
    return '';
  }
}
