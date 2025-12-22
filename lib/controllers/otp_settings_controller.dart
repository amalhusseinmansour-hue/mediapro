import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/otp_config_model.dart';

/// كونترولر إعدادات OTP
class OTPSettingsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isTesting = false.obs;
  final RxString selectedTab = 'general'.obs; // general, providers, test

  // OTP Configuration
  final Rx<OTPConfigModel?> otpConfig = Rx<OTPConfigModel?>(null);

  // OTP Settings
  final RxString defaultProvider = 'firebase'.obs;
  final RxInt otpLength = 6.obs;
  final RxInt expiryMinutes = 5.obs;
  final RxInt maxRetries = 3.obs;
  final RxBool isTestMode = true.obs;

  // Providers
  final RxMap<String, OTPProviderConfig> providers =
      <String, OTPProviderConfig>{}.obs;

  // Test OTP
  final RxString testPhoneNumber = '+971'.obs;
  final RxString testOTPCode = ''.obs;

  // Stream subscription
  StreamSubscription? _configSubscription;

  @override
  void onInit() {
    super.onInit();
    loadConfiguration();
    startListening();
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  /// تحميل التكوين
  Future<void> loadConfiguration() async {
    try {
      isLoading.value = true;

      final config = await _firestoreService.getOTPConfig();

      if (config != null) {
        otpConfig.value = config;
        _updateStateFromConfig(config);
      }
    } catch (e) {
      print('خطأ في تحميل التكوين: $e');
      Get.snackbar(
        'خطأ',
        'فشل تحميل إعدادات OTP: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث الحالة من التكوين
  void _updateStateFromConfig(OTPConfigModel config) {
    defaultProvider.value = config.defaultProvider;
    otpLength.value = config.otpLength;
    expiryMinutes.value = config.expiryMinutes;
    maxRetries.value = config.maxRetries;
    isTestMode.value = config.isTestMode;
    providers.value = config.providers;
  }

  /// بدء الاستماع للتحديثات
  void startListening() {
    _configSubscription = _firestoreService.listenToOTPConfig().listen((
      config,
    ) {
      if (config != null) {
        otpConfig.value = config;
        _updateStateFromConfig(config);
      }
    });
  }

  /// إيقاف الاستماع
  void stopListening() {
    _configSubscription?.cancel();
  }

  /// حفظ الإعدادات العامة
  Future<bool> saveGeneralSettings() async {
    try {
      isSaving.value = true;

      final success = await _firestoreService.updateOTPSettings(
        otpLength: otpLength.value,
        expiryMinutes: expiryMinutes.value,
        maxRetries: maxRetries.value,
        isTestMode: isTestMode.value,
      );

      if (success) {
        Get.snackbar(
          'نجح',
          'تم حفظ الإعدادات بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حفظ الإعدادات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      print('خطأ في حفظ الإعدادات: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الحفظ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// تحديث المزود الافتراضي
  Future<bool> updateDefaultProvider(String providerName) async {
    try {
      isSaving.value = true;

      final success = await _firestoreService.updateDefaultOTPProvider(
        providerName,
      );

      if (success) {
        defaultProvider.value = providerName;
        Get.snackbar(
          'نجح',
          'تم تعيين $providerName كمزود افتراضي',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      print('خطأ في تحديث المزود الافتراضي: $e');
      Get.snackbar(
        'خطأ',
        'فشل تحديث المزود الافتراضي: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// حفظ إعدادات المزود
  Future<bool> saveProviderConfig(OTPProviderConfig config) async {
    try {
      isSaving.value = true;

      final success = await _firestoreService.updateOTPProviderConfig(
        providerName: config.name,
        providerConfig: config,
      );

      if (success) {
        providers[config.name] = config;
        Get.snackbar(
          'نجح',
          'تم حفظ إعدادات ${config.displayName} بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حفظ إعدادات المزود',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      print('خطأ في حفظ إعدادات المزود: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الحفظ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// تفعيل/تعطيل المزود
  Future<void> toggleProvider(String providerName, bool isEnabled) async {
    final provider = providers[providerName];
    if (provider == null) return;

    final updatedProvider = provider.copyWith(isEnabled: isEnabled);
    await saveProviderConfig(updatedProvider);
  }

  /// اختبار إرسال OTP
  Future<void> testSendOTP() async {
    try {
      if (testPhoneNumber.value.length < 10) {
        Get.snackbar(
          'خطأ',
          'الرجاء إدخال رقم هاتف صحيح',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isTesting.value = true;

      Get.snackbar(
        'إرسال',
        'جاري إرسال رمز OTP...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // محاكاة إرسال OTP
      // في التطبيق الحقيقي، ستستدعي الخدمة المناسبة
      await Future.delayed(const Duration(seconds: 2));

      // توليد OTP عشوائي للاختبار
      final random = DateTime.now().millisecondsSinceEpoch % 1000000;
      testOTPCode.value = random.toString().padLeft(otpLength.value, '0');

      Get.snackbar(
        'نجح',
        'تم إرسال رمز OTP بنجاح!\nالرمز: ${testOTPCode.value} (وضع الاختبار)',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );

      print('📱 Test OTP Code: ${testOTPCode.value}');
    } catch (e) {
      print('خطأ في اختبار OTP: $e');
      Get.snackbar(
        'فشل',
        'حدث خطأ أثناء الإرسال: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isTesting.value = false;
    }
  }

  /// إعادة تعيين التكوين للقيم الافتراضية
  Future<void> resetToDefault() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('إعادة تعيين'),
          content: const Text(
            'هل أنت متأكد من إعادة تعيين جميع الإعدادات للقيم الافتراضية؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('نعم'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;

      final success = await _firestoreService.resetOTPConfigToDefault();

      if (success) {
        Get.snackbar(
          'نجح',
          'تم إعادة تعيين الإعدادات بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadConfiguration();
      }
    } catch (e) {
      print('خطأ في إعادة التعيين: $e');
      Get.snackbar(
        'خطأ',
        'فشل إعادة التعيين: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير التبويب
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  /// تحديث البيانات
  @override
  Future<void> refresh() async {
    await loadConfiguration();
  }

  /// الحصول على المزودين المفعلين
  List<OTPProviderConfig> get enabledProviders {
    return providers.values.where((p) => p.isEnabled).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// الحصول على المزودين غير المفعلين
  List<OTPProviderConfig> get disabledProviders {
    return providers.values.where((p) => !p.isEnabled).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// التحقق من صحة التكوين
  bool get isConfigValid {
    final defaultProv = providers[defaultProvider.value];
    return defaultProv != null && defaultProv.isValid && defaultProv.isEnabled;
  }

  /// الحصول على اسم المزود بالعربية
  String getProviderNameAr(String provider) {
    switch (provider.toLowerCase()) {
      case 'firebase':
        return 'فايربيز';
      case 'twilio':
        return 'توليو';
      case 'nexmo':
      case 'vonage':
        return 'نيكسمو (فونج)';
      case 'aws_sns':
        return 'أمازون SNS';
      case 'messagebird':
        return 'ميسج بيرد';
      default:
        return provider;
    }
  }
}
