import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/phone_auth_service.dart';
import '../../services/auth_service.dart';

class RegistrationWithOTPScreen extends StatefulWidget {
  const RegistrationWithOTPScreen({super.key});

  @override
  State<RegistrationWithOTPScreen> createState() =>
      _RegistrationWithOTPScreenState();
}

class _RegistrationWithOTPScreenState extends State<RegistrationWithOTPScreen> {
  final PageController _pageController = PageController();
  final PhoneAuthService _phoneAuthService = Get.find<PhoneAuthService>();
  final AuthService _authService = Get.find<AuthService>();

  // Step 1: User Info
  final TextEditingController _nameController = TextEditingController();
  String _accountType = 'individual'; // 'individual' or 'business'

  // Step 2: Phone
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+966';

  // Step 3: OTP
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _currentStep = 0;
  bool _isLoading = false;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+966', 'country': 'السعودية', 'flag': '🇸🇦'},
    {'code': '+971', 'country': 'الإمارات', 'flag': '🇦🇪'},
    {'code': '+965', 'country': 'الكويت', 'flag': '🇰🇼'},
    {'code': '+973', 'country': 'البحرين', 'flag': '🇧🇭'},
    {'code': '+974', 'country': 'قطر', 'flag': '🇶🇦'},
    {'code': '+968', 'country': 'عمان', 'flag': '🇴🇲'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pageController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate name and account type
      if (_nameController.text.isEmpty) {
        Get.snackbar(
          'خطأ',
          'يرجى إدخال الاسم',
          backgroundColor: AppColors.error.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _currentStep = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1) {
      _sendOTP();
    } else if (_currentStep == 2) {
      _verifyOTP();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رقم الهاتف',
        backgroundColor: AppColors.error.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final phoneNumber = _selectedCountryCode + _phoneController.text;
    final success = await _phoneAuthService.sendOTP(phoneNumber);

    setState(() {
      _isLoading = false;
    });

    if (success && _phoneAuthService.codeSent.value) {
      setState(() {
        _currentStep = 2;
      });
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      Get.snackbar(
        'تم الإرسال',
        'تم إرسال رمز التحقق إلى هاتفك',
        backgroundColor: AppColors.success.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otpCode = _otpControllers.map((c) => c.text).join();

    if (otpCode.length != 6) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رمز التحقق كاملاً',
        backgroundColor: AppColors.error.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userCredential = await _phoneAuthService.verifyOTP(otpCode);

    if (userCredential != null) {
      // Create user account
      final phoneNumber = _selectedCountryCode + _phoneController.text;

      // Register user (this saves to backend and locally)
      await _authService.registerUser(
        name: _nameController.text,
        phoneNumber: phoneNumber,
        userType: _accountType,
      );

      // Mark user as logged in
      await _authService.loginUser();

      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'نجح',
        'تم إنشاء حسابك بنجاح!',
        backgroundColor: AppColors.success.withValues(alpha: 0.2),
        colorText: Colors.white,
      );

      // Navigate to dashboard
      Get.offAllNamed('/dashboard');
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                ),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Get.back(),
              ),
        title: Text(
          'إنشاء حساب جديد',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'البيانات'),
                Expanded(child: _buildStepLine(0)),
                _buildStepIndicator(1, 'الهاتف'),
                Expanded(child: _buildStepLine(1)),
                _buildStepIndicator(2, 'التحقق'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildUserInfoStep(),
                _buildPhoneStep(),
                _buildOTPStep(),
              ],
            ),
          ),

          // Next Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _currentStep == 2 ? 'تأكيد' : 'التالي',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: isActive || isCompleted
                ? AppColors.cyanPurpleGradient
                : null,
            color: isActive || isCompleted ? null : AppColors.darkCard,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isCompleted
                  ? Colors.transparent
                  : AppColors.darkBorder,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive || isCompleted
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted
                ? AppColors.neonCyan
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = step < _currentStep;

    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: isCompleted ? AppColors.cyanPurpleGradient : null,
        color: isCompleted ? null : AppColors.darkBorder,
      ),
    );
  }

  Widget _buildUserInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          const Text(
            'معلوماتك الأساسية',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'ابدأ بإدخال بياناتك الأساسية',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),

          // Name Field
          Text(
            'الاسم الكامل',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'أدخل اسمك الكامل',
                hintStyle: TextStyle(color: Color(0xFF666666)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Account Type
          Text(
            'نوع الحساب',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildAccountTypeCard(
                  'individual',
                  'حساب فردي',
                  Icons.person_outline,
                  'للأفراد والمستقلين',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccountTypeCard(
                  'business',
                  'حساب أعمال',
                  Icons.business_outlined,
                  'للشركات والفرق',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard(
    String type,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _accountType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _accountType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.cyanPurpleGradient : null,
          color: isSelected ? null : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.darkBorder,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'رقم الهاتف',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'سنرسل لك رمز تحقق على هذا الرقم',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),

          // Phone Input
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                // Country Code Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.darkCard,
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    items: _countryCodes.map((country) {
                      return DropdownMenuItem(
                        value: country['code'],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              country['flag']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  country['country']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  country['code']!,
                                  style: TextStyle(
                                    color: AppColors.neonCyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCountryCode = value;
                        });
                      }
                    },
                  ),
                ),

                // Phone Number
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: '5xxxxxxxx',
                      hintStyle: TextStyle(color: Color(0xFF666666)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'أدخل رمز التحقق',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'تم إرسال رمز مكون من 6 أرقام إلى\n${_selectedCountryCode}${_phoneController.text}',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // OTP Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 50,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _otpControllers[index].text.isNotEmpty
                          ? AppColors.neonCyan
                          : AppColors.darkBorder,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      setState(() {});
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
