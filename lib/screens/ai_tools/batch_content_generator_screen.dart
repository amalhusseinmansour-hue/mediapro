import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ai_media_service.dart';
import '../../services/gemini_service.dart';

/// شاشة توليد المحتوى بالجملة
/// تتيح إنشاء عدة منشورات وصور وفيديوهات دفعة واحدة
class BatchContentGeneratorScreen extends StatefulWidget {
  const BatchContentGeneratorScreen({super.key});

  @override
  State<BatchContentGeneratorScreen> createState() => _BatchContentGeneratorScreenState();
}

class _BatchContentGeneratorScreenState extends State<BatchContentGeneratorScreen>
    with TickerProviderStateMixin {
  AIMediaService? _aiMediaService;
  GeminiService? _geminiService;

  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  bool _isGenerating = false;
  double _progress = 0.0;
  String _currentTask = '';

  // Content settings
  int _postCount = 5;
  int _imageCount = 3;
  bool _generateVideos = false;
  bool _includeHashtags = true;
  bool _includeEmojis = true;

  // Platform selection
  final Map<String, bool> _selectedPlatforms = {
    'instagram': true,
    'facebook': true,
    'twitter': false,
    'linkedin': false,
    'tiktok': false,
  };

  // Generated content
  final List<GeneratedBatchContent> _generatedContent = [];

  // Tone selection
  String _selectedTone = 'professional';
  final Map<String, String> _toneOptions = {
    'professional': 'احترافي',
    'casual': 'عفوي',
    'friendly': 'ودود',
    'formal': 'رسمي',
    'humorous': 'فكاهي',
    'inspirational': 'ملهم',
    'educational': 'تعليمي',
  };

  late AnimationController _fadeController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize services
    try {
      _aiMediaService = Get.find<AIMediaService>();
    } catch (e) {
      print('AIMediaService not found: $e');
    }

    try {
      _geminiService = Get.find<GeminiService>();
    } catch (e) {
      print('GeminiService not found: $e');
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _brandController.dispose();
    _keywordsController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _generateBatchContent() async {
    if (_topicController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال موضوع المحتوى',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _progress = 0.0;
      _generatedContent.clear();
    });

    try {
      final topic = _topicController.text.trim();
      final brand = _brandController.text.trim();
      final keywords = _keywordsController.text.trim();
      final platforms = _selectedPlatforms.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      int totalTasks = _postCount + (_imageCount > 0 ? _imageCount : 0) + (_generateVideos ? 1 : 0);
      int completedTasks = 0;

      // Generate text posts
      for (int i = 0; i < _postCount; i++) {
        setState(() {
          _currentTask = 'جاري إنشاء المنشور ${i + 1} من $_postCount...';
        });

        final post = await _generateSinglePost(
          topic: topic,
          brand: brand,
          keywords: keywords,
          platforms: platforms,
          postNumber: i + 1,
        );

        if (post != null) {
          setState(() {
            _generatedContent.add(post);
          });
        }

        completedTasks++;
        setState(() {
          _progress = completedTasks / totalTasks;
        });

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Generate images
      if (_imageCount > 0 && _aiMediaService != null) {
        for (int i = 0; i < _imageCount; i++) {
          setState(() {
            _currentTask = 'جاري إنشاء الصورة ${i + 1} من $_imageCount...';
          });

          try {
            final imageResult = await _aiMediaService!.generateImage(
              prompt: '$topic - صورة جذابة لوسائل التواصل الاجتماعي - ${i + 1}',
            );

            if (imageResult['success'] == true) {
              setState(() {
                _generatedContent.add(GeneratedBatchContent(
                  type: ContentType.image,
                  content: 'صورة: $topic',
                  imageUrl: imageResult['image_url'],
                  platforms: platforms,
                ));
              });
            }
          } catch (e) {
            print('Error generating image $i: $e');
          }

          completedTasks++;
          setState(() {
            _progress = completedTasks / totalTasks;
          });

          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Generate video (if enabled)
      if (_generateVideos && _aiMediaService != null) {
        setState(() {
          _currentTask = 'جاري إنشاء الفيديو...';
        });

        try {
          final videoResult = await _aiMediaService!.generateVideo(
            prompt: '$topic - فيديو قصير جذاب لوسائل التواصل الاجتماعي',
            duration: 8,
          );

          if (videoResult['success'] == true) {
            setState(() {
              _generatedContent.add(GeneratedBatchContent(
                type: ContentType.video,
                content: 'فيديو: $topic',
                videoUrl: videoResult['video_url'],
                platforms: platforms,
              ));
            });
          }
        } catch (e) {
          print('Error generating video: $e');
        }

        completedTasks++;
        setState(() {
          _progress = completedTasks / totalTasks;
        });
      }

      setState(() {
        _isGenerating = false;
        _currentTask = '';
      });

      Get.snackbar(
        'تم بنجاح!',
        'تم إنشاء ${_generatedContent.length} محتوى',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _currentTask = '';
      });

      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<GeneratedBatchContent?> _generateSinglePost({
    required String topic,
    required String brand,
    required String keywords,
    required List<String> platforms,
    required int postNumber,
  }) async {
    if (_geminiService == null) return null;

    try {
      final prompt = '''
أنت خبير في كتابة محتوى وسائل التواصل الاجتماعي.
اكتب منشوراً فريداً ومميزاً عن: $topic
${brand.isNotEmpty ? 'العلامة التجارية: $brand' : ''}
${keywords.isNotEmpty ? 'الكلمات المفتاحية: $keywords' : ''}

المتطلبات:
- النغمة: ${_toneOptions[_selectedTone]}
- المنصات المستهدفة: ${platforms.join(', ')}
${_includeHashtags ? '- أضف هاشتاقات مناسبة' : '- بدون هاشتاقات'}
${_includeEmojis ? '- أضف إيموجي مناسبة' : '- بدون إيموجي'}
- هذا المنشور رقم $postNumber من $_postCount، اجعله مختلفاً عن السابقين

اكتب المنشور فقط بدون أي شرح إضافي.
''';

      final response = await _geminiService!.generateContent(prompt: prompt);

      if (response.isNotEmpty) {
        return GeneratedBatchContent(
          type: ContentType.post,
          content: response,
          platforms: platforms,
        );
      }
    } catch (e) {
      print('Error generating post $postNumber: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'مولد المحتوى بالجملة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_generatedContent.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: _exportContent,
              tooltip: 'تصدير الكل',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic Input
              _buildTopicSection(),

              const SizedBox(height: 20),

              // Platform Selection
              _buildPlatformSelector(),

              const SizedBox(height: 20),

              // Content Settings
              _buildContentSettings(),

              const SizedBox(height: 20),

              // Tone Selection
              _buildToneSelector(),

              const SizedBox(height: 24),

              // Generate Button
              _buildGenerateButton(),

              const SizedBox(height: 24),

              // Progress
              if (_isGenerating) _buildProgressSection(),

              // Generated Content
              if (_generatedContent.isNotEmpty) _buildGeneratedContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.neonBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.topic_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'موضوع المحتوى',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Topic
          TextField(
            controller: _topicController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'مثال: نصائح للتسويق الرقمي',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.lightbulb_outline, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 12),

          // Brand
          TextField(
            controller: _brandController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'اسم العلامة التجارية (اختياري)',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.business, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 12),

          // Keywords
          TextField(
            controller: _keywordsController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'كلمات مفتاحية (اختياري، مفصولة بفاصلة)',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.tag, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المنصات المستهدفة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _selectedPlatforms.keys.map((platform) {
              final isSelected = _selectedPlatforms[platform] ?? false;
              return FilterChip(
                label: Text(_getPlatformName(platform)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPlatforms[platform] = selected;
                  });
                },
                avatar: Icon(
                  _getPlatformIcon(platform),
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                backgroundColor: AppColors.backgroundDark,
                selectedColor: _getPlatformColor(platform),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات المحتوى',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Post count slider
          _buildSliderOption(
            label: 'عدد المنشورات',
            value: _postCount,
            min: 1,
            max: 10,
            icon: Icons.article_rounded,
            onChanged: (value) => setState(() => _postCount = value.toInt()),
          ),

          const SizedBox(height: 16),

          // Image count slider
          _buildSliderOption(
            label: 'عدد الصور',
            value: _imageCount,
            min: 0,
            max: 5,
            icon: Icons.image_rounded,
            onChanged: (value) => setState(() => _imageCount = value.toInt()),
          ),

          const SizedBox(height: 16),

          // Toggle options
          SwitchListTile(
            title: const Text('إنشاء فيديو', style: TextStyle(color: Colors.white)),
            subtitle: Text('فيديو واحد بالذكاء الاصطناعي', style: TextStyle(color: Colors.grey[600])),
            value: _generateVideos,
            onChanged: (value) => setState(() => _generateVideos = value),
            activeThumbColor: AppColors.primaryPurple,
            contentPadding: EdgeInsets.zero,
          ),

          SwitchListTile(
            title: const Text('تضمين هاشتاقات', style: TextStyle(color: Colors.white)),
            value: _includeHashtags,
            onChanged: (value) => setState(() => _includeHashtags = value),
            activeThumbColor: AppColors.primaryPurple,
            contentPadding: EdgeInsets.zero,
          ),

          SwitchListTile(
            title: const Text('تضمين إيموجي', style: TextStyle(color: Colors.white)),
            value: _includeEmojis,
            onChanged: (value) => setState(() => _includeEmojis = value),
            activeThumbColor: AppColors.primaryPurple,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderOption({
    required String label,
    required int value,
    required double min,
    required double max,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              '$label: $value',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toString(),
          activeColor: AppColors.primaryPurple,
          inactiveColor: Colors.grey[800],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildToneSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نغمة المحتوى',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _toneOptions.entries.map((entry) {
              final isSelected = _selectedTone == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedTone = entry.key);
                  }
                },
                backgroundColor: AppColors.backgroundDark,
                selectedColor: AppColors.primaryPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateBatchContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          disabledBackgroundColor: AppColors.primaryPurple.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'جاري الإنشاء...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'إنشاء المحتوى',
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

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentTask,
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'المحتوى المُنشأ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${_generatedContent.length} عنصر',
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _generatedContent.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildContentCard(_generatedContent[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildContentCard(GeneratedBatchContent content, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getContentTypeColor(content.type).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getContentTypeColor(content.type).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getContentTypeIcon(content.type),
                  color: _getContentTypeColor(content.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getContentTypeName(content.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content.content));
                  Get.snackbar('تم', 'تم نسخ المحتوى', backgroundColor: AppColors.success, colorText: Colors.white);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content.content,
            style: TextStyle(
              color: Colors.grey[300],
              height: 1.5,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          if (content.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                content.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: content.platforms.map((platform) {
              return Chip(
                label: Text(
                  _getPlatformName(platform),
                  style: const TextStyle(fontSize: 10),
                ),
                avatar: Icon(_getPlatformIcon(platform), size: 14),
                backgroundColor: _getPlatformColor(platform).withValues(alpha: 0.2),
                labelStyle: TextStyle(color: _getPlatformColor(platform)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _exportContent() {
    final buffer = StringBuffer();
    buffer.writeln('=== المحتوى المُنشأ ===\n');

    for (int i = 0; i < _generatedContent.length; i++) {
      final content = _generatedContent[i];
      buffer.writeln('--- ${_getContentTypeName(content.type)} ${i + 1} ---');
      buffer.writeln(content.content);
      if (content.imageUrl != null) {
        buffer.writeln('رابط الصورة: ${content.imageUrl}');
      }
      if (content.videoUrl != null) {
        buffer.writeln('رابط الفيديو: ${content.videoUrl}');
      }
      buffer.writeln('');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Get.snackbar(
      'تم التصدير!',
      'تم نسخ كل المحتوى للحافظة',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  String _getPlatformName(String platform) {
    switch (platform) {
      case 'instagram': return 'إنستغرام';
      case 'facebook': return 'فيسبوك';
      case 'twitter': return 'تويتر';
      case 'linkedin': return 'لينكد إن';
      case 'tiktok': return 'تيك توك';
      default: return platform;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'instagram': return Icons.camera_alt_rounded;
      case 'facebook': return Icons.facebook_rounded;
      case 'twitter': return Icons.alternate_email_rounded;
      case 'linkedin': return Icons.work_rounded;
      case 'tiktok': return Icons.music_note_rounded;
      default: return Icons.public_rounded;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'instagram': return Colors.pink;
      case 'facebook': return Colors.blue;
      case 'twitter': return Colors.lightBlue;
      case 'linkedin': return Colors.blueAccent;
      case 'tiktok': return Colors.black;
      default: return Colors.grey;
    }
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.post: return Icons.article_rounded;
      case ContentType.image: return Icons.image_rounded;
      case ContentType.video: return Icons.videocam_rounded;
    }
  }

  Color _getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.post: return AppColors.neonBlue;
      case ContentType.image: return AppColors.success;
      case ContentType.video: return AppColors.primaryPurple;
    }
  }

  String _getContentTypeName(ContentType type) {
    switch (type) {
      case ContentType.post: return 'منشور نصي';
      case ContentType.image: return 'صورة';
      case ContentType.video: return 'فيديو';
    }
  }
}

enum ContentType { post, image, video }

class GeneratedBatchContent {
  final ContentType type;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> platforms;

  GeneratedBatchContent({
    required this.type,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.platforms,
  });
}
