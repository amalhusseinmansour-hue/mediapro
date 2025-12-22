import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/dependency_helper.dart';
import '../../services/analytics_service.dart';
import '../../services/social_accounts_service.dart';
import '../../core/utils/error_handler.dart';
import 'package:intl/intl.dart';
import '../../widgets/analytics_filter_dialog.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'أسبوع';
  late TabController _tabController;
  AnalyticsService? _analyticsService;
  SocialAccountsService? _socialAccountsService;

  @override
  void initState() {
    super.initState();

    // Initialize service safely
    _analyticsService = DependencyHelper.tryFind<AnalyticsService>();

    // Initialize social accounts service - هذه الخدمة الأساسية للبيانات
    _socialAccountsService = DependencyHelper.tryFind<SocialAccountsService>();

    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    // تحميل الحسابات من SocialAccountsService أولاً
    if (_socialAccountsService != null) {
      await _socialAccountsService!.loadAccounts();
    }

    // محاولة تحميل التحليلات من AnalyticsService (اختياري)
    if (_analyticsService != null) {
      try {
        await _analyticsService!.refreshAll();
      } catch (e) {
        print('⚠️ Analytics service error (using accounts data instead): $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.neonGradient.createShader(bounds),
          child: const Text(
            'التحليلات والإحصائيات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          // Filter Button
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: AppColors.neonCyan),
            onPressed: () {
              if (_analyticsService == null) return;

              showDialog(
                context: context,
                builder: (context) => AnalyticsFilterDialog(
                  initialFilter: _analyticsService!.activeFilter.value,
                  onApply: (filter) async {
                    await ErrorHandler.handleAsync(() async {
                      await _analyticsService!.applyFilters(filter);
                    }, errorMessage: 'فشل تطبيق الفلاتر');
                  },
                ),
              );
            },
            tooltip: 'الفلاتر',
          ),
          Obx(
            () =>
                (_analyticsService?.isLoadingUsage.value ?? false) ||
                    (_analyticsService?.isLoadingOverview.value ?? false)
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.neonCyan,
                    ),
                    onPressed: _loadAnalytics,
                    tooltip: 'تحديث',
                  ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<String>(
                color: AppColors.darkCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.neonCyan.withOpacity(0.3)),
                ),
                initialValue: _selectedPeriod,
                offset: const Offset(0, 50),
                onSelected: (value) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                  Get.snackbar(
                    'تم التحديث',
                    'عرض بيانات $_selectedPeriod',
                    backgroundColor: AppColors.darkCard,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: Icon(Icons.update, color: AppColors.neonCyan),
                  );
                },
                itemBuilder: (context) => [
                  _buildPeriodMenuItem('يوم', 'اليوم', Icons.today),
                  _buildPeriodMenuItem(
                    'أسبوع',
                    'هذا الأسبوع',
                    Icons.calendar_view_week,
                  ),
                  _buildPeriodMenuItem(
                    'شهر',
                    'هذا الشهر',
                    Icons.calendar_month,
                  ),
                  _buildPeriodMenuItem(
                    'سنة',
                    'هذه السنة',
                    Icons.calendar_today,
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedPeriod,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Active Filter Indicator
          Obx(() {
            final activeFilter = _analyticsService?.activeFilter.value;
            if (activeFilter == null || !activeFilter.isActive) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.all(16).copyWith(bottom: 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: AppColors.neonCyan, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeFilter.getDescription(),
                      style: TextStyle(color: AppColors.neonCyan, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      if (_analyticsService != null) {
                        await _analyticsService!.clearFilters();
                      }
                    },
                    child: Icon(
                      Icons.close,
                      color: AppColors.neonCyan,
                      size: 18,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Tabs
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_rounded), text: 'نظرة عامة'),
                Tab(icon: Icon(Icons.trending_up_rounded), text: 'الأداء'),
                Tab(icon: Icon(Icons.people_alt_rounded), text: 'الجمهور'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPerformanceTab(),
                _buildAudienceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPeriodMenuItem(
    String value,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Obx(() {
      // استخدام الحسابات من SocialAccountsService مباشرة
      final accounts = _socialAccountsService?.accounts ?? [];

      // Calculate real stats from connected accounts
      int totalFollowers = 0;
      int totalPosts = 0;
      double avgEngagement = 0;
      for (var account in accounts) {
        final f = account.stats?.followers ?? 0;
        final p = account.stats?.postsCount ?? 0;
        totalFollowers = totalFollowers + (f is int ? f : (f as num).toInt());
        totalPosts = totalPosts + (p is int ? p : (p as num).toInt());
        avgEngagement += account.stats?.engagementRate ?? 0;
      }
      if (accounts.isNotEmpty) {
        avgEngagement = avgEngagement / accounts.length;
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connected Accounts Section
            if (accounts.isNotEmpty) ...[
              _buildSectionHeader(
                'الحسابات المتصلة (${accounts.length})',
                Icons.link_rounded,
              ),
              const SizedBox(height: 16),
              _buildConnectedAccountsSection(accounts),
              const SizedBox(height: 24),
            ] else ...[
              _buildNoAccountsCard(),
              const SizedBox(height: 24),
            ],

            // Overview Cards Grid - Using real data
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _buildNeonMetricCard(
                  title: 'إجمالي المتابعين',
                  value: accounts.isNotEmpty ? _formatNumber(totalFollowers) : '0',
                  change: accounts.isNotEmpty ? '+${accounts.length} حساب' : '0',
                  isPositive: accounts.isNotEmpty,
                  icon: Icons.people_alt_rounded,
                  gradient: AppColors.cyanPurpleGradient,
                ),
                _buildNeonMetricCard(
                  title: 'معدل التفاعل',
                  value: '${avgEngagement.toStringAsFixed(1)}%',
                  change: accounts.isNotEmpty ? 'من ${accounts.length} حساب' : '0%',
                  isPositive: avgEngagement > 0,
                  icon: Icons.favorite_rounded,
                  gradient: AppColors.purpleMagentaGradient,
                ),
                _buildNeonMetricCard(
                  title: 'الحسابات المتصلة',
                  value: accounts.length.toString(),
                  change: accounts.isNotEmpty ? 'نشط' : 'لا يوجد',
                  isPositive: accounts.isNotEmpty,
                  icon: Icons.link_rounded,
                  gradient: AppColors.cyanMagentaGradient,
                ),
                _buildNeonMetricCard(
                  title: 'المنشورات',
                  value: _formatNumber(totalPosts),
                  change: accounts.isNotEmpty ? 'إجمالي' : '0',
                  isPositive: totalPosts > 0,
                  icon: Icons.post_add_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF6B9D)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Engagement Trend Chart
            _buildSectionHeader(
              'معدل التفاعل الأسبوعي',
              Icons.trending_up_rounded,
            ),
            const SizedBox(height: 16),
            _buildEngagementChart(),
            const SizedBox(height: 24),

            // Platform Distribution
            _buildSectionHeader(
              'توزيع الحسابات حسب المنصات',
              Icons.pie_chart_rounded,
            ),
            const SizedBox(height: 16),
            _buildPlatformDistributionDynamic(accounts),
            const SizedBox(height: 24),

            // Growth Metrics
            _buildSectionHeader('معدلات النمو', Icons.show_chart_rounded),
            const SizedBox(height: 16),
            _buildGrowthMetrics(),
          ],
        ),
      );
    });
  }

  Widget _buildPerformanceTab() {
    return Obx(() {
      final accounts = _socialAccountsService?.accounts ?? [];

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Performing Posts - Based on connected accounts
            _buildSectionHeader('أداء الحسابات المتصلة', Icons.star_rounded),
            const SizedBox(height: 16),

            if (accounts.isEmpty) ...[
              _buildNoDataCard(
                'لا توجد حسابات متصلة',
                'قم بربط حساباتك لعرض بيانات الأداء',
                Icons.link_off_rounded,
              ),
            ] else ...[
              // Show real accounts performance
              ...accounts.map((account) {
                final platform = account.platform ?? 'unknown';
                final stats = account.stats;
                return Column(
                  children: [
                    _buildTopPostCard(
                      title: account.accountName ?? 'حساب غير معروف',
                      platform: _capitalizeFirst(platform),
                      engagement: stats?.engagementRate?.toInt() ?? 0,
                      impressions: stats?.followers ?? 0,
                      shares: stats?.postsCount ?? 0,
                      platformColor: _getPlatformColor(platform),
                      platformIcon: _getPlatformIcon(platform),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
            const SizedBox(height: 24),

            // Engagement Rate by Platform - Real data
            _buildSectionHeader(
              'معدل التفاعل حسب المنصة',
              Icons.analytics_rounded,
            ),
            const SizedBox(height: 16),
            _buildEngagementByPlatformDynamic(accounts),
            const SizedBox(height: 24),

            // Best Time to Post
            _buildSectionHeader('أفضل أوقات النشر', Icons.access_time_rounded),
            const SizedBox(height: 16),
            _buildBestTimeToPostDynamic(accounts),
          ],
        ),
      );
    });
  }

  Widget _buildAudienceTab() {
    return Obx(() {
      final accounts = _socialAccountsService?.accounts ?? [];

      // Calculate total followers from all accounts
      int totalFollowers = 0;
      for (var account in accounts) {
        final f = account.stats?.followers ?? 0;
        totalFollowers = totalFollowers + (f is int ? f : (f as num).toInt());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audience Summary
            _buildSectionHeader('ملخص الجمهور', Icons.groups_rounded),
            const SizedBox(height: 16),
            _buildAudienceSummary(accounts, totalFollowers),
            const SizedBox(height: 24),

            // Followers by Platform
            _buildSectionHeader('المتابعين حسب المنصة', Icons.pie_chart_rounded),
            const SizedBox(height: 16),
            _buildFollowersByPlatform(accounts),
            const SizedBox(height: 24),

            // Account Growth
            _buildSectionHeader('نمو الحسابات', Icons.trending_up_rounded),
            const SizedBox(height: 16),
            _buildAccountsGrowthCard(accounts),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.neonGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNeonMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyanShadow.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => gradient.createShader(bounds),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPositive
                              ? AppColors.success
                              : AppColors.error,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 12,
                            color: isPositive
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            change,
                            style: TextStyle(
                              fontSize: 10,
                              color: isPositive
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildEngagementChart() {
    return Obx(() {
      final history = _analyticsService?.getGrowthHistory(days: 7) ?? [];
      
      if (history.isEmpty) {
        return _buildNoDataCard(
          'لا توجد بيانات تاريخية',
          'سيظهر الرسم البياني بعد تجميع بيانات يومية',
          Icons.show_chart,
        );
      }

      // Prepare spots
      final List<FlSpot> spots = [];
      double maxY = 0;
      
      for (int i = 0; i < history.length; i++) {
        final rate = history[i].avgEngagementRate;
        spots.add(FlSpot(i.toDouble(), rate));
        if (rate > maxY) maxY = rate;
      }
      
      // Add padding to maxY
      maxY = maxY * 1.2;
      if (maxY == 0) maxY = 10;

      return Container(
        height: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyanShadow.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.darkBorder.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < history.length) {
                      final date = history[index].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('E', 'ar').format(date), // Day name in Arabic
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (history.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.4,
                color: AppColors.neonCyan,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.darkCard,
                      strokeWidth: 3,
                      strokeColor: AppColors.neonCyan,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonCyan.withOpacity(0.4),
                      AppColors.neonCyan.withOpacity(0.1),
                      AppColors.neonCyan.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlatformDistribution() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyanShadow.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: const Color(0xFF1877F2),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    badgeWidget: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.facebook,
                        color: Color(0xFF1877F2),
                        size: 16,
                      ),
                    ),
                    badgePositionPercentageOffset: 1.3,
                  ),
                  PieChartSectionData(
                    value: 28,
                    title: '28%',
                    color: const Color(0xFFE4405F),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    badgeWidget: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFE4405F),
                        size: 16,
                      ),
                    ),
                    badgePositionPercentageOffset: 1.3,
                  ),
                  PieChartSectionData(
                    value: 22,
                    title: '22%',
                    color: const Color(0xFF1DA1F2),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    badgeWidget: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tag,
                        color: Color(0xFF1DA1F2),
                        size: 16,
                      ),
                    ),
                    badgePositionPercentageOffset: 1.3,
                  ),
                  PieChartSectionData(
                    value: 15,
                    title: '15%',
                    color: const Color(0xFF0A66C2),
                    radius: 65,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    badgeWidget: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.work,
                        color: Color(0xFF0A66C2),
                        size: 16,
                      ),
                    ),
                    badgePositionPercentageOffset: 1.3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Facebook', const Color(0xFF1877F2), '50.8K'),
                const SizedBox(height: 12),
                _buildLegendItem('Instagram', const Color(0xFFE4405F), '40.6K'),
                const SizedBox(height: 12),
                _buildLegendItem('Twitter', const Color(0xFF1DA1F2), '32.1K'),
                const SizedBox(height: 12),
                _buildLegendItem('LinkedIn', const Color(0xFF0A66C2), '21.9K'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 22),
          child: Text(
            value,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthMetrics() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyanShadow.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    'يناير',
                    'فبراير',
                    'مارس',
                    'أبريل',
                    'مايو',
                    'يونيو',
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.darkBorder.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 65,
                  gradient: AppColors.cyanPurpleGradient,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 72,
                  gradient: AppColors.purpleMagentaGradient,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 68,
                  gradient: AppColors.cyanMagentaGradient,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 85,
                  gradient: AppColors.neonGradient,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: 78,
                  gradient: AppColors.cyanPurpleGradient,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                  toY: 92,
                  gradient: AppColors.purpleMagentaGradient,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPostCard({
    required String title,
    required String platform,
    required int engagement,
    required int impressions,
    required int shares,
    required Color platformColor,
    required IconData platformIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: platformColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: platformColor.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: platformColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: platformColor.withOpacity(0.5)),
                ),
                child: Icon(platformIcon, color: platformColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: platformColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        platform,
                        style: TextStyle(
                          color: platformColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPostMetric(
                Icons.favorite_rounded,
                engagement.toString(),
                'تفاعل',
              ),
              _buildPostMetric(
                Icons.visibility_rounded,
                impressions.toString(),
                'مشاهدات',
              ),
              _buildPostMetric(
                Icons.share_rounded,
                shares.toString(),
                'مشاركات',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 20),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEngagementByPlatform() {
    final platforms = [
      {'name': 'Facebook', 'rate': 8.5, 'color': const Color(0xFF1877F2)},
      {'name': 'Instagram', 'rate': 7.2, 'color': const Color(0xFFE4405F)},
      {'name': 'Twitter', 'rate': 6.8, 'color': const Color(0xFF1DA1F2)},
      {'name': 'LinkedIn', 'rate': 5.4, 'color': const Color(0xFF0A66C2)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: platforms.map((platform) {
          final rate = platform['rate'] as double;
          final color = platform['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      platform['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$rate%',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: rate / 10,
                    backgroundColor: AppColors.darkBorder.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBestTimeToPost() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildTimeSlot(
            'الصباح (6 صباحاً - 12 ظهراً)',
            65,
            AppColors.cyanPurpleGradient,
          ),
          const SizedBox(height: 12),
          _buildTimeSlot(
            'الظهيرة (12 ظهراً - 6 مساءً)',
            85,
            AppColors.purpleMagentaGradient,
          ),
          const SizedBox(height: 12),
          _buildTimeSlot(
            'المساء (6 مساءً - 12 منتصف الليل)',
            92,
            AppColors.neonGradient,
          ),
          const SizedBox(height: 12),
          _buildTimeSlot(
            'الليل (12 منتصف الليل - 6 صباحاً)',
            45,
            AppColors.cyanMagentaGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time, int engagement, Gradient gradient) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            time,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Container(
                height: 32,
                width: engagement * 2.5,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '$engagement%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicsCards() {
    // Hide fake data
    return _buildNoDataCard(
      'بيانات الجمهور غير متوفرة',
      'تتطلب هذه البيانات صلاحيات متقدمة من المنصات',
      Icons.lock_outline,
    );
  }

  Widget _buildDemoCard(
    String label,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeDistribution() {
    // Hide fake data
    return const SizedBox.shrink();
  }

  Widget _buildLocationDistribution() {
    // Hide fake data
    return const SizedBox.shrink();
  }

  // Helper to get platform icon
  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.tag;
      case 'linkedin':
        return Icons.work;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'tiktok':
        return Icons.music_note;
      case 'snapchat':
        return Icons.snapchat;
      default:
        return Icons.public;
    }
  }

  // Helper to get platform color
  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      default:
        return AppColors.neonCyan;
    }
  }

  // Build no accounts card
  Widget _buildNoAccountsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.link_off_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد حسابات متصلة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بربط حساباتك على منصات التواصل الاجتماعي لعرض التحليلات',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed('/social-accounts');
            },
            icon: const Icon(Icons.add_link),
            label: const Text('ربط حساب جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build connected accounts section
  Widget _buildConnectedAccountsSection(List<dynamic> accounts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Accounts list
          ...accounts.map((account) => _buildConnectedAccountTile(account)),

          // Add more button
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Get.toNamed('/social-accounts');
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة حساب آخر'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neonCyan,
              side: BorderSide(color: AppColors.neonCyan.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build single account tile
  Widget _buildConnectedAccountTile(dynamic account) {
    final platform = account.platform ?? 'unknown';
    final accountName = account.accountName ?? 'حساب غير معروف';
    final profileImage = account.profileImageUrl;
    final stats = account.stats;
    final color = _getPlatformColor(platform);
    final icon = _getPlatformIcon(platform);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile image or platform icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.5)),
                  image: profileImage != null
                      ? DecorationImage(
                          image: NetworkImage(profileImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImage == null
                    ? Icon(icon, color: color, size: 28)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(icon, color: color, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          platform.toString().toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'متصل',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Stats row - Always show stats (use defaults if not available)
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAccountStat(
                'متابعين',
                stats != null ? _formatNumber(stats.followers ?? 0) : '--',
                Icons.people,
                color,
              ),
              _buildAccountStat(
                'منشورات',
                stats != null ? _formatNumber(stats.postsCount ?? 0) : '--',
                Icons.post_add,
                color,
              ),
              _buildAccountStat(
                'تفاعل',
                stats != null ? '${(stats.engagementRate ?? 0).toStringAsFixed(1)}%' : '--',
                Icons.favorite,
                color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build account stat widget
  Widget _buildAccountStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Format large numbers
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Dynamic platform distribution based on connected accounts
  Widget _buildPlatformDistributionDynamic(List<dynamic> accounts) {
    if (accounts.isEmpty) {
      return _buildPlatformDistribution(); // Fallback to static data
    }

    // Group accounts by platform
    final Map<String, int> platformCounts = {};
    for (var account in accounts) {
      final platform = account.platform?.toString().toLowerCase() ?? 'other';
      platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
    }

    final total = accounts.length;
    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];

    int index = 0;
    platformCounts.forEach((platform, count) {
      final percentage = (count / total * 100).round();
      final color = _getPlatformColor(platform);
      final icon = _getPlatformIcon(platform);

      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: '$percentage%',
          color: color,
          radius: 65,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          badgeWidget: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          badgePositionPercentageOffset: 1.3,
        ),
      );

      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLegendItem(
            _capitalizeFirst(platform),
            color,
            '$count حساب',
          ),
        ),
      );
      index++;
    });

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyanShadow.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: legendItems,
            ),
          ),
        ],
      ),
    );
  }

  // Capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // No data card
  Widget _buildNoDataCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.neonCyan, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic engagement by platform
  Widget _buildEngagementByPlatformDynamic(List<dynamic> accounts) {
    if (accounts.isEmpty) {
      return _buildNoDataCard(
        'لا توجد بيانات',
        'قم بربط حساباتك لعرض معدلات التفاعل',
        Icons.analytics_outlined,
      );
    }

    // Group by platform and calculate average engagement
    final Map<String, List<double>> platformEngagements = {};
    for (var account in accounts) {
      final platform = account.platform?.toString().toLowerCase() ?? 'other';
      final rate = account.stats?.engagementRate ?? 0.0;
      platformEngagements.putIfAbsent(platform, () => []);
      platformEngagements[platform]!.add(rate);
    }

    final List<Map<String, dynamic>> platforms = [];
    platformEngagements.forEach((platform, rates) {
      final avgRate = rates.reduce((a, b) => a + b) / rates.length;
      platforms.add({
        'name': _capitalizeFirst(platform),
        'rate': avgRate,
        'color': _getPlatformColor(platform),
      });
    });

    // Sort by rate descending
    platforms.sort((a, b) => (b['rate'] as double).compareTo(a['rate'] as double));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: platforms.map((platform) {
          final rate = platform['rate'] as double;
          final color = platform['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      platform['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${rate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: rate / 10,
                    backgroundColor: AppColors.darkBorder.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Dynamic best time to post
  Widget _buildBestTimeToPostDynamic(List<dynamic> accounts) {
    if (accounts.isEmpty) {
      return _buildNoDataCard(
        'لا توجد بيانات كافية',
        'ستظهر أفضل أوقات النشر بعد ربط حساباتك وتحليل بياناتها',
        Icons.access_time_rounded,
      );
    }

    // Since we don't have real posting time data, show a message
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'تحليل أوقات النشر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لديك ${accounts.length} حساب متصل\nابدأ بالنشر لتحليل أفضل الأوقات',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeRecommendation('الصباح', '9-11', AppColors.neonCyan),
              _buildTimeRecommendation('المساء', '7-9', AppColors.neonPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRecommendation(String period, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            period,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Audience summary card
  Widget _buildAudienceSummary(List<dynamic> accounts, int totalFollowers) {
    if (accounts.isEmpty) {
      return _buildNoDataCard(
        'لا توجد حسابات متصلة',
        'قم بربط حساباتك لعرض بيانات الجمهور',
        Icons.groups_outlined,
      );
    }

    // Calculate total posts
    int totalPosts = 0;
    double avgEngagement = 0;
    for (var account in accounts) {
      final p = account.stats?.postsCount ?? 0;
      totalPosts = totalPosts + (p is int ? p : (p as num).toInt());
      avgEngagement += account.stats?.engagementRate ?? 0;
    }
    if (accounts.isNotEmpty) {
      avgEngagement = avgEngagement / accounts.length;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'إجمالي المتابعين',
                  _formatNumber(totalFollowers),
                  Icons.people,
                  AppColors.neonCyan,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.darkBorder,
              ),
              Expanded(
                child: _buildSummaryItem(
                  'الحسابات',
                  accounts.length.toString(),
                  Icons.link,
                  AppColors.neonPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'إجمالي المنشورات',
                  _formatNumber(totalPosts),
                  Icons.post_add,
                  AppColors.neonMagenta,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.darkBorder,
              ),
              Expanded(
                child: _buildSummaryItem(
                  'معدل التفاعل',
                  '${avgEngagement.toStringAsFixed(1)}%',
                  Icons.favorite,
                  AppColors.neonPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Followers by platform
  Widget _buildFollowersByPlatform(List<dynamic> accounts) {
    if (accounts.isEmpty) {
      return _buildNoDataCard(
        'لا توجد بيانات',
        'قم بربط حساباتك لعرض توزيع المتابعين',
        Icons.pie_chart_outline,
      );
    }

    // Group followers by platform
    final Map<String, int> platformFollowers = {};
    for (var account in accounts) {
      final platform = account.platform?.toString().toLowerCase() ?? 'other';
      final f = account.stats?.followers ?? 0;
      final followers = f is int ? f : (f as num).toInt();
      final current = platformFollowers[platform] ?? 0;
      platformFollowers[platform] = current + followers;
    }

    final totalFollowers = platformFollowers.values.fold(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: platformFollowers.entries.map((entry) {
          final platform = entry.key;
          final followers = entry.value;
          final percentage = totalFollowers > 0 ? (followers / totalFollowers * 100) : 0.0;
          final color = _getPlatformColor(platform);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Icon(_getPlatformIcon(platform), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _capitalizeFirst(platform),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatNumber(followers),
                            style: TextStyle(
                              color: color,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: AppColors.darkBorder.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Accounts growth card
  Widget _buildAccountsGrowthCard(List<dynamic> accounts) {
    if (accounts.isEmpty) {
      return _buildNoDataCard(
        'لا توجد بيانات نمو',
        'ابدأ بربط حساباتك لتتبع نموها',
        Icons.trending_up_outlined,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص الحسابات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${accounts.length} حساب متصل',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Accounts list
          ...accounts.take(5).map((account) {
            final platform = account.platform ?? 'unknown';
            final color = _getPlatformColor(platform);
            final followers = account.stats?.followers ?? 0;
            final engagement = account.stats?.engagementRate ?? 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      image: account.profileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(account.profileImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: account.profileImageUrl == null
                        ? Icon(_getPlatformIcon(platform), color: color, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.accountName ?? 'حساب غير معروف',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _capitalizeFirst(platform),
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatNumber(followers),
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${engagement.toStringAsFixed(1)}% تفاعل',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          if (accounts.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              'و ${accounts.length - 5} حساب آخر...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowerGrowth() {
    return Obx(() {
      final history = _analyticsService?.getGrowthHistory(days: 30) ?? [];
      
      if (history.isEmpty) {
        return _buildNoDataCard(
          'لا توجد بيانات نمو',
          'سيظهر الرسم البياني بعد تجميع بيانات يومية',
          Icons.trending_up,
        );
      }

      // Prepare spots
      final List<FlSpot> spots = [];
      double maxY = 0;
      
      for (int i = 0; i < history.length; i++) {
        final followers = history[i].totalFollowers.toDouble();
        spots.add(FlSpot(i.toDouble(), followers));
        if (followers > maxY) maxY = followers;
      }
      
      // Add padding to maxY
      maxY = maxY * 1.2;
      if (maxY == 0) maxY = 100;

      return Container(
        height: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyanShadow.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.darkBorder.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < history.length) {
                      // Show date every 5 days if too many points
                      if (history.length > 10 && index % 5 != 0) return const Text('');
                      
                      final date = history[index].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('d MMM', 'ar').format(date),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatNumber(value.toInt()),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.4,
                gradient: AppColors.neonGradient,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.darkCard,
                      strokeWidth: 3,
                      strokeColor: AppColors.neonMagenta,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonMagenta.withOpacity(0.4),
                      AppColors.neonMagenta.withOpacity(0.1),
                      AppColors.neonMagenta.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
