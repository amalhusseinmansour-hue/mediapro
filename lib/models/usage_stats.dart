class UsageStats {
  final PostsUsage posts;
  final AIRequestsUsage aiRequests;
  final ConnectedAccountsUsage connectedAccounts;

  UsageStats({
    required this.posts,
    required this.aiRequests,
    required this.connectedAccounts,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      posts: PostsUsage.fromJson(json['posts'] ?? {}),
      aiRequests: AIRequestsUsage.fromJson(json['ai_requests'] ?? {}),
      connectedAccounts: ConnectedAccountsUsage.fromJson(json['connected_accounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.toJson(),
      'ai_requests': aiRequests.toJson(),
      'connected_accounts': connectedAccounts.toJson(),
    };
  }
}

class PostsUsage {
  final int current;
  final int limit;
  final bool isUnlimited;
  final double percentage;
  final int remaining;
  final String? resetDate;

  PostsUsage({
    required this.current,
    required this.limit,
    required this.isUnlimited,
    required this.percentage,
    required this.remaining,
    this.resetDate,
  });

  factory PostsUsage.fromJson(Map<String, dynamic> json) {
    return PostsUsage(
      current: json['current'] ?? 0,
      limit: json['limit'] ?? 0,
      isUnlimited: json['is_unlimited'] ?? false,
      percentage: (json['percentage'] ?? 0).toDouble(),
      remaining: json['remaining'] ?? 0,
      resetDate: json['reset_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'limit': limit,
      'is_unlimited': isUnlimited,
      'percentage': percentage,
      'remaining': remaining,
      'reset_date': resetDate,
    };
  }

  bool get isNearLimit => percentage >= 80.0;
  bool get isAtLimit => current >= limit && !isUnlimited;

  String get displayText {
    if (isUnlimited) return 'غير محدود';
    return '$current/$limit';
  }
}

class AIRequestsUsage {
  final int current;
  final int limit;
  final bool isUnlimited;
  final bool isAvailable;
  final double percentage;
  final dynamic remaining; // Can be int or 'unlimited'
  final String? resetDate;

  AIRequestsUsage({
    required this.current,
    required this.limit,
    required this.isUnlimited,
    required this.isAvailable,
    required this.percentage,
    required this.remaining,
    this.resetDate,
  });

  factory AIRequestsUsage.fromJson(Map<String, dynamic> json) {
    return AIRequestsUsage(
      current: json['current'] ?? 0,
      limit: json['limit'] ?? 0,
      isUnlimited: json['is_unlimited'] ?? false,
      isAvailable: json['is_available'] ?? false,
      percentage: (json['percentage'] ?? 0).toDouble(),
      remaining: json['remaining'], // Can be int or 'unlimited'
      resetDate: json['reset_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'limit': limit,
      'is_unlimited': isUnlimited,
      'is_available': isAvailable,
      'percentage': percentage,
      'remaining': remaining,
      'reset_date': resetDate,
    };
  }

  bool get isNearLimit => !isUnlimited && percentage >= 80.0;
  bool get isAtLimit => !isUnlimited && current >= limit;

  String get displayText {
    if (!isAvailable) return 'غير متاح';
    if (isUnlimited) return 'غير محدود';
    return '$current/$limit';
  }
}

class ConnectedAccountsUsage {
  final int current;
  final int limit;
  final double percentage;
  final int remaining;

  ConnectedAccountsUsage({
    required this.current,
    required this.limit,
    required this.percentage,
    required this.remaining,
  });

  factory ConnectedAccountsUsage.fromJson(Map<String, dynamic> json) {
    return ConnectedAccountsUsage(
      current: json['current'] ?? 0,
      limit: json['limit'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      remaining: json['remaining'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'limit': limit,
      'percentage': percentage,
      'remaining': remaining,
    };
  }

  bool get isNearLimit => percentage >= 80.0;
  bool get isAtLimit => current >= limit;

  String get displayText => '$current/$limit';
}
