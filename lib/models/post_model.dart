import 'package:hive/hive.dart';

part 'post_model.g.dart';

@HiveType(typeId: 6)
class PostModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  List<String> imageUrls;

  @HiveField(3)
  List<String> platforms; // instagram, facebook, twitter, etc.

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? publishedAt;

  @HiveField(6)
  PostStatus status;

  @HiveField(7)
  Map<String, dynamic>? analytics; // likes, comments, shares per platform

  @HiveField(8)
  List<String> hashtags;

  @HiveField(9)
  bool isScheduled;

  @HiveField(10)
  DateTime? scheduledTime;

  PostModel({
    required this.id,
    required this.content,
    this.imageUrls = const [],
    this.platforms = const [],
    required this.createdAt,
    this.publishedAt,
    this.status = PostStatus.draft,
    this.analytics,
    this.hashtags = const [],
    this.isScheduled = false,
    this.scheduledTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'imageUrls': imageUrls,
      'platforms': platforms,
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'status': status.index,
      'analytics': analytics,
      'hashtags': hashtags,
      'isScheduled': isScheduled,
      'scheduledTime': scheduledTime?.toIso8601String(),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      platforms: List<String>.from(json['platforms'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      status: PostStatus.values[json['status']],
      analytics: json['analytics'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      isScheduled: json['isScheduled'] ?? false,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
    );
  }
}

@HiveType(typeId: 7)
enum PostStatus {
  @HiveField(0)
  draft, // مسودة

  @HiveField(1)
  scheduled, // مجدولة

  @HiveField(2)
  published, // منشورة

  @HiveField(3)
  failed, // فشلت
}
