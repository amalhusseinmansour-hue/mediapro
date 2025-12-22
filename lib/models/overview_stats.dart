class OverviewStats {
  final int totalFollowers;
  final int totalPosts;
  final int totalEngagement;
  final int totalReach;
  final double engagementRate;
  final double followersGrowth;
  final String followersGrowthPercentage;

  OverviewStats({
    required this.totalFollowers,
    required this.totalPosts,
    required this.totalEngagement,
    required this.totalReach,
    required this.engagementRate,
    required this.followersGrowth,
    required this.followersGrowthPercentage,
  });

  factory OverviewStats.fromJson(Map<String, dynamic> json) {
    return OverviewStats(
      totalFollowers: json['total_followers'] ?? 0,
      totalPosts: json['total_posts'] ?? 0,
      totalEngagement: json['total_engagement'] ?? 0,
      totalReach: json['total_reach'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0).toDouble(),
      followersGrowth: (json['followers_growth'] ?? 0).toDouble(),
      followersGrowthPercentage: json['followers_growth_percentage'] ?? '0%',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_followers': totalFollowers,
      'total_posts': totalPosts,
      'total_engagement': totalEngagement,
      'total_reach': totalReach,
      'engagement_rate': engagementRate,
      'followers_growth': followersGrowth,
      'followers_growth_percentage': followersGrowthPercentage,
    };
  }

  String get formattedFollowers {
    if (totalFollowers >= 1000000) {
      return '${(totalFollowers / 1000000).toStringAsFixed(1)}M';
    } else if (totalFollowers >= 1000) {
      return '${(totalFollowers / 1000).toStringAsFixed(1)}K';
    }
    return totalFollowers.toString();
  }

  String get formattedReach {
    if (totalReach >= 1000000) {
      return '${(totalReach / 1000000).toStringAsFixed(1)}M';
    } else if (totalReach >= 1000) {
      return '${(totalReach / 1000).toStringAsFixed(1)}K';
    }
    return totalReach.toString();
  }

  String get formattedEngagement {
    if (totalEngagement >= 1000000) {
      return '${(totalEngagement / 1000000).toStringAsFixed(1)}M';
    } else if (totalEngagement >= 1000) {
      return '${(totalEngagement / 1000).toStringAsFixed(1)}K';
    }
    return totalEngagement.toString();
  }

  bool get isGrowing => followersGrowth > 0;
}
