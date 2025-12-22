import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../services/firebase_phone_auth_service.dart';
import '../../core/constants/app_colors.dart';

class FirebaseOTPScreen extends StatefulWidget {
  final String phoneNumber;

  const FirebaseOTPScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<FirebaseOTPScreen> createState() => _FirebaseOTPScreenState();
}

class _FirebaseOTPScreenState extends State<FirebaseOTPScreen> {
  late FirebasePhoneAuthService _phoneAuthService;
  late TextEditingController _otpController;
  late FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();
    _phoneAuthService = Get.find<FirebasePhoneAuthService>();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 40),

              // Phone Number Display
              _buildPhoneDisplay(),
              const SizedBox(height: 30),

              // OTP Input
              _buildOTPInput(),
              const SizedBox(height: 20),

              // Timer
              if (_phoneAuthService.codeSent.value) _buildTimer(),
              const SizedBox(height: 30),

              // Verify Button
              _buildVerifyButton(),
              const SizedBox(height: 20),

              // Resend Button
              if (_phoneAuthService.codeSent.value) _buildResendButton(),

              // Error Message
              if (_phoneAuthService.errorMessage.isNotEmpty)
                _buildErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
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
          child: Icon(Icons.lock_outline, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          'تحقق من رقم هاتفك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'سيتم إرسال رمز التحقق إلى رقمك',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPhoneDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone, color: AppColors.neonCyan),
          const SizedBox(width: 10),
          Text(
            widget.phoneNumber,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رمز التحقق',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        PinCodeTextField(
          appContext: context,
          length: 6,
          obscureText: false,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 50,
            fieldWidth: 45,
            activeFillColor: AppColors.darkBg,
            inactiveFillColor: AppColors.darkBg,
            selectedFillColor: AppColors.darkBg,
            activeColor: AppColors.neonCyan,
            inactiveColor: AppColors.neonCyan.withValues(alpha: 0.3),
            selectedColor: AppColors.neonPurple,
          ),
          animationDuration: const Duration(milliseconds: 300),
          backgroundColor: Colors.transparent,
          enableActiveFill: true,
          controller: _otpController,
          onChanged: (String value) {},
          beforeTextPaste: (text) {
            return text?.length == 6;
          },
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (_phoneAuthService.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _phoneAuthService.errorMessage.value,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTimer() {
    return Obx(() {
      final isExpired = _phoneAuthService.isCodeExpired.value;
      final seconds = _phoneAuthService.remainingSeconds.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              color: isExpired ? Colors.red : AppColors.neonCyan,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isExpired
                  ? 'انتهت صلاحية الرمز'
                  : 'سينتهي الرمز في: ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isExpired ? Colors.red : AppColors.neonCyan,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVerifyButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _phoneAuthService.isLoading.value
                ? [Colors.grey, Colors.grey]
                : [AppColors.neonCyan, AppColors.neonPurple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _phoneAuthService.isLoading.value ? null : _handleVerifyOTP,
            borderRadius: BorderRadius.circular(12),
            child: _phoneAuthService.isLoading.value
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'تحقق من الرمز',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Obx(() {
      final canResend = _phoneAuthService.getOTPStatus()['canResend'] as bool;

      return Center(
        child: Column(
          children: [
            Text(
              'لم تستقبل الرمز؟',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: canResend ? _handleResendOTP : null,
              child: Text(
                'إعادة الإرسال',
                style: TextStyle(
                  color: canResend ? AppColors.neonCyan : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _phoneAuthService.errorMessage.value,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _phoneAuthService.errorMessage.value = 'الرجاء إدخال رمز من 6 أرقام';
      return;
    }

    try {
      final credential = await _phoneAuthService.verifyOTP(_otpController.text);

      if (credential != null && mounted) {
        // نجح التحقق
        Get.snackbar(
          'نجح',
          'تم التحقق من الهاتف بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // الذهاب إلى الشاشة التالية
        Future.delayed(Duration(seconds: 1), () {
          Get.offNamed('/dashboard');
        });
      }
    } catch (e) {
      print('❌ خطأ في التحقق: $e');
    }
  }

  Future<void> _handleResendOTP() async {
    try {
      _otpController.clear();
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
        'فشل في إعادة الإرسال: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
