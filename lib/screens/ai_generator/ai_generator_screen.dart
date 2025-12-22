import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ai_service.dart';
import '../../services/subscription_service.dart';
import 'dart:ui';

class AIGeneratorScreen extends StatefulWidget {
  const AIGeneratorScreen({super.key});

  @override
  State<AIGeneratorScreen> createState() => _AIGeneratorScreenState();
}

class _AIGeneratorScreenState extends State<AIGeneratorScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _aiService = AIService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppColors.purpleMagentaGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPurple.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Colors.white70],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الذكاء الاصطناعي',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'إنشاء محتوى بقوة AI',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.text_fields_rounded, size: 18),
                        text: 'النصوص',
                      ),
                      Tab(
                        icon: Icon(Icons.image_rounded, size: 18),
                        text: 'الصور',
                      ),
                      Tab(
                        icon: Icon(Icons.videocam_rounded, size: 18),
                        text: 'الفيديو',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _TextGeneratorTab(aiService: _aiService),
            _ImageGeneratorTab(aiService: _aiService),
            _VideoGeneratorTab(aiService: _aiService),
          ],
        ),
      ),
    );
  }
}

class _TextGeneratorTab extends StatefulWidget {
  final AIService aiService;

  const _TextGeneratorTab({required this.aiService});

  @override
  State<_TextGeneratorTab> createState() => _TextGeneratorTabState();
}

class _TextGeneratorTabState extends State<_TextGeneratorTab> {
  final _promptController = TextEditingController();
  String? _generatedText;
  bool _isLoading = false;
  String _selectedModel = 'Gemini';  // Gemini هو المزود الأساسي (Primary Provider)
  String _selectedTone = 'محترف';
  String _selectedLanguage = 'العربية';
  int _aiRequestsThisMonth = 0;

  SubscriptionService? get _subscriptionService {
    try {
      return Get.find<SubscriptionService>();
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateText() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال وصف للمحتوى'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check subscription limits for AI usage
    if (_subscriptionService != null) {
      final canUse = await _subscriptionService!.canUseAI(_aiRequestsThisMonth);
      if (!canUse) {
        return; // Subscription service will show upgrade dialog
      }
    }

    setState(() {
      _isLoading = true;
      _generatedText = null;
    });

    try {
      String result;
      if (_selectedModel == 'ChatGPT') {
        result = await widget.aiService.generateContentWithChatGPT(
          _promptController.text,
          tone: _selectedTone,
          language: _selectedLanguage,
        );
      } else {
        result = await widget.aiService.generateContentWithGemini(
          _promptController.text,
          tone: _selectedTone,
          language: _selectedLanguage,
        );
      }

      setState(() {
        _generatedText = result;
        _aiRequestsThisMonth++; // Increment AI usage counter
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Model Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.lightGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر نموذج الذكاء الاصطناعي',
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
                      child: _buildModelCard('Gemini', Icons.auto_awesome),  // Primary
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModelCard('ChatGPT', Icons.chat),  // Backup
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tone Selector
          Text(
            'أسلوب الكتابة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['محترف', 'ودود', 'رسمي', 'إبداعي', 'تسويقي'].map((tone) {
              final isSelected = _selectedTone == tone;
              return ChoiceChip(
                label: Text(tone),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedTone = tone;
                  });
                },
                selectedColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Language Selector
          Text(
            'اللغة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['العربية', 'English', 'Français'].map((lang) {
              final isSelected = _selectedLanguage == lang;
              return ChoiceChip(
                label: Text(lang),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedLanguage = lang;
                  });
                },
                selectedColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Prompt Input
          TextFormField(
            controller: _promptController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'اكتب وصف المحتوى المطلوب',
              hintText: 'مثال: اكتب منشور تسويقي عن منتج جديد للعناية بالبشرة',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: Container(
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
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateText,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  _isLoading ? 'جاري التوليد...' : 'توليد المحتوى',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Generated Text Display
          if (_generatedText != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryPurple, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purpleShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'المحتوى المولد',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // TODO: Copy to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم النسخ إلى الحافظة'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _generatedText!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModelCard(String model, IconData icon) {
    final isSelected = _selectedModel == model;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModel = model;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryPurple : Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              model,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryPurple : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGeneratorTab extends StatefulWidget {
  final AIService aiService;

  const _ImageGeneratorTab({required this.aiService});

  @override
  State<_ImageGeneratorTab> createState() => _ImageGeneratorTabState();
}

class _ImageGeneratorTabState extends State<_ImageGeneratorTab> {
  final _promptController = TextEditingController();
  String? _generatedImageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال وصف للصورة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl = await widget.aiService.generateImage(_promptController.text);
      setState(() {
        _generatedImageUrl = imageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.image, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'توليد الصور بالذكاء الاصطناعي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'اكتب وصف للصورة وسيقوم الذكاء الاصطناعي بإنشائها',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _promptController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'وصف الصورة',
              hintText: 'مثال: صورة احترافية لمنتج عناية بالبشرة على خلفية وردية',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateImage,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'جاري التوليد...' : 'توليد الصورة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_generatedImageUrl != null) ...[
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _generatedImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: AppColors.offWhite,
                      child: const Center(
                        child: Text('فشل تحميل الصورة'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoGeneratorTab extends StatelessWidget {
  final AIService aiService;

  const _VideoGeneratorTab({required this.aiService});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.video_library,
                size: 80,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'توليد الفيديوهات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'قريباً: سنضيف ميزة توليد الفيديوهات بالذكاء الاصطناعي',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
