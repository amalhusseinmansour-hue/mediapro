import 'package:hive/hive.dart';

part 'sponsored_ad_model.g.dart';

@HiveType(typeId: 70)
enum AdStatus {
  @HiveField(0) pending,      // معلق
  @HiveField(1) underReview,  // قيد المراجعة
  @HiveField(2) approved,     // مقبول
  @HiveField(3) rejected,     // مرفوض
  @HiveField(4) active,       // نشط
  @HiveField(5) completed,    // مكتمل
  @HiveField(6) cancelled,    // ملغي
}

@HiveType(typeId: 71)
enum AdType {
  @HiveField(0) post,         // منشور
  @HiveField(1) story,        // قصة
  @HiveField(2) video,        // فيديو
  @HiveField(3) carousel,     // دوار (عدة صور)
  @HiveField(4) collection,   // مجموعة
}

@HiveType(typeId: 72)
enum AdPlatform {
  @HiveField(0) facebook,
  @HiveField(1) instagram,
  @HiveField(2) twitter,
  @HiveField(3) linkedin,
  @HiveField(4) tiktok,
  @HiveField(5) youtube,
}

@HiveType(typeId: 73)
enum AdObjective {
  @HiveField(0) awareness,        // الوعي بالعلامة التجارية
  @HiveField(1) traffic,          // زيادة الزيارات
  @HiveField(2) engagement,       // التفاعل
  @HiveField(3) leads,            // جذب العملاء المحتملين
  @HiveField(4) sales,            // المبيعات
  @HiveField(5) appInstalls,      // تثبيت التطبيقات
}

@HiveType(typeId: 74)
class TargetAudience extends HiveObject {
  @HiveField(0)
  final String? ageRange;        // الفئة العمرية مثل "18-35"

  @HiveField(1)
  final List<String>? genders;   // الجنس: male, female, all

  @HiveField(2)
  final List<String>? locations; // المواقع الجغرافية

  @HiveField(3)
  final List<String>? interests; // الاهتمامات

  @HiveField(4)
  final List<String>? languages; // اللغات

  TargetAudience({
    this.ageRange,
    this.genders,
    this.locations,
    this.interests,
    this.languages,
  });

  Map<String, dynamic> toJson() {
    return {
      'ageRange': ageRange,
      'genders': genders,
      'locations': locations,
      'interests': interests,
      'languages': languages,
    };
  }

  factory TargetAudience.fromJson(Map<String, dynamic> json) {
    return TargetAudience(
      ageRange: json['ageRange'],
      genders: json['genders'] != null ? List<String>.from(json['genders']) : null,
      locations: json['locations'] != null ? List<String>.from(json['locations']) : null,
      interests: json['interests'] != null ? List<String>.from(json['interests']) : null,
      languages: json['languages'] != null ? List<String>.from(json['languages']) : null,
    );
  }
}

