import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/analytics_filter.dart';

/// شاشة فلاتر التحليلات
class AnalyticsFilterDialog extends StatefulWidget {
  final AnalyticsFilter initialFilter;
  final Function(AnalyticsFilter) onApply;

  const AnalyticsFilterDialog({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<AnalyticsFilterDialog> createState() => _AnalyticsFilterDialogState();
}

class _AnalyticsFilterDialogState extends State<AnalyticsFilterDialog> {
  late DateTime? _dateFrom;
  late DateTime? _dateTo;
  late List<String> _selectedPlatforms;
  late List<String> _selectedMetrics;
  late String? _selectedPeriodType;

  static const List<String> _allPlatforms = [
    'twitter',
    'facebook',
    'instagram',
    'linkedin',
    'tiktok',
    'bluesky',
    'threads',
    'pinterest',
  ];

  static const List<String> _allMetrics = [
    'views',
    'engagements',
    'shares',
    'comments',
    'likes',
  ];

  static const Map<String, String> _platformNames = {
    'twitter': 'تويتر',
    'facebook': 'فيسبوك',
    'instagram': 'إنستغرام',
    'linkedin': 'لينكد إن',
    'tiktok': 'تيك توك',
    'bluesky': 'بلو سكاي',
    'threads': 'ثريدز',
    'pinterest': 'بينترست',
  };

  static const Map<String, String> _metricNames = {
    'views': 'مشاهدات',
    'engagements': 'تفاعلات',
    'shares': 'مشاركات',
    'comments': 'تعليقات',
    'likes': 'إعجابات',
  };

  static const Map<String, String> _periodTypeNames = {
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
  };

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialFilter.dateFrom;
    _dateTo = widget.initialFilter.dateTo;
    _selectedPlatforms = List<String>.from(
      widget.initialFilter.platforms ?? [],
    );
    _selectedMetrics = List<String>.from(widget.initialFilter.metrics ?? []);
    _selectedPeriodType = widget.initialFilter.periodType;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.neonCyan,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.neonGradient.createShader(bounds),
                    child: const Text(
                      'فلاتر التحليلات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: AppColors.neonCyan),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Range Filter
              Text(
                'نطاق التاريخ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _dateFrom != null && _dateTo != null
                              ? '${_dateFrom!.toLocal().toString().split(' ')[0]} - ${_dateTo!.toLocal().toString().split(' ')[0]}'
                              : 'اختر نطاق التاريخ',
                          style: TextStyle(
                            color: _dateFrom != null
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today, color: AppColors.neonCyan),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Period Type Filter
              Text(
                'نوع الفترة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _periodTypeNames.entries.map((entry) {
                  final isSelected = _selectedPeriodType == entry.key;
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (value) {
                      setState(() {
                        _selectedPeriodType = value ? entry.key : null;
                      });
                    },
                    backgroundColor: AppColors.darkBg,
                    selectedColor: AppColors.neonCyan.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.neonCyan : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.neonCyan.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Platform Filter
              Text(
                'المنصات',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allPlatforms.map((platform) {
                  final isSelected = _selectedPlatforms.contains(platform);
                  return FilterChip(
                    label: Text(_platformNames[platform] ?? platform),
                    selected: isSelected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedPlatforms.add(platform);
                        } else {
                          _selectedPlatforms.remove(platform);
                        }
                      });
                    },
                    backgroundColor: AppColors.darkBg,
                    selectedColor: AppColors.neonCyan.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.neonCyan : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.neonCyan.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Metrics Filter
              Text(
                'المقاييس',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allMetrics.map((metric) {
                  final isSelected = _selectedMetrics.contains(metric);
                  return FilterChip(
                    label: Text(_metricNames[metric] ?? metric),
                    selected: isSelected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedMetrics.add(metric);
                        } else {
                          _selectedMetrics.remove(metric);
                        }
                      });
                    },
                    backgroundColor: AppColors.darkBg,
                    selectedColor: AppColors.neonCyan.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.neonCyan : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.neonCyan.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _dateFrom = null;
                          _dateTo = null;
                          _selectedPlatforms.clear();
                          _selectedMetrics.clear();
                          _selectedPeriodType = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.neonCyan.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إعادة تعيين',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final filter = AnalyticsFilter(
                              dateFrom: _dateFrom,
                              dateTo: _dateTo,
                              platforms: _selectedPlatforms.isEmpty
                                  ? null
                                  : _selectedPlatforms,
                              metrics: _selectedMetrics.isEmpty
                                  ? null
                                  : _selectedMetrics,
                              periodType: _selectedPeriodType,
                              isActive:
                                  _dateFrom != null ||
                                  _dateTo != null ||
                                  _selectedPlatforms.isNotEmpty ||
                                  _selectedMetrics.isNotEmpty ||
                                  _selectedPeriodType != null,
                            );
                            widget.onApply(filter);
                            Get.back();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'تطبيق',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
