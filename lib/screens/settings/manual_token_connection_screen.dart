import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/social_accounts_service.dart';
import '../../services/http_service.dart';

/// شاشة ربط الحسابات يدوياً باستخدام الإيميل والباسورد
/// للمستخدمين الذين يريدون ربط حساباتهم مباشرة
class ManualTokenConnectionScreen extends StatefulWidget {
  const ManualTokenConnectionScreen({super.key});

  @override
  State<ManualTokenConnectionScreen> createState() =>
      _ManualTokenConnectionScreenState();
}

class _ManualTokenConnectionScreenState
    extends State<ManualTokenConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final SocialAccountsService _accountsService = Get.find();

  String _selectedPlatform = 'facebook';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final Map<String, Map<String, dynamic>> _platformInfo = {
    'facebook': {
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': Color(0xFF1877F2),
      'guide': '''
معلومات مهمة:

• أدخل الإيميل والباسورد الخاص بحسابك على Facebook
• تأكد من صحة بيانات الدخول
• سيتم تخزين معلومات الاتصال بشكل آمن
• سيتم استخدامها فقط للنشر على حسابك
      ''',
    },
    'instagram': {
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'color': Color(0xFFE4405F),
      'guide': '''
معلومات مهمة:

• أدخل الإيميل والباسورد الخاص بحسابك على Instagram
• تأكد من صحة بيانات الدخول
• سيتم تخزين معلومات الاتصال بشكل آمن
• سيتم استخدامها فقط للنشر على حسابك
      ''',
    },
    'linkedin': {
      'name': 'LinkedIn',
      'icon': Icons.work,
      'color': Color(0xFF0077B5),
      'guide': '''
معلومات مهمة:

• أدخل الإيميل والباسورد الخاص بحسابك على LinkedIn
• تأكد من صحة بيانات الدخول
• سيتم تخزين معلومات الاتصال بشكل آمن
• سيتم استخدامها فقط للنشر على حسابك
      ''',
    },
    'twitter': {
      'name': 'Twitter/X',
      'icon': Icons.tag,
      'color': Color(0xFF1DA1F2),
      'guide': '''
معلومات مهمة:

• أدخل الإيميل والباسورد الخاص بحسابك على Twitter/X
• تأكد من صحة بيانات الدخول
• سيتم تخزين معلومات الاتصال بشكل آمن
• سيتم استخدامها فقط للنشر على حسابك
      ''',
    },
    'youtube': {
      'name': 'YouTube',
      'icon': Icons.play_circle_filled,
      'color': Color(0xFFFF0000),
      'guide': '''
معلومات مهمة:

• أدخل الإيميل الخاص بحساب Google المرتبط بقناتك
• أدخل الباسورد الخاص بحساب Google
• تأكد من صحة بيانات الدخول
• سيتم استخدامها فقط للنشر على قناتك
      ''',
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _connectAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final platformInfo = _platformInfo[_selectedPlatform]!;
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();

      // التحقق من صحة البيانات عن طريق إرسالها للـ Backend
      print('🔄 Validating credentials for ${platformInfo['name']}...');

      final response = await _validateCredentials(
        platform: _selectedPlatform,
        email: email,
        password: password,
        username: username,
      );

      // إذا فشل التحقق، سيتم رمي استثناء من _validateCredentials
      // إذا نجح، نحفظ الحساب
      final accountId =
          response['account_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final accessToken = response['access_token'] ?? '';
      final displayName = response['display_name'] ?? username;

      await _accountsService.addAccount(
        platform: _selectedPlatform,
        accountName: displayName.isNotEmpty ? displayName : email,
        accountId: accountId,
        accessToken: accessToken,
        platformData: {
          'email': email,
          'connected_via': 'manual',
          'connected_at': DateTime.now().toIso8601String(),
          'validated': true,
        },
      );

      Get.back();
      Get.snackbar(
        'نجح الربط! ✅',
        'تم ربط حساب ${platformInfo['name']} بنجاح',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        icon: Icon(platformInfo['icon'], color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      String errorMessage = 'فشل ربط الحساب';

      if (e.toString().contains('Invalid credentials')) {
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (e.toString().contains('Account not found')) {
        errorMessage =
            'الحساب غير موجود على ${_platformInfo[_selectedPlatform]!['name']}';
      } else if (e.toString().contains('Connection failed')) {
        errorMessage =
            'فشل الاتصال بـ ${_platformInfo[_selectedPlatform]!['name']}';
      } else if (e.toString().contains('لا يوجد اتصال')) {
        errorMessage = 'لا يوجد اتصال بالإنترنت';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'فشل الربط ❌',
        errorMessage,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// التحقق من صحة بيانات الدخول مع Backend
  Future<Map<String, dynamic>> _validateCredentials({
    required String platform,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // استيراد HttpService للاتصال بالـ Backend
      final HttpService httpService = HttpService();

      final response = await httpService.post(
        '/api/social-auth/validate-credentials',
        body: {
          'platform': platform,
          'email': email,
          'password': password,
          'username': username.isNotEmpty ? username : email,
        },
      );

      if (response['success'] == true) {
        print('✅ Credentials validated successfully');
        return response['data'] ?? {};
      } else {
        final errorMsg = response['message'] ?? 'Invalid credentials';
        print('❌ Validation failed: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error validating credentials: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlatformInfo = _platformInfo[_selectedPlatform]!;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ربط الحسابات',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.cyanPurpleGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.neonCyan,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'للمستخدمين المتقدمين',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'قم بربط حساباتك على منصات التواصل الاجتماعي باستخدام الإيميل والباسورد.',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // اختيار المنصة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختر المنصة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _platformInfo.keys.map((platform) {
                        final info = _platformInfo[platform]!;
                        final isSelected = _selectedPlatform == platform;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlatform = platform;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? info['color']
                                  : AppColors.darkBg,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? info['color']
                                    : AppColors.textSecondary,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  info['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  info['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // دليل الحصول على Token
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: currentPlatformInfo['color'].withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          currentPlatformInfo['icon'],
                          color: currentPlatformInfo['color'],
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'كيفية الحصول على Token',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: currentPlatformInfo['color'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currentPlatformInfo['guide'],
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  labelStyle: TextStyle(color: AppColors.textLight),
                  hintText: 'أدخل البريد الإلكتروني',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: currentPlatformInfo['color'],
                  ),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'].withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'].withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'],
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!value.contains('@')) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // حقل كلمة المرور
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  labelStyle: TextStyle(color: AppColors.textLight),
                  hintText: 'أدخل كلمة المرور',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: currentPlatformInfo['color'],
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'].withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'].withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'],
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور قصيرة جداً';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // حقل اسم المستخدم (اختياري)
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم (اختياري)',
                  labelStyle: TextStyle(color: AppColors.textLight),
                  hintText: 'اسم المستخدم الظاهر',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: currentPlatformInfo['color'],
                  ),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'].withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'].withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: currentPlatformInfo['color'],
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // زر الربط
              ElevatedButton(
                onPressed: _isLoading ? null : _connectAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentPlatformInfo['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(currentPlatformInfo['icon'], size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'ربط ${currentPlatformInfo['name']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // تحذير أمان
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.green, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'معلوماتك آمنة ومشفرة. لن نشارك بياناتك مع أي جهة خارجية.',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
