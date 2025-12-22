import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/payment_settings_controller.dart';
import '../../models/payment_gateway_config_model.dart';
import '../../models/payment_transaction_model.dart' as transaction_models;
import '../../core/constants/app_colors.dart';

class PaymentSettingsScreen extends StatelessWidget {
  PaymentSettingsScreen({super.key});

  final PaymentSettingsController controller = Get.put(
    PaymentSettingsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('إعدادات الدفع'),
        backgroundColor: AppColors.darkCard,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 'statistics':
                  return _buildStatisticsTab();
                case 'gateways':
                  return _buildGatewaysTab();
                case 'test':
                  return _buildTestTab();
                case 'transactions':
                  return _buildTransactionsTab();
                default:
                  return _buildStatisticsTab();
              }
            }),
          ),
        ],
      ),
    );
  }

  /// شريط التبويبات
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          children: [
            _buildTabButton('statistics', 'الإحصائيات', Icons.bar_chart),
            const SizedBox(width: 8),
            _buildTabButton('gateways', 'البوابات', Icons.payment),
            const SizedBox(width: 8),
            _buildTabButton('test', 'الاختبار', Icons.science),
            const SizedBox(width: 8),
            _buildTabButton('transactions', 'المعاملات', Icons.history),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    final isSelected = controller.selectedTab.value == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonCyan : AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : Colors.white,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// تبويب الإحصائيات
  Widget _buildStatisticsTab() {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.loadStatistics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إحصائيات الدفع',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // البطاقات الإحصائية
              _buildStatCard(
                'إجمالي المبلغ',
                '${controller.totalAmount.value.toStringAsFixed(2)} د.إ',
                Icons.attach_money,
                AppColors.neonCyan,
              ),
              const SizedBox(height: 12),

              _buildStatCard(
                'المبلغ الناجح',
                '${controller.successfulAmount.value.toStringAsFixed(2)} د.إ',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'العدد الكلي',
                      '${controller.totalCount.value}',
                      Icons.list,
                      AppColors.neonPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'الناجحة',
                      '${controller.successfulCount.value}',
                      Icons.done,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'الفاشلة',
                      '${controller.failedCount.value}',
                      Icons.error,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'قيد الانتظار',
                      '${controller.pendingCount.value}',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // نسبة النجاح
              _buildSuccessRateCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.neonCyan, AppColors.neonPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'نسبة النجاح',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              '${controller.successRate.value.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => LinearProgressIndicator(
              value: controller.successRate.value / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  /// تبويب البوابات
  Widget _buildGatewaysTab() {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.gateways.length,
              itemBuilder: (context, index) {
                final gateway = controller.gateways[index];
                return _buildGatewayCard(gateway);
              },
            ),
    );
  }

  Widget _buildGatewayCard(PaymentGatewayConfigModel gateway) {
    return Card(
      color: AppColors.darkCard,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          Icons.payment,
          color: gateway.isEnabled ? AppColors.neonCyan : Colors.grey,
        ),
        title: Text(
          gateway.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          gateway.isEnabled
              ? 'مفعّلة ${gateway.isTestMode ? "(وضع الاختبار)" : ""}'
              : 'معطلة',
          style: TextStyle(
            color: gateway.isEnabled ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (gateway.isValid)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Switch(
              value: gateway.isEnabled,
              onChanged: (value) {
                final updatedGateway = gateway.copyWith(
                  isEnabled: value,
                  updatedAt: DateTime.now(),
                );
                controller.saveGatewayConfig(updatedGateway);
              },
              activeThumbColor: AppColors.neonCyan,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGatewayInfo(gateway),
                const SizedBox(height: 16),
                _buildGatewayFields(gateway),
                const SizedBox(height: 16),
                _buildGatewayActions(gateway),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayInfo(PaymentGatewayConfigModel gateway) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'العملات المدعومة',
          gateway.supportedCurrencies.join(', '),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'نسبة العمولة',
          gateway.feePercentage != null
              ? '${gateway.feePercentage}%'
              : 'غير محدد',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'الرسوم الثابتة',
          gateway.fixedFee != null ? '${gateway.fixedFee} د.إ' : 'غير محدد',
        ),
        const SizedBox(height: 8),
        _buildInfoRow('الأولوية', gateway.priority.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGatewayFields(PaymentGatewayConfigModel gateway) {
    final fields = PaymentGatewayConfigModel.getRequiredFields(gateway.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الإعدادات:',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...fields.map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: TextEditingController(
                text: gateway.credentials[field.key] ?? '',
              ),
              obscureText: field.isSecret,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: field.label,
                hintText: field.description,
                filled: true,
                fillColor: AppColors.darkBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: field.isRequired
                    ? const Icon(Icons.star, color: Colors.red, size: 12)
                    : null,
              ),
              onChanged: (value) {
                gateway.credentials[field.key] = value;
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text(
            'وضع الاختبار',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            'استخدم معاملات اختبار بدلاً من حقيقية',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          value: gateway.isTestMode,
          onChanged: (value) {
            final updatedGateway = gateway.copyWith(
              isTestMode: value,
              updatedAt: DateTime.now(),
            );
            controller.saveGatewayConfig(updatedGateway);
          },
          activeThumbColor: AppColors.neonCyan,
          tileColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget _buildGatewayActions(PaymentGatewayConfigModel gateway) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final updatedGateway = gateway.copyWith(
                updatedAt: DateTime.now(),
              );
              controller.saveGatewayConfig(updatedGateway);
            },
            icon: const Icon(Icons.save),
            label: const Text('حفظ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.testGateway(gateway),
            icon: const Icon(Icons.science),
            label: const Text('اختبار'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neonCyan,
              side: BorderSide(color: AppColors.neonCyan),
            ),
          ),
        ),
      ],
    );
  }

  /// تبويب الاختبار
  Widget _buildTestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اختبار بوابة الدفع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم باختبار بوابات الدفع قبل تفعيلها للمستخدمين',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),

          Obx(
            () => controller.gateways.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد بوابات دفع',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : Column(
                    children: controller.gateways.map((gateway) {
                      return _buildTestGatewayCard(gateway);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestGatewayCard(PaymentGatewayConfigModel gateway) {
    return Card(
      color: AppColors.darkCard,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: gateway.isValid ? AppColors.neonCyan : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gateway.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gateway.isValid ? 'جاهز للاختبار' : 'غير مكتمل',
                        style: TextStyle(
                          color: gateway.isValid ? Colors.green : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (gateway.isValid)
                  Obx(
                    () => ElevatedButton.icon(
                      onPressed: controller.isTesting.value
                          ? null
                          : () => controller.testGateway(gateway),
                      icon: controller.isTesting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: const Text('اختبار'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            if (!gateway.isValid) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'يجب إكمال جميع الإعدادات المطلوبة قبل الاختبار',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// تبويب المعاملات
  Widget _buildTransactionsTab() {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.white30),
              SizedBox(height: 16),
              Text(
                'لا توجد معاملات',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المعاملات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    final csv = controller.exportTransactionsToCSV();
                    Get.snackbar(
                      'تصدير',
                      'تم تصدير ${controller.transactions.length} معاملة',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    print(csv); // يمكن حفظه في ملف أو مشاركته
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('تصدير CSV'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neonCyan,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                final transaction = controller.transactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTransactionCard(
    transaction_models.PaymentTransactionModel transaction,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (transaction.status) {
      case transaction_models.PaymentStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case transaction_models.PaymentStatus.failed:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case transaction_models.PaymentStatus.pending:
      case transaction_models.PaymentStatus.processing:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case transaction_models.PaymentStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
      case transaction_models.PaymentStatus.refunded:
        statusColor = Colors.blue;
        statusIcon = Icons.replay;
        break;
    }

    return Card(
      color: AppColors.darkCard,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              transaction.gatewayNameAr,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            transaction.statusNameAr,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
