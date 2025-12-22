import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Service for checking internet connectivity
class ConnectivityService extends GetxController {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Observable connectivity status
  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscribeToConnectivityChanges();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Failed to get connectivity: $e');
      isConnected.value = false;
    }
  }

  /// Subscribe to connectivity changes
  void _subscribeToConnectivityChanges() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        print('Connectivity stream error: $error');
        isConnected.value = false;
      },
    );
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      isConnected.value = false;
      connectionType.value = ConnectivityResult.none;
      return;
    }

    final result = results.first;
    connectionType.value = result;

    // Consider connected if we have any type of connection
    isConnected.value = result != ConnectivityResult.none;

    print('Connection status changed: ${result.name}');
    print('Is connected: ${isConnected.value}');
  }

  /// Check if device has internet connection
  Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && result.first != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Check if connected via WiFi
  bool get isConnectedViaWiFi => connectionType.value == ConnectivityResult.wifi;

  /// Check if connected via mobile data
  bool get isConnectedViaMobile => connectionType.value == ConnectivityResult.mobile;

  /// Check if connected via ethernet
  bool get isConnectedViaEthernet => connectionType.value == ConnectivityResult.ethernet;

  /// Get connection type as string
  String get connectionTypeString {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  /// Throw exception if no internet connection
  void ensureConnected() {
    if (!isConnected.value) {
      throw Exception('لا يوجد اتصال بالإنترنت. تحقق من اتصالك بالشبكة.');
    }
  }

  /// Wait for connection with timeout
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (isConnected.value) return true;

    final completer = Completer<bool>();
    StreamSubscription? subscription;

    // Set timeout
    final timer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    // Listen for connectivity changes
    subscription = isConnected.listen((connected) {
      if (connected) {
        timer.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    return completer.future;
  }
}
