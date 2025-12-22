import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import '../core/config/env_config.dart';
import 'gemini_service.dart';
import 'groq_service.dart';

/// AIService - خدمة الذكاء الاصطناعي
/// Groq هو المزود الأساسي (مجاني 100%) - Gemini و ChatGPT احتياطي
class AIService {
  late OpenAI _openAI;
  late GenerativeModel _gemini;

  // استخدام GroqService كمزود أساسي - FREE & FAST
  GroqService? get _groqService {
    try {
      return Get.find<GroqService>();
    } catch (e) {
      return null;
    }
  }

  // استخدام GeminiService كاحتياطي
  GeminiService? get _geminiService {
    try {
      return Get.find<GeminiService>();
    } catch (e) {
      return null;
    }
  }

  bool get useGroq => _groqService?.isConfigured ?? false;
  bool get useUnifiedGemini => _geminiService?.isConfigured ?? false;

  // Check if Groq is available (primary check)
  bool get isGroqAvailable => EnvConfig.groqApiKey.isNotEmpty && !EnvConfig.groqApiKey.contains('your_');

  // Check if Gemini is available (backup)
  bool get isGeminiAvailable => EnvConfig.googleAIApiKey.isNotEmpty && !EnvConfig.googleAIApiKey.contains('your_');

  AIService() {
    _initializeServices();
  }

