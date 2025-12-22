import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/social_account_model.dart';

class AdvancedAccountsManagementScreen extends StatefulWidget {
  const AdvancedAccountsManagementScreen({super.key});

  @override
  State<AdvancedAccountsManagementScreen> createState() =>
      _AdvancedAccountsManagementScreenState();
}

class _AdvancedAccountsManagementScreenState
    extends State<AdvancedAccountsManagementScreen> {
  // TODO: May be used for future OAuth integration
  // final SocialAccountsService _accountsService =
  //     Get.find<SocialAccountsService>();
  // final OAuthService _oauthService = Get.find<OAuthService>();

  final RxBool _isLoading = false.obs;
  final RxBool _selectMode = false.obs;
  final RxList<String> _selectedAccounts = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _refreshAccounts();
  }

  Future<void> _refreshAccounts() async {
    _isLoading.value = true;
    // TODO: Implement refresh logic
    await Future.delayed(const Duration(seconds: 1));
    _isLoading.value = false;
  }

  void _toggleSelection(String accountId) {
    if (_selectedAccounts.contains(accountId)) {
      _selectedAccounts.remove(accountId);
    } else {
      _selectedAccounts.add(accountId);
    }
  }

  Future<void> _bulkDisconnect() async {
    if (_selectedAccounts.isEmpty) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text(
          'هل تريد فصل ${_selectedAccounts.length} حساب؟ لن تتمكن من النشر عليها بعد الفصل.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('فصل'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _isLoading.value = true;
      for (final _ in _selectedAccounts) {
        // TODO: Implement disconnect logic
        await Future.delayed(const Duration(milliseconds: 300));
        // Disconnect account with the given accountId
      }
      _selectedAccounts.clear();
      _selectMode.value = false;
      _isLoading.value = false;
      Get.snackbar(
        'نجاح',
        'تم فصل الحسابات المحددة',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      _refreshAccounts();
    }
  }

  Future<void> _reconnectAccount(SocialAccountModel account) async {
    Get.snackbar(
      'إعادة الربط',
      'جاري إعادة ربط الحساب...',
      backgroundColor: Color(0xFF1E1E2E),
      colorText: Colors.white,
    );

    // TODO: Implement reconnection logic using OAuth
    await Future.delayed(const Duration(seconds: 2));

    Get.back();
    Get.snackbar(
      'نجاح',
      'تم إعادة ربط الحساب بنجاح',
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
    _refreshAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          'إدارة الحسابات المتقدمة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1E1E2E),
        elevation: 0,
        actions: [
          Obx(
            () => _selectMode.value
                ? Row(
                    children: [
                      if (_selectedAccounts.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: _bulkDisconnect,
                          tooltip: 'فصل المحدد',
                        ),
                      TextButton(
                        onPressed: () {
                          _selectMode.value = false;
                          _selectedAccounts.clear();
                        },
                        child: Text(
                          'إلغاء',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : IconButton(
                    icon: Icon(Icons.checklist_rounded, color: Colors.white),
                    onPressed: () => _selectMode.value = true,
                    tooltip: 'تحديد متعدد',
                  ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshAccounts,
          ),
        ],
      ),
      body: Obx(
        () => _isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF00D9FF)),
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshAccounts,
                color: Color(0xFF00D9FF),
                backgroundColor: Color(0xFF1E1E2E),
                child: _buildAccountsList(),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to connect new account screen
          Get.toNamed('/accounts');
        },
        backgroundColor: Color(0xFF00D9FF),
        icon: Icon(Icons.add_rounded, color: Color(0xFF0A0A0A)),
        label: Text(
          'ربط حساب جديد',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsList() {
    // Mock data for demonstration
    final mockAccounts = [
      SocialAccountModel(
        id: '1',
        userId: 'user123',
        platform: 'facebook',
        accountName: 'محمد أحمد',
        accountId: 'fb_user_fb',
        profileImageUrl: '',
        connectedDate: DateTime.now().subtract(Duration(days: 10)),
      ),
      SocialAccountModel(
        id: '2',
        userId: 'user123',
        platform: 'instagram',
        accountName: 'أحمد علي',
        accountId: 'ig_user_insta',
        profileImageUrl: '',
        connectedDate: DateTime.now().subtract(Duration(days: 5)),
      ),
      SocialAccountModel(
        id: '3',
        userId: 'user123',
        platform: 'twitter',
        accountName: 'علي محمود',
        accountId: 'tw_user_twitter',
        profileImageUrl: '',
        connectedDate: DateTime.now().subtract(Duration(days: 20)),
      ),
    ];

    if (mockAccounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: Colors.grey.shade700,
            ),
            SizedBox(height: 20),
            Text(
              'لا توجد حسابات مربوطة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'اضغط على الزر أدناه لربط حساب جديد',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: mockAccounts.length,
      itemBuilder: (context, index) {
        final account = mockAccounts[index];
        return _buildAccountCard(account);
      },
    );
  }

  Widget _buildAccountCard(SocialAccountModel account) {
    final isSelected = _selectedAccounts.contains(account.id);
    final healthScore = _calculateHealthScore(account);
    final healthColor = _getHealthColor(healthScore);

    return Obx(
      () => Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: _selectMode.value && isSelected
              ? Border.all(color: Color(0xFF00D9FF), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectMode.value
                ? () => _toggleSelection(account.id)
                : () => _showAccountDetails(account),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Platform Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getPlatformColors(account.platform),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getPlatformIcon(account.platform),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      // Account Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.accountName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '@${account.accountId}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  account.isActive
                                      ? Icons.check_circle
                                      : Icons.error_outline,
                                  size: 16,
                                  color: account.isActive
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  account.isConnected ? 'متصل' : 'غير متصل',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: account.isConnected
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Selection Checkbox
                      if (_selectMode.value)
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(account.id),
                          activeColor: Color(0xFF00D9FF),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Health Score
                  Row(
                    children: [
                      Text(
                        'صحة الحساب:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: healthScore / 100,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: AlwaysStoppedAnimation(healthColor),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${healthScore.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: healthColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Action Buttons
                  if (!_selectMode.value)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!account.isConnected)
                          TextButton.icon(
                            onPressed: () => _reconnectAccount(account),
                            icon: Icon(
                              Icons.sync_rounded,
                              size: 18,
                              color: Color(0xFF00D9FF),
                            ),
                            label: Text(
                              'إعادة الربط',
                              style: TextStyle(color: Color(0xFF00D9FF)),
                            ),
                          ),
                        SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _showAccountDetails(account),
                          icon: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                          label: Text(
                            'التفاصيل',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateHealthScore(SocialAccountModel account) {
    if (!account.isConnected) return 30.0;

    // Mock calculation - in real app, calculate based on:
    // - Connection status
    // - Last successful post
    // - Error rate
    // - Token expiry
    return 85.0 + (DateTime.now().second % 15);
  }

  Color _getHealthColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'twitter':
        return Icons.tag_rounded;
      case 'linkedin':
        return Icons.business_rounded;
      case 'tiktok':
        return Icons.music_note_rounded;
      default:
        return Icons.public_rounded;
    }
  }

  List<Color> _getPlatformColors(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return [Color(0xFF1877F2), Color(0xFF0D5EBD)];
      case 'instagram':
        return [Color(0xFFC13584), Color(0xFFE1306C)];
      case 'twitter':
        return [Color(0xFF1DA1F2), Color(0xFF0D8BD9)];
      case 'linkedin':
        return [Color(0xFF0A66C2), Color(0xFF004182)];
      case 'tiktok':
        return [Color(0xFF000000), Color(0xFF333333)];
      default:
        return [Color(0xFF6A11CB), Color(0xFF2575FC)];
    }
  }

  void _showAccountDetails(SocialAccountModel account) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getPlatformColors(account.platform),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPlatformIcon(account.platform),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.fullName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '@${account.username}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildDetailRow(
              'المنصة',
              account.platform.toUpperCase(),
              Icons.public_rounded,
            ),
            _buildDetailRow(
              'الحالة',
              account.isConnected ? 'متصل' : 'غير متصل',
              account.isConnected ? Icons.check_circle : Icons.error_outline,
            ),
            _buildDetailRow(
              'تاريخ الربط',
              '${account.connectedAt.day}/${account.connectedAt.month}/${account.connectedAt.year}',
              Icons.calendar_today_rounded,
            ),
            _buildDetailRow(
              'صحة الحساب',
              '${_calculateHealthScore(account).toInt()}%',
              Icons.favorite_rounded,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _reconnectAccount(account);
                    },
                    icon: Icon(Icons.sync_rounded),
                    label: Text('إعادة الربط'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00D9FF),
                      foregroundColor: Color(0xFF0A0A0A),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      // Disconnect logic
                    },
                    icon: Icon(Icons.link_off_rounded),
                    label: Text('فصل الحساب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFF00D9FF)),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
