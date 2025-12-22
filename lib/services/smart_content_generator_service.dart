import 'package:get/get.dart';
import '../models/generated_content.dart';
import 'gemini_service.dart';

class SmartContentGeneratorService {
  final List<GeneratedContent> _generatedContents = [];

  List<GeneratedContent> get generatedContents => _generatedContents;
  List<GeneratedContent> get favoriteContents =>
      _generatedContents.where((c) => c.isFavorite).toList();

  // Gemini Service for AI content generation
  GeminiService? get _geminiService {
    try {
      return Get.find<GeminiService>();
    } catch (e) {
      return null;
    }
  }

  bool get _useGemini => _geminiService?.isConfigured ?? false;

  /// توليد محتوى ذكي
  Future<GeneratedContent> generateContent({
    required String topic,
    required ContentType contentType,
    required Platform platform,
    required String language,
    String tone = 'professional',
    int length = 150,
    bool includeHashtags = true,
    bool includeEmoji = true,
  }) async {
    try {
      String generatedText;
      List<String> hashtags;
      String? emoji;

      // استخدام Gemini API إذا كان مفعلاً
      if (_useGemini) {
        print('🤖 Using Gemini AI for content generation...');

        generatedText = await _geminiService!.generateSocialMediaContent(
          topic: topic,
          platform: platform.name,
          contentType: _getContentTypeName(contentType, language),
          language: language,
          tone: tone,
          maxLength: length,
          includeHashtags: includeHashtags,
          includeEmoji: includeEmoji,
        );

        // توليد هاشتاقات إضافية إذا لم تكن موجودة في المحتوى
        if (includeHashtags && !generatedText.contains('#')) {
          hashtags = await _geminiService!.generateHashtags(
            content: generatedText,
            platform: platform.name,
            language: language,
            count: 5,
          );
        } else {
          hashtags = _extractHashtags(generatedText);
        }

        emoji = includeEmoji ? _generateEmoji(contentType) : null;
      } else {
        // Demo mode - محاكاة التوليد
        print('📝 Using demo mode for content generation...');
        await Future.delayed(const Duration(seconds: 3));

        generatedText = _generateDemoContent(
          topic: topic,
          contentType: contentType,
          platform: platform,
          language: language,
          tone: tone,
          length: length,
        );

        hashtags = includeHashtags
            ? _generateHashtags(topic, platform, language)
            : <String>[];

        emoji = includeEmoji ? _generateEmoji(contentType) : null;
      }

      final content = GeneratedContent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        topic: topic,
        generatedText: generatedText,
        createdAt: DateTime.now(),
        contentType: contentType,
        platform: platform,
        language: language,
        tone: tone,
        length: length,
        hashtags: hashtags,
        emoji: emoji,
      );

      _generatedContents.insert(0, content);
      return content;
    } catch (e) {
      throw Exception('خطأ في توليد المحتوى: $e');
    }
  }

  String _getContentTypeName(ContentType type, String language) {
    final names = {
      ContentType.post: language == 'ar' ? 'منشور' : 'post',
      ContentType.story: language == 'ar' ? 'ستوري' : 'story',
      ContentType.reel: language == 'ar' ? 'ريل' : 'reel',
      ContentType.thread: language == 'ar' ? 'سلسلة تغريدات' : 'thread',
      ContentType.caption: language == 'ar' ? 'وصف صورة' : 'caption',
      ContentType.ad: language == 'ar' ? 'إعلان' : 'ad',
    };
    return names[type] ?? type.name;
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  // TODO: Prompt builder reserved for ChatGPT integration (currently using demo content generation)
  /*
  String _buildPrompt({
    required String topic,
    required ContentType contentType,
    required Platform platform,
    required String language,
    required String tone,
    required int length,
    required bool includeHashtags,
    required bool includeEmoji,
  }) {
    final langText = language == 'ar' ? 'بالعربية' : 'in English';
    final toneText = _getToneDescription(tone, language);

    return '''
اكتب ${contentType.arabicName} $langText عن: $topic

المنصة: ${platform.name}
الأسلوب: $toneText
الطول المطلوب: حوالي $length حرف

المتطلبات:
1. المحتوى يجب أن يكون جذاباً ومناسباً لـ ${platform.name}
2. ${includeHashtags ? 'أضف هاشتاقات مناسبة في النهاية' : 'بدون هاشتاقات'}
3. ${includeEmoji ? 'استخدم الإيموجي بشكل مناسب' : 'بدون إيموجي'}
4. يجب أن يكون المحتوى احترافياً ويحفز التفاعل
5. مناسب لطبيعة ${contentType.arabicName}
''';
  }
  */

  // TODO: Tone helper reserved for prompt builder (currently in commented code)
  /*
  String _getToneDescription(String tone, String language) {
    final tones = {
      'professional': language == 'ar' ? 'احترافي' : 'Professional',
      'casual': language == 'ar' ? 'عفوي' : 'Casual',
      'friendly': language == 'ar' ? 'ودود' : 'Friendly',
      'inspirational': language == 'ar' ? 'تحفيزي' : 'Inspirational',
      'humorous': language == 'ar' ? 'فكاهي' : 'Humorous',
      'educational': language == 'ar' ? 'تعليمي' : 'Educational',
    };
    return tones[tone] ?? tone;
  }
  */

  String _generateDemoContent({
    required String topic,
    required ContentType contentType,
    required Platform platform,
    required String language,
    required String tone,
    required int length,
  }) {
    if (language == 'ar') {
      switch (contentType) {
        case ContentType.post:
          return '''
🌟 $topic

في عالم اليوم المتسارع، أصبح $topic من أهم المواضيع التي يجب أن نوليها اهتمامنا.

من خلال فهمنا العميق لهذا الموضوع، يمكننا أن نحقق نتائج مذهلة ونصنع فرقاً حقيقياً.

ما هو رأيك في $topic؟ شاركنا تجربتك في التعليقات! 💬

#${topic.replaceAll(' ', '_')} #محتوى_احترافي #نجاح
''';

        case ContentType.story:
          return '''
✨ قصة اليوم عن $topic

اكتشف معنا...
• كيف تبدأ
• ما الذي تحتاجه
• النتائج المتوقعة

انتظر المزيد! 👀
''';

        case ContentType.reel:
          return '''
🎬 Reel: $topic

[المشهد 1] مقدمة جذابة
[المشهد 2] المحتوى الرئيسي
[المشهد 3] Call to Action

الموسيقى: Trending Sound
التأثيرات: انتقالات سريعة

#ريلز #${topic.replaceAll(' ', '_')}
''';

        case ContentType.thread:
          return '''
🧵 سلسلة تغريدات عن $topic

1/ لنتحدث عن $topic وأهميته في عصرنا الحالي...

2/ النقطة الأولى المهمة: [شرح مفصل]

3/ ثانياً: [معلومات إضافية]

4/ الخلاصة: $topic يمكن أن يغير قواعد اللعبة!

#${topic.replaceAll(' ', '_')}
''';

        case ContentType.caption:
          return '''
📸 $topic في صورة واحدة.

هذا ما نريد أن نوصله: الجمال يكمن في التفاصيل، والإبداع يبدأ من هنا.

تابعنا للمزيد من المحتوى الملهم! ✨

#تصوير #${topic.replaceAll(' ', '_')} #إبداع
''';

        case ContentType.ad:
          return '''
🎯 عرض خاص!

هل تبحث عن $topic؟

لدينا الحل الأمثل لك!

✅ جودة عالية
✅ أسعار منافسة
✅ خدمة مميزة

احصل على خصم 20% الآن!

[رابط الشراء]

#عروض #${topic.replaceAll(' ', '_')}
''';
      }
    } else {
      switch (contentType) {
        case ContentType.post:
          return '''
🌟 $topic

In today's fast-paced world, $topic has become one of the most important subjects we need to focus on.

Through our deep understanding of this topic, we can achieve amazing results and make a real difference.

What's your opinion on $topic? Share your experience in the comments! 💬

#${topic.replaceAll(' ', '_')} #ProfessionalContent #Success
''';

        case ContentType.story:
          return '''
✨ Today's story about $topic

Discover with us...
• How to start
• What you need
• Expected results

Stay tuned for more! 👀
''';

        case ContentType.reel:
          return '''
🎬 Reel: $topic

[Scene 1] Catchy intro
[Scene 2] Main content
[Scene 3] Call to Action

Music: Trending Sound
Effects: Quick transitions

#Reels #${topic.replaceAll(' ', '_')}
''';

        case ContentType.thread:
          return '''
🧵 Thread about $topic

1/ Let's talk about $topic and its importance in our current era...

2/ First important point: [Detailed explanation]

3/ Second: [Additional information]

4/ Conclusion: $topic can be a game-changer!

#${topic.replaceAll(' ', '_')}
''';

        case ContentType.caption:
          return '''
📸 $topic in one picture.

This is what we want to convey: beauty lies in the details, and creativity starts here.

Follow us for more inspiring content! ✨

#Photography #${topic.replaceAll(' ', '_')} #Creative
''';

        case ContentType.ad:
          return '''
🎯 Special Offer!

Looking for $topic?

We have the perfect solution for you!

✅ High quality
✅ Competitive prices
✅ Premium service

Get 20% off now!

[Purchase link]

#Deals #${topic.replaceAll(' ', '_')}
''';
      }
    }
  }

  List<String> _generateHashtags(
    String topic,
    Platform platform,
    String language,
  ) {
    final topicHash = topic.replaceAll(' ', '_');

    if (language == 'ar') {
      final commonArabic = ['محتوى_احترافي', 'سوشيال_ميديا', 'تسويق_رقمي'];

      switch (platform) {
        case Platform.instagram:
          return [topicHash, ...commonArabic, 'انستقرام', 'تصوير'];
        case Platform.twitter:
          return [topicHash, ...commonArabic, 'تويتر', 'نقاش'];
        case Platform.facebook:
          return [topicHash, ...commonArabic, 'فيسبوك', 'مجتمع'];
        case Platform.linkedin:
          return [topicHash, ...commonArabic, 'لينكد_ان', 'أعمال'];
        case Platform.tiktok:
          return [topicHash, ...commonArabic, 'تيك_توك', 'ترند'];
        case Platform.youtube:
          return [topicHash, ...commonArabic, 'يوتيوب', 'فيديو'];
      }
    } else {
      final commonEnglish = ['content', 'socialmedia', 'digitalmarketing'];

      switch (platform) {
        case Platform.instagram:
          return [topicHash, ...commonEnglish, 'instagram', 'photography'];
        case Platform.twitter:
          return [topicHash, ...commonEnglish, 'twitter', 'discussion'];
        case Platform.facebook:
          return [topicHash, ...commonEnglish, 'facebook', 'community'];
        case Platform.linkedin:
          return [topicHash, ...commonEnglish, 'linkedin', 'business'];
        case Platform.tiktok:
          return [topicHash, ...commonEnglish, 'tiktok', 'trending'];
        case Platform.youtube:
          return [topicHash, ...commonEnglish, 'youtube', 'video'];
      }
    }
  }

  String _generateEmoji(ContentType contentType) {
    switch (contentType) {
      case ContentType.post:
        return '📝';
      case ContentType.story:
        return '✨';
      case ContentType.reel:
        return '🎬';
      case ContentType.thread:
        return '🧵';
      case ContentType.caption:
        return '📸';
      case ContentType.ad:
        return '🎯';
    }
  }

  /// إعادة توليد المحتوى مع تعديلات
  Future<GeneratedContent> regenerateContent(
    GeneratedContent content, {
    String? newTone,
    int? newLength,
  }) async {
    return await generateContent(
      topic: content.topic,
      contentType: content.contentType,
      platform: content.platform,
      language: content.language,
      tone: newTone ?? content.tone,
      length: newLength ?? content.length,
      includeHashtags: content.hashtags.isNotEmpty,
      includeEmoji: content.emoji != null,
    );
  }

  /// تحسين محتوى موجود
  Future<String> improveContent(String text, String language) async {
    try {
      // استخدام Gemini إذا كان متاحاً
      if (_useGemini) {
        print('🤖 Using Gemini AI to improve content...');
        return await _geminiService!.improveContent(
          content: text,
          language: language,
        );
      }

      // Demo mode
      await Future.delayed(const Duration(seconds: 2));

      if (language == 'ar') {
        return '''$text

[تم تحسين المحتوى]:
• تحسين الصياغة والتنسيق
• إضافة علامات الترقيم المناسبة
• تعزيز الجاذبية والتأثير
''';
      } else {
        return '''$text

[Content improved]:
• Enhanced wording and formatting
• Added proper punctuation
• Boosted appeal and impact
''';
      }
    } catch (e) {
      throw Exception('خطأ في تحسين المحتوى: $e');
    }
  }

  /// إضافة/إزالة من المفضلة
  void toggleFavorite(String id) {
    final index = _generatedContents.indexWhere((c) => c.id == id);
    if (index != -1) {
      _generatedContents[index] = _generatedContents[index].copyWith(
        isFavorite: !_generatedContents[index].isFavorite,
      );
    }
  }

  /// حذف محتوى
  void deleteContent(String id) {
    _generatedContents.removeWhere((c) => c.id == id);
  }

  /// مسح جميع المحتويات
  void clearAllContent() {
    _generatedContents.clear();
  }

  /// الحصول على محتوى بواسطة ID
  GeneratedContent? getContentById(String id) {
    try {
      return _generatedContents.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// فلترة حسب المنصة
  List<GeneratedContent> getContentsByPlatform(Platform platform) {
    return _generatedContents.where((c) => c.platform == platform).toList();
  }

  /// فلترة حسب نوع المحتوى
  List<GeneratedContent> getContentsByType(ContentType type) {
    return _generatedContents.where((c) => c.contentType == type).toList();
  }
}
