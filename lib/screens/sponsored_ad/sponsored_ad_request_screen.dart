import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/sponsored_ad_service.dart';
import '../../models/sponsored_ad_request_model.dart';

class SponsoredAdRequestScreen extends StatefulWidget {
  const SponsoredAdRequestScreen({super.key});

  @override
  State<SponsoredAdRequestScreen> createState() =>
      _SponsoredAdRequestScreenState();
}

class _SponsoredAdRequestScreenState extends State<SponsoredAdRequestScreen> {
  final AuthService _authService = Get.find<AuthService>();
  final SponsoredAdService _sponsoredAdService = Get.put(SponsoredAdService());

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();
  final _adContentController = TextEditingController();

  String _selectedPlatform = 'facebook';
  String _selectedAdType = 'awareness';
  String _selectedCurrency = 'AED';
  DateTime? _selectedStartDate;
  bool _isSubmitting = false;

  // منصات الإعلانات
  final Map<String, String> _platforms = {
    'facebook': 'فيسبوك',
    'instagram': 'إنستغرام',
    'google': 'جوجل',
    'tiktok': 'تيك توك',
    'twitter': 'تويتر (X)',
    'linkedin': 'لينكد إن',
    'snapchat': 'سناب شات',
    'multiple': 'عدة منصات',
  };

  // أنواع الحملات الإعلانية
  final Map<String, String> _adTypes = {
    'awareness': 'زيادة الوعي بالعلامة التجارية',
    'traffic': 'زيادة الزيارات للموقع',
    'engagement': 'زيادة التفاعل والمشاركة',
    'leads': 'جمع بيانات العملاء المحتملين',
    'sales': 'زيادة المبيعات والتحويلات',
    'app_installs': 'تثبيت التطبيق',
  };

  // العملات
  final List<String> _currencies = ['AED', 'SAR', 'USD', 'EUR'];

  @override
  void initState() {
    super.initState();
    // ملء البيانات من حساب المستخدم
    final user = _authService.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _targetAudienceController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    _adContentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonCyan,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // إنشاء نموذج الطلب
      final request = SponsoredAdRequestModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        companyName: _companyNameController.text.trim().isNotEmpty
            ? _companyNameController.text.trim()
            : null,
        adPlatform: _selectedPlatform,
        adType: _selectedAdType,
        targetAudience: _targetAudienceController.text.trim(),
        budget: double.parse(_budgetController.text.trim()),
        currency: _selectedCurrency,
        durationDays: _durationController.text.trim().isNotEmpty
            ? int.parse(_durationController.text.trim())
            : null,
        startDate: _selectedStartDate,
        adContent: _adContentController.text.trim().isNotEmpty
            ? _adContentController.text.trim()
            : null,
      );

      // إرسال الطلب إلى الـ Backend
      final success = await _sponsoredAdService.submitRequest(request);

      if (mounted) {
        if (success) {
          // نجح الإرسال - تم الحفظ في قاعدة البيانات
          Get.back();
          Get.snackbar(
            'تم الإرسال بنجاح',
            'تم حفظ طلب الإعلان الممول في قاعدة البيانات. سيتم التواصل معك قريباً',
            backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.check_circle, color: AppColors.neonCyan),
            duration: const Duration(seconds: 4),
          );
        } else {
          throw Exception('فشل حفظ الطلب في قاعدة البيانات');
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء إرسال الطلب: ${e.toString()}',
          backgroundColor: Colors.red.withValues(alpha: 0.2),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'طلب إعلان ممول',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // رسالة ترحيبية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonCyan.withValues(alpha: 0.1),
                    AppColors.neonPurple.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.campaign, color: AppColors.neonCyan, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أطلق حملتك الإعلانية الآن وزد مبيعاتك!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // معلومات العميل
            _buildSectionTitle('معلومات العميل'),
            _buildTextField(
              controller: _nameController,
              label: 'الاسم الكامل',
              icon: Icons.person,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الرجاء إدخال الاسم' : null,
            ),
            _buildTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'الرجاء إدخال البريد';
                if (!GetUtils.isEmail(value!)) return 'بريد إلكتروني غير صحيح';
                return null;
              },
            ),
            _buildTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'الرجاء إدخال رقم الهاتف' : null,
            ),
            _buildTextField(
              controller: _companyNameController,
              label: 'اسم الشركة (اختياري)',
              icon: Icons.business,
            ),

            const SizedBox(height: 24),

            // تفاصيل الحملة الإعلانية
            _buildSectionTitle('تفاصيل الحملة الإعلانية'),
            _buildDropdown(
              label: 'منصة الإعلان',
              value: _selectedPlatform,
              items: _platforms,
              onChanged: (value) {
                setState(() {
                  _selectedPlatform = value!;
                });
              },
            ),
            _buildDropdown(
              label: 'هدف الحملة',
              value: _selectedAdType,
              items: _adTypes,
              onChanged: (value) {
                setState(() {
                  _selectedAdType = value!;
                });
              },
            ),
            _buildTextField(
              controller: _targetAudienceController,
              label: 'الجمهور المستهدف',
              icon: Icons.group,
              maxLines: 3,
              hint: 'مثال: رجال ونساء، 25-45 سنة، مهتمون بالتقنية...',
              validator: (value) => value?.isEmpty ?? true
                  ? 'الرجاء تحديد الجمهور المستهدف'
                  : null,
            ),

            const SizedBox(height: 24),

            // الميزانية والمدة
            _buildSectionTitle('الميزانية والمدة'),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _budgetController,
                    label: 'الميزانية',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'الرجاء إدخال الميزانية';
                      if (double.tryParse(value!) == null)
                        return 'رقم غير صحيح';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 1, child: _buildCurrencyDropdown()),
              ],
            ),
            _buildTextField(
              controller: _durationController,
              label: 'مدة الحملة بالأيام (اختياري)',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
              hint: 'مثال: 30',
            ),
            _buildDatePicker(),

            const SizedBox(height: 24),

            // محتوى الإعلان
            _buildSectionTitle('محتوى الإعلان (اختياري)'),
            _buildTextField(
              controller: _adContentController,
              label: 'تفاصيل ووصف محتوى الإعلان',
              icon: Icons.description,
              maxLines: 5,
              hint: 'اكتب نص الإعلان، الرسالة، أو أي تفاصيل إضافية...',
            ),

            const SizedBox(height: 32),

            // زر الإرسال
            _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.neonCyan),
                  )
                : ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.neonCyan.withValues(alpha: 0.5),
                    ),
                    child: const Text(
                      'إرسال الطلب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.neonCyan,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.neonCyan),
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
          ),
        ),
        dropdownColor: const Color(0xFF1A1A2E),
        style: const TextStyle(color: Colors.white),
        items: items.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCurrency,
      decoration: InputDecoration(
        labelText: 'العملة',
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
        ),
      ),
      dropdownColor: const Color(0xFF1A1A2E),
      style: const TextStyle(color: Colors.white),
      items: _currencies.map((currency) {
        return DropdownMenuItem<String>(value: currency, child: Text(currency));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCurrency = value!;
        });
      },
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event, color: AppColors.neonCyan),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedStartDate != null
                      ? 'تاريخ البدء: ${DateFormat('yyyy-MM-dd').format(_selectedStartDate!)}'
                      : 'اختر تاريخ بدء الحملة (اختياري)',
                  style: TextStyle(
                    color: _selectedStartDate != null
                        ? Colors.white
                        : Colors.grey[400],
                  ),
                ),
              ),
              if (_selectedStartDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedStartDate = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
