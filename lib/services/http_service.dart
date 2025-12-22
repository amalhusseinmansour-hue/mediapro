import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/backend_config.dart';
import '../core/services/connectivity_service.dart';
import 'shared_preferences_service.dart';

/// HTTP Service for making API requests to Laravel backend
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  String? _authToken;
  bool _isInitialized = false;

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const double retryDelayMultiplier = 2.0;

  /// Initialize HTTP service and load auth token from SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final savedToken = await _prefsService.getAuthToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        _authToken = savedToken;
        print('✅ Auth token loaded from SharedPreferences: ${savedToken.substring(0, 20)}...');
      } else {
        print('⚠️ No auth token found in SharedPreferences');
      }
      _isInitialized = true;
    } catch (e) {
      print('❌ Error loading auth token: $e');
    }
  }

  /// Set authentication token (and save to SharedPreferences)
  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    if (token != null && token.isNotEmpty) {
      await _prefsService.saveAuthToken(token);
      print('✅ Auth token saved: ${token.substring(0, 20)}...');
    }
  }

  /// Get authentication token
  String? get authToken => _authToken;

  /// Get headers with authentication token
  Map<String, String> get authHeaders => _getHeaders(null);

  /// Clear authentication token (from memory and SharedPreferences)
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _prefsService.clearAuthToken();
    print('✅ Auth token cleared');
  }

  // ========== GET Request ==========

  /// Make GET request with retry logic
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    await init(); // Ensure token is loaded
    return await _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _getHeaders(headers);

      print('GET Request: $uri');

      final response = await http.get(
        uri,
        headers: requestHeaders,
      ).timeout(BackendConfig.receiveTimeout);

      return _handleResponse(response);
    });
  }

  // ========== POST Request ==========

  /// Make POST request with retry logic
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    await init(); // Ensure token is loaded
    return await _executeWithRetry(() async {
      final uri = _buildUri(endpoint);
      final requestHeaders = _getHeaders(headers);

      print('POST Request: $uri');
      print('POST Body: ${jsonEncode(body)}');

      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: jsonEncode(body),
      ).timeout(BackendConfig.sendTimeout);

      return _handleResponse(response);
    });
  }

  // ========== PUT Request ==========

  /// Make PUT request with retry logic
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    await init(); // Ensure token is loaded
    return await _executeWithRetry(() async {
      final uri = _buildUri(endpoint);
      final requestHeaders = _getHeaders(headers);

      print('PUT Request: $uri');
      print('PUT Auth Token: ${_authToken != null ? "${_authToken!.substring(0, 20)}..." : "NULL"}');
      print('PUT Headers: $requestHeaders');
      print('PUT Body: ${jsonEncode(body)}');

      final response = await http.put(
        uri,
        headers: requestHeaders,
        body: jsonEncode(body),
      ).timeout(BackendConfig.sendTimeout);

      return _handleResponse(response);
    });
  }

  // ========== DELETE Request ==========

  /// Make DELETE request with retry logic
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    await init(); // Ensure token is loaded
    return await _executeWithRetry(() async {
      final uri = _buildUri(endpoint);
      final requestHeaders = _getHeaders(headers);

      print('DELETE Request: $uri');

      final response = await http.delete(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(BackendConfig.sendTimeout);

      return _handleResponse(response);
    });
  }

  // ========== Multipart Request (for file uploads) ==========

  /// Make multipart request for file uploads with retry logic
  Future<Map<String, dynamic>> multipart(
    String endpoint, {
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
    String method = 'POST',
  }) async {
    await init(); // Ensure token is loaded
    return await _executeWithRetry(() async {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest(method, uri);

      // Add headers
      request.headers.addAll(
        BackendConfig.getMultipartHeaders(token: _authToken),
      );

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        request.files.addAll(files);
      }

      print('Multipart Request: $uri');
      print('Fields: $fields');
      print('Files: ${files?.length ?? 0}');

      final streamedResponse = await request.send().timeout(
        BackendConfig.sendTimeout,
      );

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    });
  }

  // ========== Helper Methods ==========

  /// Execute request with retry logic and exponential backoff
  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation, {
    bool checkConnectivity = false, // Disabled: connectivity_plus gives false negatives
  }) async {
    // Check connectivity first if required
    if (checkConnectivity) {
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        throw Exception('لا يوجد اتصال بالإنترنت. تحقق من اتصالك بالشبكة.');
      }
    }

    int attempt = 0;
    Duration delay = initialRetryDelay;

    while (true) {
      try {
        return await operation();
      } on SocketException catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          print('Max retries reached. Last error: $e');
          throw Exception(BackendConfig.networkErrorMessage);
        }

        print('Network error on attempt $attempt. Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
        delay *= retryDelayMultiplier;
      } on TimeoutException catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          print('Max retries reached. Request timeout: $e');
          throw Exception('انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.');
        }

        print('Timeout on attempt $attempt. Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
        delay *= retryDelayMultiplier;
      } on HandshakeException catch (e) {
        // SSL/TLS handshake error - usually a certificate issue
        print('SSL/TLS Handshake error: $e');
        throw Exception(
          'فشل الاتصال الآمن بالخادم. قد تكون هناك مشكلة في الشهادة الأمنية.',
        );
      } on HttpException catch (e) {
        // HTTP exception - don't retry for client errors (4xx)
        if (e.statusCode >= 400 && e.statusCode < 500) {
          rethrow; // Client errors shouldn't be retried
        }

        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }

        print('HTTP error ${e.statusCode} on attempt $attempt. Retrying...');
        await Future.delayed(delay);
        delay *= retryDelayMultiplier;
      }
    }
  }

  /// Build URI with base URL and query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final url = BackendConfig.buildUrl(endpoint);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return Uri.parse('$url?$queryString');
    }

    return Uri.parse(url);
  }

  /// Get headers with authentication token
  Map<String, String> _getHeaders(Map<String, String>? additionalHeaders) {
    final headers = BackendConfig.getHeaders(token: _authToken);

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final statusCode = response.statusCode;

    // Parse response body
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      body = {'message': response.body};
    }

    // Handle success responses
    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    // Handle error responses
    final errorMessage = body['message'] ??
        body['error'] ??
        BackendConfig.getErrorMessage(statusCode);

    throw HttpException(
      errorMessage,
      statusCode: statusCode,
      response: body,
    );
  }
}

/// Custom HTTP Exception
class HttpException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? response;

  HttpException(
    this.message, {
    required this.statusCode,
    this.response,
  });

  @override
  String toString() => message;

  /// Check if error is unauthorized (401)
  bool get isUnauthorized => statusCode == BackendConfig.statusUnauthorized;

  /// Check if error is validation error (422)
  bool get isValidationError => statusCode == BackendConfig.statusValidationError;

  /// Get validation errors if available
  Map<String, List<String>>? get validationErrors {
    if (response != null && response!.containsKey('errors')) {
      final errors = response!['errors'] as Map<String, dynamic>;
      return errors.map(
        (key, value) => MapEntry(
          key,
          (value as List).cast<String>(),
        ),
      );
    }
    return null;
  }
}
