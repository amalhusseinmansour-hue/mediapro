/// نموذج خطة الاشتراك
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final int maxAccounts;
  final int maxPostsPerMonth;
  final int maxAIRequests;
  final bool hasAdvancedScheduling;
  final bool hasAnalytics;
  final bool hasTeamCollaboration;
  final bool hasExportReports;
  final bool hasPrioritySupport;
  final bool hasCustomBranding;
  final bool hasAPI;
  final List<String> features;
  final List<String> featuresAr;
  final String tier; // 'free', 'individual', 'business', 'enterprise'
  final String audienceType; // 'individual' أو 'business'
  final bool isPopular;
  final String? badge;
  final String? badgeAr;
  final int order; // للترتيب
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.maxAccounts,
    required this.maxPostsPerMonth,
    required this.maxAIRequests,
    required this.hasAdvancedScheduling,
    required this.hasAnalytics,
    required this.hasTeamCollaboration,
    required this.hasExportReports,
    required this.hasPrioritySupport,
    required this.hasCustomBranding,
    required this.hasAPI,
    required this.features,
    required this.featuresAr,
    required this.tier,
    this.audienceType = 'individual', // القيمة الافتراضية
    this.isPopular = false,
    this.badge,
    this.badgeAr,
    this.order = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // من JSON
  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    // Laravel يُرجع 'price' فقط، نحتاج لتحويله إلى monthly/yearly
    final basePrice = _toDouble(json['price'] ?? json['monthly_price']);
    final calculatedYearlyPrice = _toDouble(json['yearly_price']) != 0.0
        ? _toDouble(json['yearly_price'])
        : basePrice * 10; // تقدير: 10 أشهر سعر عند الدفع سنوياً

    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? json['description'] as String? ?? '',
      monthlyPrice: basePrice,
      yearlyPrice: calculatedYearlyPrice,
      currency: json['currency'] as String? ?? 'AED',
      maxAccounts: _toInt(json['max_accounts']) != 0 ? _toInt(json['max_accounts']) : 3,
      maxPostsPerMonth: _toInt(json['max_posts_per_month']) != 0 ? _toInt(json['max_posts_per_month']) : 100,
      maxAIRequests: _toInt(json['max_ai_requests']),
      hasAdvancedScheduling: _toBool(json['has_advanced_scheduling'] ?? json['scheduling']),
      hasAnalytics: _toBool(json['has_analytics'] ?? json['analytics']),
      hasTeamCollaboration: _toBool(json['has_team_collaboration']),
      hasExportReports: _toBool(json['has_export_reports']),
      hasPrioritySupport: _toBool(json['has_priority_support']),
      hasCustomBranding: _toBool(json['has_custom_branding']),
      hasAPI: _toBool(json['has_api'] ?? json['api_features']),
      features: _toStringList(json['features']),
      featuresAr: _toStringList(json['features_ar'] ?? json['features']),
      tier: json['tier'] as String? ?? 'individual',
      audienceType: json['audience_type'] as String? ?? 'individual',
      isPopular: _toBool(json['is_popular']),
      badge: json['badge'] as String?,
      badgeAr: json['badge_ar'] as String? ?? json['badge'] as String?,
      order: _toInt(json['order']) != 0 ? _toInt(json['order']) : _toInt(json['id']),
      isActive: _toBool(json['is_active'] ?? json['status'] == 'active', defaultValue: true),
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  // إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'description_ar': descriptionAr,
      'monthly_price': monthlyPrice,
      'yearly_price': yearlyPrice,
      'currency': currency,
      'max_accounts': maxAccounts,
      'max_posts_per_month': maxPostsPerMonth,
      'max_ai_requests': maxAIRequests,
      'has_advanced_scheduling': hasAdvancedScheduling,
      'has_analytics': hasAnalytics,
      'has_team_collaboration': hasTeamCollaboration,
      'has_export_reports': hasExportReports,
      'has_priority_support': hasPrioritySupport,
      'has_custom_branding': hasCustomBranding,
      'has_api': hasAPI,
      'features': features,
      'features_ar': featuresAr,
      'tier': tier,
      'audience_type': audienceType,
      'is_popular': isPopular,
      'badge': badge,
      'badge_ar': badgeAr,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods للتحويل الآمن
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      // إذا كانت JSON string
      try {
        final decoded = value.replaceAll('\\', '').replaceAll('[', '').replaceAll(']', '');
        return decoded.split(',').map((e) => e.trim().replaceAll('"', '')).toList();
      } catch (e) {
        return [value];
      }
    }
    return [];
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // حساب السعر حسب المدة
  double getPrice({bool isYearly = false}) {
    return isYearly ? yearlyPrice : monthlyPrice;
  }

  // السعر الشهري للسنوي (مع الخصم)
  double getMonthlyPriceIfYearly() {
    return yearlyPrice / 12;
  }

  // نسبة الخصم
  double getYearlyDiscountPercentage() {
    if (monthlyPrice == 0) return 0;
    final yearlyMonthly = yearlyPrice / 12;
    return ((monthlyPrice - yearlyMonthly) / monthlyPrice * 100);
  }

  // نسخ مع تعديلات
  SubscriptionPlanModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? monthlyPrice,
    double? yearlyPrice,
    String? currency,
    int? maxAccounts,
    int? maxPostsPerMonth,
    int? maxAIRequests,
    bool? hasAdvancedScheduling,
    bool? hasAnalytics,
    bool? hasTeamCollaboration,
    bool? hasExportReports,
    bool? hasPrioritySupport,
    bool? hasCustomBranding,
    bool? hasAPI,
    List<String>? features,
    List<String>? featuresAr,
    String? tier,
    String? audienceType,
    bool? isPopular,
    String? badge,
    String? badgeAr,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      currency: currency ?? this.currency,
      maxAccounts: maxAccounts ?? this.maxAccounts,
      maxPostsPerMonth: maxPostsPerMonth ?? this.maxPostsPerMonth,
      maxAIRequests: maxAIRequests ?? this.maxAIRequests,
      hasAdvancedScheduling: hasAdvancedScheduling ?? this.hasAdvancedScheduling,
      hasAnalytics: hasAnalytics ?? this.hasAnalytics,
      hasTeamCollaboration: hasTeamCollaboration ?? this.hasTeamCollaboration,
      hasExportReports: hasExportReports ?? this.hasExportReports,
      hasPrioritySupport: hasPrioritySupport ?? this.hasPrioritySupport,
      hasCustomBranding: hasCustomBranding ?? this.hasCustomBranding,
      hasAPI: hasAPI ?? this.hasAPI,
      features: features ?? this.features,
      featuresAr: featuresAr ?? this.featuresAr,
      tier: tier ?? this.tier,
      audienceType: audienceType ?? this.audienceType,
      isPopular: isPopular ?? this.isPopular,
      badge: badge ?? this.badge,
      badgeAr: badgeAr ?? this.badgeAr,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
