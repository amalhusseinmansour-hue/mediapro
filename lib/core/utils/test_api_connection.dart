/// Test file for API connection diagnostics
///
/// Usage: Import this file and call testApiConnection() from anywhere in your app
/// Example:
/// ```dart
/// import 'package:social_media_manager/core/utils/test_api_connection.dart';
///
/// // In your widget or controller
/// ElevatedButton(
///   onPressed: testApiConnection,
///   child: Text('Test API Connection'),
/// );
/// ```

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../../services/api_service.dart';
import 'api_diagnostics.dart';

/// Comprehensive API connection test
Future<void> testApiConnection() async {
  print('\n╔═══════════════════════════════════════════════╗');
  print('║   API Connection Test Started                 ║');
  print('╚═══════════════════════════════════════════════╝\n');

  try {
    // 1. Test Connectivity Service
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('1️⃣  Testing Connectivity Service');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final connectivityService = ConnectivityService();
    final hasConnection = await connectivityService.hasConnection();

    print('📱 Connection Status: ${hasConnection ? "✅ Connected" : "❌ Disconnected"}');
    print('📡 Connection Type: ${connectivityService.connectionTypeString}');

    if (!hasConnection) {
      print('\n⚠️  Cannot proceed without internet connection!');
      _showSnackbar('لا يوجد اتصال بالإنترنت', isError: true);
      return;
    }

    // 2. Run Diagnostics
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('2️⃣  Running API Diagnostics');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    final diagnostics = ApiDiagnostics();
    final report = await diagnostics.runDiagnostics();

    ApiDiagnostics.printReport(report);

    if (!report.isHealthy) {
      print('⚠️  Diagnostic Issues Found:');
      print(report.getSummary());
      _showSnackbar('تم اكتشاف مشاكل في الاتصال. راجع console للتفاصيل', isError: true);
    }

    // 3. Test Real API Call
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('3️⃣  Testing Real API Call');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    final apiService = ApiService();

    print('🔄 Fetching social accounts...');
    final startTime = DateTime.now();

    final response = await apiService.getSocialAccounts();

    final duration = DateTime.now().difference(startTime);

    print('✅ API call successful!');
    print('⏱️  Response time: ${duration.inMilliseconds}ms');
    print('📦 Response data: ${response.toString().substring(0, 100)}...');

    if (response.containsKey('data')) {
      final accountCount = (response['data'] as List?)?.length ?? 0;
      print('👥 Number of accounts: $accountCount');
      _showSnackbar('نجح الاتصال بالـ API! عدد الحسابات: $accountCount');
    } else {
      print('📄 Response structure: ${response.keys.join(", ")}');
      _showSnackbar('نجح الاتصال بالـ API!');
    }

    // Success summary
    print('\n╔═══════════════════════════════════════════════╗');
    print('║   ✅ All Tests Passed Successfully!           ║');
    print('╚═══════════════════════════════════════════════╝\n');

  } catch (e, stackTrace) {
    print('\n╔═══════════════════════════════════════════════╗');
    print('║   ❌ Test Failed                              ║');
    print('╚═══════════════════════════════════════════════╝\n');

    print('❌ Error: $e');
    print('📍 Stack trace:');
    print(stackTrace.toString().split('\n').take(5).join('\n'));

    _showSnackbar('فشل اختبار الاتصال: $e', isError: true);
  }
}

/// Quick API test (without detailed diagnostics)
Future<bool> quickApiTest() async {
  try {
    final connectivityService = ConnectivityService();
    final hasConnection = await connectivityService.hasConnection();

    if (!hasConnection) {
      print('❌ No internet connection');
      return false;
    }

    final apiService = ApiService();
    await apiService.getSocialAccounts();

    print('✅ Quick API test passed');
    return true;
  } catch (e) {
    print('❌ Quick API test failed: $e');
    return false;
  }
}

/// Helper to show snackbar
void _showSnackbar(String message, {bool isError = false}) {
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }

  Get.snackbar(
    isError ? '❌ خطأ' : '✅ نجاح',
    message,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
    colorText: const Color(0xFFFFFFFF),
  );
}

/// Print connectivity info
void printConnectivityInfo() {
  final connectivity = ConnectivityService();

  print('\n📊 Connectivity Information:');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Status: ${connectivity.isConnected.value ? "✅ Connected" : "❌ Disconnected"}');
  print('Type: ${connectivity.connectionTypeString}');
  print('WiFi: ${connectivity.isConnectedViaWiFi ? "✅" : "❌"}');
  print('Mobile: ${connectivity.isConnectedViaMobile ? "✅" : "❌"}');
  print('Ethernet: ${connectivity.isConnectedViaEthernet ? "✅" : "❌"}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}
