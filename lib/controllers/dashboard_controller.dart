import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/sponsored_ads_service.dart';
import '../services/api_service.dart';
import '../services/social_accounts_service.dart';
import '../models/activity_model.dart';
import '../core/constants/app_colors.dart';

/// كونترولر لوحة التحكم - لإدارة الإحصائيات والبيانات مع Real-time Updates
class DashboardController extends GetxController {
  FirestoreService? _firestoreService;
  AuthService? _authService;
  SponsoredAdsService? _adsService;
  ApiService? _apiService;
  SocialAccountsService? _accountsService;

  FirestoreService get firestoreService {
    _firestoreService ??= Get.find<FirestoreService>();
    return _firestoreService!;
  }

  AuthService get authService {
    _authService ??= Get.find<AuthService>();
    return _authService!;
  }

  SponsoredAdsService get adsService {
    _adsService ??= Get.find<SponsoredAdsService>();
    return _adsService!;
  }

  ApiService get apiService {
    _apiService ??= Get.find<ApiService>();
    return _apiService!;
  }

  SocialAccountsService get accountsService {
    _accountsService ??= Get.find<SocialAccountsService>();
    return _accountsService!;
  }

  // Observable statistics
  final RxInt totalPosts = 0.obs;
  final RxInt publishedPosts = 0.obs;
  final RxInt scheduledPosts = 0.obs;
  final RxInt connectedAccounts = 0.obs;
  final RxInt totalEngagement = 0.obs;
  final RxInt pendingAdsCount = 0.obs;
  final RxInt activeAdsCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isListening = false.obs;

  // Recent Activities
  final RxList<ActivityModel> recentActivities = <ActivityModel>[].obs;
  Box<Map>? _activitiesBox;

