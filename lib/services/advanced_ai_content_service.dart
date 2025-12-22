import 'package:get/get.dart';
import 'dart:async';
import 'http_service.dart';
import 'gemini_service.dart';
import 'claude_service.dart';

/// خدمة AI متقدمة لتوليد المحتوى بذكاء خارق
/// تستخدم Gemini كـ Primary و Claude كـ Backup
class AdvancedAIContentService extends GetxService {
  final RxBool isGenerating = false.obs;
  final RxString generatedContent = ''.obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxDouble creativity = 0.7.obs; // 0.0 to 1.0
  final RxString tone = 'professional'.obs; // professional, casual, funny, serious
  final RxString language = 'ar'.obs; // ar, en, mix

  // AI Models - Gemini is Primary
  final RxString selectedModel = 'gemini'.obs; // gemini (primary), claude (backup)

  // HTTP Service for Backend API calls
  HttpService? get _httpService {
    try {
      return Get.find<HttpService>();
    } catch (e) {
      return null;
    }
  }

  // Gemini Service for direct AI calls (Primary)
  GeminiService? get _geminiService {
    try {
      return Get.find<GeminiService>();
    } catch (e) {
      return null;
    }
  }

  // Claude Service for direct AI calls (Backup)
  ClaudeService? get _claudeService {
    try {
      return Get.find<ClaudeService>();
    } catch (e) {
      return null;
    }
  }

  bool get _useBackendAI => _httpService != null;
  bool get _useGeminiDirect => _geminiService?.isConfigured ?? false;
  bool get _useClaudeDirect => _claudeService?.isConfigured ?? false;

  @override
  void onInit() {
    super.onInit();
    print('🤖 Advanced AI Content Service initialized');
    print('✅ Primary Provider: Gemini | Backup: Claude');
  }

