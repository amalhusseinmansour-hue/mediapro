import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../core/constants/app_colors.dart';
import '../../services/phone_auth_service.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'dart:async';
import 'dart:ui' as ui;

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final _phoneAuthService = Get.find<PhoneAuthService>();
  final _authService = Get.find<AuthService>();

  String _completePhoneNumber = '';
  bool _isNewUser = false;
  bool _otpSent = false;
  int _resendTimer = 60;
  Timer? _timer;
  // تعيين السعودية كقيمة افتراضية، ثم محاولة اكتشاف الدولة
  String _initialCountryCode = 'SA';

  @override
  void initState() {
    super.initState();
    _getDeviceCountryCode();
  }

  // 🌍 الحصول على كود الدولة من إعدادات الجهاز
  void _getDeviceCountryCode() {
    try {
      // محاولة الحصول على locale الجهاز
      final locale = ui.PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode;

      if (countryCode != null && countryCode.isNotEmpty) {
        if (mounted) {
          setState(() {
            _initialCountryCode = countryCode;
          });
          print('🌍 Device country code detected: $countryCode');
        }
      } else {
        print('🌍 No country code detected, using SA as default');
      }
    } catch (e) {
      print('⚠️ Error detecting country code: $e, using SA as default');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _checkUserExists() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // التحقق من وجود المستخدم في Hive
      final hasUser = await _authService.hasExistingUser();

      if (hasUser) {
        final user = _authService.currentUser.value;
        if (user != null && user.phoneNumber == _completePhoneNumber) {
          // مستخدم موجود - تسجيل دخول
          setState(() => _isNewUser = false);
          await _sendOTP();
        } else {
          // رقم هاتف جديد - تسجيل
          setState(() => _isNewUser = true);
          // في وضع التجربة، اذهب مباشرة لإرسال OTP
          _phoneAuthService.userName.value = 'مستخدم تجريبي';
          _phoneAuthService.userEmail.value =
              '${_completePhoneNumber.replaceAll('+', '').replaceAll(' ', '')}@test.com';
          await _sendOTP();
        }
      } else {
        // مستخدم جديد - تسجيل
        setState(() => _isNewUser = true);
        // في وضع التجربة، اذهب مباشرة لإرسال OTP
        _phoneAuthService.userName.value = 'مستخدم تجريبي';
        _phoneAuthService.userEmail.value =
            '${_completePhoneNumber.replaceAll('+', '').replaceAll(' ', '')}@test.com';
        await _sendOTP();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error.withValues(alpha: 0.2),
        colorText: AppColors.error,
      );
    }
  }

  // TODO: User info dialog reserved for future registration flow
  /*
  void _showUserInfoDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'مستخدم جديد',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يرجى إدخال بياناتك لإنشاء حساب جديد',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
                Get.snackbar(
                  'تنبيه',
                  'يرجى إدخال جميع البيانات',
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              // حفظ البيانات في PhoneAuthService
              _phoneAuthService.userName.value = _nameController.text;
              _phoneAuthService.userEmail.value = _emailController.text;

              Get.back();
              _sendOTP();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }
  */

  Future<void> _sendOTP() async {
    try {
      final success = await _phoneAuthService.sendOTP(_completePhoneNumber);

      if (success) {
        setState(() {
          _otpSent = true;
        });
        _startResendTimer();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إرسال رمز التحقق',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error.withValues(alpha: 0.2),
        colorText: AppColors.error,
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال رمز التحقق',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      final userCredential = await _phoneAuthService.verifyOTP(
        _otpController.text,
      );

      if (userCredential != null) {
        // تسجيل دخول ناجح في Firebase
        await _authService.reloadUser();

        // الحصول على token من Backend
        final success = await _authService.loginWithPhone(
          phoneNumber: _completePhoneNumber,
        );

        if (success) {
          Get.snackbar(
            'نجح',
            _isNewUser ? 'تم إنشاء الحساب بنجاح' : 'تم تسجيل الدخول بنجاح',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.2),
            colorText: AppColors.primaryPurple,
          );

          // الانتقال إلى الشاشة الرئيسية
          Get.offAll(() => const DashboardScreen());
        } else {
          Get.snackbar(
            'خطأ',
            'فشل الاتصال بالخادم',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.error.withValues(alpha: 0.2),
            colorText: AppColors.error,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'رمز التحقق غير صحيح',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error.withValues(alpha: 0.2),
        colorText: AppColors.error,
      );
    }
  }

  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;

    await _phoneAuthService.resendOTP(_completePhoneNumber);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleShadow,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      size: 60,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    _otpSent ? 'التحقق من الهاتف' : 'تسجيل الدخول',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _otpSent
                        ? 'أدخل رمز التحقق المرسل إلى هاتفك'
                        : 'سجل دخولك باستخدام رقم هاتفك',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_otpSent) ...[
                            // Phone Number Field
                            IntlPhoneField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف',
                                hintText: 'يدعم جميع الدول 🌍',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              initialCountryCode: _initialCountryCode,
                              showCountryFlag: true,
                              showDropdownIcon: true,
                              searchText: 'البحث عن دولة...',
                              onChanged: (phone) {
                                _completePhoneNumber = phone.completeNumber;
                              },
                              validator: (phone) {
                                if (phone == null || phone.number.isEmpty) {
                                  return 'الرجاء إدخال رقم الهاتف';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Send OTP Button
                            Obx(
                              () => Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.purpleShadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _phoneAuthService.isLoading.value
                                      ? null
                                      : _checkUserExists,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _phoneAuthService.isLoading.value
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'إرسال رمز التحقق',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // OTP Field
                            TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                              decoration: InputDecoration(
                                labelText: 'رمز التحقق',
                                hintText: '000000',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline),
                              ),
                              maxLength: 6,
                            ),
                            const SizedBox(height: 16),

                            // Resend OTP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('لم تستلم الرمز؟ '),
                                TextButton(
                                  onPressed: _resendTimer > 0
                                      ? null
                                      : _resendOTP,
                                  child: Text(
                                    _resendTimer > 0
                                        ? 'إعادة الإرسال ($_resendTimer ث)'
                                        : 'إعادة الإرسال',
                                    style: TextStyle(
                                      color: _resendTimer > 0
                                          ? Colors.grey
                                          : AppColors.primaryPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Verify Button
                            Obx(
                              () => Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.purpleShadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _phoneAuthService.isLoading.value
                                      ? null
                                      : _verifyOTP,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _phoneAuthService.isLoading.value
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'تحقق',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Back Button
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _otpSent = false;
                                  _otpController.clear();
                                  _timer?.cancel();
                                });
                              },
                              child: const Text(
                                'تغيير رقم الهاتف',
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
}
