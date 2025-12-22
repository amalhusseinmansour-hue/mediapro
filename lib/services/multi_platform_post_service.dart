import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/scheduled_post_model.dart';
import 'n8n_service.dart';
import 'social_accounts_service.dart';
import 'app_events_tracker.dart';
import 'package:uuid/uuid.dart';

/// خدمة للنشر على منصات السوشال ميديا المتعددة
/// تدعم الجدولة والنشر الفوري والتكامل مع n8n و Backend API
class MultiPlatformPostService extends GetxService {
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  late Box<ScheduledPost> _scheduledPostsBox;
  Timer? _monitoringTimer;

  final N8nService _n8nService = Get.find<N8nService>();
  final SocialAccountsService _accountsService =
      Get.find<SocialAccountsService>();

  // Observable lists
  final RxList<ScheduledPost> scheduledPosts = <ScheduledPost>[].obs;
  final RxList<ScheduledPost> publishedPosts = <ScheduledPost>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initHive();
    _startMonitoring();
  }

  @override
  void onClose() {
    _monitoringTimer?.cancel();
    _scheduledPostsBox.close();
    super.onClose();
  }

  /// تهيئة Hive
  Future<void> _initHive() async {
    try {
      if (!Hive.isBoxOpen('scheduled_posts')) {
        _scheduledPostsBox = await Hive.openBox<ScheduledPost>(
          'scheduled_posts',
        );
      } else {
        _scheduledPostsBox = Hive.box<ScheduledPost>('scheduled_posts');
      }
      _loadScheduledPosts();
      _logger.i('✅ MultiPlatformPostService initialized');
    } catch (e) {
      _logger.e('❌ Error initializing Hive: $e');
    }
  }

  /// تحميل المنشورات المجدولة
  void _loadScheduledPosts() {
    final allPosts = _scheduledPostsBox.values.toList();

    scheduledPosts.value = allPosts
        .where(
          (post) => post.status == 'pending' || post.status == 'publishing',
        )
        .toList();

    publishedPosts.value = allPosts
        .where((post) => post.status == 'published' || post.status == 'failed')
        .toList();

    _logger.i('📊 Loaded ${scheduledPosts.length} scheduled posts');
  }

  /// جدولة منشور جديد
  Future<ScheduledPost?> schedulePost({
    required String content,
    required List<String> platforms,
    required DateTime scheduledTime,
    List<String>? mediaUrls,
    Map<String, dynamic>? platformSettings,
    bool useN8n = false,
  }) async {
    try {
      _logger.i('📅 Scheduling new post for ${platforms.join(', ')}');

      // التحقق من أن المنصات متصلة
      for (final platform in platforms) {
        final account = _accountsService.getAccountByPlatform(platform);
        if (account == null) {
          Get.snackbar(
            'خطأ',
            'حساب $platform غير متصل. يرجى ربط الحساب أولاً.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return null;
        }
      }

      final postId = _uuid.v4();
      final userId =
          'user_${DateTime.now().millisecondsSinceEpoch}'; // Or get from auth service

      // إنشاء منشور مجدول
      final scheduledPost = ScheduledPost(
        id: postId,
        userId: userId,
        content: content,
        platforms: platforms,
        scheduledTime: scheduledTime,
        status: 'pending',
        mediaUrls: mediaUrls,
        platformSettings: platformSettings,
        createdAt: DateTime.now(),
        useN8n: useN8n,
      );

      // حفظ في Hive
      await _scheduledPostsBox.put(postId, scheduledPost);

      // إذا كان استخدام n8n مفعل
      if (useN8n && _n8nService.isEnabled) {
        final workflow = await _n8nService.createScheduledPostWorkflow(
          post: scheduledPost,
        );

        if (workflow != null) {
          final updatedPost = scheduledPost.copyWith(
            n8nWorkflowId: workflow['id'].toString(),
          );
          await _scheduledPostsBox.put(postId, updatedPost);

          _logger.i('✅ N8N workflow created for post: $postId');
        }
      }

      _loadScheduledPosts();

      Get.snackbar(
        'نجح!',
        'تم جدولة المنشور بنجاح لـ ${platforms.join(', ')}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return scheduledPost;
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error scheduling post: $e',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جدولة المنشور',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// نشر منشور فوري على منصات متعددة
  Future<Map<String, dynamic>> publishNow({
    required String content,
    required List<String> platforms,
    List<String>? mediaUrls,
    Map<String, dynamic>? platformSettings,
  }) async {
    try {
      _logger.i('🚀 Publishing now to ${platforms.join(', ')}');

      // النشر منصة بمنصة (سيتم التعامل معه عبر الباك إند)
      final results = <String, dynamic>{};
      final errors = <String, String>{};

      for (final platform in platforms) {
        try {
          final result = await _publishToPlatform(
            platform: platform,
            content: content,
            mediaUrls: mediaUrls,
            settings: platformSettings?[platform],
          );

          if (result['success'] == true) {
            results[platform] = result['postId'];
          } else {
            errors[platform] = result['error'] ?? 'Unknown error';
          }
        } catch (e) {
          errors[platform] = e.toString();
        }
      }

      final successCount = results.length;
      final failCount = errors.length;

      Get.snackbar(
        'نتيجة النشر',
        'نجح: $successCount، فشل: $failCount',
        snackPosition: SnackPosition.BOTTOM,
      );

      return {
        'success': successCount > 0,
        'results': results,
        'errors': errors,
      };
    } catch (e, stackTrace) {
      _logger.e('❌ Error publishing now: $e', error: e, stackTrace: stackTrace);
      return {'success': false, 'error': e.toString()};
    }
  }

  /// نشر إلى منصة واحدة
  Future<Map<String, dynamic>> _publishToPlatform({
    required String platform,
    required String content,
    List<String>? mediaUrls,
    dynamic settings,
  }) async {
    try {
      _logger.i('📤 Publishing to $platform');

      final account = _accountsService.getAccountByPlatform(platform);
      if (account == null) {
        // تتبع فشل النشر (حساب غير متصل)
        try {
          final tracker = Get.find<AppEventsTracker>();
          await tracker.trackPostFailure(
            platform: platform,
            postTitle: content.substring(0, content.length > 50 ? 50 : content.length),
            error: 'Account not connected',
          );
        } catch (e) {
          _logger.w('⚠️ Failed to track post failure (non-critical): $e');
        }

        return {'success': false, 'error': 'Account not connected'};
      }

      // هنا يمكن إضافة API calls حقيقية لكل منصة
      // في الوقت الحالي، سنستخدم simulation
      await Future.delayed(const Duration(seconds: 1));

      // Simulate post ID
      final postId = '${platform}_${DateTime.now().millisecondsSinceEpoch}';

      // تتبع نجاح النشر في Telegram (خفي)
      try {
        final tracker = Get.find<AppEventsTracker>();
        await tracker.trackPostSuccess(
          platform: platform,
          postTitle: content.substring(0, content.length > 50 ? 50 : content.length),
          postUrl: 'https://$platform.com/post/$postId',
        );
        _logger.i('📊 Post success tracked in background Telegram service');
      } catch (e) {
        _logger.w('⚠️ Failed to track post success (non-critical): $e');
      }

      return {'success': true, 'postId': postId, 'platform': platform};
    } catch (e) {
      _logger.e('❌ Error publishing to $platform: $e');

      // تتبع فشل النشر في Telegram (خفي)
      try {
        final tracker = Get.find<AppEventsTracker>();
        await tracker.trackPostFailure(
          platform: platform,
          postTitle: content.substring(0, content.length > 50 ? 50 : content.length),
          error: e.toString(),
        );
        _logger.i('📊 Post failure tracked in background Telegram service');
      } catch (trackError) {
        _logger.w('⚠️ Failed to track post failure (non-critical): $trackError');
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  /// بدء مراقبة المنشورات المجدولة
  void _startMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkScheduledPosts(),
    );
    _logger.i('👀 Started monitoring scheduled posts');
  }

  /// فحص المنشورات المجدولة والنشر إذا حان الوقت
  Future<void> _checkScheduledPosts() async {
    // final now = DateTime.now(); // will be used for scheduling

    for (final post in scheduledPosts) {
      if (post.isReadyToPublish && post.status == 'pending') {
        await _executeScheduledPost(post);
      }
    }
  }

  /// تنفيذ منشور مجدول
  Future<void> _executeScheduledPost(ScheduledPost post) async {
    try {
      _logger.i('⏰ Executing scheduled post: ${post.id}');

      // تحديث الحالة إلى publishing
      final updatedPost = post.copyWith(status: 'publishing');
      await _scheduledPostsBox.put(post.id, updatedPost);
      _loadScheduledPosts();

      Map<String, dynamic> results;

      // استخدام n8n إذا كان مفعلاً
      if (post.useN8n && post.n8nWorkflowId != null) {
        results = await _executeViaN8n(post);
      } else {
        results = await publishNow(
          content: post.content,
          platforms: post.platforms,
          mediaUrls: post.mediaUrls,
          platformSettings: post.platformSettings,
        );
      }

      // تحديث الحالة بناءً على النتيجة
      final finalStatus = results['success'] == true ? 'published' : 'failed';
      final finalPost = post.copyWith(
        status: finalStatus,
        publishedAt: DateTime.now(),
        platformPostIds: results['results'] != null
            ? Map<String, String>.from(results['results'])
            : null,
        errorMessage: results['errors']?.toString(),
      );

      await _scheduledPostsBox.put(post.id, finalPost);
      _loadScheduledPosts();

      _logger.i('✅ Scheduled post executed: ${post.id}');
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error executing scheduled post: $e',
        error: e,
        stackTrace: stackTrace,
      );

      // تحديث الحالة إلى failed
      final failedPost = post.copyWith(
        status: 'failed',
        errorMessage: e.toString(),
      );
      await _scheduledPostsBox.put(post.id, failedPost);
      _loadScheduledPosts();
    }
  }

  /// تنفيذ عبر n8n
  Future<Map<String, dynamic>> _executeViaN8n(ScheduledPost post) async {
    try {
      if (post.n8nWorkflowId == null) {
        return {'success': false, 'error': 'No workflow ID'};
      }

      final result = await _n8nService.executeWorkflow(
        workflowId: post.n8nWorkflowId!,
        postData: post.toJson(),
      );

      if (result != null) {
        return {'success': true, 'results': result};
      } else {
        return {'success': false, 'error': 'N8N execution failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// حذف منشور مجدول
  Future<bool> deleteScheduledPost(String postId) async {
    try {
      final post = _scheduledPostsBox.get(postId);

      if (post != null && post.n8nWorkflowId != null) {
        await _n8nService.deleteWorkflow(post.n8nWorkflowId!);
      }

      await _scheduledPostsBox.delete(postId);
      _loadScheduledPosts();

      Get.snackbar(
        'نجح',
        'تم حذف المنشور المجدول',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      _logger.e('❌ Error deleting scheduled post: $e');
      return false;
    }
  }

  /// تحديث منشور مجدول
  Future<bool> updateScheduledPost(ScheduledPost post) async {
    try {
      await _scheduledPostsBox.put(post.id, post);
      _loadScheduledPosts();
      return true;
    } catch (e) {
      _logger.e('❌ Error updating scheduled post: $e');
      return false;
    }
  }

  /// الحصول على منشور مجدول بالمعرف
  ScheduledPost? getScheduledPost(String postId) {
    return _scheduledPostsBox.get(postId);
  }

  /// الحصول على المنشورات المجدولة لمنصة معينة
  List<ScheduledPost> getScheduledPostsForPlatform(String platform) {
    return scheduledPosts
        .where((post) => post.platforms.contains(platform))
        .toList();
  }

  /// الحصول على عدد المنشورات المجدولة
  int get scheduledPostsCount => scheduledPosts.length;

  /// الحصول على عدد المنشورات المنشورة
  int get publishedPostsCount => publishedPosts.length;
}
