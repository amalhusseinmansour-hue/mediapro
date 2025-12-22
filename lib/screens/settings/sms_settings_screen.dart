import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/sms_service.dart';
import '../../models/sms_model.dart';

class SmsSettingsScreen extends StatefulWidget {
  const SmsSettingsScreen({super.key});

  @override
  State<SmsSettingsScreen> createState() => _SmsSettingsScreenState();
}

class _SmsSettingsScreenState extends State<SmsSettingsScreen> {
  final SmsService _smsService = Get.put(SmsService());
  final _searchController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _senderIdController = TextEditingController();
  final _apiUrlController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = _smsService.settings.value;
    if (settings != null) {
      _apiKeyController.text = settings.apiKey ?? '';
      _senderIdController.text = settings.senderId ?? '';
      _apiUrlController.text = settings.apiUrl ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiKeyController.dispose();
    _senderIdController.dispose();
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('إعدادات SMS'),
        backgroundColor: AppColors.darkBg,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _showTestSmsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearCacheDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (_smsService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonCyan),
          );
        }

        return Column(
          children: [
            // إحصائيات
            _buildStatsSection(),

            const SizedBox(height: 20),

            // عنوان القسم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.message, color: AppColors.neonCyan),
                  const SizedBox(width: 8),
                  Text(
                    'سجل الرسائل النصية',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'عرض جميع رسائل SMS المرسلة',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'بحث',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.neonCyan),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // جدول الرسائل
            Expanded(
              child: _buildMessagesTable(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(
                title: 'إجمالي الرسائل',
                value: '${_smsService.totalMessages}',
                subtitle: 'جميع الرسائل المرسلة',
                icon: Icons.message,
                color: AppColors.neonCyan,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                title: 'رسائل اليوم',
                value: '${_smsService.todayMessages}',
                subtitle: 'الرسائل المرسلة اليوم',
                icon: Icons.today,
                color: AppColors.neonPurple,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(
                title: 'معدل النجاح',
                value: '${_smsService.successRate.toStringAsFixed(0)}%',
                subtitle: 'تم التوصيل: ${_smsService.deliveredCount} | فشل: ${_smsService.failedCount}',
                icon: Icons.check_circle,
                color: _smsService.successRate > 50 ? Colors.green : Colors.red,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                title: 'التكلفة الإجمالية',
                value: '${_smsService.totalCost.toStringAsFixed(2)} ر.س',
                subtitle: 'تكلفة الرسائل المسلمة',
                icon: Icons.attach_money,
                color: AppColors.neonPink,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkCard,
            AppColors.darkCard.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
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
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTable() {
    final messages = _searchQuery.isEmpty
        ? _smsService.messages
        : _smsService.searchMessages(_searchQuery);

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'لا توجد رسائل',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppColors.neonCyan.withValues(alpha: 0.1),
            ),
            dataRowColor: WidgetStateProperty.all(Colors.transparent),
            columns: const [
              DataColumn(label: Text('#', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('المستلم', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('نص الرسالة', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الحالة', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الغرض', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الأجزاء', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('التكلفة', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('وقت الإرسال', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))),
            ],
            rows: messages.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final message = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text('$index', style: const TextStyle(color: Colors.white))),
                  DataCell(Text(message.recipient, style: const TextStyle(color: Colors.white))),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        message.message.length > 50
                            ? '${message.message.substring(0, 50)}...'
                            : message.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(message.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor(message.status)),
                      ),
                      child: Text(
                        message.statusText,
                        style: TextStyle(color: _getStatusColor(message.status), fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(Text(message.purposeText, style: const TextStyle(color: Colors.white70))),
                  DataCell(Text('${message.parts}', style: const TextStyle(color: Colors.white))),
                  DataCell(Text('${message.cost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white))),
                  DataCell(Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(message.sentAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SmsStatus status) {
    switch (status) {
      case SmsStatus.pending:
        return Colors.orange;
      case SmsStatus.sent:
        return Colors.blue;
      case SmsStatus.delivered:
        return Colors.green;
      case SmsStatus.failed:
        return Colors.red;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('تعديل الإعدادات', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _apiKeyController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonCyan),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonCyan, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senderIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Sender ID',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonCyan),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonCyan, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'API URL',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonCyan),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonCyan, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
            ),
            child: const Text('حفظ', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    final newSettings = SmsSettings(
      apiKey: _apiKeyController.text.trim(),
      senderId: _senderIdController.text.trim(),
      apiUrl: _apiUrlController.text.trim(),
      isEnabled: _apiKeyController.text.trim().isNotEmpty,
      costPerMessage: 0.05,
    );

    final success = await _smsService.saveSettings(newSettings);
    if (success && mounted) {
      Navigator.pop(context);
      Get.snackbar(
        'تم',
        'تم حفظ الإعدادات بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _showTestSmsDialog() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('إرسال تجريبي', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: phoneController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            labelStyle: TextStyle(color: Colors.white70),
            hintText: '966xxxxxxxxx',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neonCyan),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neonCyan, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.isNotEmpty) {
                Navigator.pop(context);
                await _smsService.sendVerificationCode(phone);
                Get.snackbar(
                  'تم',
                  'تم إرسال رسالة تجريبية',
                  backgroundColor: AppColors.neonCyan,
                  colorText: Colors.black,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
            ),
            child: const Text('إرسال', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('مسح الكاش', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل تريد مسح جميع الرسائل؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _smsService.clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
