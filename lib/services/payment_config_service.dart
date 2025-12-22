import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment_gateway_config_model.dart';
import '../core/error/app_logger.dart';
import 'firestore_service.dart';

/// خدمة إدارة إعدادات الدفع المحلية والسحابية
class PaymentConfigService extends GetxController {
  static const String _configBoxName = 'paymentConfigs';

  Box<Map>? _configBox;
  final AppLogger _logger = AppLogger();
  FirestoreService? _firestoreService;

  // إعدادات Paymob الافتراضية
  final Rx<PaymentGatewayConfigModel?> paymobConfig =
      Rx<PaymentGatewayConfigModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  /// تهيئة الخدمة
  Future<void> _initializeService() async {
    try {
      // فتح صندوق Hive
      _configBox = await Hive.openBox<Map>(_configBoxName);

      // محاولة الحصول على FirestoreService
      try {
        _firestoreService = Get.find<FirestoreService>();
      } catch (e) {
        _logger.warning(
          'FirestoreService not available - using local storage only',
          e,
        );
      }

      // تحميل الإعدادات المحفوظة
      await loadPaymobConfig();

      // إذا لم توجد إعدادات، أنشئ الإعدادات الافتراضية
      if (paymobConfig.value == null) {
        await _createDefaultPaymobConfig();
      }
    } catch (e) {
      _logger.error('Error initializing PaymentConfigService', e);
    }
  }

  /// إنشاء إعدادات Paymob الافتراضية
  Future<void> _createDefaultPaymobConfig() async {
    final now = DateTime.now();
    final defaultConfig = PaymentGatewayConfigModel(
      id: 'paymob',
      name: 'paymob',
      displayName: 'Paymob - MIGS Online Card',
      isEnabled: true, // مفعّل افتراضياً
      isTestMode: false, // وضع Live
      credentials: {
        'apiKey':
            'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFME1qTXNJbTVoYldVaU9pSnBibWwwYVdGc0luMC41WU5fQzd4LU82cjZIM2dqeVUxX095VU9GWmEzM1hramdKc2hUSXRiU1B1QW4wYURBVzh5dU5UeEdXY3UzalphMlItMlVfdXBqTWlFMk1BM2RmS0kxQQ==',
        'integrationId': '81249',
        'iframeId': '81249',
        'hmacSecret': 'BA095DD5F6DADC3FF2D6C9BE9E8CFB8C',
        'secretKey':
            'are_sk_live_9de41b699c84f1cdda78478ac87ce590916495a6f563df9a17692e33fd9023c5',
        'publicKey': 'are_pk_live_SgS4VDIjkSDiJoPPrDx4Q3uQJjKgr37n',
      },
      settings: {
        'accountStatus': 'Live',
        'accountName': 'MIGS-online',
        'integrations': [
          {
            'id': '81249',
            'name': 'MIGS-online',
            'type': 'Online Card',
            'currency': 'AED',
            'status': 'Live',
          },
          {
            'id': '81250',
            'name': 'MIGS-onlineAmex',
            'type': 'Online Card',
            'currency': 'AED',
            'status': 'Live',
          },
        ],
        'mode': 'live',
      },
      supportedCurrencies: ['AED'],
      feePercentage: 2.9,
      fixedFee: 0.0,
      priority: 1,
      createdAt: now,
      updatedAt: now,
    );

    await savePaymobConfig(defaultConfig);
    _logger.info('Live Paymob config created with MIGS integrations');
  }

