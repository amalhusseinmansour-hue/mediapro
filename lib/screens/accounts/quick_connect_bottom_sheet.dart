import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/social_accounts_service.dart';
import '../../services/subscription_service.dart';
import '../../services/facebook_graph_api_service.dart';

/// Modern Bottom Sheet for Quick Account Connection
class QuickConnectBottomSheet extends StatefulWidget {
  const QuickConnectBottomSheet({super.key});

  @override
  State<QuickConnectBottomSheet> createState() =>
      _QuickConnectBottomSheetState();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickConnectBottomSheet(),
    );
  }
}

class _QuickConnectBottomSheetState extends State<QuickConnectBottomSheet>
    with SingleTickerProviderStateMixin {
  // TODO: Reserve for direct social media integration
  // final DirectSocialMediaService _directService = Get.find<DirectSocialMediaService>();
  final SocialAccountsService _accountsService =
      Get.find<SocialAccountsService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();
  final FacebookGraphApiService _facebookService =
      Get.find<FacebookGraphApiService>();

  late AnimationController _animController;
  final RxString _searchQuery = ''.obs;

  final List<Map<String, dynamic>> _platforms = [
    {
      'id': 'facebook',
      'name': 'Facebook',
      'icon': '📘',
      'color': const Color(0xFF1877F2),
      'description': 'صفحات ومجموعات',
    },
    {
      'id': 'instagram',
      'name': 'Instagram',
      'icon': '📷',
      'color': const Color(0xFFE4405F),
      'description': 'منشورات وقصص',
    },
    {
      'id': 'twitter',
      'name': 'X (Twitter)',
      'icon': '🐦',
      'color': const Color(0xFF1DA1F2),
      'description': 'تغريدات وخيوط',
    },
    {
      'id': 'youtube',
      'name': 'YouTube',
      'icon': '📺',
      'color': const Color(0xFFFF0000),
      'description': 'فيديوهات وقصص',
    },
    {
      'id': 'linkedin',
      'name': 'LinkedIn',
      'icon': '💼',
      'color': const Color(0xFF0A66C2),
      'description': 'منشورات احترافية',
    },
    {
      'id': 'tiktok',
      'name': 'TikTok',
      'icon': '🎵',
      'color': const Color(0xFF000000),
      'description': 'فيديوهات قصيرة',
    },
    {
      'id': 'snapchat',
      'name': 'Snapchat',
      'icon': '👻',
      'color': const Color(0xFFFFFC00),
      'description': 'قصص وعدسات',
    },
    {
      'id': 'pinterest',
      'name': 'Pinterest',
      'icon': '📌',
      'color': const Color(0xFFE60023),
      'description': 'لوحات وصور',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPlatforms {
    if (_searchQuery.value.isEmpty) {
      return _platforms;
    }
    return _platforms.where((platform) {
      final query = _searchQuery.value.toLowerCase();
      return platform['name'].toString().toLowerCase().contains(query) ||
          platform['description'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.darkBg, AppColors.darkCard],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.4),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.link_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => AppColors
                                .cyanPurpleGradient
                                .createShader(bounds),
                            child: const Text(
                              'ربط حساب جديد',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'اختر المنصة للربط السريع',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textLight),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) => _searchQuery.value = value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منصة...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.neonCyan,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Platforms Grid
          Expanded(
            child: Obx(() {
              final platforms = _filteredPlatforms;
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: platforms.length,
                itemBuilder: (context, index) {
                  final platform = platforms[index];
                  return _buildPlatformCard(platform, index);
                },
              );
            }),
          ),

          // Info Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.neonCyan,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اتصال آمن ومشفر - بياناتك محمية 100%',
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(Map<String, dynamic> platform, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Obx(() {
            final isConnected = _accountsService.accounts.any(
              (account) =>
                  account.platform.toLowerCase() ==
                  platform['id'].toLowerCase(),
            );

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    platform['color'].withValues(alpha: 0.15),
                    platform['color'].withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isConnected
                      ? platform['color'].withValues(alpha: 0.6)
                      : platform['color'].withValues(alpha: 0.2),
                  width: isConnected ? 2 : 1,
                ),
                boxShadow: isConnected
                    ? [
                        BoxShadow(
                          color: platform['color'].withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isConnected ? null : () => _connectPlatform(platform),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: platform['color'].withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              platform['icon'],
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Name
                        Text(
                          platform['name'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Description or Status
                        if (isConnected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'متصل',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            platform['description'],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _connectPlatform(Map<String, dynamic> platform) async {
    try {
      // Check subscription limits
      final connectedCount = _accountsService.activeAccountsCount;
      final canAdd = await _subscriptionService.canAddAccount(connectedCount);

      if (!canAdd) {
        Get.snackbar(
          'تحذير',
          'لقد وصلت للحد الأقصى من الحسابات في باقتك الحالية',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.warning, color: Colors.orange),
        );
        return;
      }

      // Close the bottom sheet first for better UX
      Navigator.pop(context);

      final platformId = platform['id'];

      // OAuth Integration - Metricool Style
      if (platformId == 'facebook' || platformId == 'instagram') {
        // Show loading
        Get.dialog(
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: platform['color']),
                  const SizedBox(height: 16),
                  Text(
                    'جاري الاتصال بـ ${platform['name']}...',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );

        // Facebook OAuth Login
        final success = await _facebookService.loginWithFacebook();

        // Close loading
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        if (success) {
          Get.snackbar(
            'نجح الربط! ✅',
            'تم ربط ${platform['name']} بنجاح',
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'فشل الربط',
            _facebookService.lastError.value.isNotEmpty
                ? _facebookService.lastError.value
                : 'فشل الاتصال بـ ${platform['name']}',
            backgroundColor: AppColors.error.withValues(alpha: 0.2),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.error, color: AppColors.error),
          );
        }
      } else {
        // Other platforms - coming soon
        Get.snackbar(
          'قريباً',
          'ربط ${platform['name']} سيكون متاحاً قريباً',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.info, color: Colors.orange),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('❌ Connection error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الربط: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: AppColors.error),
      );
    }
  }
}
