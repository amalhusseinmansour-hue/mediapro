import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/otp_settings_controller.dart';
import '../../models/otp_config_model.dart';

/// شاشة إعدادات OTP
class OTPSettingsScreen extends StatelessWidget {
  const OTPSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OTPSettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات OTP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => controller.resetToDefault(),
            tooltip: 'إعادة تعيين',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.otpConfig.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            _buildTabs(controller),
            Expanded(
              child: _buildTabContent(controller),
            ),
          ],
        );
      }),
    );
  }

  /// بناء التبويبات
  Widget _buildTabs(OTPSettingsController controller) {
    return Obx(() {
      return Container(
        color: Colors.grey[200],
        child: Row(
          children: [
            _buildTab(
              controller: controller,
              tab: 'general',
              icon: Icons.settings,
              label: 'الإعدادات العامة',
            ),
            _buildTab(
              controller: controller,
              tab: 'providers',
              icon: Icons.dns,
              label: 'المزودون',
            ),
            _buildTab(
              controller: controller,
              tab: 'test',
              icon: Icons.bug_report,
              label: 'اختبار',
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTab({
    required OTPSettingsController controller,
    required String tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = controller.selectedTab.value == tab;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء محتوى التبويب
  Widget _buildTabContent(OTPSettingsController controller) {
    return Obx(() {
      switch (controller.selectedTab.value) {
        case 'general':
          return _buildGeneralTab(controller);
        case 'providers':
          return _buildProvidersTab(controller);
        case 'test':
          return _buildTestTab(controller);
        default:
          return const SizedBox();
      }
    });
  }

  /// تبويب الإعدادات العامة
  Widget _buildGeneralTab(OTPSettingsController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إعدادات OTP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // OTP Length
                Text(
                  'طول رمز OTP: ${controller.otpLength.value} أرقام',
                  style: const TextStyle(fontSize: 16),
                ),
                Obx(() => Slider(
                  value: controller.otpLength.value.toDouble(),
                  min: 4,
                  max: 8,
                  divisions: 4,
                  label: controller.otpLength.value.toString(),
                  onChanged: (value) {
                    controller.otpLength.value = value.toInt();
                  },
                )),

                const SizedBox(height: 16),

                // Expiry Minutes
                Text(
                  'مدة الصلاحية: ${controller.expiryMinutes.value} دقائق',
                  style: const TextStyle(fontSize: 16),
                ),
                Obx(() => Slider(
                  value: controller.expiryMinutes.value.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  label: '${controller.expiryMinutes.value} دقيقة',
                  onChanged: (value) {
                    controller.expiryMinutes.value = value.toInt();
                  },
                )),

                const SizedBox(height: 16),

                // Max Retries
                Text(
                  'الحد الأقصى للمحاولات: ${controller.maxRetries.value}',
                  style: const TextStyle(fontSize: 16),
                ),
                Obx(() => Slider(
                  value: controller.maxRetries.value.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: controller.maxRetries.value.toString(),
                  onChanged: (value) {
                    controller.maxRetries.value = value.toInt();
                  },
                )),

                const SizedBox(height: 16),

                // Test Mode
                Obx(() => SwitchListTile(
                  title: const Text('وضع الاختبار'),
                  subtitle: const Text(
                    'في وضع الاختبار، سيتم إرسال OTP محلي بدلاً من استخدام الخدمات الحقيقية',
                  ),
                  value: controller.isTestMode.value,
                  onChanged: (value) {
                    controller.isTestMode.value = value;
                  },
                )),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isSaving.value
                        ? null
                        : () => controller.saveGeneralSettings(),
                    icon: controller.isSaving.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      controller.isSaving.value ? 'جاري الحفظ...' : 'حفظ الإعدادات',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Default Provider
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المزود الافتراضي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),

                Obx(() {
                  final providersList = controller.providers.values.toList()
                    ..sort((a, b) => a.priority.compareTo(b.priority));

                  return DropdownButtonFormField<String>(
                    initialValue: controller.defaultProvider.value,
                    decoration: const InputDecoration(
                      labelText: 'اختر المزود',
                      border: OutlineInputBorder(),
                    ),
                    items: providersList.map((provider) {
                      return DropdownMenuItem(
                        value: provider.name,
                        child: Row(
                          children: [
                            Icon(
                              provider.isEnabled
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: provider.isEnabled
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(provider.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateDefaultProvider(value);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// تبويب المزودين
  Widget _buildProvidersTab(OTPSettingsController controller) {
    return Obx(() {
      final providersList = controller.providers.values.toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

      if (providersList.isEmpty) {
        return const Center(
          child: Text('لا توجد مزودون'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: providersList.length,
        itemBuilder: (context, index) {
          final provider = providersList[index];
          return _buildProviderCard(controller, provider);
        },
      );
    });
  }

  /// بطاقة المزود
  Widget _buildProviderCard(
    OTPSettingsController controller,
    OTPProviderConfig provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          provider.isEnabled ? Icons.check_circle : Icons.cancel,
          color: provider.isEnabled ? Colors.green : Colors.red,
        ),
        title: Text(provider.displayName),
        subtitle: Text(
          provider.isEnabled
              ? 'مفعل • الأولوية: ${provider.priority}'
              : 'معطل • الأولوية: ${provider.priority}',
        ),
        trailing: Switch(
          value: provider.isEnabled,
          onChanged: (value) {
            controller.toggleProvider(provider.name, value);
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Test Mode
                SwitchListTile(
                  title: const Text('وضع الاختبار'),
                  value: provider.isTestMode,
                  onChanged: (value) {
                    final updated = provider.copyWith(isTestMode: value);
                    controller.saveProviderConfig(updated);
                  },
                ),

                const Divider(),
                const SizedBox(height: 8),

                // Provider Fields
                ..._buildProviderFields(controller, provider),

                const SizedBox(height: 16),

                // Status
                if (provider.isValid)
                  const ListTile(
                    leading: Icon(Icons.verified, color: Colors.green),
                    title: Text('الإعدادات صحيحة'),
                    tileColor: Colors.green,
                    textColor: Colors.white,
                  )
                else
                  const ListTile(
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text('الإعدادات غير مكتملة'),
                    subtitle: Text('يرجى إدخال جميع البيانات المطلوبة'),
                    tileColor: Colors.red,
                    textColor: Colors.white,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء حقول المزود
  List<Widget> _buildProviderFields(
    OTPSettingsController controller,
    OTPProviderConfig provider,
  ) {
    final fields = OTPProviderConfig.getRequiredFields(provider.name);

    if (fields.isEmpty || (fields.length == 1 && fields[0].key == 'info')) {
      return [
        ListTile(
          leading: const Icon(Icons.info, color: Colors.blue),
          title: Text(fields.isNotEmpty ? fields[0].description : 'لا توجد إعدادات إضافية'),
          tileColor: Colors.blue.withValues(alpha: 0.1),
        ),
      ];
    }

    return fields.where((f) => f.key != 'info').map((field) {
      final currentValue = provider.credentials[field.key] ?? '';
      final textController = TextEditingController(text: currentValue);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: textController,
          obscureText: field.isSecret,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.description,
            border: const OutlineInputBorder(),
            suffixIcon: field.isRequired
                ? const Icon(Icons.star, color: Colors.red, size: 16)
                : null,
          ),
          onChanged: (value) {
            final updatedCredentials = Map<String, String>.from(provider.credentials);
            updatedCredentials[field.key] = value;

            final updated = provider.copyWith(credentials: updatedCredentials);
            controller.saveProviderConfig(updated);
          },
        ),
      );
    }).toList();
  }

  /// تبويب الاختبار
  Widget _buildTestTab(OTPSettingsController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختبار إرسال OTP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Phone Number
                TextField(
                  controller: TextEditingController(
                    text: controller.testPhoneNumber.value,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: '+971xxxxxxxxx',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    controller.testPhoneNumber.value = value;
                  },
                ),

                const SizedBox(height: 16),

                // Current Provider Info
                Obx(() {
                  final defaultProv = controller.providers[controller.defaultProvider.value];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المزود الحالي: ${defaultProv?.displayName ?? "غير محدد"}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'وضع ${defaultProv?.isTestMode == true ? "الاختبار" : "الإنتاج"}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Send Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isTesting.value
                        ? null
                        : () => controller.testSendOTP(),
                    icon: controller.isTesting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      controller.isTesting.value ? 'جاري الإرسال...' : 'إرسال OTP',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  )),
                ),

                const SizedBox(height: 16),

                // Warning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تأكد من أن رقم الهاتف صحيح وأن المزود مُعد بشكل صحيح',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 12,
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
      ],
    );
  }
}
