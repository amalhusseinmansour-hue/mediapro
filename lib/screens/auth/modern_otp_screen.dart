import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class ModernOTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String userType;

  const ModernOTPScreen({
    super.key,
    required this.phoneNumber,
    required this.name,
    required this.userType,
  });

  @override
  State<ModernOTPScreen> createState() => _ModernOTPScreenState();
}

class _ModernOTPScreenState extends State<ModernOTPScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _startResendTimer();

    // Auto-focus first field
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('الرجاء إدخال رمز التحقق كاملاً');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📲 Verifying OTP: $otp');

      // Simulate verification
      await Future.delayed(const Duration(seconds: 1));

      // Get AuthService
      final authService = Get.find<AuthService>();

      // Register/Login user
      print('📝 Registering user: ${widget.name}, Phone: ${widget.phoneNumber}');
      final user = await authService.registerUser(
        name: widget.name,
        phoneNumber: widget.phoneNumber,
        userType: widget.userType,
      );

      print('✅ User registered successfully: ${user.id}');

      // Update login status
      await authService.loginUser();
      print('✅ User logged in successfully');

      if (mounted) {
        setState(() => _isLoading = false);

        // Navigate to dashboard
        Get.offAll(
          () => const DashboardScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 600),
        );
      }
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('حدث خطأ أثناء التحقق. الرجاء المحاولة مرة أخرى');
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;

    // Simulate resending
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إرسال رمز جديد'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    _startResendTimer();
    _clearOTP();
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Animated icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.cyanPurpleGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sms_outlined,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.cyanPurpleGradient.createShader(bounds),
                  child: const Text(
                    'التحقق من الرمز',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'أدخل الرمز المرسل إلى\n'),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Input Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => _buildOTPBox(index),
                  ),
                ),
                const SizedBox(height: 40),

                // Verify Button
                _buildNeonButton(),
                const SizedBox(height: 24),

                // Resend Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لم يصلك الرمز؟  ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_resendTimer > 0)
                      Text(
                        '($_resendTimer ثانية)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _resendOTP,
                        child: const Text(
                          'إعادة إرسال',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.neonCyan,
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

  Widget _buildOTPBox(int index) {
    final hasValue = _otpControllers[index].text.isNotEmpty;

    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue ? AppColors.neonCyan : AppColors.darkBorder,
          width: hasValue ? 2 : 1,
        ),
        boxShadow: hasValue
            ? [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.neonCyan,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {});

          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto verify when all 6 digits are entered
          if (index == 5 && value.isNotEmpty) {
            final otp = _otpControllers.map((c) => c.text).join();
            if (otp.length == 6) {
              _verifyOTP();
            }
          }
        },
      ),
    );
  }

  Widget _buildNeonButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تحقق',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}
