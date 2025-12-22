class AutoScheduledPost {
  final int id;
  final String userId;
  final String content;
  final List<String> mediaUrls;
  final List<String> platforms;
  final DateTime scheduleTime;
  final String recurrencePattern;
  final int? recurrenceInterval;
  final DateTime? recurrenceEndDate;
  final bool isActive;
  final String status;
  final DateTime? lastPostedAt;
  final DateTime? nextPostAt;
  final int postCount;

  AutoScheduledPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.mediaUrls,
    required this.platforms,
    required this.scheduleTime,
    required this.recurrencePattern,
    this.recurrenceInterval,
    this.recurrenceEndDate,
    required this.isActive,
    required this.status,
    this.lastPostedAt,
    this.nextPostAt,
    required this.postCount,
  });

  factory AutoScheduledPost.fromJson(Map<String, dynamic> json) {
    return AutoScheduledPost(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'] as List)
          : [],
      platforms: json['platforms'] != null
          ? List<String>.from(json['platforms'] as List)
          : [],
      scheduleTime: DateTime.parse(json['schedule_time'] as String),
      recurrencePattern: json['recurrence_pattern'] as String,
      recurrenceInterval: json['recurrence_interval'] as int?,
      recurrenceEndDate: json['recurrence_end_date'] != null
          ? DateTime.parse(json['recurrence_end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      lastPostedAt: json['last_posted_at'] != null
          ? DateTime.parse(json['last_posted_at'] as String)
          : null,
      nextPostAt: json['next_post_at'] != null
          ? DateTime.parse(json['next_post_at'] as String)
          : null,
      postCount: json['post_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'media_urls': mediaUrls,
      'platforms': platforms,
      'schedule_time': scheduleTime.toIso8601String(),
      'recurrence_pattern': recurrencePattern,
      'recurrence_interval': recurrenceInterval,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isPending => status == 'pending';
  bool get isStatusActive => status == 'active';  // Changed from isActive to avoid conflict
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'active':
        return 'نشط';
      case 'paused':
        return 'متوقف مؤقتاً';
      case 'completed':
        return 'مكتمل';
      case 'failed':
        return 'فشل';
      default:
        return status;
    }
  }

  String get recurrencePatternText {
    switch (recurrencePattern) {
      case 'once':
        return 'مرة واحدة';
      case 'daily':
        return 'يومي';
      case 'weekly':
        return 'أسبوعي';
      case 'monthly':
        return 'شهري';
      case 'custom':
        return 'مخصص';
      default:
        return recurrencePattern;
    }
  }

  String get platformsText {
    if (platforms.isEmpty) return 'لا توجد منصات';
    return platforms.join(', ');
  }
}
