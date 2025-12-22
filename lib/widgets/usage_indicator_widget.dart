import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../services/analytics_service.dart';
import '../models/usage_stats.dart';

/// Widget لعرض استخدام المستخدم الحالي
class UsageIndicatorWidget extends StatelessWidget {
  final bool showDetails;

  const UsageIndicatorWidget({
    super.key,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final analyticsService = Get.find<AnalyticsService>();

    return Obx(() {
      if (analyticsService.isLoadingUsage.value) {
        return _buildLoadingCard();
      }

      final usage = analyticsService.usageStats.value;
      if (usage == null) {
        return _buildErrorCard();
      }

      return _buildUsageCard(usage);
    });
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 8),
          Text(
            'فشل تحميل الإحصائيات',
            style: TextStyle(color: AppColors.error, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(UsageStats usage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyanShadow.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'استخدامك الحالي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Posts Usage
          _buildUsageItem(
            icon: Icons.post_add_rounded,
            label: 'المنشورات',
            usage: usage.posts,
            gradient: AppColors.cyanPurpleGradient,
          ),
          const SizedBox(height: 16),

          // AI Usage
          _buildUsageItem(
            icon: Icons.auto_awesome_rounded,
            label: 'طلبات الذكاء الاصطناعي',
            usage: usage.aiRequests.isAvailable
                ? usage.aiRequests
                : null,
            gradient: AppColors.purpleMagentaGradient,
            isAI: true,
          ),
          const SizedBox(height: 16),

          // Accounts Usage
          _buildUsageItem(
            icon: Icons.link_rounded,
            label: 'الحسابات المربوطة',
            usage: usage.connectedAccounts,
            gradient: AppColors.cyanMagentaGradient,
          ),

          if (showDetails) ...[
            const SizedBox(height: 20),
            _buildUpgradeButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageItem({
    required IconData icon,
    required String label,
    required dynamic usage,
    required Gradient gradient,
    bool isAI = false,
  }) {
    if (usage == null) {
      return _buildUnavailableItem(icon, label, gradient);
    }

    final bool isNearLimit = usage is PostsUsage
        ? usage.isNearLimit
        : usage is AIRequestsUsage
            ? usage.isNearLimit
            : usage is ConnectedAccountsUsage
                ? usage.isNearLimit
                : false;

    final bool isAtLimit = usage is PostsUsage
        ? usage.isAtLimit
        : usage is AIRequestsUsage
            ? usage.isAtLimit
            : usage is ConnectedAccountsUsage
                ? usage.isAtLimit
                : false;

    final String displayText = usage is PostsUsage
        ? usage.displayText
        : usage is AIRequestsUsage
            ? usage.displayText
            : usage is ConnectedAccountsUsage
                ? usage.displayText
                : '0/0';

    final double percentage = usage is PostsUsage
        ? usage.percentage
        : usage is AIRequestsUsage
            ? usage.percentage
            : usage is ConnectedAccountsUsage
                ? usage.percentage
                : 0.0;

    Color statusColor = AppColors.success;
    if (isAtLimit) {
      statusColor = AppColors.error;
    } else if (isNearLimit) {
      statusColor = AppColors.warning;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                displayText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.darkBorder.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 8,
          ),
        ),
        if (isNearLimit && !isAtLimit) ...[
          const SizedBox(height: 4),
          Text(
            '⚠️ أوشكت على الوصول للحد الأقصى',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 11,
            ),
          ),
        ],
        if (isAtLimit) ...[
          const SizedBox(height: 4),
          Text(
            '🚫 وصلت للحد الأقصى - قم بالترقية',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUnavailableItem(IconData icon, String label, Gradient gradient) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkBorder.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'غير متاح',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.toNamed('/subscription'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ترقية الباقة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget مصغر لعرض استخدام واحد فقط
class CompactUsageIndicator extends StatelessWidget {
  final String type; // 'post', 'ai', or 'account'

  const CompactUsageIndicator({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final analyticsService = Get.find<AnalyticsService>();

    return Obx(() {
      final usage = analyticsService.usageStats.value;
      if (usage == null) return const SizedBox.shrink();

      dynamic usageData;
      IconData icon;
      String label;
      Gradient gradient;

      switch (type) {
        case 'post':
          usageData = usage.posts;
          icon = Icons.post_add_rounded;
          label = 'المنشورات';
          gradient = AppColors.cyanPurpleGradient;
          break;
        case 'ai':
          usageData = usage.aiRequests;
          icon = Icons.auto_awesome_rounded;
          label = 'AI';
          gradient = AppColors.purpleMagentaGradient;
          break;
        case 'account':
          usageData = usage.connectedAccounts;
          icon = Icons.link_rounded;
          label = 'الحسابات';
          gradient = AppColors.cyanMagentaGradient;
          break;
        default:
          return const SizedBox.shrink();
      }

      final bool isNearLimit = usageData is PostsUsage
          ? usageData.isNearLimit
          : usageData is AIRequestsUsage
              ? usageData.isNearLimit
              : usageData is ConnectedAccountsUsage
                  ? usageData.isNearLimit
                  : false;

      final bool isAtLimit = usageData is PostsUsage
          ? usageData.isAtLimit
          : usageData is AIRequestsUsage
              ? usageData.isAtLimit
              : usageData is ConnectedAccountsUsage
                  ? usageData.isAtLimit
                  : false;

      final String displayText = usageData is PostsUsage
          ? usageData.displayText
          : usageData is AIRequestsUsage
              ? usageData.displayText
              : usageData is ConnectedAccountsUsage
                  ? usageData.displayText
                  : '0/0';

      Color statusColor = AppColors.success;
      if (isAtLimit) {
        statusColor = AppColors.error;
      } else if (isNearLimit) {
        statusColor = AppColors.warning;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }
}
