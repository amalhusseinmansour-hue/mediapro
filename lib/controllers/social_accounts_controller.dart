import 'package:get/get.dart';
import '../models/social_account_model.dart';
import '../services/social_accounts_service.dart';
import '../services/oauth_service.dart';

/// كونترولر إدارة حسابات التواصل الاجتماعي
class SocialAccountsController extends GetxController {
  // استخدام lazy loading لتجنب الأخطاء
  SocialAccountsService? get _accountsService {
    try {
      return Get.find<SocialAccountsService>();
    } catch (e) {
      print('⚠️ SocialAccountsService not available: $e');
      return null;
    }
  }

  OAuthService? get _oauthService {
    try {
      return Get.find<OAuthService>();
    } catch (e) {
      print('⚠️ OAuthService not available: $e');
      return null;
    }
  }

  // الحالات المراقبة
  final RxList<SocialAccountModel> connectedAccounts =
      <SocialAccountModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnecting = false.obs;
  final RxString selectedPlatform = ''.obs;

  // إحصائيات الحسابات
  final RxInt totalConnectedAccounts = 0.obs;
  final RxList<String> connectedPlatforms = <String>[].obs;
  final RxMap<String, List<SocialAccountModel>> accountsByPlatform =
      <String, List<SocialAccountModel>>{}.obs;

  // الأخطاء والرسائل
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadConnectedAccounts();
    _setupListeners();
  }

  void _setupListeners() {
    // الاستماع لتغييرات الحسابات
    _accountsService?.accounts.listen((accounts) {
      connectedAccounts.value = accounts;
      _updateStatistics();
    });
  }

  /// تحميل الحسابات المتصلة
  Future<void> loadConnectedAccounts() async {
    isLoading.value = true;
    try {
      if (_accountsService == null) {
        errorMessage.value = 'خدمة الحسابات غير متوفرة';
        print('❌ SocialAccountsService is not registered in GetX');
        return;
      }
      await _accountsService!.loadAccounts();
      connectedAccounts.value = _accountsService!.accounts;
      _updateStatistics();
    } catch (e) {
      errorMessage.value = 'فشل تحميل الحسابات: $e';
      print('❌ Error loading accounts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث إحصائيات الحسابات
  void _updateStatistics() {
    totalConnectedAccounts.value = connectedAccounts.length;

    // تجميع الحسابات حسب المنصة
    final platformMap = <String, List<SocialAccountModel>>{};
    for (final account in connectedAccounts) {
      if (!platformMap.containsKey(account.platform)) {
        platformMap[account.platform] = [];
      }
      platformMap[account.platform]!.add(account);
    }

    accountsByPlatform.value = platformMap;
    connectedPlatforms.value = platformMap.keys.toList();
  }

  /// ربط حساب جديد
  Future<void> connectAccount(String platform) async {
    isConnecting.value = true;
    selectedPlatform.value = platform;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      if (_oauthService == null) {
        errorMessage.value = 'خدمة OAuth غير متوفرة';
        print('❌ OAuthService is not registered in GetX');
        return;
      }

      bool success = false;

      switch (platform.toLowerCase()) {
        case 'facebook':
          success = await _oauthService!.connectFacebook();
          break;
        case 'twitter':
        case 'x':
          success = await _oauthService!.connectTwitter();
          break;
        case 'instagram':
          success = await _oauthService!.connectInstagram();
          break;
        case 'linkedin':
          success = await _oauthService!.connectLinkedIn();
          break;
        case 'youtube':
          success = await _oauthService!.connectYouTube();
          break;
        case 'tiktok':
          success = await _oauthService!.connectTikTok();
          break;
        default:
          errorMessage.value = 'منصة غير مدعومة';
      }

      if (success) {
        successMessage.value = 'تم ربط الحساب بنجاح!';
        await Future.delayed(const Duration(milliseconds: 500));
        await loadConnectedAccounts();
      } else {
        if (errorMessage.isEmpty) {
          errorMessage.value = 'فشل الربط';
        }
      }
    } catch (e) {
      errorMessage.value = 'خطأ: ${e.toString()}';
      print('❌ Error connecting account: $e');
    } finally {
      isConnecting.value = false;
      selectedPlatform.value = '';
    }
  }

  /// قطع الحساب
  Future<void> disconnectAccount(String accountId) async {
    isLoading.value = true;
    try {
      if (_accountsService == null) {
        errorMessage.value = 'خدمة الحسابات غير متوفرة';
        print('❌ SocialAccountsService is not registered in GetX');
        return;
      }
      final success = await _accountsService!.deleteAccount(accountId);
      if (success) {
        successMessage.value = 'تم قطع الحساب بنجاح';
        await loadConnectedAccounts();
      } else {
        errorMessage.value = 'فشل قطع الحساب';
      }
    } catch (e) {
      errorMessage.value = 'خطأ: ${e.toString()}';
      print('❌ Error disconnecting account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث بيانات الحساب
  Future<void> refreshAccount(String accountId) async {
    isLoading.value = true;
    try {
      if (_accountsService == null) {
        errorMessage.value = 'خدمة الحسابات غير متوفرة';
        print('❌ SocialAccountsService is not registered in GetX');
        return;
      }
      // إعادة تحميل جميع الحسابات
      await loadConnectedAccounts();
      successMessage.value = 'تم تحديث البيانات بنجاح';
    } catch (e) {
      errorMessage.value = 'فشل التحديث: ${e.toString()}';
      print('❌ Error refreshing account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على الحسابات المتصلة لمنصة معينة
  List<SocialAccountModel> getAccountsForPlatform(String platform) {
    return accountsByPlatform[platform] ?? [];
  }

  /// التحقق من وجود منصة متصلة
  bool isPlatformConnected(String platform) {
    return connectedPlatforms.contains(platform);
  }

  /// الحصول على عدد الحسابات المتصلة لمنصة معينة
  int getAccountCountForPlatform(String platform) {
    return accountsByPlatform[platform]?.length ?? 0;
  }
}
