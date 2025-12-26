import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/social_accounts_controller.dart';
import '../../models/social_account_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/feature_flags.dart';
import '../subscription/subscription_screen.dart';

class SocialAccountsManagementScreen extends StatefulWidget {
  const SocialAccountsManagementScreen({super.key});

  @override
  State<SocialAccountsManagementScreen> createState() =>
      _SocialAccountsManagementScreenState();
}

class _SocialAccountsManagementScreenState
    extends State<SocialAccountsManagementScreen>
    with SingleTickerProviderStateMixin {
  late SocialAccountsController controller;
  late AnimationController _animController;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();

    // استخدام try-catch للتعامل مع أي أخطاء عند تهيئة الـ Controller
    try {
      controller = Get.put(SocialAccountsController());
    } catch (e) {
      print('❌ Error initializing SocialAccountsController: $e');
      // إذا فشل التهيئة، استخدم controller فارغ كحل بديل
      controller = SocialAccountsController();
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // تأخير animation حتى يتم build بشكل كامل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animController.forward();
      }
    });

    // تحميل الحسابات
    Future.microtask(() {
      try {
        controller.loadConnectedAccounts();
      } catch (e) {
        print('❌ Error loading accounts: $e');
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1a1a1a),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.neonCyan),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'إدارة حسابات التواصل',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Obx(() {
      // معالجة حالة الخطأ
      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade300, size: 64),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.loadConnectedAccounts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.neonCyan),
          ),
        );
      }

      return SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadConnectedAccounts(),
          color: AppColors.neonCyan,
          backgroundColor: const Color(0xFF1a1a1a),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildSubscriptionInfoCard(_authService.currentUser.value),
              const SizedBox(height: 16),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildConnectedAccountsSection(),
              const SizedBox(height: 24),
              _buildAvailablePlatformsSection(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSubscriptionInfoCard(UserModel? user) {
    if (user == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonPurple.withOpacity(0.15),
              AppColors.neonCyan.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.workspace_premium,
              size: 40,
              color: AppColors.neonCyan,
            ),
            const SizedBox(height: 12),
            Text(
              'باقتك: ${user.tierDisplayName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك ربط حتى ${user.maxAccounts} ${user.maxAccounts == 1 ? 'حساب' : 'حسابات'}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'المربوطة حالياً: ${controller.totalConnectedAccounts}/${user.maxAccounts}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.neonCyan,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (controller.totalConnectedAccounts >= user.maxAccounts) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'وصلت للحد الأقصى من الحسابات',
                        style: TextStyle(
                          color: Colors.orange.shade200,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Hide upgrade button on iOS for App Store approval
              if (!user.isBusinessTier && FeatureFlags.showUpgradePrompts) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Get.to(() => const SubscriptionScreen()),
                  icon: const Icon(Icons.upgrade, size: 16),
                  label: const Text('ترقية للمزيد من الحسابات'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neonCyan,
                    backgroundColor: AppColors.neonCyan.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonCyan.withOpacity(0.1),
              AppColors.neonPurple.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'إجمالي الحسابات',
                  controller.totalConnectedAccounts.toString(),
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'المنصات المتصلة',
                  controller.connectedPlatforms.length.toString(),
                  Icons.layers,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.neonCyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildConnectedAccountsSection() {
    return Obx(() {
      if (controller.connectedAccounts.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'الحسابات المتصلة (${controller.connectedAccounts.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.connectedAccounts.length,
            itemBuilder: (context, index) {
              final account = controller.connectedAccounts[index];
              return _buildAccountCard(account);
            },
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.account_circle_outlined,
              color: AppColors.neonCyan.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد حسابات متصلة',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'ربط حسابك الأول لتبدأ',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(SocialAccountModel account) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonCyan.withOpacity(0.2),
                    AppColors.neonPurple.withOpacity(0.2),
                  ],
                ),
              ),
              child: account.profileImageUrl != null
                  ? Image.network(
                      account.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.account_circle, color: AppColors.neonCyan),
                    )
                  : Icon(Icons.account_circle, color: AppColors.neonCyan),
            ),
          ),
          title: Text(
            account.accountName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            account.platform,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: PopupMenuButton(
            color: const Color(0xFF2a2a2a),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.neonCyan, size: 20),
                    SizedBox(width: 8),
                    Text('تحديث', style: TextStyle(color: Colors.white)),
                  ],
                ),
                onTap: () => controller.refreshAccount(account.id),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('فصل', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () => _showDeleteConfirmation(account),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailablePlatformsSection() {
    final List<Map<String, Object>> platforms = [
      {'id': 'facebook', 'name': 'Facebook', 'icon': Icons.facebook, 'type': 'social'},
      {'id': 'instagram', 'name': 'Instagram', 'icon': Icons.camera_alt, 'type': 'social'},
      {'id': 'twitter', 'name': 'Twitter/X', 'icon': Icons.close, 'type': 'social'},
      {'id': 'linkedin', 'name': 'LinkedIn', 'icon': Icons.business, 'type': 'social'},
      {'id': 'youtube', 'name': 'YouTube', 'icon': Icons.play_circle, 'type': 'social'},
      {'id': 'tiktok', 'name': 'TikTok', 'icon': Icons.music_note, 'type': 'social'},
      // Telegram removed - now handled automatically in background
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ربط منصات إضافية',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: platforms.length,
          itemBuilder: (context, index) {
            final platform = platforms[index];
            final platformId = platform['id'] as String;
            final platformName = platform['name'] as String;
            final platformIcon = platform['icon'] as IconData;
            final platformType = platform['type'] as String;
            final isConnected = controller.isPlatformConnected(platformId);
            return _buildPlatformCard(
              platformId,
              platformName,
              platformIcon,
              isConnected,
              platformType,
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPlatformCard(
    String platformId,
    String platformName,
    IconData icon,
    bool isConnected,
    String platformType,
  ) {
    final user = _authService.currentUser.value;
    final bool canConnect = user != null &&
        controller.totalConnectedAccounts < user.maxAccounts;

    return GestureDetector(
      onTap: isConnected
          ? null
          : () {
              // إذا كان تليجرام، افتح شاشة التليجرام الخاصة
              if (platformId == 'telegram') {
                _showTelegramGuide();
              } else {
                // المنصات الأخرى
                if (canConnect) {
                  controller.connectAccount(platformId);
                } else {
                  _showLimitReachedDialog(user);
                }
              }
            },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? AppColors.neonCyan
                : Colors.white.withOpacity(0.1),
            width: isConnected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.neonCyan, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    platformName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // زر المساعدة
            if (!isConnected)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _showPlatformHelp(platformId, platformName),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.4),
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.help_outline, color: Colors.blue, size: 14),
                  ),
                ),
              ),
            // علامة الاتصال
            if (isConnected)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(SocialAccountModel account) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text('فصل الحساب', style: TextStyle(color: Colors.white)),
        content: Text(
          'هل أنت متأكد من رغبتك في فصل حساب ${account.accountName}؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              controller.disconnectAccount(account.id);
              Get.back();
            },
            child: const Text('فصل', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog(UserModel? user) {
    if (user == null) return;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('وصلت للحد الأقصى', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لقد وصلت للحد الأقصى من الحسابات (${user.maxAccounts}) في باقة ${user.tierDisplayName}.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            if (!user.isBusinessTier) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upgrade, color: AppColors.neonCyan, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'قم بالترقية للحصول على:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!user.isIndividualTier) ...[
                      _buildUpgradeFeature('باقة الأفراد: حتى 3 حسابات'),
                      _buildUpgradeFeature('باقة الشركات: حتى 10 حسابات'),
                    ] else ...[
                      _buildUpgradeFeature('باقة الشركات: حتى 10 حسابات'),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          // Hide upgrade button on iOS for App Store approval
          if (!user.isBusinessTier && FeatureFlags.showUpgradePrompts)
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.to(() => const SubscriptionScreen());
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('ترقية الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  void _showPlatformHelp(String platformId, String platformName) {
    // إذا كان تليجرام، استخدم الدليل المفصل
    if (platformId == 'telegram') {
      _showTelegramGuide();
      return;
    }

    // للمنصات الأخرى، اعرض شرح بسيط
    final Map<String, Map<String, String>> helpInfo = {
      'facebook': {
        'title': 'كيف أربط Facebook؟',
        'description': 'لربط حسابك على Facebook:',
        'step1': 'اضغط على زر "ربط Facebook" أدناه',
        'step2': 'ستفتح صفحة تسجيل دخول Facebook',
        'step3': 'سجل الدخول وامنح الأذونات المطلوبة',
        'step4': 'سيتم ربط حسابك تلقائياً',
      },
      'instagram': {
        'title': 'كيف أربط Instagram؟',
        'description': 'لربط حسابك على Instagram:',
        'step1': 'تأكد أن حسابك محول لحساب أعمال',
        'step2': 'اضغط على زر "ربط Instagram"',
        'step3': 'سجل الدخول بحساب Facebook المربوط بـ Instagram',
        'step4': 'اختر حساب Instagram الذي تريد ربطه',
      },
      'twitter': {
        'title': 'كيف أربط Twitter/X؟',
        'description': 'لربط حسابك على Twitter:',
        'step1': 'اضغط على زر "ربط Twitter"',
        'step2': 'سجل الدخول بحسابك على Twitter',
        'step3': 'اسمح للتطبيق بالوصول لحسابك',
        'step4': 'سيتم الربط فوراً',
      },
      'linkedin': {
        'title': 'كيف أربط LinkedIn؟',
        'description': 'لربط حسابك على LinkedIn:',
        'step1': 'اضغط على زر "ربط LinkedIn"',
        'step2': 'سجل الدخول بحسابك الشخصي أو صفحتك',
        'step3': 'امنح الأذونات المطلوبة',
        'step4': 'ستتمكن من النشر مباشرة',
      },
      'youtube': {
        'title': 'كيف أربط YouTube؟',
        'description': 'لربط قناتك على YouTube:',
        'step1': 'اضغط على زر "ربط YouTube"',
        'step2': 'سجل الدخول بحساب Google الخاص بقناتك',
        'step3': 'اختر القناة التي تريد ربطها',
        'step4': 'امنح أذونات النشر',
      },
      'tiktok': {
        'title': 'كيف أربط TikTok؟',
        'description': 'لربط حسابك على TikTok:',
        'step1': 'اضغط على زر "ربط TikTok"',
        'step2': 'سجل الدخول بحسابك',
        'step3': 'امنح التطبيق أذونات النشر',
        'step4': 'استمتع بالنشر التلقائي',
      },
    };

    final info = helpInfo[platformId];
    if (info == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline,
                color: AppColors.neonCyan,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                info['title']!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info['description']!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildSimpleStep('1', info['step1']!),
              const SizedBox(height: 8),
              _buildSimpleStep('2', info['step2']!),
              const SizedBox(height: 8),
              _buildSimpleStep('3', info['step3']!),
              const SizedBox(height: 8),
              _buildSimpleStep('4', info['step4']!),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.neonCyan,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  void _showTelegramGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0088CC).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.telegram,
                color: Color(0xFF0088CC),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'ربط بوت تليجرام',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يمكنك ربط بوت تليجرام للنشر التلقائي على قناتك أو مجموعتك',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildGuideStep(
                '1',
                'إنشاء البوت',
                'افتح تطبيق تليجرام وابحث عن @BotFather',
                Icons.search,
              ),
              const SizedBox(height: 12),
              _buildGuideStep(
                '2',
                'احصل على Token',
                'أرسل /newbot واتبع التعليمات للحصول على Bot Token',
                Icons.key,
              ),
              const SizedBox(height: 12),
              _buildGuideStep(
                '3',
                'أضف البوت هنا',
                'انسخ الـ Token والـ Username وأضفهم في الشاشة التالية',
                Icons.add_circle,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ستحتاج أيضاً لإضافة البوت إلى قناتك أو مجموعتك كمشرف',
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0088CC),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.neonCyan,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.neonCyan, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.neonCyan, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
