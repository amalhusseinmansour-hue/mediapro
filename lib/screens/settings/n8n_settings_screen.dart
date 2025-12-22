import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_colors.dart';
import '../../services/n8n_service.dart';

class N8nSettingsScreen extends StatefulWidget {
  const N8nSettingsScreen({super.key});

  @override
  State<N8nSettingsScreen> createState() => _N8nSettingsScreenState();
}

class _N8nSettingsScreenState extends State<N8nSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _storage = GetStorage();
  final _n8nService = Get.find<N8nService>();

  bool _isEnabled = false;
  bool _isTesting = false;
  bool? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    _urlController.text = _storage.read('n8n_url') ?? '';
    _apiKeyController.text = _storage.read('n8n_api_key') ?? '';
    _isEnabled = _storage.read('n8n_enabled') ?? false;
    setState(() {});
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    await _storage.write('n8n_url', _urlController.text);
    await _storage.write('n8n_api_key', _apiKeyController.text);
    await _storage.write('n8n_enabled', _isEnabled);

    await _n8nService.init(
      n8nUrl: _urlController.text.isNotEmpty ? _urlController.text : null,
      apiKey: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
    );

    Get.snackbar(
      'نجح',
      'تم حفظ إعدادات n8n بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }

  Future<void> _testConnection() async {
    if (_urlController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رابط n8n أولاً',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isTesting = true;
      _connectionStatus = null;
    });

    // تحديث الإعدادات مؤقتاً للاختبار
    await _n8nService.init(
      n8nUrl: _urlController.text,
      apiKey: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
    );

    final success = await _n8nService.testConnection();

    setState(() {
      _isTesting = false;
      _connectionStatus = success;
    });

    Get.snackbar(
      success ? 'نجح' : 'فشل',
      success
          ? 'تم الاتصال بـ n8n بنجاح'
          : 'فشل الاتصال بـ n8n. تحقق من الرابط والإعدادات',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: success
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.error.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),

              _buildEnableToggle(),
              const SizedBox(height: 24),

              _buildURLField(),
              const SizedBox(height: 16),

              _buildAPIKeyField(),
              const SizedBox(height: 24),

              _buildTestButton(),
              const SizedBox(height: 24),

              if (_connectionStatus != null) _buildStatusCard(),
              const SizedBox(height: 24),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.warning, AppColors.neonPurple],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.api_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إعدادات n8n',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'أتمتة النشر المتقدمة',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonCyan.withValues(alpha: 0.1),
            AppColors.neonPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.neonCyan),
              const SizedBox(width: 12),
              const Text(
                'ما هو n8n؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'n8n هو أداة أتمتة مفتوحة المصدر تسمح لك بإنشاء workflows معقدة للنشر التلقائي على منصات السوشال ميديا المتعددة.\n\nباستخدام n8n، يمكنك:\n• جدولة المنشورات بدقة\n• النشر على منصات متعددة في نفس الوقت\n• إنشاء workflows مخصصة\n• مراقبة النشر في الوقت الفعلي',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEnabled
              ? AppColors.success.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isEnabled
                  ? AppColors.success.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isEnabled ? Icons.check_circle : Icons.power_settings_new,
              color: _isEnabled ? AppColors.success : AppColors.textLight,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفعيل n8n',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'تمكين التكامل مع n8n',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildURLField() {
    return TextFormField(
      controller: _urlController,
      enabled: _isEnabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'رابط n8n',
        hintText: 'https://your-n8n-instance.com',
        labelStyle: const TextStyle(color: AppColors.textLight),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(Icons.link, color: AppColors.neonCyan),
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.neonCyan, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      validator: (value) {
        if (_isEnabled && (value == null || value.isEmpty)) {
          return 'يرجى إدخال رابط n8n';
        }
        if (_isEnabled && value != null && !value.startsWith('http')) {
          return 'يجب أن يبدأ الرابط بـ http أو https';
        }
        return null;
      },
    );
  }

  Widget _buildAPIKeyField() {
    return TextFormField(
      controller: _apiKeyController,
      enabled: _isEnabled,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'API Key (اختياري)',
        hintText: 'n8n API Key',
        labelStyle: const TextStyle(color: AppColors.textLight),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(Icons.key, color: AppColors.neonPurple),
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.neonPurple, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isEnabled && !_isTesting ? _testConnection : null,
        icon: _isTesting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.warning,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.wifi_tethering),
        label: Text(
          _isTesting ? 'جاري الاختبار...' : 'اختبار الاتصال',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warning,
          side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledForegroundColor: AppColors.textLight.withValues(alpha: 0.5),
          disabledBackgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isSuccess = _connectionStatus == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccess
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.error.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isSuccess
                  ? 'الاتصال ناجح! يمكنك حفظ الإعدادات الآن.'
                  : 'فشل الاتصال. تحقق من الرابط والإعدادات.',
              style: TextStyle(
                color: isSuccess ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cyanPurpleGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _saveSettings,
          icon: const Icon(Icons.save_rounded),
          label: const Text(
            'حفظ الإعدادات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