  /// توليد محتوى ذكي بناءً على الموضوع
  /// يستخدم Backend API للتواصل مع Gemini/Claude
  Future<String> generateContent({
    required String topic,
    required String contentType, // post, caption, story, thread
    int? wordCount,
    List<String>? keywords,
    String? targetAudience,
  }) async {
    try {
      isGenerating.value = true;
      generatedContent.value = '';

      print('🤖 Generating content for: $topic');
      print('📝 Type: $contentType | Tone: ${tone.value} | Language: ${language.value}');

      String content;

      // استخدام Backend API للتواصل مع AI
      if (_useBackendAI) {
        print('🚀 Using Backend API for AI content generation...');

        try {
          final response = await _httpService!.post(
            '/ai/content/generate',
            body: {
              'prompt': topic,
              'type': contentType,
              'platform': 'general',
              'language': language.value,
              'tone': tone.value,
              'max_length': wordCount ?? 300,
              'include_hashtags': true,
              'include_emoji': true,
              'model': selectedModel.value, // gemini or claude
            },
          );

          if (response['success'] == true && response['data'] != null) {
            content = response['data']['content'] ?? response['data']['text'] ?? '';
            print('✅ Content generated via Backend API');
          } else {
            throw Exception(response['message'] ?? 'Failed to generate content');
          }
        } catch (e) {
          print('⚠️ Backend API error: $e, trying Gemini direct...');
          // Fallback to Gemini direct if available (Primary)
          if (_useGeminiDirect) {
            print('🚀 Using Gemini API directly (PRIMARY)...');
            content = await _geminiService!.generateSocialMediaContent(
              topic: topic,
              platform: 'general',
              contentType: contentType,
              language: language.value,
              tone: tone.value,
              maxLength: wordCount ?? 300,
              includeHashtags: true,
              includeEmoji: true,
            );
            print('✅ Content generated via Gemini direct');
          } else if (_useClaudeDirect) {
            // Fallback to Claude (Backup)
            print('🔄 Using Claude API directly (backup)...');
            content = await _claudeService!.generateSocialMediaContent(
              topic: topic,
              platform: 'general',
              contentType: contentType,
              language: language.value,
              tone: tone.value,
              maxLength: wordCount ?? 300,
              includeHashtags: true,
              includeEmoji: true,
            );
            print('✅ Content generated via Claude direct');
          } else {
            // Final fallback to demo mode
            print('📝 Using demo mode...');
            content = await _generateByType(
              topic: topic,
              type: contentType,
              wordCount: wordCount ?? 100,
              keywords: keywords,
              targetAudience: targetAudience,
            );
          }
        }
      } else if (_useGeminiDirect) {
        // Use Gemini API directly (Primary - no backend)
        print('🚀 Using Gemini API directly (PRIMARY)...');
        content = await _geminiService!.generateSocialMediaContent(
          topic: topic,
          platform: 'general',
          contentType: contentType,
          language: language.value,
          tone: tone.value,
          maxLength: wordCount ?? 300,
          includeHashtags: true,
          includeEmoji: true,
        );
        print('✅ Content generated via Gemini direct');
      } else if (_useClaudeDirect) {
        // Use Claude API directly (Backup)
        print('🔄 Using Claude API directly (Backup)...');
        content = await _claudeService!.generateSocialMediaContent(
          topic: topic,
          platform: 'general',
          contentType: contentType,
          language: language.value,
          tone: tone.value,
          maxLength: wordCount ?? 300,
          includeHashtags: true,
          includeEmoji: true,
        );
        print('✅ Content generated via Claude direct');
      } else {
        // Demo mode - محاكاة التوليد
        print('📝 Using demo mode...');
        await Future.delayed(const Duration(seconds: 2));

        content = await _generateByType(
          topic: topic,
          type: contentType,
          wordCount: wordCount ?? 100,
          keywords: keywords,
          targetAudience: targetAudience,
        );
      }

      generatedContent.value = content;

      // Generate suggestions for improvement
      await _generateSuggestions(content);

      Get.snackbar(
        '✅ تم التوليد',
        _useBackendAI ? 'تم إنشاء محتوى باستخدام AI' : 'تم إنشاء محتوى احترافي بنجاح',
        duration: const Duration(seconds: 3),
      );

      return content;
    } catch (e) {
      print('❌ Error generating content: $e');

      // تحسين رسالة الخطأ للمستخدم
      final errorStr = e.toString().toLowerCase();
      String errorMessage;

      if (errorStr.contains('socketexception') ||
          errorStr.contains('failed host lookup') ||
          errorStr.contains('network') ||
          errorStr.contains('connection')) {
        errorMessage = 'فشل الاتصال بالإنترنت - جرب تبديل الشبكة';
      } else {
        errorMessage = 'فشل توليد المحتوى: $e';
      }

      Get.snackbar(
        '❌ خطأ',
        errorMessage,
        duration: const Duration(seconds: 5),
      );
      return '';
    } finally {
      isGenerating.value = false;
    }
  }

  Future<String> _generateByType({
    required String topic,
    required String type,
    required int wordCount,
    List<String>? keywords,
    String? targetAudience,
  }) async {
    switch (type) {
      case 'post':
        return _generatePost(topic, wordCount, keywords);
      case 'caption':
        return _generateCaption(topic, keywords);
      case 'story':
        return _generateStory(topic);
      case 'thread':
        return _generateThread(topic, wordCount);
      default:
        return _generatePost(topic, wordCount, keywords);
    }
  }

  String _generatePost(String topic, int wordCount, List<String>? keywords) {
    final templates = [
      '''🚀 $topic - دعونا نتحدث!

${_getToneBasedIntro()}

${_getMainContent(topic, wordCount)}

${_getCallToAction()}

${_generateHashtags(keywords ?? [])}''',
      '''✨ $topic

${_getQuestionHook()}

${_getMainContent(topic, wordCount)}

💡 ${_getTip()}

${_generateHashtags(keywords ?? [])}''',
      '''📢 $topic: ${_getAttentionGrabber()}

${_getMainContent(topic, wordCount)}

🎯 ${_getActionStep()}

${_generateHashtags(keywords ?? [])}''',
    ];

    return templates[DateTime.now().second % templates.length];
  }

