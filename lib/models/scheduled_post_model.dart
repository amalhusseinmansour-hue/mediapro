import 'package:hive/hive.dart';

part 'scheduled_post_model.g.dart';

@HiveType(typeId: 50)
class ScheduledPost extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final List<String> platforms; // ['facebook', 'instagram', 'twitter', etc.]

  @HiveField(4)
  final DateTime scheduledTime;

  @HiveField(5)
  final String status; // 'pending', 'publishing', 'published', 'failed'

  @HiveField(6)
  final List<String>? mediaUrls;

  @HiveField(7)
  final Map<String, dynamic>? platformSettings; // خيارات خاصة لكل منصة

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? publishedAt;

  @HiveField(10)
  final String? errorMessage;

  @HiveField(11)
  final Map<String, String>? platformPostIds; // معرفات المنشورات على كل منصة

  @HiveField(12)
  final bool useN8n; // هل سيتم استخدام n8n للنشر

  @HiveField(13)
  final String? n8nWorkflowId; // معرف workflow في n8n

  @HiveField(14)
  final String? n8nExecutionId; // معرف التنفيذ في n8n

  ScheduledPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.platforms,
    required this.scheduledTime,
    required this.status,
    this.mediaUrls,
    this.platformSettings,
    required this.createdAt,
    this.publishedAt,
    this.errorMessage,
    this.platformPostIds,
    this.useN8n = false,
    this.n8nWorkflowId,
    this.n8nExecutionId,
  });

  // تحويل من JSON
  factory ScheduledPost.fromJson(Map<String, dynamic> json) {
    return ScheduledPost(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      platforms: json['platforms'] != null
          ? List<String>.from(json['platforms'])
          : [],
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'])
          : null,
      platformSettings: json['platform_settings'] != null
          ? Map<String, dynamic>.from(json['platform_settings'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      errorMessage: json['error_message'],
      platformPostIds: json['platform_post_ids'] != null
          ? Map<String, String>.from(json['platform_post_ids'])
          : null,
      useN8n: json['use_n8n'] ?? false,
      n8nWorkflowId: json['n8n_workflow_id'],
      n8nExecutionId: json['n8n_execution_id'],
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'platforms': platforms,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status,
      'media_urls': mediaUrls,
      'platform_settings': platformSettings,
      'created_at': createdAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'error_message': errorMessage,
      'platform_post_ids': platformPostIds,
      'use_n8n': useN8n,
      'n8n_workflow_id': n8nWorkflowId,
      'n8n_execution_id': n8nExecutionId,
    };
  }

  // نسخ مع تعديل
  ScheduledPost copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? platforms,
    DateTime? scheduledTime,
    String? status,
    List<String>? mediaUrls,
    Map<String, dynamic>? platformSettings,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? errorMessage,
    Map<String, String>? platformPostIds,
    bool? useN8n,
    String? n8nWorkflowId,
    String? n8nExecutionId,
  }) {
    return ScheduledPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      platforms: platforms ?? this.platforms,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      platformSettings: platformSettings ?? this.platformSettings,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      platformPostIds: platformPostIds ?? this.platformPostIds,
      useN8n: useN8n ?? this.useN8n,
      n8nWorkflowId: n8nWorkflowId ?? this.n8nWorkflowId,
      n8nExecutionId: n8nExecutionId ?? this.n8nExecutionId,
    );
  }

  // التحقق من ما إذا كان الوقت قد حان للنشر
  bool get isReadyToPublish {
    return status == 'pending' && DateTime.now().isAfter(scheduledTime);
  }

  // الحصول على الوقت المتبقي للنشر
  Duration get timeUntilPublish {
    return scheduledTime.difference(DateTime.now());
  }

  // التحقق من ما إذا كان قد تم النشر بنجاح
  bool get isPublished {
    return status == 'published';
  }

  // التحقق من ما إذا كانت هناك أخطاء
  bool get hasFailed {
    return status == 'failed';
  }
}
