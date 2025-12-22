import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/website_request_service.dart';
import '../../models/website_request_model.dart';
import 'package:intl/intl.dart';

/// شاشة عرض طلبات المواقع الإلكترونية للمستخدم
class MyWebsiteRequestsScreen extends StatefulWidget {
  const MyWebsiteRequestsScreen({super.key});

  @override
  State<MyWebsiteRequestsScreen> createState() => _MyWebsiteRequestsScreenState();
}

class _MyWebsiteRequestsScreenState extends State<MyWebsiteRequestsScreen> {
  final WebsiteRequestService _service = Get.find<WebsiteRequestService>();

  String? _selectedStatus;
  final Map<String, String> _statusNames = {
    'pending': 'قيد الانتظار',
    'reviewing': 'قيد المراجعة',
    'approved': 'تم الموافقة',
    'in_progress': 'قيد التنفيذ',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',
  };

  final Map<String, Color> _statusColors = {
    'pending': Colors.orange,
    'reviewing': Colors.blue,
    'approved': Colors.green,
    'in_progress': AppColors.neonCyan,
    'completed': Colors.purple,
    'cancelled': Colors.red,
  };

  final Map<String, IconData> _statusIcons = {
    'pending': Icons.pending,
    'reviewing': Icons.rate_review,
    'approved': Icons.check_circle,
    'in_progress': Icons.construction,
    'completed': Icons.done_all,
    'cancelled': Icons.cancel,
  };

  final Map<String, String> _websiteTypes = {
    'corporate': 'موقع شركة',
    'ecommerce': 'متجر إلكتروني',
    'portfolio': 'معرض أعمال',
    'blog': 'مدونة',
    'custom': 'مخصص',
  };

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    await _service.fetchRequests(status: _selectedStatus);
  }

  Future<void> _deleteRequest(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الطلب'),
        content: const Text('هل أنت متأكد من حذف هذا الطلب؟\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _service.deleteRequest(id);
        if (success && mounted) {
          Get.snackbar(
            'تم الحذف',
            'تم حذف الطلب بنجاح',
            backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
            colorText: Colors.white,
            icon: const Icon(Icons.check, color: AppColors.neonCyan),
          );
          _loadRequests();
        }
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'فشل حذف الطلب: ${e.toString()}',
          backgroundColor: Colors.red.withValues(alpha: 0.2),
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
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
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'طلباتي',
            style: TextStyle(
              fontSize: 22,
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
          // Status Filter
          _buildStatusFilter(),

          // Requests List
          Expanded(
            child: Obx(() {
              if (_service.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                  ),
                );
              }

              if (_service.requests.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _loadRequests,
                color: AppColors.neonCyan,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _service.requests.length,
                  itemBuilder: (context, index) {
                    final request = _service.requests[index];
                    return _buildRequestCard(request);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('الكل', null),
          const SizedBox(width: 8),
          ..._statusNames.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildFilterChip(entry.value, entry.key),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
        _loadRequests();
      },
      backgroundColor: AppColors.darkCard,
      selectedColor: AppColors.neonCyan.withValues(alpha: 0.3),
      checkmarkColor: AppColors.neonCyan,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.neonCyan : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.neonCyan : Colors.transparent,
        width: 1,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppColors.cyanPurpleGradient.scale(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.language_rounded,
              size: 80,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedStatus != null
                ? 'لا توجد طلبات بحالة: ${_statusNames[_selectedStatus]}'
                : 'لم تقم بإرسال أي طلبات بعد',
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(WebsiteRequestModel request) {
    final statusColor = _statusColors[request.status] ?? Colors.grey;
    final statusIcon = _statusIcons[request.status] ?? Icons.help;
    final statusName = _statusNames[request.status] ?? request.status ?? 'غير معروف';
    final websiteTypeName = _websiteTypes[request.websiteType] ?? request.websiteType;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkCard,
            AppColors.darkCard.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRequestDetails(request),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.companyName ?? 'طلب موقع',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            websiteTypeName,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusName,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  request.description,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Footer
                Row(
                  children: [
                    if (request.budget != null) ...[
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${request.budget} ${request.currency ?? "SAR"}',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(request.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (request.status == 'pending')
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteRequest(request.id!),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showRequestDetails(WebsiteRequestModel request) {
    final statusColor = _statusColors[request.status] ?? Colors.grey;
    final statusIcon = _statusIcons[request.status] ?? Icons.help;
    final statusName = _statusNames[request.status] ?? request.status ?? 'غير معروف';
    final websiteTypeName = _websiteTypes[request.websiteType] ?? request.websiteType;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.cyanPurpleGradient.scale(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.companyName ?? 'طلب موقع',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusName,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDetailRow('نوع الموقع', websiteTypeName, Icons.web),
                  const SizedBox(height: 16),
                  _buildDetailRow('البريد الإلكتروني', request.email, Icons.email),
                  const SizedBox(height: 16),
                  _buildDetailRow('رقم الهاتف', request.phone, Icons.phone),
                  const SizedBox(height: 16),
                  if (request.budget != null) ...[
                    _buildDetailRow(
                      'الميزانية',
                      '${request.budget} ${request.currency ?? "SAR"}',
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailRow(
                    'تاريخ الإرسال',
                    _formatDate(request.createdAt),
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  const Text(
                    'وصف المشروع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      request.description,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Admin Notes (if any)
                  if (request.adminNotes != null && request.adminNotes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'ملاحظات الإدارة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanPurpleGradient.scale(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.neonPurple.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            color: AppColors.neonPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              request.adminNotes!,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.neonCyan,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
