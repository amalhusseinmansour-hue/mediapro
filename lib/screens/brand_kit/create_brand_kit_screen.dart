import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/brand_kit_model.dart';
import '../../services/brand_kit_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateBrandKitScreen extends StatefulWidget {
  final BrandKit? editBrandKit;

  const CreateBrandKitScreen({super.key, this.editBrandKit});

  @override
  State<CreateBrandKitScreen> createState() => _CreateBrandKitScreenState();
}

class _CreateBrandKitScreenState extends State<CreateBrandKitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers
  final _brandNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sloganController = TextEditingController();
  final _websiteController = TextEditingController();
  final _keywordController = TextEditingController();

  // Data
  String _selectedIndustry = 'technology';
  String _selectedTone = 'professional';
  List<String> _primaryColors = ['#00D4FF', '#9333EA'];
  List<String> _secondaryColors = [];
  List<String> _keywords = [];
  List<String> _targetAudience = [];

  bool _isLoading = false;

  final List<Map<String, dynamic>> _industries = [
    {'id': 'technology', 'name': 'التقنية', 'icon': Icons.computer_rounded},
    {'id': 'fashion', 'name': 'الأزياء', 'icon': Icons.checkroom_rounded},
    {'id': 'food', 'name': 'الطعام', 'icon': Icons.restaurant_rounded},
    {'id': 'health', 'name': 'الصحة', 'icon': Icons.favorite_rounded},
    {'id': 'education', 'name': 'التعليم', 'icon': Icons.school_rounded},
    {'id': 'travel', 'name': 'السفر', 'icon': Icons.flight_rounded},
    {'id': 'sports', 'name': 'الرياضة', 'icon': Icons.sports_soccer_rounded},
    {'id': 'entertainment', 'name': 'الترفيه', 'icon': Icons.movie_rounded},
    {'id': 'finance', 'name': 'المالية', 'icon': Icons.account_balance_rounded},
    {'id': 'real_estate', 'name': 'العقارات', 'icon': Icons.home_rounded},
    {'id': 'beauty', 'name': 'الجمال', 'icon': Icons.spa_rounded},
    {'id': 'other', 'name': 'أخرى', 'icon': Icons.category_rounded},
  ];

  final List<Map<String, dynamic>> _tones = [
    {'id': 'professional', 'name': 'احترافي', 'desc': 'رسمي ومهني'},
    {'id': 'friendly', 'name': 'ودود', 'desc': 'قريب ودافئ'},
    {'id': 'casual', 'name': 'عفوي', 'desc': 'مريح وغير رسمي'},
    {'id': 'luxury', 'name': 'فاخر', 'desc': 'راقي وأنيق'},
    {'id': 'playful', 'name': 'مرح', 'desc': 'ممتع وحيوي'},
    {'id': 'inspirational', 'name': 'ملهم', 'desc': 'محفز وإيجابي'},
  ];

  final List<String> _audienceOptions = [
    'الشباب (18-25)',
    'البالغين (26-40)',
    'كبار السن (40+)',
    'رجال الأعمال',
    'الأمهات',
    'الطلاب',
    'المحترفين',
    'العائلات',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.editBrandKit != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final brand = widget.editBrandKit!;
    _brandNameController.text = brand.brandName;
    _descriptionController.text = brand.description;
    _sloganController.text = brand.slogan ?? '';
    _websiteController.text = brand.websiteUrl ?? '';
    _selectedIndustry = brand.industry;
    _selectedTone = brand.tone;
    _primaryColors = List.from(brand.primaryColors);
    _secondaryColors = List.from(brand.secondaryColors);
    _keywords = List.from(brand.keywords);
    _targetAudience = List.from(brand.targetAudience);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _brandNameController.dispose();
    _descriptionController.dispose();
    _sloganController.dispose();
    _websiteController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.editBrandKit != null ? 'تعديل Brand Kit' : 'إنشاء Brand Kit',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('السابق'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildBasicInfoStep(),
                _buildColorsStep(),
                _buildToneKeywordsStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Bottom Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive ? AppColors.cyanPurpleGradient : null,
                    color: isActive ? null : AppColors.darkCard,
                    border: Border.all(
                      color: isActive
                          ? Colors.transparent
                          : AppColors.neonCyan.withValues(alpha:0.3),
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: index < _currentStep
                            ? AppColors.cyanPurpleGradient
                            : null,
                        color: index < _currentStep
                            ? null
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Step 1: Basic Info
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              icon: Icons.business_rounded,
              title: 'المعلومات الأساسية',
              subtitle: 'أدخل معلومات علامتك التجارية',
            ),
            const SizedBox(height: 24),

            // Brand Name
            _buildTextField(
              controller: _brandNameController,
              label: 'اسم العلامة التجارية',
              hint: 'مثال: ميديا برو',
              icon: Icons.badge_rounded,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'وصف العلامة',
              hint: 'اكتب وصفاً موجزاً لعلامتك التجارية...',
              icon: Icons.description_rounded,
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),

            // Slogan
            _buildTextField(
              controller: _sloganController,
              label: 'الشعار (اختياري)',
              hint: 'مثال: نحو مستقبل رقمي أفضل',
              icon: Icons.format_quote_rounded,
            ),
            const SizedBox(height: 20),

            // Website
            _buildTextField(
              controller: _websiteController,
              label: 'الموقع الإلكتروني (اختياري)',
              hint: 'https://example.com',
              icon: Icons.link_rounded,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),

            // Industry
            const Text(
              'المجال',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _industries.map((industry) {
                final isSelected = _selectedIndustry == industry['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndustry = industry['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                      color: isSelected ? null : AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.neonCyan.withValues(alpha:0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          industry['icon'],
                          color: isSelected ? Colors.white : AppColors.neonCyan,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          industry['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textLight,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Colors
  Widget _buildColorsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.palette_rounded,
            title: 'الألوان',
            subtitle: 'اختر ألوان علامتك التجارية',
          ),
          const SizedBox(height: 24),

          // Primary Colors
          _buildColorSection(
            title: 'الألوان الأساسية',
            colors: _primaryColors,
            onAdd: () => _showColorPicker(isPrimary: true),
            onRemove: (index) => setState(() => _primaryColors.removeAt(index)),
          ),
          const SizedBox(height: 24),

          // Secondary Colors
          _buildColorSection(
            title: 'الألوان الثانوية (اختياري)',
            colors: _secondaryColors,
            onAdd: () => _showColorPicker(isPrimary: false),
            onRemove: (index) => setState(() => _secondaryColors.removeAt(index)),
          ),
          const SizedBox(height: 32),

          // Color Preview
          _buildColorPreview(),
        ],
      ),
    );
  }

  Widget _buildColorSection({
    required String title,
    required List<String> colors,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(colors.length, (index) {
            return GestureDetector(
              onTap: () => onRemove(index),
              child: Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _parseColor(colors[index]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _parseColor(colors[index]).withValues(alpha:0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        if (colors.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha:0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Text(
                'اضغط + لإضافة لون',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColorPreview() {
    if (_primaryColors.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _primaryColors.map((c) => _parseColor(c)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _brandNameController.text.isEmpty
                ? 'اسم العلامة'
                : _brandNameController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _sloganController.text.isEmpty
                ? 'الشعار الخاص بك'
                : _sloganController.text,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker({required bool isPrimary}) {
    Color pickedColor = AppColors.neonCyan;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'اختر لوناً',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickedColor,
            onColorChanged: (color) => pickedColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final hex =
                  '#${pickedColor.value.toRadixString(16).substring(2).toUpperCase()}';
              setState(() {
                if (isPrimary) {
                  _primaryColors.add(hex);
                } else {
                  _secondaryColors.add(hex);
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // Step 3: Tone & Keywords
  Widget _buildToneKeywordsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.record_voice_over_rounded,
            title: 'النبرة والجمهور',
            subtitle: 'حدد شخصية علامتك التجارية',
          ),
          const SizedBox(height: 24),

          // Tone Selection
          const Text(
            'نبرة العلامة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _tones.length,
            itemBuilder: (context, index) {
              final tone = _tones[index];
              final isSelected = _selectedTone == tone['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedTone = tone['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                    color: isSelected ? null : AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.neonPurple.withValues(alpha:0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tone['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Text(
                          tone['desc'],
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Target Audience
          const Text(
            'الجمهور المستهدف',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _audienceOptions.map((audience) {
              final isSelected = _targetAudience.contains(audience);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _targetAudience.remove(audience);
                    } else {
                      _targetAudience.add(audience);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                    color: isSelected ? null : AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.neonCyan.withValues(alpha:0.3),
                    ),
                  ),
                  child: Text(
                    audience,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Keywords
          const Text(
            'الكلمات المفتاحية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'أضف كلمة مفتاحية...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addKeyword(),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _addKeyword,
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanPurpleGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _keywords.map((keyword) {
              return Chip(
                label: Text(keyword),
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: AppColors.neonPurple.withValues(alpha:0.3),
                deleteIcon: const Icon(Icons.close, size: 18),
                deleteIconColor: Colors.white,
                onDeleted: () => setState(() => _keywords.remove(keyword)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _addKeyword() {
    if (_keywordController.text.isNotEmpty) {
      setState(() {
        _keywords.add(_keywordController.text.trim());
        _keywordController.clear();
      });
    }
  }

  // Step 4: Review
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.preview_rounded,
            title: 'مراجعة',
            subtitle: 'راجع معلومات علامتك التجارية',
          ),
          const SizedBox(height: 24),

          // Brand Card Preview
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha:0.3),
              ),
            ),
            child: Column(
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: _primaryColors.isNotEmpty
                        ? LinearGradient(
                            colors:
                                _primaryColors.map((c) => _parseColor(c)).toList(),
                          )
                        : AppColors.cyanPurpleGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _brandNameController.text.isEmpty
                                  ? 'اسم العلامة'
                                  : _brandNameController.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _industries.firstWhere(
                                (i) => i['id'] == _selectedIndustry,
                              )['name'],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha:0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_sloganController.text.isNotEmpty) ...[
                        Text(
                          '"${_sloganController.text}"',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Colors row
                      Row(
                        children: [
                          const Icon(Icons.palette, color: AppColors.neonCyan, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _primaryColors.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 30,
                                    height: 30,
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      color: _parseColor(_primaryColors[index]),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha:0.2),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tone
                      _buildReviewRow(
                        Icons.record_voice_over,
                        'النبرة',
                        _tones.firstWhere((t) => t['id'] == _selectedTone)['name'],
                      ),
                      const SizedBox(height: 12),

                      // Audience
                      if (_targetAudience.isNotEmpty) ...[
                        _buildReviewRow(
                          Icons.people,
                          'الجمهور',
                          _targetAudience.join('، '),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Keywords
                      if (_keywords.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _keywords.map((k) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neonPurple.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                k,
                                style: const TextStyle(
                                  color: AppColors.neonPurple,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.cyanPurpleGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.neonCyan),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    final isLastStep = _currentStep == 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : (isLastStep ? _saveBrandKit : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanPurpleGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastStep ? 'حفظ Brand Kit' : 'التالي',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastStep
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_brandNameController.text.isEmpty ||
          _descriptionController.text.isEmpty) {
        Get.snackbar(
          'خطأ',
          'يرجى ملء الحقول المطلوبة',
          backgroundColor: Colors.red.withValues(alpha:0.2),
          colorText: Colors.white,
        );
        return;
      }
    }

    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveBrandKit() async {
    setState(() => _isLoading = true);

    try {
      final brandKit = BrandKit(
        id: widget.editBrandKit?.id ?? const Uuid().v4(),
        userId: 'current_user', // Will be replaced with actual user ID
        brandName: _brandNameController.text,
        industry: _selectedIndustry,
        description: _descriptionController.text,
        primaryColors: _primaryColors,
        secondaryColors: _secondaryColors,
        logoUrl: null,
        websiteUrl:
            _websiteController.text.isEmpty ? null : _websiteController.text,
        tone: _selectedTone,
        keywords: _keywords,
        targetAudience: _targetAudience,
        slogan: _sloganController.text.isEmpty ? null : _sloganController.text,
        fonts: null,
        createdAt: widget.editBrandKit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        trendingData: null,
        aiSuggestions: null,
        isActive: widget.editBrandKit?.isActive ?? true,
      );

      final service = Get.find<BrandKitService>();
      bool success;

      if (widget.editBrandKit != null) {
        success = await service.updateBrandKit(brandKit);
      } else {
        success = await service.saveBrandKit(brandKit);
      }

      if (success) {
        Get.back(result: brandKit);
        Get.snackbar(
          'تم بنجاح',
          widget.editBrandKit != null
              ? 'تم تحديث Brand Kit بنجاح'
              : 'تم إنشاء Brand Kit بنجاح',
          backgroundColor: AppColors.neonCyan.withValues(alpha:0.2),
          colorText: Colors.white,
        );
      } else {
        throw Exception('فشل في حفظ Brand Kit');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha:0.2),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _parseColor(String colorString) {
    try {
      colorString = colorString.replaceAll('#', '');
      if (colorString.length == 6) {
        colorString = 'FF$colorString';
      }
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return AppColors.neonCyan;
    }
  }
}
