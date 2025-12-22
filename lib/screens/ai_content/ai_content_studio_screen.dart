import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/advanced_ai_content_service.dart';

class AIContentStudioScreen extends StatefulWidget {
  const AIContentStudioScreen({super.key});

  @override
  State<AIContentStudioScreen> createState() => _AIContentStudioScreenState();
}

class _AIContentStudioScreenState extends State<AIContentStudioScreen>
    with SingleTickerProviderStateMixin {
  final AdvancedAIContentService _aiService = Get.put(AdvancedAIContentService());
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  late TabController _tabController;
  final RxString selectedType = 'post'.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _topicController.dispose();
    _keywordsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Content Studio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () => _showHistory(),
            tooltip: 'السجل',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D9FF),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.create_rounded), text: 'إنشاء'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'تحليل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateTab(),
          _buildAnalyzeTab(),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlowingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎨 نوع المحتوى',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContentTypeSelector(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildGlowingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✍️ الموضوع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'مثال: التسويق الرقمي للشركات الناشئة',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF2A2A3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lightbulb_outline, color: Color(0xFF00D9FF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAdvancedSettings(),
          const SizedBox(height: 30),
          Obx(() => _buildGenerateButton()),
          const SizedBox(height: 30),
          Obx(() => _buildGeneratedContent()),
        ],
      ),
    );
  }

  Widget _buildContentTypeSelector() {
    final types = [
      {'value': 'post', 'label': 'منشور', 'icon': Icons.article_outlined, 'color': Color(0xFF00D9FF)},
      {'value': 'caption', 'label': 'تعليق', 'icon': Icons.comment_outlined, 'color': Color(0xFFFF6B6B)},
      {'value': 'story', 'label': 'قصة', 'icon': Icons.auto_stories_outlined, 'color': Color(0xFFFFD93D)},
      {'value': 'thread', 'label': 'سلسلة', 'icon': Icons.view_list_rounded, 'color': Color(0xFF4ECDC4)},
    ];

    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: types.map((type) {
          final isSelected = selectedType.value == type['value'];
          return GestureDetector(
            onTap: () => selectedType.value = type['value'] as String,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          type['color'] as Color,
                          (type['color'] as Color).withValues(alpha: 0.6),
                        ],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? (type['color'] as Color) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (type['color'] as Color).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return _buildGlowingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '⚙️ إعدادات متقدمة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey.shade400),
                onPressed: () => _showHelpDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tone Selector
          const Text(
            'الأسلوب',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                children: [
                  _buildChip('محترف', 'professional', Icons.business_center),
                  _buildChip('عادي', 'casual', Icons.chat_bubble_outline),
                  _buildChip('مرح', 'funny', Icons.sentiment_very_satisfied),
                  _buildChip('جاد', 'serious', Icons.psychology_outlined),
                ],
              )),
          const SizedBox(height: 16),
          // Creativity Slider
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'الإبداع',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        '${(_aiService.creativity.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF00D9FF),
                      inactiveTrackColor: Colors.grey.shade800,
                      thumbColor: const Color(0xFF00D9FF),
                      overlayColor: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _aiService.creativity.value,
                      onChanged: (value) => _aiService.creativity.value = value,
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, IconData icon) {
    final isSelected = _aiService.tone.value == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (_) => _aiService.tone.value = value,
      selectedColor: const Color(0xFF00D9FF),
      backgroundColor: const Color(0xFF2A2A3E),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
      ),
    );
  }

  Widget _buildGenerateButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _aiService.isGenerating.value ? null : _generateContent,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _aiService.isGenerating.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'جاري التوليد...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        'توليد المحتوى بالذكاء الاصطناعي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedContent() {
    if (_aiService.generatedContent.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildGlowingCard(
      color: const Color(0xFF1A1A2E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '✨ المحتوى المولّد',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF00D9FF)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _aiService.generatedContent.value));
                  Get.snackbar('✅ تم', 'تم نسخ المحتوى');
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.pink),
                onPressed: () => _aiService.saveToFavorites(_aiService.generatedContent.value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _aiService.generatedContent.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _improveContent(),
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: const Text('تحسين'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _generateHashtags(),
            icon: const Icon(Icons.tag, size: 18),
            label: const Text('هاشتاغات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Obx(() {
      if (_aiService.suggestions.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 اقتراحات التحسين',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ..._aiService.suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, color: Color(0xFF00D9FF), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      );
    });
  }

  Widget _buildAnalyzeTab() {
    final textController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlowingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 تحليل المحتوى',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'الصق المحتوى هنا للتحليل...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF2A2A3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final analysis = _aiService.analyzeContent(textController.text);
                      _showAnalysisResults(analysis);
                    },
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('تحليل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: const Color(0xFF0A0A0A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingCard({required Widget child, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color ?? const Color(0xFF1E1E2E),
            (color ?? const Color(0xFF1E1E2E)).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _generateContent() async {
    if (_topicController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال الموضوع');
      return;
    }

    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await _aiService.generateContent(
      topic: _topicController.text,
      contentType: selectedType.value,
      keywords: keywords.isEmpty ? null : keywords,
    );
  }

  Future<void> _improveContent() async {
    final improved = await _aiService.improveContent(_aiService.generatedContent.value);
    _aiService.generatedContent.value = improved;
    Get.snackbar('✅ تم', 'تم تحسين المحتوى');
  }

  Future<void> _generateHashtags() async {
    final hashtags = await _aiService.generateHashtags(_aiService.generatedContent.value);
    _aiService.generatedContent.value += '\n\n${hashtags.join(' ')}';
    Get.snackbar('✅ تم', 'تم إضافة الهاشتاغات');
  }

  void _showAnalysisResults(Map<String, dynamic> analysis) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📊 نتائج التحليل',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildScoreRow('النتيجة الإجمالية', analysis['score'], Colors.green),
            _buildScoreRow('سهولة القراءة', analysis['readability'], Colors.blue),
            _buildScoreRow('احتمالية التفاعل', analysis['engagement_potential'], Colors.orange),
            _buildScoreRow('SEO', analysis['seo_score'], Colors.purple),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  foregroundColor: const Color(0xFF0A0A0A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('حسناً'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildScoreRow(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                '${score.toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    Get.snackbar('قريباً', 'ميزة السجل ستكون متاحة قريباً');
  }

  void _showHelpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💡 نصائح الاستخدام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildHelpItem('اختر نوع المحتوى المناسب'),
              _buildHelpItem('اكتب موضوعاً واضحاً ومحدداً'),
              _buildHelpItem('اختر الأسلوب المناسب لجمهورك'),
              _buildHelpItem('استخدم الإبداع المناسب (50-70% مثالي)'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                  ),
                  child: const Text('فهمت'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00D9FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
