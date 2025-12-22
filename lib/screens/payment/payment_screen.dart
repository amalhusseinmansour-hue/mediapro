import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/payment_model.dart';
import '../../core/constants/app_colors.dart';
import '../../services/paymob_service.dart';

/// شاشة الدفع عبر Paymob (متصفح خارجي)
class PaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final int orderId;
  final String subscriptionTier;

  const PaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.subscriptionTier,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver {
  final PaymobService _paymobService = PaymobService();
  Timer? _statusTimer;
  bool _isChecking = false;
  bool _paymentLaunched = false;
  bool _isTestMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // التحقق من الوضع التجريبي
    if (widget.paymentUrl == 'test_mode') {
      _isTestMode = true;
    } else {
      // فتح رابط الدفع تلقائياً عند بدء الشاشة
      _launchPaymentUrl();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // عند العودة للتطبيق، تحقق من الحالة
    if (state == AppLifecycleState.resumed && _paymentLaunched && !_isTestMode) {
      _checkPaymentStatus();
    }
  }

  Future<void> _launchPaymentUrl() async {
    if (_isTestMode) return;

    final uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // فتح في متصفح خارجي لتجنب مشاكل iframe
      );
      setState(() {
        _paymentLaunched = true;
      });
      
      // بدء التحقق الدوري
      _startPolling();
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح رابط الدفع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startPolling() {
    _statusTimer?.cancel();
    // تحقق كل 5 ثواني
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking || _isTestMode) return;
    
    setState(() => _isChecking = true);

    try {
      final status = await _paymobService.checkPaymentStatus(widget.orderId);
      
      if (status == PaymentStatus.success) {
        _statusTimer?.cancel();
        _handlePaymentSuccess();
      } else if (status == PaymentStatus.failed) {
        _statusTimer?.cancel();
        _handlePaymentFailure();
      }
      // إذا كان pending، نستمر في التحقق
    } catch (e) {
      print('Error checking status: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  void _handlePaymentSuccess() {
    Get.back(result: {
      'status': PaymentStatusEnum.success,
      'orderId': widget.orderId,
      'tier': widget.subscriptionTier,
    });

    Get.snackbar(
      'نجح الدفع',
      'تم تفعيل اشتراكك بنجاح',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _handlePaymentFailure() {
    Get.back(result: {
      'status': PaymentStatusEnum.failed,
      'orderId': widget.orderId,
    });

    Get.snackbar(
      'فشل الدفع',
      'لم تكتمل عملية الدفع. يرجى المحاولة مرة أخرى',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _handlePaymentCancelled() {
    Get.back(result: {
      'status': PaymentStatusEnum.cancelled,
      'orderId': widget.orderId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: Text(_isTestMode ? 'الوضع التجريبي' : 'إتمام الدفع'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: _isTestMode ? _buildTestModeUI() : _buildLiveModeUI(),
    );
  }

  Widget _buildLiveModeUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.payment_rounded,
                size: 64,
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'جاري عملية الدفع...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'يرجى إتمام عملية الدفع في المتصفح، ثم العودة إلى التطبيق.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            if (_isChecking)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              )
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _checkPaymentStatus,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('التحقق من حالة الدفع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _launchPaymentUrl,
                    icon: const Icon(Icons.open_in_browser_rounded),
                    label: const Text('فتح صفحة الدفع مرة أخرى'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.neonPurple,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestModeUI() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  size: 64,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'وضع الدفع التجريبي',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'هذا الوضع التجريبي يسمح لك باختبار عملية الاشتراك دون الحاجة لإدخال بيانات دفع حقيقية.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order ID: ${widget.orderId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الباقة: ${widget.subscriptionTier}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success Button
                  ElevatedButton.icon(
                    onPressed: _handlePaymentSuccess,
                    icon: const Icon(Icons.check_circle_outline, size: 28),
                    label: const Text(
                      'محاكاة دفع ناجح',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Failure Button
                  OutlinedButton.icon(
                    onPressed: _handlePaymentFailure,
                    icon: const Icon(Icons.error_outline, size: 24),
                    label: const Text(
                      'محاكاة دفع فاشل',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel Button
                  TextButton.icon(
                    onPressed: _handlePaymentCancelled,
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text(
                      'إلغاء',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('إلغاء عملية الدفع؟', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل أنت متأكد من إلغاء عملية الدفع؟ سيتم فقدان التقدم الحالي.',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('استمرار'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePaymentCancelled();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إلغاء الدفع'),
          ),
        ],
      ),
    );
  }
}
