class GeneratedContent {
  final String id;
  final String topic;
  final String generatedText;
  final DateTime createdAt;
  final ContentType contentType;
  final Platform platform;
  final String language;
  final String tone;
  final int length;
  final List<String> hashtags;
  final String? emoji;
  final bool isFavorite;

  GeneratedContent({
    required this.id,
    required this.topic,
    required this.generatedText,
    required this.createdAt,
    this.contentType = ContentType.post,
    this.platform = Platform.instagram,
    this.language = 'ar',
    this.tone = 'professional',
    this.length = 150,
    this.hashtags = const [],
    this.emoji,
    this.isFavorite = false,
  });

  GeneratedContent copyWith({
    String? id,
    String? topic,
    String? generatedText,
    DateTime? createdAt,
    ContentType? contentType,
    Platform? platform,
    String? language,
    String? tone,
    int? length,
    List<String>? hashtags,
    String? emoji,
    bool? isFavorite,
  }) {
    return GeneratedContent(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      generatedText: generatedText ?? this.generatedText,
      createdAt: createdAt ?? this.createdAt,
      contentType: contentType ?? this.contentType,
      platform: platform ?? this.platform,
      language: language ?? this.language,
      tone: tone ?? this.tone,
      length: length ?? this.length,
      hashtags: hashtags ?? this.hashtags,
      emoji: emoji ?? this.emoji,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'generatedText': generatedText,
      'createdAt': createdAt.toIso8601String(),
      'contentType': contentType.toString(),
      'platform': platform.toString(),
      'language': language,
      'tone': tone,
      'length': length,
      'hashtags': hashtags,
      'emoji': emoji,
      'isFavorite': isFavorite,
    };
  }

  factory GeneratedContent.fromJson(Map<String, dynamic> json) {
    return GeneratedContent(
      id: json['id'],
      topic: json['topic'],
      generatedText: json['generatedText'],
      createdAt: DateTime.parse(json['createdAt']),
      contentType: _parseContentType(json['contentType']),
      platform: _parsePlatform(json['platform']),
      language: json['language'] ?? 'ar',
      tone: json['tone'] ?? 'professional',
      length: json['length'] ?? 150,
      hashtags: List<String>.from(json['hashtags'] ?? []),
      emoji: json['emoji'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  static ContentType _parseContentType(String? value) {
    switch (value) {
      case 'ContentType.post':
        return ContentType.post;
      case 'ContentType.story':
        return ContentType.story;
      case 'ContentType.reel':
        return ContentType.reel;
      case 'ContentType.thread':
        return ContentType.thread;
      case 'ContentType.caption':
        return ContentType.caption;
      case 'ContentType.ad':
        return ContentType.ad;
      default:
        return ContentType.post;
    }
  }

  static Platform _parsePlatform(String? value) {
    switch (value) {
      case 'Platform.instagram':
        return Platform.instagram;
      case 'Platform.twitter':
        return Platform.twitter;
      case 'Platform.facebook':
        return Platform.facebook;
      case 'Platform.linkedin':
        return Platform.linkedin;
      case 'Platform.tiktok':
        return Platform.tiktok;
      case 'Platform.youtube':
        return Platform.youtube;
      default:
        return Platform.instagram;
    }
  }
}

enum ContentType {
  post,
  story,
  reel,
  thread,
  caption,
  ad,
}

enum Platform {
  instagram,
  twitter,
  facebook,
  linkedin,
  tiktok,
  youtube,
}

// Extensions للحصول على أسماء عربية
extension ContentTypeExtension on ContentType {
  String get arabicName {
    switch (this) {
      case ContentType.post:
        return 'منشور';
      case ContentType.story:
        return 'ستوري';
      case ContentType.reel:
        return 'ريل';
      case ContentType.thread:
        return 'سلسلة تغريدات';
      case ContentType.caption:
        return 'تعليق توضيحي';
      case ContentType.ad:
        return 'إعلان';
    }
  }

  String get englishName {
    switch (this) {
      case ContentType.post:
        return 'Post';
      case ContentType.story:
        return 'Story';
      case ContentType.reel:
        return 'Reel';
      case ContentType.thread:
        return 'Thread';
      case ContentType.caption:
        return 'Caption';
      case ContentType.ad:
        return 'Ad';
    }
  }

  String get emoji {
    switch (this) {
      case ContentType.post:
        return '📝';
      case ContentType.story:
        return '✨';
      case ContentType.reel:
        return '🎬';
      case ContentType.thread:
        return '🧵';
      case ContentType.caption:
        return '📸';
      case ContentType.ad:
        return '🎯';
    }
  }
}

extension PlatformExtension on Platform {
  String get name {
    switch (this) {
      case Platform.instagram:
        return 'Instagram';
      case Platform.twitter:
        return 'Twitter';
      case Platform.facebook:
        return 'Facebook';
      case Platform.linkedin:
        return 'LinkedIn';
      case Platform.tiktok:
        return 'TikTok';
      case Platform.youtube:
        return 'YouTube';
    }
  }

  String get icon {
    switch (this) {
      case Platform.instagram:
        return '📷';
      case Platform.twitter:
        return '🐦';
      case Platform.facebook:
        return '👥';
      case Platform.linkedin:
        return '💼';
      case Platform.tiktok:
        return '🎵';
      case Platform.youtube:
        return '▶️';
    }
  }
}