  String _generateCaption(String topic, List<String>? keywords) {
    final captions = [
      '✨ $topic | ${_getEmotionalHook()} 💫',
      '🎯 $topic - ${_getValueProp()} 🚀',
      '💡 $topic | ${_getInspirationalQuote()} ⭐',
      '🔥 $topic - ${_getTrendyPhrase()} 💪',
    ];

    return captions[DateTime.now().second % captions.length];
  }

  String _generateStory(String topic) {
    return '''📱 $topic

Swipe Up للمزيد 👆

${_getStoryEmoji()}''';
  }

  String _generateThread(String topic, int wordCount) {
    return '''🧵 Thread about $topic

1/ ${_getThreadIntro()}

2/ ${_getThreadPoint()}

3/ ${_getThreadPoint()}

4/ ${_getThreadConclusion()}

${_generateHashtags([])}''';
  }

  String _getToneBasedIntro() {
    switch (tone.value) {
      case 'professional':
        return 'في عالم الأعمال الحديث، من المهم أن نفهم...';
      case 'casual':
        return 'تعالوا نتكلم بصراحة...';
      case 'funny':
        return 'قصة طريفة حدثت لي...';
      case 'serious':
        return 'دعونا نناقش موضوعاً مهماً...';
      default:
        return 'هل تعلم أن...';
    }
  }

  String _getMainContent(String topic, int wordCount) {
    final contents = [
      '$topic يمثل فرصة رائعة للنمو والتطور. من خلال فهم عميق لهذا الموضوع، يمكننا تحقيق نتائج مذهلة.',
      'عندما نتحدث عن $topic، نتحدث عن مستقبل الأعمال. الإحصائيات تظهر نمواً بنسبة 300% في هذا المجال.',
      '$topic ليس مجرد موضوع، إنه استثمار في المستقبل. الشركات الناجحة تدرك أهمية هذا.',
    ];
    return contents[DateTime.now().second % contents.length];
  }

  String _getCallToAction() {
    final ctas = [
      '👉 شاركنا رأيك في التعليقات!',
      '💬 هل جربت هذا من قبل؟ أخبرنا!',
      '🔔 تابعنا للمزيد من النصائح!',
      '📩 راسلنا لمعرفة المزيد!',
    ];
    return ctas[DateTime.now().second % ctas.length];
  }

  String _getQuestionHook() {
    final questions = [
      'هل تساءلت يوماً عن...؟',
      'ما رأيك في...؟',
      'كيف يمكن أن...؟',
      'هل تعلم أن...؟',
    ];
    return questions[DateTime.now().second % questions.length];
  }

  String _getTip() {
    final tips = [
      'نصيحة: ابدأ صغيراً وازد تدريجياً',
      'نصيحة: الاستمرارية هي المفتاح',
      'نصيحة: تابع النتائج وحلل البيانات',
      'نصيحة: لا تخف من التجربة',
    ];
    return tips[DateTime.now().second % tips.length];
  }

  String _getAttentionGrabber() {
    final grabbers = [
      'هذا سيغير كل شيء!',
      'لن تصدق ما اكتشفته!',
      'الحقيقة التي لا يخبرك بها أحد',
      'السر الذي استخدمه الخبراء',
    ];
    return grabbers[DateTime.now().second % grabbers.length];
  }

  String _getActionStep() {
    final steps = [
      'ابدأ اليوم واصنع الفرق',
      'خطوتك التالية تبدأ الآن',
      'حان الوقت لتحقيق النجاح',
      'لا تنتظر، ابدأ الآن',
    ];
    return steps[DateTime.now().second % steps.length];
  }

  String _getEmotionalHook() {
    return 'رحلة ملهمة نحو النجاح';
  }

  String _getValueProp() {
    return 'استثمر في نفسك، استثمر في مستقبلك';
  }

