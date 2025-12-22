import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/upload_post_service.dart';
import '../../services/platform_oauth_service.dart';
import '../../services/social_accounts_service.dart';
import '../../services/subscription_service.dart';

class ConnectAccountsScreen extends StatefulWidget {
  const ConnectAccountsScreen({super.key});

  @override
  State<ConnectAccountsScreen> createState() => _ConnectAccountsScreenState();
}

class _ConnectAccountsScreenState extends State<ConnectAccountsScreen> {
  // TODO: Reserve for future post upload integration
  // final UploadPostService _uploadPostService = Get.find<UploadPostService>();
  late final PlatformOAuthService _oauthService;
  final SocialAccountsService _accountsService =
      Get.find<SocialAccountsService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();

  @override
  void initState() {
    super.initState();
    // Initialize platform-specific OAuth service
    try {
      _oauthService = Get.find<PlatformOAuthService>();
    } catch (e) {
      _oauthService = Get.put(PlatformOAuthService());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'ربط الحسابات',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonCyan),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildStepsCard(),
          const SizedBox(height: 32),
          const Text(
            'المنصات المتاحة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildPlatformCards(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient.scale(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: AppColors.neonCyan,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ربط سريع وآمن',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'اربط حساباتك عبر upload-post للنشر التلقائي',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خطوات الربط',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStep('1', 'اضغط على المنصة المطلوبة', Icons.touch_app),
          const SizedBox(height: 12),
          _buildStep('2', 'سجل دخول إلى حسابك', Icons.login),
          const SizedBox(height: 12),
          _buildStep('3', 'امنح الأذونات المطلوبة', Icons.check_circle),
          const SizedBox(height: 12),
          _buildStep('4', 'ابدأ النشر التلقائي!', Icons.rocket_launch),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.cyanPurpleGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: AppColors.neonCyan, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPlatformCards() {
    final platforms = UploadPostService.getSupportedPlatforms();

    return platforms.map((platform) {
      return _buildPlatformCard(platform);
    }).toList();
  }

  Widget _buildPlatformCard(SocialPlatform platform) {
    return Obx(() {
      // Check if platform is connected via SocialAccountsService
      final isConnected = _accountsService.accounts.any(
        (account) =>
            account.platform.toLowerCase() == platform.id.toLowerCase() &&
            account.isActive,
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: isConnected
              ? AppColors.cyanPurpleGradient.scale(0.2)
              : null,
          color: isConnected ? null : AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnected
                ? AppColors.neonCyan
                : AppColors.neonCyan.withValues(alpha: 0.2),
            width: isConnected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isConnected
                  ? AppColors.neonCyan.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isConnected ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isConnected ? null : () => _connectPlatform(platform),
            splashColor: AppColors.neonCyan.withValues(alpha: 0.1),
            highlightColor: AppColors.neonCyan.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Platform Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse('FF${platform.color}', radix: 16),
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        platform.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Platform Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConnected ? 'متصل' : 'غير متصل',
                          style: TextStyle(
                            fontSize: 13,
                            color: isConnected
                                ? AppColors.neonCyan
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildSupportedFormats(platform),
                      ],
                    ),
                  ),
                  // Connect Button
                  if (!isConnected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.add_link_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ربط',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.neonCyan,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSupportedFormats(SocialPlatform platform) {
    final formats = <String>[];
    if (platform.supportsVideo) formats.add('فيديو');
    if (platform.supportsImage) formats.add('صور');
    if (platform.supportsText) formats.add('نص');

    return Wrap(
      spacing: 4,
      children: formats.map((format) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            format,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.neonCyan.withValues(alpha: 0.8),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _connectPlatform(SocialPlatform platform) async {
    try {
      // Check subscription limits
      final connectedCount = _accountsService.activeAccountsCount;
      final canAdd = await _subscriptionService.canAddAccount(connectedCount);

      if (!canAdd) {
        Get.snackbar(
          'تحذير',
          'لقد وصلت للحد الأقصى من الحسابات المسموح بها في باقتك الحالية',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.warning, color: Colors.orange),
        );
        return;
      }

      // Show compact confirmation dialog
      final confirmed = await Get.dialog<bool>(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse('FF${platform.color}', radix: 16),
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          platform.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        platform.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  'سيتم فتح صفحة المصادقة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                // Security Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.neonCyan,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'آمن ومشفر',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(result: false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.darkBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.cyanPurpleGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => Get.back(result: true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'متابعة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed == true) {
        bool success = false;

        // Instagram uses its own dialog for username input, so no loading needed
        if (platform.id.toLowerCase() == 'instagram') {
          success = await _oauthService.connectInstagram();
        } else {
          // Show compact loading for other platforms
          Get.dialog(
            Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppColors.neonCyan,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري الربط...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );

          // Direct OAuth based on platform
          switch (platform.id.toLowerCase()) {
            case 'facebook':
              success = await _oauthService.connectFacebook();
              break;
            case 'x':
              success = await _oauthService.connectTwitter();
              break;
            case 'youtube':
              success = await _oauthService.connectYouTube();
              break;
            case 'linkedin':
              success = await _oauthService.connectLinkedIn();
              break;
            case 'tiktok':
              success = await _oauthService.connectTikTok();
              break;
            case 'threads':
              Get.back(); // Close loading
              Get.snackbar(
                'قريباً',
                'ربط Threads سيكون متاحاً قريباً',
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
              return;
            default:
              Get.back(); // Close loading
              Get.snackbar(
                'خطأ',
                'منصة غير مدعومة',
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
              return;
          }

          Get.back(); // Close loading
        }

        if (success) {
          // Reload accounts
          await _accountsService.loadAccounts();

          Get.snackbar(
            'نجح!',
            'تم ربط حساب ${platform.displayName} بنجاح!',
            backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.check_circle, color: AppColors.neonCyan),
          );
        } else {
          Get.snackbar(
            'فشل',
            'تعذر ربط حساب ${platform.displayName}',
            backgroundColor: Colors.red.withValues(alpha: 0.2),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
      }
    } catch (e) {
      // Close loading if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'خطأ',
        'فشل ربط الحساب: $e',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }
}
