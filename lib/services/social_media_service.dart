import 'package:get/get.dart';
import '../models/social_account_model.dart';
import '../models/scheduled_post_model.dart';
import 'api_service.dart';

/// Service for managing social media operations via Laravel backend + Ayrshare
class SocialMediaService extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable lists
  final RxList<SocialAccountModel> socialAccounts = <SocialAccountModel>[].obs;
  final RxList<ScheduledPost> scheduledPosts = <ScheduledPost>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load social accounts on init
    loadSocialAccounts();
  }

  // ========== Social Accounts Management ==========

  /// Load all connected social accounts from backend
  Future<void> loadSocialAccounts({bool showError = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.getSocialAccounts();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> accountsData = response['data'];
        socialAccounts.value = accountsData
            .map((json) => SocialAccountModel.fromJson(json))
            .toList();

        print('✅ Loaded ${socialAccounts.length} social accounts');
      }
    } catch (e) {
      errorMessage.value = 'فشل تحميل الحسابات المتصلة';
      print('❌ Error loading social accounts: $e');

      // Only show error popup if explicitly requested (e.g., manual refresh)
      if (showError) {
        Get.snackbar(
          'خطأ',
          'فشل تحميل الحسابات المتصلة. تأكد من إعداد الباك إند',
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a social account
  Future<bool> deleteSocialAccount(String accountId) async {
    try {
      isLoading.value = true;

      final response = await _apiService.deleteSocialAccount(accountId);

      if (response['success'] == true) {
        // Remove from local list
        socialAccounts.removeWhere((account) => account.id == accountId);

        Get.snackbar(
          'نجح',
          'تم حذف الحساب بنجاح',
          snackPosition: SnackPosition.TOP,
        );

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error deleting social account: $e');

      Get.snackbar(
        'خطأ',
        'فشل حذف الحساب',
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get accounts for a specific platform
  List<SocialAccountModel> getAccountsByPlatform(String platform) {
    return socialAccounts
        .where((account) => account.platform.toLowerCase() == platform.toLowerCase())
        .toList();
  }

  /// Check if a platform is connected
  bool isPlatformConnected(String platform) {
    return socialAccounts.any(
      (account) => account.platform.toLowerCase() == platform.toLowerCase() && account.isActive,
    );
  }

  // ========== Post Creation ==========

  /// Create a social media post (immediate or scheduled)
  Future<bool> createPost({
    required String content,
    required List<String> platforms,
    List<String>? mediaUrls,
    DateTime? scheduledAt,
  }) async {
    try {
      isLoading.value = true;

      // Validate platforms are connected
      for (final platform in platforms) {
        if (!isPlatformConnected(platform)) {
          Get.snackbar(
            'تنبيه',
            'منصة $platform غير متصلة',
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      }

      final response = await _apiService.createSocialPost(
        content: content,
        platforms: platforms,
        mediaUrls: mediaUrls,
        scheduledAt: scheduledAt,
      );

      if (response['success'] == true) {
        // If scheduled, add to scheduled posts list
        if (scheduledAt != null && response['scheduled_post'] != null) {
          final scheduledPost = ScheduledPost.fromJson(response['scheduled_post']);
          scheduledPosts.add(scheduledPost);
        }

        Get.snackbar(
          'نجح',
          scheduledAt != null
              ? 'تم جدولة المنشور بنجاح'
              : 'تم نشر المحتوى بنجاح',
          snackPosition: SnackPosition.TOP,
        );

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error creating post: $e');

      Get.snackbar(
        'خطأ',
        'فشل نشر المحتوى',
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Scheduled Posts Management ==========

  /// Load all scheduled posts
  Future<void> loadScheduledPosts() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getScheduledPosts();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> postsData = response['data'];
        scheduledPosts.value = postsData
            .map((json) => ScheduledPost.fromJson(json))
            .toList();

        print('✅ Loaded ${scheduledPosts.length} scheduled posts');
      }
    } catch (e) {
      print('❌ Error loading scheduled posts: $e');

      Get.snackbar(
        'خطأ',
        'فشل تحميل المنشورات المجدولة',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel a scheduled post
  Future<bool> cancelScheduledPost(String postId) async {
    try {
      isLoading.value = true;

      final response = await _apiService.cancelScheduledPost(postId);

      if (response['success'] == true) {
        // Remove from local list
        scheduledPosts.removeWhere((post) => post.id == postId);

        Get.snackbar(
          'نجح',
          'تم إلغاء المنشور المجدول',
          snackPosition: SnackPosition.TOP,
        );

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error canceling scheduled post: $e');

      Get.snackbar(
        'خطأ',
        'فشل إلغاء المنشور المجدول',
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== AI Content Generation ==========

  /// Generate AI content for social media
  Future<String?> generateAIContent({
    required String topic,
    required String platform,
    String tone = 'professional',
    int? maxLength,
  }) async {
    try {
      isLoading.value = true;

      final response = await _apiService.generateAIContent(
        topic: topic,
        platform: platform,
        tone: tone,
        maxLength: maxLength,
      );

      if (response['success'] == true && response['content'] != null) {
        print('✅ AI content generated successfully');
        return response['content'] as String;
      }

      return null;
    } catch (e) {
      print('❌ Error generating AI content: $e');

      Get.snackbar(
        'خطأ',
        'فشل توليد المحتوى بالذكاء الاصطناعي',
        snackPosition: SnackPosition.TOP,
      );

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Helper Methods ==========

  /// Get platform icon
  String getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return '📘';
      case 'instagram':
        return '📷';
      case 'twitter':
      case 'x':
        return '🐦';
      case 'linkedin':
        return '💼';
      case 'youtube':
        return '📹';
      case 'tiktok':
        return '🎵';
      default:
        return '📱';
    }
  }

  /// Get platform display name
  String getPlatformDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'فيسبوك';
      case 'instagram':
        return 'إنستغرام';
      case 'twitter':
      case 'x':
        return 'تويتر';
      case 'linkedin':
        return 'لينكد إن';
      case 'youtube':
        return 'يوتيوب';
      case 'tiktok':
        return 'تيك توك';
      default:
        return platform;
    }
  }

  /// Get available platforms (all supported platforms)
  List<String> get availablePlatforms => [
        'facebook',
        'instagram',
        'twitter',
        'linkedin',
        'youtube',
        'tiktok',
      ];

  /// Get connected platforms only
  List<String> get connectedPlatforms {
    return socialAccounts
        .where((account) => account.isActive)
        .map((account) => account.platform)
        .toSet()
        .toList();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadSocialAccounts(),
      loadScheduledPosts(),
    ]);
  }
}
