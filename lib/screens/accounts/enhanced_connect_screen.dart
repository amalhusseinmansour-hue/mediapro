import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_colors.dart';
import '../../services/oauth_service.dart';
import '../../services/social_accounts_service.dart';
import '../../services/facebook_graph_api_service.dart';

/// Enhanced Account Connection Screen - يطابق تصميم التطبيق مع ربط فعلي
class EnhancedConnectScreen extends StatefulWidget {
  const EnhancedConnectScreen({super.key});

  @override
  State<EnhancedConnectScreen> createState() => _EnhancedConnectScreenState();
}

class _EnhancedConnectScreenState extends State<EnhancedConnectScreen>
    with TickerProviderStateMixin {
  final OAuthService _oauthService = Get.find<OAuthService>();
  final SocialAccountsService _accountsService =
      Get.find<SocialAccountsService>();
  final FacebookGraphApiService _facebookService =
      Get.find<FacebookGraphApiService>();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, bool> _connectingStatus = {};

  // المنصات المتاحة مع تصميم يطابق التطبيق
  final List<SocialPlatformData> _platforms = [
    SocialPlatformData(
      id: 'facebook',
      name: 'Facebook',
      subtitle: 'ربط صفحات ومجموعات فيسبوك',
      icon: Icons.facebook,
      gradient: const LinearGradient(
        colors: [Color(0xFF1877F2), Color(0xFF0D5DBE)],
      ),
      shadowColor: const Color(0xFF1877F2),
    ),
    SocialPlatformData(
      id: 'instagram',
      name: 'Instagram',
      subtitle: 'ربط حساب الأعمال على إنستقرام',
      icon: Icons.camera_alt_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
      ),
      shadowColor: const Color(0xFFE4405F),
    ),
    SocialPlatformData(
      id: 'twitter',
      name: 'X (Twitter)',
      subtitle: 'ربط حسابك على تويتر/إكس',
      icon: Icons.tag,
      gradient: AppColors.cyanPurpleGradient,
      shadowColor: AppColors.neonCyan,
    ),
    SocialPlatformData(
      id: 'linkedin',
      name: 'LinkedIn',
      subtitle: 'ربط الملف الشخصي أو صفحة الشركة',
      icon: Icons.business_center_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF0A66C2), Color(0xFF084D92)],
      ),
      shadowColor: const Color(0xFF0A66C2),
    ),
    SocialPlatformData(
      id: 'youtube',
      name: 'YouTube',
      subtitle: 'ربط قناتك على يوتيوب',
      icon: Icons.play_circle_filled_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
      ),
      shadowColor: const Color(0xFFFF0000),
    ),
    SocialPlatformData(
      id: 'tiktok',
      name: 'TikTok',
      subtitle: 'ربط حسابك على تيك توك',
      icon: Icons.music_note_rounded,
      gradient: AppColors.purpleMagentaGradient,
      shadowColor: AppColors.neonMagenta,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBody(),
                ),
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
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ).createShader(bounds),
                      child: const Text(
                        'ربط الحسابات',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final count = _accountsService.activeAccountsCount;
                      return Text(
                        '$count ${count == 1 ? 'حساب متصل' : 'حسابات متصلة'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
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
        _buildInfoCard(),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'المنصات المتاحة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._platforms.asMap().entries.map((entry) {
          int index = entry.key;
          var platform = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildPlatformCard(platform),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 20),
      ],
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
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security_rounded,
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
                  'اتصال آمن ومشفر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'جميع بياناتك محمية ومشفرة. لن نقوم أبداً بحفظ كلمات المرور.',
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

  Widget _buildPlatformCard(SocialPlatformData platform) {
    return Obx(() {
      final isConnected = _accountsService.accounts.any(
        (account) => account.platform == platform.id && account.isActive,
      );
      final isConnecting = _connectingStatus[platform.id] ?? false;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnected
                ? platform.shadowColor.withValues(alpha: 0.5)
                : AppColors.darkBorder,
            width: 1.5,
          ),
          boxShadow: [
            if (isConnected)
              BoxShadow(
                color: platform.shadowColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isConnecting ? null : () => _connectPlatform(platform),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: platform.gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: platform.shadowColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(platform.icon, color: Colors.white, size: 30),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          platform.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status/Action
                  if (isConnecting)
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                            platform.shadowColor,
                          ),
                        ),
                      ),
                    )
                  else if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.success, Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'متصل',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: platform.gradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: platform.shadowColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'ربط',
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

  Future<void> _connectPlatform(SocialPlatformData platform) async {
    setState(() {
      _connectingStatus[platform.id] = true;
    });

    try {
      bool success = false;

      switch (platform.id) {
        case 'facebook':
          success = await _connectFacebook();
          break;
        case 'instagram':
          success = await _connectInstagram();
          break;
        case 'twitter':
          success = await _connectTwitter();
          break;
        case 'linkedin':
          success = await _connectLinkedIn();
          break;
        case 'youtube':
          success = await _connectYouTube();
          break;
        case 'tiktok':
          success = await _connectTikTok();
          break;
      }

      if (success) {
        Get.snackbar(
          'نجح الربط',
          'تم ربط ${platform.name} بنجاح!',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 16,
          icon: const Icon(Icons.check_circle, color: Colors.white, size: 32),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'فشل الربط',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 16,
        icon: const Icon(Icons.error, color: Colors.white, size: 32),
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() {
        _connectingStatus[platform.id] = false;
      });
    }
  }

  Future<bool> _connectFacebook() async {
    try {
      // استخدام FacebookGraphApiService للربط الفعلي
      final success = await _facebookService.loginWithFacebook();

      if (success) {
        final pages = _facebookService.userPages;

        if (pages.isNotEmpty) {
          // إضافة أول صفحة (يمكن لاحقاً السماح للمستخدم بالاختيار)
          final firstPage = pages.first;
          await _accountsService.addAccount(
            platform: 'facebook',
            accountName: firstPage.name,
            accountId: firstPage.id,
            profileImageUrl: null,
            accessToken: firstPage.accessToken,
            platformData: {
              'id': firstPage.id,
              'name': firstPage.name,
              'access_token': firstPage.accessToken,
              'category': firstPage.category,
            },
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception('فشل ربط Facebook: ${e.toString()}');
    }
  }

  Future<bool> _connectInstagram() async {
    // استخدام OAuthService
    return await _oauthService
        .connectFacebook(); // Instagram يتم ربطه عبر Facebook
  }

  Future<bool> _connectTwitter() async {
    try {
      // استخدام Twitter Login
      final twitterLogin = TwitterLogin(
        apiKey: 'YOUR_API_KEY', // سيتم تكوينه لاحقاً
        apiSecretKey: 'YOUR_API_SECRET',
        redirectURI: 'your-app://callback',
      );

      final authResult = await twitterLogin.login();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        await _accountsService.addAccount(
          platform: 'twitter',
          accountName: authResult.user?.name ?? 'Twitter User',
          accountId: authResult.user?.id.toString() ?? '',
          profileImageUrl: authResult.user?.thumbnailImage,
          accessToken: authResult.authToken,
          platformData: {
            'auth_token': authResult.authToken,
            'auth_token_secret': authResult.authTokenSecret,
          },
        );
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('فشل ربط Twitter: ${e.toString()}');
    }
  }

  Future<bool> _connectLinkedIn() async {
    Get.snackbar(
      'قريباً',
      'ربط LinkedIn سيكون متاحاً قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
    return false;
  }

  Future<bool> _connectYouTube() async {
    try {
      // استخدام Google Sign In لـ YouTube
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/youtube.readonly',
          'https://www.googleapis.com/auth/youtube.upload',
        ],
      );

      final account = await googleSignIn.signIn();
      if (account != null) {
        await _accountsService.addAccount(
          platform: 'youtube',
          accountName: account.displayName ?? 'YouTube Channel',
          accountId: account.id,
          profileImageUrl: account.photoUrl,
          accessToken: (await account.authentication).accessToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('فشل ربط YouTube: ${e.toString()}');
    }
  }

  Future<bool> _connectTikTok() async {
    Get.snackbar(
      'قريباً',
      'ربط TikTok سيكون متاحاً قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
    return false;
  }
}

class SocialPlatformData {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Color shadowColor;

  SocialPlatformData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
  });
}
