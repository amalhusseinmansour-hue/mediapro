import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final NotificationService _notificationService = Get.find<NotificationService>();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Gradient AppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'الإشعارات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => _notificationService.unreadCount.value > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_notificationService.unreadCount.value}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Obx(() => _notificationService.notifications.isNotEmpty
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                        color: AppColors.darkCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: AppColors.neonCyan.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'mark_all_read',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.done_all_rounded,
                                  color: AppColors.neonCyan,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'تعليم الكل كمقروء',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'clear_all',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'حذف الكل',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'mark_all_read') {
                            await _notificationService.markAllAsRead();
                            Get.snackbar(
                              'تم',
                              'تم تعليم جميع الإشعارات كمقروءة',
                              backgroundColor: AppColors.darkCard,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          } else if (value == 'clear_all') {
                            _showClearAllDialog();
                          }
                        },
                      )
                    : const SizedBox.shrink()),
              ],
            ),

            // Notifications List
            Obx(() {
              if (_notificationService.notifications.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              final groupedNotifications = _groupNotificationsByDate();

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dateKey = groupedNotifications.keys.elementAt(index);
                      final notifications = groupedNotifications[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            child: Text(
                              dateKey,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonCyan,
                              ),
                            ),
                          ),
                          // Notifications
                          ...notifications.asMap().entries.map((entry) {
                            final notifIndex = entry.key;
                            final notification = entry.value;
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 400 + (notifIndex * 100),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, animValue, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - animValue)),
                                  child: Opacity(
                                    opacity: animValue,
                                    child: _buildNotificationCard(notification),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      );
                    },
                    childCount: groupedNotifications.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate() {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();

    for (var notification in _notificationService.notifications) {
      final date = notification.timestamp;
      String dateKey;

      if (_isSameDay(date, now)) {
        dateKey = 'اليوم';
      } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
        dateKey = 'أمس';
      } else if (now.difference(date).inDays < 7) {
        dateKey = 'هذا الأسبوع';
      } else {
        dateKey = DateFormat('d MMMM yyyy', 'ar').format(date);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }

    return grouped;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) async {
        await _notificationService.deleteNotification(notification.id);
        Get.snackbar(
          'تم الحذف',
          'تم حذف الإشعار',
          backgroundColor: AppColors.darkCard,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      },
      child: GestureDetector(
        onTap: () async {
          if (!notification.isRead) {
            await _notificationService.markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: notification.isRead
                ? LinearGradient(
                    colors: [
                      AppColors.darkCard,
                      AppColors.darkCard,
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.darkCard,
                      _getColorForType(notification.type).withValues(alpha: 0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.textLight.withValues(alpha: 0.2)
                  : _getColorForType(notification.type).withValues(alpha: 0.5),
              width: notification.isRead ? 1 : 2,
            ),
            boxShadow: [
              if (!notification.isRead)
                BoxShadow(
                  color: _getColorForType(notification.type).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getColorForType(notification.type),
                        _getColorForType(notification.type).withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(notification.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: AppColors.cyanPurpleGradient,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: notification.isRead
                              ? AppColors.textLight.withValues(alpha: 0.6)
                              : AppColors.textLight,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight.withValues(alpha: 0.5),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم عرض جميع إشعاراتك هنا',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        title: const Text(
          'حذف جميع الإشعارات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(
            color: AppColors.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _notificationService.clearAllNotifications();
              Get.back();
              Get.snackbar(
                'تم',
                'تم حذف جميع الإشعارات',
                backgroundColor: AppColors.darkCard,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF4CAF50);
      case NotificationType.error:
        return const Color(0xFFF44336);
      case NotificationType.warning:
        return const Color(0xFFFFC107);
      case NotificationType.post:
        return const Color(0xFF00E5FF);
      case NotificationType.analytics:
        return const Color(0xFF7C4DFF);
      case NotificationType.scheduled:
        return const Color(0xFFFF6B9D);
      case NotificationType.account:
        return const Color(0xFF00BCD4);
      case NotificationType.system:
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF00E5FF);
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline_rounded;
      case NotificationType.error:
        return Icons.error_outline_rounded;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.post:
        return Icons.article_outlined;
      case NotificationType.analytics:
        return Icons.analytics_outlined;
      case NotificationType.scheduled:
        return Icons.schedule_rounded;
      case NotificationType.account:
        return Icons.account_circle_outlined;
      case NotificationType.system:
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('d MMM', 'ar').format(timestamp);
    }
  }
}
