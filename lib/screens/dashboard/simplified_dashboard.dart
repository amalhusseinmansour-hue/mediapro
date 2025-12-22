import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/social_accounts_service.dart';
import '../../services/subscription_service.dart';
import '../../services/wallet_service.dart';

class SimplifiedDashboard extends StatefulWidget {
  const SimplifiedDashboard({super.key});

  @override
  State<SimplifiedDashboard> createState() => _SimplifiedDashboardState();
}

class _SimplifiedDashboardState extends State<SimplifiedDashboard> {
  final AuthService _authService = Get.find();
  final AnalyticsService _analyticsService = Get.find();
  final SocialAccountsService _accountsService = Get.find();
  final SubscriptionService _subscriptionService = Get.find();
  final WalletService _walletService = Get.find();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Load analytics, accounts, subscription info
    // Methods removed or not implemented yet
    /* await Future.wait([
      _analyticsService.fetchUsage(),
      _accountsService.fetchAccounts(),
      _subscriptionService.fetchCurrentSubscription(),
      _walletService.fetchWallet(),
    ]); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 0 ? _buildCreatePostButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return _buildAccountsScreen();
      case 2:
        return _buildAnalyticsScreen();
      case 3:
        return _buildProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  // Home Screen - Overview
  Widget _buildHomeScreen() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: const Color(0xFF1A1A1A),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'welcome'.tr,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Obx(() => Text(
                    _authService.currentUser.value?.name ?? 'User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Get.toNamed('/notifications'),
            ),
          ],
        ),

        // Stats Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentPosts(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Stats Grid
  Widget _buildStatsGrid() {
    return Obx(() {
      final usage = _analyticsService.usageStats.value;
      // final subscription = _subscriptionService.currentSubscription.value; // Not implemented

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard(
            title: 'connected_accounts'.tr,
            value: '${_accountsService.accounts.length}',
            icon: Icons.link,
            color: Colors.blue,
          ),
          _buildStatCard(
            title: 'posts_this_month'.tr,
            value: '${usage?.posts.current ?? 0}/${usage?.posts.limit ?? 0}',
            icon: Icons.post_add,
            color: Colors.green,
          ),
          _buildStatCard(
            title: 'scheduled_posts'.tr,
            value: '0', // TODO: Get from service
            icon: Icons.schedule,
            color: Colors.orange,
          ),
          _buildStatCard(
            title: 'wallet_balance'.tr,
            value: 'AED 0', // TODO: Get from wallet service
            icon: Icons.account_balance_wallet,
            color: Colors.purple,
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Quick Actions
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'connect_account'.tr,
                icon: Icons.add_link,
                color: Colors.blue,
                onTap: () => Get.toNamed('/connect-accounts'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: 'schedule_post'.tr,
                icon: Icons.schedule,
                color: Colors.orange,
                onTap: () => Get.toNamed('/schedule-post'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Recent Posts
  Widget _buildRecentPosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recent_posts'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/posts-history'),
              child: Text('see_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.post_add, size: 48, color: Colors.grey[700]),
                const SizedBox(height: 12),
                Text(
                  'no_posts_yet'.tr,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Accounts Screen
  Widget _buildAccountsScreen() {
    return Center(child: Text('Accounts Screen - Coming Soon'));
  }

  // Analytics Screen
  Widget _buildAnalyticsScreen() {
    return Center(child: Text('Analytics Screen - Coming Soon'));
  }

  // Profile Screen
  Widget _buildProfileScreen() {
    return Center(child: Text('Profile Screen - Coming Soon'));
  }

  // Create Post FAB
  Widget _buildCreatePostButton() {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/create-post'),
      backgroundColor: const Color(0xFF6366F1),
      icon: const Icon(Icons.add),
      label: Text('create_post'.tr),
    );
  }

  // Bottom Navigation
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.link_outlined),
            activeIcon: const Icon(Icons.link),
            label: 'accounts'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
            label: 'analytics'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'profile'.tr,
          ),
        ],
      ),
    );
  }
}
