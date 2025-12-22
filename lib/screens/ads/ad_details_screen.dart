import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sponsored_ad_model.dart';
import '../../services/sponsored_ads_service.dart';

class AdDetailsScreen extends StatelessWidget {
  final SponsoredAdModel ad;

  const AdDetailsScreen({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final SponsoredAdsService adsService = Get.find<SponsoredAdsService>();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'تفاصيل الإعلان',
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
          _buildAdHeader(ad),
          const SizedBox(height: 24),
          _buildAdInfo(ad),
          const SizedBox(height: 24),
          _buildDescriptionSection(ad),
          const SizedBox(height: 24),
          _buildTargetingSection(ad),
          if (ad.statistics != null) ...[
            const SizedBox(height: 24),
            _buildStatisticsSection(ad),
          ],
          if (ad.adminNote != null) ...[
            const SizedBox(height: 24),
            _buildAdminNoteSection(ad),
          ],
          const SizedBox(height: 24),
          _buildStatusSection(ad, adsService),
        ],
      ),
    );
  }

  Widget _buildAdHeader(SponsoredAdModel ad) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ad.statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '\$${ad.budget.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ad.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdInfo(SponsoredAdModel ad) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.category_rounded,
            label: 'نوع الإعلان',
            value: ad.adTypeText,
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.flag_rounded,
            label: 'الهدف',
            value: ad.objectiveText,
            color: AppColors.neonPurple,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'المدة',
            value: '${ad.durationDays} ${ad.durationDays == 1 ? "يوم" : "أيام"}',
            color: AppColors.neonMagenta,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'تاريخ الإنشاء',
            value: DateFormat('yyyy/MM/dd - HH:mm').format(ad.createdAt),
            color: const Color(0xFF00E676),
          ),
          if (ad.startDate != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.play_arrow_rounded,
              label: 'تاريخ البداية',
              value: DateFormat('yyyy/MM/dd').format(ad.startDate!),
              color: const Color(0xFF00E676),
            ),
          ],
          if (ad.endDate != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.stop_rounded,
              label: 'تاريخ النهاية',
              value: DateFormat('yyyy/MM/dd').format(ad.endDate!),
              color: const Color(0xFFFF5252),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(SponsoredAdModel ad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.neonCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'وصف الإعلان',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            ad.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetingSection(SponsoredAdModel ad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: AppColors.neonPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'الاستهداف',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المنصات المستهدفة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ad.platforms.map((platform) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.neonPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      SponsoredAdModel.getPlatformText(platform),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neonPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(SponsoredAdModel ad) {
    final stats = ad.statistics!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF00E676),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'إحصائيات الإعلان',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00E676).withValues(alpha: 0.1),
                const Color(0xFF00E676).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'الظهور',
                      value: _formatNumber(stats['impressions'] ?? 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'النقرات',
                      value: _formatNumber(stats['clicks'] ?? 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'معدل النقر',
                      value: '${stats['ctr']?.toStringAsFixed(2) ?? '0.00'}%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'التحويلات',
                      value: _formatNumber(stats['conversions'] ?? 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                label: 'المبلغ المنفق',
                value: '\$${stats['spend']?.toStringAsFixed(2) ?? '0.00'}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNoteSection(SponsoredAdModel ad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFF00E676),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'ملاحظات الإدارة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00E676).withValues(alpha: 0.1),
                const Color(0xFF00E676).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            ad.adminNote!,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(SponsoredAdModel ad, SponsoredAdsService adsService) {
    Color statusColor = _getStatusColor(ad.status);
    IconData statusIcon = _getStatusIcon(ad.status);
    String statusMessage = _getStatusMessage(ad.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
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

  IconData _getStatusIcon(AdStatus status) {
    switch (status) {
      case AdStatus.pending:
        return Icons.pending_rounded;
      case AdStatus.underReview:
        return Icons.rate_review_rounded;
      case AdStatus.approved:
        return Icons.check_circle_rounded;
      case AdStatus.rejected:
        return Icons.cancel_rounded;
      case AdStatus.active:
        return Icons.play_circle_rounded;
      case AdStatus.completed:
        return Icons.check_circle_rounded;
      case AdStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _getStatusMessage(AdStatus status) {
    switch (status) {
      case AdStatus.pending:
        return 'طلبك قيد الانتظار';
      case AdStatus.underReview:
        return 'يتم مراجعة طلبك';
      case AdStatus.approved:
        return 'تم قبول طلبك';
      case AdStatus.rejected:
        return 'تم رفض طلبك';
      case AdStatus.active:
        return 'إعلانك نشط الآن';
      case AdStatus.completed:
        return 'اكتمل الإعلان';
      case AdStatus.cancelled:
        return 'تم إلغاء الإعلان';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
