import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/social_account_model.dart';
import '../controllers/dashboard_controller.dart';
import 'auth_service.dart';
import 'phone_auth_service.dart';
import 'api_service.dart';

class SocialAccountsService extends GetxController {
  static const String _accountsBoxName = 'socialAccounts';

  final RxList<SocialAccountModel> accounts = <SocialAccountModel>[].obs;
  final RxBool isLoading = false.obs;

  final ApiService _apiService = ApiService();

  AuthService? get _authService {
    try {
      return Get.find<AuthService>();
    } catch (e) {
      return null;
    }
  }

  PhoneAuthService? get _phoneAuthService {
    try {
      return Get.find<PhoneAuthService>();
    } catch (e) {
      return null;
    }
  }

  String? get _currentUserId {
    // Try AuthService first
    final authUser = _authService?.currentUser.value;
    if (authUser != null) return authUser.id;

    // Try PhoneAuthService
    final phoneUser = _phoneAuthService?.currentFirebaseUser;
    if (phoneUser != null) return phoneUser.phoneNumber ?? phoneUser.uid;

    // No fallback - user must be authenticated
    return null;
  }

  Box<SocialAccountModel>? _accountsBox;

  @override
  void onInit() {
    super.onInit();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    isLoading.value = true;
    try {
      _accountsBox = await Hive.openBox<SocialAccountModel>(_accountsBoxName);
      await loadAccounts();
    } catch (e) {
      print('Error initializing social accounts box: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل جميع الحسابات للمستخدم الحالي
  Future<void> loadAccounts() async {
    try {
      if (_accountsBox == null) {
        print('⚠️ Accounts box not initialized yet');
        return;
      }

      final userId = _currentUserId;

      // محاولة التحميل من Backend أولاً
      try {
        final token = _apiService.authToken;
        if (token != null && token.isNotEmpty) {
          print('🔵 Fetching accounts from backend...');
          final response = await _apiService.getSocialAccounts();

          // Backend returns 'data' not 'accounts'
          final accountsData = response['accounts'] ?? response['data'];
          if (response['success'] == true && accountsData != null) {
            final List<dynamic> backendAccounts =
                accountsData as List<dynamic>;

            // مسح البيانات المحلية القديمة
            await _accountsBox!.clear();

            // حفظ الحسابات الجديدة محلياً
            for (final accountData in backendAccounts) {
              // Handle is_active which can be int (1/0) or bool
              bool isActive = true;
              final isActiveValue = accountData['is_active'];
              if (isActiveValue is bool) {
                isActive = isActiveValue;
              } else if (isActiveValue is int) {
                isActive = isActiveValue == 1;
              }

              final account = SocialAccountModel(
                id: accountData['id'].toString(),
                userId: userId ?? '',
                platform: accountData['platform'] ?? '',
                accountName:
                    accountData['account_name'] ??
                    accountData['display_name'] ??
                    accountData['username'] ??
                    '',
                accountId: accountData['account_id'] ?? accountData['username'] ?? '',
                profileImageUrl: accountData['profile_picture'],
                accessToken: '',
                connectedDate: accountData['created_at'] != null
                    ? DateTime.parse(accountData['created_at'])
                    : DateTime.now(),
                isActive: isActive,
                platformData: {'platform_name': accountData['platform']},
              );

              await _accountsBox!.put(account.id, account);
            }

            print('✅ Loaded ${backendAccounts.length} accounts from backend');
          } else {
            print('⚠️ Invalid response format or no accounts: $response');
          }
        }
      } catch (e) {
        print('⚠️ Failed to load from backend, using local data: $e');
      }

      // التحميل من التخزين المحلي
      final allAccounts = _accountsBox!.values.toList();

      // فلترة الحسابات للمستخدم الحالي فقط
      accounts.value = allAccounts
          .where((account) => account.userId == userId)
          .toList();

      // ترتيب حسب التاريخ (الأحدث أولاً)
      accounts.sort((a, b) => b.connectedDate.compareTo(a.connectedDate));

      // جلب الإحصائيات لجميع الحسابات
      if (accounts.isNotEmpty) {
        fetchAllAccountsStats();
      }
    } catch (e) {
      print('Error loading accounts: $e');
    }
  }

  // إضافة حساب جديد
  Future<SocialAccountModel?> addAccount({
    required String platform,
    required String accountName,
    required String accountId,
    String? profileImageUrl,
    String? accessToken,
    Map<String, dynamic>? platformData,
    AccountStats? stats,
  }) async {
    try {
      print('🔵 Starting addAccount for platform: $platform');

      if (_accountsBox == null) {
        print('❌ Accounts box not initialized yet. Cannot add account.');
        Get.snackbar(
          'خطأ',
          'الرجاء الانتظار حتى يتم تحميل البيانات',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return null;
      }

      final userId = _currentUserId;

      // Check if user is authenticated
      if (userId == null) {
        print('❌ User not authenticated. Cannot add account.');
        Get.snackbar(
          'خطأ',
          'يجب عليك تسجيل الدخول أولاً لإضافة حساب',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return null;
      }

      const uuid = Uuid();

      final account = SocialAccountModel(
        id: uuid.v4(),
        userId: userId,
        platform: platform.toLowerCase(),
        accountName: accountName,
        accountId: accountId,
        profileImageUrl: profileImageUrl,
        accessToken: accessToken,
        connectedDate: DateTime.now(),
        isActive: true,
        platformData: platformData,
        stats: stats,
      );

      await _accountsBox!.put(account.id, account);
      accounts.insert(0, account);

      print('✅ Account added successfully: ${account.id}');

      // إضافة نشاط ربط حساب إلى لوحة التحكم
      try {
        final dashboardController = Get.find<DashboardController>();
        await dashboardController.addAccountConnectedActivity(
          _getPlatformDisplayName(platform),
          accountName,
        );
      } catch (e) {
        print('⚠️ Could not add activity: $e');
      }

      // إرسال للـ Backend (String-Style Direct Connection)
      try {
        final token = _apiService.authToken;
        if (token != null && token.isNotEmpty) {
          print('🔵 Syncing account to backend...');
          final response = await _apiService.addSocialAccount(
            platform: platform.toLowerCase(),
            accountName: accountName,
            accountId: accountId,
            profileImageUrl: profileImageUrl,
            accessToken: accessToken,
            platformData: platformData,
          );

          if (response['success'] == true) {
            print('✅ Account synced to backend successfully');

            // تحديث الـ ID من Backend إذا كان مختلف
            if (response['data'] != null && response['data']['id'] != null) {
              final backendId = response['data']['id'].toString();
              if (backendId != account.id) {
                // حذف الحساب القديم
                await _accountsBox!.delete(account.id);
                accounts.removeWhere((a) => a.id == account.id);

                // إضافة الحساب بـ ID جديد
                account.id = backendId;
                await _accountsBox!.put(account.id, account);
                accounts.insert(0, account);

                print('✅ Account ID updated to backend ID: $backendId');
              }
            }
          }
        } else {
          print('⚠️ No auth token available, account saved locally only');
        }
      } catch (e) {
        print('⚠️ Failed to sync to backend, saved locally: $e');
      }

      return account;
    } catch (e) {
      print('❌ Error adding account: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إضافة الحساب: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // حذف حساب
  Future<bool> deleteAccount(String accountId) async {
    try {
      if (_accountsBox == null) {
        print('⚠️ Accounts box not initialized yet');
        return false;
      }

      // حذف من Backend أولاً
      try {
        final token = _apiService.authToken;
        if (token != null && token.isNotEmpty) {
          print('🔵 Deleting account from backend...');
          final response = await _apiService.deleteSocialAccount(accountId);

          if (response['success'] == true) {
            print('✅ Account deleted from backend successfully');
          }
        }
      } catch (e) {
        print('⚠️ Failed to delete from backend: $e');
        // استمر في الحذف المحلي حتى لو فشل الحذف من Backend
      }

      // حذف محلياً
      await _accountsBox!.delete(accountId);
      accounts.removeWhere((account) => account.id == accountId);

      Get.snackbar(
        'تم بنجاح',
        'تم حذف الحساب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف الحساب',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
  }

  // تحديث حالة الحساب (نشط/غير نشط)
  Future<bool> updateAccountStatus(String accountId, bool isActive) async {
    try {
      if (_accountsBox == null) {
        print('⚠️ Accounts box not initialized yet');
        return false;
      }

      final account = _accountsBox!.get(accountId);
      if (account == null) return false;

      // تحديث في Backend أولاً
      try {
        final token = _apiService.authToken;
        if (token != null && token.isNotEmpty) {
          print('🔵 Updating account status in backend...');
          await _apiService.updateSocialAccount(accountId, isActive: isActive);
          print('✅ Account status updated in backend');
        }
      } catch (e) {
        print('⚠️ Failed to update in backend: $e');
      }

      // تحديث محلياً
      account.isActive = isActive;
      await _accountsBox!.put(accountId, account);

      // تحديث القائمة المحلية
      final index = accounts.indexWhere((a) => a.id == accountId);
      if (index != -1) {
        accounts[index] = account;
        accounts.refresh();
      }

      return true;
    } catch (e) {
      print('Error updating account status: $e');
      return false;
    }
  }

  // تحديث إحصائيات الحساب
  Future<bool> updateAccountStats(String accountId, AccountStats stats) async {
    try {
      if (_accountsBox == null) {
        print('⚠️ Accounts box not initialized yet');
        return false;
      }

      final account = _accountsBox!.get(accountId);
      if (account == null) return false;

      account.stats = stats;
      await _accountsBox!.put(accountId, account);

      // تحديث القائمة المحلية
      final index = accounts.indexWhere((a) => a.id == accountId);
      if (index != -1) {
        accounts[index] = account;
        accounts.refresh();
      }

      return true;
    } catch (e) {
      print('Error updating account stats: $e');
      return false;
    }
  }

  // الحصول على حسابات منصة معينة
  List<SocialAccountModel> getAccountsByPlatform(String platform) {
    return accounts
        .where(
          (account) =>
              account.platform.toLowerCase() == platform.toLowerCase() &&
              account.isActive,
        )
        .toList();
  }

  // الحصول على عدد الحسابات النشطة
  int get activeAccountsCount => accounts.where((a) => a.isActive).length;

  // الحصول على عدد الحسابات غير النشطة
  int get inactiveAccountsCount => accounts.where((a) => !a.isActive).length;

  // التحقق من وجود حساب لمنصة معينة
  bool hasPlatformAccount(String platform) {
    return accounts.any(
      (account) =>
          account.platform.toLowerCase() == platform.toLowerCase() &&
          account.isActive,
    );
  }

  // الحصول على حساب بواسطة المنصة (أول حساب نشط)
  SocialAccountModel? getAccountByPlatform(String platform) {
    try {
      return accounts.firstWhere(
        (account) =>
            account.platform.toLowerCase() == platform.toLowerCase() &&
            account.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  // إضافة حسابات تجريبية (Demo Accounts)
  Future<void> addDemoAccounts() async {
    try {
      final userId = _currentUserId;

      if (userId == null) {
        print('❌ User not authenticated. Cannot add demo accounts.');
        return;
      }

      // التحقق من عدم وجود حسابات تجريبية مسبقاً
      if (accounts.length >= 3) {
        print('ℹ️ Demo accounts already exist or user has accounts');
        return;
      }

      print('🔵 Adding demo social media accounts...');

      // Facebook Demo Account
      await addAccount(
        platform: 'facebook',
        accountName: 'صفحتي التجريبية',
        accountId: 'demo_fb_123456',
        profileImageUrl:
            'https://ui-avatars.com/api/?name=Facebook+Demo&background=1877f2&color=fff',
        platformData: {
          'followers': 15420,
          'posts': 234,
          'engagement_rate': 4.8,
        },
      );

      // Instagram Demo Account
      await addAccount(
        platform: 'instagram',
        accountName: '@demo_account',
        accountId: 'demo_ig_789012',
        profileImageUrl:
            'https://ui-avatars.com/api/?name=Instagram+Demo&background=e4405f&color=fff',
        platformData: {'followers': 8750, 'posts': 156, 'engagement_rate': 6.2},
      );

      // Twitter (X) Demo Account
      await addAccount(
        platform: 'twitter',
        accountName: '@demo_user',
        accountId: 'demo_tw_345678',
        profileImageUrl:
            'https://ui-avatars.com/api/?name=Twitter+Demo&background=1da1f2&color=fff',
        platformData: {
          'followers': 3250,
          'tweets': 512,
          'engagement_rate': 3.5,
        },
      );

      print('✅ Demo accounts added successfully!');

      Get.snackbar(
        'تم بنجاح',
        'تم إضافة حسابات تجريبية للاختبار',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Error adding demo accounts: $e');
    }
  }

  // حذف جميع الحسابات التجريبية
  Future<void> removeDemoAccounts() async {
    try {
      if (_accountsBox == null) {
        print('⚠️ Accounts box not initialized yet');
        return;
      }

      // حذف الحسابات التجريبية
      final demoAccounts = accounts
          .where((account) => account.accountId.startsWith('demo_'))
          .toList();

      for (final account in demoAccounts) {
        await deleteAccount(account.id);
      }

      print('✅ Demo accounts removed successfully!');
    } catch (e) {
      print('❌ Error removing demo accounts: $e');
    }
  }

  // الحصول على اسم المنصة للعرض
  String _getPlatformDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'Facebook';
      case 'instagram':
        return 'Instagram';
      case 'twitter':
        return 'Twitter';
      case 'linkedin':
        return 'LinkedIn';
      case 'youtube':
        return 'YouTube';
      case 'tiktok':
        return 'TikTok';
      case 'snapchat':
        return 'Snapchat';
      default:
        return platform;
    }
  }

  // ========== Analytics Fetching ==========

  /// جلب الإحصائيات لجميع الحسابات المتصلة
  Future<void> fetchAllAccountsStats() async {
    try {
      print('📊 Fetching stats for all accounts...');

      for (final account in accounts) {
        await fetchAccountStats(account);
      }

      print('✅ All account stats fetched');
    } catch (e) {
      print('❌ Error fetching account stats: $e');
    }
  }

  /// جلب الإحصائيات لحساب معين
  Future<void> fetchAccountStats(SocialAccountModel account) async {
    try {
      print('📊 Fetching stats for ${account.platform}: ${account.accountName}');

      // محاولة جلب الإحصائيات من Backend
      final token = _apiService.authToken;
      if (token != null && token.isNotEmpty) {
        try {
          final response = await _apiService.getAccountAnalytics(account.id);

          if (response['success'] == true && response['data'] != null) {
            final data = response['data'];
            final stats = AccountStats(
              followers: data['followers'] ?? 0,
              postsCount: data['posts_count'] ?? data['postsCount'] ?? 0,
              engagementRate: (data['engagement_rate'] ?? data['engagementRate'] ?? 0.0).toDouble(),
              lastUpdated: DateTime.now(),
            );

            await updateAccountStats(account.id, stats);
            print('✅ Stats updated from backend for ${account.accountName}');
            return;
          }
        } catch (e) {
          print('⚠️ Backend stats fetch failed: $e');
        }
      }

      // إذا فشل Backend، استخدم بيانات افتراضية بناءً على المنصة
      final defaultStats = _getDefaultStatsForPlatform(account.platform);
      await updateAccountStats(account.id, defaultStats);
      print('ℹ️ Using default stats for ${account.accountName}');
    } catch (e) {
      print('❌ Error fetching stats for ${account.accountName}: $e');
    }
  }

  /// الحصول على إحصائيات افتراضية للمنصة
  AccountStats _getDefaultStatsForPlatform(String platform) {
    // إرجاع إحصائيات افتراضية معقولة لكل منصة
    return AccountStats(
      followers: 0,
      postsCount: 0,
      engagementRate: 0.0,
      lastUpdated: DateTime.now(),
    );
  }
}
