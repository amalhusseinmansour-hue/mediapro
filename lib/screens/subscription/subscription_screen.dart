import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/paymob_config.dart';
import '../../services/auth_service.dart';
import '../../services/paymob_service.dart';
import '../../services/firestore_service.dart';
import '../../services/subscription_service.dart';
import '../../models/user_model.dart';
import '../../models/payment_model.dart';
import '../../models/subscription_plan_model.dart';
import '../payment/payment_screen.dart';

/// شاشة الاشتراكات
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = Get.find<AuthService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();
  final PaymobService _paymobService = PaymobService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false; // لمنع الضغط المتكرر

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

    // Fetch subscription plans from backend
    _subscriptionService.fetchSubscriptionPlans();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'خطط الاشتراك',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ارتقِ بعملك إلى المستوى التالي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اختر الخطة المناسبة لك واستمتع بمميزات غير محدودة',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Display subscription plans from backend
              Obx(() {
                if (_subscriptionService.isLoadingPlans) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.neonCyan,
                        ),
                      ),
                    ),
                  );
                }

                if (_subscriptionService.plansError.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _subscriptionService.plansError,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _subscriptionService.fetchSubscriptionPlans(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final plans = _subscriptionService.subscriptionPlans;

                if (plans.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    child: const Text(
                      'لا توجد خطط اشتراك متاحة حالياً',
                      style: TextStyle(color: AppColors.textLight),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: plans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final plan = entry.value;

                    return TweenAnimationBuilder<double>(
                      key: ValueKey(plan.id),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 700 + (index * 100)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildPlanCardFromModel(plan),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 32),

              // Features Comparison
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.neonCyan,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'ملاحظات هامة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '• جميع الأسعار بالدرهم الإماراتي\n'
                      '• الاشتراك شهري ويتجدد تلقائياً\n'
                      '• يمكن إلغاء الاشتراك في أي وقت\n'
                      '• الدفع آمن ومشفر 100%\n'
                      '• دعم فني متاح لجميع المشتركين',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required Gradient gradient,
    required Color borderColor,
    required List<String> features,
    required bool isPopular,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isPopular
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: isPopular
                            ? AppColors.neonCyan
                            : AppColors.neonPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (badge != null) const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  period,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Features
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: gradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSubscription(title, price),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: borderColor, width: 2),
                      ),
                    ),
                    child: Text(
                      _getButtonText(title),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build plan card from SubscriptionPlanModel
  Widget _buildPlanCardFromModel(SubscriptionPlanModel plan) {
    // Determine gradient and border color based on tier
    Gradient gradient;
    Color borderColor;

    switch (plan.tier) {
      case 'individual':
        gradient = AppColors.cyanPurpleGradient;
        borderColor = AppColors.neonCyan;
        break;
      case 'business':
      case 'team':
        gradient = AppColors.purpleMagentaGradient;
        borderColor = AppColors.neonPurple;
        break;
      case 'enterprise':
        gradient = const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        );
        borderColor = const Color(0xFFFFD700);
        break;
      default:
        gradient = AppColors.cyanPurpleGradient;
        borderColor = AppColors.neonCyan;
    }

    // Use monthly price
    final price = plan.monthlyPrice;
    final priceText = '${price.toStringAsFixed(2)} ${plan.currency}';
    final period = 'شهرياً';

    // Add checkmark to features if not already present
    final features = plan.featuresAr
        .map((f) => f.startsWith('✓') ? f : '✓ $f')
        .toList();

    return _buildPlanCard(
      title: plan.nameAr,
      price: priceText,
      period: period,
      gradient: gradient,
      borderColor: borderColor,
      features: features,
      isPopular: plan.isPopular,
      badge: plan.badgeAr,
    );
  }

  String _getButtonText(String planTitle) {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return 'اشترك الآن';

    switch (planTitle) {
      case 'باقة الأفراد':
        return currentUser.isIndividualTier
            ? 'الباقة الحالية'
            : 'اشترك في باقة الأفراد';
      case 'باقة الشركات':
        return currentUser.isBusinessTier
            ? 'الباقة الحالية'
            : 'اشترك في باقة الشركات';
      default:
        return 'اشترك الآن';
    }
  }

  void _handleSubscription(String planTitle, String price) {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return;

    // تحديد نوع الخطة
    String tier;
    // دعم الأسماء القديمة والجديدة
    if (planTitle.contains('فرد') || planTitle.contains('Individual')) {
      tier = 'individual';
    } else if (planTitle.contains('أعمال') ||
        planTitle.contains('Business') ||
        planTitle.contains('شركات')) {
      tier = 'business';
    } else {
      // إذا لم نتمكن من تحديد النوع، نفترض أنها ترقية
      tier = 'individual';
    }

    // إذا كانت نفس الخطة الحالية
    if (currentUser.subscriptionTier == tier) {
      Get.snackbar(
        'خطة نشطة',
        'أنت بالفعل مشترك في هذه الخطة',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.info_outline_rounded, color: AppColors.neonCyan),
      );
      return;
    }

    // عرض نافذة تأكيد
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
                  Icons.rocket_launch_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tier == 'free' ? 'تأكيد الرجوع' : 'تأكيد الترقية',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tier == 'free'
                    ? 'هل تريد الرجوع إلى الخطة المجانية؟'
                    : 'هل تريد الترقية إلى خطة $planTitle؟',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _processUpgrade(tier, planTitle);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تأكيد',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  void _processUpgrade(String tier, String planTitle) async {
    if (_isProcessing) return; // منع الضغط المتكرر

    final user = _authService.currentUser.value;
    if (user == null) {
      Get.snackbar(
        'خطأ',
        'يجب تسجيل الدخول أولاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // إذا كانت الخطة المجانية، لا حاجة للدفع
    if (tier == 'free') {
      await _downgradeTofree(user, planTitle);
      return;
    }

    // التحقق من تكوين Paymob - استخدام PaymobConfig مباشرة
    if (PaymobConfig.apiKey.isEmpty) {
      Get.snackbar(
        'خدمة الدفع غير متوفرة',
        'يرجى التواصل مع الدعم الفني لتفعيل خدمة الدفع',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // العثور على الخطة من القائمة
      final plan = _subscriptionService.subscriptionPlans.firstWhere(
        (p) => p.tier == tier,
        orElse: () => _subscriptionService.subscriptionPlans.first,
      );

      final amount = plan.monthlyPrice;

      print('💰 بدء عملية الدفع - المبلغ: $amount ${plan.currency}');

      // عرض رسالة تحميل
      Get.dialog(
        const Center(
          child: Card(
            color: AppColors.darkCard,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.neonCyan,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تجهيز صفحة الدفع...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // إنشاء عملية دفع
      final paymentResult = await _paymobService.initiatePayment(
        userId: user.id,
        userEmail: user.email,
        userName: user.name,
        userPhone: user.phoneNumber,
        subscriptionTier: tier,
        amount: amount,
        currency: plan.currency,
      );

      // إغلاق رسالة التحميل
      Get.back();

      if (!paymentResult.isSuccess) {
        Get.snackbar(
          'فشل في تجهيز الدفع',
          paymentResult.errorMessage ?? 'حدث خطأ غير متوقع',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        setState(() => _isProcessing = false);
        return;
      }

      print('✅ Payment URL: ${paymentResult.paymentUrl}');

      // فتح شاشة الدفع
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            paymentUrl: paymentResult.paymentUrl!,
            orderId: paymentResult.orderId!,
            subscriptionTier: tier,
          ),
        ),
      );

      // معالجة نتيجة الدفع
      if (result != null && result is Map<String, dynamic>) {
        final status = result['status'] as PaymentStatusEnum;

        if (status == PaymentStatusEnum.success) {
          final expiresAt = DateTime.now().add(const Duration(days: 30));

          // تحديث المستخدم المحلي
          final updatedUser = user.copyWith(
            subscriptionTier: tier,
            subscriptionStartDate: DateTime.now(),
            subscriptionEndDate: expiresAt,
          );

          // محاولة تحديث في Firestore إذا كان متاحاً
          try {
            await _firestoreService.updateUser(updatedUser);
          } catch (e) {
            print('⚠️ تعذر التحديث في Firestore: $e');
          }

          _authService.currentUser.value = updatedUser;

          Get.snackbar(
            'تمت الترقية بنجاح!',
            'تم ترقية اشتراكك إلى خطة $planTitle',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 4),
          );

          setState(() {}); // تحديث الواجهة
        }
      }
    } catch (e) {
      print('❌ خطأ في عملية الدفع: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء معالجة الدفع: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// الرجوع للخطة المجانية (بدون دفع)
  Future<void> _downgradeTofree(UserModel user, String planTitle) async {
    setState(() => _isProcessing = true);

    try {
      // تحديث المستخدم المحلي والـ Firestore
      final updatedUser = user.copyWith(
        subscriptionTier: 'free',
        subscriptionStartDate: DateTime.now(),
        subscriptionEndDate: null,
      );

      await _firestoreService.updateUser(updatedUser);
      _authService.currentUser.value = updatedUser;

      Get.snackbar(
        'تم التغيير',
        'تم الرجوع إلى الخطة المجانية',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: AppColors.neonCyan),
        duration: const Duration(seconds: 3),
      );

      setState(() {}); // تحديث الواجهة
    } catch (e) {
      print('❌ خطأ في تغيير الخطة: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تغيير الخطة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
