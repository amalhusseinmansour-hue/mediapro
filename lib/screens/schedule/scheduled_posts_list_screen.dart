import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/scheduled_post_model.dart';
import '../../services/multi_platform_post_service.dart';
import 'schedule_post_screen.dart';

class ScheduledPostsListScreen extends StatelessWidget {
  const ScheduledPostsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<MultiPlatformPostService>();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (service.scheduledPosts.isEmpty && service.publishedPosts.isEmpty) {
          return _buildEmptyState();
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildScheduledList(service.scheduledPosts),
                    _buildPublishedList(service.publishedPosts),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const SchedulePostScreen()),
        backgroundColor: AppColors.neonCyan,
        icon: const Icon(Icons.add_rounded),
        label: const Text('منشور جديد'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.neonCyan, AppColors.neonPurple],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'المنشورات المجدولة',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'إدارة جدول النشر',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          gradient: AppColors.cyanPurpleGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textLight,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'قيد الانتظار'),
          Tab(text: 'المنشورة'),
        ],
      ),
    );
  }

  Widget _buildScheduledList(List<ScheduledPost> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 80,
              color: AppColors.textLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد منشورات مجدولة',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildScheduledPostCard(posts[index]);
      },
    );
  }

  Widget _buildPublishedList(List<ScheduledPost> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.textLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد منشورات منشورة',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPublishedPostCard(posts[index]);
      },
    );
  }

  Widget _buildScheduledPostCard(ScheduledPost post) {
    final service = Get.find<MultiPlatformPostService>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with platforms
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.2),
                  AppColors.neonPurple.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(post.scheduledTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _buildStatusBadge(post.status),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),

                // Platforms
                Wrap(
                  spacing: 8,
                  children: post.platforms.map((platform) {
                    return _buildPlatformChip(platform);
                  }).toList(),
                ),

                if (post.useN8n) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.api, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      const Text(
                        'n8n Automation',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Time until publish
                _buildTimeUntilPublish(post),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showDeleteDialog(post, service);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('حذف'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedPostCard(ScheduledPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: post.status == 'published'
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: post.status == 'published'
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  post.status == 'published' ? Icons.check_circle : Icons.error,
                  color: post.status == 'published'
                      ? AppColors.success
                      : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post.publishedAt != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(post.publishedAt!)
                        : 'غير منشور',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _buildStatusBadge(post.status),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),

                // Platforms
                Wrap(
                  spacing: 8,
                  children: post.platforms.map((platform) {
                    final wasSuccessful = post.platformPostIds?.containsKey(platform) ?? false;
                    return _buildPlatformChip(platform, success: wasSuccessful);
                  }).toList(),
                ),

                if (post.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        text = 'قيد الانتظار';
        icon = Icons.schedule;
        break;
      case 'publishing':
        color = AppColors.neonCyan;
        text = 'جاري النشر';
        icon = Icons.upload;
        break;
      case 'published':
        color = AppColors.success;
        text = 'منشور';
        icon = Icons.check_circle;
        break;
      case 'failed':
        color = AppColors.error;
        text = 'فشل';
        icon = Icons.error;
        break;
      default:
        color = AppColors.textLight;
        text = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformChip(String platform, {bool? success}) {
    final platformData = _getPlatformData(platform);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: platformData['color'].withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: success == false
              ? AppColors.error
              : platformData['color'].withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            platformData['icon'],
            size: 14,
            color: success == false ? AppColors.error : platformData['color'],
          ),
          const SizedBox(width: 4),
          Text(
            platformData['name'],
            style: TextStyle(
              color: success == false ? AppColors.error : platformData['color'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (success == true) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check, size: 12, color: AppColors.success),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeUntilPublish(ScheduledPost post) {
    final duration = post.timeUntilPublish;

    if (duration.isNegative) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
            SizedBox(width: 8),
            Text(
              'حان وقت النشر',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    String timeText;
    if (hours > 24) {
      final days = hours ~/ 24;
      timeText = 'بعد $days يوم';
    } else if (hours > 0) {
      timeText = 'بعد $hours ساعة و $minutes دقيقة';
    } else {
      timeText = 'بعد $minutes دقيقة';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 16, color: AppColors.neonCyan),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: TextStyle(
              color: AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 100,
            color: AppColors.textLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد منشورات مجدولة',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بجدولة منشورك الأول',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const SchedulePostScreen()),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إنشاء منشور مجدول'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPlatformData(String platform) {
    final platforms = {
      'facebook': {
        'name': 'Facebook',
        'icon': Icons.facebook,
        'color': const Color(0xFF1877F2),
      },
      'instagram': {
        'name': 'Instagram',
        'icon': Icons.camera_alt,
        'color': const Color(0xFFE4405F),
      },
      'twitter': {
        'name': 'Twitter',
        'icon': Icons.chat,
        'color': const Color(0xFF1DA1F2),
      },
      'linkedin': {
        'name': 'LinkedIn',
        'icon': Icons.business,
        'color': const Color(0xFF0A66C2),
      },
      'tiktok': {
        'name': 'TikTok',
        'icon': Icons.music_note,
        'color': const Color(0xFF000000),
      },
      'youtube': {
        'name': 'YouTube',
        'icon': Icons.play_arrow,
        'color': const Color(0xFFFF0000),
      },
    };

    return platforms[platform.toLowerCase()] ??
        {
          'name': platform,
          'icon': Icons.public,
          'color': AppColors.textLight,
        };
  }

  void _showDeleteDialog(ScheduledPost post, MultiPlatformPostService service) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'حذف المنشور المجدول',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذا المنشور المجدول؟\n\nلا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await service.deleteScheduledPost(post.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
