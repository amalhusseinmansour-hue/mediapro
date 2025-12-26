import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/advanced_ai_content_service.dart';
import '../../services/ai_proxy_service.dart';
import '../../services/http_service.dart';
import 'dart:math';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;

  AdvancedAIContentService? _aiService;
  AIProxyService? _proxyService;
  HttpService? _httpService;

  final List<String> _quickPrompts = [
    'اقترح أفكار محتوى',
    'اكتب منشور لـ Instagram',
    'اكتب تغريدة',
    'اقتراح هاشتاقات',
    'تحسين النص',
    'ترجمة للإنجليزية',
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _initService();
    _addWelcomeMessage();
  }

  void _initService() {
    try {
      if (Get.isRegistered<AdvancedAIContentService>()) {
        _aiService = Get.find<AdvancedAIContentService>();
      }
      if (Get.isRegistered<AIProxyService>()) {
        _proxyService = Get.find<AIProxyService>();
      }
      if (Get.isRegistered<HttpService>()) {
        _httpService = Get.find<HttpService>();
      }
    } catch (e) {
      print('AI Service not available: $e');
    }
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      content:
          'مرحباً! أنا مساعدك الذكي لإنشاء المحتوى. كيف يمكنني مساعدتك اليوم؟',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildQuickPrompts(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cyanPurpleGradient,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المساعد الذكي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _isTyping ? 'يكتب...' : 'متصل',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha:0.8),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: _clearChat,
          tooltip: 'مسح المحادثة',
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyMessage(message.content),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isUser ? AppColors.cyanPurpleGradient : null,
                  color: isUser ? null : AppColors.darkCard,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: AppColors.neonCyan.withValues(alpha:0.3),
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withValues(alpha:0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha:0.3),
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = sin(
                      (_typingAnimationController.value * 2 * pi) - delay,
                    );
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha:
                          0.5 + (value + 1) * 0.25,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(_quickPrompts[index]),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              backgroundColor: AppColors.darkCard,
              side: BorderSide(
                color: AppColors.neonCyan.withValues(alpha:0.3),
              ),
              onPressed: () => _sendQuickPrompt(_quickPrompts[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha:0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded),
                      color: AppColors.textSecondary,
                      onPressed: () {
                        Get.snackbar(
                          'قريباً',
                          'إرفاق الملفات قيد التطوير',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha:0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _generateAIResponse(text);
  }

  void _sendQuickPrompt(String prompt) {
    _messageController.text = prompt;
    _sendMessage();
  }

  Future<void> _generateAIResponse(String userMessage) async {
    String response;

    try {
      // Try using backend AI first
      if (_httpService != null) {
        final apiResponse = await _httpService!.post(
          '/ai/chat',
          body: {
            'message': userMessage,
            'context': 'social_media_assistant',
            'language': 'ar',
          },
        );

        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          response = apiResponse['data']['response'] ??
                     apiResponse['data']['content'] ??
                     apiResponse['data']['message'] ?? '';
          if (response.isNotEmpty) {
            _addAIResponse(response);
            return;
          }
        }
      }

      // Try using AI Proxy Service
      if (_proxyService != null) {
        final type = _detectContentType(userMessage);
        final platform = _detectPlatform(userMessage);

        response = await _proxyService!.generateContent(
          prompt: userMessage,
          type: type,
          platform: platform,
          language: 'ar',
        );

        if (response.isNotEmpty && response != userMessage) {
          _addAIResponse(response);
          return;
        }
      }

      // Try using Advanced AI Content Service
      if (_aiService != null) {
        response = await _aiService!.generateContent(
          topic: userMessage,
          contentType: 'post',
        );

        if (response.isNotEmpty) {
          _addAIResponse(response);
          return;
        }
      }

      // Fallback to local responses
      response = _generateLocalResponse(userMessage);
      _addAIResponse(response);

    } catch (e) {
      print('❌ AI Chat Error: $e');
      // Fallback to local responses on error
      response = _generateLocalResponse(userMessage);
      _addAIResponse(response);
    }
  }

  void _addAIResponse(String response) {
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  String _detectContentType(String message) {
    if (message.contains('أفكار') || message.contains('اقترح')) {
      return 'ideas';
    } else if (message.contains('هاشتاق') || message.contains('hashtag')) {
      return 'hashtags';
    } else if (message.contains('تحسين') || message.contains('حسن')) {
      return 'improve';
    } else if (message.contains('ترجم')) {
      return 'translate';
    }
    return 'content';
  }

  String _detectPlatform(String message) {
    if (message.contains('Instagram') || message.contains('انستجرام')) {
      return 'instagram';
    } else if (message.contains('تغريدة') || message.contains('Twitter') || message.contains('تويتر')) {
      return 'twitter';
    } else if (message.contains('Facebook') || message.contains('فيسبوك')) {
      return 'facebook';
    } else if (message.contains('LinkedIn') || message.contains('لينكدإن')) {
      return 'linkedin';
    } else if (message.contains('TikTok') || message.contains('تيك توك')) {
      return 'tiktok';
    }
    return 'general';
  }

  String _generateLocalResponse(String userMessage) {
    // Generate contextual responses based on user message
    if (userMessage.contains('أفكار') || userMessage.contains('اقترح')) {
      return _generateContentIdeas();
    } else if (userMessage.contains('Instagram') ||
        userMessage.contains('انستجرام')) {
      return _generateInstagramPost();
    } else if (userMessage.contains('تغريدة') || userMessage.contains('Twitter')) {
      return _generateTweet();
    } else if (userMessage.contains('هاشتاق') || userMessage.contains('hashtag')) {
      return _generateHashtags();
    } else if (userMessage.contains('تحسين') || userMessage.contains('حسن')) {
      return _generateImprovement(userMessage);
    } else if (userMessage.contains('ترجم')) {
      return _generateTranslation(userMessage);
    } else {
      return _generateGenericResponse(userMessage);
    }
  }

  String _generateContentIdeas() {
    return '''إليك بعض أفكار المحتوى الرائعة:

1. **محتوى تعليمي:**
   - نصائح وحيل في مجالك
   - شرح مفاهيم معقدة ببساطة
   - دروس قصيرة (How-to)

2. **محتوى تفاعلي:**
   - استطلاعات رأي
   - أسئلة وأجوبة مع المتابعين
   - تحديات وجوائز

3. **قصص النجاح:**
   - تجارب العملاء
   - إنجازات الفريق
   - رحلة العلامة التجارية

4. **محتوى ترفيهي:**
   - ميمز متعلقة بمجالك
   - خلف الكواليس
   - يوم في حياة الفريق

هل تريد مني تفصيل أي من هذه الأفكار؟''';
  }

  String _generateInstagramPost() {
    return '''إليك منشور Instagram جاهز:

📸 **المنشور:**

"كل يوم هو فرصة جديدة لتحقيق أهدافك! 🚀

لا تدع الخوف من الفشل يمنعك من البدء. كل خطوة صغيرة تقربك من حلمك الكبير.

ما هو الهدف الذي تسعى لتحقيقه هذا الأسبوع؟ شاركنا في التعليقات! 👇

#تحفيز #نجاح #أهداف #إلهام #تطوير_الذات #motivation #success"

---
💡 **نصائح للنشر:**
- أفضل وقت: 6-9 مساءً
- استخدم صورة ملهمة
- الرد على التعليقات مهم!''';
  }

  String _generateTweet() {
    return '''إليك مجموعة تغريدات جاهزة:

**تغريدة 1:**
"النجاح ليس وجهة، بل رحلة مستمرة من التعلم والتطور 🎯

ما هو أهم درس تعلمته هذا العام؟"

**تغريدة 2:**
"3 عادات غيرت حياتي:
1. القراءة يومياً 📚
2. التخطيط المسبق 📝
3. التعلم من الأخطاء 💪

أي عادة تريد أن تضيفها؟"

**تغريدة 3:**
"💡 نصيحة اليوم:
لا تقارن بداياتك بنهايات غيرك.
كل شخص له مساره الخاص."

---
اختر ما يناسب جمهورك! 🎯''';
  }

  String _generateHashtags() {
    return '''إليك مجموعة هاشتاقات مقترحة:

**هاشتاقات عامة:**
#محتوى #تسويق #سوشيال_ميديا #محتوى_رقمي #تسويق_الكتروني

**هاشتاقات تفاعلية:**
#شاركنا #رأيك_يهمنا #سؤال_اليوم #تحدي

**هاشتاقات إلهامية:**
#تحفيز #نجاح #إلهام #قصة_نجاح #تطوير_الذات

**هاشتاقات إنجليزية:**
#ContentCreator #SocialMedia #Marketing #DigitalMarketing #Growth

---
💡 **نصيحة:** استخدم 5-10 هاشتاقات لكل منشور للوصول الأمثل''';
  }

  String _generateImprovement(String text) {
    return '''سأساعدك في تحسين النص!

**النص الأصلي:**
"${text.replaceAll('تحسين', '').replaceAll('حسن', '').trim()}"

**النص المحسّن:**
يمكنني تحسين النص إذا أرسلته لي. أركز على:
- وضوح الرسالة
- جاذبية الأسلوب
- تحسين القواعد اللغوية
- إضافة عناصر جذب الانتباه

أرسل لي النص الذي تريد تحسينه! ✨''';
  }

  String _generateTranslation(String text) {
    return '''خدمة الترجمة:

أرسل لي النص الذي تريد ترجمته وسأقوم بترجمته لك.

**اللغات المدعومة:**
- العربية ↔ الإنجليزية
- العربية ↔ الفرنسية
- العربية ↔ الإسبانية

💡 **نصيحة:** حدد اللغة المستهدفة للحصول على ترجمة أدق.

مثال: "ترجم للإنجليزية: مرحباً بكم"''';
  }

  String _generateGenericResponse(String message) {
    final responses = [
      'شكراً لرسالتك! كيف يمكنني مساعدتك في إنشاء محتوى أفضل؟',
      'أنا هنا لمساعدتك! يمكنني:\n- كتابة منشورات\n- اقتراح أفكار\n- تحسين النصوص\n- إنشاء هاشتاقات\n\nماذا تحتاج؟',
      'رائع! دعني أساعدك في تحويل أفكارك إلى محتوى مميز. ما هو هدفك من المحتوى؟',
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ الرسالة إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'مسح المحادثة',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من مسح جميع الرسائل؟',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
