import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../services/business_verification_service.dart';

/// صفحة إدارة طلبات التحقق من حسابات الشركات (للمشرف)
class AdminBusinessVerificationsScreen extends StatefulWidget {
  const AdminBusinessVerificationsScreen({super.key});

  @override
  State<AdminBusinessVerificationsScreen> createState() =>
      _AdminBusinessVerificationsScreenState();
}

class _AdminBusinessVerificationsScreenState
    extends State<AdminBusinessVerificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BusinessVerificationService _verificationService;

  List<Map<String, dynamic>> _pendingVerifications = [];
  List<Map<String, dynamic>> _approvedVerifications = [];
  List<Map<String, dynamic>> _rejectedVerifications = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    try {
      _verificationService = Get.find<BusinessVerificationService>();
    } catch (e) {
      _verificationService = Get.put(BusinessVerificationService());
    }

    _loadVerifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVerifications() async {
    setState(() => _isLoading = true);

    try {
      final pending = await _verificationService.getAllVerifications(status: 'pending');
      final approved = await _verificationService.getAllVerifications(status: 'approved');
      final rejected = await _verificationService.getAllVerifications(status: 'rejected');

      setState(() {
        _pendingVerifications = pending;
        _approvedVerifications = approved;
        _rejectedVerifications = rejected;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveVerification(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الموافقة'),
        content: const Text('هل أنت متأكد من الموافقة على هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _verificationService.approveVerification(userId);
      if (success) {
        _showSuccess('تمت الموافقة على الطلب بنجاح');
        _loadVerifications();
      } else {
        _showError('فشل الموافقة على الطلب');
      }
    }
  }

  Future<void> _rejectVerification(String userId) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال سبب الرفض:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'سبب الرفض...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال سبب الرفض')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _verificationService.rejectVerification(
        userId,
        reason: reasonController.text.trim(),
      );
      if (success) {
        _showSuccess('تم رفض الطلب');
        _loadVerifications();
      } else {
        _showError('فشل رفض الطلب');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showDocumentPreview(String title, String? url) {
    if (url == null) {
      _showError('المستند غير متوفر');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, size: 50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة طلبات التحقق'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('قيد المراجعة'),
                  if (_pendingVerifications.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pendingVerifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'مقبولة'),
            const Tab(text: 'مرفوضة'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVerifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVerificationsList(_pendingVerifications, 'pending'),
                _buildVerificationsList(_approvedVerifications, 'approved'),
                _buildVerificationsList(_rejectedVerifications, 'rejected'),
              ],
            ),
    );
  }

  Widget _buildVerificationsList(List<Map<String, dynamic>> verifications, String status) {
    if (verifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending'
                  ? Icons.pending_actions
                  : (status == 'approved' ? Icons.check_circle : Icons.cancel),
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'pending'
                  ? 'لا توجد طلبات قيد المراجعة'
                  : (status == 'approved'
                      ? 'لا توجد طلبات مقبولة'
                      : 'لا توجد طلبات مرفوضة'),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVerifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: verifications.length,
        itemBuilder: (context, index) {
          final verification = verifications[index];
          return _buildVerificationCard(verification, status);
        },
      ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> verification, String status) {
    final userId = verification['user_id']?.toString() ?? '';
    final companyName = verification['company_name'] ?? 'غير محدد';
    final userName = verification['user_name'] ?? 'غير محدد';
    final email = verification['email'] ?? 'غير محدد';
    final phone = verification['phone'] ?? 'غير محدد';
    final commercialRegistration = verification['commercial_registration'];
    final tradeLicense = verification['trade_license'];
    final rejectionReason = verification['rejection_reason'];
    final createdAt = verification['created_at'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Info
            _buildInfoRow(Icons.email, email),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, phone),
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.calendar_today, _formatDate(createdAt)),
            ],
            const SizedBox(height: 16),

            // Documents
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDocumentPreview('السجل التجاري', commercialRegistration),
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('السجل التجاري'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDocumentPreview('الرخصة التجارية', tradeLicense),
                    icon: const Icon(Icons.card_membership, size: 18),
                    label: const Text('الرخصة'),
                  ),
                ),
              ],
            ),

            // Rejection Reason
            if (status == 'rejected' && rejectionReason != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سبب الرفض: $rejectionReason',
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons (for pending only)
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveVerification(userId),
                      icon: const Icon(Icons.check),
                      label: const Text('موافقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectVerification(userId),
                      icon: const Icon(Icons.close),
                      label: const Text('رفض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'قيد المراجعة';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        color = Colors.green;
        text = 'مقبول';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'مرفوض';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = 'غير معروف';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'غير محدد';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
  }
}
