import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/postiz_manager.dart';

/// شاشة التحليلات والإحصائيات
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final PostizManager _postizManager = PostizManager();

  AnalyticsSummary? _summary;
  List<SocialAccount> _accounts = [];
  bool _isLoading = true;
  String _selectedPeriod = '30days';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final startDate = _getStartDate();
      final endDate = DateTime.now();

      final summary = await _postizManager.getAnalyticsSummary(
        startDate: startDate,
        endDate: endDate,
      );

      final accounts = await _postizManager.getConnectedAccounts();

      setState(() {
        _summary = summary;
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('فشل في تحميل التحليلات: $e');
    }
  }

  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case '7days':
        return DateTime.now().subtract(const Duration(days: 7));
      case '30days':
        return DateTime.now().subtract(const Duration(days: 30));
      case '90days':
        return DateTime.now().subtract(const Duration(days: 90));
      default:
        return DateTime.now().subtract(const Duration(days: 30));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليلات'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7days', child: Text('آخر 7 أيام')),
              const PopupMenuItem(value: '30days', child: Text('آخر 30 يوم')),
              const PopupMenuItem(value: '90days', child: Text('آخر 90 يوم')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ملخص الإحصائيات
                    _buildSummaryCards(),
                    const SizedBox(height: 24),

                    // رسم بياني للتفاعل
                    _buildEngagementChart(),
                    const SizedBox(height: 24),

                    // إحصائيات الحسابات
                    _buildAccountsStats(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    if (_summary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('لا توجد بيانات متاحة'),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'المنشورات',
          _summary!.totalPosts.toString(),
          Icons.post_add,
          Colors.blue,
        ),
        _buildStatCard(
          'الوصول',
          _formatNumber(_summary!.totalReach),
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          'التفاعل',
          _formatNumber(_summary!.totalEngagement),
          Icons.favorite,
          Colors.red,
        ),
        _buildStatCard(
          'معدل التفاعل',
          '${_summary!.engagementRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معدل التفاعل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateChartData(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    // بيانات تجريبية - يجب استبدالها ببيانات حقيقية من API
    return [
      const FlSpot(0, 1),
      const FlSpot(1, 3),
      const FlSpot(2, 2),
      const FlSpot(3, 5),
      const FlSpot(4, 3.5),
      const FlSpot(5, 4),
      const FlSpot(6, 6),
    ];
  }

  Widget _buildAccountsStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إحصائيات الحسابات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_accounts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا توجد حسابات مربوطة'),
            ),
          )
        else
          Column(
            children: _accounts.map((account) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: account.profilePicture != null
                        ? NetworkImage(account.profilePicture!)
                        : null,
                    child: account.profilePicture == null
                        ? Text(account.platform.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(account.name),
                  subtitle: Text('@${account.username}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      _showAccountDetails(account);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAccountDetails(SocialAccount account) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account.name),
        content: const Text('تحميل التفاصيل...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );

    try {
      final analytics = await _postizManager.getAccountAnalytics(
        integrationId: account.integrationId,
        startDate: _getStartDate(),
        endDate: DateTime.now(),
      );

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(account.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('المتابعون', analytics.followers.toString()),
              _buildDetailRow('المنشورات', analytics.totalPosts.toString()),
              _buildDetailRow('الوصول', _formatNumber(analytics.totalReach)),
              _buildDetailRow('التفاعل', _formatNumber(analytics.totalEngagement)),
              _buildDetailRow(
                'معدل التفاعل',
                '${analytics.averageEngagementRate.toStringAsFixed(1)}%',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showError('فشل في تحميل التفاصيل: $e');
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
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
