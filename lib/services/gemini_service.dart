import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';

/// Gemini AI Service
/// خدمة موحدة للتعامل مع Google Gemini API
/// تدعم Gemini Pro والنماذج المتقدمة
class GeminiService extends GetxService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;

  // النماذج المتاحة في Gemini - محدثة 2025
  static const String modelPro = 'gemini-1.5-pro';         // الأفضل للمهام المعقدة
  static const String modelFlash = 'gemini-1.5-flash';     // سريع وفعال
  static const String modelPro2 = 'gemini-2.0-flash-exp';  // نموذج تجريبي سريع

  // النموذج الافتراضي - يمكن تغييره
  final RxString currentModel = 'gemini-1.5-flash'.obs;

  String get _apiKey => EnvConfig.googleAIApiKey;

  @override
  void onInit() {
    super.onInit();
    print('🤖 Gemini Service initialized (Pro Mode)');
    _validateApiKey();
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty || _apiKey.contains('your_')) {
      print('⚠️ Warning: Gemini API key not configured');
    } else {
      print('✅ Gemini Pro API key configured');
      print('📌 Current model: ${currentModel.value}');
    }
  }

  /// تغيير النموذج المستخدم
  void setModel(String model) {
    currentModel.value = model;
    print('🔄 Switched to model: $model');
  }

  /// الحصول على قائمة النماذج المتاحة
  List<Map<String, String>> get availableModels => [
    {'id': modelPro, 'name': 'Gemini 1.5 Pro', 'description': 'الأفضل للمهام المعقدة'},
    {'id': modelFlash, 'name': 'Gemini 1.5 Flash', 'description': 'سريع وفعال'},
    {'id': modelPro2, 'name': 'Gemini 2.0 Flash Exp', 'description': 'نموذج تجريبي'},
  ];

  /// توليد محتوى نصي باستخدام Gemini
  Future<String> generateContent({
    required String prompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    // استخدام النموذج المحدد أو الافتراضي (Gemini Pro)
    final useModel = model ?? currentModel.value;
    try {
      isLoading.value = true;
      lastError.value = '';

      if (_apiKey.isEmpty || _apiKey.contains('your_')) {
        throw Exception('Gemini API key not configured. Please add your API key.');
      }

      print('🔄 Calling Gemini Pro API...');
      print('📝 Model: $useModel');

      final url = '$_baseUrl/models/$useModel:generateContent?key=$_apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': maxTokens,
            'topP': 0.95,
            'topK': 40,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
          ],
        }),
      ).timeout(const Duration(seconds: 60));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            final text = content['parts'][0]['text'] as String;
            print('✅ Content generated successfully');
            return text;
          }
        }

        throw Exception('No content generated');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('Gemini API error: $errorMessage');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Gemini error: $e');

      // تحسين رسالة الخطأ للمستخدم
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('failed host lookup') ||
          errorStr.contains('network') ||
          errorStr.contains('connection')) {
        throw Exception('فشل الاتصال بالإنترنت\n\n'
            '⚠️ حلول مقترحة:\n'
            '1. تأكد من اتصالك بالإنترنت\n'
            '2. جرب التبديل بين WiFi وبيانات الموبايل\n'
            '3. أعد تشغيل الراوتر أو التطبيق\n'
            '4. تحقق من إعدادات DNS');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد محتوى لوسائل التواصل الاجتماعي
  Future<String> generateSocialMediaContent({
    required String topic,
    required String platform,
    required String contentType,
    String language = 'ar',
    String tone = 'professional',
    int maxLength = 500,
    bool includeHashtags = true,
    bool includeEmoji = true,
  }) async {
    final langText = language == 'ar' ? 'بالعربية' : 'in English';
    final toneText = _getToneDescription(tone, language);

    // Platform-specific guidelines
    final platformGuidelines = _getPlatformGuidelines(platform, language);

    final prompt = '''
أنت كاتب محتوى محترف ومتخصص في السوشال ميديا مع خبرة 10+ سنوات في إنشاء محتوى viral يحقق ملايين المشاهدات.

🎯 المهمة: اكتب $contentType $langText عن: $topic

📱 المنصة: $platform
🎨 الأسلوب: $toneText
📏 الطول: حوالي $maxLength حرف

$platformGuidelines

⚡ قواعد المحتوى التنافسي:

1. 🪝 HOOK قوي في أول 3 ثواني:
   - ابدأ بسؤال مثير أو حقيقة صادمة أو إحصائية مفاجئة
   - استخدم كلمات قوية مثل: "سر"، "لن تصدق"، "أخيراً"، "حصرياً"
   - تجنب البدايات المملة مثل "في هذا المنشور..."

2. 💎 قيمة حقيقية:
   - قدم معلومة مفيدة أو نصيحة عملية يمكن تطبيقها فوراً
   - اجعل القارئ يشعر أنه استفاد شيئاً جديداً
   - استخدم أمثلة واقعية وأرقام محددة

3. 🎭 أسلوب جذاب:
   ${includeEmoji ? '- استخدم إيموجي ملونة ومعبرة (3-7 إيموجي) لتقسيم النص وجذب العين' : '- بدون إيموجي'}
   - قسّم النص لفقرات قصيرة (2-3 أسطر)
   - استخدم التنسيق: نقاط، أرقام، فواصل أسطر

4. 🔥 Call-to-Action قوي:
   - اطلب تفاعل محدد: "شاركنا رأيك"، "احفظ المنشور"، "تاق صديقك"
   - استخدم أسئلة مفتوحة تحفز النقاش
   - خلق إحساس بالإلحاح إذا مناسب

${includeHashtags ? '''5. #️⃣ هاشتاقات ذكية (8-12 هاشتاق):
   - 3-4 هاشتاقات شائعة (أكثر من مليون استخدام)
   - 3-4 هاشتاقات متوسطة (100K-1M استخدام)
   - 2-4 هاشتاقات محددة للموضوع
   - ${language == 'ar' ? 'مزيج عربي وإنجليزي' : 'Mix of languages if appropriate'}''' : ''}

⚠️ تجنب:
- الجمل الطويلة والمعقدة
- الكلام العام بدون قيمة
- النبرة الرسمية الجافة (إلا إذا طُلب)
- تكرار نفس الكلمات

✅ اكتب المحتوى مباشرة بدون أي مقدمات مثل "إليك المحتوى" أو "بالتأكيد".
''';

    return generateContent(prompt: prompt, temperature: 0.85);
  }

  /// Get platform-specific content guidelines
  String _getPlatformGuidelines(String platform, String language) {
    final isArabic = language == 'ar';

    switch (platform.toLowerCase()) {
      case 'instagram':
        return isArabic ? '''
📸 إرشادات Instagram:
- أول جملة هي الأهم (تظهر قبل "المزيد")
- استخدم أسطر فارغة للتنسيق
- الهاشتاقات في نهاية المنشور أو في أول تعليق
- طول مثالي: 150-300 كلمة
- فقرات قصيرة جداً (1-2 سطر)''' : '''
📸 Instagram Guidelines:
- First sentence is crucial (shows before "More")
- Use line breaks for formatting
- Hashtags at end or first comment
- Ideal length: 150-300 words
- Very short paragraphs (1-2 lines)''';

      case 'twitter':
      case 'x':
        return isArabic ? '''
🐦 إرشادات Twitter/X:
- الحد 280 حرف - كن مختصراً وقوياً
- Thread إذا كان المحتوى طويل
- استخدم سؤال أو رأي جريء
- 2-3 هاشتاقات فقط
- استخدم الأرقام والقوائم''' : '''
🐦 Twitter/X Guidelines:
- 280 char limit - be concise and powerful
- Use thread for long content
- Start with question or bold opinion
- Only 2-3 hashtags
- Use numbers and lists''';

      case 'facebook':
        return isArabic ? '''
📘 إرشادات Facebook:
- محتوى أطول مقبول (300-500 كلمة)
- القصص الشخصية تعمل بشكل ممتاز
- أسئلة تحفز التعليقات
- استخدم التنسيق الغني
- شجع المشاركة والتاج''' : '''
📘 Facebook Guidelines:
- Longer content OK (300-500 words)
- Personal stories work great
- Questions encourage comments
- Use rich formatting
- Encourage shares and tags''';

      case 'linkedin':
        return isArabic ? '''
💼 إرشادات LinkedIn:
- نبرة احترافية لكن شخصية
- شارك خبرات ودروس مهنية
- استخدم إحصائيات ودراسات
- 3-5 هاشتاقات مهنية
- طول مثالي: 200-400 كلمة''' : '''
💼 LinkedIn Guidelines:
- Professional but personal tone
- Share experiences and lessons
- Use statistics and studies
- 3-5 professional hashtags
- Ideal length: 200-400 words''';

      case 'tiktok':
        return isArabic ? '''
🎵 إرشادات TikTok:
- وصف قصير ومثير (150 حرف)
- استخدم كلمات البحث الشائعة
- هاشتاقات ترند + محددة
- نص يكمل الفيديو لا يكرره
- CTA واضح: تابع، شارك، علق''' : '''
🎵 TikTok Guidelines:
- Short, exciting caption (150 chars)
- Use trending search terms
- Trending + niche hashtags
- Text complements video, doesn't repeat
- Clear CTA: follow, share, comment''';

      default:
        return isArabic ? '''
📱 إرشادات عامة:
- محتوى قابل للمشاركة
- قيمة واضحة للقارئ
- تنسيق سهل القراءة
- CTA يناسب المنصة''' : '''
📱 General Guidelines:
- Shareable content
- Clear value for reader
- Easy-to-read formatting
- Platform-appropriate CTA''';
    }
  }

  /// توليد أفكار محتوى
  Future<List<String>> generateContentIdeas({
    required String topic,
    required String platform,
    String language = 'ar',
    int count = 5,
  }) async {
    final langText = language == 'ar' ? 'بالعربية' : 'in English';

    final prompt = '''
أنت استراتيجي محتوى رقمي محترف متخصص في إنشاء أفكار viral تحقق ملايين المشاهدات.

🎯 المهمة: اقترح $count أفكار محتوى مبتكرة وتنافسية $langText لمنصة $platform عن: $topic

📋 أنواع الأفكار المطلوبة (نوّع بينها):
- 🎓 محتوى تعليمي (How-to, نصائح، أسرار)
- 😂 محتوى ترفيهي (فكاهة، تحديات، trends)
- 💡 محتوى ملهم (قصص نجاح، اقتباسات، تحفيز)
- 🔥 محتوى جدلي (آراء، نقاشات، مقارنات)
- 📊 محتوى معلوماتي (إحصائيات، حقائق، أخبار)

⚡ معايير الأفكار التنافسية:
1. كل فكرة لها "hook" قوي يجذب من أول ثانية
2. قابلة للتنفيذ فوراً
3. تحفز التفاعل (حفظ، مشاركة، تعليق)
4. مناسبة لخوارزمية $platform
5. فريدة وليست مكررة أو مملة

📝 التنسيق:
- رقم. [نوع المحتوى] عنوان الفكرة - وصف قصير لماذا ستنجح

مثال:
1. [تعليمي] "5 أسرار لن يخبرك بها أحد عن..." - يجذب الفضول ويقدم قيمة حصرية

✅ قدم الأفكار فقط بدون مقدمات:
''';

    final result = await generateContent(prompt: prompt, temperature: 0.9);

    // Parse the result into a list
    return result
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// توليد هاشتاغات ذكية
  Future<List<String>> generateHashtags({
    required String content,
    required String platform,
    String language = 'ar',
    int count = 10,
  }) async {
    final prompt = '''
أنت خبير SEO وهاشتاقات السوشال ميديا مع معرفة عميقة بالترندات الحالية.

🎯 المهمة: اقترح $count هاشتاق استراتيجي لمنصة $platform

📝 المحتوى:
$content

📊 استراتيجية الهاشتاقات المثالية:

🔥 الفئة 1 - هاشتاقات ضخمة (3-4):
- أكثر من 10 مليون استخدام
- مثل: #explore #viral #trending

📈 الفئة 2 - هاشتاقات متوسطة (3-4):
- من 100K إلى 10M استخدام
- خاصة بالمجال/الصناعة

🎯 الفئة 3 - هاشتاقات محددة (3-4):
- أقل من 100K استخدام
- خاصة بالموضوع المحدد
- تساعد في الظهور في نتائج البحث

💡 قواعد:
${language == 'ar' ? '''- مزيج 50% عربي و 50% إنجليزي
- استخدم هاشتاقات عربية شائعة مثل: #اكسبلور #السعودية #الامارات #مصر''' : '- Use a mix of popular and niche hashtags'}
- تجنب الهاشتاقات المحظورة أو المشبوهة
- كل هاشتاق في سطر منفصل يبدأ بـ #
- بدون أي نص إضافي

✅ الهاشتاقات:
''';

    final result = await generateContent(prompt: prompt, temperature: 0.6);

    return result
        .split('\n')
        .where((line) => line.trim().startsWith('#'))
        .map((line) => line.trim())
        .take(count)
        .toList();
  }

  /// تحسين محتوى موجود
  Future<String> improveContent({
    required String content,
    String language = 'ar',
    String platform = 'general',
  }) async {
    final prompt = '''
أنت محرر محتوى محترف متخصص في تحويل المحتوى العادي إلى محتوى viral يحقق أعلى تفاعل.

🎯 المهمة: حوّل هذا المحتوى إلى نسخة تنافسية عالية الجودة

📝 المحتوى الأصلي:
$content

📱 المنصة: $platform

🔧 التحسينات المطلوبة:

1. 🪝 أضف Hook قوي في البداية:
   - سؤال مثير للفضول
   - أو حقيقة صادمة
   - أو وعد بقيمة

2. ✨ حسّن الأسلوب:
   - جمل قصيرة وقوية
   - كلمات عاطفية ومؤثرة
   - تدفق سلس بين الفقرات

3. 🎨 أضف عناصر بصرية:
   - إيموجي معبرة ومتنوعة (5-8)
   - فواصل أسطر للتنسيق
   - نقاط أو أرقام إذا مناسب

4. 🔥 عزز التفاعل:
   - سؤال يحفز التعليقات
   - طلب مشاركة أو حفظ
   - CTA واضح وقوي

5. 📊 حسّن للخوارزمية:
   - كلمات مفتاحية طبيعية
   - طول مناسب للمنصة
   - بداية تشد الانتباه (أول 3 ثواني)

⚠️ حافظ على:
- الرسالة والمعنى الأساسي
- اللغة ${language == 'ar' ? 'العربية' : 'الإنجليزية'}
- أصالة المحتوى

✅ اكتب النسخة المحسنة مباشرة بدون مقدمات:
''';

    return generateContent(prompt: prompt, temperature: 0.75);
  }

  /// ترجمة المحتوى
  Future<String> translateContent({
    required String content,
    required String targetLanguage,
  }) async {
    final langName = targetLanguage == 'ar' ? 'العربية' :
                     targetLanguage == 'en' ? 'English' :
                     targetLanguage;

    final prompt = '''
ترجم المحتوى التالي إلى $langName مع الحفاظ على:
1. الأسلوب والنبرة
2. الإيموجي والتنسيق
3. الهاشتاقات (ترجمها إذا كانت كلمات)

المحتوى:
$content

قدم الترجمة فقط بدون أي مقدمات.
''';

    return generateContent(prompt: prompt, temperature: 0.3);
  }

  /// توليد رد على تعليق
  Future<String> generateReply({
    required String comment,
    String tone = 'friendly',
    String language = 'ar',
  }) async {
    final toneText = _getToneDescription(tone, language);

    final prompt = '''
اكتب رداً ${language == 'ar' ? 'بالعربية' : 'in English'} على التعليق التالي بأسلوب $toneText:

التعليق: $comment

المتطلبات:
1. الرد يجب أن يكون مهذباً واحترافياً
2. قصير ومختصر (جملة أو جملتين)
3. يشجع على استمرار المحادثة
4. يمكن إضافة إيموجي واحد مناسب

قدم الرد فقط:
''';

    return generateContent(prompt: prompt, temperature: 0.7);
  }

  /// تحليل المحتوى وإعطاء اقتراحات
  Future<Map<String, dynamic>> analyzeContent({
    required String content,
    String platform = 'general',
  }) async {
    final prompt = '''
حلل المحتوى التالي وقدم تقييماً شاملاً:

المحتوى: $content
المنصة: $platform

قدم التحليل بالشكل التالي (JSON):
{
  "score": [رقم من 0-100],
  "readability": [رقم من 0-100],
  "engagement_potential": [رقم من 0-100],
  "strengths": ["نقطة قوة 1", "نقطة قوة 2"],
  "improvements": ["اقتراح 1", "اقتراح 2", "اقتراح 3"],
  "hashtag_suggestions": ["#هاشتاق1", "#هاشتاق2"]
}

قدم JSON فقط بدون أي نص إضافي.
''';

    try {
      final result = await generateContent(prompt: prompt, temperature: 0.5);

      // Try to parse JSON from the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(result);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }

      // Fallback default values
      return {
        'score': 70,
        'readability': 75,
        'engagement_potential': 65,
        'strengths': ['محتوى واضح', 'طول مناسب'],
        'improvements': ['أضف المزيد من الإيموجي', 'استخدم أسئلة للتفاعل'],
        'hashtag_suggestions': ['#محتوى', '#سوشيال_ميديا'],
      };
    } catch (e) {
      return {
        'score': 70,
        'readability': 75,
        'engagement_potential': 65,
        'strengths': [],
        'improvements': [],
        'hashtag_suggestions': [],
        'error': e.toString(),
      };
    }
  }

  /// توليد محتوى لحملة إعلانية
  Future<String> generateAdContent({
    required String product,
    required String targetAudience,
    String language = 'ar',
    String platform = 'general',
    String adType = 'awareness', // awareness, conversion, engagement
  }) async {
    final adTypeText = {
      'awareness': language == 'ar' ? 'توعوي' : 'awareness',
      'conversion': language == 'ar' ? 'تحويلي' : 'conversion',
      'engagement': language == 'ar' ? 'تفاعلي' : 'engagement',
    };

    final prompt = '''
أنت خبير في كتابة الإعلانات الرقمية.

اكتب إعلان ${adTypeText[adType]} ${language == 'ar' ? 'بالعربية' : 'in English'} للمنتج/الخدمة التالية:

المنتج/الخدمة: $product
الجمهور المستهدف: $targetAudience
المنصة: $platform

المتطلبات:
1. عنوان جذاب يلفت الانتباه
2. وصف مختصر للفوائد الرئيسية
3. Call-to-action واضح ومحفز
4. استخدام إيموجي مناسب
5. الالتزام بحدود المنصة للإعلانات

قدم الإعلان فقط بدون مقدمات.
''';

    return generateContent(prompt: prompt, temperature: 0.8);
  }

  String _getToneDescription(String tone, String language) {
    final tones = {
      'professional': language == 'ar' ? 'احترافي ورسمي' : 'Professional and formal',
      'casual': language == 'ar' ? 'عفوي وودود' : 'Casual and friendly',
      'friendly': language == 'ar' ? 'ودود ومرح' : 'Friendly and cheerful',
      'inspirational': language == 'ar' ? 'تحفيزي وملهم' : 'Inspirational and motivating',
      'humorous': language == 'ar' ? 'فكاهي ومرح' : 'Humorous and fun',
      'educational': language == 'ar' ? 'تعليمي ومعلوماتي' : 'Educational and informative',
      'serious': language == 'ar' ? 'جدي ورصين' : 'Serious and sober',
    };
    return tones[tone] ?? tone;
  }

  /// Check if API is configured
  bool get isConfigured => _apiKey.isNotEmpty && !_apiKey.contains('your_');
}
