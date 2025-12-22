import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/transcribed_audio.dart';
import '../core/config/env_config.dart';
import 'gemini_service.dart';

class SpeechToTextService {
  final List<TranscribedAudio> _transcriptions = [];

  List<TranscribedAudio> get transcriptions => _transcriptions;

  // Gemini API for text processing
  static String get _geminiApiKey => EnvConfig.googleAIApiKey;
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // GeminiService for AI features
  GeminiService? get _geminiService {
    try {
      return Get.find<GeminiService>();
    } catch (e) {
      return null;
    }
  }

  bool get _useGemini => _geminiService?.isConfigured ?? false;

  /// تحويل ملف صوتي إلى نص باستخدام Gemini
  Future<TranscribedAudio> transcribeAudioFile({
    required String audioPath,
    String language = 'ar',
    String? title,
  }) async {
    try {
      String transcribedText;
      int duration = 0;

      // Try Gemini audio transcription
      if (_geminiApiKey.isNotEmpty) {
        print('🎤 Transcribing audio with Gemini...');
        transcribedText = await _transcribeWithGemini(audioPath, language);

        // Estimate duration from file size
        final file = File(audioPath);
        if (await file.exists()) {
          final fileSize = await file.length();
          duration = (fileSize / 16000).round(); // Rough estimate for audio
        }
      } else {
        // Fallback to demo mode
        print('⚠️ Gemini API key not configured, using demo mode');
        await Future.delayed(const Duration(seconds: 2));
        transcribedText = _generateDemoTranscription(language);
        duration = 45;
      }

      final segments = _generateSegmentsFromText(transcribedText);

      final transcription = TranscribedAudio(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        audioPath: audioPath,
        transcribedText: transcribedText,
        createdAt: DateTime.now(),
        duration: duration,
        language: language,
        title: title ?? 'تسجيل ${_transcriptions.length + 1}',
        segments: segments,
        confidence: 0.95,
        source: AudioSource.file,
      );

      _transcriptions.insert(0, transcription);
      return transcription;
    } catch (e) {
      throw Exception('خطأ في تحويل الصوت إلى نص: $e');
    }
  }