  void _initializeServices() {
    // Initialize ChatGPT using EnvConfig (Backup)
    _openAI = OpenAI.instance.build(
      token: EnvConfig.openAIApiKey,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 60),
        connectTimeout: const Duration(seconds: 60),
      ),
    );

    // Initialize Gemini using EnvConfig - BACKUP PROVIDER
    _gemini = GenerativeModel(
      model: 'gemini-2.0-flash',  // Latest Gemini model
      apiKey: EnvConfig.googleAIApiKey,
    );

    print('🤖 AIService initialized - Primary: Groq (FREE) | Backups: Gemini, ChatGPT');
  }

  // Generate content using ChatGPT
  Future<String> generateContentWithChatGPT(
    String prompt, {
    String tone = 'محترف',
    String language = 'العربية',
  }) async {
    try {
      // Check if OpenAI API key is configured
      if (EnvConfig.openAIApiKey.isEmpty || EnvConfig.openAIApiKey.contains('your_')) {
        throw Exception('مفتاح OpenAI API غير مُعد. يرجى استخدام Gemini بدلاً من ذلك.');
      }

      final enhancedPrompt = '''
      أنت مساعد ذكي متخصص في كتابة محتوى السوشال ميديا.

      المطلوب: $prompt

      الأسلوب المطلوب: $tone
      اللغة: $language

      يرجى كتابة محتوى جذاب ومناسب للنشر على السوشال ميديا.
      ''';

      final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: [
          Messages(
            role: Role.user,
            content: enhancedPrompt,
          ),
        ],
        maxToken: 500,
      );

      final response = await _openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        return response.choices.first.message?.content ?? 'فشل توليد المحتوى';
      }

      return 'فشل توليد المحتوى';
    } catch (e) {
      throw Exception('خطأ في ChatGPT: ${e.toString()}');
    }
  }

  // Generate content - يستخدم Groq أولاً (مجاني) ثم Gemini كاحتياطي
  Future<String> generateContentWithGemini(
    String prompt, {
    String tone = 'محترف',
    String language = 'العربية',
  }) async {
    // 1. محاولة Groq أولاً (مجاني 100%)
    if (useGroq) {
      try {
        print('🚀 Using Groq (FREE) as primary...');
        return await _groqService!.generateSocialMediaContent(
          topic: prompt,
          platform: 'general',
          contentType: 'post',
          language: language == 'العربية' ? 'ar' : 'en',
          tone: tone,
        );
      } catch (e) {
        print('⚠️ Groq failed: $e - Falling back to Gemini...');
      }
    }

    // 2. محاولة Gemini كاحتياطي
    try {
      if (useUnifiedGemini) {
        print('🔄 Trying Gemini as backup...');
        return await _geminiService!.generateSocialMediaContent(
          topic: prompt,
          platform: 'general',
          contentType: 'post',
          language: language == 'العربية' ? 'ar' : 'en',
          tone: tone,
        );
      }

      final langText = language == 'العربية' ? 'بالعربية' : 'in English';
      final enhancedPrompt = '''
أنت كاتب محتوى محترف ومتخصص في السوشال ميديا مع خبرة 10+ سنوات في إنشاء محتوى viral.

🎯 المهمة: اكتب محتوى سوشال ميديا $langText عن: $prompt

🎨 الأسلوب: $tone

⚡ قواعد المحتوى التنافسي:

1. 🪝 ابدأ بـ HOOK قوي:
   - سؤال مثير أو حقيقة صادمة أو وعد بقيمة
   - تجنب البدايات المملة

2. 💎 قدم قيمة حقيقية:
   - معلومة مفيدة أو نصيحة عملية
   - أمثلة واقعية إن أمكن

3. 🎭 أسلوب جذاب:
   - إيموجي ملونة ومعبرة (5-8)
   - فقرات قصيرة (2-3 أسطر)
   - تنسيق بنقاط أو أرقام

4. 🔥 Call-to-Action قوي:
   - سؤال يحفز التعليقات
   - طلب مشاركة أو حفظ

5. #️⃣ هاشتاقات (8-12):
   - مزيج عربي وإنجليزي
   - شائعة + محددة للموضوع

✅ اكتب المحتوى مباشرة بدون مقدمات:
''';

      final content = [Content.text(enhancedPrompt)];
      final response = await _gemini.generateContent(content);

      return response.text ?? 'فشل توليد المحتوى';
    } catch (e) {
      print('❌ Gemini also failed: $e');
      throw Exception('خطأ في توليد المحتوى: ${e.toString()}');
    }
  }

  // Generate image using DALL-E
  Future<String> generateImage(String prompt) async {
    try {
      final request = GenerateImage(
        prompt,
        1, // number of images
        size: ImageSize.size1024,
      );

      final response = await _openAI.generateImage(request);

      if (response != null && response.data != null && response.data!.isNotEmpty) {
        return response.data!.first?.url ?? '';
      }

      return '';
    } catch (e) {
      throw Exception('خطأ في توليد الصورة: ${e.toString()}');
    }
  }

  // Generate content ideas - يستخدم Groq أولاً
  Future<List<String>> generateContentIdeas(
    String topic, {
    int count = 5,
  }) async {
    // 1. محاولة Groq أولاً (مجاني)
    if (useGroq) {
      try {
        print('🚀 Generating ideas with Groq (FREE)...');
        return await _groqService!.generateContentIdeas(
          topic: topic,
          platform: 'general',
          count: count,
        );
      } catch (e) {
        print('⚠️ Groq failed for ideas: $e - Falling back...');
      }
    }

    try {
      // 2. محاولة Gemini كاحتياطي
      if (useUnifiedGemini) {
        return await _geminiService!.generateContentIdeas(
          topic: topic,
          platform: 'general',
          count: count,
        );
      }

      final prompt = '''
أنت استراتيجي محتوى رقمي متخصص في إنشاء أفكار viral.

🎯 اقترح $count أفكار محتوى مبتكرة وتنافسية عن: $topic

📋 أنواع الأفكار (نوّع بينها):
- 🎓 تعليمي (How-to, نصائح، أسرار)
- 😂 ترفيهي (فكاهة، تحديات)
- 💡 ملهم (قصص نجاح، تحفيز)
- 🔥 جدلي (آراء، مقارنات)

⚡ معايير كل فكرة:
1. Hook قوي يجذب من أول ثانية
2. قابلة للتنفيذ فوراً
3. تحفز التفاعل

📝 التنسيق:
رقم. [نوع] عنوان الفكرة - وصف قصير

✅ قدم الأفكار فقط:
''';

      final result = await generateContentWithGemini(prompt);

      // Parse the result into a list
      return result
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('خطأ في توليد الأفكار: ${e.toString()}');
    }
  }

  // Generate hashtags - يستخدم Groq أولاً
  Future<List<String>> generateHashtags(
    String content, {
    int count = 10,
  }) async {
    // 1. محاولة Groq أولاً (مجاني)
    if (useGroq) {
      try {
        print('🚀 Generating hashtags with Groq (FREE)...');
        return await _groqService!.generateHashtags(
          topic: content,
          platform: 'general',
          count: count,
        );
      } catch (e) {
        print('⚠️ Groq failed for hashtags: $e - Falling back...');
      }
    }

    try {
      // 2. محاولة Gemini كاحتياطي
      if (useUnifiedGemini) {
        return await _geminiService!.generateHashtags(
          content: content,
          platform: 'general',
          count: count,
        );
      }

      final prompt = '''
أنت خبير SEO وهاشتاقات السوشال ميديا.

🎯 اقترح $count هاشتاق استراتيجي للمحتوى التالي:

📝 المحتوى:
$content

📊 استراتيجية الهاشتاقات:

🔥 هاشتاقات ضخمة (3-4): أكثر من 10M استخدام
📈 هاشتاقات متوسطة (3-4): 100K-10M استخدام
🎯 هاشتاقات محددة (3-4): أقل من 100K

💡 قواعد:
- مزيج 50% عربي و 50% إنجليزي
- استخدم: #اكسبلور #السعودية #الامارات #مصر
- كل هاشتاق في سطر يبدأ بـ #
- بدون أي نص إضافي

✅ الهاشتاقات:
''';

      final result = await generateContentWithGemini(prompt);

      // Parse the result into a list
      return result
          .split('\n')
          .where((line) => line.trim().isNotEmpty && line.contains('#'))
          .map((line) => line.trim().startsWith('#') ? line.trim() : '#${line.trim()}')
          .take(count)
          .toList();
    } catch (e) {
      throw Exception('خطأ في توليد الهاشتاجات: ${e.toString()}');
    }
  }

  // Improve existing content - يستخدم Groq أولاً
  Future<String> improveContent(String content) async {
    // 1. محاولة Groq أولاً (مجاني)
    if (useGroq) {
      try {
        print('🚀 Improving content with Groq (FREE)...');
        return await _groqService!.improveContent(
          content: content,
          platform: 'general',
        );
      } catch (e) {
        print('⚠️ Groq failed for improvement: $e - Falling back...');
      }
    }

    try {
      // 2. محاولة Gemini كاحتياطي
      if (useUnifiedGemini) {
        return await _geminiService!.improveContent(content: content);
      }

      final prompt = '''
أنت محرر محتوى محترف متخصص في تحويل المحتوى العادي إلى محتوى viral.

🎯 المهمة: حوّل هذا المحتوى إلى نسخة تنافسية

📝 المحتوى الأصلي:
$content

🔧 التحسينات المطلوبة:

1. 🪝 Hook قوي في البداية (سؤال/حقيقة/وعد)

2. ✨ أسلوب جذاب:
   - جمل قصيرة وقوية
   - كلمات عاطفية

3. 🎨 عناصر بصرية:
   - إيموجي معبرة (5-8)
   - فواصل أسطر للتنسيق

4. 🔥 تفاعل:
   - سؤال يحفز التعليقات
   - CTA واضح

⚠️ حافظ على المعنى الأساسي

✅ النسخة المحسنة:
''';

      return await generateContentWithGemini(prompt);
    } catch (e) {
      throw Exception('خطأ في تحسين المحتوى: ${e.toString()}');
    }
  }

  // Translate content - يستخدم Groq أولاً
  Future<String> translateContent(String content, String targetLanguage) async {
    // 1. محاولة Groq أولاً (مجاني)
    if (useGroq) {
      try {
        print('🚀 Translating with Groq (FREE)...');
        return await _groqService!.translateContent(
          content: content,
          targetLanguage: targetLanguage == 'العربية' ? 'ar' : 'en',
        );
      } catch (e) {
        print('⚠️ Groq failed for translation: $e - Falling back...');
      }
    }

    try {
      // 2. محاولة Gemini كاحتياطي
      if (useUnifiedGemini) {
        return await _geminiService!.translateContent(
          content: content,
          targetLanguage: targetLanguage,
        );
      }

      final prompt = '''
      ترجم المحتوى التالي إلى $targetLanguage:

      $content

      قدم الترجمة فقط بدون أي مقدمات أو تعليقات.
      ''';

      return await generateContentWithChatGPT(prompt);
    } catch (e) {
      throw Exception('خطأ في الترجمة: ${e.toString()}');
    }
  }
}
