import 'package:get/get.dart';
import 'settings_service.dart';
import 'http_service.dart';

/// خدمة الجدولة الذكية للمنشورات باستخدام AI
class AISchedulingService extends GetxService {
  final SettingsService _settings = Get.find<SettingsService>();
  final HttpService _httpService = Get.find<HttpService>();

  final RxBool isScheduling = false.obs;
  final RxList<Map<String, dynamic>> scheduledPosts = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> schedulingStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    print('🤖 AI Scheduling Service initialized');
    loadScheduledPosts();
    loadStats();
  }

  // ==================== جدولة منشور واحد ====================

  /// جدولة منشور يدوياً باستخدام AI لتحديد أفضل وقت
  Future<Map<String, dynamic>> schedulePost({
    required String content,
    required List<String> platforms,
    List<String>? mediaUrls,
    DateTime? preferredTime,
    bool allowTimeAdjustment = true,
  }) async {
    try {
      isScheduling.value = true;

      final response = await _httpService.post(
        '/ai-scheduling/schedule-post',
        body: {
          'content': content,
          'platforms': platforms,
          if (mediaUrls != null && mediaUrls.isNotEmpty) 'media_urls': mediaUrls,
          if (preferredTime != null) 'preferred_time': preferredTime.toIso8601String(),
          'allow_time_adjustment': allowTimeAdjustment,
        },
      );

      if (response['success'] == true) {
        print('✅ Post scheduled successfully with AI');
        await loadScheduledPosts(); // Refresh list
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'فشلت عملية الجدولة');
      }
    } catch (e) {
      print('❌ Schedule post error: $e');
      rethrow;
    } finally {
      isScheduling.value = false;
    }
  }

  // ==================== توليد وجدولة تلقائياً ====================

  /// توليد محتوى + صورة + جدولة تلقائياً
  Future<Map<String, dynamic>> generateAndSchedule({
    required String topic,
    required List<String> platforms,
    String tone = 'professional',
    String length = 'medium',
    bool generateImage = true,
    DateTime? preferredTime,
  }) async {
    try {
      isScheduling.value = true;

      print('🎨 Generating and scheduling post for topic: $topic');

      final response = await _httpService.post(
        '/ai-scheduling/generate-and-schedule',
        body: {
          'topic': topic,
          'platforms': platforms,
          'tone': tone,
          'length': length,
          'generate_image': generateImage,
          if (preferredTime != null) 'preferred_time': preferredTime.toIso8601String(),
        },
      );

      if (response['success'] == true) {
        print('✅ Post generated and scheduled successfully');
        await loadScheduledPosts(); // Refresh list
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'فشلت عملية التوليد والجدولة');
      }
    } catch (e) {
      print('❌ Generate and schedule error: $e');
      rethrow;
    } finally {
      isScheduling.value = false;
    }
  }

  // ==================== جدولة متعددة ====================

  /// جدولة عدة منشورات على مدى فترة زمنية (أسبوع مثلاً)
  Future<Map<String, dynamic>> scheduleMultiplePosts({
    required List<String> topics,
    required List<String> platforms,
    int daysSpread = 7,
  }) async {
    try {
      isScheduling.value = true;

      print('📅 Scheduling ${topics.length} posts over $daysSpread days');

      final response = await _httpService.post(
        '/ai-scheduling/schedule-multiple',
        body: {
          'topics': topics,
          'platforms': platforms,
          'days_spread': daysSpread,
        },
      );

      if (response['success'] == true) {
        print('✅ Multiple posts scheduled successfully');
        await loadScheduledPosts(); // Refresh list
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'فشلت عملية الجدولة المتعددة');
      }
    } catch (e) {
      print('❌ Schedule multiple posts error: $e');
      rethrow;
    } finally {
      isScheduling.value = false;
    }
  }

  // ==================== جلب المنشورات المجدولة ====================

  /// الحصول على جميع المنشورات المجدولة
  Future<void> loadScheduledPosts({String? status}) async {
    try {
      final url = status != null
          ? '/ai-scheduling/my-scheduled-posts?status=$status'
          : '/ai-scheduling/my-scheduled-posts';

      final response = await _httpService.get(url);

      if (response['success'] == true) {
        final postsData = response['data']['posts'] as List;
        scheduledPosts.value = postsData.cast<Map<String, dynamic>>();
        print('📊 Loaded ${scheduledPosts.length} scheduled posts');
      }
    } catch (e) {
      print('❌ Load scheduled posts error: $e');
    }
  }

  /// الحصول على إحصائيات الجدولة
  Future<void> loadStats() async {
    try {
      final response = await _httpService.get('/ai-scheduling/stats');

      if (response['success'] == true) {
        schedulingStats.value = response['data'];
        print('📈 Scheduling stats loaded');
      }
    } catch (e) {
      print('❌ Load stats error: $e');
    }
  }

  // ==================== إدارة المنشورات المجدولة ====================

  /// إلغاء منشور مجدول
  Future<bool> cancelScheduledPost(int postId) async {
    try {
      final response = await _httpService.delete('/ai-scheduling/$postId');

      if (response['success'] == true) {
        print('✅ Post cancelled successfully');
        await loadScheduledPosts(); // Refresh list
        await loadStats(); // Refresh stats
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Cancel post error: $e');
      return false;
    }
  }

  /// إعادة جدولة منشور
  Future<bool> reschedulePost(int postId, DateTime newTime) async {
    try {
      final response = await _httpService.put(
        '/ai-scheduling/$postId/reschedule',
        body: {
          'new_time': newTime.toIso8601String(),
        },
      );

      if (response['success'] == true) {
        print('✅ Post rescheduled successfully');
        await loadScheduledPosts(); // Refresh list
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Reschedule post error: $e');
      return false;
    }
  }

  // ==================== Helpers ====================

  /// الحصول على المنشورات القادمة
  List<Map<String, dynamic>> get upcomingPosts {
    return scheduledPosts.where((post) {
      final scheduledAt = DateTime.parse(post['scheduled_at']);
      return scheduledAt.isAfter(DateTime.now()) && post['status'] == 'pending';
    }).toList();
  }

  /// الحصول على المنشورات المنشورة
  List<Map<String, dynamic>> get publishedPosts {
    return scheduledPosts.where((post) => post['status'] == 'published').toList();
  }

  /// الحصول على المنشورات الفاشلة
  List<Map<String, dynamic>> get failedPosts {
    return scheduledPosts.where((post) => post['status'] == 'failed').toList();
  }

  /// تحقق إذا كان AI Scheduling مفعّل
  bool get isAISchedulingEnabled {
    // يمكن إضافة إعداد في SettingsService لاحقاً
    return true;
  }

  /// عدد المنشورات المجدولة القادمة
  int get upcomingPostsCount => upcomingPosts.length;

  /// عدد المنشورات المنشورة
  int get publishedPostsCount => publishedPosts.length;

  /// أفضل وقت للنشر (من الإحصائيات)
  String get bestPostingTime {
    return schedulingStats['best_performing_time'] ?? '14:00';
  }

  /// أفضل منصة (من الإحصائيات)
  String get bestPlatform {
    return schedulingStats['best_performing_platform'] ?? 'instagram';
  }
}
