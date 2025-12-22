import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/social_media_service.dart';

/// Ayrshare Post Screen - Posts to social media via Laravel Backend + Ayrshare API
/// Social accounts are connected from Laravel admin dashboard (NOT in-app)
/// Supports: Facebook, Instagram, Twitter, LinkedIn, YouTube, TikTok
class AyrsharePostScreen extends StatefulWidget {
  const AyrsharePostScreen({super.key});

  @override
  State<AyrsharePostScreen> createState() => _AyrsharePostScreenState();
}

class _AyrsharePostScreenState extends State<AyrsharePostScreen> {
  final SocialMediaService _socialMediaService = Get.find<SocialMediaService>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  final RxList<String> _selectedPlatforms = <String>[].obs;
  final RxBool _isScheduled = false.obs;
  final Rx<DateTime?> _scheduledDateTime = Rx<DateTime?>(null);
  final RxBool _showAIGenerator = false.obs;

  @override
  void initState() {
    super.initState();
    // Load connected accounts on init
    _socialMediaService.loadSocialAccounts();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryPurple,
              surface: AppColors.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryPurple,
                surface: AppColors.cardDark,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        _scheduledDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  Future<void> _generateAIContent() async {
    if (_topicController.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال موضوع المحتوى',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_selectedPlatforms.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار منصة لتوليد المحتوى',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final content = await _socialMediaService.generateAIContent(
      topic: _topicController.text.trim(),
      platform: _selectedPlatforms.first,
      tone: 'professional',
    );

    if (content != null) {
      _contentController.text = content;
      _showAIGenerator.value = false;
    }
  }

  Future<void> _publishPost() async {
    if (_selectedPlatforms.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار منصة واحدة على الأقل',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى كتابة محتوى المنشور',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_isScheduled.value && _scheduledDateTime.value == null) {
      Get.snackbar(
        'تنبيه',
        'يرجى تحديد تاريخ ووقت النشر',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final success = await _socialMediaService.createPost(
      content: _contentController.text.trim(),
      platforms: _selectedPlatforms.toList(),
      scheduledAt: _isScheduled.value ? _scheduledDateTime.value : null,
    );

    if (success) {
      _contentController.clear();
      _topicController.clear();
      _selectedPlatforms.clear();
      _scheduledDateTime.value = null;
      _isScheduled.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('نشر على السوشال ميديا'),
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                _socialMediaService.loadSocialAccounts(showError: true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connected Accounts Section
            Obx(() {
              if (_socialMediaService.socialAccounts.isEmpty) {
                return Card(
                  color: AppColors.cardDark,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.link_off,
                          color: Colors.orange,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'لا توجد حسابات متصلة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'يتم ربط الحسابات من لوحة التحكم الإدارية',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Card(
                color: AppColors.cardDark,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الحسابات المتصلة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _socialMediaService.socialAccounts.map((
                          account,
                        ) {
                          return Chip(
                            avatar: Text(
                              _socialMediaService.getPlatformIcon(
                                account.platform,
                              ),
                              style: const TextStyle(fontSize: 20),
                            ),
                            label: Text(account.accountName),
                            backgroundColor: account.isActive
                                ? AppColors.primaryPurple.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Platform Selection
            Card(
              color: AppColors.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختر المنصات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final connectedPlatforms =
                          _socialMediaService.connectedPlatforms;

                      if (connectedPlatforms.isEmpty) {
                        return const Text(
                          'لا توجد منصات متصلة',
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: connectedPlatforms.map((platform) {
                          return Obx(() {
                            final isSelected = _selectedPlatforms.contains(
                              platform,
                            );
                            return FilterChip(
                              selected: isSelected,
                              label: Text(
                                '${_socialMediaService.getPlatformIcon(platform)} ${_socialMediaService.getPlatformDisplayName(platform)}',
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  _selectedPlatforms.add(platform);
                                } else {
                                  _selectedPlatforms.remove(platform);
                                }
                              },
                              selectedColor: AppColors.primaryPurple
                                  .withValues(alpha: 0.3),
                              backgroundColor: AppColors.backgroundDark,
                            );
                          });
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI Content Generator
            Obx(
              () => _showAIGenerator.value
                  ? Card(
                      color: AppColors.cardDark,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '🤖 مولد المحتوى بالذكاء الاصطناعي',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      _showAIGenerator.value = false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _topicController,
                              decoration: const InputDecoration(
                                hintText: 'أدخل موضوع المحتوى...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _generateAIContent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                              ),
                              child: const Text('توليد المحتوى'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Content Input
            Card(
              color: AppColors.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'محتوى المنشور',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          color: AppColors.primaryPurple,
                          onPressed: () =>
                              _showAIGenerator.value = !_showAIGenerator.value,
                          tooltip: 'مولد المحتوى بالذكاء الاصطناعي',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب محتوى منشورك هنا...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Schedule Option
            Card(
              color: AppColors.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'جدولة المنشور',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => Switch(
                            value: _isScheduled.value,
                            onChanged: (value) => _isScheduled.value = value,
                            activeThumbColor: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (!_isScheduled.value) return const SizedBox.shrink();

                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _selectDateTime,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _scheduledDateTime.value == null
                                  ? 'اختر التاريخ والوقت'
                                  : DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).format(_scheduledDateTime.value!),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Publish Button
            Obx(
              () => Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purpleShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _socialMediaService.isLoading.value
                      ? null
                      : _publishPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _socialMediaService.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isScheduled.value
                              ? 'جدولة المنشور 📅'
                              : 'نشر الآن 🚀',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
