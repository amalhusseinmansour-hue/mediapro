import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class LiveAnalyticsDashboard extends StatefulWidget {
  const LiveAnalyticsDashboard({super.key});

  @override
  State<LiveAnalyticsDashboard> createState() => _LiveAnalyticsDashboardState();
}

class _LiveAnalyticsDashboardState extends State<LiveAnalyticsDashboard> {
  final RxInt liveViews = 0.obs;
  final RxInt liveLikes = 0.obs;
  final RxInt liveComments = 0.obs;
  final RxInt liveShares = 0.obs;
  final RxBool isLive = true.obs;

  Timer? _liveUpdateTimer;

  @override
  void initState() {
    super.initState();
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _liveUpdateTimer?.cancel();
    super.dispose();
  }

  void _startLiveUpdates() {
    // Simulate live data updates every 2 seconds
    _liveUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (isLive.value) {
        liveViews.value += DateTime.now().second % 10;
        liveLikes.value += DateTime.now().second % 5;
        liveComments.value += DateTime.now().second % 3;
        liveShares.value += DateTime.now().second % 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E1E2E),
            flexibleSpace: FlexibleSpaceBar(
              title: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive.value)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isLive.value ? 'LIVE Analytics' : 'Analytics Paused',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Obx(() => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const Text(
                            '📊 إحصائيات حية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تحديث كل ${isLive.value ? '2 ثانية' : 'متوقف'}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ),
            actions: [
              Obx(() => IconButton(
                    icon: Icon(
                      isLive.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: isLive.value ? Colors.red : Colors.green,
                    ),
                    onPressed: () => isLive.value = !isLive.value,
                  )),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  liveViews.value = 0;
                  liveLikes.value = 0;
                  liveComments.value = 0;
                  liveShares.value = 0;
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLiveStatsGrid(),
                  const SizedBox(height: 20),
                  _buildEngagementChart(),
                  const SizedBox(height: 20),
                  _buildPlatformBreakdown(),
                  const SizedBox(height: 20),
                  _buildTopPerformingPosts(),
                  const SizedBox(height: 20),
                  _buildRealTimeActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildLiveStatCard(
          'المشاهدات',
          liveViews,
          Icons.visibility_rounded,
          const Color(0xFF00D9FF),
        ),
        _buildLiveStatCard(
          'الإعجابات',
          liveLikes,
          Icons.favorite_rounded,
          Colors.red,
        ),
        _buildLiveStatCard(
          'التعليقات',
          liveComments,
          Icons.comment_rounded,
          Colors.green,
        ),
        _buildLiveStatCard(
          'المشاركات',
          liveShares,
          Icons.share_rounded,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildLiveStatCard(String label, RxInt value, IconData icon, Color color) {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1E2E),
                color.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: value.value),
                duration: const Duration(milliseconds: 500),
                builder: (context, animValue, child) {
                  return Text(
                    animValue.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildEngagementChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 معدل التفاعل',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Obx(() => LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade800,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}h',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          10,
                          (i) => FlSpot(i.toDouble(), (liveViews.value * (i + 1) / 10).toDouble()),
                        ),
                        isCurved: true,
                        color: const Color(0xFF00D9FF),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌐 التوزيع حسب المنصة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildPlatformRow('Facebook', 45, const Color(0xFF1877F2)),
          _buildPlatformRow('Instagram', 30, const Color(0xFFE1306C)),
          _buildPlatformRow('Twitter', 15, const Color(0xFF1DA1F2)),
          _buildPlatformRow('LinkedIn', 10, const Color(0xFF0A66C2)),
        ],
      ),
    );
  }

  Widget _buildPlatformRow(String platform, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                platform,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '$percentage%',
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
              value: percentage / 100,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingPosts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 أفضل المنشورات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildPostItem('منشور عن التسويق الرقمي', 1240, 89),
          _buildPostItem('نصائح للمبتدئين في البيزنس', 980, 76),
          _buildPostItem('قصة نجاح ملهمة', 756, 64),
        ],
      ),
    );
  }

  Widget _buildPostItem(String title, int engagement, int percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.trending_up, color: Color(0xFF00D9FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$engagement تفاعل',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+$percentage%',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '⚡ النشاط الحالي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem('أحمد محمد', 'أعجب بمنشورك', 'الآن', Icons.favorite, Colors.red),
          _buildActivityItem('سارة علي', 'علّقت على منشورك', 'منذ دقيقة', Icons.comment, Colors.blue),
          _buildActivityItem('محمد خالد', 'شارك منشورك', 'منذ دقيقتين', Icons.share, Colors.green),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String user, String action, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  action,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
