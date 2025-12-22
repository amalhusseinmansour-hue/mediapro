/// ملف اختبار سريع لتشخيص مشكلة Paymob
///
/// كيفية الاستخدام:
/// 1. أضفه إلى مشروع Flutter
/// 2. استدعِ [runPaymobDiagnostics()] في main.dart أو أي مكان مناسب
/// 3. انظر إلى console output للنتائج

import 'package:social_media_manager/services/paymob_service.dart';

/// تشغيل تشخيصات Paymob الكاملة
Future<void> runPaymobDiagnostics() async {
  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║          PAYMOB AUTHENTICATION DIAGNOSTICS                  ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  final paymobService = PaymobService();

  // تشغيل التشخيص
  final result = await paymobService.diagnosePaymobConnection();

  // طباعة النتيجة
  print('\n📋 Diagnostic Result:');
  print('─' * 60);
  print(result);
  print('─' * 60);

  // التوصيات
  print('\n💡 Recommendations:');
  if (result.isTestMode) {
    print('✓ ✓ ✓ Test mode is enabled - suitable for development');
  } else if (result.isConnected) {
    print('✓ ✓ ✓ Paymob connection is working properly');
  } else if (result.hasError) {
    print('✗ ✗ ✗ Paymob connection has errors');

    if (result.errorCode == 403) {
      print('\n  🔑 Error 403 - Authentication Failed');
      print('  → Your API key is incorrect or expired');
      print('  → Steps to fix:');
      print('    1. Go to https://accept.paymob.com/portal2/en/settings');
      print('    2. Navigate to API Keys section');
      print('    3. Copy the correct API Key');
      print('    4. Update paymobApiKey in lib/core/config/api_config.dart');
      print('    5. Try again');
    } else if (result.errorCode == 400) {
      print('\n  📝 Error 400 - Bad Request');
      print('  → Check the request format');
      print('  → Ensure API key is in the correct format');
    } else if (result.errorCode == 401) {
      print('\n  🔐 Error 401 - Unauthorized');
      print('  → API key might be expired or has insufficient permissions');
      print('  → Try regenerating the API key');
    } else {
      print('\n  ⚠️ Error ${result.errorCode}');
      print('  → ${result.message}');
    }
  }

  // معلومات مفيدة
  print('\n📚 Useful Links:');
  print('  • Paymob Dashboard: https://accept.paymob.com/portal2');
  print('  • API Keys: https://accept.paymob.com/portal2/en/settings');
  print('  • Documentation: https://docs.paymob.com');
  print('  • Support: support@paymob.com');

  print('\n' + ('═' * 60) + '\n');
}

/// اختبار بسيط للمصادقة مع Paymob
/// يستخدم Intention API الجديد
Future<void> testPaymobAuthentication() async {
  print('\n🧪 Testing Paymob Authentication...\n');

  final paymobService = PaymobService();
  final result = await paymobService.diagnosePaymobConnection();

  if (result.isConnected) {
    print('✅ Authentication Successful');
    print('🔗 Paymob Intention API is working');
  } else {
    print('❌ Authentication Failed');
    print('💡 Error: ${result.message}');
    print('💡 See diagnostic above for troubleshooting steps');
  }
}

/// معلومات عن الخدمات المتاحة
void printServicesStatus() {
  print('\n📊 Services Status:');
  print('─' * 60);

  // Placeholder - في التطبيق الحقيقي يكون هناك استدعاء لـ ApiConfig
  print('Paymob: ❓ (run diagnosis to check)');

  print('─' * 60 + '\n');
}
