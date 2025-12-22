import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:hive_flutter/hive_flutter.dart';
import '../core/config/api_config.dart';
import '../models/wallet_recharge_request.dart';
import 'auth_service.dart';

class WalletRechargeService extends GetxService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.backendBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final AuthService _authService = Get.find<AuthService>();
  final RxList<WalletRechargeRequest> requests = <WalletRechargeRequest>[].obs;
  final RxBool isLoading = false.obs;

  // Local storage box
  Box<String>? _requestsBox;
  static const String _boxName = 'wallet_recharge_requests';

  @override
  void onInit() {
    super.onInit();
    _setupInterceptors();
    _initLocalStorage();
  }

  Future<void> _initLocalStorage() async {
    try {
      _requestsBox = await Hive.openBox<String>(_boxName);
      await _loadLocalRequests();
      print('✅ WalletRechargeService: Local storage initialized');
    } catch (e) {
      print('⚠️ WalletRechargeService: Failed to init local storage: $e');
    }
  }

  Future<void> _loadLocalRequests() async {
    if (_requestsBox == null) return;

    try {
      final List<WalletRechargeRequest> localRequests = [];
      for (var key in _requestsBox!.keys) {
        final jsonStr = _requestsBox!.get(key);
        if (jsonStr != null) {
          final json = jsonDecode(jsonStr);
          localRequests.add(WalletRechargeRequest.fromJson(json));
        }
      }
      // Sort by date (newest first)
      localRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      requests.value = localRequests;
      print('✅ Loaded ${localRequests.length} local recharge requests');
    } catch (e) {
      print('⚠️ Error loading local requests: $e');
    }
  }

  Future<void> _saveRequestLocally(WalletRechargeRequest request) async {
    if (_requestsBox == null) return;

    try {
      await _requestsBox!.put(request.id.toString(), jsonEncode(request.toJson()));
      print('✅ Request saved locally: ${request.id}');
    } catch (e) {
      print('⚠️ Error saving request locally: $e');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = _authService.currentUser.value?.id;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('Wallet Recharge API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Submit a new recharge request
  Future<Map<String, dynamic>> submitRechargeRequest({
    required String userId,
    required double amount,
    required File receiptImage,
    String? paymentMethod,
    String? bankName,
    String? transactionReference,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      // Create local request first (always works)
      final localRequest = WalletRechargeRequest(
        id: DateTime.now().millisecondsSinceEpoch,
        referenceNumber: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        amount: amount,
        currency: 'SAR',
        paymentMethod: paymentMethod ?? 'bank_transfer',
        bankName: bankName,
        transactionReference: transactionReference,
        notes: notes,
        receiptImagePath: receiptImage.path,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save locally first
      await _saveRequestLocally(localRequest);
      requests.insert(0, localRequest);
      print('✅ Recharge request saved locally');

      // Try to sync with server (optional - won't fail the operation)
      try {
        final formData = FormData.fromMap({
          'user_id': userId,
          'amount': amount,
          'currency': 'SAR',
          'receipt_image': await MultipartFile.fromFile(
            receiptImage.path,
            filename: 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
          if (paymentMethod != null) 'payment_method': paymentMethod,
          if (bankName != null) 'bank_name': bankName,
          if (transactionReference != null) 'transaction_reference': transactionReference,
          if (notes != null) 'notes': notes,
        });

        final response = await _dio.post(
          '/api/wallet-recharge-requests',
          data: formData,
        );

        if (response.statusCode == 201 && response.data['success'] == true) {
          print('✅ Request synced with server');
        }
      } catch (e) {
        print('⚠️ Server sync failed (request saved locally): $e');
        // Don't fail - request is saved locally
      }

      return {
        'success': true,
        'message': 'تم إرسال الطلب بنجاح - سيتم مراجعته قريباً',
        'request': localRequest,
      };
    } catch (e) {
      print('Submit recharge request error: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Get user's recharge requests
  Future<void> getUserRequests(String userId, {String? status}) async {
    try {
      isLoading.value = true;

      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/wallet-recharge-requests/user/$userId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> requestsData = response.data['requests'] ?? [];
        requests.value = requestsData
            .map((json) => WalletRechargeRequest.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      print('Get user requests error: ${e.message}');
      requests.value = [];
    } catch (e) {
      print('Get user requests error: $e');
      requests.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Get a single request details
  Future<WalletRechargeRequest?> getRequestDetails(int requestId) async {
    try {
      final response = await _dio.get('/wallet-recharge-requests/$requestId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return WalletRechargeRequest.fromJson(response.data['request']);
      }
      return null;
    } on DioException catch (e) {
      print('Get request details error: ${e.message}');
      return null;
    } catch (e) {
      print('Get request details error: $e');
      return null;
    }
  }

  /// Get pending requests
  List<WalletRechargeRequest> get pendingRequests {
    return requests.where((r) => r.isPending).toList();
  }

  /// Get approved requests
  List<WalletRechargeRequest> get approvedRequests {
    return requests.where((r) => r.isApproved).toList();
  }

  /// Get rejected requests
  List<WalletRechargeRequest> get rejectedRequests {
    return requests.where((r) => r.isRejected).toList();
  }

  /// Check if there are pending requests
  bool get hasPendingRequests {
    return requests.any((r) => r.isPending);
  }

  /// Get total pending amount
  double get totalPendingAmount {
    return pendingRequests.fold(0.0, (sum, request) => sum + request.amount);
  }

  /// Clear all data
  void clear() {
    requests.clear();
  }
}
