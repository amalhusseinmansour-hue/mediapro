import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/users_management_service.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final UsersManagementService _usersService = Get.put(
    UsersManagementService(),
  );
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStatsCards(),
            _buildFiltersSection(),
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
      floatingActionButton: _buildRefreshButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.neonCyan, AppColors.neonPurple],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'إدارة المستخدمين',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            '${_usersService.allUsers.length} مستخدم',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
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
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final stats = _usersService.statistics;
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي',
                stats['total'].toString(),
                Icons.people_outline,
                AppColors.neonCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'نشط',
                stats['active'].toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'مدفوع',
                (stats['individual']! + stats['business']!).toString(),
                Icons.workspace_premium_outlined,
                AppColors.neonPurple,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
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
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _usersService.setSearchQuery(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'بحث بالاسم، البريد، أو رقم الهاتف...',
                hintStyle: TextStyle(color: AppColors.textLight),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.neonCyan),
                suffixIcon: Obx(
                  () => _usersService.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textLight,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _usersService.setSearchQuery('');
                          },
                        )
                      : const SizedBox(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => Row(
                      children: [
                        _buildFilterChip('الكل', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('مجاني', 'free'),
                        const SizedBox(width: 8),
                        _buildFilterChip('أفراد', 'individual'),
                        const SizedBox(width: 8),
                        _buildFilterChip('شركات', 'business'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSortButton(),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _usersService.filterTier.value == value;
    return InkWell(
      onTap: () => _usersService.setFilterTier(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.cyanPurpleGradient : null,
          color: isSelected ? null : AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan
                : AppColors.textLight.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.sort, color: AppColors.neonCyan),
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3), width: 1),
      ),
      onSelected: (value) => _usersService.setSorting(value),
      itemBuilder: (context) => [
        _buildSortMenuItem('تاريخ التسجيل', 'createdAt', Icons.calendar_today),
        _buildSortMenuItem('الاسم', 'name', Icons.sort_by_alpha),
        _buildSortMenuItem('آخر تسجيل دخول', 'lastLogin', Icons.access_time),
      ],
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(
    String label,
    String value,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.neonCyan),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Obx(() {
      if (_usersService.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        );
      }

      final users = _usersService.filteredUsers;

      if (users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: AppColors.textLight.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد نتائج',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildUserCard(users[index]),
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildUserCard(UserModel user) {
    final tierColor = _getTierColor(user.subscriptionTier);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tierColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tierColor.withValues(alpha: 0.3),
                      tierColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tierColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.person, color: tierColor, size: 32),
                        ),
                      )
                    : Icon(Icons.person, color: tierColor, size: 32),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isPhoneVerified)
                          Icon(
                            Icons.verified,
                            color: AppColors.success,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phoneNumber,
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (user.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: user.isActive ? AppColors.success : AppColors.error,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  user.isActive ? 'نشط' : 'معطل',
                  style: TextStyle(
                    color: user.isActive ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.textLight, height: 1),
          const SizedBox(height: 16),
          // User details
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                user.tierDisplayName,
                Icons.workspace_premium,
                tierColor,
              ),
              _buildInfoChip(
                'منذ ${_getTimeAgo(user.createdAt)}',
                Icons.calendar_today,
                AppColors.textLight,
              ),
              if (user.lastLogin != null)
                _buildInfoChip(
                  'آخر دخول: ${_getTimeAgo(user.lastLogin!)}',
                  Icons.access_time,
                  AppColors.textLight,
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  user.isActive ? 'تعطيل' : 'تفعيل',
                  user.isActive ? Icons.block : Icons.check_circle,
                  user.isActive ? AppColors.error : AppColors.success,
                  () => _showToggleStatusDialog(user),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'تعديل الباقة',
                  Icons.edit,
                  AppColors.neonCyan,
                  () => _showUpdateSubscriptionDialog(user),
                ),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                Icons.delete_outline,
                AppColors.error,
                () => _showDeleteDialog(user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Obx(
      () => FloatingActionButton(
        onPressed: _usersService.isLoading.value
            ? null
            : () => _usersService.refresh(),
        backgroundColor: AppColors.neonCyan,
        child: _usersService.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'individual':
        return AppColors.neonCyan;
      case 'business':
        return AppColors.neonPurple;
      default:
        return AppColors.textLight;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  void _showToggleStatusDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          user.isActive ? 'تعطيل المستخدم' : 'تفعيل المستخدم',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          user.isActive
              ? 'هل أنت متأكد من تعطيل هذا المستخدم؟ لن يتمكن من الوصول إلى التطبيق.'
              : 'هل أنت متأكد من تفعيل هذا المستخدم؟',
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              _usersService.updateUserStatus(user.id, !user.isActive);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(user.isActive ? 'تعطيل' : 'تفعيل'),
          ),
        ],
      ),
    );
  }

  void _showUpdateSubscriptionDialog(UserModel user) {
    String selectedTier = user.subscriptionTier;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تعديل الاشتراك',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text(
                    'مجاني',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'free',
                  groupValue: selectedTier,
                  activeColor: AppColors.neonCyan,
                  onChanged: (value) => setState(() => selectedTier = value!),
                ),
                RadioListTile<String>(
                  title: const Text(
                    'باقة الأفراد',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'individual',
                  groupValue: selectedTier,
                  activeColor: AppColors.neonCyan,
                  onChanged: (value) => setState(() => selectedTier = value!),
                ),
                RadioListTile<String>(
                  title: const Text(
                    'باقة الشركات',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'business',
                  groupValue: selectedTier,
                  activeColor: AppColors.neonPurple,
                  onChanged: (value) => setState(() => selectedTier = value!),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final endDate = selectedTier == 'free'
                  ? null
                  : DateTime.now().add(const Duration(days: 30));
              _usersService.updateUserSubscription(
                userId: user.id,
                tier: selectedTier,
                endDate: endDate,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف المستخدم',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'هل أنت متأكد من حذف ${user.name}؟ هذا الإجراء لا يمكن التراجع عنه.',
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              _usersService.deleteUser(user.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
