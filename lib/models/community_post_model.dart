/// نموذج بيانات بوست من المجتمع
class CommunityPostModel {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final List<String> images;
  final String platform;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final List<String> hashtags;
  final bool isVerified;
  final String? category;

  CommunityPostModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    this.images = const [],
    required this.platform,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.createdAt,
    this.hashtags = const [],
    this.isVerified = false,
    this.category,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'].toString(),
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'] ?? '',
      content: json['content'] ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      platform: json['platform'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      hashtags: (json['hashtags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isVerified: json['is_verified'] ?? false,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'content': content,
      'images': images,
      'platform': platform,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'created_at': createdAt.toIso8601String(),
      'hashtags': hashtags,
      'is_verified': isVerified,
      'category': category,
    };
  }
}

/// نموذج بيانات الترند
class TrendingTopicModel {
  final String id;
  final String title;
  final String hashtag;
  final int postsCount;
  final String category;
  final String? description;
  final double trendingScore;
  final List<String> relatedHashtags;
  final List<ContentIdeaModel> contentIdeas;
  final String? iconEmoji;
  final String? trendingReason;

  TrendingTopicModel({
    required this.id,
    required this.title,
    required this.hashtag,
    required this.postsCount,
    required this.category,
    this.description,
    required this.trendingScore,
    this.relatedHashtags = const [],
    this.contentIdeas = const [],
    this.iconEmoji,
    this.trendingReason,
  });

  factory TrendingTopicModel.fromJson(Map<String, dynamic> json) {
    return TrendingTopicModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      hashtag: json['hashtag'] ?? '',
      postsCount: json['posts_count'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'],
      trendingScore: (json['trending_score'] ?? 0).toDouble(),
      relatedHashtags: (json['related_hashtags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      contentIdeas: (json['content_ideas'] as List<dynamic>?)?.map((e) => ContentIdeaModel.fromJson(e)).toList() ?? [],
      iconEmoji: json['icon_emoji'],
      trendingReason: json['trending_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hashtag': hashtag,
      'posts_count': postsCount,
      'category': category,
      'description': description,
      'trending_score': trendingScore,
      'related_hashtags': relatedHashtags,
      'content_ideas': contentIdeas.map((e) => e.toJson()).toList(),
      'icon_emoji': iconEmoji,
      'trending_reason': trendingReason,
    };
  }
}

/// نموذج بيانات فكرة المحتوى
class ContentIdeaModel {
  final String id;
  final String title;
  final String description;
  final List<String> suggestedPlatforms;
  final String contentType;
  final int estimatedEngagement;
  final String? exampleText;

  ContentIdeaModel({
    required this.id,
    required this.title,
    required this.description,
    this.suggestedPlatforms = const [],
    required this.contentType,
    this.estimatedEngagement = 0,
    this.exampleText,
  });

  factory ContentIdeaModel.fromJson(Map<String, dynamic> json) {
    return ContentIdeaModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      suggestedPlatforms: (json['suggested_platforms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      contentType: json['content_type'] ?? '',
      estimatedEngagement: json['estimated_engagement'] ?? 0,
      exampleText: json['example_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'suggested_platforms': suggestedPlatforms,
      'content_type': contentType,
      'estimated_engagement': estimatedEngagement,
      'example_text': exampleText,
    };
  }
}
