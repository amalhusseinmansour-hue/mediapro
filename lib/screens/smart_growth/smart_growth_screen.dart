import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/smart_growth_service.dart';
import '../../core/constants/app_colors.dart';

/// 🚀 شاشة النظام الذكي لزيادة الأرباح 500%
class SmartGrowthScreen extends StatelessWidget {
  const SmartGrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(SmartGrowthService());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => service.analyzeAndGenerateRecommendations(),
          child: CustomScrollView(
            slivers: [
              _buildAppBar(service),
              _buildGrowthScoreCard(service),
              _buildInsightsSection(service),
              _buildRecommendationsSection(service),
            ],
          ),
        ),
      ),
    );
  }

  /// شريط التطبيق
  Widget _buildAppBar(SmartGrowthService service) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          '🚀 نظام النمو الذكي',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple.withValues(alpha: 0.3),
                AppColors.accentCyan.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Obx(() {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                if (service.isAnalyzing.value)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatBadge(
                        icon: Icons.trending_up,
                        label: 'النمو',
                        value: service.growthTrend.value == 'rising'
                            ? '+${service.insights.value?.audienceGrowthRate.toStringAsFixed(1) ?? 0}%'
                            : '${service.insights.value?.audienceGrowthRate.toStringAsFixed(1) ?? 0}%',
                        color: service.growthTrend.value == 'rising'
                            ? Colors.green
                            : service.growthTrend.value == 'falling'
                            ? Colors.red
                            : Colors.orange,
                      ),
                      const SizedBox(width: 20),
                      _buildStatBadge(
                        icon: Icons.money,
                        label: 'زيادة متوقعة',
                        value:
                            '+${service.insights.value?.revenueImpactPrediction.toStringAsFixed(0) ?? 0}%',
                        color: Colors.amber,
                      ),
                    ],
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بطاقة نقاط النمو
  Widget _buildGrowthScoreCard(SmartGrowthService service) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final score = service.growthScore.value;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.1),
                  AppColors.accentCyan.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentCyan.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'نقاط النمو الخاصة بك',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(
                          _getScoreColor(score),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            score.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getScoreLabel(score),
                            style: TextStyle(
                              color: _getScoreColor(score),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildScoreExplanation(score),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScoreExplanation(double score) {
    String explanation;
    IconData icon;
    Color color;

    if (score >= 80) {
      explanation = '🎉 ممتاز! أنت في طريقك لزيادة أرباحك 500%';
      icon = Icons.rocket_launch;
      color = Colors.green;
    } else if (score >= 60) {
      explanation = '👍 جيد جداً! لكن يمكنك تحسين بعض النقاط';
      icon = Icons.trending_up;
      color = Colors.blue;
    } else if (score >= 40) {
      explanation = '📈 جيد! اتبع التوصيات لتحسين النتائج';
      icon = Icons.insights;
      color = Colors.orange;
    } else {
      explanation = '💡 هناك فرص كبيرة للتحسين!';
      icon = Icons.lightbulb_outline;
      color = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              explanation,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// قسم الرؤى
  Widget _buildInsightsSection(SmartGrowthService service) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final insights = service.insights.value;
        if (insights == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '📊 رؤى وتحليلات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInsightCard(
                    icon: Icons.favorite,
                    title: 'معدل التفاعل',
                    value:
                        '${insights.averageEngagementRate.toStringAsFixed(1)}%',
                    trend: insights.averageEngagementRate > 5 ? 'up' : 'down',
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    icon: Icons.people,
                    title: 'نمو الجمهور',
                    value:
                        '+${insights.audienceGrowthRate.toStringAsFixed(1)}%',
                    trend: insights.audienceGrowthRate > 0 ? 'up' : 'down',
                  ),
                  const SizedBox(height: 12),
                  _buildBestTimesCard(insights.bestPostingTimes),
                  const SizedBox(height: 12),
                  _buildTopContentTypesCard(insights.topPerformingContentTypes),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
  }) {
    final trendColor = trend == 'up' ? Colors.green : Colors.red;
    final trendIcon = trend == 'up' ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.3),
                  AppColors.accentCyan.withValues(alpha: 0.3),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(trendIcon, color: trendColor, size: 32),
        ],
      ),
    );
  }

  Widget _buildBestTimesCard(List<PostingTime> times) {
    if (times.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: AppColors.accentCyan, size: 20),
              SizedBox(width: 8),
              Text(
                'أفضل أوقات النشر',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...times.take(3).map((time) {
            final days = [
              'الأحد',
              'الاثنين',
              'الثلاثاء',
              'الأربعاء',
              'الخميس',
              'الجمعة',
              'السبت',
            ];
            final hour = time.hour > 12 ? time.hour - 12 : time.hour;
            final period = time.hour >= 12 ? 'مساءً' : 'صباحاً';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${days[time.dayOfWeek - 1]} - $hour:00 $period',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${time.averageEngagement.toStringAsFixed(0)} تفاعل',
                    style: const TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopContentTypesCard(List<ContentType> types) {
    if (types.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category, color: AppColors.primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'أنواع المحتوى الأكثر نجاحاً',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...types.take(3).map((type) {
            final icons = {
              'text': Icons.text_fields,
              'image': Icons.image,
              'video': Icons.videocam,
              'link': Icons.link,
            };
            final typeNames = {
              'text': 'النصوص',
              'image': 'الصور',
              'video': 'الفيديوهات',
              'link': 'الروابط',
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    icons[type.type] ?? Icons.article,
                    color: AppColors.primaryPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeNames[type.type] ?? type.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${type.postCount} منشور',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${type.averageEngagement.toStringAsFixed(1)}% تفاعل',
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// قسم التوصيات
  Widget _buildRecommendationsSection(SmartGrowthService service) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: Obx(() {
        final recommendations = service.recommendations;

        if (recommendations.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                'لا توجد توصيات حالياً',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '💡 توصيات ذكية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final rec = recommendations[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildRecommendationCard(rec),
            );
          }, childCount: recommendations.length + 1),
        );
      }),
    );
  }

  Widget _buildRecommendationCard(SmartRecommendation rec) {
    final priorityColors = {
      'high': Colors.red,
      'medium': Colors.orange,
      'low': Colors.blue,
    };

    final priorityLabels = {'high': 'عاجل', 'medium': 'مهم', 'low': 'عادي'};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: priorityColors[rec.priority]!.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColors[rec.priority]!.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priorityLabels[rec.priority]!,
                  style: TextStyle(
                    color: priorityColors[rec.priority],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (rec.actionable)
                const Icon(
                  Icons.touch_app,
                  color: AppColors.accentCyan,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rec.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rec.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.impact,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (rec.actionable) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // تطبيق التوصية
                Get.snackbar(
                  '✅ جاري التطبيق',
                  rec.action,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.accentCyan,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 18),
                  const SizedBox(width: 8),
                  Text(rec.action),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'ممتاز';
    if (score >= 60) return 'جيد جداً';
    if (score >= 40) return 'جيد';
    return 'بحاجة لتحسين';
  }
}
