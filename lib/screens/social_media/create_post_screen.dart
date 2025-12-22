import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../services/postiz_manager.dart';
import '../../services/linkedin_service.dart';
import '../../core/constants/app_colors.dart';

/// نماذج المحتوى الجاهزة
class ContentTemplate {
  final String id;
  final String title;
  final String content;
  final String category;
  final IconData icon;
  final Color color;

  ContentTemplate({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
    required this.color,
  });
}

/// شاشة إنشاء وجدولة منشور محسنة
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final PostizManager _postizManager = PostizManager();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late TabController _tabController;
  late LinkedInService _linkedInService;

  List<SocialAccount> _accounts = [];
  List<String> _selectedAccountIds = [];
  List<File> _selectedImages = [];
  List<String> _uploadedUrls = [];
  DateTime? _scheduledDate;
  bool _isLoading = false;
  bool _isScheduled = false;
  String _selectedCategory = 'الكل';

  // نماذج المحتوى الجاهزة
  final List<ContentTemplate> _templates = [
    ContentTemplate(
      id: '1',
      title: 'إطلاق منتج',
      content: '🚀 نحن سعداء بالإعلان عن إطلاق [اسم المنتج]!\n\n✨ مميزات رائعة:\n• [ميزة 1]\n• [ميزة 2]\n• [ميزة 3]\n\n🎁 عرض خاص لأول 100 عميل!\n\n#إطلاق_جديد #منتج_جديد',
      category: 'تسويق',
      icon: Icons.rocket_launch_rounded,
      color: const Color(0xFF00E5FF),
    ),
    ContentTemplate(
      id: '2',
      title: 'عرض خاص',
      content: '🎉 عرض لفترة محدودة!\n\n💰 خصم [النسبة]% على [المنتج/الخدمة]\n\n⏰ العرض ساري حتى [التاريخ]\n\n🛒 لا تفوت الفرصة!\n\n#عروض #تخفيضات #خصم',
      category: 'تسويق',
      icon: Icons.local_offer_rounded,
      color: const Color(0xFFFF6B9D),
    ),
    ContentTemplate(
      id: '3',
      title: 'نصيحة اليوم',
      content: '💡 نصيحة اليوم:\n\n"[النصيحة هنا]"\n\n✨ شاركنا رأيك في التعليقات!\n\n#نصائح #تطوير_الذات #إلهام',
      category: 'محتوى قيمي',
      icon: Icons.lightbulb_rounded,
      color: const Color(0xFFFFD700),
    ),
    ContentTemplate(
      id: '4',
      title: 'سؤال للجمهور',
      content: '🤔 سؤال اليوم:\n\n[السؤال هنا]؟\n\n📝 شاركونا إجاباتكم في التعليقات!\n\n#تفاعل #سؤال_وجواب #مجتمع',
      category: 'تفاعل',
      icon: Icons.help_rounded,
      color: const Color(0xFF7C4DFF),
    ),
    ContentTemplate(
      id: '5',
      title: 'شكر للمتابعين',
      content: '❤️ شكراً لكم!\n\n🎉 وصلنا [العدد] متابع!\n\nما كان هذا ممكناً بدون دعمكم المستمر 🙏\n\n✨ نعدكم بالمزيد من المحتوى المميز!\n\n#شكر #مجتمعنا #إنجاز',
      category: 'تفاعل',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFE91E63),
    ),
    ContentTemplate(
      id: '6',
      title: 'خلف الكواليس',
      content: '🎬 خلف الكواليس!\n\n📸 نظرة حصرية على [الموضوع]\n\n[وصف قصير]\n\n👀 تابعونا للمزيد!\n\n#خلف_الكواليس #حصري #يوميات',
      category: 'محتوى قيمي',
      icon: Icons.movie_rounded,
      color: const Color(0xFF9C27B0),
    ),
    ContentTemplate(
      id: '7',
      title: 'إنفوجرافيك',
      content: '📊 معلومات مهمة عن [الموضوع]:\n\n📌 [معلومة 1]\n📌 [معلومة 2]\n📌 [معلومة 3]\n📌 [معلومة 4]\n\n💾 احفظ هذا المنشور للمراجعة!\n\n#معلومات #إنفوجرافيك #تعليم',
      category: 'تعليمي',
      icon: Icons.analytics_rounded,
      color: const Color(0xFF4CAF50),
    ),
    ContentTemplate(
      id: '8',
      title: 'قصة نجاح',
      content: '🌟 قصة نجاح!\n\n📖 [اسم الشخص/الشركة]\n\n💪 التحدي: [التحدي]\n\n🎯 الحل: [الحل]\n\n🏆 النتيجة: [النتيجة]\n\n#قصص_نجاح #إلهام #تحفيز',
      category: 'محتوى قيمي',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFFF9800),
    ),
  ];

  final List<String> _categories = [
    'الكل',
    'تسويق',
    'تفاعل',
    'محتوى قيمي',
    'تعليمي',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initLinkedInService();
    _loadAccounts();
  }

  void _initLinkedInService() {
    if (!Get.isRegistered<LinkedInService>()) {
      Get.put(LinkedInService());
    }
    _linkedInService = Get.find<LinkedInService>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _postizManager.getConnectedAccounts();
      setState(() => _accounts = accounts);
    } catch (e) {
      _showError('فشل في تحميل الحسابات: $e');
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
    _uploadedUrls.clear();

    for (final image in _selectedImages) {
      try {
        final url = await _postizManager.uploadMedia(image.path);
        if (url != null) {
          _uploadedUrls.add(url);
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _selectScheduleDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.neonCyan,
              onPrimary: Colors.white,
              surface: AppColors.darkCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.neonCyan,
                onPrimary: Colors.white,
                surface: AppColors.darkCard,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _scheduledDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _publishPost() async {
    if (_contentController.text.trim().isEmpty) {
      _showError('الرجاء كتابة محتوى المنشور');
      return;
    }

    // السماح بالنشر حتى بدون حسابات مربوطة (سيستخدم LinkedIn share)
    if (_selectedAccountIds.isEmpty && _accounts.isNotEmpty) {
      _showError('الرجاء اختيار حساب واحد على الأقل');
      return;
    }

    if (_isScheduled && _scheduledDate == null) {
      _showError('الرجاء تحديد وقت الجدولة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // إذا لا توجد حسابات مربوطة، استخدم المشاركة المباشرة
      if (_selectedAccountIds.isEmpty) {
        await _shareToLinkedIn();
        setState(() => _isLoading = false);
        return;
      }

      // رفع الصور أولاً
      if (_selectedImages.isNotEmpty) {
        await _uploadImages();
      }

      // نشر المنشور
      await _postizManager.publishPost(
        integrationIds: _selectedAccountIds,
        content: _contentController.text,
        mediaUrls: _uploadedUrls.isNotEmpty ? _uploadedUrls : null,
        scheduleDate: _isScheduled ? _scheduledDate : null,
      );

      setState(() => _isLoading = false);

      _showSuccess(
        _isScheduled ? 'تم جدولة المنشور بنجاح' : 'تم نشر المنشور بنجاح',
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('فشل النشر: $e');
    }
  }

  void _useTemplate(ContentTemplate template) {
    setState(() {
      _contentController.text = template.content;
    });
    _tabController.animateTo(0); // العودة لتبويب الكتابة
    _showSuccess('تم تطبيق القالب: ${template.title}');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.neonCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// مشاركة مباشرة على LinkedIn
  Future<void> _shareToLinkedIn() async {
    if (_contentController.text.trim().isEmpty) {
      _showError('الرجاء كتابة محتوى المنشور أولاً');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _linkedInService.shareDirectly(
        content: _contentController.text,
      );

      setState(() => _isLoading = false);

      if (result.success) {
        _showSuccess(result.message ?? 'تم فتح LinkedIn للمشاركة');
      } else {
        _showError(result.error ?? 'فشل في فتح المشاركة');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ: $e');
    }
  }

  /// مشاركة مع رابط على LinkedIn
  Future<void> _shareToLinkedInWithLink(String url, {String? title}) async {
    if (_contentController.text.trim().isEmpty) {
      _showError('الرجاء كتابة محتوى المنشور أولاً');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _linkedInService.shareWithLink(
        content: _contentController.text,
        linkUrl: url,
        title: title,
      );

      setState(() => _isLoading = false);

      if (result.success) {
        _showSuccess(result.message ?? 'تم فتح LinkedIn للمشاركة');
      } else {
        _showError(result.error ?? 'فشل في فتح المشاركة');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ: $e');
    }
  }

  /// فتح تطبيق LinkedIn مباشرة
  Future<void> _openLinkedIn() async {
    final result = await _linkedInService.openLinkedInApp();
    if (result.success) {
      _showSuccess(result.message ?? 'تم فتح LinkedIn');
    } else {
      _showError(result.error ?? 'فشل في فتح LinkedIn');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.neonCyan, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'إنشاء منشور',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(left: 16),
              child: ElevatedButton.icon(
                onPressed: _publishPost,
                icon: Icon(
                  _isScheduled ? Icons.schedule_rounded : Icons.send_rounded,
                  size: 18,
                ),
                label: Text(_isScheduled ? 'جدولة' : 'نشر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(icon: Icon(Icons.edit_rounded, size: 20), text: 'كتابة'),
                Tab(
                    icon: Icon(Icons.auto_awesome_rounded, size: 20),
                    text: 'نماذج جاهزة'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWriteTab(),
          _buildTemplatesTab(),
        ],
      ),
    );
  }

  Widget _buildWriteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // محتوى المنشور
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _contentController,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'اكتب محتوى المنشور هنا...\n\n💡 نصيحة: استخدم الإيموجي والهاشتاجات لزيادة التفاعل',
                    hintStyle: TextStyle(
                      color: AppColors.textLight.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
                // عداد الأحرف
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _contentController,
                        builder: (context, value, child) {
                          final length = value.text.length;
                          Color countColor = AppColors.textLight;
                          if (length > 280)
                            countColor = Colors.orange;
                          if (length > 500) countColor = Colors.red;

                          return Text(
                            '$length حرف',
                            style: TextStyle(
                              color: countColor,
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.tag_rounded,
                                color: AppColors.neonCyan, size: 22),
                            onPressed: () {
                              _contentController.text += ' #';
                              _contentController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _contentController.text.length),
                              );
                            },
                            tooltip: 'إضافة هاشتاج',
                          ),
                          IconButton(
                            icon: Icon(Icons.emoji_emotions_rounded,
                                color: AppColors.neonPurple, size: 22),
                            onPressed: () {
                              // يمكن إضافة لوحة إيموجي هنا
                            },
                            tooltip: 'إضافة إيموجي',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // الصور المرفقة
          if (_selectedImages.isNotEmpty) ...[
            _buildSectionTitle('الصور المرفقة', Icons.image_rounded),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return _buildAddImageButton();
                  }
                  return _buildImageThumbnail(index);
                },
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            _buildAddMediaSection(),
            const SizedBox(height: 20),
          ],

          // اختيار الحسابات
          _buildSectionTitle('اختر الحسابات للنشر', Icons.account_circle_rounded),
          const SizedBox(height: 12),
          _buildAccountsSection(),
          const SizedBox(height: 20),

          // مشاركة سريعة على LinkedIn
          _buildSectionTitle('مشاركة سريعة', Icons.rocket_launch_rounded),
          const SizedBox(height: 12),
          _buildLinkedInShareSection(),

          // خيارات الجدولة
          _buildSectionTitle('خيارات الجدولة', Icons.schedule_rounded),
          const SizedBox(height: 12),
          _buildScheduleSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return Column(
      children: [
        // فلتر التصنيفات
        Container(
          height: 50,
          margin: const EdgeInsets.all(16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  backgroundColor: AppColors.darkCard,
                  selectedColor: AppColors.neonCyan,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.neonCyan
                        : AppColors.neonCyan.withValues(alpha: 0.2),
                  ),
                ),
              );
            },
          ),
        ),
        // قائمة النماذج
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _getFilteredTemplates().length,
            itemBuilder: (context, index) {
              final template = _getFilteredTemplates()[index];
              return _buildTemplateCard(template);
            },
          ),
        ),
      ],
    );
  }

  List<ContentTemplate> _getFilteredTemplates() {
    if (_selectedCategory == 'الكل') return _templates;
    return _templates
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  Widget _buildTemplateCard(ContentTemplate template) {
    return InkWell(
      onTap: () => _useTemplate(template),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: template.color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: template.color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    template.color.withValues(alpha: 0.3),
                    template.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(template.icon, color: template.color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              template.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: template.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                template.category,
                style: TextStyle(
                  color: template.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'اضغط للاستخدام',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: template.color,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.cyanPurpleGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAddMediaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMediaButton(
            icon: Icons.image_rounded,
            label: 'صورة',
            color: AppColors.neonCyan,
            onTap: _pickImages,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.darkBorder,
          ),
          _buildMediaButton(
            icon: Icons.videocam_rounded,
            label: 'فيديو',
            color: AppColors.neonPurple,
            onTap: () {
              // إضافة فيديو
            },
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.darkBorder,
          ),
          _buildMediaButton(
            icon: Icons.gif_rounded,
            label: 'GIF',
            color: AppColors.neonMagenta,
            onTap: () {
              // إضافة GIF
            },
          ),
        ],
      ),
    );
  }

  /// قسم المشاركة السريعة على LinkedIn
  Widget _buildLinkedInShareSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A66C2).withValues(alpha: 0.2),
            const Color(0xFF0A66C2).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0A66C2).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A66C2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مشاركة على LinkedIn',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'انشر مباشرة على حسابك المهني',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareToLinkedIn,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('مشاركة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.5),
                  ),
                ),
                child: IconButton(
                  onPressed: _openLinkedIn,
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    color: Color(0xFF0A66C2),
                  ),
                  tooltip: 'فتح LinkedIn',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: _pickImages,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: AppColors.neonCyan, size: 32),
            const SizedBox(height: 4),
            Text(
              'إضافة',
              style: TextStyle(
                color: AppColors.neonCyan,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 8),
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
            ),
            image: DecorationImage(
              image: FileImage(_selectedImages[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Color(0xFFFF6B6B)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsSection() {
    if (_accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF0A66C2).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline, color: Color(0xFF0A66C2)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'لا توجد حسابات مربوطة',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'يمكنك المشاركة مباشرة على LinkedIn أو ربط حساباتك',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/social-accounts');
                    },
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('ربط حساب'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareToLinkedIn,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('شارك على LinkedIn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: _accounts.map((account) {
          final isSelected = _selectedAccountIds.contains(account.integrationId);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedAccountIds.remove(account.integrationId);
                } else {
                  _selectedAccountIds.add(account.integrationId);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.neonCyan.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.darkBorder.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: account.profilePicture != null
                          ? DecorationImage(
                              image: NetworkImage(account.profilePicture!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: account.profilePicture == null
                          ? AppColors.cyanPurpleGradient
                          : null,
                    ),
                    child: account.profilePicture == null
                        ? Center(
                            child: Text(
                              account.platform.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${account.username}',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppColors.textLight,
                              width: 2,
                            ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _isScheduled,
            onChanged: (value) {
              setState(() {
                _isScheduled = value;
                if (!value) _scheduledDate = null;
              });
            },
            title: const Text(
              'جدولة المنشور',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: _scheduledDate != null
                ? Text(
                    'سينشر في: ${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year} الساعة ${_scheduledDate!.hour}:${_scheduledDate!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 13,
                    ),
                  )
                : Text(
                    'سينشر فوراً',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
            activeThumbColor: AppColors.neonCyan,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          if (_isScheduled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton.icon(
                onPressed: _selectScheduleDateTime,
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text(
                  _scheduledDate == null ? 'اختر التاريخ والوقت' : 'تغيير الموعد',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
