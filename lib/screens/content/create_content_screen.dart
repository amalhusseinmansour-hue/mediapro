import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../services/otp_service.dart';
import '../../services/subscription_service.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedContentType = 'Image Post';
  final List<String> _selectedPlatforms = [];
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  final _uuid = const Uuid();
  final _otpService = OTPService();
  final List<String> _selectedImagePaths = [];
  bool _isSaving = false;

  // Get Subscription service
  SubscriptionService? get _subscriptionService {
    try {
      return Get.find<SubscriptionService>();
    } catch (e) {
      print('⚠️ Subscription service not available: $e');
      return null;
    }
  }

  // Get Firestore service if available
  FirestoreService? get _firestoreService {
    try {
      return Get.find<FirestoreService>();
    } catch (e) {
      print('⚠️ Firestore service not available: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePaths.add(image.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اختيار الصورة: ${image.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اختيار الفيديو: ${video.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  Future<void> _saveAsDraft() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال المحتوى'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check subscription limits
    if (_subscriptionService != null) {
      try {
        await _otpService.getLocalUserData();

        // Get current month posts count from Hive
        final postsBox = await Hive.openBox<PostModel>('posts');
        final now = DateTime.now();
        final currentMonthPosts = postsBox.values.where((post) {
          return post.createdAt.year == now.year &&
              post.createdAt.month == now.month;
        }).length;

        final canCreate = await _subscriptionService!.canCreatePost(
          currentMonthPosts,
        );
        if (!canCreate) {
          return; // Subscription service will show upgrade dialog
        }
      } catch (e) {
        print('⚠️ Could not check subscription limits: $e');
      }
    }

    setState(() => _isSaving = true);

    try {
      // Get current user data
      final userData = await _otpService.getLocalUserData();
      final userId = userData?['id'] ?? 'unknown_user';

      // Create post model
      final post = PostModel(
        id: _uuid.v4(),
        content: _contentController.text.trim(),
        imageUrls: _selectedImagePaths,
        platforms: _selectedPlatforms,
        createdAt: DateTime.now(),
        status: PostStatus.draft,
        hashtags: _extractHashtags(_contentController.text),
        isScheduled: false,
      );

      // Save to Hive (local storage)
      final postsBox = await Hive.openBox<PostModel>('posts');
      await postsBox.put(post.id, post);
      print('✅ تم حفظ المنشور في Hive (محلياً)');

      // Save to Firestore if available
      if (_firestoreService != null) {
        try {
          await _firestoreService!.savePost(userId, post);
          print('✅ تم حفظ المنشور في Firestore');
        } catch (e) {
          print('⚠️ لم يتم الحفظ في Firestore: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ المحتوى كمسودة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ خطأ في حفظ المحتوى: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _scheduleContent() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال المحتوى'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_scheduledDate == null || _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تحديد تاريخ ووقت النشر'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار منصة واحدة على الأقل'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check subscription limits
    if (_subscriptionService != null) {
      try {
        // Check advanced scheduling permission
        if (!_subscriptionService!.canUseAdvancedScheduling()) {
          return; // Subscription service will show upgrade dialog
        }

        // Check posts limit
        final postsBox = await Hive.openBox<PostModel>('posts');
        final now = DateTime.now();
        final currentMonthPosts = postsBox.values.where((post) {
          return post.createdAt.year == now.year &&
              post.createdAt.month == now.month;
        }).length;

        final canCreate = await _subscriptionService!.canCreatePost(
          currentMonthPosts,
        );
        if (!canCreate) {
          return; // Subscription service will show upgrade dialog
        }
      } catch (e) {
        print('⚠️ Could not check subscription limits: $e');
      }
    }

    setState(() => _isSaving = true);

    try {
      // Get current user data
      final userData = await _otpService.getLocalUserData();
      final userId = userData?['id'] ?? 'unknown_user';

      // Combine date and time
      final scheduledDateTime = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );

      // Create post model
      final post = PostModel(
        id: _uuid.v4(),
        content: _contentController.text.trim(),
        imageUrls: _selectedImagePaths,
        platforms: _selectedPlatforms,
        createdAt: DateTime.now(),
        status: PostStatus.scheduled,
        hashtags: _extractHashtags(_contentController.text),
        isScheduled: true,
        scheduledTime: scheduledDateTime,
      );

      // Save to Hive (local storage)
      final postsBox = await Hive.openBox<PostModel>('posts');
      await postsBox.put(post.id, post);
      print('✅ تم حفظ المنشور المجدول في Hive');

      // Save to Firestore if available
      if (_firestoreService != null) {
        try {
          await _firestoreService!.savePost(userId, post);
          print('✅ تم حفظ المنشور المجدول في Firestore');
          print('📅 موعد النشر: $scheduledDateTime');
          print('📱 المنصات: ${_selectedPlatforms.join(', ')}');
        } catch (e) {
          print('⚠️ لم يتم الحفظ في Firestore: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم جدولة المحتوى بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ خطأ في جدولة المحتوى: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Extract hashtags from content
  List<String> _extractHashtags(String text) {
    final hashtagRegex = RegExp(r'#[\u0600-\u06FFa-zA-Z0-9_]+');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive values
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    final horizontalPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 16.0
        : 24.0;
    final verticalSpacing = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 16.0
        : 20.0;
    final titleFontSize = isSmallScreen
        ? 14.0
        : isMediumScreen
        ? 15.0
        : 16.0;
    final buttonHeight = isSmallScreen
        ? 44.0
        : isMediumScreen
        ? 48.0
        : 56.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'إنشاء محتوى',
          style: TextStyle(fontSize: isSmallScreen ? 18.0 : 20.0),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: horizontalPadding / 2),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _saveAsDraft,
              icon: _isSaving
                  ? SizedBox(
                      width: isSmallScreen ? 14.0 : 16.0,
                      height: isSmallScreen ? 14.0 : 16.0,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.save_outlined,
                      size: isSmallScreen ? 18.0 : 20.0,
                    ),
              label: Text(
                _isSaving ? 'جاري الحفظ...' : 'حفظ',
                style: TextStyle(fontSize: isSmallScreen ? 12.0 : 14.0),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : 12.0,
                  vertical: isSmallScreen ? 6.0 : 8.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              style: TextStyle(fontSize: titleFontSize),
              decoration: InputDecoration(
                labelText: 'عنوان المحتوى',
                labelStyle: TextStyle(fontSize: titleFontSize),
                prefixIcon: Icon(
                  Icons.title,
                  size: isSmallScreen ? 20.0 : 24.0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isSmallScreen ? 12.0 : 16.0,
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),

            // Content Type Selector
            Text(
              'نوع المحتوى',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            SizedBox(height: verticalSpacing * 0.75),
            Wrap(
              spacing: isSmallScreen ? 6.0 : 8.0,
              runSpacing: isSmallScreen ? 6.0 : 8.0,
              children: AppConstants.contentTypes.map((type) {
                final isSelected = _selectedContentType == type;
                return ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(fontSize: isSmallScreen ? 11.0 : 13.0),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedContentType = type;
                    });
                  },
                  selectedColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 12.0,
                    vertical: isSmallScreen ? 4.0 : 6.0,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: verticalSpacing * 1.5),

            // Content Field
            TextFormField(
              controller: _contentController,
              maxLines: isSmallScreen ? 5 : 6,
              style: TextStyle(fontSize: titleFontSize),
              decoration: InputDecoration(
                labelText: 'المحتوى',
                labelStyle: TextStyle(fontSize: titleFontSize),
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isSmallScreen ? 12.0 : 16.0,
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),

            // Media Buttons
            isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(
                          Icons.image,
                          size: isSmallScreen ? 18.0 : 20.0,
                        ),
                        label: Text(
                          'إضافة صورة',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13.0 : 14.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryPurple,
                          side: const BorderSide(
                            color: AppColors.primaryPurple,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10.0 : 12.0,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 0.5),
                      OutlinedButton.icon(
                        onPressed: _pickVideo,
                        icon: Icon(
                          Icons.videocam,
                          size: isSmallScreen ? 18.0 : 20.0,
                        ),
                        label: Text(
                          'إضافة فيديو',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13.0 : 14.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryPink,
                          side: const BorderSide(color: AppColors.primaryPink),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10.0 : 12.0,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(
                            Icons.image,
                            size: isSmallScreen ? 18.0 : 20.0,
                          ),
                          label: Text(
                            'إضافة صورة',
                            style: TextStyle(fontSize: titleFontSize - 1),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryPurple,
                            side: const BorderSide(
                              color: AppColors.primaryPurple,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 10.0 : 12.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: horizontalPadding * 0.75),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickVideo,
                          icon: Icon(
                            Icons.videocam,
                            size: isSmallScreen ? 18.0 : 20.0,
                          ),
                          label: Text(
                            'إضافة فيديو',
                            style: TextStyle(fontSize: titleFontSize - 1),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryPink,
                            side: const BorderSide(
                              color: AppColors.primaryPink,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 10.0 : 12.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: verticalSpacing * 1.5),

            // Platform Selector
            Text(
              'المنصات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            SizedBox(height: verticalSpacing * 0.75),
            Wrap(
              spacing: isSmallScreen ? 6.0 : 8.0,
              runSpacing: isSmallScreen ? 6.0 : 8.0,
              children: AppConstants.socialPlatforms.map((platform) {
                final isSelected = _selectedPlatforms.contains(platform);
                return FilterChip(
                  label: Text(
                    platform,
                    style: TextStyle(fontSize: isSmallScreen ? 11.0 : 13.0),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPlatforms.add(platform);
                      } else {
                        _selectedPlatforms.remove(platform);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primaryPurple,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 12.0,
                    vertical: isSmallScreen ? 4.0 : 6.0,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: verticalSpacing * 1.5),

            // Schedule Section
            Text(
              'جدولة النشر',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            SizedBox(height: verticalSpacing * 0.75),
            isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: Icon(
                          Icons.calendar_today,
                          size: isSmallScreen ? 16.0 : 18.0,
                        ),
                        label: Text(
                          _scheduledDate == null
                              ? 'اختر التاريخ'
                              : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13.0 : 14.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryPurple,
                          side: const BorderSide(color: AppColors.border),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10.0 : 12.0,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 0.5),
                      OutlinedButton.icon(
                        onPressed: _selectTime,
                        icon: Icon(
                          Icons.access_time,
                          size: isSmallScreen ? 16.0 : 18.0,
                        ),
                        label: Text(
                          _scheduledTime == null
                              ? 'اختر الوقت'
                              : '${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13.0 : 14.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryPurple,
                          side: const BorderSide(color: AppColors.border),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10.0 : 12.0,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: Icon(
                            Icons.calendar_today,
                            size: isSmallScreen ? 16.0 : 18.0,
                          ),
                          label: Text(
                            _scheduledDate == null
                                ? 'اختر التاريخ'
                                : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                            style: TextStyle(fontSize: titleFontSize - 1),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryPurple,
                            side: const BorderSide(color: AppColors.border),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 10.0 : 12.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: horizontalPadding * 0.75),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectTime,
                          icon: Icon(
                            Icons.access_time,
                            size: isSmallScreen ? 16.0 : 18.0,
                          ),
                          label: Text(
                            _scheduledTime == null
                                ? 'اختر الوقت'
                                : '${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: titleFontSize - 1),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryPurple,
                            side: const BorderSide(color: AppColors.border),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 10.0 : 12.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: verticalSpacing * 2),

            // Schedule Button
            SizedBox(
              width: double.infinity,
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 10.0 : 12.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purpleShadow,
                      blurRadius: isSmallScreen ? 6.0 : 8.0,
                      offset: Offset(0, isSmallScreen ? 3.0 : 4.0),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _scheduleContent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 10.0 : 12.0,
                      ),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: isSmallScreen ? 20.0 : 24.0,
                          width: isSmallScreen ? 20.0 : 24.0,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'جدولة المحتوى',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? 15.0
                                : isMediumScreen
                                ? 16.0
                                : 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            // Add bottom padding for safe area
            SizedBox(height: verticalSpacing),
          ],
        ),
      ),
    );
  }
}