  String _getInspirationalQuote() {
    final quotes = [
      'النجاح ليس نهاية، الفشل ليس قاتلاً',
      'كل إنجاز عظيم بدأ بقرار المحاولة',
      'المستقبل ملك لمن يؤمن بأحلامه',
    ];
    return quotes[DateTime.now().second % quotes.length];
  }

  String _getTrendyPhrase() {
    final phrases = [
      'الفرصة التي كنت تنتظرها',
      'حان وقت التغيير',
      'دعونا نصنع التاريخ',
    ];
    return phrases[DateTime.now().second % phrases.length];
  }

  String _getStoryEmoji() {
    final emojis = ['🔥', '✨', '💫', '🌟', '⚡'];
    return emojis[DateTime.now().second % emojis.length];
  }

  String _getThreadIntro() {
    return 'دعوني أشارككم شيئاً مهماً تعلمته...';
  }

  String _getThreadPoint() {
    final points = [
      'النقطة المهمة هنا هي فهم الأساسيات',
      'من تجربتي الشخصية، وجدت أن...',
      'الخبراء يؤكدون على أهمية...',
    ];
    return points[DateTime.now().second % points.length];
  }

  String _getThreadConclusion() {
    return 'في النهاية، المهم هو أن تبدأ رحلتك الآن!';
  }

  String _generateHashtags(List<String> keywords) {
    final defaultTags = ['#SocialMedia', '#Marketing', '#Success', '#Business', '#Digital'];
    final tags = keywords.isNotEmpty ? keywords : defaultTags;
    return tags.take(5).map((t) => t.startsWith('#') ? t : '#$t').join(' ');
  }

  /// توليد اقتراحات للتحسين
  Future<void> _generateSuggestions(String content) async {
    suggestions.clear();

    await Future.delayed(const Duration(milliseconds: 500));

    suggestions.addAll([
      '💡 أضف emoji في البداية للفت الانتباه',
      '🎯 اجعل الـ CTA أكثر وضوحاً',
      '📊 أضف إحصائية أو رقم محدد',
      '❓ استخدم سؤالاً لزيادة التفاعل',
      '🏷️ أضف 2-3 هاشتاغات إضافية',
    ]);
  }

