import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../services/n8n_social_posting_service.dart';
import '../../services/direct_social_media_service.dart';

/// Real Post Screen - Posts to social media platforms
/// - Supports: Direct sharing (no account needed) + N8N Automation
class RealPostScreen extends StatefulWidget {
  const RealPostScreen({super.key});

  @override
  State<RealPostScreen> createState() => _RealPostScreenState();
}

class _RealPostScreenState extends State<RealPostScreen> {
  final N8nSocialPostingService _socialMediaService = Get.find<N8nSocialPostingService>();
  final DirectSocialMediaService _directShareService = Get.find<DirectSocialMediaService>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final RxList<String> _selectedPlatforms = <String>[].obs;
  final RxBool _isPosting = false.obs;
  final RxString _selectedMediaType = 'text'.obs; // text, image, video
  final RxString _shareMode = 'direct'.obs; // 'direct' = مشاركة مباشرة, 'api' = نشر عبر API

  File? _selectedMedia;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedMedia = File(image.path);
          _selectedMediaType.value = 'image';
        });
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل اختيار الصورة: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedMedia = File(video.path);
          _selectedMediaType.value = 'video';
        });
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل اختيار الفيديو: $e');
    }
  }

  Future<void> _publishPost() async {
    final description = _descriptionController.text.trim();

    if (_selectedMediaType.value == 'text' && description.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى كتابة نص المنشور');
      return;
    }

    if (_selectedMediaType.value != 'text' && _selectedMedia == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار ملف للنشر');
      return;
    }

    // Direct Share Mode - لا يتطلب ربط حسابات
    if (_shareMode.value == 'direct') {
      await _directShare();
      return;
    }

    // API Mode - يتطلب ربط حسابات
    if (_selectedPlatforms.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى اختيار منصة واحدة على الأقل');
      return;
    }

    _isPosting.value = true;

    try {
      // Post to multiple platforms via N8N
      final result = await _socialMediaService.postToMultiplePlatforms(
        content: description,
        platforms: _selectedPlatforms.toList(),
        mediaFile: _selectedMedia,
        mediaType: _selectedMediaType.value,
      );

      // Show results
      if (result['success'] == true) {
        Get.snackbar(
          'نجاح! 🎉',
          result['message'] ?? 'تم إرسال المنشور بنجاح',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );

        // Clear form
        _clearForm();
      } else {
        // Show errors
        String errorMessage = result['message'] ?? 'فشل النشر على المنصات';

        Get.snackbar(
          'فشل النشر',
          errorMessage,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 7),
        );
      }
    } catch (e) {
      print('❌ Error publishing post: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء النشر: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isPosting.value = false;
    }
  }

  /// مشاركة مباشرة - لا تتطلب ربط حسابات
  Future<void> _directShare() async {
    final description = _descriptionController.text.trim();
    _isPosting.value = true;

    try {
      if (_selectedMedia != null) {
        // Share with media file
        await Share.shareXFiles(
          [XFile(_selectedMedia!.path)],
          text: description,
          subject: _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : null,
        );
      } else {
        // Share text only
        await Share.share(
          description,
          subject: _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : null,
        );
      }

      Get.snackbar(
        'تم! 🎉',
        'تم فتح قائمة المشاركة - اختر التطبيق المناسب',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('❌ Error direct sharing: $e');
      Get.snackbar(
        'خطأ',
        'فشل في المشاركة: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      _isPosting.value = false;
    }
  }

  /// مشاركة إلى تطبيق محدد مباشرة
  Future<void> _shareToSpecificApp(String platform) async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty && _selectedMedia == null) {
      Get.snackbar('تنبيه', 'يرجى كتابة نص أو اختيار ملف');
      return;
    }

    _isPosting.value = true;

    try {
      // نسخ النص للحافظة
      if (description.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: description));
      }

      // فتح التطبيق مباشرة
      final opened = await _openSocialMediaApp(platform);

      if (opened) {
        Get.snackbar(
          'تم فتح $platform 📱',
          description.isNotEmpty
              ? 'تم نسخ النص! الصقه في المنشور الجديد'
              : 'قم بإنشاء منشور جديد',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('❌ Error sharing to $platform: $e');
      // Fallback to system share
      await _directShare();
    } finally {
      _isPosting.value = false;
    }
  }

  /// فتح تطبيق السوشال ميديا
  Future<bool> _openSocialMediaApp(String platform) async {
    // Deep links for creating new posts
    final Map<String, String> createPostUrls = {
      'instagram': 'instagram://library',
      'facebook': 'fb://composer',
      'twitter': 'twitter://post?message=${Uri.encodeComponent(_descriptionController.text)}',
      'x': 'twitter://post?message=${Uri.encodeComponent(_descriptionController.text)}',
      'tiktok': 'tiktok://camera',
      'whatsapp': 'whatsapp://send?text=${Uri.encodeComponent(_descriptionController.text)}',
      'telegram': 'tg://msg?text=${Uri.encodeComponent(_descriptionController.text)}',
      'snapchat': 'snapchat://camera',
      'linkedin': 'linkedin://shareArticle?summary=${Uri.encodeComponent(_descriptionController.text)}',
    };

    final Map<String, String> webUrls = {
      'instagram': 'https://www.instagram.com/',
      'facebook': 'https://www.facebook.com/sharer/sharer.php?quote=${Uri.encodeComponent(_descriptionController.text)}',
      'twitter': 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(_descriptionController.text)}',
      'x': 'https://x.com/intent/tweet?text=${Uri.encodeComponent(_descriptionController.text)}',
      'tiktok': 'https://www.tiktok.com/upload',
      'whatsapp': 'https://wa.me/?text=${Uri.encodeComponent(_descriptionController.text)}',
      'telegram': 'https://t.me/share/url?text=${Uri.encodeComponent(_descriptionController.text)}',
      'snapchat': 'https://www.snapchat.com/',
      'linkedin': 'https://www.linkedin.com/shareArticle?mini=true&summary=${Uri.encodeComponent(_descriptionController.text)}',
    };

    try {
      final appUrl = createPostUrls[platform.toLowerCase()];
      if (appUrl != null) {
        final uri = Uri.parse(appUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }

      // Fallback to web
      final webUrl = webUrls[platform.toLowerCase()];
      if (webUrl != null) {
        final uri = Uri.parse(webUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error opening $platform: $e');
      return false;
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedMedia = null;
    });
    _selectedPlatforms.clear();
    _selectedMediaType.value = 'text';
  }

  @override
  Widget build(BuildContext context) {
    final platformsInfo = N8nSocialPostingService.getPlatformInfo();
    final supportedPlatforms = ['facebook', 'twitter', 'instagram', 'linkedin'];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        title: const Text('نشر على السوشال ميديا'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Share Mode Selection
            const Text(
              'طريقة المشاركة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
              children: [
                Expanded(
                  child: _buildShareModeButton(
                    'مشاركة مباشرة',
                    'direct',
                    Icons.share,
                    'لا تحتاج ربط حسابات',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShareModeButton(
                    'نشر تلقائي',
                    'api',
                    Icons.cloud_upload,
                    'يحتاج ربط حسابات',
                    Colors.blue,
                  ),
                ),
              ],
            )),
            const SizedBox(height: 24),

            // Media Type Selection
            const Text(
              'نوع المحتوى',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
              children: [
                _buildMediaTypeButton('نص', 'text', Icons.text_fields),
                const SizedBox(width: 12),
                _buildMediaTypeButton('صورة', 'image', Icons.image),
                const SizedBox(width: 12),
                _buildMediaTypeButton('فيديو', 'video', Icons.video_library),
              ],
            )),
            const SizedBox(height: 24),

            // Title Field (for video/image)
            if (_selectedMediaType.value != 'text') ...[
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'العنوان (اختياري)',
                  labelStyle: const TextStyle(color: AppColors.textLight),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Description/Text Field
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: _selectedMediaType.value == 'text' ? 'نص المنشور' : 'الوصف',
                labelStyle: const TextStyle(color: AppColors.textLight),
                hintText: 'اكتب محتوى المنشور هنا...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: AppColors.darkCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Media Picker
            if (_selectedMediaType.value != 'text') ...[
              if (_selectedMedia == null)
                GestureDetector(
                  onTap: _selectedMediaType.value == 'image' ? _pickImage : _pickVideo,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedMediaType.value == 'image'
                              ? Icons.add_photo_alternate
                              : Icons.add_a_photo,
                            color: AppColors.neonCyan,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedMediaType.value == 'image'
                              ? 'اختر صورة'
                              : 'اختر فيديو',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: _selectedMediaType.value == 'image'
                          ? DecorationImage(
                              image: FileImage(_selectedMedia!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: _selectedMediaType.value == 'video'
                        ? Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          )
                        : null,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.8),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedMedia = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
            ],

            // Platform Selection (only for API mode)
            Obx(() {
              if (_shareMode.value == 'api') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختر المنصات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: supportedPlatforms.map((platformId) {
                        final info = platformsInfo[platformId]!;
                        return _buildPlatformChip(platformId, info);
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Quick Share Buttons (only for direct mode)
            Obx(() {
              if (_shareMode.value == 'direct') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مشاركة سريعة إلى',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickShareButton('Instagram', 'instagram', '📸', Color(0xFFE1306C)),
                          const SizedBox(width: 8),
                          _buildQuickShareButton('Facebook', 'facebook', '📘', Color(0xFF1877F2)),
                          const SizedBox(width: 8),
                          _buildQuickShareButton('Twitter/X', 'twitter', '🐦', Color(0xFF1DA1F2)),
                          const SizedBox(width: 8),
                          _buildQuickShareButton('TikTok', 'tiktok', '🎵', Color(0xFF000000)),
                          const SizedBox(width: 8),
                          _buildQuickShareButton('WhatsApp', 'whatsapp', '💬', Color(0xFF25D366)),
                          const SizedBox(width: 8),
                          _buildQuickShareButton('Telegram', 'telegram', '✈️', Color(0xFF0088CC)),
                          const SizedBox(width: 8),
                          _buildQuickShareButton('LinkedIn', 'linkedin', '💼', Color(0xFF0A66C2)),
                          const SizedBox(width: 8),
                          _buildQuickShareButton('Snapchat', 'snapchat', '👻', Color(0xFFFFFC00)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Publish/Share Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isPosting.value ? null : _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _shareMode.value == 'direct'
                      ? Colors.green
                      : AppColors.neonCyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPosting.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _shareMode.value == 'direct'
                              ? Icons.share
                              : Icons.send,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _shareMode.value == 'direct'
                              ? 'مشاركة الآن 📤'
                              : 'نشر الآن 🚀',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
              ),
            )),
            const SizedBox(height: 16),

            // Info text for direct mode
            Obx(() {
              if (_shareMode.value == 'direct') {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'المشاركة المباشرة تفتح قائمة التطبيقات المثبتة لاختيار التطبيق المناسب',
                          style: TextStyle(
                            color: Colors.green.shade300,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShareModeButton(String label, String mode, IconData icon, String subtitle, Color color) {
    final isSelected = _shareMode.value == mode;
    return GestureDetector(
      onTap: () => _shareMode.value = mode,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white70, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? color.withValues(alpha: 0.8) : Colors.white54,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickShareButton(String label, String platform, String emoji, Color color) {
    return GestureDetector(
      onTap: () => _shareToSpecificApp(platform),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color == Color(0xFF000000) ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeButton(String label, String type, IconData icon) {
    final isSelected = _selectedMediaType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _selectedMediaType.value = type;
          setState(() {
            _selectedMedia = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonCyan : AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformChip(String platformId, Map<String, String> info) {
    return Obx(() {
      final isSelected = _selectedPlatforms.contains(platformId);
      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(info['icon'] ?? '📱'),
            const SizedBox(width: 8),
            Text(info['displayName'] ?? platformId),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _selectedPlatforms.add(platformId);
          } else {
            _selectedPlatforms.remove(platformId);
          }
        },
        backgroundColor: AppColors.darkCard,
        selectedColor: Color(int.parse('0xFF${info['color'] ?? '1877F2'}')),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textLight,
        ),
      );
    });
  }
}
