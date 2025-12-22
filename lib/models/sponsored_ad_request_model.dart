/// نموذج طلب إعلان ممول
class SponsoredAdRequestModel {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String adPlatform;
  final String adType;
  final String targetAudience;
  final double budget;
  final String currency;
  final int? durationDays;
  final DateTime? startDate;
  final String? adContent;
  final Map<String, dynamic>? targetingOptions;
  final String status;
  final String? adminNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SponsoredAdRequestModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    required this.adPlatform,
    required this.adType,
    required this.targetAudience,
    required this.budget,
    this.currency = 'AED',
    this.durationDays,
    this.startDate,
    this.adContent,
    this.targetingOptions,
    this.status = 'pending',
    this.adminNotes,
    this.createdAt,
    this.updatedAt,
  });

  /// تحويل من JSON
  factory SponsoredAdRequestModel.fromJson(Map<String, dynamic> json) {
    return SponsoredAdRequestModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['company_name'],
      adPlatform: json['ad_platform'] ?? 'facebook',
      adType: json['ad_type'] ?? 'awareness',
      targetAudience: json['target_audience'] ?? '',
      budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'AED',
      durationDays: json['duration_days'],
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      adContent: json['ad_content'],
      targetingOptions: json['targeting_options'] != null
          ? Map<String, dynamic>.from(json['targeting_options'])
          : null,
      status: json['status'] ?? 'pending',
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (companyName != null) 'company_name': companyName,
      'ad_platform': adPlatform,
      'ad_type': adType,
      'target_audience': targetAudience,
      'budget': budget,
      'currency': currency,
      if (durationDays != null) 'duration_days': durationDays,
      if (startDate != null) 'start_date': startDate!.toIso8601String().split('T')[0],
      if (adContent != null) 'ad_content': adContent,
      if (targetingOptions != null) 'targeting_options': targetingOptions,
      'status': status,
      if (adminNotes != null) 'admin_notes': adminNotes,
    };
  }

  /// نسخ النموذج مع تعديلات
  SponsoredAdRequestModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? adPlatform,
    String? adType,
    String? targetAudience,
    double? budget,
    String? currency,
    int? durationDays,
    DateTime? startDate,
    String? adContent,
    Map<String, dynamic>? targetingOptions,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SponsoredAdRequestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyName: companyName ?? this.companyName,
      adPlatform: adPlatform ?? this.adPlatform,
      adType: adType ?? this.adType,
      targetAudience: targetAudience ?? this.targetAudience,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      adContent: adContent ?? this.adContent,
      targetingOptions: targetingOptions ?? this.targetingOptions,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// الحصول على اسم المنصة بالعربية
  String getPlatformArabic() {
    const platforms = {
      'facebook': 'فيسبوك',
      'instagram': 'إنستغرام',
      'google': 'جوجل',
      'tiktok': 'تيك توك',
      'twitter': 'تويتر (X)',
      'linkedin': 'لينكد إن',
      'snapchat': 'سناب شات',
      'multiple': 'عدة منصات',
    };
    return platforms[adPlatform] ?? adPlatform;
  }

  /// الحصول على نوع الإعلان بالعربية
  String getAdTypeArabic() {
    const types = {
      'awareness': 'زيادة الوعي',
      'traffic': 'زيادة الزيارات',
      'engagement': 'زيادة التفاعل',
      'leads': 'جمع العملاء المحتملين',
      'sales': 'زيادة المبيعات',
      'app_installs': 'تثبيت التطبيق',
    };
    return types[adType] ?? adType;
  }

  /// الحصول على الحالة بالعربية
  String getStatusArabic() {
    const statuses = {
      'pending': 'قيد الانتظار',
      'reviewing': 'قيد المراجعة',
      'accepted': 'مقبول',
      'rejected': 'مرفوض',
      'running': 'قيد التنفيذ',
      'completed': 'مكتمل',
    };
    return statuses[status] ?? status;
  }

  @override
  String toString() {
    return 'SponsoredAdRequest(id: $id, name: $name, platform: $adPlatform, budget: $budget $currency, status: $status)';
  }
}
