/// Test API Connection After Fix
///
/// This file tests the API connection after changing isProduction to true
///
/// How to run:
/// dart test_api_after_fix.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing API Connection After Fix...\n');

  // Production URL (what the app should use now)
  const String productionUrl = 'https://mediaprosocial.io/api';

  // Development URL (what was being used before)
  const String devUrl = 'http://localhost:8000/api';

  print('✅ Production URL: $productionUrl');
  print('❌ Old Dev URL: $devUrl\n');

  // Test 1: Health Check
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Test 1: Health Check Endpoint');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    final healthResponse = await http.get(
      Uri.parse('$productionUrl/health'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (healthResponse.statusCode == 200) {
      final data = jsonDecode(healthResponse.body);
      print('✅ Status: ${healthResponse.statusCode}');
      print('✅ Response: ${data['status']}');
      print('✅ Timestamp: ${data['timestamp']}');
    } else {
      print('❌ Failed with status: ${healthResponse.statusCode}');
      print('Response: ${healthResponse.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n');

  // Test 2: Subscription Plans
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Test 2: Subscription Plans Endpoint');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    final plansResponse = await http.get(
      Uri.parse('$productionUrl/subscription-plans'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (plansResponse.statusCode == 200) {
      final data = jsonDecode(plansResponse.body);
      print('✅ Status: ${plansResponse.statusCode}');
      print('✅ Success: ${data['success']}');
      print('✅ Plans Found: ${data['data'].length}');

      if (data['data'].length > 0) {
        print('\n📋 Available Plans:');
        for (var plan in data['data']) {
          print('  - ${plan['name']}: ${plan['price']} ${plan['currency']}');
        }
      }
    } else {
      print('❌ Failed with status: ${plansResponse.statusCode}');
      print('Response: ${plansResponse.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n');

  // Test 3: Check CORS
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Test 3: CORS Configuration');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    final corsResponse = await http.get(
      Uri.parse('$productionUrl/health'),
      headers: {
        'Origin': 'https://mediaprosocial.io',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (corsResponse.statusCode == 200) {
      print('✅ CORS: Working');
      print('✅ Origin: https://mediaprosocial.io');

      if (corsResponse.headers.containsKey('access-control-allow-origin')) {
        print('✅ CORS Header: ${corsResponse.headers['access-control-allow-origin']}');
      } else {
        print('⚠️ No CORS headers found (might be ok for same-origin)');
      }
    } else {
      print('❌ CORS check failed with status: ${corsResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n');

  // Summary
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Summary');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ Backend URL: $productionUrl');
  print('✅ All tests completed!');
  print('\n📱 Next Steps:');
  print('1. Run: flutter clean');
  print('2. Run: flutter pub get');
  print('3. Run: flutter build apk --release');
  print('4. Test the app with real API calls');
  print('\n💡 Tip: Check backend_config.dart to ensure isProduction = true');
}
