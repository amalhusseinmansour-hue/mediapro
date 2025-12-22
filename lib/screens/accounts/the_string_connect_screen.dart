import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/social_accounts_service.dart';
import '../../services/facebook_graph_api_service.dart';

/// The String Style Account Connection Screen
/// تصميم مستوحى من https://dashboard.thestring.net
class TheStringConnectScreen extends StatefulWidget {
  const TheStringConnectScreen({super.key});

  @override
  State<TheStringConnectScreen> createState() => _TheStringConnectScreenState();
}

class _TheStringConnectScreenState extends State<TheStringConnectScreen>
    with TickerProviderStateMixin {
  // TODO: Reserve for String OAuth integration
  // final OAuthService _oauthService = Get.find<OAuthService>();
  final SocialAccountsService _accountsService =
      Get.find<SocialAccountsService>();
  final FacebookGraphApiService _facebookService =
      Get.find<FacebookGraphApiService>();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final Map<String, bool> _connectingStatus = {};

  // المنصات المتاحة بألوان The String
  final List<SocialPlatform> _platforms = [
    SocialPlatform(
      id: 'facebook',
      name: 'Facebook',
      subtitle: 'Connect your Facebook Pages',
      icon: Icons.facebook,
      color: const Color(0xFF1877F2),
      gradient: const LinearGradient(
        colors: [Color(0xFF1877F2), Color(0xFF0D5DBE)],
      ),
    ),
    SocialPlatform(
      id: 'instagram',
      name: 'Instagram',
      subtitle: 'Connect your Instagram Business Account',
      icon: Icons.camera_alt,
      color: const Color(0xFFE4405F),
      gradient: const LinearGradient(
        colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
      ),
    ),
    SocialPlatform(
      id: 'twitter',
      name: 'X (Twitter)',
      subtitle: 'Connect your Twitter/X Account',
      icon: Icons.tag,
      color: const Color(0xFF000000),
      gradient: const LinearGradient(
        colors: [Color(0xFF000000), Color(0xFF333333)],
      ),
    ),
    SocialPlatform(
      id: 'linkedin',
      name: 'LinkedIn',
      subtitle: 'Connect your LinkedIn Profile or Page',
      icon: Icons.business_center,
      color: const Color(0xFF0A66C2),
      gradient: const LinearGradient(
        colors: [Color(0xFF0A66C2), Color(0xFF084D92)],
      ),
    ),
    SocialPlatform(
      id: 'youtube',
      name: 'YouTube',
      subtitle: 'Connect your YouTube Channel',
      icon: Icons.play_circle_filled,
      color: const Color(0xFFFF0000),
      gradient: const LinearGradient(
        colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
      ),
    ),
    SocialPlatform(
      id: 'tiktok',
      name: 'TikTok',
      subtitle: 'Connect your TikTok Account',
      icon: Icons.music_note,
      color: const Color(0xFF000000),
      gradient: const LinearGradient(
        colors: [Color(0xFF00F2EA), Color(0xFFFF0050), Color(0xFF000000)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // The String background color
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0277D4)),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connect Your Accounts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final count = _accountsService.activeAccountsCount;
                      return Text(
                        '$count ${count == 1 ? 'account' : 'accounts'} connected',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Info Card
        _buildInfoCard(),
        const SizedBox(height: 24),

        // Platforms Grid
        const Text(
          'Available Platforms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),

        // Platform Cards
        ..._platforms.map((platform) => _buildPlatformCard(platform)),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0277D4), Color(0xFF0069FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277D4).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Connection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your data is encrypted and secure. We never store your passwords.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFE0F2FE)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(SocialPlatform platform) {
    return Obx(() {
      final isConnected = _accountsService.accounts.any(
        (account) => account.platform == platform.id && account.isActive,
      );
      final isConnecting = _connectingStatus[platform.id] ?? false;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected
                ? platform.color.withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isConnected
                  ? platform.color.withValues(alpha: 0.1)
                  : const Color(0x05000000),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isConnecting ? null : () => _connectPlatform(platform),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: platform.gradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: platform.color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(platform.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          platform.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status/Action
                  if (isConnecting)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF0277D4)),
                      ),
                    )
                  else if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Connected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: platform.gradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: platform.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _connectPlatform(SocialPlatform platform) async {
    setState(() {
      _connectingStatus[platform.id] = true;
    });

    try {
      switch (platform.id) {
        case 'facebook':
          await _connectFacebook();
          break;
        case 'instagram':
          await _connectInstagram();
          break;
        case 'twitter':
          await _connectTwitter();
          break;
        case 'linkedin':
          await _connectLinkedIn();
          break;
        case 'youtube':
          await _connectYouTube();
          break;
        case 'tiktok':
          await _connectTikTok();
          break;
      }

      Get.snackbar(
        'Success',
        '${platform.name} connected successfully!',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Connection Failed',
        e.toString(),
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() {
        _connectingStatus[platform.id] = false;
      });
    }
  }

  Future<void> _connectFacebook() async {
    try {
      // استخدام FacebookGraphApiService
      final success = await _facebookService.loginWithFacebook();

      if (success) {
        // الصفحات تم تحميلها تلقائياً في loadUserPages()
        final pages = _facebookService.userPages;

        if (pages.isNotEmpty) {
          // إضافة أول صفحة (أو السماح للمستخدم بالاختيار)
          final firstPage = pages.first;
          await _accountsService.addAccount(
            platform: 'facebook',
            accountName: firstPage.name,
            accountId: firstPage.id,
            profileImageUrl: null, // سيتم جلبها لاحقاً من Graph API
            accessToken: firstPage.accessToken,
            platformData: {
              'id': firstPage.id,
              'name': firstPage.name,
              'access_token': firstPage.accessToken,
              'category': firstPage.category,
            },
          );
        }
      } else {
        throw Exception(_facebookService.lastError.value);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _connectInstagram() async {
    // Instagram OAuth flow
    Get.snackbar(
      'Coming Soon',
      'Instagram connection will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _connectTwitter() async {
    // Twitter OAuth flow
    Get.snackbar(
      'Coming Soon',
      'Twitter/X connection will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _connectLinkedIn() async {
    // LinkedIn OAuth flow
    Get.snackbar(
      'Coming Soon',
      'LinkedIn connection will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _connectYouTube() async {
    // YouTube OAuth flow
    Get.snackbar(
      'Coming Soon',
      'YouTube connection will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _connectTikTok() async {
    // TikTok OAuth flow
    Get.snackbar(
      'Coming Soon',
      'TikTok connection will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class SocialPlatform {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  SocialPlatform({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