  /// Transcribe audio using Gemini API
  Future<String> _transcribeWithGemini(String audioPath, String language) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);

      // Detect mime type from extension
      final extension = audioPath.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'mp3':
          mimeType = 'audio/mp3';
          break;
        case 'wav':
          mimeType = 'audio/wav';
          break;
        case 'm4a':
          mimeType = 'audio/mp4';
          break;
        case 'ogg':
          mimeType = 'audio/ogg';
          break;
        case 'flac':
          mimeType = 'audio/flac';
          break;
        default:
          mimeType = 'audio/mpeg';
      }

      final langName = language == 'ar' ? 'Arabic' : 'English';

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-exp:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inlineData': {
                    'mimeType': mimeType,
                    'data': base64Audio,
                  }
                },
                {
                  'text': '''Transcribe this audio file accurately.
The audio is in $langName language.
Provide only the transcription without any additional commentary.
Include proper punctuation and paragraph breaks where appropriate.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 8192,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text.isNotEmpty) {
          print('✅ Gemini transcription successful');
          return text;
        }
        throw Exception('Empty response from Gemini');
      } else {
        print('❌ Gemini transcription failed: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Gemini transcription failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in Gemini transcription: $e');
      rethrow;
    }
  }

  /// Generate segments from transcribed text
  List<AudioSegment> _generateSegmentsFromText(String text) {
    final sentences = text.split(RegExp(r'[.!?،؟]\s+'));
    final segments = <AudioSegment>[];
    int currentTime = 0;

    for (int i = 0; i < sentences.length; i++) {
      if (sentences[i].trim().isEmpty) continue;

      final duration = (sentences[i].length / 8).round() * 1000; // Estimate ~8 chars per second
      segments.add(
        AudioSegment(
          startTime: currentTime,
          endTime: currentTime + duration,
          text: sentences[i].trim(),
          confidence: 0.90 + (i % 10) * 0.01,
        ),
      );
      currentTime += duration;
    }

    return segments;
  }

  /// تحويل تسجيل صوتي إلى نص
  Future<TranscribedAudio> transcribeRecording({
    required String recordingPath,
    String language = 'ar',
    String? title,
  }) async {
    try {
      String transcribedText;
      int duration = 0;

      // Try Gemini audio transcription
      if (_geminiApiKey.isNotEmpty) {
        print('🎤 Transcribing recording with Gemini...');
        transcribedText = await _transcribeWithGemini(recordingPath, language);

        // Estimate duration from file size
        final file = File(recordingPath);
        if (await file.exists()) {
          final fileSize = await file.length();
          duration = (fileSize / 16000).round();
        }
      } else {
        // Fallback to demo mode
        print('⚠️ Gemini API key not configured, using demo mode');
        await Future.delayed(const Duration(seconds: 2));
        transcribedText = _generateDemoTranscription(language);
        duration = 30;
      }

      final segments = _generateSegmentsFromText(transcribedText);

      final transcription = TranscribedAudio(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        audioPath: recordingPath,
        transcribedText: transcribedText,
        createdAt: DateTime.now(),
        duration: duration,
        language: language,
        title: title ?? 'تسجيل ${_transcriptions.length + 1}',
        segments: segments,
        confidence: 0.92,
        source: AudioSource.recording,
      );

      _transcriptions.insert(0, transcription);
      return transcription;
    } catch (e) {
      throw Exception('خطأ في تحويل التسجيل إلى نص: $e');
    }
  }

  /// تحسين النص باستخدام الذكاء الاصطناعي (Gemini)
  Future<String> improveText(String text, String language) async {
    try {
      // Try using GeminiService first
      if (_useGemini) {
        print('✨ Improving text with GeminiService...');
        return await _geminiService!.improveContent(content: text);
      }

      // Try direct Gemini API
      if (_geminiApiKey.isNotEmpty) {
        print('✨ Improving text with Gemini API...');
        return await _improveTextWithGemini(text, language);
      }

      // Fallback to demo mode
      print('⚠️ Gemini not configured, using demo mode');
      await Future.delayed(const Duration(seconds: 1));

      if (language == 'ar') {
        return '''$text

[تم تحسين النص]:
• إضافة علامات الترقيم المناسبة
• تصحيح الأخطاء الإملائية
• تحسين الصياغة والتنسيق
''';
      } else {
        return '''$text

[Text improved]:
• Added proper punctuation
• Fixed spelling errors
• Improved formatting and structure
''';
      }
    } catch (e) {
      throw Exception('خطأ في تحسين النص: $e');
    }
  }

  /// Improve text using direct Gemini API
  Future<String> _improveTextWithGemini(String text, String language) async {
    final langInstructions = language == 'ar'
        ? 'أنت محرر نصوص محترف. قم بتحسين النص التالي من خلال: إضافة علامات الترقيم المناسبة، تصحيح الأخطاء الإملائية، وتحسين الصياغة مع الحفاظ على المعنى الأصلي. قدم النص المحسن فقط بدون أي تعليقات.'
        : 'You are a professional text editor. Improve the following text by: adding proper punctuation, fixing spelling errors, and improving the structure while preserving the original meaning. Provide only the improved text without any comments.';

    final response = await http.post(
      Uri.parse('$_geminiBaseUrl/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$langInstructions\n\nالنص:\n$text'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 4096,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (result != null && result.isNotEmpty) {
        print('✅ Text improved successfully');
        return result;
      }
    }
    throw Exception('Failed to improve text: ${response.statusCode}');
  }

  /// تلخيص النص باستخدام Gemini
  Future<String> summarizeText(String text, String language) async {
    try {
      // Try direct Gemini API
      if (_geminiApiKey.isNotEmpty) {
        print('📝 Summarizing text with Gemini...');
        return await _summarizeWithGemini(text, language);
      }

      // Fallback to demo mode
      print('⚠️ Gemini not configured, using demo mode');
      await Future.delayed(const Duration(seconds: 1));

      if (language == 'ar') {
        return 'ملخص النص:\n\nهذا نص تجريبي يوضح كيفية عمل ميزة تحويل الصوت إلى نص. يتضمن النص معلومات مهمة حول الموضوع المطروح مع أمثلة عملية.';
      } else {
        return 'Text Summary:\n\nThis is a demo text showing how the speech-to-text feature works. The text includes important information about the subject with practical examples.';
      }
    } catch (e) {
      throw Exception('خطأ في تلخيص النص: $e');
    }
  }

  /// Summarize text using Gemini API
  Future<String> _summarizeWithGemini(String text, String language) async {
    final langInstructions = language == 'ar'
        ? 'قم بتلخيص النص التالي بشكل موجز ومفيد. قدم النقاط الرئيسية في فقرة أو فقرتين.'
        : 'Summarize the following text concisely and meaningfully. Present the main points in one or two paragraphs.';

    final response = await http.post(
      Uri.parse('$_geminiBaseUrl/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$langInstructions\n\nالنص:\n$text'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 1024,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (result != null && result.isNotEmpty) {
        print('✅ Text summarized successfully');
        return result;
      }
    }
    throw Exception('Failed to summarize text: ${response.statusCode}');
  }

  /// استخراج الكلمات المفتاحية باستخدام Gemini
  Future<List<String>> extractKeywords(String text, String language) async {
    try {
      // Try direct Gemini API
      if (_geminiApiKey.isNotEmpty) {
        print('🔑 Extracting keywords with Gemini...');
        return await _extractKeywordsWithGemini(text, language);
      }

      // Fallback to demo mode
      print('⚠️ Gemini not configured, using demo mode');
      await Future.delayed(const Duration(seconds: 1));

      if (language == 'ar') {
        return [
          'الذكاء الاصطناعي',
          'تحويل الصوت',
          'التعلم الآلي',
          'التكنولوجيا',
          'الابتكار',
        ];
      } else {
        return [
          'artificial intelligence',
          'speech-to-text',
          'machine learning',
          'technology',
          'innovation',
        ];
      }
    } catch (e) {
      throw Exception('خطأ في استخراج الكلمات المفتاحية: $e');
    }
  }

  /// Extract keywords using Gemini API
  Future<List<String>> _extractKeywordsWithGemini(String text, String language) async {
    final langInstructions = language == 'ar'
        ? 'استخرج 5-10 كلمات مفتاحية من النص التالي. قدم الكلمات المفتاحية فقط، كل كلمة في سطر منفصل، بدون ترقيم أو رموز.'
        : 'Extract 5-10 keywords from the following text. Provide only the keywords, each on a separate line, without numbering or symbols.';

    final response = await http.post(
      Uri.parse('$_geminiBaseUrl/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$langInstructions\n\nالنص:\n$text'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 256,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (result != null && result.isNotEmpty) {
        print('✅ Keywords extracted successfully');
        return result
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && !s.startsWith('-') && !RegExp(r'^\d+\.').hasMatch(s))
            .map((s) => s.replaceAll(RegExp(r'^[-•]\s*'), ''))
            .toList();
      }
    }
    throw Exception('Failed to extract keywords: ${response.statusCode}');
  }

  /// توليد عنوان ذكي للنص باستخدام Gemini
  Future<String> generateSmartTitle(String text, String language) async {
    try {
      // Try direct Gemini API
      if (_geminiApiKey.isNotEmpty) {
        print('💡 Generating smart title with Gemini...');
        return await _generateTitleWithGemini(text, language);
      }

      // Fallback to demo mode
      print('⚠️ Gemini not configured, using demo mode');
      await Future.delayed(const Duration(seconds: 1));

      final timestamp = DateTime.now();
      if (language == 'ar') {
        return 'نص مُحول بتاريخ ${timestamp.day}/${timestamp.month}/${timestamp.year}';
      } else {
        return 'Transcribed Text - ${timestamp.day}/${timestamp.month}/${timestamp.year}';
      }
    } catch (e) {
      throw Exception('خطأ في توليد العنوان: $e');
    }
  }

  /// Generate smart title using Gemini API
  Future<String> _generateTitleWithGemini(String text, String language) async {
    final langInstructions = language == 'ar'
        ? 'اقترح عنواناً قصيراً وجذاباً (3-7 كلمات) للنص التالي. قدم العنوان فقط بدون أي علامات ترقيم إضافية.'
        : 'Suggest a short and engaging title (3-7 words) for the following text. Provide only the title without any additional punctuation.';

    final response = await http.post(
      Uri.parse('$_geminiBaseUrl/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$langInstructions\n\nالنص:\n$text'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.5,
          'maxOutputTokens': 64,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (result != null && result.isNotEmpty) {
        print('✅ Title generated successfully');
        return result.trim().replaceAll('"', '').replaceAll("'", '');
      }
    }

    // Fallback to timestamp-based title
    final timestamp = DateTime.now();
    if (language == 'ar') {
      return 'نص مُحول بتاريخ ${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else {
      return 'Transcribed Text - ${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _generateDemoTranscription(String language) {
    if (language == 'ar') {
      return '''مرحباً، هذا نص تجريبي تم توليده لإظهار كيفية عمل ميزة تحويل الصوت إلى نص.

في هذا النص، نستعرض مجموعة من النقاط المهمة:

أولاً: تقنية تحويل الصوت إلى نص أصبحت من أهم التقنيات في عصرنا الحالي. حيث تساعد على توفير الوقت والجهد في كتابة المحتوى.

ثانياً: استخدام الذكاء الاصطناعي يجعل عملية التحويل أكثر دقة واحترافية. كما يمكنه تصحيح الأخطاء تلقائياً.

ثالثاً: هذه التقنية مفيدة جداً للصحفيين، والكتّاب، والطلاب، ومنشئي المحتوى على وسائل التواصل الاجتماعي.

في الختام، نأمل أن تكون هذه الميزة مفيدة لك في إنشاء محتوى احترافي بسهولة وسرعة.''';
    } else {
      return '''Hello, this is a demo text generated to show how the speech-to-text feature works.

In this text, we explore several important points:

First: Speech-to-text technology has become one of the most important technologies in our current era. It helps save time and effort in content creation.

Second: Using artificial intelligence makes the conversion process more accurate and professional. It can also automatically correct errors.

Third: This technology is very useful for journalists, writers, students, and social media content creators.

In conclusion, we hope this feature will be useful for you in creating professional content easily and quickly.''';
    }
  }

  List<AudioSegment> _generateDemoSegments(String text) {
    final sentences = text.split('\n\n');
    final segments = <AudioSegment>[];
    int currentTime = 0;

    for (int i = 0; i < sentences.length; i++) {
      final duration =
          (sentences[i].length / 10).round() * 1000; // تقدير تقريبي
      segments.add(
        AudioSegment(
          startTime: currentTime,
          endTime: currentTime + duration,
          text: sentences[i],
          confidence: 0.90 + (i % 10) * 0.01,
        ),
      );
      currentTime += duration;
    }

    return segments;
  }

  /// حذف نسخة
  void deleteTranscription(String id) {
    _transcriptions.removeWhere((t) => t.id == id);
  }

  /// مسح جميع النسخ
  void clearAllTranscriptions() {
    _transcriptions.clear();
  }

  /// الحصول على نسخة بواسطة ID
  TranscribedAudio? getTranscriptionById(String id) {
    try {
      return _transcriptions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// تصدير النص إلى ملف
  Future<String> exportToFile(
    TranscribedAudio transcription,
    String format,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${transcription.title}_$timestamp.$format';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);

      switch (format.toLowerCase()) {
        case 'txt':
          await file.writeAsString(transcription.transcribedText);
          break;
        case 'json':
          await file.writeAsString(jsonEncode(transcription.toJson()));
          break;
        case 'srt':
          // تنسيق ترجمات SRT
          final srtContent = _generateSRTContent(transcription.segments);
          await file.writeAsString(srtContent);
          break;
        default:
          await file.writeAsString(transcription.transcribedText);
      }

      return filePath;
    } catch (e) {
      throw Exception('فشل تصدير الملف: $e');
    }
  }

  String _generateSRTContent(List<AudioSegment> segments) {
    final buffer = StringBuffer();
    for (int i = 0; i < segments.length; i++) {
      buffer.writeln('${i + 1}');
      buffer.writeln(
        '${_formatSRTTime(segments[i].startTime)} --> ${_formatSRTTime(segments[i].endTime)}',
      );
      buffer.writeln(segments[i].text);
      buffer.writeln();
    }
    return buffer.toString();
  }

  String _formatSRTTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$millis';
  }
}
