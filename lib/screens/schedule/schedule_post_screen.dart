import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/multi_platform_post_service.dart';
import '../../services/social_accounts_service.dart';
import '../../services/n8n_service.dart';
import 'package:image_picker/image_picker.dart';

class SchedulePostScreen extends StatefulWidget {
  const SchedulePostScreen({super.key});

  @override
  State<SchedulePostScreen> createState() => _SchedulePostScreenState();
}

class _SchedulePostScreenState extends State<SchedulePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _multiPlatformService = Get.find<MultiPlatformPostService>();
  final _accountsService = Get.find<SocialAccountsService>();
  final _n8nService = Get.find<N8nService>();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _selectedPlatforms = [];
  final List<String> _mediaUrls = [];
  bool _useN8n = false;
  bool _isPublishing = false;

  final List<Map<String, dynamic>> _availablePlatforms = [
    {
      'id': 'facebook',
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': const Color(0xFF1877F2),
    },
    {
      'id': 'instagram',
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'color': const Color(0xFFE4405F),
    },
    {
      'id': 'twitter',
      'name': 'Twitter',
      'icon': Icons.chat,
      'color': const Color(0xFF1DA1F2),
    },
    {
      'id': 'linkedin',
      'name': 'LinkedIn',
      'icon': Icons.business,
      'color': const Color(0xFF0A66C2),
    },
    {
      'id': 'tiktok',
      'name': 'TikTok',
      'icon': Icons.music_note,
      'color': const Color(0xFF000000),
    },
    {
      'id': 'youtube',
      'name': 'YouTube',
      'icon': Icons.play_arrow,
      'color': const Color(0xFFFF0000),
    },
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('المحتوى'),
              const SizedBox(height: 12),
              _buildContentField(),
              const SizedBox(height: 24),

              _buildSectionTitle('اختر المنصات'),
              const SizedBox(height: 12),
              _buildPlatformSelection(),
              const SizedBox(height: 24),

              _buildSectionTitle('جدولة النشر'),
              const SizedBox(height: 12),
              _buildDateTimePicker(),
              const SizedBox(height: 24),

              _buildSectionTitle('الصور والفيديو'),
              const SizedBox(height: 12),
              _buildMediaUpload(),
              const SizedBox(height: 24),

              if (_n8nService.isEnabled) ...[
                _buildN8nToggle(),
                const SizedBox(height: 24),
              ],

              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.neonCyan, AppColors.neonPurple],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.schedule_send_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'جدولة منشور جديد',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'نشر على منصات متعددة',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          AppColors.cyanPurpleGradient.createShader(bounds),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _contentController,
        maxLines: 8,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'اكتب محتوى منشورك هنا...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى إدخال محتوى المنشور';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPlatformSelection() {
    return Obx(() {
      final connectedAccounts = _accountsService.accounts;

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _availablePlatforms.map((platform) {
          final isConnected = connectedAccounts.any(
            (account) => account.platform.toLowerCase() == platform['id'],
          );
          final isSelected = _selectedPlatforms.contains(platform['id']);

          return GestureDetector(
            onTap: () {
              if (!isConnected) {
                // عرض dialog لربط الحساب
                _showConnectAccountDialog(platform);
              } else {
                setState(() {
                  if (isSelected) {
                    _selectedPlatforms.remove(platform['id']);
                  } else {
                    _selectedPlatforms.add(platform['id']);
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? platform['color'].withValues(alpha: 0.2)
                    : AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? platform['color']
                      : (isConnected
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.3)),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    platform['icon'],
                    color: isConnected
                        ? (isSelected ? platform['color'] : Colors.white54)
                        : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    platform['name'],
                    style: TextStyle(
                      color: isConnected
                          ? (isSelected ? Colors.white : Colors.white54)
                          : Colors.red,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (!isConnected) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock, size: 14, color: Colors.red),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildDateTimePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Date Picker
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.neonCyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التاريخ',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Time Picker
          InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.neonPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الوقت',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaUpload() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        children: [
          if (_mediaUrls.isNotEmpty)
            Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _mediaUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.image,
                            color: AppColors.neonCyan,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mediaUrls.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          OutlinedButton.icon(
            onPressed: _pickMedia,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('إضافة صور أو فيديو'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neonCyan,
              side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildN8nToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.api_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استخدام n8n Automation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'أتمتة متقدمة للنشر',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _useN8n,
            onChanged: (value) {
              setState(() {
                _useN8n = value;
              });
            },
            activeThumbColor: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Schedule Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _isPublishing ? null : _schedulePost,
              icon: _isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.schedule_send_rounded),
              label: Text(
                _isPublishing ? 'جاري الجدولة...' : 'جدولة المنشور',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Publish Now Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _isPublishing ? null : _publishNow,
            icon: const Icon(Icons.send_rounded),
            label: const Text(
              'نشر الآن',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neonPurple,
              side: BorderSide(
                color: AppColors.neonPurple.withValues(alpha: 0.5),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.neonPurple,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _mediaUrls.add(image.path);
      });
    }
  }

  Future<void> _schedulePost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlatforms.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار منصة واحدة على الأقل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final result = await _multiPlatformService.schedulePost(
      content: _contentController.text,
      platforms: _selectedPlatforms,
      scheduledTime: scheduledDateTime,
      mediaUrls: _mediaUrls.isEmpty ? null : _mediaUrls,
      useN8n: _useN8n,
    );

    setState(() {
      _isPublishing = false;
    });

    if (result != null) {
      Get.back();
    }
  }

  Future<void> _publishNow() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlatforms.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار منصة واحدة على الأقل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    await _multiPlatformService.publishNow(
      content: _contentController.text,
      platforms: _selectedPlatforms,
      mediaUrls: _mediaUrls.isEmpty ? null : _mediaUrls,
    );

    setState(() {
      _isPublishing = false;
    });

    Get.back();
  }

  void _showConnectAccountDialog(Map<String, dynamic> platform) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(platform['icon'], color: platform['color'], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ربط حساب ${platform['name']}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off_rounded, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(
              'حساب ${platform['name']} غير متصل.\n\nيجب ربط الحساب أولاً قبل جدولة المنشورات.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 15),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.neonCyan, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'اذهب إلى إدارة الحسابات لربط حسابك',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back(); // إغلاق dialog
              Get.back(); // الرجوع للشاشة السابقة
              // يمكن إضافة navigation لشاشة الحسابات هنا
            },
            icon: const Icon(Icons.link_rounded),
            label: const Text('اذهب لربط الحساب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
