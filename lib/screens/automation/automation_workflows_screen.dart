import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/laravel_api_service.dart';
import '../../services/n8n_workflow_service.dart';
import '../../models/user_model.dart';
import '../subscription/subscription_screen.dart';

/// شاشة إدارة سيناريوهات الأتمتة (N8N Workflows) مع قيود الاشتراكات
class AutomationWorkflowsScreen extends StatefulWidget {
  const AutomationWorkflowsScreen({super.key});

  @override
  State<AutomationWorkflowsScreen> createState() => _AutomationWorkflowsScreenState();
}

class _AutomationWorkflowsScreenState extends State<AutomationWorkflowsScreen> {
  final AuthService _authService = Get.find<AuthService>();
  final LaravelApiService _laravelApi = Get.find<LaravelApiService>();
  final N8nWorkflowService _n8nService = Get.find<N8nWorkflowService>();
  final _formKey = GlobalKey<FormState>();
  final _workflowNameController = TextEditingController();
  final _workflowDescriptionController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _workflows = [];
  String? _selectedTrigger = 'manual';
  String? _selectedAction = 'post_to_social';

  final List<Map<String, String>> _triggerTypes = [
    {'value': 'manual', 'label': 'يدوي', 'icon': '👆'},
    {'value': 'schedule', 'label': 'جدولة زمنية', 'icon': '⏰'},
    {'value': 'webhook', 'label': 'Webhook', 'icon': '🔗'},
    {'value': 'rss_feed', 'label': 'RSS Feed', 'icon': '📡'},
  ];

  final List<Map<String, String>> _actionTypes = [
    {'value': 'post_to_social', 'label': 'نشر على وسائل التواصل', 'icon': '📱'},
    {'value': 'send_email', 'label': 'إرسال بريد إلكتروني', 'icon': '📧'},
    {'value': 'save_to_drive', 'label': 'حفظ في Google Drive', 'icon': '💾'},
    {'value': 'generate_content', 'label': 'توليد محتوى AI', 'icon': '🤖'},
    {'value': 'edit_image', 'label': 'تعديل صورة AI', 'icon': '🎨'},
    {'value': 'send_telegram', 'label': 'إرسال رسالة تليجرام', 'icon': '✈️'},
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkflows();
  }

