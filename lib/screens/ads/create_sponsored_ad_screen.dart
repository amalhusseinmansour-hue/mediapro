import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sponsored_ad_model.dart';
import '../../services/sponsored_ads_service.dart';

class CreateSponsoredAdScreen extends StatefulWidget {
  const CreateSponsoredAdScreen({super.key});

  @override
  State<CreateSponsoredAdScreen> createState() =>
      _CreateSponsoredAdScreenState();
}

class _CreateSponsoredAdScreenState extends State<CreateSponsoredAdScreen> {
  final SponsoredAdsService _adsService = Get.find<SponsoredAdsService>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();

  AdType _selectedAdType = AdType.post;
  AdObjective _selectedObjective = AdObjective.awareness;
  final List<AdPlatform> _selectedPlatforms = [AdPlatform.facebook];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _websiteUrlController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    super.dispose();
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
            'إعلان ممول جديد',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 20),
            _buildAdTypeSelector(),
            const SizedBox(height: 20),
            _buildObjectiveSelector(),
            const SizedBox(height: 20),
            _buildPlatformsSelector(),
            const SizedBox(height: 20),
            _buildBudgetField(),
            const SizedBox(height: 20),
            _buildDurationField(),
            const SizedBox(height: 20),
            _buildWebsiteUrlField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: AppColors.neonCyan,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'سيتم مراجعة طلبك خلال 24-48 ساعة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عنوان الإعلان',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'أدخل عنواناً جذاباً لإعلانك',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال عنوان الإعلان';
            }
            if (value.trim().length < 5) {
              return 'العنوان يجب أن يكون 5 أحرف على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'وصف الإعلان',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white),
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'اشرح تفاصيل إعلانك والرسالة التي تود إيصالها...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال وصف الإعلان';
            }
            if (value.trim().length < 20) {
              return 'الوصف يجب أن يكون 20 حرف على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الإعلان',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AdType.values.map((type) {
            final isSelected = _selectedAdType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAdType = type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                  color: isSelected ? null : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan
                        : AppColors.neonCyan.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  _getAdTypeText(type),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildObjectiveSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'هدف الإعلان',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AdObjective.values.map((objective) {
            final isSelected = _selectedObjective == objective;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedObjective = objective;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                  color: isSelected ? null : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan
                        : AppColors.neonCyan.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  _getObjectiveText(objective),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlatformsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المنصات المستهدفة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AdPlatform.values.map((platform) {
            final isSelected = _selectedPlatforms.contains(platform);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedPlatforms.length > 1) {
                      _selectedPlatforms.remove(platform);
                    }
                  } else {
                    _selectedPlatforms.add(platform);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                  color: isSelected ? null : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan
                        : AppColors.neonCyan.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  SponsoredAdModel.getPlatformText(platform),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الميزانية (بالدولار)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _budgetController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '100',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.attach_money, color: AppColors.neonCyan),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال الميزانية';
            }
            final budget = double.tryParse(value);
            if (budget == null || budget < 10) {
              return 'الميزانية يجب أن تكون 10 دولار على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مدة الإعلان (بالأيام)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _durationController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '7',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.calendar_today, color: AppColors.neonCyan),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال مدة الإعلان';
            }
            final duration = int.tryParse(value);
            if (duration == null || duration < 1) {
              return 'المدة يجب أن تكون يوم واحد على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWebsiteUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'رابط الموقع (اختياري)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _websiteUrlController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'https://example.com',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.link, color: AppColors.neonCyan),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitAd,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonCyan,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'إرسال الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final ad = await _adsService.createAd(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      adType: _selectedAdType,
      platforms: _selectedPlatforms,
      objective: _selectedObjective,
      budget: double.parse(_budgetController.text.trim()),
      durationDays: int.parse(_durationController.text.trim()),
      websiteUrl: _websiteUrlController.text.trim().isNotEmpty
          ? _websiteUrlController.text.trim()
          : null,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (ad != null) {
      // محاكاة الموافقة (للاختبار فقط)
      _adsService.simulateApproval(ad.id);

      Get.back();
      Get.snackbar(
        'تم الإرسال',
        'تم إنشاء طلب الإعلان بنجاح. سنقوم بمراجعته قريباً',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الطلب',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  String _getAdTypeText(AdType type) {
    switch (type) {
      case AdType.post:
        return 'منشور';
      case AdType.story:
        return 'قصة';
      case AdType.video:
        return 'فيديو';
      case AdType.carousel:
        return 'دوار';
      case AdType.collection:
        return 'مجموعة';
    }
  }

  String _getObjectiveText(AdObjective objective) {
    switch (objective) {
      case AdObjective.awareness:
        return 'الوعي بالعلامة';
      case AdObjective.traffic:
        return 'زيادة الزيارات';
      case AdObjective.engagement:
        return 'التفاعل';
      case AdObjective.leads:
        return 'جذب العملاء';
      case AdObjective.sales:
        return 'المبيعات';
      case AdObjective.appInstalls:
        return 'تثبيت التطبيقات';
    }
  }
}
