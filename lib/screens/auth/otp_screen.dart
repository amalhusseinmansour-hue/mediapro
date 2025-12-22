import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/otp_service.dart';
import '../../services/firestore_service.dart';
import '../dashboard/dashboard_screen.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String otpCode; // لعرضه في وضع التطوير

  const OTPScreen({super.key, required this.email, required this.otpCode});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpService = OTPService();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

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

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('الرجاء إدخال رمز التحقق كاملاً');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid = await _otpService.verifyOTP(otp);

      if (isValid && mounted) {
        await _otpService.setFirstLoginCompleted();

        // Update user login status in Firestore
        try {
          final firestoreService = Get.find<FirestoreService>();
          final userData = await _otpService.getLocalUserData();

          if (userData != null && userData['id'] != null) {
            // Update last login time in Firestore
            await firestoreService.updateUserLastLogin(userData['id']!);
            print('✅ تم تحديث آخر تسجيل دخول في Firestore بعد التحقق من OTP');

            // Also update user as logged in if UserModel exists
            final userModel = await firestoreService.getUserById(
              userData['id']!,
            );
            if (userModel != null) {
              final updatedUser = userModel.copyWith(
                isLoggedIn: true,
                isPhoneVerified: true,
              );
              await firestoreService.createOrUpdateUser(updatedUser);
              print('✅ تم تحديث حالة تسجيل الدخول للمستخدم في Firestore');
            }
          }
        } catch (e) {
          print('⚠️ لم يتم التحديث في Firestore: $e');
          // لا نعرض خطأ للمستخدم - الأهم أن OTP صحيح
        }

        Get.offAll(() => const DashboardScreen());
      } else if (mounted) {
        _showError('رمز التحقق غير صحيح أو منتهي الصلاحية');
        _clearOTP();
      }
    } catch (e) {
      if (mounted) {
        _showError('حدث خطأ: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    try {
      final newOTP = await _otpService.sendOTP(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال رمز جديد\nالرمز: $newOTP'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
        _clearOTP();
      }
    } catch (e) {
      if (mounted) {
        _showError('فشل إعادة الإرسال: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpControllers[index].text.isEmpty
              ? AppColors.border
              : AppColors.primaryPurple,
          width: 2,
        ),
        boxShadow: [
          if (_otpControllers[index].text.isNotEmpty)
            BoxShadow(
              color: AppColors.purpleShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
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
          color: AppColors.primaryPurple,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // التحقق التلقائي عند إدخال 6 أرقام
          if (index == 5 && value.isNotEmpty) {
            _verifyOTP();
          }

          setState(() {});
        },
      ),
    );
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
                  // Icon
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
                      Icons.security,
                      size: 60,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'التحقق برمز OTP',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'تم إرسال رمز التحقق إلى',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Form
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
                      children: [
                        Text(
                          'أدخل رمز التحقق',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),

                        // Development Mode: Show OTP Code
                        if (widget.otpCode.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryPurple,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الرمز: ${widget.otpCode}',
                                  style: const TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.otpCode.isNotEmpty)
                          const SizedBox(height: 16),

                        // OTP Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                            (index) => _buildOTPBox(index),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Verify Button
                        Container(
                          width: double.infinity,
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
                            onPressed: _isLoading ? null : _verifyOTP,
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
                        const SizedBox(height: 16),

                        // Resend Button
                        TextButton(
                          onPressed: _isResending ? null : _resendOTP,
                          child: _isResending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'إعادة إرسال الرمز',
                                  style: TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Back Button
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'رجوع',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
