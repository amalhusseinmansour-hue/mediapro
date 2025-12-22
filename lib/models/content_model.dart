class ContentModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String contentType; // 'Image Post', 'Video Post', 'Story', etc.
  final List<String> mediaUrls;
  final List<String> targetPlatforms;
  final List<String> targetAccountIds;
  final DateTime? scheduledDate;
  final ContentStatus status;
  final DateTime createdDate;
  final DateTime? publishedDate;
  final Map<String, dynamic>? aiMetadata; // For AI-generated content info
  final Map<String, dynamic>? analytics;

  ContentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.contentType,
    this.mediaUrls = const [],
    this.targetPlatforms = const [],
    this.targetAccountIds = const [],
    this.scheduledDate,
    required this.status,
    required this.createdDate,
    this.publishedDate,
    this.aiMetadata,
    this.analytics,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      contentType: json['contentType'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      targetPlatforms: List<String>.from(json['targetPlatforms'] ?? []),
      targetAccountIds: List<String>.from(json['targetAccountIds'] ?? []),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      status: ContentStatus.values.firstWhere(
        (e) => e.toString() == 'ContentStatus.${json['status']}',
        orElse: () => ContentStatus.draft,
      ),
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      publishedDate: json['publishedDate'] != null
          ? DateTime.parse(json['publishedDate'])
          : null,
      aiMetadata: json['aiMetadata'],
      analytics: json['analytics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'contentType': contentType,
      'mediaUrls': mediaUrls,
      'targetPlatforms': targetPlatforms,
      'targetAccountIds': targetAccountIds,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'createdDate': createdDate.toIso8601String(),
      'publishedDate': publishedDate?.toIso8601String(),
      'aiMetadata': aiMetadata,
      'analytics': analytics,
    };
  }
}

enum ContentStatus {
  draft,
  scheduled,
  published,
  failed,
}
