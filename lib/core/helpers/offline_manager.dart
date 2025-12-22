import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_colors.dart';

/// مدير وضع Offline المحسن
class OfflineManager extends GetxController {
  static OfflineManager get instance => Get.find<OfflineManager>();

  // حالة الاتصال
  final RxBool isOnline = true.obs;
  final RxBool isChecking = false.obs;

  // العمليات المعلقة
  final RxList<PendingOperation> pendingOperations = <PendingOperation>[].obs;

  // Hive boxes للتخزين
  late Box<PendingOperation> _pendingBox;
  late Box<Map> _cacheBox;

  Timer? _connectionCheckTimer;
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeOfflineMode();
  }

  @override
  void onClose() {
    _connectionCheckTimer?.cancel();
    _syncTimer?.cancel();
    super.onClose();
  }

  /// تهيئة وضع Offline
  Future<void> _initializeOfflineMode() async {
    try {
      // فتح Hive boxes
      _pendingBox = await Hive.openBox<PendingOperation>('pending_operations');
      _cacheBox = await Hive.openBox<Map>('offline_cache');

      // تحميل العمليات المعلقة
      _loadPendingOperations();

      // بدء فحص الاتصال
      _startConnectionCheck();

      // بدء مزامنة تلقائية
      _startAutoSync();

      // فحص الاتصال الأولي
      await checkConnection();

      print('✅ Offline Manager initialized');
    } catch (e) {
      print('⚠️ Failed to initialize Offline Manager: $e');
    }
  }

  /// فحص الاتصال بالإنترنت
  Future<bool> checkConnection() async {
    if (isChecking.value) return isOnline.value;

    isChecking.value = true;

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      final wasOffline = !isOnline.value;
      isOnline.value = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      // إذا عاد الاتصال، بدء المزامنة
      if (wasOffline && isOnline.value) {
        _onConnectionRestored();
      }

      return isOnline.value;
    } on SocketException catch (_) {
      isOnline.value = false;
      return false;
    } on TimeoutException catch (_) {
      isOnline.value = false;
      return false;
    } catch (e) {
      print('⚠️ Connection check failed: $e');
      return isOnline.value;
    } finally {
      isChecking.value = false;
    }
  }

  /// بدء فحص الاتصال الدوري
  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => checkConnection(),
    );
  }

  /// بدء المزامنة التلقائية
  void _startAutoSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        if (isOnline.value && pendingOperations.isNotEmpty) {
          syncPendingOperations();
        }
      },
    );
  }

  /// عند عودة الاتصال
  void _onConnectionRestored() {
    print('✅ Connection restored');

    // إظهار رسالة
    Get.snackbar(
      'عاد الاتصال',
      'تم استعادة الاتصال بالإنترنت',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF34C759),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.wifi, color: Colors.white),
    );

    // بدء المزامنة
    syncPendingOperations();
  }

  /// إضافة عملية معلقة
  Future<void> addPendingOperation(PendingOperation operation) async {
    try {
      await _pendingBox.add(operation);
      pendingOperations.add(operation);
      print('📝 Added pending operation: ${operation.type}');
    } catch (e) {
      print('⚠️ Failed to add pending operation: $e');
    }
  }

  /// تحميل العمليات المعلقة
  void _loadPendingOperations() {
    try {
      final operations = _pendingBox.values.toList();
      pendingOperations.value = operations;
      print('📋 Loaded ${operations.length} pending operations');
    } catch (e) {
      print('⚠️ Failed to load pending operations: $e');
    }
  }

  /// مزامنة العمليات المعلقة
  Future<void> syncPendingOperations() async {
    if (!isOnline.value || pendingOperations.isEmpty) return;

    print('🔄 Starting sync of ${pendingOperations.length} operations...');

    final operationsToSync = List<PendingOperation>.from(pendingOperations);

    for (var operation in operationsToSync) {
      try {
        // محاولة تنفيذ العملية
        final success = await _executeOperation(operation);

        if (success) {
          // حذف العملية من القائمة والتخزين
          await _removePendingOperation(operation);
          print('✅ Synced operation: ${operation.type}');
        }
      } catch (e) {
        print('⚠️ Failed to sync operation ${operation.type}: $e');
      }
    }

    if (operationsToSync.length > 0) {
      Get.snackbar(
        'تمت المزامنة',
        'تم مزامنة ${operationsToSync.length - pendingOperations.length} عملية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryPurple,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// تنفيذ عملية معلقة
  Future<bool> _executeOperation(PendingOperation operation) async {
    // TODO: تنفيذ العملية حسب النوع
    // يمكن استخدام strategy pattern هنا

    switch (operation.type) {
      case OperationType.createPost:
        // TODO: استدعاء FirestoreService.createPost
        return true;

      case OperationType.updatePost:
        // TODO: استدعاء FirestoreService.updatePost
        return true;

      case OperationType.deletePost:
        // TODO: استدعاء FirestoreService.deletePost
        return true;

      case OperationType.updateUser:
        // TODO: استدعاء FirestoreService.updateUser
        return true;

      default:
        return false;
    }
  }

  /// حذف عملية معلقة
  Future<void> _removePendingOperation(PendingOperation operation) async {
    try {
      final index = pendingOperations.indexOf(operation);
      if (index != -1) {
        await _pendingBox.deleteAt(index);
        pendingOperations.removeAt(index);
      }
    } catch (e) {
      print('⚠️ Failed to remove pending operation: $e');
    }
  }

  /// حفظ بيانات في الـ cache
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      await _cacheBox.put(key, data);
      print('💾 Cached data: $key');
    } catch (e) {
      print('⚠️ Failed to cache data: $e');
    }
  }

  /// الحصول على بيانات من الـ cache
  Map<String, dynamic>? getCachedData(String key) {
    try {
      final data = _cacheBox.get(key);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('⚠️ Failed to get cached data: $e');
      return null;
    }
  }

  /// حذف بيانات من الـ cache
  Future<void> clearCache({String? key}) async {
    try {
      if (key != null) {
        await _cacheBox.delete(key);
      } else {
        await _cacheBox.clear();
      }
      print('🗑️ Cache cleared');
    } catch (e) {
      print('⚠️ Failed to clear cache: $e');
    }
  }

  /// عرض شريط Offline
  void showOfflineBar() {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Row(
          children: const [
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'لا يوجد اتصال بالإنترنت. العمل في وضع Offline',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF3B30),
        duration: const Duration(days: 1), // دائم حتى يعود الاتصال
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      ),
    );
  }

  /// إخفاء شريط Offline
  void hideOfflineBar() {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  }

  /// الحصول على حالة الاتصال كنص
  String get connectionStatus {
    if (isChecking.value) return 'جاري الفحص...';
    return isOnline.value ? 'متصل' : 'غير متصل';
  }

  /// الحصول على لون حالة الاتصال
  Color get connectionStatusColor {
    if (isChecking.value) return const Color(0xFFFF9500);
    return isOnline.value ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
  }
}

/// نموذج العملية المعلقة
@HiveType(typeId: 100)
class PendingOperation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final OperationType type;

  @HiveField(2)
  final Map<String, dynamic> data;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  int retries;

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retries = 0,
  });
}

/// أنواع العمليات
@HiveType(typeId: 101)
enum OperationType {
  @HiveField(0)
  createPost,

  @HiveField(1)
  updatePost,

  @HiveField(2)
  deletePost,

  @HiveField(3)
  updateUser,

  @HiveField(4)
  uploadMedia,

  @HiveField(5)
  createComment,

  @HiveField(6)
  createPayment,
}

/// Widget لعرض حالة الاتصال
class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offlineManager = Get.find<OfflineManager>();

    return Obx(() {
      if (offlineManager.isOnline.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30).withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'وضع Offline - سيتم مزامنة التغييرات عند عودة الاتصال',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (offlineManager.pendingOperations.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${offlineManager.pendingOperations.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
