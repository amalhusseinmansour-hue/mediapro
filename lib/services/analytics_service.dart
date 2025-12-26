import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../core/config/api_config.dart';
import '../models/usage_stats.dart';
import '../models/overview_stats.dart';
import '../models/analytics_filter.dart';
import 'package:hive/hive.dart';
import '../models/analytics_history_model.dart';
import 'social_accounts_service.dart';
import 'auth_service.dart';
import 'api_service.dart';

class AnalyticsService extends GetxService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.backendBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final AuthService _authService = Get.find<AuthService>();

  ApiService? get _apiService {
    try {
      return Get.find<ApiService>();
    } catch (e) {
      return null;
    }
  }

  // Observable data
  final Rx<UsageStats?> usageStats = Rx<UsageStats?>(null);
  final Rx<OverviewStats?> overviewStats = Rx<OverviewStats?>(null);
  final RxBool isLoadingUsage = false.obs;
  final RxBool isLoadingOverview = false.obs;
  final RxString error = ''.obs;

  // Posts and Platforms Analytics
  final RxMap<String, dynamic> postsAnalytics = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> platformsAnalytics = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingPostsAnalytics = false.obs;
  final RxBool isLoadingPlatformsAnalytics = false.obs;

  // Filter state
  final Rx<AnalyticsFilter> activeFilter = AnalyticsFilter().obs;
  final RxMap<String, dynamic> filteredData = <String, dynamic>{}.obs;

  // History Box
  late Box<AnalyticsHistoryModel> _historyBox;
  final RxList<AnalyticsHistoryModel> historyData = <AnalyticsHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupInterceptors();
    _initHistoryBox();
  }

  Future<void> _initHistoryBox() async {
    try {
      _historyBox = await Hive.openBox<AnalyticsHistoryModel>('analytics_history');
      _loadHistory();
    } catch (e) {
      print('❌ Failed to open analytics history box: $e');
    }
  }

  void _loadHistory() {
    if (_historyBox.isOpen) {
      final List<AnalyticsHistoryModel> list = _historyBox.values.toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      historyData.assignAll(list);
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token from ApiService
          final token = _apiService?.authToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('📊 Analytics request with token: ${token.substring(0, 20)}...');
          } else {
            print('⚠️ Analytics request without token');
          }
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) {
          print('❌ Analytics API Error: ${error.message}');
          print('❌ Status Code: ${error.response?.statusCode}');
          print('❌ Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  /// جلب إحصائيات الاستخدام
  Future<void> fetchUsageStats() async {
    try {
      isLoadingUsage.value = true;
      error.value = '';

      print('📊 Fetching usage stats...');

      final response = await _dio.get('/api/analytics/usage');

      print('📊 Usage Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          usageStats.value = UsageStats.fromJson(data['usage']);
          print('✅ Usage stats loaded successfully');
        } else {
          throw Exception(data['message'] ?? 'فشل في تحميل الإحصائيات');
        }
      } else {
        throw Exception('خطأ في الاتصال بالخادم');
      }
    } on DioException catch (e) {
      print('❌ Usage stats error: ${e.message}');
      error.value = e.response?.data['message'] ?? 'فشل في تحميل الإحصائيات';
      usageStats.value = null;
    } catch (e) {
      print('❌ Usage stats error: $e');
      error.value = 'حدث خطأ غير متوقع';
      usageStats.value = null;
    } finally {
      isLoadingUsage.value = false;
    }
  }

  /// جلب النظرة العامة
  Future<void> fetchOverviewStats() async {
    try {
      isLoadingOverview.value = true;
      error.value = '';

      print('📊 Fetching overview stats...');

      final response = await _dio.get('/api/analytics/overview');

      print('📊 Overview Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          overviewStats.value = OverviewStats.fromJson(data['overview']);
          print('✅ Overview stats loaded successfully');
        } else {
          throw Exception(data['message'] ?? 'فشل في تحميل النظرة العامة');
        }
      } else {
        throw Exception('خطأ في الاتصال بالخادم');
      }
    } on DioException catch (e) {
      print('❌ Overview stats error: ${e.message}');
      error.value = e.response?.data['message'] ?? 'فشل في تحميل النظرة العامة';
      overviewStats.value = null;
    } catch (e) {
      print('❌ Overview stats error: $e');
      error.value = 'حدث خطأ غير متوقع';
      overviewStats.value = null;
    } finally {
      isLoadingOverview.value = false;
    }
  }

  /// جلب إحصائيات الاستخدام مع الفلاتر
  Future<void> fetchUsageStatsFiltered(AnalyticsFilter filter) async {
    try {
      isLoadingUsage.value = true;
      error.value = '';
      activeFilter.value = filter;

      print('📊 Fetching filtered usage stats with: ${filter.toJson()}');

      final params = filter.toJson();
      final response = await _dio.get(
        '/api/analytics/usage',
        queryParameters: params,
      );

      print('📊 Filtered Usage Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          usageStats.value = UsageStats.fromJson(data['usage']);
          filteredData.value = data['usage'] ?? {};
          print('✅ Filtered usage stats loaded successfully');
        } else {
          throw Exception(
            data['message'] ?? 'فشل في تحميل الإحصائيات المفلترة',
          );
        }
      } else {
        throw Exception('خطأ في الاتصال بالخادم');
      }
    } on DioException catch (e) {
      print('❌ Filtered usage stats error: ${e.message}');
      error.value =
          e.response?.data['message'] ?? 'فشل في تحميل الإحصائيات المفلترة';
      usageStats.value = null;
    } catch (e) {
      print('❌ Filtered usage stats error: $e');
      error.value = 'حدث خطأ غير متوقع';
      usageStats.value = null;
    } finally {
      isLoadingUsage.value = false;
    }
  }

  /// جلب النظرة العامة مع الفلاتر
  Future<void> fetchOverviewStatsFiltered(AnalyticsFilter filter) async {
    try {
      isLoadingOverview.value = true;
      error.value = '';
      activeFilter.value = filter;

      print('📊 Fetching filtered overview stats with: ${filter.toJson()}');

      final params = filter.toJson();
      final response = await _dio.get(
        '/api/analytics/overview',
        queryParameters: params,
      );

      print('📊 Filtered Overview Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          overviewStats.value = OverviewStats.fromJson(data['overview']);
          filteredData.value = data['overview'] ?? {};
          print('✅ Filtered overview stats loaded successfully');
        } else {
          throw Exception(
            data['message'] ?? 'فشل في تحميل النظرة العامة المفلترة',
          );
        }
      } else {
        throw Exception('خطأ في الاتصال بالخادم');
      }
    } on DioException catch (e) {
      print('❌ Filtered overview stats error: ${e.message}');
      error.value =
          e.response?.data['message'] ?? 'فشل في تحميل النظرة العامة المفلترة';
      overviewStats.value = null;
    } catch (e) {
      print('❌ Filtered overview stats error: $e');
      error.value = 'حدث خطأ غير متوقع';
      overviewStats.value = null;
    } finally {
      isLoadingOverview.value = false;
    }
  }

  /// تطبيق الفلاتر وتحديث جميع الإحصائيات
  Future<void> applyFilters(AnalyticsFilter filter) async {
    await Future.wait([
      fetchUsageStatsFiltered(filter),
      fetchOverviewStatsFiltered(filter),
    ]);
  }

  /// إزالة جميع الفلاتر والعودة للبيانات الكاملة
  Future<void> clearFilters() async {
    activeFilter.value = AnalyticsFilter();
    await refreshAll();
  }

  /// التحقق من الحد قبل إجراء عملية
  Future<Map<String, dynamic>> checkLimit(String type) async {
    try {
      print('🔍 Checking limit for: $type');

      final response = await _dio.get('/api/analytics/check-limit/$type');

      print('🔍 Limit Check Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ Limit check: ${data['can_proceed']}');
        return data;
      } else {
        return {
          'success': false,
          'can_proceed': false,
          'message': 'خطأ في التحقق من الحد',
        };
      }
    } on DioException catch (e) {
      print('❌ Limit check error: ${e.message}');
      return {
        'success': false,
        'can_proceed': false,
        'message': e.response?.data['message'] ?? 'فشل في التحقق من الحد',
      };
    } catch (e) {
      print('❌ Limit check error: $e');
      return {
        'success': false,
        'can_proceed': false,
        'message': 'حدث خطأ غير متوقع',
      };
    }
  }

  /// التحقق من إمكانية إنشاء منشور
  Future<bool> canCreatePost() async {
    final result = await checkLimit('post');
    return result['can_proceed'] ?? false;
  }

  /// التحقق من إمكانية استخدام AI
  Future<bool> canUseAI() async {
    final result = await checkLimit('ai');
    return result['can_proceed'] ?? false;
  }

  /// التحقق من إمكانية ربط حساب
  Future<bool> canConnectAccount() async {
    final result = await checkLimit('account');
    return result['can_proceed'] ?? false;
  }

  /// عرض رسالة عند الوصول للحد
  void showLimitReachedDialog(String type) {
    String title = '';
    String message = '';

    switch (type) {
      case 'post':
        title = '⚠️ وصلت للحد الأقصى من المنشورات';
        message =
            'لقد استنفدت حصتك الشهرية من المنشورات. قم بالترقية للباقة الأعمال للحصول على 500 منشور شهرياً!';
        break;

      case 'ai':
        title = '⚠️ وصلت للحد الأقصى من طلبات AI';
        message =
            'لقد استنفدت حصتك الشهرية من طلبات الذكاء الاصطناعي. قم بالترقية للباقة الأعمال للحصول على AI غير محدود!';
        break;

      case 'account':
        title = '⚠️ وصلت للحد الأقصى من الحسابات';
        message =
            'لقد وصلت للحد الأقصى من الحسابات المربوطة. قم بالترقية للباقة الأعمال لربط 15 حساب!';
        break;
    }

    Get.snackbar(
      title,
      message,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E1E2E),
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          Get.toNamed('/subscription');
        },
        child: const Text(
          'ترقية الآن',
          style: TextStyle(
            color: Color(0xFF00D9FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// جلب تحليلات المنشورات
  Future<void> fetchPostsAnalytics({
    String period = 'week',
  }) async {
    try {
      isLoadingPostsAnalytics.value = true;
      print('📊 Fetching posts analytics for period: $period');

      final response = await _dio.get(
        '/api/analytics/posts',
        queryParameters: {'period': period},
      );

      print('📊 Posts Analytics Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          postsAnalytics.value = data['analytics'] ?? {};
          print('✅ Posts analytics loaded successfully');
        } else {
          throw Exception(data['message'] ?? 'فشل في تحميل تحليلات المنشورات');
        }
      } else {
        throw Exception('خطأ في الاتصال بالخادم');
      }
    } on DioException catch (e) {
      print('❌ Posts analytics error: ${e.message}');
      postsAnalytics.value = {};
    } catch (e) {
      print('❌ Posts analytics error: $e');
      postsAnalytics.value = {};
    } finally {
      isLoadingPostsAnalytics.value = false;
    }
  }

  /// جلب تحليلات المنصات
  Future<void> fetchPlatformsAnalytics() async {
    try {
      isLoadingPlatformsAnalytics.value = true;
      print('📊 Fetching platforms analytics...');

      final response = await _dio.get('/api/analytics/platforms');

      print('📊 Platforms Analytics Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          final platforms = data['platforms'] as List<dynamic>? ?? [];
          platformsAnalytics.value = platforms
              .map((p) => p as Map<String, dynamic>)
              .toList();
          print('✅ Platforms analytics loaded successfully');
        } else {
          throw Exception(data['message'] ?? 'فشل في تحميل تحليلات المنصات');
        }
      } else {
        throw Exception('خطأ في الاتصال بالخادم');
      }
    } on DioException catch (e) {
      print('❌ Platforms analytics error: ${e.message}');
      platformsAnalytics.value = [];
    } catch (e) {
      print('❌ Platforms analytics error: $e');
      platformsAnalytics.value = [];
    } finally {
      isLoadingPlatformsAnalytics.value = false;
    }
  }

  /// تحديث كل الإحصائيات
  Future<void> refreshAll() async {
    await Future.wait([
      fetchUsageStats(),
      fetchOverviewStats(),
      fetchPostsAnalytics(),
      fetchPlatformsAnalytics(),
    ]);

    // Record daily snapshot after refreshing
    await recordDailySnapshot();
  }

  /// تسجيل لقطة يومية للإحصائيات
  Future<void> recordDailySnapshot() async {
    try {
      if (!_historyBox.isOpen) return;

      final socialAccountsService = Get.find<SocialAccountsService>();
      final accounts = socialAccountsService.accounts;

      if (accounts.isEmpty) return;

      // Calculate totals
      int totalFollowers = 0;
      int totalPosts = 0;
      double totalEngagement = 0;
      final Map<String, int> followersByPlatform = {};

      for (var account in accounts) {
        final f = account.stats?.followers ?? 0;
        final p = account.stats?.postsCount ?? 0;
        final e = account.stats?.engagementRate ?? 0.0;
        final platform = account.platform.toString().toLowerCase() ?? 'other';

        final followers = f;
        final posts = p;

        totalFollowers += followers;
        totalPosts += posts;
        totalEngagement += e;

        followersByPlatform[platform] = (followersByPlatform[platform] ?? 0) + followers;
      }

      final avgEngagement = accounts.isNotEmpty ? totalEngagement / accounts.length : 0.0;
      final today = DateTime.now();
      final dateKey = DateTime(today.year, today.month, today.day); // Normalize to midnight

      // Check if we already have a snapshot for today
      final existingIndex = historyData.indexWhere((h) => 
        h.date.year == today.year && 
        h.date.month == today.month && 
        h.date.day == today.day
      );

      final snapshot = AnalyticsHistoryModel(
        date: dateKey,
        totalFollowers: totalFollowers,
        totalPosts: totalPosts,
        avgEngagementRate: avgEngagement,
        followersByPlatform: followersByPlatform,
      );

      if (existingIndex >= 0) {
        // Update today's snapshot
        final key = historyData[existingIndex].key;
        await _historyBox.put(key, snapshot);
        historyData[existingIndex] = snapshot;
      } else {
        // Add new snapshot
        await _historyBox.add(snapshot);
        historyData.add(snapshot);
      }
      
      // Sort history
      historyData.sort((a, b) => a.date.compareTo(b.date));
      
      print('✅ Daily analytics snapshot recorded: $totalFollowers followers');

    } catch (e) {
      print('❌ Error recording daily snapshot: $e');
    }
  }

  /// الحصول على بيانات النمو للفترة المحددة
  List<AnalyticsHistoryModel> getGrowthHistory({int days = 7}) {
    if (historyData.isEmpty) return [];
    
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    return historyData.where((h) => h.date.isAfter(startDate)).toList();
  }

  /// مسح البيانات
  void clear() {
    usageStats.value = null;
    overviewStats.value = null;
    postsAnalytics.value = {};
    platformsAnalytics.value = [];
    error.value = '';
  }
}
