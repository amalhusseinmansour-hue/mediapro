import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/business_verification_service.dart';
import '../../services/auth_service.dart';

/// صفحة رفع المستندات التجارية للتحقق من حساب الشركة
class BusinessVerificationScreen extends StatefulWidget {
  const BusinessVerificationScreen({super.key});

  @override
  State<BusinessVerificationScreen> createState() => _BusinessVerificationScreenState();
}

class _BusinessVerificationScreenState extends State<BusinessVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _imagePicker = ImagePicker();

  late BusinessVerificationService _verificationService;
  late AuthService _authService;

  File? _commercialRegistrationFile;
  File? _tradeLicenseFile;

  String? _commercialRegistrationUrl;
  String? _tradeLicenseUrl;

  bool _isLoading = false;
  bool _isUploading = false;
  String _uploadingDocument = '';

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  void _initServices() {
    try {
      _verificationService = Get.find<BusinessVerificationService>();
    } catch (e) {
      _verificationService = Get.put(BusinessVerificationService());
    }

    try {
      _authService = Get.find<AuthService>();
    } catch (e) {
      _authService = Get.put(AuthService());
    }

    // تعبئة اسم الشركة إذا كان موجوداً
    final user = _authService.currentUser.value;
    if (user?.companyName != null) {
      _companyNameController.text = user!.companyName!;
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String documentType) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (documentType == 'commercial_registration') {
            _commercialRegistrationFile = File(pickedFile.path);
          } else {
            _tradeLicenseFile = File(pickedFile.path);
          }
        });

        // رفع المستند تلقائياً
        await _uploadDocument(documentType);
      }
    } catch (e) {
      _showError('فشل اختيار الصورة: $e');
    }
  }

  Future<void> _uploadDocument(String documentType) async {
    final file = documentType == 'commercial_registration'
        ? _commercialRegistrationFile
        : _tradeLicenseFile;

    if (file == null) return;

    setState(() {
      _isUploading = true;
      _uploadingDocument = documentType;
    });

    try {
      String? url;
      if (documentType == 'commercial_registration') {
        url = await _verificationService.uploadCommercialRegistration(file);
        if (url != null) {
          setState(() => _commercialRegistrationUrl = url);
        }
      } else {
        url = await _verificationService.uploadTradeLicense(file);
        if (url != null) {
          setState(() => _tradeLicenseUrl = url);
        }
      }

      if (url == null) {
        _showError(_verificationService.errorMessage.value);
      } else {
        _showSuccess('تم رفع المستند بنجاح');
      }
    } finally {
      setState(() {
        _isUploading = false;
        _uploadingDocument = '';
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_commercialRegistrationUrl == null) {
      _showError('يرجى رفع صورة السجل التجاري');
      return;
    }

    if (_tradeLicenseUrl == null) {
      _showError('يرجى رفع صورة الرخصة التجارية');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _verificationService.submitVerificationRequest(
        companyName: _companyNameController.text.trim(),
        commercialRegistrationUrl: _commercialRegistrationUrl!,
        tradeLicenseUrl: _tradeLicenseUrl!,
      );

      if (result['success'] == true) {
        _showSuccess(result['message'] ?? 'تم تقديم طلب التحقق بنجاح');
        // الانتظار قليلاً ثم العودة
        await Future.delayed(const Duration(seconds: 2));
        Get.back(result: true);
      } else {
        _showError(result['message'] ?? 'فشل تقديم طلب التحقق');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من حساب الشركة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'تفعيل حساب الشركة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يرجى رفع المستندات المطلوبة للتحقق من حسابك',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Company Name Field
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'اسم الشركة',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الشركة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Commercial Registration
              _buildDocumentUploadCard(
                title: 'السجل التجاري',
                subtitle: 'صورة واضحة من السجل التجاري الساري',
                icon: Icons.description,
                file: _commercialRegistrationFile,
                url: _commercialRegistrationUrl,
                documentType: 'commercial_registration',
              ),
              const SizedBox(height: 16),

              // Trade License
              _buildDocumentUploadCard(
                title: 'الرخصة التجارية',
                subtitle: 'صورة واضحة من الرخصة التجارية السارية',
                icon: Icons.card_membership,
                file: _tradeLicenseFile,
                url: _tradeLicenseUrl,
                documentType: 'trade_license',
              ),
              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'سيتم مراجعة المستندات خلال 24-48 ساعة عمل',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
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
                  onPressed: _isLoading ? null : _submitVerification,
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
                          'تقديم طلب التحقق',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required String? url,
    required String documentType,
  }) {
    final isUploading = _isUploading && _uploadingDocument == documentType;
    final isUploaded = url != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded
              ? Colors.green
              : (file != null ? AppColors.primaryPurple : AppColors.border),
          width: isUploaded || file != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle : icon,
                  color: isUploaded ? Colors.green : AppColors.primaryPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUploaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'تم الرفع',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview or Upload Button
          if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.file(
                    file,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (isUploading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            InkWell(
              onTap: () => _pickImage(documentType),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 36,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط لاختيار صورة',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Change Image Button
          if (file != null && !isUploading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(documentType),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('تغيير الصورة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryPurple,
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
}
