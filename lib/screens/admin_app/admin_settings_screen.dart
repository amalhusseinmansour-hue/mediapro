import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/admin_api_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late AdminApiService _adminService;
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};

  // Controllers for editable fields
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    // Initialize or find the service
    if (!Get.isRegistered<AdminApiService>()) {
      Get.put(AdminApiService());
    }
    _adminService = Get.find<AdminApiService>();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _adminService.fetchAllSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('فشل في تحميل الإعدادات');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateSetting(String group, String key, dynamic value) async {
    final success = await _adminService.updateSetting(group, key, value);
    if (success) {
      _showSuccess('تم تحديث الإعداد بنجاح');
      await _loadSettings();
    } else {
      _showError('فشل في تحديث الإعداد');
    }
  }

  void _showEditDialog(String group, String key, String currentValue, String label) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: Text(
          'تعديل $label',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'أدخل القيمة الجديدة',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateSetting(group, key, controller.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('إعدادات التطبيق'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : RefreshIndicator(
              onRefresh: _loadSettings,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // AI Settings
                  _buildSettingsSection(
                    title: 'إعدادات AI',
                    icon: Icons.auto_awesome,
                    color: const Color(0xFF6C63FF),
                    settings: _buildAISettings(),
                  ),
                  const SizedBox(height: 16),

                  // OTP/SMS Settings
                  _buildSettingsSection(
                    title: 'إعدادات OTP/SMS',
                    icon: Icons.message,
                    color: const Color(0xFF4CAF50),
                    settings: _buildOTPSettings(),
                  ),
                  const SizedBox(height: 16),

                  // Payment Settings
                  _buildSettingsSection(
                    title: 'إعدادات الدفع',
                    icon: Icons.payment,
                    color: const Color(0xFFFF6B9D),
                    settings: _buildPaymentSettings(),
                  ),
                  const SizedBox(height: 16),

                  // General Settings
                  _buildSettingsSection(
                    title: 'إعدادات عامة',
                    icon: Icons.settings,
                    color: const Color(0xFF00E5FF),
                    settings: _buildGeneralSettings(),
                  ),
                  const SizedBox(height: 16),

                  // Analytics Settings
                  _buildSettingsSection(
                    title: 'إعدادات التحليلات',
                    icon: Icons.analytics,
                    color: const Color(0xFFFFD700),
                    settings: _buildAnalyticsSettings(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          setState(() => _isLoading = true);
          await _loadSettings();
          _showSuccess('تم تحديث جميع الإعدادات');
        },
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.sync),
        label: const Text('مزامنة الإعدادات'),
      ),
    );
  }

  List<_SettingItem> _buildAISettings() {
    final ai = _settings['ai'] ?? {};
    final aiContent = _settings['ai_content'] ?? {};

    return [
      _SettingItem(
        label: 'توليد الصور AI',
        value: _getBoolDisplay(ai['image_generation_enabled'] ?? aiContent['image_generation_enabled']),
        isToggle: true,
        isEnabled: ai['image_generation_enabled'] == true || aiContent['image_generation_enabled'] == true,
        onToggle: (value) => _updateSetting('ai', 'image_generation_enabled', value),
      ),
      _SettingItem(
        label: 'توليد الفيديو AI',
        value: _getBoolDisplay(ai['video_generation_enabled'] ?? aiContent['video_generation_enabled']),
        isToggle: true,
        isEnabled: ai['video_generation_enabled'] == true || aiContent['video_generation_enabled'] == true,
        onToggle: (value) => _updateSetting('ai', 'video_generation_enabled', value),
      ),
      _SettingItem(
        label: 'مزود الصور',
        value: ai['image_provider'] ?? aiContent['image_provider'] ?? 'replicate',
        onTap: () => _showEditDialog('ai', 'image_provider',
            ai['image_provider'] ?? 'replicate', 'مزود الصور'),
      ),
      _SettingItem(
        label: 'Replicate API Key',
        value: _maskApiKey(ai['replicate_api_key'] ?? ''),
        onTap: () => _showEditDialog('ai', 'replicate_api_key',
            ai['replicate_api_key'] ?? '', 'Replicate API Key'),
      ),
      _SettingItem(
        label: 'Runway API Key',
        value: _maskApiKey(ai['runway_api_key'] ?? ''),
        onTap: () => _showEditDialog('ai', 'runway_api_key',
            ai['runway_api_key'] ?? '', 'Runway API Key'),
      ),
      _SettingItem(
        label: 'النموذج الافتراضي',
        value: ai['default_model'] ?? aiContent['text_model'] ?? 'gpt-4',
        onTap: () => _showEditDialog('ai', 'default_model',
            ai['default_model'] ?? 'gpt-4', 'النموذج الافتراضي'),
      ),
    ];
  }

  List<_SettingItem> _buildOTPSettings() {
    final otp = _settings['otp'] ?? {};

    return [
      _SettingItem(
        label: 'Twilio',
        value: _getBoolDisplay(otp['twilio_enabled']),
        isToggle: true,
        isEnabled: otp['twilio_enabled'] == true,
        onToggle: (value) => _updateSetting('otp', 'twilio_enabled', value),
      ),
      _SettingItem(
        label: 'Account SID',
        value: _maskApiKey(otp['twilio_account_sid'] ?? ''),
        onTap: () => _showEditDialog('otp', 'twilio_account_sid',
            otp['twilio_account_sid'] ?? '', 'Account SID'),
      ),
      _SettingItem(
        label: 'Auth Token',
        value: _maskApiKey(otp['twilio_auth_token'] ?? ''),
        onTap: () => _showEditDialog('otp', 'twilio_auth_token',
            otp['twilio_auth_token'] ?? '', 'Auth Token'),
      ),
      _SettingItem(
        label: 'رقم الهاتف',
        value: otp['twilio_phone_number'] ?? 'غير محدد',
        onTap: () => _showEditDialog('otp', 'twilio_phone_number',
            otp['twilio_phone_number'] ?? '', 'رقم الهاتف'),
      ),
      _SettingItem(
        label: 'وضع الاختبار',
        value: _getBoolDisplay(otp['test_otp_enabled']),
        isToggle: true,
        isEnabled: otp['test_otp_enabled'] == true,
        onToggle: (value) => _updateSetting('otp', 'test_otp_enabled', value),
      ),
      _SettingItem(
        label: 'كود الاختبار',
        value: otp['test_otp_code'] ?? '123456',
        onTap: () => _showEditDialog('otp', 'test_otp_code',
            otp['test_otp_code'] ?? '123456', 'كود الاختبار'),
      ),
    ];
  }

  List<_SettingItem> _buildPaymentSettings() {
    final payment = _settings['payment'] ?? {};

    return [
      _SettingItem(
        label: 'Stripe',
        value: _getBoolDisplay(payment['stripe_enabled']),
        isToggle: true,
        isEnabled: payment['stripe_enabled'] == true,
        onToggle: (value) => _updateSetting('payment', 'stripe_enabled', value),
      ),
      _SettingItem(
        label: 'Paymob',
        value: _getBoolDisplay(payment['paymob_enabled']),
        isToggle: true,
        isEnabled: payment['paymob_enabled'] == true,
        onToggle: (value) => _updateSetting('payment', 'paymob_enabled', value),
      ),
      _SettingItem(
        label: 'PayPal',
        value: _getBoolDisplay(payment['paypal_enabled']),
        isToggle: true,
        isEnabled: payment['paypal_enabled'] == true,
        onToggle: (value) => _updateSetting('payment', 'paypal_enabled', value),
      ),
      _SettingItem(
        label: 'Apple Pay',
        value: _getBoolDisplay(payment['apple_pay_enabled']),
        isToggle: true,
        isEnabled: payment['apple_pay_enabled'] == true,
        onToggle: (value) => _updateSetting('payment', 'apple_pay_enabled', value),
      ),
      _SettingItem(
        label: 'Google Pay',
        value: _getBoolDisplay(payment['google_pay_enabled']),
        isToggle: true,
        isEnabled: payment['google_pay_enabled'] == true,
        onToggle: (value) => _updateSetting('payment', 'google_pay_enabled', value),
      ),
      _SettingItem(
        label: 'البوابة الافتراضية',
        value: payment['default_gateway'] ?? 'stripe',
        onTap: () => _showEditDialog('payment', 'default_gateway',
            payment['default_gateway'] ?? 'stripe', 'البوابة الافتراضية'),
      ),
      _SettingItem(
        label: 'الحد الأدنى للدفع',
        value: '${payment['minimum_amount'] ?? 10} ${_settings['localization']?['currency'] ?? 'AED'}',
        onTap: () => _showEditDialog('payment', 'minimum_amount',
            '${payment['minimum_amount'] ?? 10}', 'الحد الأدنى للدفع'),
      ),
    ];
  }

  List<_SettingItem> _buildGeneralSettings() {
    final app = _settings['app'] ?? {};
    final localization = _settings['localization'] ?? {};
    final features = _settings['features'] ?? {};

    return [
      _SettingItem(
        label: 'اسم التطبيق',
        value: app['name'] ?? 'ميديا برو',
        onTap: () => _showEditDialog('app', 'name',
            app['name'] ?? 'ميديا برو', 'اسم التطبيق'),
      ),
      _SettingItem(
        label: 'اسم التطبيق (إنجليزي)',
        value: app['name_en'] ?? 'Media Pro',
        onTap: () => _showEditDialog('app', 'name_en',
            app['name_en'] ?? 'Media Pro', 'اسم التطبيق (إنجليزي)'),
      ),
      _SettingItem(
        label: 'العملة',
        value: localization['currency'] ?? 'AED',
        onTap: () => _showEditDialog('localization', 'currency',
            localization['currency'] ?? 'AED', 'العملة'),
      ),
      _SettingItem(
        label: 'اللغة الافتراضية',
        value: _getLanguageDisplay(localization['default_language']),
        onTap: () => _showEditDialog('localization', 'default_language',
            localization['default_language'] ?? 'ar', 'اللغة الافتراضية'),
      ),
      _SettingItem(
        label: 'وضع الصيانة',
        value: _getBoolDisplay(app['maintenance_mode']),
        isToggle: true,
        isEnabled: app['maintenance_mode'] == true,
        onToggle: (value) => _updateSetting('app', 'maintenance_mode', value),
      ),
      _SettingItem(
        label: 'Firebase',
        value: _getBoolDisplay(features['firebase_enabled']),
        isToggle: true,
        isEnabled: features['firebase_enabled'] == true,
        onToggle: (value) => _updateSetting('features', 'firebase_enabled', value),
      ),
      _SettingItem(
        label: 'إصدار التطبيق',
        value: app['version'] ?? '1.0.0',
        onTap: () => _showEditDialog('app', 'version',
            app['version'] ?? '1.0.0', 'إصدار التطبيق'),
      ),
    ];
  }

  List<_SettingItem> _buildAnalyticsSettings() {
    final analytics = _settings['analytics'] ?? {};

    return [
      _SettingItem(
        label: 'التحليلات',
        value: _getBoolDisplay(analytics['enabled']),
        isToggle: true,
        isEnabled: analytics['enabled'] == true,
        onToggle: (value) => _updateSetting('analytics', 'enabled', value),
      ),
      _SettingItem(
        label: 'Google Analytics',
        value: _getBoolDisplay(analytics['google_analytics_enabled']),
        isToggle: true,
        isEnabled: analytics['google_analytics_enabled'] == true,
        onToggle: (value) => _updateSetting('analytics', 'google_analytics_enabled', value),
      ),
      _SettingItem(
        label: 'Facebook Pixel',
        value: _getBoolDisplay(analytics['facebook_pixel_enabled']),
        isToggle: true,
        isEnabled: analytics['facebook_pixel_enabled'] == true,
        onToggle: (value) => _updateSetting('analytics', 'facebook_pixel_enabled', value),
      ),
      _SettingItem(
        label: 'Firebase Analytics',
        value: _getBoolDisplay(analytics['firebase_analytics_enabled']),
        isToggle: true,
        isEnabled: analytics['firebase_analytics_enabled'] == true,
        onToggle: (value) => _updateSetting('analytics', 'firebase_analytics_enabled', value),
      ),
      _SettingItem(
        label: 'GA Tracking ID',
        value: analytics['google_analytics_tracking_id'] ?? 'غير محدد',
        onTap: () => _showEditDialog('analytics', 'google_analytics_tracking_id',
            analytics['google_analytics_tracking_id'] ?? '', 'GA Tracking ID'),
      ),
      _SettingItem(
        label: 'Facebook Pixel ID',
        value: analytics['facebook_pixel_id'] ?? 'غير محدد',
        onTap: () => _showEditDialog('analytics', 'facebook_pixel_id',
            analytics['facebook_pixel_id'] ?? '', 'Facebook Pixel ID'),
      ),
    ];
  }

  String _getBoolDisplay(dynamic value) {
    if (value == true || value == 'true' || value == 1 || value == '1') {
      return 'مفعّل';
    }
    return 'معطّل';
  }

  String _getLanguageDisplay(String? lang) {
    switch (lang) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return lang ?? 'العربية';
    }
  }

  String _maskApiKey(String key) {
    if (key.isEmpty) return 'غير مضاف';
    if (key.length <= 8) return '***';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_SettingItem> settings,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: color.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
          ...settings.asMap().entries.map((entry) {
            final index = entry.key;
            final setting = entry.value;
            return _buildSettingRow(setting, index < settings.length - 1, color);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingRow(_SettingItem setting, bool showDivider, Color accentColor) {
    return InkWell(
      onTap: setting.isToggle ? null : setting.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                setting.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
            if (setting.isToggle)
              Switch(
                value: setting.isEnabled,
                onChanged: setting.onToggle,
                activeThumbColor: accentColor,
                activeTrackColor: accentColor.withValues(alpha: 0.3),
              )
            else
              Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      setting.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: setting.value == 'مفعّل'
                            ? Colors.green
                            : setting.value == 'معطّل'
                                ? Colors.grey
                                : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem {
  final String label;
  final String value;
  final bool isToggle;
  final bool isEnabled;
  final VoidCallback? onTap;
  final Function(bool)? onToggle;

  _SettingItem({
    required this.label,
    required this.value,
    this.isToggle = false,
    this.isEnabled = false,
    this.onTap,
    this.onToggle,
  });
}
