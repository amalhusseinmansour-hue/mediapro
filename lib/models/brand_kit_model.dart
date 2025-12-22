import 'package:hive/hive.dart';

part 'brand_kit_model.g.dart';

@HiveType(typeId: 80)
class BrandKit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String brandName;

  @HiveField(3)
  String industry; // المجال (tech, fashion, food, etc.)

  @HiveField(4)
  String description;

  @HiveField(5)
  List<String> primaryColors; // الألوان الأساسية (hex codes)

  @HiveField(6)
  List<String> secondaryColors; // الألوان الثانوية

  @HiveField(7)
  String? logoUrl;

  @HiveField(8)
  String? websiteUrl;

  @HiveField(9)
  String tone; // نبرة العلامة (professional, casual, friendly, etc.)

  @HiveField(10)
  List<String> keywords; // كلمات مفتاحية

  @HiveField(11)
  List<String> targetAudience; // الجمهور المستهدف

  @HiveField(12)
  String? slogan; // الشعار

  @HiveField(13)
  Map<String, dynamic>? fonts; // الخطوط (name, size, weight)

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  @HiveField(16)
  Map<String, dynamic>? trendingData; // بيانات الترندات

  @HiveField(17)
  Map<String, dynamic>? aiSuggestions; // اقتراحات AI

  @HiveField(18)
  bool isActive;

  BrandKit({
    required this.id,
    required this.userId,
    required this.brandName,
    required this.industry,
    required this.description,
    required this.primaryColors,
    required this.secondaryColors,
    this.logoUrl,
    this.websiteUrl,
    required this.tone,
    required this.keywords,
    required this.targetAudience,
    this.slogan,
    this.fonts,
    required this.createdAt,
    required this.updatedAt,
    this.trendingData,
    this.aiSuggestions,
    this.isActive = true,
  });

  factory BrandKit.fromJson(Map<String, dynamic> json) {
    return BrandKit(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      brandName: json['brand_name'] ?? '',
      industry: json['industry'] ?? '',
      description: json['description'] ?? '',
      primaryColors: (json['primary_colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      secondaryColors: (json['secondary_colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      logoUrl: json['logo_url'],
      websiteUrl: json['website_url'],
      tone: json['tone'] ?? 'professional',
      keywords: (json['keywords'] as List?)?.map((e) => e.toString()).toList() ?? [],
      targetAudience: (json['target_audience'] as List?)?.map((e) => e.toString()).toList() ?? [],
      slogan: json['slogan'],
      fonts: json['fonts'] != null ? Map<String, dynamic>.from(json['fonts']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      trendingData: json['trending_data'] != null ? Map<String, dynamic>.from(json['trending_data']) : null,
      aiSuggestions: json['ai_suggestions'] != null ? Map<String, dynamic>.from(json['ai_suggestions']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand_name': brandName,
      'industry': industry,
      'description': description,
      'primary_colors': primaryColors,
      'secondary_colors': secondaryColors,
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'tone': tone,
      'keywords': keywords,
      'target_audience': targetAudience,
      'slogan': slogan,
      'fonts': fonts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'trending_data': trendingData,
      'ai_suggestions': aiSuggestions,
      'is_active': isActive,
    };
  }
}

/// نموذج لأفكار الترند
class TrendingIdea {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> hashtags;
  final int popularity; // 1-100
  final String source; // twitter, instagram, google trends, etc.
  final DateTime discoveredAt;
  final Map<String, dynamic>? metadata;

  TrendingIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.hashtags,
    required this.popularity,
    required this.source,
    required this.discoveredAt,
    this.metadata,
  });

  factory TrendingIdea.fromJson(Map<String, dynamic> json) {
    return TrendingIdea(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      hashtags: (json['hashtags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      popularity: json['popularity'] ?? 0,
      source: json['source'] ?? '',
      discoveredAt: json['discovered_at'] != null
          ? DateTime.parse(json['discovered_at'])
          : DateTime.now(),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'hashtags': hashtags,
      'popularity': popularity,
      'source': source,
      'discovered_at': discoveredAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// اقتراحات تحسين البراند من AI
class BrandSuggestion {
  final String type; // color, tone, keyword, content, etc.
  final String title;
  final String description;
  final dynamic value; // القيمة المقترحة
  final String reason; // السبب
  final int confidence; // 1-100
  final bool applied; // هل تم تطبيقها

  BrandSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.value,
    required this.reason,
    required this.confidence,
    this.applied = false,
  });

  factory BrandSuggestion.fromJson(Map<String, dynamic> json) {
    return BrandSuggestion(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      value: json['value'],
      reason: json['reason'] ?? '',
      confidence: json['confidence'] ?? 0,
      applied: json['applied'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'value': value,
      'reason': reason,
      'confidence': confidence,
      'applied': applied,
    };
  }
}
