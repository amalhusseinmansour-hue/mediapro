import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/website_request_model.dart';
import 'api_service.dart';

class WebsiteRequestService extends GetxController {
  ApiService? _apiService;

  final RxBool isLoading = false.obs;
  final RxList<WebsiteRequestModel> requests = <WebsiteRequestModel>[].obs;

  // API Endpoint
  static const String _endpoint = 'website-requests';

  // Local storage
  Box<String>? _requestsBox;
  static const String _boxName = 'website_requests';

  @override
  void onInit() {
    super.onInit();
    _initLocalStorage();
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      print('⚠️ ApiService not found');
    }
  }

  Future<void> _initLocalStorage() async {
    try {
      _requestsBox = await Hive.openBox<String>(_boxName);
      await _loadLocalRequests();
      print('✅ WebsiteRequestService: Local storage initialized');
    } catch (e) {
      print('⚠️ WebsiteRequestService: Failed to init local storage: $e');
    }
  }

  Future<void> _loadLocalRequests() async {
    if (_requestsBox == null) return;

    try {
      final List<WebsiteRequestModel> localRequests = [];
      for (var key in _requestsBox!.keys) {
        final jsonStr = _requestsBox!.get(key);
        if (jsonStr != null) {
          final json = jsonDecode(jsonStr);
          localRequests.add(WebsiteRequestModel.fromJson(json));
        }
      }
      requests.value = localRequests;
      print('✅ Loaded ${localRequests.length} local website requests');
    } catch (e) {
      print('⚠️ Error loading local requests: $e');
    }
  }

  Future<void> _saveRequestLocally(WebsiteRequestModel request) async {
    if (_requestsBox == null) return;

    try {
      await _requestsBox!.put(request.id.toString(), jsonEncode(request.toJson()));
      print('✅ Website request saved locally: ${request.id}');
    } catch (e) {
      print('⚠️ Error saving request locally: $e');
    }
  }

  /// Submit a new website request
  Future<bool> submitRequest(WebsiteRequestModel request) async {
    try {
      isLoading.value = true;

      // Save locally first (always works)
      await _saveRequestLocally(request);
      requests.insert(0, request);
      print('✅ Website request saved locally');

      // Try server sync (optional)
      try {
        if (_apiService != null) {
          final response = await _apiService!.post(
            _endpoint,
            data: request.toJson(),
          );

          if (response['success'] == true) {
            print('✅ Website request synced with server');
          }
        }
      } catch (e) {
        print('⚠️ Server sync failed (request saved locally): $e');
        // Don't fail - request is saved locally
      }

      return true;
    } catch (e) {
      print('⚠️ Error submitting website request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all website requests (for admin)
  Future<void> fetchRequests({
    String? status,
    String? websiteType,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      isLoading.value = true;

      // Load from local storage first
      await _loadLocalRequests();

      // Try server sync
      if (_apiService != null) {
        final queryParams = <String, dynamic>{
          'page': page,
          'per_page': perPage,
          if (status != null) 'status': status,
          if (websiteType != null) 'website_type': websiteType,
          if (search != null) 'search': search,
        };

        try {
          final response = await _apiService!.get(
            _endpoint,
            queryParameters: queryParams,
          );

          if (response['success'] == true && response['data'] != null) {
            final data = response['data'];
            final List<dynamic> requestsJson = data['data'] ?? [];
            requests.value = requestsJson
                .map((json) => WebsiteRequestModel.fromJson(json))
                .toList();
            print('✅ Fetched ${requests.length} website requests from server');
          }
        } catch (e) {
          print('⚠️ Server fetch failed, using local data: $e');
        }
      }
    } catch (e) {
      print('⚠️ Error fetching website requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      if (_apiService == null) return {};

      final response = await _apiService!.get(
        '$_endpoint/statistics',
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }
      return {};
    } catch (e) {
      print('⚠️ Error fetching statistics: $e');
      return {};
    }
  }

  /// Update request status (admin only)
  Future<bool> updateRequest(int id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      if (_apiService == null) {
        print('⚠️ API Service not available');
        return false;
      }

      final response = await _apiService!.put(
        '$_endpoint/$id',
        data: data,
      );

      if (response['success'] == true) {
        print('✅ Website request updated successfully');
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to update request');
      }
    } catch (e) {
      print('⚠️ Error updating website request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete request (admin only)
  Future<bool> deleteRequest(int id) async {
    try {
      isLoading.value = true;

      // Delete locally
      if (_requestsBox != null) {
        await _requestsBox!.delete(id.toString());
      }
      requests.removeWhere((req) => req.id == id);

      // Try server delete
      if (_apiService != null) {
        try {
          final response = await _apiService!.delete(
            '$_endpoint/$id',
          );

          if (response['success'] == true) {
            print('✅ Website request deleted from server');
          }
        } catch (e) {
          print('⚠️ Server delete failed: $e');
        }
      }

      print('✅ Website request deleted locally');
      return true;
    } catch (e) {
      print('⚠️ Error deleting website request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