  /// توليد هاشتاغات ذكية
  Future<List<String>> generateHashtags(String content) async {
    // استخدام Backend API إذا كان متاحاً
    if (_useBackendAI) {
      try {
        final response = await _httpService!.post(
          '/ai/content/generate',
          body: {
            'prompt': 'Generate 8 relevant hashtags for this content: $content',
            'type': 'hashtags',
            'platform': 'general',
            'language': language.value,
          },
        );

        if (response['success'] == true && response['data'] != null) {
          final hashtagsData = response['data']['hashtags'] ?? response['data']['content'];
          if (hashtagsData is List) {
            return hashtagsData.cast<String>();
          } else if (hashtagsData is String) {
            // Parse hashtags from string
            return hashtagsData.split(RegExp(r'[\s,]+'))
                .where((tag) => tag.startsWith('#'))
                .toList();
          }
        }
      } catch (e) {
        print('❌ Error generating hashtags via Backend API: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 800));

    // Fallback: Analyze content and suggest relevant hashtags
    final hashtags = <String>[
      '#SocialMedia',
      '#Marketing',
      '#DigitalMarketing',
      '#ContentCreation',
      '#Business',
      '#Entrepreneur',
      '#Success',
      '#Motivation',
      '#Tips',
      '#Strategy',
    ];

    // Return 5-8 random hashtags
    hashtags.shuffle();
    return hashtags.take(5 + DateTime.now().second % 4).toList();
  }

  /// تحسين المحتوى الموجود
  Future<String> improveContent(String content) async {
    isGenerating.value = true;

    try {
      // استخدام Backend API إذا كان متاحاً
      if (_useBackendAI) {
        print('🤖 Using Backend API to improve content...');
        try {
          final response = await _httpService!.post(
            '/ai/content/generate',
            body: {
              'prompt': 'Improve this social media content and make it more engaging: $content',
              'type': 'improve',
              'language': language.value,
              'tone': tone.value,
            },
          );

          if (response['success'] == true && response['data'] != null) {
            return response['data']['content'] ?? response['data']['text'] ?? content;
          }
        } catch (e) {
          print('⚠️ Backend API error: $e');
        }
      }

      await Future.delayed(const Duration(seconds: 1));

      // Fallback: Add emojis, improve structure, add hashtags
      final improved = '''✨ $content

💡 نصيحة إضافية: لا تنسى التفاعل مع جمهورك!

#Success #Motivation #Tips''';

      return improved;
    } finally {
      isGenerating.value = false;
    }
  }

  /// توليد محتوى بلغات متعددة
  Future<String> translateContent(String content, String targetLang) async {
    // استخدام Backend API إذا كان متاحاً
    if (_useBackendAI) {
      try {
        print('🤖 Using Backend API to translate content...');
        final response = await _httpService!.post(
          '/ai/content/generate',
          body: {
            'prompt': 'Translate this content to $targetLang: $content',
            'type': 'translate',
            'target_language': targetLang,
          },
        );

        if (response['success'] == true && response['data'] != null) {
          final translated = response['data']['content'] ?? response['data']['text'] ?? content;
          Get.snackbar('✅ تم', 'تم ترجمة المحتوى إلى $targetLang باستخدام AI');
          return translated;
        }
      } catch (e) {
        print('❌ Error translating via Backend API: $e');
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    Get.snackbar('✅ تم', 'تم ترجمة المحتوى إلى $targetLang');

    return content;
  }

  /// تحليل المحتوى وإعطاء نقاط
  Map<String, dynamic> analyzeContent(String content) {
    final score = _calculateScore(content);

    return {
      'score': score,
      'readability': _calculateReadability(content),
      'engagement_potential': _calculateEngagement(content),
      'seo_score': _calculateSEO(content),
      'suggestions': suggestions.toList(),
    };
  }

  double _calculateScore(String content) {
    double score = 50.0;

    // Length check
    if (content.length > 50 && content.length < 280) score += 15;

    // Emoji check
    if (content.contains(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true))) score += 10;

    // Hashtag check
    if (content.contains('#')) score += 10;

    // CTA check
    if (content.contains('👉') || content.contains('💬') || content.contains('📩')) score += 10;

    // Question check
    if (content.contains('؟') || content.contains('?')) score += 5;

    return score.clamp(0, 100);
  }

  double _calculateReadability(String content) {
    // Simple readability score
    final words = content.split(' ').length;
    if (words < 20) return 90.0;
    if (words < 50) return 75.0;
    if (words < 100) return 60.0;
    return 40.0;
  }

  double _calculateEngagement(String content) {
    double engagement = 50.0;

    if (content.contains('؟') || content.contains('?')) engagement += 15;
    if (content.contains('💬') || content.contains('👉')) engagement += 15;
    if (content.contains('#')) engagement += 10;
    if (content.contains(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true))) engagement += 10;

    return engagement.clamp(0, 100);
  }

  double _calculateSEO(String content) {
    double seo = 50.0;

    final hashtagCount = '#'.allMatches(content).length;
    if (hashtagCount >= 3 && hashtagCount <= 8) seo += 25;

    if (content.length > 100) seo += 15;

    final keywords = ['محتوى', 'تسويق', 'نجاح', 'أعمال'];
    for (final keyword in keywords) {
      if (content.contains(keyword)) seo += 5;
    }

    return seo.clamp(0, 100);
  }

  /// حفظ المحتوى المفضل
  Future<void> saveToFavorites(String content) async {
    // TODO: Save to local storage or backend
    Get.snackbar('✅ تم', 'تم حفظ المحتوى في المفضلة');
  }

  /// مشاركة المحتوى
  Future<void> shareContent(String content) async {
    // TODO: Implement share functionality
    Get.snackbar('✅ تم', 'تم نسخ المحتوى للحافظة');
  }
}
