import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/linkedin_service.dart';
import '../../core/constants/app_colors.dart';

/// شاشة تحليلات LinkedIn
class LinkedInAnalyticsScreen extends StatefulWidget {
  const LinkedInAnalyticsScreen({super.key});

  @override
  State<LinkedInAnalyticsScreen> createState() => _LinkedInAnalyticsScreenState();
}

class _LinkedInAnalyticsScreenState extends State<LinkedInAnalyticsScreen> {
  late LinkedInService _linkedInService;
  LinkedInAnalyticsDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initService();
    _loadAnalytics();
  }

  void _initService() {
    if (!Get.isRegistered<LinkedInService>()) {
      Get.put(LinkedInService());
    }
    _linkedInService = Get.find<LinkedInService>();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _linkedInService.getAnalyticsDashboard();

      if (result.success && result.dashboard != null) {
        setState(() {
          _dashboard = result.dashboard;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.error ?? 'فشل في جلب التحليلات';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ: $e';
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
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: const Color(0xFF0A66C2), size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business_center_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'تحليلات LinkedIn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2)),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_dashboard == null) {
      return _buildNoDataState();
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFF0A66C2),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(),
            const SizedBox(height: 20),

            // Network Stats
            _buildNetworkStats(),
            const SizedBox(height: 20),

            // Engagement Summary
            _buildEngagementSummary(),
            const SizedBox(height: 20),

            // Engagement Chart
            _buildEngagementChart(),
            const SizedBox(height: 20),

            // Recent Posts
            _buildRecentPosts(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  color: Colors.red, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              _error ?? 'حدث خطأ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'تأكد من ربط حساب LinkedIn أولاً',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAnalytics,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.analytics_outlined,
                  color: Color(0xFF0A66C2), size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد بيانات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'قم بربط حساب LinkedIn للحصول على التحليلات',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final profile = _dashboard?.profile;
    final network = _dashboard?.network;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A66C2),
            const Color(0xFF0A66C2).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A66C2).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              image: profile?.picture != null
                  ? DecorationImage(
                      image: NetworkImage(profile!.picture!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile?.picture == null
                ? Center(
                    child: Text(
                      profile?.name?.substring(0, 1).toUpperCase() ?? 'L',
                      style: const TextStyle(
                        color: Color(0xFF0A66C2),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? 'المستخدم',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profile?.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile!.email!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMiniStat(
                      '${network?.connections ?? 0}',
                      'اتصال',
                      Icons.people_alt_rounded,
                    ),
                    const SizedBox(width: 20),
                    _buildMiniStat(
                      '${network?.followers ?? 0}',
                      'متابع',
                      Icons.person_add_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkStats() {
    return _buildSectionTitle('إحصائيات الشبكة', Icons.hub_rounded);
  }

  Widget _buildEngagementSummary() {
    final summary = _dashboard?.engagementSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ملخص التفاعل', Icons.trending_up_rounded),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Main Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '${summary?.totalPosts ?? 0}',
                      'المنشورات',
                      Icons.article_rounded,
                      const Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '${summary?.totalImpressions ?? 0}',
                      'المشاهدات',
                      Icons.visibility_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Engagement Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '${summary?.totalLikes ?? 0}',
                      'إعجاب',
                      Icons.thumb_up_rounded,
                      Colors.pink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '${summary?.totalComments ?? 0}',
                      'تعليق',
                      Icons.comment_rounded,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '${summary?.totalShares ?? 0}',
                      'مشاركة',
                      Icons.share_rounded,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Engagement Rate
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0A66C2).withValues(alpha: 0.2),
                      const Color(0xFF0A66C2).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'معدل التفاعل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A66C2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${summary?.engagementRate ?? 0}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementChart() {
    final summary = _dashboard?.engagementSummary;
    if (summary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('توزيع التفاعل', Icons.pie_chart_rounded),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
            ),
          ),
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: summary.totalLikes.toDouble(),
                    title: 'إعجاب',
                    color: Colors.pink,
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: summary.totalComments.toDouble(),
                    title: 'تعليق',
                    color: Colors.orange,
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: summary.totalShares.toDouble(),
                    title: 'مشاركة',
                    color: Colors.purple,
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPosts() {
    final posts = _dashboard?.recentPosts ?? [];

    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('أحدث المنشورات', Icons.article_rounded),
        const SizedBox(height: 12),
        ...posts.map((post) => _buildPostCard(post)),
      ],
    );
  }

  Widget _buildPostCard(LinkedInPostAnalytics post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildPostStat(Icons.thumb_up_rounded, '${post.likes}',
                      Colors.pink),
                  const SizedBox(width: 16),
                  _buildPostStat(Icons.comment_rounded, '${post.comments}',
                      Colors.orange),
                  const SizedBox(width: 16),
                  _buildPostStat(Icons.share_rounded, '${post.shares}',
                      Colors.purple),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${post.impressions} مشاهدة',
                  style: const TextStyle(
                    color: Color(0xFF0A66C2),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A66C2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