@HiveType(typeId: 75)
class SponsoredAdModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;            // عنوان الإعلان

  @HiveField(3)
  final String description;      // وصف الإعلان

  @HiveField(4)
  final AdType adType;           // نوع الإعلان

  @HiveField(5)
  final List<AdPlatform> platforms; // المنصات المستهدفة

  @HiveField(6)
  final AdObjective objective;   // هدف الإعلان

  @HiveField(7)
  final double budget;           // الميزانية بالدولار

  @HiveField(8)
  final int durationDays;        // مدة الإعلان بالأيام

  @HiveField(9)
  final TargetAudience? targetAudience; // الجمهور المستهدف

  @HiveField(10)
  final String? websiteUrl;      // رابط الموقع (اختياري)

  @HiveField(11)
  final String? callToAction;    // دعوة لاتخاذ إجراء (اختياري)

  @HiveField(12)
  final List<String>? imageUrls; // روابط الصور (اختياري)

  @HiveField(13)
  final AdStatus status;         // حالة الطلب

  @HiveField(14)
  final DateTime createdAt;      // تاريخ الإنشاء

  @HiveField(15)
  final DateTime? reviewedAt;    // تاريخ المراجعة

  @HiveField(16)
  final DateTime? startDate;     // تاريخ بداية الإعلان

  @HiveField(17)
  final DateTime? endDate;       // تاريخ نهاية الإعلان

  @HiveField(18)
  final String? adminNote;       // ملاحظات المسؤول

  @HiveField(19)
  final String? rejectionReason; // سبب الرفض (إذا رُفض)

  @HiveField(20)
  final Map<String, dynamic>? statistics; // إحصائيات الإعلان

  SponsoredAdModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.adType,
    required this.platforms,
    required this.objective,
    required this.budget,
    required this.durationDays,
    this.targetAudience,
    this.websiteUrl,
    this.callToAction,
    this.imageUrls,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.startDate,
    this.endDate,
    this.adminNote,
    this.rejectionReason,
    this.statistics,
  });

  // النصوص المترجمة لحالة الإعلان
  String get statusText {
    switch (status) {
      case AdStatus.pending:
        return 'معلق';
      case AdStatus.underReview:
        return 'قيد المراجعة';
      case AdStatus.approved:
        return 'مقبول';
      case AdStatus.rejected:
        return 'مرفوض';
      case AdStatus.active:
        return 'نشط';
      case AdStatus.completed:
        return 'مكتمل';
      case AdStatus.cancelled:
        return 'ملغي';
    }
  }

  // النصوص المترجمة لنوع الإعلان
  String get adTypeText {
    switch (adType) {
      case AdType.post:
        return 'منشور';
      case AdType.story:
        return 'قصة';
      case AdType.video:
        return 'فيديو';
      case AdType.carousel:
        return 'دوار';
      case AdType.collection:
        return 'مجموعة';
    }
  }

  // النصوص المترجمة لهدف الإعلان
  String get objectiveText {
    switch (objective) {
      case AdObjective.awareness:
        return 'الوعي بالعلامة';
      case AdObjective.traffic:
        return 'زيادة الزيارات';
      case AdObjective.engagement:
        return 'التفاعل';
      case AdObjective.leads:
        return 'جذب العملاء';
      case AdObjective.sales:
        return 'المبيعات';
      case AdObjective.appInstalls:
        return 'تثبيت التطبيقات';
    }
  }

  // النصوص المترجمة للمنصات
  static String getPlatformText(AdPlatform platform) {
    switch (platform) {
      case AdPlatform.facebook:
        return 'فيسبوك';
      case AdPlatform.instagram:
        return 'إنستغرام';
      case AdPlatform.twitter:
        return 'تويتر';
      case AdPlatform.linkedin:
        return 'لينكد إن';
      case AdPlatform.tiktok:
        return 'تيك توك';
      case AdPlatform.youtube:
        return 'يوتيوب';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'adType': adType.index,
      'platforms': platforms.map((p) => p.index).toList(),
      'objective': objective.index,
      'budget': budget,
      'durationDays': durationDays,
      'targetAudience': targetAudience?.toJson(),
      'websiteUrl': websiteUrl,
      'callToAction': callToAction,
      'imageUrls': imageUrls,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'adminNote': adminNote,
      'rejectionReason': rejectionReason,
      'statistics': statistics,
    };
  }

  factory SponsoredAdModel.fromJson(Map<String, dynamic> json) {
    return SponsoredAdModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      adType: AdType.values[json['adType']],
      platforms: (json['platforms'] as List).map((p) => AdPlatform.values[p]).toList(),
      objective: AdObjective.values[json['objective']],
      budget: (json['budget'] as num).toDouble(),
      durationDays: json['durationDays'],
      targetAudience: json['targetAudience'] != null
          ? TargetAudience.fromJson(json['targetAudience'])
          : null,
      websiteUrl: json['websiteUrl'],
      callToAction: json['callToAction'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      status: AdStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      adminNote: json['adminNote'],
      rejectionReason: json['rejectionReason'],
      statistics: json['statistics'] != null
          ? Map<String, dynamic>.from(json['statistics'])
          : null,
    );
  }
}
