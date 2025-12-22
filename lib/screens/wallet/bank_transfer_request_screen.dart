import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/laravel_api_service.dart';
import '../../services/auth_service.dart';

class BankTransferRequestScreen extends StatefulWidget {
  final double? suggestedAmount;

  const BankTransferRequestScreen({super.key, this.suggestedAmount});

  @override
  State<BankTransferRequestScreen> createState() =>
      _BankTransferRequestScreenState();
}

class _BankTransferRequestScreenState extends State<BankTransferRequestScreen> {
  final LaravelApiService _apiService = Get.find<LaravelApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _transferRefController = TextEditingController();

  // TODO: Receipt image upload reserved for future implementation
  // File? _receiptImage;
  bool _isLoading = false;
  Map<String, dynamic>? _bankInfo;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedAmount != null) {
      _amountController.text = widget.suggestedAmount!.toStringAsFixed(0);
    }
    _fetchBankInfo();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _senderNameController.dispose();
    _transferRefController.dispose();
    super.dispose();
  }

  Future<void> _fetchBankInfo() async {
    try {
      final result = await _apiService.get('/bank-account-info');
      if (result['success'] == true && result['bank_account'] != null) {
        setState(() {
          _bankInfo = result['bank_account'];
        });
      }
    } catch (e) {
      print('❌ Error fetching bank info: $e');
    }
  }

  // TODO: Image picker functionality reserved for future implementation
  /*
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _receiptImage = File(image.path);
      });
    }
  }
  */

  Future<void> _submitRequest() async {
    // Validate inputs
    if (_amountController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال المبلغ المحول',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    if (_senderNameController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال اسم المحول',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    if (_transferRefController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال رقم التحويل المرجعي',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال مبلغ صحيح',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser.value?.id ?? 'guest';

      // Prepare request data
      final requestData = {
        'user_id': userId,
        'amount': amount,
        'sender_name': _senderNameController.text.trim(),
        'transfer_reference': _transferRefController.text.trim(),
        'notes': _notesController.text.trim(),
        'status': 'pending',
      };

      // Submit the request
      final result = await _apiService.post(
        '/bank-transfer-requests',
        requestData,
      );

      if (result['success'] == true) {
        Get.back();
        Get.snackbar(
          'نجح',
          'تم إرسال طلب التحويل بنجاح. سيتم مراجعته خلال 24 ساعة.',
          backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.check_circle, color: AppColors.neonCyan),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'خطأ',
          result['message'] ?? 'فشل إرسال الطلب',
          backgroundColor: Colors.red.withValues(alpha: 0.2),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } catch (e) {
      print('❌ Error submitting bank transfer request: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إرسال الطلب. الرجاء المحاولة مرة أخرى',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
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
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'طلب تحويل بنكي',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonCyan),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInstructionsCard(),
          const SizedBox(height: 24),
          if (_bankInfo != null) _buildBankInfoCard(),
          const SizedBox(height: 24),
          _buildForm(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient.scale(0.3),
        borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: AppColors.neonCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'تعليمات التحويل البنكي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '1. قم بتحويل المبلغ المطلوب إلى الحساب البنكي أدناه\n'
            '2. احتفظ بإيصال التحويل\n'
            '3. املأ النموذج أدناه بمعلومات التحويل\n'
            '4. سيتم مراجعة الطلب خلال 24 ساعة\n'
            '5. سيتم إضافة الرصيد بعد التحقق من التحويل',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleMagentaGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'معلومات الحساب البنكي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('اسم البنك:', _bankInfo!['bank_name'] ?? ''),
          _buildInfoRow('اسم صاحب الحساب:', _bankInfo!['account_holder'] ?? ''),
          _buildInfoRow('رقم الحساب:', _bankInfo!['account_number'] ?? ''),
          _buildInfoRow('الآيبان:', _bankInfo!['iban'] ?? ''),
          if (_bankInfo!['swift_code'] != null)
            _buildInfoRow('Swift Code:', _bankInfo!['swift_code'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                // Copy to clipboard functionality could be added here
              },
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات التحويل',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _amountController,
          label: 'المبلغ المحول (درهم)',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _senderNameController,
          label: 'اسم المحول (كما في الإيصال)',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _transferRefController,
          label: 'رقم التحويل المرجعي',
          icon: Icons.numbers,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _notesController,
          label: 'ملاحظات (اختياري)',
          icon: Icons.note,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.neonCyan),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'إرسال الطلب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
