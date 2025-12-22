/// نموذج فلاتر التحليلات
/// يستخدم لتخزين وتمرير معاملات الفلترة للخادم

class AnalyticsFilter {
  /// تاريخ البداية (شامل)
  final DateTime? dateFrom;

  /// تاريخ النهاية (شامل)
  final DateTime? dateTo;

  /// المنصات المراد فلترتها
  /// مثال: ['twitter', 'facebook', 'instagram', 'linkedin', 'tiktok', 'bluesky', 'threads', 'pinterest']
  final List<String>? platforms;

  /// المقاييس المراد عرضها
  /// مثال: ['views', 'engagements', 'shares', 'comments', 'likes']
  final List<String>? metrics;

  /// نوع الفترة (يومي، أسبوع، شهر)
  /// القيم الممكنة: 'daily', 'weekly', 'monthly'
  final String? periodType;

  /// هل تم تفعيل الفلتر
  final bool isActive;

  AnalyticsFilter({
    this.dateFrom,
    this.dateTo,
    this.platforms,
    this.metrics,
    this.periodType,
    this.isActive = false,
  });

  /// تحويل الفلتر إلى JSON لإرساله للخادم
  Map<String, dynamic> toJson() {
    return {
      if (dateFrom != null)
        'date_from': dateFrom!.toIso8601String().split('T')[0],
      if (dateTo != null) 'date_to': dateTo!.toIso8601String().split('T')[0],
      if (platforms != null && platforms!.isNotEmpty) 'platforms': platforms,
      if (metrics != null && metrics!.isNotEmpty) 'metrics': metrics,
      if (periodType != null) 'period_type': periodType,
    };
  }

  /// إنشاء فلتر من JSON
  factory AnalyticsFilter.fromJson(Map<String, dynamic> json) {
    return AnalyticsFilter(
      dateFrom: json['date_from'] != null
          ? DateTime.parse(json['date_from'])
          : null,
      dateTo: json['date_to'] != null ? DateTime.parse(json['date_to']) : null,
      platforms: List<String>.from(json['platforms'] ?? []),
      metrics: List<String>.from(json['metrics'] ?? []),
      periodType: json['period_type'],
      isActive: json['is_active'] ?? false,
    );
  }

  /// إنشاء نسخة معدلة من الفلتر
  AnalyticsFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<String>? platforms,
    List<String>? metrics,
    String? periodType,
    bool? isActive,
  }) {
    return AnalyticsFilter(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      platforms: platforms ?? this.platforms,
      metrics: metrics ?? this.metrics,
      periodType: periodType ?? this.periodType,
      isActive: isActive ?? this.isActive,
    );
  }

  /// هل الفلتر فارغ (بدون أي معاملات)
  bool get isEmpty =>
      dateFrom == null &&
      dateTo == null &&
      (platforms == null || platforms!.isEmpty) &&
      (metrics == null || metrics!.isEmpty) &&
      periodType == null;

  /// الحصول على وصف الفلتر النشط
  String getDescription() {
    if (isEmpty) return 'بدون فلاتر';

    List<String> parts = [];

    if (dateFrom != null && dateTo != null) {
      parts.add(
        'من ${dateFrom!.toString().split(' ')[0]} إلى ${dateTo!.toString().split(' ')[0]}',
      );
    }

    if (platforms != null && platforms!.isNotEmpty) {
      parts.add('المنصات: ${platforms!.join(", ")}');
    }

    if (metrics != null && metrics!.isNotEmpty) {
      parts.add('المقاييس: ${metrics!.join(", ")}');
    }

    if (periodType != null) {
      final periodMap = {
        'daily': 'يومي',
        'weekly': 'أسبوعي',
        'monthly': 'شهري',
      };
      parts.add('النوع: ${periodMap[periodType] ?? periodType}');
    }

    return parts.join(' | ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsFilter &&
          runtimeType == other.runtimeType &&
          dateFrom == other.dateFrom &&
          dateTo == other.dateTo &&
          platforms == other.platforms &&
          metrics == other.metrics &&
          periodType == other.periodType &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      dateFrom.hashCode ^
      dateTo.hashCode ^
      platforms.hashCode ^
      metrics.hashCode ^
      periodType.hashCode ^
      isActive.hashCode;

  @override
  String toString() =>
      'AnalyticsFilter(dateFrom: $dateFrom, dateTo: $dateTo, platforms: $platforms, metrics: $metrics, periodType: $periodType, isActive: $isActive)';
}
