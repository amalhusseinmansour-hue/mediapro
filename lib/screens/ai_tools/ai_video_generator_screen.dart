import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../services/ai_media_service.dart';

/// شاشة مولد الفيديو بالذكاء الاصطناعي
/// يدعم: Veo 3, Veo 2, Replicate, Runway
class AIVideoGeneratorScreen extends StatefulWidget {
  const AIVideoGeneratorScreen({super.key});

  @override
  State<AIVideoGeneratorScreen> createState() => _AIVideoGeneratorScreenState();
}

class _AIVideoGeneratorScreenState extends State<AIVideoGeneratorScreen>
    with TickerProviderStateMixin {
  AIMediaService? _aiMediaService;
  final TextEditingController _promptController = TextEditingController();

  bool _isGenerating = false;
  bool _showAdvancedOptions = false;

  // Video settings
  String _selectedProvider = 'veo3';
  int _selectedDuration = 8;
  String _selectedAspectRatio = '16:9';

  // Generated videos
  final List<GeneratedVideo> _generatedVideos = [];
  VideoPlayerController? _videoController;
  int? _playingIndex;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;

  final List<String> _providers = ['veo3', 'veo2', 'replicate', 'runway'];
  final Map<String, String> _providerNames = {
    'veo3': 'Google Veo 3 (الأفضل)',
    'veo2': 'Google Veo 2',
    'replicate': 'Replicate',
    'runway': 'Runway Gen-3',
  };

  final List<int> _durationOptions = [5, 8, 10, 15, 20, 30];
  final List<String> _aspectRatios = ['16:9', '9:16', '1:1', '4:3'];

  // Prompt suggestions
  final List<String> _promptSuggestions = [
    'منظر طبيعي خلاب لشروق الشمس فوق الجبال',
    'مقهى مريح في يوم ماطر مع أصوات المطر',
    'حركة بطيئة لأمواج البحر على شاطئ رملي ذهبي',
    'مدينة مستقبلية ليلاً مع أضواء نيون متحركة',
    'حديقة يابانية هادئة مع أزهار الكرز المتساقطة',
    'سيارة رياضية تسير على طريق جبلي متعرج',
    'فراشات ملونة تطير في حقل من الزهور',
    'قطرات ماء تتساقط في حركة بطيئة',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

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
    _fadeController.dispose();
    _pulseController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _generateVideo() async {
    if (_promptController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال وصف للفيديو',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (_aiMediaService == null) {
      Get.snackbar(
        'خطأ',
        'خدمة الذكاء الاصطناعي غير متوفرة',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final result = await _aiMediaService!.generateVideo(
        prompt: _promptController.text.trim(),
        duration: _selectedDuration,
      );

      if (result['success'] == true) {
        final newVideo = GeneratedVideo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          prompt: _promptController.text.trim(),
          videoUrl: result['video_url'] ?? '',
          provider: result['provider'] ?? _selectedProvider,
          model: result['model'] ?? '',
          duration: result['duration'] ?? _selectedDuration,
          aspectRatio: result['aspect_ratio'] ?? _selectedAspectRatio,
          createdAt: DateTime.now(),
        );

        setState(() {
          _generatedVideos.insert(0, newVideo);
          _isGenerating = false;
        });

        Get.snackbar(
          'تم بنجاح!',
          'تم إنشاء الفيديو بنجاح',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        throw Exception(result['error'] ?? result['message'] ?? 'خطأ غير معروف');
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _playVideo(int index) async {
    final video = _generatedVideos[index];

    if (_playingIndex == index && _videoController?.value.isPlaying == true) {
      await _videoController?.pause();
      setState(() {});
      return;
    }

    await _videoController?.dispose();

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
      await _videoController!.initialize();
      await _videoController!.play();
      await _videoController!.setLooping(true);

      setState(() {
        _playingIndex = index;
      });

      _showVideoPlayer(video);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تشغيل الفيديو: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _showVideoPlayer(GeneratedVideo video) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معاينة الفيديو',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            video.provider.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _videoController?.pause();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),

              // Video Player
              Flexible(
                child: AspectRatio(
                  aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                  child: _videoController?.value.isInitialized == true
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoController!),
                            // Play/Pause overlay
                            GestureDetector(
                              onTap: () {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                                setState(() {});
                              },
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryPurple,
                          ),
                        ),
                ),
              ),

              // Video Controls
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.download_rounded,
                      label: 'تحميل',
                      color: AppColors.success,
                      onTap: () => _downloadVideo(video),
                    ),
                    _buildControlButton(
                      icon: Icons.share_rounded,
                      label: 'مشاركة',
                      color: AppColors.neonBlue,
                      onTap: () => _shareVideo(video),
                    ),
                    _buildControlButton(
                      icon: Icons.copy_rounded,
                      label: 'نسخ الرابط',
                      color: AppColors.primaryPurple,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: video.videoUrl));
                        Get.snackbar(
                          'تم',
                          'تم نسخ رابط الفيديو',
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadVideo(GeneratedVideo video) async {
    try {
      Get.snackbar(
        'جاري التحميل...',
        'يرجى الانتظار',
        backgroundColor: AppColors.primaryPurple,
        colorText: Colors.white,
        showProgressIndicator: true,
      );

      final response = await http.get(Uri.parse(video.videoUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'ai_video_${video.id}.mp4';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        Get.snackbar(
          'تم التحميل!',
          'تم حفظ الفيديو بنجاح',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الفيديو: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _shareVideo(GeneratedVideo video) async {
    try {
      await Share.share(
        'شاهد هذا الفيديو المذهل الذي تم إنشاؤه بالذكاء الاصطناعي!\n\n${video.videoUrl}',
        subject: 'فيديو AI - ${video.prompt}',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في مشاركة الفيديو',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'مولد الفيديو بالذكاء الاصطناعي',
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
          if (_generatedVideos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () {
                setState(() {
                  _generatedVideos.clear();
                });
              },
              tooltip: 'مسح الكل',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Selection
              _buildProviderSelector(),

              const SizedBox(height: 20),

              // Prompt Input
              _buildPromptInput(),

              const SizedBox(height: 16),

              // Prompt Suggestions
              _buildPromptSuggestions(),

              const SizedBox(height: 20),

              // Advanced Options
              _buildAdvancedOptions(),

              const SizedBox(height: 24),

              // Generate Button
              _buildGenerateButton(),

              const SizedBox(height: 24),

              // Generated Videos Gallery
              if (_generatedVideos.isNotEmpty) _buildVideosGallery(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.2),
            AppColors.neonBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.video_camera_back_rounded,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'اختر مزود الخدمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _providers.map((provider) {
              final isSelected = _selectedProvider == provider;
              return InkWell(
                onTap: () => setState(() => _selectedProvider = provider),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primaryPurple, AppColors.neonBlue],
                          )
                        : null,
                    color: isSelected ? null : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getProviderIcon(provider),
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _providerNames[provider] ?? provider,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[400],
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
    );
  }

  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case 'veo3':
        return Icons.star_rounded;
      case 'veo2':
        return Icons.videocam_rounded;
      case 'replicate':
        return Icons.memory_rounded;
      case 'runway':
        return Icons.flight_takeoff_rounded;
      default:
        return Icons.video_camera_back_rounded;
    }
  }

  Widget _buildPromptInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                'وصف الفيديو',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _promptController.clear(),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('مسح'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'صف الفيديو الذي تريد إنشاءه بالتفصيل...\nمثال: منظر غروب الشمس على شاطئ استوائي مع أمواج هادئة',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: Colors.amber[400], size: 20),
            const SizedBox(width: 8),
            Text(
              'اقتراحات',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _promptSuggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _promptController.text = _promptSuggestions[index];
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _promptSuggestions[index].length > 30
                        ? '${_promptSuggestions[index].substring(0, 30)}...'
                        : _promptSuggestions[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'خيارات متقدمة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showAdvancedOptions ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Options
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 12),

                  // Duration
                  _buildOptionRow(
                    label: 'المدة (ثانية)',
                    child: Wrap(
                      spacing: 8,
                      children: _durationOptions.map((duration) {
                        final isSelected = _selectedDuration == duration;
                        return ChoiceChip(
                          label: Text('$duration'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedDuration = duration);
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
                  ),

                  const SizedBox(height: 16),

                  // Aspect Ratio
                  _buildOptionRow(
                    label: 'نسبة العرض',
                    child: Wrap(
                      spacing: 8,
                      children: _aspectRatios.map((ratio) {
                        final isSelected = _selectedAspectRatio == ratio;
                        return ChoiceChip(
                          label: Text(ratio),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedAspectRatio = ratio);
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
                  ),

                  const SizedBox(height: 16),

                  // Provider Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getProviderInfo(_selectedProvider),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _showAdvancedOptions
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  String _getProviderInfo(String provider) {
    switch (provider) {
      case 'veo3':
        return 'Veo 3 هو أحدث نموذج من Google - يدعم حتى 30 ثانية مع جودة سينمائية عالية';
      case 'veo2':
        return 'Veo 2 - جودة ممتازة حتى 16 ثانية، أرخص من Veo 3';
      case 'replicate':
        return 'Replicate - مجموعة متنوعة من نماذج الفيديو مفتوحة المصدر';
      case 'runway':
        return 'Runway Gen-3 - نموذج احترافي لإنتاج الفيديوهات';
      default:
        return '';
    }
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateVideo,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          disabledBackgroundColor: AppColors.primaryPurple.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.5 + (_pulseController.value * 0.5),
                        child: const Text(
                          'جاري إنشاء الفيديو...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'إنشاء الفيديو',
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

  Widget _buildVideosGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.video_library_rounded,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 8),
            const Text(
              'الفيديوهات المُنشأة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '${_generatedVideos.length} فيديو',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _generatedVideos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final video = _generatedVideos[index];
            return _buildVideoCard(video, index);
          },
        ),
      ],
    );
  }

  Widget _buildVideoCard(GeneratedVideo video, int index) {
    final isPlaying = _playingIndex == index && _videoController?.value.isPlaying == true;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying
              ? AppColors.primaryPurple
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail / Player
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.3),
                      AppColors.neonBlue.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),

              // Play button overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _playVideo(index),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ),

              // Duration badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${video.duration}s',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Provider badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    video.provider.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Video Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.prompt,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.aspect_ratio_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      video.aspectRatio,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(video.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Spacer(),
                    // Action buttons
                    IconButton(
                      icon: const Icon(Icons.download_rounded),
                      color: AppColors.success,
                      iconSize: 20,
                      onPressed: () => _downloadVideo(video),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      color: AppColors.neonBlue,
                      iconSize: 20,
                      onPressed: () => _shareVideo(video),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: AppColors.error,
                      iconSize: 20,
                      onPressed: () {
                        setState(() {
                          _generatedVideos.removeAt(index);
                          if (_playingIndex == index) {
                            _videoController?.dispose();
                            _playingIndex = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return '${time.day}/${time.month}/${time.year}';
  }
}

/// نموذج الفيديو المُنشأ
class GeneratedVideo {
  final String id;
  final String prompt;
  final String videoUrl;
  final String provider;
  final String model;
  final int duration;
  final String aspectRatio;
  final DateTime createdAt;

  GeneratedVideo({
    required this.id,
    required this.prompt,
    required this.videoUrl,
    required this.provider,
    required this.model,
    required this.duration,
    required this.aspectRatio,
    required this.createdAt,
  });
}
