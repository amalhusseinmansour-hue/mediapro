import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/backend_config.dart';
import 'http_service.dart';

/// Admin API Service
/// Handles all admin panel API calls to Laravel backend
class AdminApiService extends GetxController {
  static String get baseUrl => BackendConfig.baseUrl;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Dashboard Statistics
  final RxMap<String, dynamic> dashboardStats = <String, dynamic>{}.obs;

  // Settings Data
  final RxMap<String, dynamic> allSettings = <String, dynamic>{}.obs;

  /// Get auth token from HttpService
  String? get _authToken {
    try {
      if (Get.isRegistered<HttpService>()) {
        final httpService = Get.find<HttpService>();
        return httpService.authToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get headers with auth
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ==================== DASHBOARD STATISTICS ====================

  /// Fetch dashboard statistics
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('Fetching admin dashboard statistics...');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard/stats'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      print('Dashboard stats response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          dashboardStats.value = data['data'] ?? {};
          print('Dashboard stats loaded successfully');
          return dashboardStats;
        }
      }

      // Return default stats if API fails
      return _getDefaultStats();
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      errorMessage.value = e.toString();
      return _getDefaultStats();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get default statistics (fallback)
  Map<String, dynamic> _getDefaultStats() {
    return {
      'users': {'total': 0, 'trend': '+0%', 'active': 0, 'new_today': 0},
      'ads': {'total': 0, 'pending': 0, 'approved': 0, 'rejected': 0},
      'payments': {'total': 0.0, 'trend': '+0%', 'today': 0.0, 'month': 0.0},
      'subscriptions': {'total': 0, 'active': 0, 'expired': 0, 'trend': '+0%'},
    };
  }

  // ==================== USERS MANAGEMENT ====================

  /// Fetch all users
  Future<List<Map<String, dynamic>>> fetchUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
  }) async {
    try {
      isLoading.value = true;
      print('Fetching users list...');

      var url = '$baseUrl/admin/users?page=$page&per_page=$perPage';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (status != null && status.isNotEmpty) url += '&status=$status';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final users = (data['data']['users'] as List?)
              ?.map((u) => Map<String, dynamic>.from(u))
              .toList();
          return users ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user status
  Future<bool> updateUserStatus(String userId, String status) async {
    try {
      isLoading.value = true;
      print('Updating user $userId status to $status...');

      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId/status'),
        headers: _headers,
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      print('Deleting user $userId...');

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== ADS MANAGEMENT ====================

  /// Fetch ads for review
  Future<List<Map<String, dynamic>>> fetchAdsForReview({
    String status = 'pending',
    int page = 1,
  }) async {
    try {
      isLoading.value = true;
      print('Fetching ads for review...');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/ads?status=$status&page=$page'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final ads = (data['data']['ads'] as List?)
              ?.map((a) => Map<String, dynamic>.from(a))
              .toList();
          return ads ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Approve ad
  Future<bool> approveAd(String adId) async {
    try {
      isLoading.value = true;
      print('Approving ad $adId...');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/ads/$adId/approve'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error approving ad: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reject ad
  Future<bool> rejectAd(String adId, {String? reason}) async {
    try {
      isLoading.value = true;
      print('Rejecting ad $adId...');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/ads/$adId/reject'),
        headers: _headers,
        body: json.encode({'reason': reason ?? 'Rejected by admin'}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting ad: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== PAYMENTS MANAGEMENT ====================

  /// Fetch payments
  Future<List<Map<String, dynamic>>> fetchPayments({
    int page = 1,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      isLoading.value = true;
      print('Fetching payments...');

      var url = '$baseUrl/admin/payments?page=$page';
      if (status != null) url += '&status=$status';
      if (dateFrom != null) url += '&date_from=$dateFrom';
      if (dateTo != null) url += '&date_to=$dateTo';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final payments = (data['data']['payments'] as List?)
              ?.map((p) => Map<String, dynamic>.from(p))
              .toList();
          return payments ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Refund payment
  Future<bool> refundPayment(String paymentId) async {
    try {
      isLoading.value = true;
      print('Refunding payment $paymentId...');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/payments/$paymentId/refund'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error refunding payment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SETTINGS MANAGEMENT ====================

  /// Fetch all settings
  Future<Map<String, dynamic>> fetchAllSettings() async {
    try {
      isLoading.value = true;
      print('Fetching all admin settings...');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/settings'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          allSettings.value = data['data'] ?? {};
          print('Settings loaded: ${allSettings.keys.length} groups');
          return allSettings;
        }
      }

      // Fallback to public settings endpoint
      return await _fetchPublicSettings();
    } catch (e) {
      print('Error fetching settings: $e');
      return await _fetchPublicSettings();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch public settings (fallback)
  Future<Map<String, dynamic>> _fetchPublicSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/app-config'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          allSettings.value = data['data'] ?? {};
          return allSettings;
        }
      }
      return {};
    } catch (e) {
      print('Error fetching public settings: $e');
      return {};
    }
  }

  /// Update setting
  Future<bool> updateSetting(String group, String key, dynamic value) async {
    try {
      isLoading.value = true;
      print('Updating setting $group.$key...');

      final response = await http.put(
        Uri.parse('$baseUrl/admin/settings'),
        headers: _headers,
        body: json.encode({
          'group': group,
          'key': key,
          'value': value,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Update local cache
        if (allSettings[group] != null) {
          allSettings[group][key] = value;
          allSettings.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating setting: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update multiple settings
  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    try {
      isLoading.value = true;
      print('Updating multiple settings...');

      final response = await http.put(
        Uri.parse('$baseUrl/admin/settings/batch'),
        headers: _headers,
        body: json.encode({'settings': settings}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Refresh all settings
        await fetchAllSettings();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== REPORTS ====================

  /// Fetch reports data
  Future<Map<String, dynamic>> fetchReports({
    String period = 'month',
    String? type,
  }) async {
    try {
      isLoading.value = true;
      print('Fetching reports...');

      var url = '$baseUrl/admin/reports?period=$period';
      if (type != null) url += '&type=$type';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        }
      }
      return {};
    } catch (e) {
      print('Error fetching reports: $e');
      return {};
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get setting value by path
  dynamic getSetting(String path) {
    final parts = path.split('.');
    dynamic value = allSettings;
    for (final part in parts) {
      if (value is Map && value.containsKey(part)) {
        value = value[part];
      } else {
        return null;
      }
    }
    return value;
  }

  /// Check if user is admin
  Future<bool> checkAdminAccess() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/check-access'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_admin'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking admin access: $e');
      return false;
    }
  }
}