  // Stream subscriptions للاستماع للتحديثات
  StreamSubscription? _postsSubscription;
  StreamSubscription? _accountsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initActivitiesBox();
    fetchDashboardStats();
    startListening(); // بدء الاستماع للتحديثات
    _loadRecentActivities();
  }

  Future<void> _initActivitiesBox() async {
    try {
      _activitiesBox = await Hive.openBox<Map>('recentActivities');
    } catch (e) {
      print('خطأ في فتح صندوق النشاطات: $e');
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      if (_activitiesBox == null) return;

      final activities = _activitiesBox!.values
          .map(
            (activityMap) =>
                ActivityModel.fromMap(Map<String, dynamic>.from(activityMap)),
          )
          .toList();

      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      recentActivities.value = activities.take(10).toList();
    } catch (e) {
      print('خطأ في تحميل النشاطات: $e');
    }
  }

  @override
  void onClose() {
    stopListening(); // إيقاف الاستماع عند إغلاق الكونترولر
    super.onClose();
  }

  /// جلب إحصائيات لوحة التحكم
  Future<void> fetchDashboardStats() async {
    print('📊 [Dashboard] بدء جلب إحصائيات لوحة التحكم...');
    try {
      isLoading.value = true;

      final userId = authService.currentUser.value?.id;
      if (userId == null) {
        print('❌ [Dashboard] لا يوجد مستخدم مسجل دخول');
        return;
      }

      print('📊 [Dashboard] جلب الإحصائيات للمستخدم: $userId');

      // جلب الإحصائيات من Backend API بدلاً من Firestore
      await _fetchStatsFromBackend();

      // تحديث إحصائيات الإعلانات
      _updateAdsStats();

      print('✅ [Dashboard] النتائج النهائية:');
      print('   - الحسابات المتصلة: ${connectedAccounts.value}');
      print('   - إجمالي المنشورات: ${totalPosts.value}');
      print('   - المنشورة: ${publishedPosts.value}');
      print('   - المجدولة: ${scheduledPosts.value}');
      print('   - التفاعل: ${totalEngagement.value}');
    } catch (e) {
      print('❌ [Dashboard] خطأ في جلب إحصائيات لوحة التحكم: $e');
      // في حالة الفشل، حاول من Firestore كـ fallback
      await _fetchStatsFromFirestore();
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب الإحصائيات من Backend API
  Future<void> _fetchStatsFromBackend() async {
    try {
      // أولاً: انتظر حتى ينتهي SocialAccountsService من التحميل (حد أقصى 3 ثواني)
      List accounts = [];

      // انتظر حتى ينتهي التحميل أو انقضاء الوقت
      int waitCount = 0;
      while (accountsService.isLoading.value && waitCount < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }

      // تحقق من وجود حسابات محفوظة في SocialAccountsService
      final cachedAccounts = accountsService.accounts;
      if (cachedAccounts.isNotEmpty) {
        connectedAccounts.value = cachedAccounts.length;
        print('✅ استخدام الحسابات المحفوظة: ${cachedAccounts.length}');
        // تحويل الحسابات إلى صيغة API للتوافق
        accounts = cachedAccounts.map((a) => {
          'id': a.id,
          'platform': a.platform,
          'account_name': a.accountName,
        }).toList();
      } else {
        // إذا لم تكن هناك حسابات محفوظة، حاول جلبها من API
        print('⏳ لا توجد حسابات محفوظة، جلب من API...');
        final accountsResponse = await apiService.getSocialAccounts();
        if (accountsResponse['success'] == true) {
          accounts = accountsResponse['data'] as List? ?? [];
          connectedAccounts.value = accounts.length;
          print('✅ عدد الحسابات المتصلة من API: ${accounts.length}');
        }
      }

      // جلب التحليلات لكل حساب
      int totalFollowersCount = 0;
      int totalEngagementCount = 0;
      int totalPostsCount = 0;

      for (var account in accounts) {
        try {
          final accountId = account['id']?.toString();
          if (accountId != null) {
            final analyticsResponse = await apiService.getAccountAnalytics(accountId);
            if (analyticsResponse['success'] == true) {
              final data = analyticsResponse['data'] ?? {};
              totalFollowersCount += (data['followers'] ?? 0) as int;
              totalEngagementCount += (data['likes_count'] ?? 0) as int;
              totalPostsCount += (data['posts_count'] ?? 0) as int;
            }
          }
        } catch (e) {
          print('⚠️ خطأ في جلب تحليلات الحساب: $e');
        }
      }

      // جلب البوستات من API
      try {
        final postsResponse = await apiService.getPostHistory();
        if (postsResponse['success'] == true) {
          final posts = postsResponse['data'] as List? ?? [];
          totalPosts.value = posts.length;
          publishedPosts.value = posts.where((p) => p['status'] == 'published').length;
          scheduledPosts.value = posts.where((p) => p['status'] == 'scheduled').length;

          // حساب التفاعل من البوستات
          int engagement = 0;
          for (var post in posts) {
            engagement += (post['likes'] ?? 0) as int;
            engagement += (post['comments'] ?? 0) as int;
            engagement += (post['shares'] ?? 0) as int;
          }
          if (engagement > 0) {
            totalEngagement.value = engagement;
          } else {
            totalEngagement.value = totalEngagementCount;
          }
          print('✅ عدد البوستات: ${posts.length}, المنشورة: ${publishedPosts.value}, المجدولة: ${scheduledPosts.value}');
        }
      } catch (e) {
        print('⚠️ خطأ في جلب البوستات: $e');
        // استخدم إحصائيات الحسابات
        totalPosts.value = totalPostsCount;
        totalEngagement.value = totalEngagementCount;
      }

      print('✅ تم جلب الإحصائيات من Backend بنجاح');
    } catch (e) {
      print('⚠️ خطأ في جلب الإحصائيات من Backend: $e');
      // لا نرمي الخطأ - نستخدم القيم الموجودة
    }
  }

  /// جلب الإحصائيات من Firestore (fallback)
  Future<void> _fetchStatsFromFirestore() async {
    try {
      final userId = authService.currentUser.value?.id;
      if (userId == null) return;

      final stats = await firestoreService.getUserDashboardStats(userId);
      totalPosts.value = stats['totalPosts'] ?? 0;
      publishedPosts.value = stats['publishedPosts'] ?? 0;
      scheduledPosts.value = stats['scheduledPosts'] ?? 0;
      connectedAccounts.value = stats['connectedAccounts'] ?? 0;
      totalEngagement.value = stats['totalEngagement'] ?? 0;
    } catch (e) {
      print('⚠️ خطأ في جلب الإحصائيات من Firestore: $e');
    }
  }

  /// تحديث إحصائيات الإعلانات
  void _updateAdsStats() {
    pendingAdsCount.value =
        adsService.pendingAdsCount + adsService.underReviewAdsCount;
    activeAdsCount.value = adsService.activeAdsCount;
  }

  /// تحديث الإحصائيات
  Future<void> refreshStats() async {
    await fetchDashboardStats();
  }

  /// تنسيق الأرقام الكبيرة (1000 -> 1K)
  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  /// بدء الاستماع للتحديثات في الوقت الفعلي
  void startListening() {
    final userId = authService.currentUser.value?.id;
    if (userId == null) {
      print('لا يوجد مستخدم للاستماع لبياناته');
      return;
    }

    isListening.value = true;
    print('🎧 بدء الاستماع للتحديثات في لوحة التحكم...');

    // استخدام Backend API بدلاً من Firestore
    // تحديث كل 30 ثانية
    _startPeriodicRefresh();
  }

  Timer? _refreshTimer;

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isListening.value) {
        _fetchStatsFromBackend();
      }
    });
  }

  /// إيقاف الاستماع للتحديثات
  void stopListening() {
    _postsSubscription?.cancel();
    _accountsSubscription?.cancel();
    _refreshTimer?.cancel();
    isListening.value = false;
    print('🔇 تم إيقاف الاستماع للتحديثات');
  }

  /// إعادة بدء الاستماع
  void restartListening() {
    stopListening();
    startListening();
  }

  /// إضافة نشاط جديد
  Future<void> addActivity(ActivityModel activity) async {
    try {
      if (_activitiesBox == null) {
        await _initActivitiesBox();
      }

      await _activitiesBox!.put(activity.id, activity.toMap());
      await _loadRecentActivities();
    } catch (e) {
      print('خطأ في إضافة النشاط: $e');
    }
  }

  /// إضافة نشاط نشر منشور
  Future<void> addPostPublishedActivity(
    String platform,
    String postTitle,
  ) async {
    final activity = ActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.postPublished,
      title: 'تم نشر منشور جديد',
      subtitle: '$platform - $postTitle',
      timestamp: DateTime.now(),
      icon: Icons.send_rounded,
      color: AppColors.neonCyan,
    );
    await addActivity(activity);
  }

  /// إضافة نشاط جدولة منشور
  Future<void> addPostScheduledActivity(
    String platform,
    DateTime scheduledTime,
  ) async {
    final activity = ActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.postScheduled,
      title: 'تم جدولة منشور',
      subtitle:
          '$platform - ${scheduledTime.day}/${scheduledTime.month} ${scheduledTime.hour}:${scheduledTime.minute}',
      timestamp: DateTime.now(),
      icon: Icons.access_time_rounded,
      color: AppColors.neonPurple,
    );
    await addActivity(activity);
  }

  /// إضافة نشاط ربط حساب
  Future<void> addAccountConnectedActivity(
    String platform,
    String accountName,
  ) async {
    final activity = ActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.accountConnected,
      title: 'تم ربط حساب جديد',
      subtitle: '$platform - $accountName',
      timestamp: DateTime.now(),
      icon: Icons.link_rounded,
      color: AppColors.neonMagenta,
    );
    await addActivity(activity);
  }

  /// إضافة نشاط فشل نشر
  Future<void> addPostFailedActivity(String platform, String reason) async {
    final activity = ActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.postFailed,
      title: 'فشل نشر منشور',
      subtitle: '$platform - $reason',
      timestamp: DateTime.now(),
      icon: Icons.error_outline,
      color: Colors.red,
    );
    await addActivity(activity);
  }
}
