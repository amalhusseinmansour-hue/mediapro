import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String callbackUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.callbackUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  final RxBool _isLoading = true.obs;
  final RxDouble _progress = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.darkBg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _progress.value = progress / 100;
            print('🌐 Payment page loading: $progress%');
          },
          onPageStarted: (String url) {
            print('🌐 Page started loading: $url');
            _isLoading.value = true;
          },
          onPageFinished: (String url) {
            print('✅ Page finished loading: $url');
            _isLoading.value = false;

            // Check if payment completed
            _checkPaymentCompletion(url);
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Web resource error: ${error.description}');
            _showErrorDialog(error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔍 Navigation request: ${request.url}');

            // Check if navigation is to Deep Link callback (socialmediamanager://)
            if (request.url.startsWith('socialmediamanager://')) {
              print('✅ Deep Link callback detected: ${request.url}');
              // Check for success indicators in the URL
              if (request.url.contains('success=true') ||
                  request.url.contains('status=successful') ||
                  request.url.contains('payment/callback')) {
                _handlePaymentSuccess();
              } else if (request.url.contains('success=false') ||
                  request.url.contains('status=failed')) {
                _handlePaymentFailure();
              } else {
                // Default to success if it's our callback URL
                _handlePaymentSuccess();
              }
              return NavigationDecision.prevent;
            }

            // Check if navigation is to callback URL (Paymob UAE redirections)
            if (request.url.contains(widget.callbackUrl) ||
                request.url.contains('payment/callback') ||
                request.url.contains('success=true') ||
                request.url.contains('txn_response_code=APPROVED') ||
                request.url.contains('status=successful')) {
              print('✅ Payment callback detected');
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }

            // Check for payment failure
            if (request.url.contains('success=false') ||
                request.url.contains('payment/failed') ||
                request.url.contains('txn_response_code=DECLINED') ||
                request.url.contains('status=failed')) {
              print('❌ Payment failed detected');
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentCompletion(String url) {
    // Check various success indicators (including Paymob UAE response codes)
    if (url.contains('success=true') ||
        url.contains('payment/success') ||
        url.contains('transaction_processed=true') ||
        url.contains('txn_response_code=APPROVED') ||
        url.contains('status=successful')) {
      _handlePaymentSuccess();
    } else if (url.contains('success=false') ||
        url.contains('payment/failed') ||
        url.contains('payment/cancel') ||
        url.contains('txn_response_code=DECLINED') ||
        url.contains('status=failed')) {
      _handlePaymentFailure();
    }
  }

  void _handlePaymentSuccess() {
    print('✅ Payment completed successfully');
    Get.back(result: true);
    Get.snackbar(
      'نجح',
      'تمت عملية الدفع بنجاح',
      backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.check_circle, color: AppColors.neonCyan),
      duration: const Duration(seconds: 3),
    );
  }

  void _handlePaymentFailure() {
    print('❌ Payment failed or cancelled');
    Get.back(result: false);
    Get.snackbar(
      'فشل',
      'فشلت عملية الدفع. الرجاء المحاولة مرة أخرى',
      backgroundColor: Colors.red.withValues(alpha: 0.2),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorDialog(String error) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'حدث خطأ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(result: false); // Close WebView
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // Close dialog
                          _controller.reload(); // Retry loading
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
                          'إعادة المحاولة',
                          style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        // Confirm before closing payment screen
        final confirmed = await Get.dialog<bool>(
          Dialog(
            backgroundColor: AppColors.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'إلغاء عملية الدفع؟',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'هل أنت متأكد من رغبتك في إلغاء عملية الدفع؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(result: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'متابعة الدفع',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(color: Colors.white),
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

        if (confirmed == true) {
          Get.back(result: false); // Return false to indicate cancelled payment
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkCard,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.cyanPurpleGradient.createShader(bounds),
            child: const Text(
              'إتمام عملية الدفع',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.neonCyan),
            onPressed: () {
              // Trigger back navigation which will show the confirmation dialog
              Navigator.of(context).maybePop();
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Obx(
              () => LinearProgressIndicator(
                value: _isLoading.value ? _progress.value : 1.0,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progress.value < 1.0
                      ? AppColors.neonCyan
                      : Colors.transparent,
                ),
                minHeight: 4,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            Obx(
              () => _isLoading.value && _progress.value < 0.3
                  ? Container(
                      color: AppColors.darkBg,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppColors.cyanPurpleGradient.scale(
                                  0.3,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.neonCyan,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'جاري تحميل صفحة الدفع...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'الرجاء الانتظار',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
