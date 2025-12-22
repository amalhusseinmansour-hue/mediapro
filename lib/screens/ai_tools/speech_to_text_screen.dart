import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/speech_to_text_service.dart';
import '../../models/transcribed_audio.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToTextService _speechToTextService = SpeechToTextService();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  late TabController _tabController;
  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isProcessing = false;

  String _selectedLanguage = 'ar';
  TranscribedAudio? _currentTranscription;
  List<String> _keywords = [];

  final Map<String, String> _languageOptions = {
    'ar': 'العربية',
    'en': 'English',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });

    // في الإنتاج، استخدم حزمة record أو audio_recorder
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isRecording = false;
    });

    // محاكاة مسار الملف المسجل
    _transcribeRecording('demo_recording.m4a');
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _transcribeRecording(String path) async {
    setState(() {
      _isTranscribing = true;
    });

    try {
      final transcription = await _speechToTextService.transcribeRecording(
        recordingPath: path,
        language: _selectedLanguage,
        title: _titleController.text.isEmpty ? null : _titleController.text,
      );

      setState(() {
        _currentTranscription = transcription;
        _textController.text = transcription.transcribedText;
        _isTranscribing = false;
      });

      // استخراج الكلمات المفتاحية
      _extractKeywords();

      Get.snackbar(
        'نجح',
        'تم تحويل الصوت إلى نص بنجاح!',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      _tabController.animateTo(1);
    } catch (e) {
      setState(() {
        _isTranscribing = false;
      });

      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      // TODO: Add file picker functionality
      Get.snackbar(
        'قريباً',
        'ميزة رفع الملفات الصوتية ستتوفر قريباً',
        backgroundColor: AppColors.darkCard,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      /* FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        setState(() {
          _isTranscribing = true;
        });

        final transcription = await _speechToTextService.transcribeAudioFile(
          audioPath: filePath,
          language: _selectedLanguage,
          title: _titleController.text.isEmpty
              ? null
              : _titleController.text,
        );

        setState(() {
          _currentTranscription = transcription;
          _textController.text = transcription.transcribedText;
          _isTranscribing = false;
        });

        _extractKeywords();

        Get.snackbar(
          'نجح',
          'تم تحويل الملف الصوتي إلى نص بنجاح!',
          backgroundColor: AppColors.neonCyan.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        _tabController.animateTo(1);
      }
*/
    } catch (e) {
      setState(() {
        _isTranscribing = false;
      });

      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _extractKeywords() async {
    if (_currentTranscription == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final keywords = await _speechToTextService.extractKeywords(
        _currentTranscription!.transcribedText,
        _selectedLanguage,
      );

      setState(() {
        _keywords = keywords;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _improveText() async {
    if (_currentTranscription == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final improvedText = await _speechToTextService.improveText(
        _textController.text,
        _selectedLanguage,
      );

      setState(() {
        _textController.text = improvedText;
        _isProcessing = false;
      });

      Get.snackbar(
        'نجح',
        'تم تحسين النص بنجاح!',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _summarizeText() async {
    if (_currentTranscription == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final summary = await _speechToTextService.summarizeText(
        _textController.text,
        _selectedLanguage,
      );

      setState(() {
        _isProcessing = false;
      });

      Get.dialog(
        AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('ملخص النص', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Text(summary, style: const TextStyle(color: Colors.white70)),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
            TextButton(
              onPressed: () {
                _textController.text = summary;
                Get.back();
              },
              child: const Text('استبدال النص'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordTab(),
                _buildEditorTab(),
                _buildGalleryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.darkCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonPink.withValues(alpha: 0.3),
                  AppColors.neonCyan.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'صوت إلى نص',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonPink.withValues(alpha: 0.3),
              AppColors.neonCyan.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(icon: Icon(Icons.mic), text: 'تسجيل'),
          Tab(icon: Icon(Icons.edit_note), text: 'المحرر'),
          Tab(icon: Icon(Icons.library_books), text: 'المعرض'),
        ],
      ),
    );
  }

  Widget _buildRecordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildLanguageSelector(),
          const SizedBox(height: 16),
          _buildTitleInput(),
          const SizedBox(height: 24),
          _buildRecordingSection(),
          const SizedBox(height: 16),
          _buildOrDivider(),
          const SizedBox(height: 16),
          _buildUploadSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonPink.withValues(alpha: 0.1),
            AppColors.neonCyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.neonCyan,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحويل الصوت إلى نص',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'سجل صوتك أو ارفع ملف صوتي لتحويله إلى نص مكتوب',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.language, color: AppColors.neonPink, size: 20),
              SizedBox(width: 12),
              Text(
                'اللغة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _languageOptions.entries.map((entry) {
              final isSelected = _selectedLanguage == entry.key;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedLanguage = entry.key;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.neonPink.withValues(alpha: 0.2)
                        : AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.neonPink
                          : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? AppColors.neonPink : Colors.grey,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.title, color: AppColors.neonCyan, size: 20),
              SizedBox(width: 12),
              Text(
                'عنوان التسجيل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(اختياري)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'أدخل عنوان للتسجيل...',
              hintStyle: TextStyle(
                color: Colors.grey.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.darkBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.neonCyan,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isRecording
              ? AppColors.neonPink
              : AppColors.neonCyan.withValues(alpha: 0.3),
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (_isTranscribing)
            Column(
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppColors.neonCyan,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'جاري تحويل الصوت إلى نص...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            )
          else
            Column(
              children: [
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isRecording
                            ? [AppColors.neonPink, Colors.red]
                            : [AppColors.neonCyan, AppColors.neonPink],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isRecording
                                      ? AppColors.neonPink
                                      : AppColors.neonCyan)
                                  .withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isRecording ? 'اضغط للإيقاف' : 'اضغط للتسجيل',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isRecording) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'جاري التسجيل...',
                    style: TextStyle(color: AppColors.neonPink, fontSize: 14),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.grey.withValues(alpha: 0.3), thickness: 1),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.grey.withValues(alpha: 0.3), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonPink.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isTranscribing ? null : _pickAudioFile,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neonPink.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: AppColors.neonPink,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'رفع ملف صوتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MP3, WAV, M4A, etc.',
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorTab() {
    if (_currentTranscription == null && !_isTranscribing) {
      return _buildEmptyState(
        icon: Icons.edit_note,
        title: 'لا يوجد نص',
        subtitle: 'قم بتسجيل صوت أو رفع ملف صوتي لبدء التحويل',
      );
    }

    if (_isTranscribing) {
      return _buildLoadingState('جاري تحويل الصوت إلى نص...');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTranscriptionInfo(),
          const SizedBox(height: 16),
          _buildSmartToolsSection(),
          const SizedBox(height: 16),
          _buildTextEditor(),
          if (_keywords.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildKeywordsSection(),
          ],
          const SizedBox(height: 16),
          _buildEditorActions(),
        ],
      ),
    );
  }

  Widget _buildTranscriptionInfo() {
    if (_currentTranscription == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.neonCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات التحويل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                Icons.mic,
                _currentTranscription!.source == AudioSource.recording
                    ? 'تسجيل'
                    : 'ملف',
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.access_time,
                '${_currentTranscription!.duration}ث',
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.speed,
                '${(_currentTranscription!.confidence * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartToolsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonPink.withValues(alpha: 0.1),
            AppColors.purple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonPink.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.neonPink, size: 20),
              SizedBox(width: 12),
              Text(
                'أدوات ذكية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSmartToolButton(
                icon: Icons.auto_fix_high,
                label: 'تحسين النص',
                onTap: _improveText,
              ),
              _buildSmartToolButton(
                icon: Icons.summarize,
                label: 'تلخيص',
                onTap: _summarizeText,
              ),
              _buildSmartToolButton(
                icon: Icons.tag,
                label: 'استخراج كلمات',
                onTap: _extractKeywords,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.darkCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.neonPink, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextEditor() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: AppColors.neonCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'محرر النصوص',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: null,
            minLines: 15,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.8,
            ),
            decoration: InputDecoration(
              hintText: 'النص المُحول سيظهر هنا...',
              hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
              filled: true,
              fillColor: AppColors.darkBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.neonCyan,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tag, color: AppColors.purple, size: 20),
              SizedBox(width: 12),
              Text(
                'الكلمات المفتاحية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _keywords.map((keyword) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
                ),
                child: Text(
                  keyword,
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.share,
            label: 'مشاركة',
            color: AppColors.neonCyan,
            onTap: () {
              Share.share(_textController.text);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.download,
            label: 'تصدير',
            color: AppColors.neonPink,
            onTap: _showExportDialog,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete_outline,
            label: 'حذف',
            color: Colors.red,
            onTap: () {
              setState(() {
                _currentTranscription = null;
                _textController.clear();
                _keywords.clear();
              });
              _tabController.animateTo(0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('تصدير النص', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption('نص عادي', 'txt'),
            const SizedBox(height: 12),
            _buildExportOption('JSON', 'json'),
            const SizedBox(height: 12),
            _buildExportOption('ترجمات SRT', 'srt'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ],
      ),
    );
  }

  Widget _buildExportOption(String label, String format) {
    return Material(
      color: AppColors.darkBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          if (_currentTranscription != null) {
            try {
              await _speechToTextService.exportToFile(
                _currentTranscription!,
                format,
              );

              Get.back();

              Get.snackbar(
                'نجح',
                'تم تصدير الملف بنجاح!',
                backgroundColor: AppColors.neonCyan.withValues(alpha: 0.8),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            } catch (e) {
              Get.snackbar(
                'خطأ',
                e.toString(),
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryTab() {
    final transcriptions = _speechToTextService.transcriptions;

    if (transcriptions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.library_books_outlined,
        title: 'لا يوجد محتوى',
        subtitle: 'قم بتسجيل صوت أو رفع ملف صوتي لبدء التحويل',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transcriptions.length,
      itemBuilder: (context, index) {
        final transcription = transcriptions[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < transcriptions.length - 1 ? 12 : 0,
          ),
          child: _buildTranscriptionCard(transcription),
        );
      },
    );
  }

  Widget _buildTranscriptionCard(TranscribedAudio transcription) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentTranscription = transcription;
              _textController.text = transcription.transcribedText;
            });
            _tabController.animateTo(1);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.neonPink.withValues(alpha: 0.3),
                            AppColors.neonCyan.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        transcription.source == AudioSource.recording
                            ? Icons.mic
                            : Icons.audio_file,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transcription.title ?? 'بدون عنوان',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(transcription.createdAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  transcription.transcribedText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChip(
                      Icons.access_time,
                      '${transcription.duration}ث',
                      AppColors.neonCyan,
                    ),
                    _buildChip(
                      Icons.language,
                      _languageOptions[transcription.language] ??
                          transcription.language,
                      AppColors.neonPink,
                    ),
                    _buildChip(
                      Icons.speed,
                      '${(transcription.confidence * 100).toStringAsFixed(0)}%',
                      AppColors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 2),
            ),
            child: Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              color: AppColors.neonCyan,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
