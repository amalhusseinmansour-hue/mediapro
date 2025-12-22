import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/gemini_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  GeminiService? _geminiService;

  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  final RxBool _isLoading = false.obs;

  // سجل المحادثة للسياق
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initGeminiService();
    _addWelcomeMessage();
  }

  void _initGeminiService() {
    try {
      _geminiService = Get.find<GeminiService>();
      print('✅ GeminiService connected to AI Assistant');
    } catch (e) {
      print('⚠️ GeminiService not found, trying to register...');
      try {
        _geminiService = Get.put(GeminiService());
        print('✅ GeminiService registered and connected');
      } catch (e2) {
        print('❌ Failed to initialize GeminiService: $e2');
      }
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: 'مرحباً! أنا مساعدك الذكي المدعوم بـ Gemini 2.5 🤖✨\n\nيمكنني مساعدتك في:\n• كتابة محتوى السوشال ميديا\n• اقتراح أفكار منشورات\n• تحسين النصوص والهاشتاقات\n• الإجابة على أسئلتك\n\nكيف يمكنني مساعدتك اليوم؟',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    _messages.add(
      ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    _messageController.clear();
    _scrollToBottom();

    // إضافة رسالة المستخدم للسجل
    _conversationHistory.add({'role': 'user', 'content': message});

    // Show loading
    _isLoading.value = true;

    try {
      if (_geminiService == null) {
        throw Exception('خدمة Gemini غير متوفرة');
      }

      // بناء السياق مع المحادثة السابقة
      String contextPrompt = '''You are a smart AI assistant specialized in social media management and digital marketing.
Your name is "MEDIA PRO Assistant" powered by Google Gemini.

IMPORTANT RULES:
1. ALWAYS respond in Arabic language (العربية) - this is mandatory
2. Provide helpful and concise answers
3. Use emojis appropriately to make responses engaging
4. Remember the conversation context
5. Be friendly and professional
6. Focus on social media content creation, marketing strategies, and digital presence

Example response format:
- Use Arabic text
- Be clear and helpful
- Add relevant emojis

''';

      // إضافة سجل المحادثة للسياق (آخر 10 رسائل)
      if (_conversationHistory.length > 1) {
        contextPrompt += 'سجل المحادثة السابقة:\n';
        final recentHistory = _conversationHistory.length > 10
            ? _conversationHistory.sublist(_conversationHistory.length - 10)
            : _conversationHistory;
        for (var msg in recentHistory.take(recentHistory.length - 1)) {
          final role = msg['role'] == 'user' ? 'المستخدم' : 'المساعد';
          contextPrompt += '$role: ${msg['content']}\n';
        }
        contextPrompt += '\n';
      }

      contextPrompt += '''
User's current message: $message

REMEMBER: You MUST respond in Arabic language (العربية). Be helpful, friendly and use emojis.
Your response:''';

      // Generate AI response using Gemini 2.5 Flash (سريع ومجاني)
      final response = await _geminiService!.generateContent(
        prompt: contextPrompt,
        // model: null = استخدام النموذج الافتراضي (gemini-2.5-flash)
        temperature: 0.7,
        maxTokens: 1024,
      );

      // إضافة رد المساعد للسجل
      _conversationHistory.add({'role': 'assistant', 'content': response});

      // Add AI response
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('❌ AI Assistant Error: $e');
      String errorMessage = 'عذراً، حدث خطأ في معالجة طلبك.';

      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'عذراً، تأكد من اتصالك بالإنترنت وحاول مرة أخرى.';
      } else if (e.toString().contains('API key')) {
        errorMessage = 'عذراً، هناك مشكلة في إعدادات الخدمة.';
      }

      _messages.add(
        ChatMessage(
          text: '$errorMessage\n\nالرجاء المحاولة مرة أخرى. 🔄',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    } finally {
      _isLoading.value = false;
      _scrollToBottom();
    }
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

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  Widget _buildQuickActionsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => AppColors.cyanPurpleGradient.createShader(bounds),
            child: const Text(
              'اقتراحات سريعة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick action buttons
          _buildQuickActionButton(
            'اقترح أفكار منشورات للأسبوع القادم',
            Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'اكتب تسميات توضيحية جذابة لمنشور',
            Icons.text_fields_rounded,
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'ما هو أفضل وقت للنشر؟',
            Icons.schedule_rounded,
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'اقترح هاشتاجات ترندينغ',
            Icons.tag_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String text, IconData icon) {
    return InkWell(
      onTap: () {
        Get.back();
        _messageController.text = text;
        _sendMessage();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المساعد الذكي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'مدعوم بـ Gemini 2.5 ✨',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: _showQuickActions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              );
            }),
          ),

          // Loading indicator
          Obx(() {
            if (!_isLoading.value) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.cyanPurpleGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'المساعد يكتب...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              border: Border(
                top: BorderSide(
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
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
                          color: AppColors.neonCyan.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك هنا...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.cyanPurpleGradient,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _sendMessage,
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? AppColors.cyanPurpleGradient
                        : null,
                    color: message.isUser
                        ? null
                        : message.isError
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppColors.darkCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: message.isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    border: !message.isUser && !message.isError
                        ? Border.all(
                            color: AppColors.neonCyan.withValues(alpha: 0.1),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isError
                          ? Colors.red[300]
                          : Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.neonCyan,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
