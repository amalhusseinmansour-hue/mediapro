import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/firebase_phone_auth_service.dart';
import '../../core/constants/app_colors.dart';

/// شاشة التسجيل برقم الهاتف باستخدام Firebase OTP
class PhoneRegistrationScreen extends StatefulWidget {
  const PhoneRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PhoneRegistrationScreen> createState() =>
      _PhoneRegistrationScreenState();
}

class _PhoneRegistrationScreenState extends State<PhoneRegistrationScreen> {
  final _phoneController = TextEditingController();
  final _phoneAuthService = Get.find<FirebasePhoneAuthService>();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() => _errorMessage = 'الرجاء إدخال رقم الهاتف');
      return;
    }

    if (!_isValidPhoneNumber(phone)) {
      setState(() => _errorMessage = 'رقم الهاتف غير صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // إضافة + في البداية إذا لم تكن موجودة
      String phoneNumber = phone.startsWith('+') ? phone : '+$phone';

      // إرسال OTP
      await _phoneAuthService.sendOTP(phoneNumber);

      if (mounted) {
        // الانتقال لشاشة التحقق
        Get.to(() => FirebaseOTPVerificationScreen(phoneNumber: phoneNumber));
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isValidPhoneNumber(String phone) {
    // إزالة الأحرف غير الرقمية
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // التحقق من الطول (يجب أن يكون بين 10 و15 رقم)
    return cleanPhone.replaceAll('+', '').length >= 10 &&
        cleanPhone.replaceAll('+', '').length <= 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

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
                    size: 50,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'التسجيل برقم الهاتف',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تسجيل سريع وآمن عبر OTP',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form Container
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'رقم الهاتف',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),

                      // Phone Input Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '+966501234567',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabled: !_isLoading,
                        ),
                        onChanged: (_) {
                          if (_errorMessage.isNotEmpty) {
                            setState(() => _errorMessage = '');
                          }
                        },
                      ),
                      const SizedBox(height: 8),

                      // Helper Text
                      Text(
                        'أدخل رقمك برمز الدولة (مثل: +966)',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),

                      // Error Message
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Send OTP Button
                      Container(
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
                          onPressed: _isLoading ? null : _handleSendOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'إرسال رمز التحقق',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟ ',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// شاشة التحقق من OTP بعد إرسال الرمز
class FirebaseOTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const FirebaseOTPVerificationScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<FirebaseOTPVerificationScreen> createState() =>
      _FirebaseOTPVerificationScreenState();
}

class _FirebaseOTPVerificationScreenState
    extends State<FirebaseOTPVerificationScreen> {
  late FirebasePhoneAuthService _phoneAuthService;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _phoneAuthService = Get.find<FirebasePhoneAuthService>();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleOTPInput(String value, int index) {
    if (value.isNotEmpty && value != _otpControllers[index].text) {
      if (RegExp(r'^[0-9]$').hasMatch(value)) {
        if (index < 5) {
          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
        }
      }
    }
  }

  String _getOTP() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _handleVerifyOTP() async {
    final otp = _getOTP();

    if (otp.length != 6) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال رمز من 6 أرقام',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final credential = await _phoneAuthService.verifyOTP(otp);

      if (credential != null && mounted) {
        Get.snackbar(
          'نجح',
          'تم التحقق من الهاتف بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Future.delayed(const Duration(seconds: 1), () {
          Get.offAllNamed('/dashboard');
        });
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل التحقق: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleResendOTP() async {
    try {
      // مسح الحقول
      for (var controller in _otpControllers) {
        controller.clear();
      }

      await _phoneAuthService.resendOTP(widget.phoneNumber);

      Get.snackbar(
        'تم',
        'تم إعادة إرسال الرمز',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إعادة الإرسال',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Header
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.neonCyan, AppColors.neonPurple],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'تحقق من الرمز',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل رمز التحقق المرسل إلى ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Input Fields
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'رمز التحقق',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                counterText: '',
                              ),
                              onChanged: (value) {
                                _handleOTPInput(value, index);
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Timer
                      Obx(() {
                        final seconds =
                            _phoneAuthService.remainingSeconds.value;
                        final isExpired = _phoneAuthService.isCodeExpired.value;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isExpired
                                ? Colors.red.withValues(alpha: 0.1)
                                : AppColors.neonCyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isExpired
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : AppColors.neonCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isExpired ? Icons.close : Icons.timer,
                                color: isExpired
                                    ? Colors.red
                                    : AppColors.neonCyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isExpired
                                    ? 'انتهت صلاحية الرمز'
                                    : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isExpired
                                      ? Colors.red
                                      : AppColors.neonCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

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
                                : _handleVerifyOTP,
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
                                    'تحقق من الرمز',
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

                      // Resend Button
                      Obx(() {
                        final canResend =
                            _phoneAuthService.getOTPStatus()['canResend']
                                as bool;

                        return TextButton(
                          onPressed: canResend ? _handleResendOTP : null,
                          child: Text(
                            'إعادة إرسال الرمز',
                            style: TextStyle(
                              color: canResend
                                  ? AppColors.primaryPurple
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
