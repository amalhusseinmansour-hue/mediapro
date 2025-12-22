import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/wallet_recharge_service.dart';
import '../../services/auth_service.dart';
import '../../models/wallet_recharge_request.dart';

class RechargeRequestsScreen extends StatefulWidget {
  const RechargeRequestsScreen({super.key});

  @override
  State<RechargeRequestsScreen> createState() => _RechargeRequestsScreenState();
}

class _RechargeRequestsScreenState extends State<RechargeRequestsScreen>
    with SingleTickerProviderStateMixin {
  final WalletRechargeService _rechargeService = Get.find<WalletRechargeService>();
  final AuthService _authService = Get.find<AuthService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final userId = _authService.currentUser.value?.id;
    if (userId != null) {
      await _rechargeService.getUserRequests(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'طلبات الشحن',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonCyan),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonCyan),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              if (_rechargeService.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonCyan),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildAllRequests(),
                  _buildPendingRequests(),
                  _buildApprovedRequests(),
                  _buildRejectedRequests(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.cyanPurpleGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: [
          Tab(text: 'الكل (${_rechargeService.requests.length})'),
          Tab(text: 'قيد الانتظار (${_rechargeService.pendingRequests.length})'),
          Tab(text: 'المقبولة (${_rechargeService.approvedRequests.length})'),
          Tab(text: 'المرفوضة (${_rechargeService.rejectedRequests.length})'),
        ],
      ),
    );
  }

  Widget _buildAllRequests() {
    return Obx(() {
      if (_rechargeService.requests.isEmpty) {
        return _buildEmptyState('لا توجد طلبات');
      }
      return _buildRequestsList(_rechargeService.requests);
    });
  }

  Widget _buildPendingRequests() {
    return Obx(() {
      if (_rechargeService.pendingRequests.isEmpty) {
        return _buildEmptyState('لا توجد طلبات قيد الانتظار');
      }
      return _buildRequestsList(_rechargeService.pendingRequests);
    });
  }

  Widget _buildApprovedRequests() {
    return Obx(() {
      if (_rechargeService.approvedRequests.isEmpty) {
        return _buildEmptyState('لا توجد طلبات مقبولة');
      }
      return _buildRequestsList(_rechargeService.approvedRequests);
    });
  }

  Widget _buildRejectedRequests() {
    return Obx(() {
      if (_rechargeService.rejectedRequests.isEmpty) {
        return _buildEmptyState('لا توجد طلبات مرفوضة');
      }
      return _buildRequestsList(_rechargeService.rejectedRequests);
    });
  }

  Widget _buildRequestsList(List<WalletRechargeRequest> requests) {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: AppColors.neonCyan,
      backgroundColor: AppColors.darkCard,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(requests[index]);
        },
      ),
    );
  }

  Widget _buildRequestCard(WalletRechargeRequest request) {
    Color statusColor;
    IconData statusIcon;

    if (request.isPending) {
      statusColor = const Color(0xFFFFD700);
      statusIcon = Icons.pending;
    } else if (request.isApproved) {
      statusColor = const Color(0xFF00E676);
      statusIcon = Icons.check_circle;
    } else {
      statusColor = const Color(0xFFFF5252);
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.2),
                  statusColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      request.statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${request.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المبلغ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      request.formattedAmount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                if (request.paymentMethod != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.textSecondary, height: 1),
                  const SizedBox(height: 12),
                  _buildInfoRow('طريقة الدفع', request.paymentMethod!),
                ],

                if (request.bankName != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('البنك', request.bankName!),
                ],

                if (request.transactionReference != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('رقم المرجع', request.transactionReference!),
                ],

                const SizedBox(height: 12),
                const Divider(color: AppColors.textSecondary, height: 1),
                const SizedBox(height: 12),

                _buildInfoRow('تاريخ الطلب', _formatDate(request.createdAt)),

                if (request.processedAt != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('تاريخ المعالجة', _formatDate(request.processedAt!)),
                ],

                if (request.adminNotes != null && request.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes, color: statusColor, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'ملاحظات الإدارة',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.adminNotes!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (request.receiptUrl != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showReceiptDialog(request.receiptUrl!),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('عرض الإيصال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
                      foregroundColor: AppColors.neonCyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.cyanPurpleGradient.scale(0.3),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(String receiptUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'صورة الإيصال',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Image
              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    receiptUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.neonCyan),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red),
                            SizedBox(height: 8),
                            Text(
                              'فشل تحميل الصورة',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
}
