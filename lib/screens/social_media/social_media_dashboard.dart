import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/postiz_manager.dart';
import 'connect_accounts_screen.dart';
import 'create_post_screen.dart';
import 'analytics_screen.dart';

/// لوحة التحكم الرئيسية لإدارة Social Media
class SocialMediaDashboard extends StatefulWidget {
  const SocialMediaDashboard({Key? key}) : super(key: key);

  @override
  State<SocialMediaDashboard> createState() => _SocialMediaDashboardState();
}

class _SocialMediaDashboardState extends State<SocialMediaDashboard> {
  final PostizManager _postizManager = PostizManager();

  List<SocialAccount> _accounts = [];
  List<Post> _recentPosts = [];
  AnalyticsSummary? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // تحميل البيانات بالتوازي
      final results = await Future.wait([
        _postizManager.getConnectedAccounts(),
        _postizManager.getPosts(),
        _postizManager.getAnalyticsSummary(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      ]);

      setState(() {
        _accounts = results[0] as List<SocialAccount>;
        _recentPosts = (results[1] as List<Post>).take(5).toList();
        _analytics = results[2] as AnalyticsSummary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('فشل في تحميل البيانات: $e');
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
        title: const Text('إدارة وسائل التواصل'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // إحصائيات سريعة
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // أزرار الإجراءات السريعة
                    _buildQuickActions(),
                    const SizedBox(height: 24),

                    // الحسابات المربوطة
                    _buildConnectedAccountsSection(),
                    const SizedBox(height: 24),

                    // المنشورات الأخيرة
                    _buildRecentPostsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الأداء (آخر 30 يوم)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'المنشورات',
                    _analytics?.totalPosts.toString() ?? '0',
                    Icons.post_add,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الوصول',
                    _formatNumber(_analytics?.totalReach ?? 0),
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'التفاعل',
                    _formatNumber(_analytics?.totalEngagement ?? 0),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'معدل التفاعل',
                    '${_analytics?.engagementRate.toStringAsFixed(1) ?? '0'}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
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
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجراءات سريعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'إنشاء منشور',
                Icons.create,
                Colors.blue,
                () => Get.to(() => const CreatePostScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'ربط حساب',
                Icons.add_link,
                Colors.green,
                () => Get.to(() => const ConnectAccountsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'التحليلات',
                Icons.analytics,
                Colors.purple,
                () => Get.to(() => const AnalyticsScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'الجدولة',
                Icons.schedule,
                Colors.orange,
                () => Get.to(() => const CreatePostScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الحسابات المربوطة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const ConnectAccountsScreen()),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_accounts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('لم تقم بربط أي حساب بعد'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const ConnectAccountsScreen()),
                    child: const Text('ربط الآن'),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final account = _accounts[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: account.profilePicture != null
                            ? NetworkImage(account.profilePicture!)
                            : null,
                        child: account.profilePicture == null
                            ? Text(
                                account.platform.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 24),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        account.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecentPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المنشورات الأخيرة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_recentPosts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'لا توجد منشورات بعد',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentPosts.length,
            itemBuilder: (context, index) {
              final post = _recentPosts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: _getStatusIcon(post.status),
                  title: Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _getPostSubtitle(post),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: _getStatusChip(post.status),
                ),
              );
            },
          ),
      ],
    );
  }

  Icon _getStatusIcon(PostStatus status) {
    switch (status) {
      case PostStatus.published:
        return const Icon(Icons.check_circle, color: Colors.green);
      case PostStatus.scheduled:
        return const Icon(Icons.schedule, color: Colors.orange);
      case PostStatus.draft:
        return const Icon(Icons.edit, color: Colors.grey);
      case PostStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  Widget _getStatusChip(PostStatus status) {
    Color color;
    String label;

    switch (status) {
      case PostStatus.published:
        color = Colors.green;
        label = 'منشور';
        break;
      case PostStatus.scheduled:
        color = Colors.orange;
        label = 'مجدول';
        break;
      case PostStatus.draft:
        color = Colors.grey;
        label = 'مسودة';
        break;
      case PostStatus.failed:
        color = Colors.red;
        label = 'فشل';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  String _getPostSubtitle(Post post) {
    if (post.status == PostStatus.scheduled && post.scheduledAt != null) {
      return 'سينشر في: ${_formatDate(post.scheduledAt!)}';
    } else if (post.publishedAt != null) {
      return 'نُشر في: ${_formatDate(post.publishedAt!)}';
    }
    return 'مسودة';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