  Future<void> _loadWorkflows() async {
    setState(() => _isLoading = true);
    try {
      final workflows = await _laravelApi.getWorkflows();
      setState(() {
        _workflows = workflows;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workflows: $e');
      setState(() {
        _workflows = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _createWorkflow() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser.value;
    if (user == null) return;

    // Check subscription limits
    if (!user.canUseAutomation) {
      _showUpgradeDialog();
      return;
    }

    if (_workflows.length >= user.maxAutomationWorkflows) {
      _showLimitReachedDialog(user);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _laravelApi.createWorkflow(
        name: _workflowNameController.text.trim(),
        description: _workflowDescriptionController.text.trim(),
        trigger: _selectedTrigger ?? 'manual',
        action: _selectedAction ?? 'post_to_social',
      );

      if (mounted) {
        if (result['success'] == true) {
          Get.snackbar(
            'نجح',
            'تم إنشاء سيناريو الأتمتة بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          _workflowNameController.clear();
          _workflowDescriptionController.clear();
          await _loadWorkflows();
        } else {
          Get.snackbar(
            'خطأ',
            result['message'] ?? 'فشل إنشاء السيناريو',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'فشل إنشاء السيناريو: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترقية الاشتراك'),
        content: const Text(
          'ميزة الأتمتة متاحة فقط للمشتركين في الباقات المدفوعة.\n\nقم بالترقية للاستمتاع بهذه الميزة القوية!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const SubscriptionScreen());
            },
            child: const Text('ترقية الآن'),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('وصلت للحد الأقصى'),
        content: Text(
          'لقد وصلت للحد الأقصى من سيناريوهات الأتمتة (${user.maxAutomationWorkflows}) في باقة ${user.tierDisplayName}.\n\n'
          'قم بالترقية لباقة أعلى للحصول على المزيد من السيناريوهات!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          if (!user.isBusinessTier)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.to(() => const SubscriptionScreen());
              },
              child: const Text('ترقية الآن'),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleWorkflow(String workflowId, bool currentStatus) async {
    setState(() => _isLoading = true);
    try {
      final success = await _laravelApi.toggleWorkflow(workflowId, !currentStatus);
      await _loadWorkflows();
      if (mounted) {
        Get.snackbar(
          success ? 'نجح' : 'خطأ',
          success
              ? (currentStatus ? 'تم إيقاف السيناريو' : 'تم تفعيل السيناريو')
              : 'فشل تغيير حالة السيناريو',
          backgroundColor: success ? Colors.green : Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'فشل تغيير حالة السيناريو: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteWorkflow(String workflowId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السيناريو'),
        content: const Text('هل أنت متأكد من حذف هذا السيناريو؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final success = await _laravelApi.deleteWorkflow(workflowId);
        await _loadWorkflows();
        if (mounted) {
          Get.snackbar(
            success ? 'نجح' : 'خطأ',
            success ? 'تم حذف السيناريو' : 'فشل حذف السيناريو',
            backgroundColor: success ? Colors.green : Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        if (mounted) {
          Get.snackbar(
            'خطأ',
            'فشل حذف السيناريو: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأتمتة'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subscription info card
                  _buildSubscriptionInfoCard(user),
                  const SizedBox(height: 24),

                  // Create workflow form
                  _buildCreateWorkflowForm(user),
                  const SizedBox(height: 24),

                  // Workflows list
                  _buildWorkflowsList(user),
                ],
              ),
            ),
    );
  }

  Widget _buildSubscriptionInfoCard(UserModel? user) {
    if (user == null) return const SizedBox();

    final isUnlimited = user.isBusinessTier && user.maxAutomationWorkflows >= 999999;

    return Card(
      color: user.canUseAutomation ? Colors.purple.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              user.canUseAutomation ? Icons.auto_awesome : Icons.info,
              size: 48,
              color: user.canUseAutomation ? Colors.purple : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              user.canUseAutomation
                  ? 'باقتك: ${user.tierDisplayName}'
                  : 'ترقية مطلوبة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.canUseAutomation
                  ? (isUnlimited
                      ? 'يمكنك إنشاء سيناريوهات أتمتة غير محدودة'
                      : 'يمكنك إنشاء حتى ${user.maxAutomationWorkflows} ${user.maxAutomationWorkflows == 1 ? 'سيناريو' : 'سيناريوهات'}')
                  : 'قم بالترقية لباقة مدفوعة لاستخدام الأتمتة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            if (!user.canUseAutomation) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => const SubscriptionScreen()),
                icon: const Icon(Icons.upgrade),
                label: const Text('ترقية الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreateWorkflowForm(UserModel? user) {
    final canCreate = user != null &&
        user.canUseAutomation &&
        _workflows.length < user.maxAutomationWorkflows;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    'إنشاء سيناريو جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workflowNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم السيناريو',
                  hintText: 'مثال: نشر تلقائي على السوشال ميديا',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                enabled: canCreate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم السيناريو';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workflowDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف السيناريو',
                  hintText: 'اشرح ماذا يفعل هذا السيناريو',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                enabled: canCreate,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف السيناريو';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedTrigger,
                decoration: const InputDecoration(
                  labelText: 'المحفز (Trigger)',
                  prefixIcon: Icon(Icons.play_arrow),
                  border: OutlineInputBorder(),
                ),
                items: _triggerTypes.map((trigger) {
                  return DropdownMenuItem(
                    value: trigger['value'],
                    child: Row(
                      children: [
                        Text(trigger['icon']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(trigger['label']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: canCreate ? (value) {
                  setState(() => _selectedTrigger = value);
                } : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedAction,
                decoration: const InputDecoration(
                  labelText: 'الإجراء (Action)',
                  prefixIcon: Icon(Icons.bolt),
                  border: OutlineInputBorder(),
                ),
                items: _actionTypes.map((action) {
                  return DropdownMenuItem(
                    value: action['value'],
                    child: Row(
                      children: [
                        Text(action['icon']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(action['label']!)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: canCreate ? (value) {
                  setState(() => _selectedAction = value);
                } : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: canCreate ? _createWorkflow : null,
                icon: const Icon(Icons.add),
                label: const Text('إنشاء السيناريو'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.purple,
                ),
              ),
              if (!canCreate && user?.canUseAutomation == true) ...[
                const SizedBox(height: 8),
                Text(
                  'لقد وصلت للحد الأقصى من السيناريوهات',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowsList(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.webhook, color: Colors.purple),
            const SizedBox(width: 8),
            Text(
              'السيناريوهات (${_workflows.length}${user != null && user.maxAutomationWorkflows < 999999 ? '/${user.maxAutomationWorkflows}' : ''})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_workflows.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد سيناريوهات أتمتة بعد',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بإنشاء أول سيناريو لك للبدء',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_workflows.map((workflow) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: workflow['is_active'] == true ? Colors.green : Colors.grey,
                    child: const Icon(Icons.webhook, color: Colors.white),
                  ),
                  title: Text(workflow['name'] ?? 'Workflow'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workflow['description'] ?? ''),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            workflow['is_active'] == true ? Icons.check_circle : Icons.pause_circle,
                            size: 14,
                            color: workflow['is_active'] == true ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workflow['is_active'] == true ? 'نشط' : 'متوقف',
                            style: TextStyle(
                              fontSize: 12,
                              color: workflow['is_active'] == true ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: workflow['is_active'] == true,
                        onChanged: (value) => _toggleWorkflow(workflow['id'], workflow['is_active'] == true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkflow(workflow['id']),
                      ),
                    ],
                  ),
                ),
              ))),
      ],
    );
  }

  @override
  void dispose() {
    _workflowNameController.dispose();
    _workflowDescriptionController.dispose();
    super.dispose();
  }
}
