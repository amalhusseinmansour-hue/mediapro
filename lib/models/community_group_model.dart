import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج مجموعة المجتمع
class CommunityGroupModel {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final String category;
  final String creatorId;
  final List<String> adminIds;
  final List<String> memberIds;
  final int membersCount;
  final bool isPrivate;
  final bool isPremium;
  final double premiumPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? settings;
  final List<String> tags;
  final String? rules;
  final bool isVerified;
  final int postsCount;
  final int engagementScore;

  CommunityGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.category,
    required this.creatorId,
    this.adminIds = const [],
    this.memberIds = const [],
    this.membersCount = 0,
    this.isPrivate = false,
    this.isPremium = false,
    this.premiumPrice = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.settings,
    this.tags = const [],
    this.rules,
    this.isVerified = false,
    this.postsCount = 0,
    this.engagementScore = 0,
  });

  factory CommunityGroupModel.fromJson(Map<String, dynamic> json) {
    return CommunityGroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'] ?? '',
      category: json['category'] ?? '',
      creatorId: json['creator_id'] ?? '',
      adminIds: (json['admin_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      memberIds: (json['member_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      membersCount: json['members_count'] ?? 0,
      isPrivate: json['is_private'] ?? false,
      isPremium: json['is_premium'] ?? false,
      premiumPrice: (json['premium_price'] ?? 0).toDouble(),
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] is Timestamp
              ? (json['updated_at'] as Timestamp).toDate()
              : DateTime.parse(json['updated_at']))
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rules: json['rules'],
      isVerified: json['is_verified'] ?? false,
      postsCount: json['posts_count'] ?? 0,
      engagementScore: json['engagement_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image': coverImage,
      'category': category,
      'creator_id': creatorId,
      'admin_ids': adminIds,
      'member_ids': memberIds,
      'members_count': membersCount,
      'is_private': isPrivate,
      'is_premium': isPremium,
      'premium_price': premiumPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'settings': settings,
      'tags': tags,
      'rules': rules,
      'is_verified': isVerified,
      'posts_count': postsCount,
      'engagement_score': engagementScore,
    };
  }

  CommunityGroupModel copyWith({
    String? name,
    String? description,
    String? coverImage,
    String? category,
    List<String>? adminIds,
    List<String>? memberIds,
    int? membersCount,
    bool? isPrivate,
    bool? isPremium,
    double? premiumPrice,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
    List<String>? tags,
    String? rules,
    bool? isVerified,
    int? postsCount,
    int? engagementScore,
  }) {
    return CommunityGroupModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      category: category ?? this.category,
      creatorId: creatorId,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      membersCount: membersCount ?? this.membersCount,
      isPrivate: isPrivate ?? this.isPrivate,
      isPremium: isPremium ?? this.isPremium,
      premiumPrice: premiumPrice ?? this.premiumPrice,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      rules: rules ?? this.rules,
      isVerified: isVerified ?? this.isVerified,
      postsCount: postsCount ?? this.postsCount,
      engagementScore: engagementScore ?? this.engagementScore,
    );
  }
}

/// نموذج عضوية المجموعة
class GroupMembershipModel {
  final String id;
  final String userId;
  final String groupId;
  final String role; // member, moderator, admin, owner
  final DateTime joinedAt;
  final bool isActive;
  final int contributionScore;
  final Map<String, dynamic>? permissions;

  GroupMembershipModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
    this.contributionScore = 0,
    this.permissions,
  });

  factory GroupMembershipModel.fromJson(Map<String, dynamic> json) {
    return GroupMembershipModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      groupId: json['group_id'] ?? '',
      role: json['role'] ?? 'member',
      joinedAt: json['joined_at'] is Timestamp
          ? (json['joined_at'] as Timestamp).toDate()
          : DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
      contributionScore: json['contribution_score'] ?? 0,
      permissions: json['permissions'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'is_active': isActive,
      'contribution_score': contributionScore,
      'permissions': permissions,
    };
  }
}
