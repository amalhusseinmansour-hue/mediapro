import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sponsored_ad_model.dart';
import '../../services/sponsored_ads_service.dart';

class AdReviewDialog extends StatefulWidget {
  final SponsoredAdModel ad;

  const AdReviewDialog({super.key, required this.ad});

  @override
  State<AdReviewDialog> createState() => _AdReviewDialogState();
}

class _AdReviewDialogState extends State<AdReviewDialog> {
  final SponsoredAdsService _adsService = Get.find<SponsoredAdsService>();
  final _noteController = TextEditingController();
  AdStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ad.status;
    _noteController.text = widget.ad.adminNote ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildAdInfo(),
                  const SizedBox(height: 20),
                  _buildPlatforms(),
                  const SizedBox(height: 20),
                  _buildStatusSelector(),
                  const SizedBox(height: 20),
                  _buildAdminNoteField(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.rate_review_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'مراجعة الإعلان',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAdInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.ad.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.ad.description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoChip(
              label: 'النوع',
              value: widget.ad.adTypeText,
              color: AppColors.neonPurple,
            ),
            const SizedBox(width: 8),
            _buildInfoChip(
              label: 'الهدف',
              value: widget.ad.objectiveText,
              color: AppColors.neonCyan,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(
              label: 'الميزانية',
              value: '\$${widget.ad.budget.toStringAsFixed(0)}',
              color: const Color(0xFF00E676),
            ),
            const SizedBox(width: 8),
            _buildInfoChip(
              label: 'المدة',
              value: '${widget.ad.durationDays} ${widget.ad.durationDays == 1 ? "يوم" : "أيام"}',
              color: AppColors.neonMagenta,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'تاريخ الإنشاء: ${DateFormat('yyyy/MM/dd - HH:mm').format(widget.ad.createdAt)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatforms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المنصات المستهدفة:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.ad.platforms.map((platform) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                SponsoredAdModel.getPlatformText(platform),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تحديث حالة الإعلان:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AdStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.cyanPurpleGradient : null,
                  color: isSelected ? null : AppColors.darkBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan
                        : AppColors.neonCyan.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildAdminNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملاحظة للمستخدم:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أضف ملاحظة للمستخدم...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.darkBg,
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
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBg,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
              ),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حفظ التغييرات',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (_selectedStatus == null) return;

    DateTime? startDate;
    DateTime? endDate;

    if (_selectedStatus == AdStatus.approved || _selectedStatus == AdStatus.active) {
      startDate = widget.ad.startDate ?? DateTime.now().add(const Duration(days: 1));
      endDate = widget.ad.endDate ?? startDate.add(Duration(days: widget.ad.durationDays));
    }

    final success = await _adsService.updateAdStatus(
      adId: widget.ad.id,
      status: _selectedStatus!,
      adminNote: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
      startDate: startDate,
      endDate: endDate,
    );

    if (success) {
      Navigator.pop(context);
      Get.snackbar(
        'تم التحديث',
        'تم تحديث حالة الإعلان بنجاح',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  String _getStatusText(AdStatus status) {
    switch (status) {
      case AdStatus.pending:
        return 'معلق';
      case AdStatus.underReview:
        return 'قيد المراجعة';
      case AdStatus.approved:
        return 'مقبول';
      case AdStatus.rejected:
        return 'مرفوض';
      case AdStatus.active:
        return 'نشط';
      case AdStatus.completed:
        return 'مكتمل';
      case AdStatus.cancelled:
        return 'ملغي';
    }
  }
}
