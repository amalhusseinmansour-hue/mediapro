import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ayrshare_service.dart';
import '../../services/auth_service.dart';

/// شاشة ربط الحسابات عبر Ayrshare
/// توفر ربط سريع وسهل لجميع منصات التواصل الاجتماعي
class AyrshareConnectScreen extends StatefulWidget {
  const AyrshareConnectScreen({super.key});

  @override
  State<AyrshareConnectScreen> createState() => _AyrshareConnectScreenState();
}

class _AyrshareConnectScreenState extends State<AyrshareConnectScreen> {
  final AyrshareService _ayrshareService = AyrshareService();
  // TODO: Reserve for future Ayrshare account management
  // final SocialAccountsService _accountsService = Get.find();
  final AuthService _authService = Get.find();

  String? _selectedPlatform;
  bool _isConnecting = false;

  final Map<String, Map<String, dynamic>> _platforms = {
    'facebook': {
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': const Color(0xFF1877F2),
      'description': 'الوصول إلى 2.9 مليار مستخدم',
    },
    'instagram': {
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'color': const Color(0xFFE4405F),
      'description': 'مشاركة الصور والقصص',
    },
    'twitter': {
      'name': 'Twitter/X',
      'icon': Icons.tag,
      'color': const Color(0xFF1DA1F2),
      'description': 'تحديثات فورية للعالم',
    },
    'linkedin': {
      'name': 'LinkedIn',
      'icon': Icons.work,
      'color': const Color(0xFF0077B5),
      'description': 'الشبكة المهنية',
    },
    'tiktok': {
      'name': 'TikTok',
      'icon': Icons.music_note,
      'color': const Color(0xFF000000),
      'description': 'فيديوهات قصيرة وإبداعية',
    },
    'youtube': {
      'name': 'YouTube',
      'icon': Icons.play_circle_filled,
      'color': const Color(0xFFFF0000),
      'description': 'منصة الفيديو الأولى',
    },
    'pinterest': {
      'name': 'Pinterest',
      'icon': Icons.push_pin,
      'color': const Color(0xFFE60023),
      'description': 'اكتشاف الأفكار',
    },
  };

  Future<void> _connectWithAyrshare(String platform) async {
    setState(() {
      _selectedPlatform = platform;
      _isConnecting = true;
    });

    try {
      final userId = _authService.currentUser.value?.id ?? '';

      // إنشاء JWT URL للـ Single Sign-On (Business Plan Workflow)
      final result = await _ayrshareService.generateJWT(userId: userId);

      if (result['success'] == true) {
        final jwtUrl = result['url'] as String;
        final profileKey = result['profile_key'] as String;

        // حفظ profile_key مؤقتاً
        await _saveProfileKey(platform, profileKey);

        // فتح رابط JWT في المتصفح لربط جميع الحسابات
        if (await canLaunch(jwtUrl)) {
          await launch(jwtUrl, forceSafariVC: false, forceWebView: false);

          Get.snackbar(
            'جارٍ الربط... ⏳',
            'سيتم فتح صفحة Ayrshare لربط حساباتك.\nاختر المنصات وارجع للتطبيق بعد الموافقة.',
            backgroundColor: AppColors.neonCyan.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
            icon: const Icon(Icons.flash_on, color: Colors.white),
          );

          // انتظار callback من Deep Link
          _waitForCallback(platform, profileKey);
        } else {
          throw Exception('لا يمكن فتح رابط JWT');
        }
      } else {
        throw Exception('فشل في إنشاء رابط JWT');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ ❌',
        'فشل ربط الحساب: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() {
        _isConnecting = false;
        _selectedPlatform = null;
      });
    }
  }

  Future<void> _saveProfileKey(String platform, String profileKey) async {
    // حفظ في SharedPreferences أو Hive للاستخدام عند العودة
    // يمكن استخدام SharedPreferencesService
  }

  Future<void> _waitForCallback(String platform, String profileKey) async {
    // هذه الدالة ستنتظر callback من Deep Link
    // عند العودة من OAuth، سيتم استدعاء Deep Link Handler
    // وسيتم حفظ الحساب المربوط
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ربط سريع مع Ayrshare',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.cyanPurpleGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات Ayrshare
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.neonCyan.withValues(alpha: 0.1),
                    AppColors.neonPurple.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.cyanPurpleGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ربط سريع وآمن',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'بنقرة واحدة، اربط جميع حساباتك',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لا حاجة لإنشاء تطبيقات OAuth معقدة',
                            style: TextStyle(
                              color: AppColors.textLight,
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

            const SizedBox(height: 30),

            // عنوان المنصات
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanPurpleGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'اختر المنصة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // قائمة المنصات
            ..._platforms.entries.map((entry) {
              final platform = entry.key;
              final info = entry.value;
              final isConnecting =
                  _isConnecting && _selectedPlatform == platform;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isConnecting || _isConnecting
                        ? null
                        : () => _connectWithAyrshare(platform),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (info['color'] as Color).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: info['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              info['icon'],
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  info['description'],
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isConnecting)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.neonCyan,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.arrow_forward_ios,
                              color: info['color'],
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            // ملاحظة أمان
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'جميع عمليات الربط آمنة ومشفرة عبر OAuth 2.0.\nنحن لا نخزن كلمات المرور أبداً.',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
