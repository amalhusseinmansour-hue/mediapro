import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sponsored_ad_model.dart';
import '../../services/sponsored_ads_service.dart';
import 'ad_review_dialog.dart';

class AdminAdsManagementScreen extends StatefulWidget {
  const AdminAdsManagementScreen({super.key});

  @override
  State<AdminAdsManagementScreen> createState() =>
      _AdminAdsManagementScreenState();
}

class _AdminAdsManagementScreenState extends State<AdminAdsManagementScreen> {
  final SponsoredAdsService _adsService = Get.find<SponsoredAdsService>();
  AdStatus? _filterStatus;

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
            'إدارة الإعلانات الممولة',
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
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Obx(() {
              if (_adsService.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonCyan),
                );
              }

              final allAds = _adsService.getAllAds();
              final filteredAds = _filterStatus == null
                  ? allAds
                  : allAds.where((ad) => ad.status == _filterStatus).toList();

              if (filteredAds.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => _adsService.loadAllAds(),
                color: AppColors.neonCyan,
                backgroundColor: AppColors.darkCard,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildStatsSection(allAds),
                    const SizedBox(height: 24),
                    ...filteredAds.map((ad) => _buildAdCard(ad)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصفية حسب الحالة:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('الكل', null),
                const SizedBox(width: 8),
                ...AdStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      _getStatusText(status),
                      status,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AdStatus? status) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.cyanPurpleGradient : null,
          color: isSelected ? null : AppColors.darkBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan
                : AppColors.neonCyan.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<SponsoredAdModel> allAds) {
    final pendingCount =
        allAds.where((ad) => ad.status == AdStatus.pending).length;
    final underReviewCount =
        allAds.where((ad) => ad.status == AdStatus.underReview).length;
    final activeCount =
        allAds.where((ad) => ad.status == AdStatus.active).length;
    final totalBudget = allAds.fold(0.0, (sum, ad) => sum + ad.budget);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'معلق',
                value: pendingCount.toString(),
                color: const Color(0xFFFF9800),
                icon: Icons.pending_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'قيد المراجعة',
                value: underReviewCount.toString(),
                color: const Color(0xFFFFB300),
                icon: Icons.rate_review_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'نشطة',
                value: activeCount.toString(),
                color: const Color(0xFF00E676),
                icon: Icons.play_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'الميزانية الكلية',
                value: '\$${totalBudget.toStringAsFixed(0)}',
                color: AppColors.neonCyan,
                icon: Icons.payments_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.cyanPurpleGradient.scale(0.3),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              size: 64,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد إعلانات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _filterStatus == null
                ? 'لا توجد أي طلبات إعلانات حالياً'
                : 'لا توجد إعلانات بحالة ${_getStatusText(_filterStatus!)}',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(SponsoredAdModel ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(ad.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showAdReviewDialog(ad);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ad.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ad.statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(ad.status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.neonPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ad.adTypeText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonPurple,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${ad.budget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ad.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  ad.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'User ID: ${ad.userId.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('yyyy/MM/dd').format(ad.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (ad.status == AdStatus.pending ||
                    ad.status == AdStatus.underReview) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveAd(ad),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
                          label: const Text(
                            'موافقة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rejectAd(ad),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5252),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          label: const Text(
                            'رفض',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAdReviewDialog(SponsoredAdModel ad) {
    showDialog(
      context: context,
      builder: (context) => AdReviewDialog(ad: ad),
    );
  }

  Future<void> _approveAd(SponsoredAdModel ad) async {
    final startDate = DateTime.now().add(const Duration(days: 1));
    final endDate = startDate.add(Duration(days: ad.durationDays));

    final success = await _adsService.updateAdStatus(
      adId: ad.id,
      status: AdStatus.approved,
      adminNote: 'تم قبول طلبك! سيبدأ الإعلان قريباً',
      startDate: startDate,
      endDate: endDate,
    );

    if (success) {
      Get.snackbar(
        'تمت الموافقة',
        'تم قبول الإعلان بنجاح',
        backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _rejectAd(SponsoredAdModel ad) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'رفض الإعلان',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أدخل سبب الرفض...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.darkBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _adsService.updateAdStatus(
                  adId: ad.id,
                  status: AdStatus.rejected,
                  rejectionReason: controller.text.trim(),
                  adminNote: 'تم رفض طلبك',
                );

                Navigator.pop(context);

                Get.snackbar(
                  'تم الرفض',
                  'تم رفض الإعلان',
                  backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.2),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('رفض', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  Color _getStatusColor(AdStatus status) {
    switch (status) {
      case AdStatus.pending:
        return const Color(0xFFFF9800);
      case AdStatus.underReview:
        return const Color(0xFFFFB300);
      case AdStatus.approved:
        return const Color(0xFF00E676);
      case AdStatus.rejected:
        return const Color(0xFFFF5252);
      case AdStatus.active:
        return const Color(0xFF00E676);
      case AdStatus.completed:
        return AppColors.neonPurple;
      case AdStatus.cancelled:
        return AppColors.textSecondary;
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
