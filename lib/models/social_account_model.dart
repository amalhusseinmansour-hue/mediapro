import 'package:hive/hive.dart';

part 'social_account_model.g.dart';

@HiveType(typeId: 16)
class SocialAccountModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String platform; // instagram, facebook, twitter, linkedin, youtube, tiktok

  @HiveField(3)
  String accountName;

  @HiveField(4)
  String accountId;

  @HiveField(5)
  String? profileImageUrl;

  @HiveField(6)
  String? accessToken;

  @HiveField(7)
  DateTime connectedDate;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  Map<String, dynamic>? platformData; // Additional platform-specific data

  @HiveField(10)
  AccountStats? stats;

  SocialAccountModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.accountName,
    required this.accountId,
    this.profileImageUrl,
    this.accessToken,
    required this.connectedDate,
    this.isActive = true,
    this.platformData,
    this.stats,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'platform': platform,
      'accountName': accountName,
      'accountId': accountId,
      'profileImageUrl': profileImageUrl,
      'accessToken': accessToken,
      'connectedDate': connectedDate.toIso8601String(),
      'isActive': isActive,
      'platformData': platformData,
      'stats': stats?.toJson(),
    };
  }

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    // Handle id - backend sends int, we need String
    final id = json['id']?.toString() ?? '';

    // Handle isActive - backend sends is_active as int (1/0) or bool
    bool isActive = true;
    final isActiveValue = json['is_active'] ?? json['isActive'];
    if (isActiveValue is bool) {
      isActive = isActiveValue;
    } else if (isActiveValue is int) {
      isActive = isActiveValue == 1;
    } else if (isActiveValue != null) {
      isActive = true;
    }

    // Handle connectedDate - backend sends created_at
    DateTime connectedDate = DateTime.now();
    final dateStr = json['created_at'] ?? json['connectedDate'];
    if (dateStr != null && dateStr is String) {
      try {
        connectedDate = DateTime.parse(dateStr);
      } catch (_) {
        connectedDate = DateTime.now();
      }
    }

    return SocialAccountModel(
      id: id,
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      platform: json['platform'] ?? '',
      accountName: json['account_name'] ?? json['accountName'] ?? json['display_name'] ?? json['username'] ?? '',
      accountId: json['account_id'] ?? json['accountId'] ?? json['username'] ?? '',
      profileImageUrl: json['profile_picture'] ?? json['profile_image_url'] ?? json['profileImageUrl'],
      accessToken: json['access_token'] ?? json['accessToken'],
      connectedDate: connectedDate,
      isActive: isActive,
      platformData: json['platform_data'] ?? json['platformData'],
      stats: json['stats'] != null
          ? AccountStats.fromJson(json['stats'])
          : null,
    );
  }

  /// Getter للتحقق من اتصال الحساب
  bool get isConnected =>
      isActive && accessToken != null && accessToken!.isNotEmpty;

  /// Getter للحصول على اسم المستخدم (username)
  String get username => accountName;

  /// Getter للحصول على الاسم الكامل
  String get fullName => accountName;

  /// Getter للحصول على تاريخ الاتصال
  DateTime get connectedAt => connectedDate;
}

@HiveType(typeId: 17)
class AccountStats extends HiveObject {
  @HiveField(0)
  int followers;

  @HiveField(1)
  int following;

  @HiveField(2)
  int postsCount;

  @HiveField(3)
  double engagementRate;

  @HiveField(4)
  DateTime lastUpdated;

  AccountStats({
    this.followers = 0,
    this.following = 0,
    this.postsCount = 0,
    this.engagementRate = 0.0,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'followers': followers,
      'following': following,
      'postsCount': postsCount,
      'engagementRate': engagementRate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AccountStats.fromJson(Map<String, dynamic> json) {
    return AccountStats(
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      engagementRate: (json['engagementRate'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