  /// تحميل إعدادات Paymob
  Future<void> loadPaymobConfig() async {
    try {
      isLoading.value = true;

      // أولاً: محاولة التحميل من Firestore إذا كان متاحاً
      if (_firestoreService != null) {
        try {
          final config = await _firestoreService!.getPaymentGatewayConfig(
            'paymob',
          );
          if (config != null) {
            paymobConfig.value = config;
            // حفظ نسخة محلية
            await _saveToHive(config);
            _logger.info('Paymob config loaded from Firestore');
            return;
          }
        } catch (e) {
          _logger.warning('Could not load from Firestore', e);
        }
      }

      // ثانياً: التحميل من Hive
      if (_configBox != null && _configBox!.containsKey('paymob')) {
        final rawData = _configBox!.get('paymob');
        if (rawData != null) {
          // تحويل آمن من Map<dynamic, dynamic> إلى Map<String, dynamic>
          final data = Map<String, dynamic>.from(rawData);
          paymobConfig.value = _configFromMap(data);
          _logger.info('Paymob config loaded from Hive');
        }
      }
    } catch (e) {
      _logger.error('Error loading Paymob config', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// حفظ إعدادات Paymob
  Future<bool> savePaymobConfig(PaymentGatewayConfigModel config) async {
    try {
      isLoading.value = true;

      // 1. حفظ محلياً في Hive
      await _saveToHive(config);
      paymobConfig.value = config;
      _logger.info('Paymob config saved to Hive');

      // 2. حفظ في Firestore إذا كان متاحاً
      if (_firestoreService != null) {
        final success = await _firestoreService!.savePaymentGatewayConfig(
          config,
        );
        if (success) {
          _logger.info('Paymob config saved to Firestore');
        } else {
          _logger.warning('Could not save to Firestore');
        }
      }

      return true;
    } catch (e) {
      _logger.error('Error saving Paymob config', e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// حفظ في Hive
  Future<void> _saveToHive(PaymentGatewayConfigModel config) async {
    if (_configBox == null) {
      _logger.warning('Config box not initialized');
      return;
    }

    final data = {
      'id': config.id,
      'name': config.name,
      'displayName': config.displayName,
      'isEnabled': config.isEnabled,
      'isTestMode': config.isTestMode,
      'credentials': config.credentials,
      'settings': config.settings,
      'supportedCurrencies': config.supportedCurrencies,
      'feePercentage': config.feePercentage,
      'fixedFee': config.fixedFee,
      'priority': config.priority,
      'createdAt': config.createdAt.toIso8601String(),
      'updatedAt': config.updatedAt.toIso8601String(),
    };

    await _configBox!.put('paymob', data);
  }

  /// تحويل من Map إلى Model
  PaymentGatewayConfigModel _configFromMap(Map<String, dynamic> data) {
    return PaymentGatewayConfigModel(
      id: data['id'] ?? 'paymob',
      name: data['name'] ?? 'paymob',
      displayName: data['displayName'] ?? 'Paymob',
      isEnabled: data['isEnabled'] ?? true,
      isTestMode: data['isTestMode'] ?? false,
      credentials: Map<String, String>.from(data['credentials'] ?? {}),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      supportedCurrencies: List<String>.from(
        data['supportedCurrencies'] ?? ['AED'],
      ),
      feePercentage: data['feePercentage']?.toDouble(),
      fixedFee: data['fixedFee']?.toDouble(),
      priority: data['priority'] ?? 1,
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        data['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// تحديث مفاتيح API فقط
  Future<bool> updatePaymobCredentials({
    String? apiKey,
    String? integrationId,
    String? iframeId,
    String? hmacSecret,
    String? secretKey,
  }) async {
    if (paymobConfig.value == null) {
      await _createDefaultPaymobConfig();
    }

    final currentConfig = paymobConfig.value!;
    final newCredentials = Map<String, String>.from(currentConfig.credentials);

    if (apiKey != null) newCredentials['apiKey'] = apiKey;
    if (integrationId != null) newCredentials['integrationId'] = integrationId;
    if (iframeId != null) newCredentials['iframeId'] = iframeId;
    if (hmacSecret != null) newCredentials['hmacSecret'] = hmacSecret;
    if (secretKey != null) newCredentials['secretKey'] = secretKey;

    final updatedConfig = currentConfig.copyWith(
      credentials: newCredentials,
      updatedAt: DateTime.now(),
    );

    return await savePaymobConfig(updatedConfig);
  }

  /// تفعيل/تعطيل بوابة الدفع
  Future<bool> togglePaymobStatus(bool isEnabled) async {
    if (paymobConfig.value == null) return false;

    final updatedConfig = paymobConfig.value!.copyWith(
      isEnabled: isEnabled,
      updatedAt: DateTime.now(),
    );

    return await savePaymobConfig(updatedConfig);
  }

  /// التبديل بين وضع الاختبار والإنتاج
  Future<bool> toggleTestMode(bool isTestMode) async {
    if (paymobConfig.value == null) return false;

    final updatedConfig = paymobConfig.value!.copyWith(
      isTestMode: isTestMode,
      updatedAt: DateTime.now(),
    );

    return await savePaymobConfig(updatedConfig);
  }

  /// الحصول على مفتاح API
  String? get apiKey => paymobConfig.value?.credentials['apiKey'];

  /// الحصول على Integration ID
  String? get integrationId => paymobConfig.value?.credentials['integrationId'];

  /// الحصول على Iframe ID
  String? get iframeId => paymobConfig.value?.credentials['iframeId'];

  /// الحصول على HMAC Secret
  String? get hmacSecret => paymobConfig.value?.credentials['hmacSecret'];

  /// الحصول على Secret Key
  String? get secretKey => paymobConfig.value?.credentials['secretKey'];

  /// التحقق من صحة الإعدادات
  bool get isConfigValid => paymobConfig.value?.isValid ?? false;

  /// التحقق من تفعيل البوابة
  bool get isEnabled => paymobConfig.value?.isEnabled ?? false;

  /// هل في وضع الاختبار؟
  bool get isTestMode => paymobConfig.value?.isTestMode ?? false;
}
