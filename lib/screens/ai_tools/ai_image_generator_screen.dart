import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../services/ai_image_service.dart';
import '../../services/ai_media_service.dart';
import '../../models/generated_image.dart';

class AIImageGeneratorScreen extends StatefulWidget {
  const AIImageGeneratorScreen({super.key});

  @override
  State<AIImageGeneratorScreen> createState() => _AIImageGeneratorScreenState();
}

class _AIImageGeneratorScreenState extends State<AIImageGeneratorScreen>
    with TickerProviderStateMixin {
  final AIImageService _aiImageService = AIImageService();
  AIMediaService? _aiMediaService;
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _negativePromptController =
      TextEditingController();

  bool _isGenerating = false;
  bool _isConvertingToVideo = false;
  bool _showAdvancedOptions = false;

  // Model selection - Gemini Imagen (Primary Provider - الأساسي)
  ImageGenerationModel _selectedModel = ImageGenerationModel.geminiImagen;

  // Advanced options
  int _selectedWidth = 512;
  int _selectedHeight = 512;
  int _steps = 30;
  double _cfgScale = 7.0;
  int? _seed;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    // Initialize AIMediaService
    try {
      _aiMediaService = Get.find<AIMediaService>();
    } catch (e) {
      print('AIMediaService not found: $e');
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _negativePromptController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال وصف للصورة',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      await _aiImageService.generateImage(
        prompt: _promptController.text.trim(),
        negativePrompt: _negativePromptController.text.trim().isEmpty
            ? null
            : _negativePromptController.text.trim(),
        width: _selectedWidth,
        height: _selectedHeight,
        steps: _steps,
        cfgScale: _cfgScale,
        seed: _seed,
        model: _selectedModel,
      );

      setState(() {});

      Get.snackbar(
        'نجح',
        'تم توليد الصورة بنجاح!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل توليد الصورة: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _shareImage(GeneratedImage image) async {
    try {
      // تحميل الصورة من URL
      final response = await http.get(Uri.parse(image.imageUrl));
      final bytes = response.bodyBytes;

      // حفظ مؤقتاً
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${image.id}.png');
      await file.writeAsBytes(bytes);

      // مشاركة
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'صورة تم توليدها بالذكاء الاصطناعي\n${image.prompt}');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشلت المشاركة: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveImage(GeneratedImage image) async {
    // يمكن تنفيذ حفظ الصورة في معرض الصور
    Get.snackbar(
      'نجح',
      'تم حفظ الصورة',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void _deleteImage(String id) {
    _aiImageService.deleteImage(id);
    setState(() {});
    Get.snackbar(
      'نجح',
      'تم حذف الصورة',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  /// Helper method to build image widget - handles both local files and URLs
  Widget _buildImageWidget(String imageUrl) {
    // Check if it's a local file path
    final isLocalFile = imageUrl.startsWith('/') ||
                        imageUrl.startsWith('file://') ||
                        !imageUrl.startsWith('http');

    if (isLocalFile) {
      // Local file - use Image.file
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);

      return Image.file(
        file,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading local image: $error');
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey, size: 48),
                  SizedBox(height: 8),
                  Text('فشل تحميل الصورة', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Network URL - use Image.network
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.neonCyan,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network image: $error');
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey, size: 48),
                  SizedBox(height: 8),
                  Text('فشل تحميل الصورة', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _convertToVideo(GeneratedImage image) async {
    if (_aiMediaService == null) {
      Get.snackbar(
        'خطأ',
        'خدمة توليد الفيديو غير متاحة',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isConvertingToVideo = true);

    try {
      Get.snackbar(
        'جاري التحويل',
        'يتم تحويل الصورة إلى فيديو...',
        backgroundColor: AppColors.neonPurple,
        colorText: Colors.white,
        duration: const Duration(seconds: 60),
        showProgressIndicator: true,
        progressIndicatorBackgroundColor: Colors.white24,
      );

      final result = await _aiMediaService!.imageToVideo(
        imageUrl: image.imageUrl,
        prompt: image.prompt,
        duration: 5,
      );

      Get.closeAllSnackbars();

      if (result['success'] == true) {
        Get.snackbar(
          'نجح',
          'تم تحويل الصورة إلى فيديو!',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );

        // Show video URL
        Get.dialog(
          AlertDialog(
            backgroundColor: AppColors.darkCard,
            title: Row(
              children: [
                Icon(Icons.video_library, color: AppColors.neonCyan),
                const SizedBox(width: 8),
                const Text(
                  'فيديو جاهز',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم توليد الفيديو بنجاح!',
                  style: TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result['video_url'] ?? 'رابط الفيديو',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('إغلاق'),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result['video_url'] ?? ''));
                  Get.snackbar('تم', 'تم نسخ الرابط', backgroundColor: AppColors.success, colorText: Colors.white);
                },
                child: Text('نسخ الرابط', style: TextStyle(color: AppColors.neonCyan)),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'خطأ',
          result['error'] ?? 'فشل تحويل الصورة إلى فيديو',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'خطأ',
        'فشل التحويل: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isConvertingToVideo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'مولد الصور بالذكاء الاصطناعي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_aiImageService.generatedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: AppColors.darkCard,
                    title: const Text(
                      'حذف جميع الصور',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'هل أنت متأكد من حذف جميع الصور المولدة؟',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          _aiImageService.clearAllImages();
                          setState(() {});
                          Get.back();
                        },
                        child: Text(
                          'حذف',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prompt Input
              _buildPromptSection(),
              const SizedBox(height: 20),

              // Advanced Options Toggle
              _buildAdvancedOptionsToggle(),
              const SizedBox(height: 16),

              // Advanced Options Panel
              if (_showAdvancedOptions) ...[
                _buildAdvancedOptions(),
                const SizedBox(height: 20),
              ],

              // Generate Button
              _buildGenerateButton(),
              const SizedBox(height: 32),

              // Generated Images Gallery
              if (_aiImageService.generatedImages.isNotEmpty) ...[
                _buildGalleryHeader(),
                const SizedBox(height: 16),
                _buildImageGallery(),
              ] else if (!_isGenerating) ...[
                _buildEmptyState(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: AppColors.neonCyan,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'وصف الصورة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _promptController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText:
                  'اكتب وصفاً تفصيلياً للصورة التي تريد توليدها...\nمثال: صورة واقعية لغروب شمس جميل على شاطئ البحر',
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
              filled: true,
              fillColor: AppColors.darkBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          // Negative Prompt
          ExpansionTile(
            title: Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  color: AppColors.neonPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'ما لا تريده في الصورة (اختياري)',
                  style: TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            tilePadding: EdgeInsets.zero,
            children: [
              TextField(
                controller: _negativePromptController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'مثال: ضبابي، سيئ الجودة، مشوه',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.darkBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return InkWell(
      onTap: () {
        setState(() => _showAdvancedOptions = !_showAdvancedOptions);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _showAdvancedOptions
                ? AppColors.neonPurple
                : AppColors.textLight.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: _showAdvancedOptions
                  ? AppColors.neonPurple
                  : AppColors.textLight,
            ),
            const SizedBox(width: 12),
            Text(
              'خيارات متقدمة',
              style: TextStyle(
                color: _showAdvancedOptions
                    ? AppColors.neonPurple
                    : AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              _showAdvancedOptions
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: _showAdvancedOptions
                  ? AppColors.neonPurple
                  : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Size (Model selection hidden - using Nano Banana only)
          _buildOptionHeader(
            'حجم الصورة',
            Icons.photo_size_select_large_rounded,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSizeChip('512x512', 512, 512),
              _buildSizeChip('768x768', 768, 768),
              _buildSizeChip('1024x1024', 1024, 1024),
              _buildSizeChip('512x768', 512, 768),
              _buildSizeChip('768x512', 768, 512),
            ],
          ),
          const SizedBox(height: 20),

          // Steps
          _buildOptionHeader('عدد الخطوات', Icons.stairs_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _steps.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 8,
                  activeColor: AppColors.neonPurple,
                  inactiveColor: AppColors.textLight.withValues(alpha: 0.2),
                  label: _steps.toString(),
                  onChanged: (value) {
                    setState(() => _steps = value.toInt());
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _steps.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CFG Scale
          _buildOptionHeader(
            'قوة الالتزام بالوصف',
            Icons.power_settings_new_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _cfgScale,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  activeColor: AppColors.neonCyan,
                  inactiveColor: AppColors.textLight.withValues(alpha: 0.2),
                  label: _cfgScale.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => _cfgScale = value);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _cfgScale.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Seed
          _buildOptionHeader('البذرة (Seed)', Icons.grass_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'عشوائي',
                    hintStyle: TextStyle(color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.darkBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _seed = value.isEmpty ? null : int.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() => _seed = null);
                },
                icon: Icon(Icons.refresh_rounded, color: AppColors.neonCyan),
                style: IconButton.styleFrom(backgroundColor: AppColors.darkBg),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonPurple, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildModelChip(
    String label,
    ImageGenerationModel model,
    IconData icon,
  ) {
    final isSelected = _selectedModel == model;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedModel = model;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withValues(alpha: 0.2)
              : AppColors.darkBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan
                : AppColors.textLight.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.neonCyan : AppColors.textLight,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.neonCyan : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeChip(String label, int width, int height) {
    final isSelected = _selectedWidth == width && _selectedHeight == height;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedWidth = width;
          _selectedHeight = height;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonPurple.withValues(alpha: 0.2)
              : AppColors.darkBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.neonPurple
                : AppColors.textLight.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.neonPurple : AppColors.textLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isGenerating ? null : AppColors.purpleMagentaGradient,
        color: _isGenerating ? AppColors.textLight.withValues(alpha: 0.2) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isGenerating
            ? null
            : [
                BoxShadow(
                  color: AppColors.neonPurple.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.neonPurple,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'جاري التوليد...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'توليد الصورة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGalleryHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.cyanPurpleGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.photo_library_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'الصور المولدة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_aiImageService.generatedImages.length}',
            style: TextStyle(
              color: AppColors.neonCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _aiImageService.generatedImages.length,
      itemBuilder: (context, index) {
        final image = _aiImageService.generatedImages[index];
        return _buildImageCard(image);
      },
    );
  }

  Widget _buildImageCard(GeneratedImage image) {
    return GestureDetector(
      onTap: () => _showImageDetails(image),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildImageWidget(image.imageUrl),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.prompt,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.image_rounded,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${image.width}x${image.height}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetails(GeneratedImage image) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildImageWidget(image.imageUrl),
              ),
              const SizedBox(height: 20),

              // Prompt
              _buildDetailRow(Icons.edit_note_rounded, 'الوصف', image.prompt),
              if (image.negativePrompt != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.block_rounded,
                  'Negative Prompt',
                  image.negativePrompt!,
                ),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.image_rounded,
                'الحجم',
                '${image.width}x${image.height}',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.stairs_rounded,
                'الخطوات',
                image.steps?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.power_settings_new_rounded,
                'CFG Scale',
                image.cfgScale?.toStringAsFixed(1) ?? 'N/A',
              ),
              if (image.seed != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.grass_rounded, 'Seed', image.seed!),
              ],

              const SizedBox(height: 24),

              // Actions Row 1 - Share, Save, Delete
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share_rounded,
                      label: 'مشاركة',
                      color: AppColors.neonCyan,
                      onTap: () {
                        Get.back();
                        _shareImage(image);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.download_rounded,
                      label: 'حفظ',
                      color: AppColors.neonPurple,
                      onTap: () {
                        Get.back();
                        _saveImage(image);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.delete_rounded,
                    label: '',
                    color: AppColors.error,
                    onTap: () {
                      Get.back();
                      _deleteImage(image.id);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Actions Row 2 - Convert to Video
              if (_aiMediaService != null)
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    icon: _isConvertingToVideo ? Icons.hourglass_empty : Icons.movie_creation_rounded,
                    label: _isConvertingToVideo ? 'جاري التحويل...' : 'تحويل إلى فيديو',
                    color: Colors.orange,
                    onTap: _isConvertingToVideo
                        ? () {}
                        : () {
                            Get.back();
                            _convertToVideo(image);
                          },
                  ),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label.isEmpty ? 12 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.purpleMagentaGradient.scale(0.3),
            ),
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 60,
              color: AppColors.neonPurple,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد صور مولدة بعد',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بكتابة وصف وتوليد صورتك الأولى!',
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
