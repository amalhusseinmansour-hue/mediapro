import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/dependency_helper.dart';
import '../../core/utils/error_handler.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../services/phone_auth_service.dart';
import '../../services/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  PhoneAuthService? _phoneAuthService;
  AuthService? _authService;

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize services safely
    _phoneAuthService = DependencyHelper.tryFind<PhoneAuthService>();
    _authService = DependencyHelper.tryFind<AuthService>();

    if (_phoneAuthService == null || _authService == null) {
      DependencyHelper.showDependencyError('خدمة المصادقة');
    }

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ErrorHandler.showError('يرجى إدخال رمز التحقق كاملاً');
      return;
    }

    // Check if services are available
    if (_phoneAuthService == null || _authService == null) {
      ErrorHandler.showError('خدمة المصادقة غير متوفرة');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ErrorHandler.handleAsync<bool>(
      () async {
        // محاولة التحقق من OTP
        final userCredential = await _phoneAuthService!.verifyOTP(otp);

        // في وضع الاختبار، userCredential يكون null لكن المستخدم محفوظ في Hive
        // نتحقق من AuthService لمعرفة إذا تم تسجيل الدخول
        await _authService!.reloadUser();

        if (_authService!.isAuthenticated.value) {
          return true;
        } else if (userCredential != null && userCredential.user != null) {
          final phoneNumber = widget.phoneNumber;
          final loginSuccess = await _authService!.loginWithPhone(
            phoneNumber: phoneNumber,
          );

          if (loginSuccess) {
            return true;
          } else {
            ErrorHandler.showError('فشل تسجيل الدخول');
            return false;
          }
        } else {
          ErrorHandler.showError('رمز التحقق غير صحيح');
          return false;
        }
      },
      errorMessage: 'فشل التحقق من الرمز',
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success == true && mounted) {
      Get.back(); // Close OTP screen
      Get.back(); // Close Phone Auth screen
      ErrorHandler.showSuccess('تم تسجيل الدخول بنجاح');
    }
  }

  void _resendOTP() async {
    if (!_canResend) return;

    // Check if service is available
    if (_phoneAuthService == null) {
      ErrorHandler.showError('خدمة المصادقة غير متوفرة');
      return;
    }

    await ErrorHandler.handleAsync(
      () async {
        await _phoneAuthService!.resendOTP(widget.phoneNumber);
        _startTimer();
        ErrorHandler.showInfo('تم إرسال رمز جديد');
      },
      errorMessage: 'فشل إعادة إرسال الرمز',
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'جاري التحقق...',
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleMagentaGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPurple.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sms_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Title
            const Text(
              'تأكيد رقم الهاتف',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'تم إرسال رمز التحقق إلى\n'),
                  TextSpan(
                    text: widget.phoneNumber,
                    style: TextStyle(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // OTP Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _buildOTPBox(index);
              }),
            ),

            const SizedBox(height: 32),

            // Verify Button
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.purpleMagentaGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPurple.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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

            const SizedBox(height: 24),

            // Resend Code
            Center(
              child: _canResend
                  ? TextButton(
                      onPressed: _resendOTP,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: AppColors.neonCyan,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إعادة إرسال الرمز',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.neonCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      'يمكنك إعادة الإرسال بعد $_remainingSeconds ثانية',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),

            const SizedBox(height: 32),

            // Info Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.neonPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'أدخل رمز التحقق المكون من 6 أرقام الذي تم إرساله إلى هاتفك',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
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
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? AppColors.neonPurple
              : AppColors.textSecondary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: _otpControllers[index].text.isNotEmpty
            ? [
                BoxShadow(
                  color: AppColors.neonPurple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          setState(() {});

          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-verify when all fields are filled
          if (index == 5 && value.isNotEmpty) {
            final allFilled = _otpControllers.every((c) => c.text.isNotEmpty);
            if (allFilled) {
              _verifyOTP();
            }
          }
        },
      ),
    );
  }
}
