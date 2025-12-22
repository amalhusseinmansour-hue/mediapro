import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';
import '../services/connectivity_service.dart';

/// Utility class for diagnosing API connectivity issues
class ApiDiagnostics {
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Run comprehensive API connectivity diagnostics
  Future<DiagnosticReport> runDiagnostics() async {
    final report = DiagnosticReport();

    // 1. Check internet connectivity
    print('\n========== API Diagnostics Started ==========');
    print('1️⃣ Checking internet connectivity...');
    report.hasInternetConnection = await _connectivityService.hasConnection();
    report.connectionType = _connectivityService.connectionTypeString;
    print('   Result: ${report.hasInternetConnection ? "✅ Connected" : "❌ No Connection"}');
    print('   Type: ${report.connectionType}');

    // 2. DNS Resolution Test
    print('\n2️⃣ Testing DNS resolution...');
    try {
      final uri = Uri.parse(BackendConfig.baseUrl);
      final host = uri.host;
      final addresses = await InternetAddress.lookup(host);
      report.dnsResolved = addresses.isNotEmpty;
      report.resolvedIPs = addresses.map((addr) => addr.address).toList();
      print('   Result: ✅ DNS resolved successfully');
      print('   Host: $host');
      print('   IPs: ${report.resolvedIPs.join(", ")}');
    } catch (e) {
      report.dnsResolved = false;
      report.dnsError = e.toString();
      print('   Result: ❌ DNS resolution failed');
      print('   Error: ${e.toString()}');
    }

    // 3. Ping Test (HTTP HEAD request)
    print('\n3️⃣ Testing server reachability...');
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.head(
        Uri.parse(BackendConfig.baseUrl),
        headers: BackendConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));

      stopwatch.stop();
      report.serverReachable = true;
      report.pingTimeMs = stopwatch.elapsedMilliseconds;
      report.serverStatusCode = response.statusCode;
      print('   Result: ✅ Server reachable');
      print('   Status Code: ${response.statusCode}');
      print('   Response Time: ${report.pingTimeMs}ms');
    } catch (e) {
      report.serverReachable = false;
      report.serverError = e.toString();
      print('   Result: ❌ Server not reachable');
      print('   Error: ${e.toString()}');
    }

    // 4. SSL/TLS Certificate Check
    print('\n4️⃣ Checking SSL/TLS certificate...');
    if (BackendConfig.baseUrl.startsWith('https://')) {
      try {
        final uri = Uri.parse(BackendConfig.baseUrl);
        final socket = await SecureSocket.connect(
          uri.host,
          uri.port == 0 ? 443 : uri.port,
          timeout: const Duration(seconds: 10),
        );
        report.sslValid = true;
        report.sslCertificate = socket.peerCertificate?.subject ?? 'Unknown';
        await socket.close();
        print('   Result: ✅ SSL certificate valid');
        print('   Subject: ${report.sslCertificate}');
      } catch (e) {
        report.sslValid = false;
        report.sslError = e.toString();
        print('   Result: ❌ SSL certificate error');
        print('   Error: ${e.toString()}');
      }
    } else {
      report.sslValid = null; // Not applicable for HTTP
      print('   Result: ⚠️ Not using HTTPS');
    }

    // 5. API Endpoint Test
    print('\n5️⃣ Testing API endpoint...');
    try {
      final response = await http.get(
        Uri.parse('${BackendConfig.baseUrl}/health'),
        headers: BackendConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));

      report.apiEndpointReachable = response.statusCode == 200;
      report.apiStatusCode = response.statusCode;
      report.apiResponse = response.body;
      print('   Result: ${report.apiEndpointReachable ? "✅" : "⚠️"} API responded');
      print('   Status Code: ${response.statusCode}');
    } catch (e) {
      report.apiEndpointReachable = false;
      report.apiError = e.toString();
      print('   Result: ❌ API endpoint error');
      print('   Error: ${e.toString()}');
    }

    print('\n========== Diagnostics Completed ==========\n');
    return report;
  }

  /// Quick connectivity check
  Future<bool> quickCheck() async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) return false;

      final response = await http.head(
        Uri.parse(BackendConfig.baseUrl),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  /// Print diagnostic report summary
  static void printReport(DiagnosticReport report) {
    print('\n📊 Diagnostic Report Summary:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🌐 Internet: ${report.hasInternetConnection ? "✅" : "❌"} (${report.connectionType})');
    print('🔍 DNS: ${report.dnsResolved ? "✅" : "❌"}');
    if (report.dnsResolved) {
      print('   IPs: ${report.resolvedIPs.join(", ")}');
    }
    print('📡 Server: ${report.serverReachable ? "✅" : "❌"}');
    if (report.serverReachable) {
      print('   Response Time: ${report.pingTimeMs}ms');
    }
    print('🔒 SSL: ${report.sslValid == true ? "✅" : report.sslValid == false ? "❌" : "N/A"}');
    print('🔌 API: ${report.apiEndpointReachable ? "✅" : "❌"}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
}

/// Diagnostic report data class
class DiagnosticReport {
  // Internet connectivity
  bool hasInternetConnection = false;
  String connectionType = 'Unknown';

  // DNS resolution
  bool dnsResolved = false;
  List<String> resolvedIPs = [];
  String? dnsError;

  // Server reachability
  bool serverReachable = false;
  int pingTimeMs = 0;
  int? serverStatusCode;
  String? serverError;

  // SSL/TLS
  bool? sslValid;
  String? sslCertificate;
  String? sslError;

  // API endpoint
  bool apiEndpointReachable = false;
  int? apiStatusCode;
  String? apiResponse;
  String? apiError;

  /// Overall health status
  bool get isHealthy =>
      hasInternetConnection &&
      dnsResolved &&
      serverReachable &&
      (sslValid ?? true) &&
      apiEndpointReachable;

  /// Get summary text
  String getSummary() {
    if (isHealthy) {
      return '✅ جميع الاختبارات نجحت. الاتصال بالـ API يعمل بشكل صحيح.';
    }

    final issues = <String>[];
    if (!hasInternetConnection) {
      issues.add('❌ لا يوجد اتصال بالإنترنت');
    }
    if (!dnsResolved) {
      issues.add('❌ فشل في حل اسم النطاق (DNS)');
    }
    if (!serverReachable) {
      issues.add('❌ الخادم غير متاح');
    }
    if (sslValid == false) {
      issues.add('❌ مشكلة في شهادة SSL');
    }
    if (!apiEndpointReachable) {
      issues.add('❌ الـ API لا يستجيب');
    }

    return issues.join('\n');
  }

  /// Get detailed report as JSON
  Map<String, dynamic> toJson() {
    return {
      'internet': {
        'connected': hasInternetConnection,
        'type': connectionType,
      },
      'dns': {
        'resolved': dnsResolved,
        'ips': resolvedIPs,
        'error': dnsError,
      },
      'server': {
        'reachable': serverReachable,
        'pingMs': pingTimeMs,
        'statusCode': serverStatusCode,
        'error': serverError,
      },
      'ssl': {
        'valid': sslValid,
        'certificate': sslCertificate,
        'error': sslError,
      },
      'api': {
        'reachable': apiEndpointReachable,
        'statusCode': apiStatusCode,
        'response': apiResponse,
        'error': apiError,
      },
      'healthy': isHealthy,
    };
  }
}
