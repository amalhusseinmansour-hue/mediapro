import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../models/subscription_plan_model.dart';
import '../core/constants/app_colors.dart';
import '../core/config/api_config.dart';
import 'auth_service.dart';

class SubscriptionService extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Observable list of subscription plans
  final RxList<SubscriptionPlanModel> _subscriptionPlans =
      <SubscriptionPlanModel>[].obs;
  final RxBool _isLoadingPlans = false.obs;
  final RxString _plansError = ''.obs;

  List<SubscriptionPlanModel> get subscriptionPlans => _subscriptionPlans;
  bool get isLoadingPlans => _isLoadingPlans.value;
  String get plansError => _plansError.value;

  // Get current user
  UserModel? get currentUser => _authService.currentUser.value;

  /// Fetch subscription plans from backend
  Future<void> fetchSubscriptionPlans() async {
    try {
      _isLoadingPlans.value = true;
      _plansError.value = '';

      print('📋 Fetching subscription plans from backend...');

      final url = Uri.parse(
        '${ApiConfig.backendBaseUrl}/api/v1/subscription-plans',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('انتهت مهلة الاتصال بالخادم');
            },
          );

      print('📋 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        List<dynamic> plansData;
        if (data is Map && data.containsKey('data')) {
          plansData = data['data'] as List;
        } else if (data is Map && data.containsKey('plans')) {
          plansData = data['plans'] as List;
        } else if (data is List) {
          plansData = data;
        } else {
          throw Exception('تنسيق غير متوقع لبيانات الخطط');
        }

        final plans = plansData
            .map((json) => SubscriptionPlanModel.fromJson(json))
            .where((plan) => plan.isActive)
            .toList();

        // Sort by order
        plans.sort((a, b) => a.order.compareTo(b.order));

        _subscriptionPlans.value = plans;
        print('✅ تم تحميل ${plans.length} خطط اشتراك');
      } else {
        throw Exception('فشل في تحميل الخطط: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في تحميل خطط الاشتراك: $e');
      _plansError.value = 'فشل في تحميل خطط الاشتراك: $e';

      // Load default fallback plans
      _loadDefaultPlans();
    } finally {
      _isLoadingPlans.value = false;
    }
  }

  /// Load default hardcoded plans as fallback
  void _loadDefaultPlans() {
    print('⚠️  تحميل الخطط الافتراضية...');

    _subscriptionPlans.value = [
      SubscriptionPlanModel(
        id: '1',
        name: 'Individual Plan',
        nameAr: 'باقة الأفراد',
        description: 'Perfect for individuals and content creators',
        descriptionAr: 'مثالية للأفراد ومنشئي المحتوى',
        monthlyPrice: 10.0,  // Test price
        yearlyPrice: 100.0,  // Test price
        currency: 'AED',
        maxAccounts: 5,
        maxPostsPerMonth: 999999,
        maxAIRequests: 999999,
        hasAdvancedScheduling: true,
        hasAnalytics: true,
        hasTeamCollaboration: false,
        hasExportReports: false,
        hasPrioritySupport: false,
        hasCustomBranding: false,
        hasAPI: false,
        features: [
          'Connect up to 5 social media accounts',
          'Schedule unlimited posts',
          'AI content generation',
          'Basic analytics and insights',
          'Email support',
          'Content calendar',
          'Auto-posting to all platforms',
        ],
        featuresAr: [
          'ربط حتى 5 حسابات سوشال ميديا',
          'جدولة منشورات غير محدودة',
          'إنشاء محتوى بالذكاء الاصطناعي',
          'تحليلات ورؤى أساسية',
          'دعم فني عبر البريد',
          'تقويم المحتوى',
          'النشر التلقائي لجميع المنصات',
        ],
        tier: 'individual',
        isPopular: true,
        badge: 'Most Popular',
        badgeAr: 'الأكثر شعبية',
        order: 1,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      SubscriptionPlanModel(
        id: '2',
        name: 'Business Plan',
        nameAr: 'باقة الشركات',
        description: 'Ideal for businesses and marketing teams',
        descriptionAr: 'مثالية للشركات وفرق التسويق',
        monthlyPrice: 159.99,
        yearlyPrice: 1727.89,
        currency: 'AED',
        maxAccounts: 999999,
        maxPostsPerMonth: 999999,
        maxAIRequests: 999999,
        hasAdvancedScheduling: true,
        hasAnalytics: true,
        hasTeamCollaboration: true,
        hasExportReports: true,
        hasPrioritySupport: true,
        hasCustomBranding: true,
        hasAPI: true,
        features: [
          'Connect unlimited social media accounts',
          'Schedule unlimited posts',
          'Advanced AI content generation',
          'Advanced analytics and reporting',
          'Priority email and chat support',
          'Team collaboration tools',
          'Content calendar with team features',
          'Auto-posting to all platforms',
          'Custom branding options',
          'API access',
        ],
        featuresAr: [
          'ربط عدد غير محدود من حسابات السوشال ميديا',
          'جدولة منشورات غير محدودة',
          'إنشاء محتوى متقدم بالذكاء الاصطناعي',
          'تحليلات وتقارير متقدمة',
          'دعم ذو أولوية عبر البريد والدردشة',
          'أدوات التعاون الجماعي',
          'تقويم محتوى مع ميزات الفريق',
          'النشر التلقائي لجميع المنصات',
          'خيارات العلامة التجارية المخصصة',
          'الوصول إلى API',
        ],
        tier: 'business',
        isPopular: false,
        badge: 'For Professionals',
        badgeAr: 'للمحترفين',
        order: 2,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Subscription tier checks
  bool get isFree => currentUser?.isFree ?? true;
  bool get isIndividual => currentUser?.isIndividualTier ?? false;
  bool get isTeam => currentUser?.isTeamTier ?? false;
  bool get isEnterprise => currentUser?.isEnterpriseTier ?? false;

  // Check if user can add more accounts
  Future<bool> canAddAccount(int currentAccountsCount) async {
    // Allow adding accounts if no user is logged in (for demo/testing)
    if (currentUser == null) return true;

    final maxAccounts = currentUser!.maxAccounts;
    if (currentAccountsCount >= maxAccounts) {
      _showUpgradeDialog(
        title: 'وصلت للحد الأقصى من الحسابات',
        message:
            'الخطة الحالية (${currentUser!.tierDisplayName}) تسمح بـ $maxAccounts حساب فقط.\nقم بالترقية للإضافة المزيد!',
      );
      return false;
    }

    return true;
  }

  // Check if user can create more posts this month
  Future<bool> canCreatePost(int currentMonthPostsCount) async {
    if (currentUser == null) return false;

    final maxPosts = currentUser!.maxPostsPerMonth;
    if (currentMonthPostsCount >= maxPosts) {
      _showUpgradeDialog(
        title: 'وصلت للحد الأقصى من المنشورات',
        message:
            'الخطة الحالية (${currentUser!.tierDisplayName}) تسمح بـ $maxPosts منشور شهرياً.\nقم بالترقية للنشر المزيد!',
      );
      return false;
    }

    return true;
  }

  // Check if user can use AI features
  Future<bool> canUseAI(int currentMonthAIRequests) async {
    if (currentUser == null) return false;

    if (!currentUser!.canUseAI) {
      _showUpgradeDialog(
        title: 'ميزة الذكاء الاصطناعي',
        message:
            'ميزات الذكاء الاصطناعي غير متوفرة في الخطة المجانية.\nقم بالترقية للاستمتاع بها!',
        features: [
          'تحليل الاتجاهات',
          'مولد الهاشتاقات الذكي',
          'أفضل وقت للنشر',
          'إنشاء محتوى بالذكاء الاصطناعي',
        ],
      );
      return false;
    }

    final maxAIRequests = currentUser!.maxAIRequestsPerMonth;
    if (currentMonthAIRequests >= maxAIRequests && maxAIRequests != 999999) {
      _showUpgradeDialog(
        title: 'وصلت للحد الأقصى من طلبات الذكاء الاصطناعي',
        message:
            'الخطة الحالية (${currentUser!.tierDisplayName}) تسمح بـ $maxAIRequests طلب شهرياً.\nقم بالترقية لطلبات غير محدودة!',
      );
      return false;
    }

    return true;
  }

  // Check if user can use analytics
  bool canUseAnalytics() {
    if (currentUser == null) return false;

    if (!currentUser!.canUseAnalytics) {
      _showUpgradeDialog(
        title: 'التحليلات المتقدمة',
        message:
            'التحليلات التفصيلية غير متوفرة في الخطة المجانية.\nقم بالترقية لمشاهدة تحليلات شاملة!',
        features: [
          'تحليل الأداء التفصيلي',
          'إحصائيات المنصات',
          'تقارير النمو',
          'تحليل المشاركة',
        ],
      );
      return false;
    }

    return true;
  }

  // Check if user can use advanced scheduling
  bool canUseAdvancedScheduling() {
    if (currentUser == null) return false;

    if (!currentUser!.canUseAdvancedScheduling) {
      _showUpgradeDialog(
        title: 'الجدولة المتقدمة',
        message:
            'الجدولة المتقدمة غير متوفرة في الخطة المجانية.\nقم بالترقية للوصول إليها!',
        features: [
          'جدولة متعددة للمنصات',
          'جدولة ذكية بالذكاء الاصطناعي',
          'إعادة النشر التلقائي',
          'تقويم المحتوى',
        ],
      );
      return false;
    }

    return true;
  }

  // Check if user can export reports
  bool canExportReports() {
    if (currentUser == null) return false;

    if (!currentUser!.canExportReports) {
      _showUpgradeDialog(
        title: 'تصدير التقارير',
        message:
            'تصدير التقارير غير متوفر في الخطة المجانية.\nقم بالترقية لتصدير تقاريرك!',
      );
      return false;
    }

    return true;
  }

  // Check if user can use team collaboration
  bool canUseTeamCollaboration() {
    if (currentUser == null) return false;

    if (!currentUser!.canUseTeamCollaboration) {
      _showUpgradeDialog(
        title: 'التعاون الجماعي',
        message:
            'ميزة التعاون الجماعي متوفرة فقط في خطة الفريق والمؤسسية.\nقم بالترقية للعمل مع فريقك!',
        features: [
          'مستخدمين متعددين',
          'أدوار وصلاحيات',
          'سير عمل الموافقة',
          'التعليقات والمراجعة',
        ],
      );
      return false;
    }

    return true;
  }

  // Show upgrade dialog
  void _showUpgradeDialog({
    required String title,
    required String message,
    List<String>? features,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.cyanPurpleGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Features list
              if (features != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: AppColors.cyanPurpleGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textLight,
                        side: BorderSide(
                          color: AppColors.textLight.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          // Navigate to subscription screen
                          Get.toNamed('/subscription');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ترقية الخطة',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Get subscription tier color
  Color getTierColor() {
    if (currentUser == null) return AppColors.textLight;

    switch (currentUser!.subscriptionTier) {
      case 'free':
        return AppColors.textLight;
      case 'individual':
        return AppColors.neonCyan;
      case 'team':
        return AppColors.neonPurple;
      case 'enterprise':
        return const Color(0xFFFFD700); // Gold
      default:
        return AppColors.textLight;
    }
  }

  // Get subscription tier icon
  IconData getTierIcon() {
    if (currentUser == null) return Icons.account_circle;

    switch (currentUser!.subscriptionTier) {
      case 'free':
        return Icons.account_circle;
      case 'individual':
        return Icons.person;
      case 'team':
        return Icons.groups;
      case 'enterprise':
        return Icons.business;
      default:
        return Icons.account_circle;
    }
  }
}
