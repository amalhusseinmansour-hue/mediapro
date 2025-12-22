import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/social_media_fetch_service.dart';
import '../../models/post_model.dart';
import '../chatbot/ai_chatbot_screen.dart';
import 'create_content_screen.dart';
import 'dart:ui';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final SocialMediaFetchService _fetchService = SocialMediaFetchService();
  List<PostModel> _allPosts = [];
  List<PostModel> _draftPosts = [];
  List<PostModel> _scheduledPosts = [];
  List<PostModel> _publishedPosts = [];
  bool _isLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();

    // جلب البوستات من السوشال ميديا
    _loadSocialMediaPosts();
  }

  Future<void> _loadSocialMediaPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      _allPosts = await _fetchService.fetchAllPosts();

      // تصنيف البوستات حسب حالتها
      _draftPosts = _allPosts.where((post) => post.status == PostStatus.draft).toList();
      _scheduledPosts = _allPosts.where((post) => post.status == PostStatus.scheduled).toList();
      _publishedPosts = _allPosts.where((post) => post.status == PostStatus.published).toList();

      print('✅ تم تحميل البوستات: ${_draftPosts.length} مسودات، ${_scheduledPosts.length} مجدولة، ${_publishedPosts.length} منشورة');
    } catch (e) {
      print('خطأ في جلب البوستات: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPosts = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.content_paste_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'المحتوى',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // زر الشات بوت
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.smart_toy_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Get.to(
                                () => const AIChatbotScreen(),
                                transition: Transition.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 400),
                              );
                            },
                            tooltip: 'المساعد الذكي',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // زر تحديث
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: _isLoadingPosts
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                  ),
                            onPressed: _isLoadingPosts ? null : _loadSocialMediaPosts,
                            tooltip: 'تحديث',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('المسودات'),
                            if (_draftPosts.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_draftPosts.length}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('المجدولة'),
                            if (_scheduledPosts.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.neonPurple.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_scheduledPosts.length}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('المنشورة'),
                            if (_publishedPosts.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.neonCyan.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_publishedPosts.length}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildContentList(_draftPosts, isDraft: true),
              _buildContentList(_scheduledPosts, isScheduled: true),
              _buildContentList(_publishedPosts, isPublished: true),
            ],
          ),
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.cyanPurpleGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.5),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Get.to(
                    () => const CreateContentScreen(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 400),
                  );
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'إنشاء محتوى',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.cyanPurpleGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'منشور',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: AppColors.neonCyan,
                          ),
                          color: AppColors.darkCard,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppColors.neonCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility_rounded, size: 20, color: AppColors.neonCyan),
                                  const SizedBox(width: 12),
                                  const Text('عرض', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share_rounded, size: 20, color: AppColors.neonPurple),
                                  const SizedBox(width: 12),
                                  const Text('مشاركة', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.content.split(' - ').first,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post.content.contains(' - ')
                            ? post.content.split(' - ').skip(1).join(' - ')
                            : post.content,
                          style: TextStyle(
                            color: AppColors.textLight.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Platforms Chips
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: post.platforms.map((platform) {
                        return _buildEnhancedPlatformChip(platform);
                      }).toList(),
                    ),
                  ),

                  // Footer with engagement
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.neonCyan,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(post.publishedAt ?? post.createdAt),
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (post.analytics != null) ...[
                          const Spacer(),
                          _buildEngagementChip(
                            Icons.favorite_rounded,
                            post.analytics!['likes']?.toString() ?? '0',
                          ),
                          const SizedBox(width: 8),
                          _buildEngagementChip(
                            Icons.comment_rounded,
                            post.analytics!['comments']?.toString() ?? '0',
                          ),
                          const SizedBox(width: 8),
                          _buildEngagementChip(
                            Icons.share_rounded,
                            post.analytics!['shares']?.toString() ?? '0',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentList(
    List<PostModel> posts, {
    bool isDraft = false,
    bool isScheduled = false,
    bool isPublished = false,
  }) {
    // عرض شاشة التحميل
    if (_isLoadingPosts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري تحميل البوستات...',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // عرض رسالة "لا يوجد محتوى"
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                isDraft
                    ? Icons.drafts_rounded
                    : isScheduled
                        ? Icons.schedule_rounded
                        : Icons.cloud_download_rounded,
                size: 60,
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isDraft
                  ? 'لا توجد مسودات'
                  : isScheduled
                      ? 'لا توجد منشورات مجدولة'
                      : 'لا توجد منشورات',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDraft
                  ? 'ابدأ بإنشاء محتوى جديد'
                  : isScheduled
                      ? 'لم تقم بجدولة أي منشورات بعد'
                      : 'سيتم عرض منشوراتك من السوشال ميديا هنا',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSocialMediaPosts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تحديث'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: AppColors.neonCyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // عرض قائمة البوستات مع Pull-to-Refresh
    return RefreshIndicator(
      onRefresh: _loadSocialMediaPosts,
      color: AppColors.neonCyan,
      backgroundColor: AppColors.darkCard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  /// Enhanced platform chip with gradient and icons
  Widget _buildEnhancedPlatformChip(String platform) {
    // تحديد اللون والأيقونة لكل منصة
    final platformData = _getPlatformData(platform);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: platformData['colors'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (platformData['colors'] as List<Color>)[0].withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            platformData['icon'] as IconData,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            platform,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// الحصول على بيانات المنصة (ألوان وأيقونات)
  Map<String, dynamic> _getPlatformData(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return {
          'colors': [const Color(0xFF1877F2), const Color(0xFF0C5EDA)],
          'icon': Icons.facebook_rounded,
        };
      case 'instagram':
        return {
          'colors': [
            const Color(0xFFC13584),
            const Color(0xFFE1306C),
            const Color(0xFFFD1D1D),
          ],
          'icon': Icons.camera_alt_rounded,
        };
      case 'twitter':
      case 'x':
        return {
          'colors': [const Color(0xFF1DA1F2), const Color(0xFF0C85D0)],
          'icon': Icons.flutter_dash_rounded,
        };
      case 'tiktok':
        return {
          'colors': [const Color(0xFF000000), const Color(0xFF69C9D0)],
          'icon': Icons.music_note_rounded,
        };
      case 'linkedin':
        return {
          'colors': [const Color(0xFF0077B5), const Color(0xFF00669C)],
          'icon': Icons.work_rounded,
        };
      case 'youtube':
        return {
          'colors': [const Color(0xFFFF0000), const Color(0xFFCC0000)],
          'icon': Icons.play_circle_filled_rounded,
        };
      default:
        return {
          'colors': [AppColors.neonCyan, AppColors.neonPurple],
          'icon': Icons.public_rounded,
        };
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildEngagementChip(IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonCyan.withValues(alpha: 0.2),
            AppColors.neonPurple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neonCyan),
          const SizedBox(width: 5),
          Text(
            count,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

}
