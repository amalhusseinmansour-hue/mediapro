import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/theme_controller.dart';
import '../../core/controllers/locale_controller.dart';
import '../../services/auth_service_temp.dart' as auth_temp;
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';
import '../auth/business_verification_screen.dart';
import '../wallet/wallet_screen.dart';
import '../website_request/website_request_screen.dart';
import '../support/support_tickets_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = auth_temp.AuthService();
  final _themeController = Get.find<ThemeController>();
  final _localeController = Get.find<LocaleController>();
  final _notificationService = Get.find<NotificationService>();
  AuthService? _mainAuthService;
  ApiService? _apiService;
  bool _notificationsEnabled = true;
  bool _autoPostEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initServices();
    _loadSettings();
  }

  void _initServices() {
    try {
      _mainAuthService = Get.find<AuthService>();
    } catch (e) {
      // AuthService not available
    }
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      // ApiService not available
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoPostEnabled = prefs.getBool('auto_post_enabled') ?? false;
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('auto_post_enabled', _autoPostEnabled);

    // حفظ في قاعدة البيانات
    try {
      await _apiService?.updateNotificationSettings(
        notificationsEnabled: _notificationsEnabled,
        autoPostEnabled: _autoPostEnabled,
      );
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: _mainAuthService?.currentUser.value?.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              _mainAuthService!.currentUser.value!.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primaryPurple,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mainAuthService?.currentUser.value?.name ?? 'المستخدم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _mainAuthService?.currentUser.value?.email.isNotEmpty == true
                              ? _mainAuthService!.currentUser.value!.email
                              : _mainAuthService?.currentUser.value?.phoneNumber ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        if (_mainAuthService?.currentUser.value?.isBusiness == true) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _mainAuthService?.currentUser.value?.companyName ?? 'حساب شركة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAccountInfoDialog(),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Settings
            Text(
              'إعدادات الحساب',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.account_circle,
              title: 'معلومات الحساب',
              subtitle: 'تعديل البيانات الشخصية',
              onTap: () {
                _showAccountInfoDialog();
              },
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.credit_card,
              title: 'الاشتراك',
              subtitle: 'إدارة خطة الاشتراك',
              badge: 'أفراد',
              badgeColor: AppColors.primaryPurple,
              onTap: () {
                // TODO: Navigate to subscription management
              },
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'المحفظة الإلكترونية',
              subtitle: 'إدارة رصيدك والمعاملات',
              onTap: () {
                Get.to(() => const WalletScreen());
              },
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.lock,
              title: 'الأمان',
              subtitle: 'تغيير كلمة المرور والأمان',
              onTap: () {
                _showSecurityDialog();
              },
            ),
            const SizedBox(height: 8),
            // Account Status Card (حالة تفعيل الحساب - يتم من Filament)
            _buildAccountStatusCard(),
            // Business Verification Card (للشركات فقط)
            if (_mainAuthService?.currentUser.value?.isBusiness == true) ...[
              const SizedBox(height: 8),
              _buildBusinessVerificationCard(),
            ],
            const SizedBox(height: 24),

            // App Settings
            Text(
              'إعدادات التطبيق',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSwitchCard(
              icon: Icons.notifications,
              title: 'الإشعارات',
              subtitle: 'تفعيل الإشعارات',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveNotificationSettings();
              },
            ),
            const SizedBox(height: 8),
            _buildSwitchCard(
              icon: Icons.auto_mode,
              title: 'النشر التلقائي',
              subtitle: 'نشر المحتوى تلقائياً في الوقت المحدد',
              value: _autoPostEnabled,
              onChanged: (value) {
                setState(() {
                  _autoPostEnabled = value;
                });
                _saveNotificationSettings();
              },
            ),
            const SizedBox(height: 8),
            Obx(() => _buildSwitchCard(
              icon: Icons.dark_mode,
              title: 'الوضع الليلي',
              subtitle: 'تفعيل الوضع الليلي',
              value: _themeController.isDarkMode,
              onChanged: (value) {
                _themeController.toggleTheme();
              },
            )),
            const SizedBox(height: 24),

            // Content & Brand Settings
            Text(
              'إعدادات المحتوى',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.groups_rounded,
              title: 'الجمهور المستهدف',
              subtitle: 'حدد نوع جمهورك المستهدف',
              onTap: () {
                _showTargetAudienceDialog();
              },
            ),
            const SizedBox(height: 24),

            // Services
            Text(
              'الخدمات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.language_rounded,
              title: 'طلب موقع إلكتروني',
              subtitle: 'اطلب موقعاً أو متجراً إلكترونياً احترافياً',
              badge: 'جديد',
              badgeColor: AppColors.neonCyan,
              onTap: () {
                Get.to(() => const WebsiteRequestScreen());
              },
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.support_agent_rounded,
              title: 'الدعم الفني',
              subtitle: 'تواصل معنا وأرسل تذاكر الدعم',
              onTap: () {
                Get.to(() => const SupportTicketsScreen());
              },
            ),
            const SizedBox(height: 24),

            // Other Settings
            Text(
              'أخرى',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Obx(() => _buildLanguageCard()),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.help,
              title: 'المساعدة والدعم',
              subtitle: 'مركز المساعدة والأسئلة الشائعة',
              onTap: () {
                // TODO: Navigate to help center
              },
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.info,
              title: 'عن التطبيق',
              subtitle: 'الإصدار 1.0.0',
              onTap: () {
                _showAboutDialog();
              },
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.privacy_tip,
              title: 'سياسة الخصوصية',
              subtitle: 'اطلع على سياسة الخصوصية',
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
            const SizedBox(height: 24),

            // Test Notifications Button (Debug)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bug_report_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'وضع التجربة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _notificationService.sendTestNotifications();
                        Get.snackbar(
                          'تم',
                          'تم إرسال إشعارات تجريبية',
                          backgroundColor: AppColors.darkCard,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          icon: Icon(Icons.check_circle, color: AppColors.neonCyan),
                        );
                      },
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('إرسال إشعارات تجريبية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.neonCyan,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor?.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatusCard() {
    final user = _mainAuthService?.currentUser.value;
    if (user == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = user.accountStatus;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'مُفعَّل';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'قيد المراجعة';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'suspended':
        statusColor = Colors.red;
        statusText = 'موقوف';
        statusIcon = Icons.block;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'غير معروف';
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: status != 'active'
            ? Border.all(color: statusColor.withValues(alpha: 0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'حالة الحساب',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.accountStatusMessage,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Show rejection reason if exists
          if ((status == 'suspended' || status == 'rejected') &&
              user.accountRejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.accountRejectionReason!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Contact support button for suspended/rejected accounts
          if (status == 'suspended' || status == 'rejected') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.to(() => const SupportTicketsScreen()),
                icon: const Icon(Icons.support_agent, size: 18),
                label: const Text('تواصل مع الدعم'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: statusColor,
                  side: BorderSide(color: statusColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessVerificationCard() {
    final user = _mainAuthService?.currentUser.value;
    if (user == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = user.businessVerificationStatus;

    Color statusColor;
    String statusText;
    IconData statusIcon;
    bool canUpload = false;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'مُفعَّل';
        statusIcon = Icons.verified;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'قيد المراجعة';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        statusIcon = Icons.error;
        canUpload = true;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'يتطلب التفعيل';
        statusIcon = Icons.warning;
        canUpload = true;
    }

    return InkWell(
      onTap: canUpload
          ? () => Get.to(() => const BusinessVerificationScreen())
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: status == 'none' || status == 'rejected'
              ? Border.all(color: statusColor.withValues(alpha: 0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'التحقق من حساب الشركة',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status == 'approved'
                        ? 'تم التحقق من حساب الشركة'
                        : status == 'pending'
                            ? 'جاري مراجعة المستندات'
                            : status == 'rejected'
                                ? 'يرجى إعادة رفع المستندات'
                                : 'ارفع السجل التجاري والرخصة لتفعيل الحساب',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (status == 'rejected' && user.verificationRejectionReason != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سبب الرفض: ${user.verificationRejectionReason}',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (canUpload)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textLight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _localeController.toggleLanguage(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language,
                color: AppColors.primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localeController.isArabic ? 'اللغة' : 'Language',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _localeController.currentLanguageName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _localeController.otherLanguageName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Media Manager',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'تطبيق شامل لإدارة حسابات السوشال ميديا بذكاء اصطناعي متقدم.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Get.offAll(() => const LoginScreen());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في تسجيل الخروج: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showAccountInfoDialog() {
    final user = _mainAuthService?.currentUser.value;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final companyNameController = TextEditingController(text: user?.companyName ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('معلومات الحساب'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (user?.isBusiness == true) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: companyNameController,
                    decoration: InputDecoration(
                      labelText: 'اسم الشركة',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() => isSaving = true);

                      try {
                        // حفظ في قاعدة البيانات
                        final response = await _apiService?.updateUserProfile(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          companyName: user?.isBusiness == true
                              ? companyNameController.text.trim()
                              : null,
                        );

                        if (response?['success'] == true) {
                          // تحديث البيانات المحلية
                          if (_mainAuthService != null && user != null) {
                            final updatedUser = user.copyWith(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              companyName: user.isBusiness
                                  ? companyNameController.text.trim()
                                  : null,
                            );
                            _mainAuthService!.currentUser.value = updatedUser;
                          }

                          Navigator.pop(context);
                          setState(() {}); // تحديث الواجهة

                          Get.snackbar(
                            'تم الحفظ',
                            'تم حفظ معلومات الحساب بنجاح',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          Get.snackbar(
                            'خطأ',
                            response?['message'] ?? 'فشل حفظ البيانات',
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'خطأ',
                          'حدث خطأ أثناء الحفظ: $e',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } finally {
                        setDialogState(() => isSaving = false);
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSaving = false;
    bool showOldPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تغيير كلمة المرور'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: !showOldPassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الحالية',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(showOldPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => showOldPassword = !showOldPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(showNewPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => showNewPassword = !showNewPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => showConfirmPassword = !showConfirmPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      // التحقق من صحة البيانات
                      if (oldPasswordController.text.isEmpty) {
                        Get.snackbar('خطأ', 'يرجى إدخال كلمة المرور الحالية',
                            backgroundColor: AppColors.error, colorText: Colors.white);
                        return;
                      }
                      if (newPasswordController.text.length < 6) {
                        Get.snackbar('خطأ', 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل',
                            backgroundColor: AppColors.error, colorText: Colors.white);
                        return;
                      }
                      if (newPasswordController.text != confirmPasswordController.text) {
                        Get.snackbar('خطأ', 'كلمة المرور الجديدة غير متطابقة',
                            backgroundColor: AppColors.error, colorText: Colors.white);
                        return;
                      }

                      setDialogState(() => isSaving = true);

                      try {
                        final response = await _apiService?.changePassword(
                          currentPassword: oldPasswordController.text,
                          newPassword: newPasswordController.text,
                          newPasswordConfirmation: confirmPasswordController.text,
                        );

                        if (response?['success'] == true) {
                          Navigator.pop(context);
                          Get.snackbar(
                            'تم التحديث',
                            'تم تغيير كلمة المرور بنجاح',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          Get.snackbar(
                            'خطأ',
                            response?['message'] ?? 'فشل تغيير كلمة المرور',
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'خطأ',
                          'حدث خطأ أثناء تغيير كلمة المرور',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } finally {
                        setDialogState(() => isSaving = false);
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBrandKitDialog() {
    final brandNameController = TextEditingController();
    final brandDescriptionController = TextEditingController();
    final brandColorsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.palette_rounded, color: AppColors.neonCyan),
            const SizedBox(width: 8),
            const Text('Brand Kit'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: brandNameController,
                decoration: InputDecoration(
                  labelText: 'اسم البراند',
                  hintText: 'مثال: شركة التقنية الحديثة',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: brandDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'وصف البراند',
                  hintText: 'وصف مختصر عن البراند...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: brandColorsController,
                decoration: InputDecoration(
                  labelText: 'ألوان البراند',
                  hintText: '#FF5733, #33FF57',
                  prefixIcon: const Icon(Icons.color_lens),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: AppColors.neonCyan, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'سيتم استخدام هذه المعلومات لتوليد محتوى مخصص',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'تم الحفظ',
                'تم حفظ Brand Kit بنجاح',
                backgroundColor: AppColors.darkCard,
                colorText: Colors.white,
                icon: Icon(Icons.check_circle, color: AppColors.neonCyan),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showTargetAudienceDialog() {
    final ageRangeController = TextEditingController();
    final interestsController = TextEditingController();
    String selectedGender = 'الكل';
    String selectedLocation = 'عالمي';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.groups_rounded, color: AppColors.neonCyan),
              const SizedBox(width: 8),
              const Text('الجمهور المستهدف'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الجنس',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['الكل', 'ذكور', 'إناث'].map((gender) {
                    return ChoiceChip(
                      label: Text(gender),
                      selected: selectedGender == gender,
                      onSelected: (selected) {
                        setDialogState(() {
                          selectedGender = gender;
                        });
                      },
                      selectedColor: AppColors.neonCyan,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageRangeController,
                  decoration: InputDecoration(
                    labelText: 'الفئة العمرية',
                    hintText: 'مثال: 18-35',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'الموقع',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['عالمي', 'الخليج', 'مصر', 'المغرب العربي'].map((location) {
                    return ChoiceChip(
                      label: Text(location),
                      selected: selectedLocation == location,
                      onSelected: (selected) {
                        setDialogState(() {
                          selectedLocation = location;
                        });
                      },
                      selectedColor: AppColors.neonCyan,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: interestsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الاهتمامات',
                    hintText: 'تقنية، رياضة، طبخ...',
                    prefixIcon: const Icon(Icons.favorite),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.psychology_rounded, color: AppColors.neonPurple, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'AI سيستخدم هذه المعلومات لإنشاء محتوى ملائم',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() => isSaving = true);

                      try {
                        // حفظ محلياً
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('target_gender', selectedGender);
                        await prefs.setString('target_age_range', ageRangeController.text);
                        await prefs.setString('target_location', selectedLocation);
                        await prefs.setString('target_interests', interestsController.text);

                        // حفظ في قاعدة البيانات
                        final response = await _apiService?.updateTargetAudience(
                          gender: selectedGender,
                          ageRange: ageRangeController.text,
                          location: selectedLocation,
                          interests: interestsController.text,
                        );

                        Navigator.pop(context);

                        if (response?['success'] == true) {
                          Get.snackbar(
                            'تم الحفظ',
                            'تم حفظ معلومات الجمهور المستهدف بنجاح',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            icon: Icon(Icons.check_circle, color: Colors.white),
                          );
                        } else {
                          // تم الحفظ محلياً على الأقل
                          Get.snackbar(
                            'تم الحفظ محلياً',
                            'تم حفظ الإعدادات على الجهاز',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'خطأ',
                          'حدث خطأ أثناء الحفظ',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } finally {
                        setDialogState(() => isSaving = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
