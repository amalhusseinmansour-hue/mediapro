class Subscription {
  final SubscriptionTier tier;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int postsPerMonth;
  final int scheduledPostsLimit;
  final int platformsLimit;
  final bool hasAdvancedAnalytics;
  final bool hasAITools;
  final bool hasTeamCollaboration;
  final bool hasPrioritySupport;
  final bool hasWhiteLabel;
  final bool hasCustomBranding;

  Subscription({
    required this.tier,
    this.startDate,
    this.endDate,
    this.isActive = false,
    required this.postsPerMonth,
    required this.scheduledPostsLimit,
    required this.platformsLimit,
    required this.hasAdvancedAnalytics,
    required this.hasAITools,
    required this.hasTeamCollaboration,
    required this.hasPrioritySupport,
    required this.hasWhiteLabel,
    required this.hasCustomBranding,
  });

  // Factory للحساب المجاني (الفردي)
  factory Subscription.free() {
    return Subscription(
      tier: SubscriptionTier.individual,
      isActive: true,
      postsPerMonth: 10,
      scheduledPostsLimit: 5,
      platformsLimit: 2,
      hasAdvancedAnalytics: false,
      hasAITools: false,
      hasTeamCollaboration: false,
      hasPrioritySupport: false,
      hasWhiteLabel: false,
      hasCustomBranding: false,
    );
  }

  // Factory لحساب الشركات
  factory Subscription.business({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return Subscription(
      tier: SubscriptionTier.business,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
      postsPerMonth: 999999, // غير محدود
      scheduledPostsLimit: 999999,
      platformsLimit: 999999,
      hasAdvancedAnalytics: true,
      hasAITools: true,
      hasTeamCollaboration: true,
      hasPrioritySupport: true,
      hasWhiteLabel: true,
      hasCustomBranding: true,
    );
  }

  // Factory لحساب Pro (وسط)
  factory Subscription.pro({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return Subscription(
      tier: SubscriptionTier.pro,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
      postsPerMonth: 100,
      scheduledPostsLimit: 50,
      platformsLimit: 5,
      hasAdvancedAnalytics: true,
      hasAITools: true,
      hasTeamCollaboration: false,
      hasPrioritySupport: false,
      hasWhiteLabel: false,
      hasCustomBranding: false,
    );
  }

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  int get daysRemaining {
    if (endDate == null) return 0;
    final difference = endDate!.difference(DateTime.now());
    return difference.inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier.toString(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'postsPerMonth': postsPerMonth,
      'scheduledPostsLimit': scheduledPostsLimit,
      'platformsLimit': platformsLimit,
      'hasAdvancedAnalytics': hasAdvancedAnalytics,
      'hasAITools': hasAITools,
      'hasTeamCollaboration': hasTeamCollaboration,
      'hasPrioritySupport': hasPrioritySupport,
      'hasWhiteLabel': hasWhiteLabel,
      'hasCustomBranding': hasCustomBranding,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      tier: _parseTier(json['tier']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? false,
      postsPerMonth: json['postsPerMonth'] ?? 10,
      scheduledPostsLimit: json['scheduledPostsLimit'] ?? 5,
      platformsLimit: json['platformsLimit'] ?? 2,
      hasAdvancedAnalytics: json['hasAdvancedAnalytics'] ?? false,
      hasAITools: json['hasAITools'] ?? false,
      hasTeamCollaboration: json['hasTeamCollaboration'] ?? false,
      hasPrioritySupport: json['hasPrioritySupport'] ?? false,
      hasWhiteLabel: json['hasWhiteLabel'] ?? false,
      hasCustomBranding: json['hasCustomBranding'] ?? false,
    );
  }

  static SubscriptionTier _parseTier(String? value) {
    switch (value) {
      case 'SubscriptionTier.individual':
        return SubscriptionTier.individual;
      case 'SubscriptionTier.pro':
        return SubscriptionTier.pro;
      case 'SubscriptionTier.business':
        return SubscriptionTier.business;
      default:
        return SubscriptionTier.individual;
    }
  }
}

enum SubscriptionTier {
  individual, // مجاني للأفراد
  pro,        // احترافي
  business,   // للشركات
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get arabicName {
    switch (this) {
      case SubscriptionTier.individual:
        return 'فردي';
      case SubscriptionTier.pro:
        return 'احترافي';
      case SubscriptionTier.business:
        return 'للشركات';
    }
  }

  String get englishName {
    switch (this) {
      case SubscriptionTier.individual:
        return 'Individual';
      case SubscriptionTier.pro:
        return 'Professional';
      case SubscriptionTier.business:
        return 'Business';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.individual:
        return 'للاستخدام الشخصي المحدود';
      case SubscriptionTier.pro:
        return 'للمحترفين وصناع المحتوى';
      case SubscriptionTier.business:
        return 'للشركات والفرق الكبيرة';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.individual:
        return 0.0;
      case SubscriptionTier.pro:
        return 29.99;
      case SubscriptionTier.business:
        return 99.99;
    }
  }

  double get yearlyPrice {
    switch (this) {
      case SubscriptionTier.individual:
        return 0.0;
      case SubscriptionTier.pro:
        return 299.99; // خصم 2 شهر
      case SubscriptionTier.business:
        return 999.99; // خصم 2 شهر
    }
  }

  String get icon {
    switch (this) {
      case SubscriptionTier.individual:
        return '👤';
      case SubscriptionTier.pro:
        return '⭐';
      case SubscriptionTier.business:
        return '🏢';
    }
  }
}
