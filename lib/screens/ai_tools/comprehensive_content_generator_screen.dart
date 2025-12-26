import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/claude_ai_service.dart';
import '../../services/canva_service.dart';

/// شاشة توليد المحتوى الشامل
/// توليد محتوى لجميع المنصات + تصميمات Canva
class ComprehensiveContentGeneratorScreen extends StatefulWidget {
  const ComprehensiveContentGeneratorScreen({super.key});

  @override
  State<ComprehensiveContentGeneratorScreen> createState() => _ComprehensiveContentGeneratorScreenState();
}

class _ComprehensiveContentGeneratorScreenState extends State<ComprehensiveContentGeneratorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  // Services
  ClaudeAIService? _claudeService;
  CanvaService? _canvaService;

  // State
  bool _isLoading = false;
  Map<String, dynamic>? _generatedContent;
  String? _error;

  // Settings
  String _selectedLanguage = 'ar';
  String _selectedTone = 'professional';
  final List<String> _selectedPlatforms = ['instagram', 'facebook', 'twitter'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initServices();
  }

  void _initServices() {
    try {
      _claudeService = Get.find<ClaudeAIService>();
    } catch (e) {
      _claudeService = Get.put(ClaudeAIService());
    }

    try {
      _canvaService = Get.find<CanvaService>();
    } catch (e) {
      _canvaService = Get.put(CanvaService());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _generateContent() async {
    if (_topicController.text.isEmpty) {
      setState(() => _error = 'Please enter a topic');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _generatedContent = null;
    });

    try {
      final result = await _claudeService!.generateComprehensive(
        topic: _topicController.text,
        platforms: _selectedPlatforms,
        language: _selectedLanguage,
        tone: _selectedTone,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
      );

      setState(() {
        _generatedContent = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مولد المحتوى الشامل'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note), text: 'الإعدادات'),
            Tab(icon: Icon(Icons.article), text: 'المحتوى'),
            Tab(icon: Icon(Icons.image), text: 'التصميم'),
            Tab(icon: Icon(Icons.calendar_month), text: 'الجدولة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSettingsTab(theme, isDark),
          _buildContentTab(theme, isDark),
          _buildDesignTab(theme, isDark),
          _buildScheduleTab(theme, isDark),
        ],
      ),
    );
  }

  /// تبويب الإعدادات
  Widget _buildSettingsTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الموضوع',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _topicController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب موضوع المحتوى...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Brand Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العلامة التجارية (اختياري)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      hintText: 'اسم العلامة التجارية...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Platform Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المنصات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ClaudeAIService.getSupportedPlatforms().map((platform) {
                      final isSelected = _selectedPlatforms.contains(platform['id']);
                      return FilterChip(
                        label: Text(platform['name']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPlatforms.add(platform['id']!);
                            } else {
                              _selectedPlatforms.remove(platform['id']);
                            }
                          });
                        },
                        selectedColor: theme.primaryColor.withOpacity(0.2),
                        checkmarkColor: theme.primaryColor,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language & Tone
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اللغة',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLanguage,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ar', child: Text('العربية')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'fr', child: Text('Francais')),
                            DropdownMenuItem(value: 'es', child: Text('Espanol')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedLanguage = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النبرة',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTone,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: ClaudeAIService.getAvailableTones().map((tone) {
                            return DropdownMenuItem(
                              value: tone['id'],
                              child: Text(tone['name']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedTone = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateContent,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'جاري التوليد...' : 'توليد المحتوى'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// تبويب المحتوى المولد
  Widget _buildContentTab(ThemeData theme, bool isDark) {
    if (_generatedContent == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم توليد محتوى بعد',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اذهب لتبويب الإعدادات وابدأ التوليد',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final content = _generatedContent!['content'];
    final parsed = content['parsed'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parsed['content'] != null) ...[
            for (final platform in _selectedPlatforms)
              if (parsed['content'][platform] != null)
                _buildPlatformContentCard(
                  theme,
                  isDark,
                  platform,
                  parsed['content'][platform],
                ),
          ],

          // Image Prompts
          if (parsed['image_prompts'] != null) ...[
            const SizedBox(height: 24),
            Text(
              'برومبتات الصور',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPromptCard(
              theme,
              isDark,
              'الصورة الرئيسية',
              parsed['image_prompts']['main'] ?? '',
              Icons.image,
            ),
          ],

          // Video Prompts
          if (parsed['video_prompts'] != null) ...[
            const SizedBox(height: 24),
            Text(
              'برومبتات الفيديو',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPromptCard(
              theme,
              isDark,
              'الفيديو الرئيسي',
              parsed['video_prompts']['main'] ?? '',
              Icons.videocam,
            ),
          ],

          // Best Posting Times
          if (parsed['best_posting_times'] != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'أفضل أوقات النشر',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...((parsed['best_posting_times'] as Map).entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key.toString().toUpperCase()),
                            Text(
                              e.value.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList()),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlatformContentCard(
    ThemeData theme,
    bool isDark,
    String platform,
    Map<String, dynamic> content,
  ) {
    final platformIcons = {
      'instagram': Icons.camera_alt,
      'facebook': Icons.facebook,
      'twitter': Icons.flutter_dash,
      'tiktok': Icons.music_note,
      'linkedin': Icons.business,
      'youtube': Icons.play_circle_fill,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  platformIcons[platform] ?? Icons.share,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  platform.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    final text = _extractTextFromContent(content);
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم النسخ!')),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...content.entries.map((entry) {
              if (entry.value is String) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              } else if (entry.value is List) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: (entry.value as List).map((item) {
                          return Chip(
                            label: Text(item.toString(), style: const TextStyle(fontSize: 12)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard(
    ThemeData theme,
    bool isDark,
    String title,
    String prompt,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: prompt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ البرومبت!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                prompt,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractTextFromContent(Map<String, dynamic> content) {
    final buffer = StringBuffer();
    content.forEach((key, value) {
      if (value is String) {
        buffer.writeln('$key: $value');
      } else if (value is List) {
        buffer.writeln('$key: ${value.join(', ')}');
      }
    });
    return buffer.toString();
  }

  /// تبويب التصميم (Canva)
  Widget _buildDesignTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Canva Connection Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.palette, color: Colors.purple),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Canva',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Obx(() => Text(
                          _canvaService?.isConnected.value == true
                              ? 'متصل'
                              : 'غير متصل',
                          style: TextStyle(
                            color: _canvaService?.isConnected.value == true
                                ? Colors.green
                                : Colors.grey,
                          ),
                        )),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_canvaService?.isConnected.value == true) {
                        // Show designs
                        _showCanvaDesigns();
                      } else {
                        // Connect to Canva
                        await _canvaService?.openAuthorizationPage();
                      }
                    },
                    child: Obx(() => Text(
                      _canvaService?.isConnected.value == true
                          ? 'عرض التصميمات'
                          : 'ربط Canva',
                    )),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Create Section
          Text(
            'إنشاء تصميم سريع',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickCreateCard(
                theme,
                'Instagram Post',
                Icons.camera_alt,
                Colors.pink,
                () => _quickCreateDesign('instagram', 'post'),
              ),
              _buildQuickCreateCard(
                theme,
                'Instagram Story',
                Icons.video_library,
                Colors.purple,
                () => _quickCreateDesign('instagram', 'story'),
              ),
              _buildQuickCreateCard(
                theme,
                'Facebook Post',
                Icons.facebook,
                Colors.blue,
                () => _quickCreateDesign('facebook', 'post'),
              ),
              _buildQuickCreateCard(
                theme,
                'Twitter Post',
                Icons.flutter_dash,
                Colors.lightBlue,
                () => _quickCreateDesign('twitter', 'post'),
              ),
              _buildQuickCreateCard(
                theme,
                'LinkedIn Post',
                Icons.business,
                Colors.indigo,
                () => _quickCreateDesign('linkedin', 'post'),
              ),
              _buildQuickCreateCard(
                theme,
                'YouTube Thumbnail',
                Icons.play_circle_fill,
                Colors.red,
                () => _quickCreateDesign('youtube', 'thumbnail'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCreateCard(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _quickCreateDesign(String platform, String contentType) async {
    try {
      final result = await _canvaService?.quickCreate(
        platform: platform,
        contentType: contentType,
        title: _topicController.text.isNotEmpty
            ? '${_topicController.text} - $platform'
            : null,
      );

      if (result != null && result['success'] == true) {
        // Open in Canva
        if (result['edit_url'] != null) {
          _canvaService?.openInCanva(result['design_id']);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showCanvaDesigns() async {
    final designs = await _canvaService?.listDesigns();
    if (designs != null && designs.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'تصميماتك',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: designs.length,
                  itemBuilder: (context, index) {
                    final design = designs[index];
                    return ListTile(
                      leading: const Icon(Icons.design_services),
                      title: Text(design['title'] ?? 'Untitled'),
                      subtitle: Text(design['created_at'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          _canvaService?.openInCanva(design['id']);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// تبويب الجدولة
  Widget _buildScheduleTab(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'قريباً',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جدولة المحتوى تلقائياً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
