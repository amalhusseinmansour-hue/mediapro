import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/admin_api_service.dart';
import 'admin_users_screen.dart';
import 'admin_ads_review_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_reports_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AdminApiService _adminService;

  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initService();
  }

  Future<void> _initService() async {
    // Initialize or find the service
    if (!Get.isRegistered<AdminApiService>()) {
      Get.put(AdminApiService());
    }
    _adminService = Get.find<AdminApiService>();
    await _loadStats();
    _animationController.forward();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.fetchDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading stats: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get stat values with fallback
  String _getUsersCount() {
    final users = _stats['users'];
    if (users is Map) {
      return _formatNumber(users['total'] ?? 0);
    }
    return '0';
  }

  String _getUsersTrend() {
    final users = _stats['users'];
    if (users is Map) {
      return users['trend'] ?? '+0%';
    }
    return '+0%';
  }

  String _getAdsCount() {
    final ads = _stats['ads'];
    if (ads is Map) {
      return _formatNumber(ads['total'] ?? 0);
    }
    return '0';
  }

  String _getPendingAdsCount() {
    final ads = _stats['ads'];
    if (ads is Map) {
      return _formatNumber(ads['pending'] ?? 0);
    }
    return '0';
  }

  String _getAdsTrend() {
    final ads = _stats['ads'];
    if (ads is Map) {
      return ads['trend'] ?? '+0%';
    }
    return '+0%';
  }

  String _getPaymentsTotal() {
    final payments = _stats['payments'];
    if (payments is Map) {
      final total = payments['total'] ?? 0;
      if (total is num) {
        return '\$${_formatNumber(total.toInt())}';
      }
    }
    return '\$0';
  }

  String _getPaymentsTrend() {
    final payments = _stats['payments'];
    if (payments is Map) {
      return payments['trend'] ?? '+0%';
    }
    return '+0%';
  }

  String _getSubscriptionsCount() {
    final subs = _stats['subscriptions'];
    if (subs is Map) {
      return _formatNumber(subs['total'] ?? 0);
    }
    return '0';
  }

  String _getSubscriptionsTrend() {
    final subs = _stats['subscriptions'];
    if (subs is Map) {
      return subs['trend'] ?? '+0%';
    }
    return '+0%';
  }

  String _formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1D1E33),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStats,
                  tooltip: 'تحديث',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF4CAF50),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated background circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animationController.value * 2 * 3.14159,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لوحة تحكم الأدمن',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'إدارة كاملة للتطبيق',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Statistics Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'إحصائيات سريعة',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          title: 'المستخدمين',
                          value: _getUsersCount(),
                          icon: Icons.people_rounded,
                          color: const Color(0xFF6C63FF),
                          trend: _getUsersTrend(),
                        ),
                        _buildStatCard(
                          title: 'الإعلانات',
                          value: _getAdsCount(),
                          icon: Icons.campaign_rounded,
                          color: const Color(0xFFFF6B9D),
                          trend: _getAdsTrend(),
                        ),
                        _buildStatCard(
                          title: 'المدفوعات',
                          value: _getPaymentsTotal(),
                          icon: Icons.payments_rounded,
                          color: const Color(0xFF4CAF50),
                          trend: _getPaymentsTrend(),
                        ),
                        _buildStatCard(
                          title: 'الاشتراكات',
                          value: _getSubscriptionsCount(),
                          icon: Icons.stars_rounded,
                          color: const Color(0xFFFFD700),
                          trend: _getSubscriptionsTrend(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'إدارة سريعة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      title: 'إدارة المستخدمين',
                      subtitle: 'عرض وإدارة جميع المستخدمين',
                      icon: Icons.people_rounded,
                      color: const Color(0xFF6C63FF),
                      badge: _getUsersCount(),
                      onTap: () => Get.to(() => const AdminUsersScreen()),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      title: 'مراجعة الإعلانات',
                      subtitle: 'الموافقة على الإعلانات المعلقة',
                      icon: Icons.campaign_rounded,
                      color: const Color(0xFFFF6B9D),
                      badge: _getPendingAdsCount(),
                      urgent: int.tryParse(_getPendingAdsCount()) != null &&
                          int.parse(_getPendingAdsCount()) > 0,
                      onTap: () => Get.to(() => const AdminAdsReviewScreen()),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      title: 'المدفوعات والاشتراكات',
                      subtitle: 'إدارة المعاملات المالية',
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF4CAF50),
                      badge: _getPaymentsTotal(),
                      onTap: () => Get.to(() => const AdminPaymentsScreen()),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      title: 'إعدادات التطبيق',
                      subtitle: 'AI، OTP، Payment Settings',
                      icon: Icons.settings_rounded,
                      color: const Color(0xFF00E5FF),
                      onTap: () => Get.to(() => const AdminSettingsScreen()),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      title: 'التقارير والتحليلات',
                      subtitle: 'إحصائيات مفصلة ورسوم بيانية',
                      icon: Icons.analytics_rounded,
                      color: const Color(0xFFFFD700),
                      onTap: () => Get.to(() => const AdminReportsScreen()),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    final isPositive = trend.startsWith('+') && trend != '+0%';

    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_animationController),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? const Color(0xFF4CAF50)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    bool urgent = false,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _animationController,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: urgent
                  ? Colors.red.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0.3),
              width: urgent ? 2 : 1,
            ),
            boxShadow: urgent
                ? [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: urgent
                        ? LinearGradient(
                            colors: [Colors.red, Colors.red.shade700],
                          )
                        : LinearGradient(
                            colors: [color, color.withValues(alpha: 0.8)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: urgent
                            ? Colors.red.withValues(alpha: 0.4)
                            : color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white60,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
