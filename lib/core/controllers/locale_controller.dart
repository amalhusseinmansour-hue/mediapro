import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleController extends GetxController {
  static const String _storageKey = 'app_locale';
  final _storage = GetStorage();

  // Default locale is Arabic
  final Rx<Locale> _currentLocale = const Locale('ar', 'AE').obs;

  Locale get currentLocale => _currentLocale.value;

  bool get isArabic => _currentLocale.value.languageCode == 'ar';
  bool get isEnglish => _currentLocale.value.languageCode == 'en';

  // Text direction based on language
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  // Load saved locale from storage
  void _loadSavedLocale() {
    final savedLocale = _storage.read(_storageKey);
    if (savedLocale != null) {
      if (savedLocale == 'ar') {
        _currentLocale.value = const Locale('ar', 'AE');
      } else if (savedLocale == 'en') {
        _currentLocale.value = const Locale('en', 'US');
      }
      Get.updateLocale(_currentLocale.value);
    }
  }

  // Change language
  void changeLocale(String languageCode) {
    if (languageCode == 'ar') {
      _currentLocale.value = const Locale('ar', 'AE');
    } else if (languageCode == 'en') {
      _currentLocale.value = const Locale('en', 'US');
    }

    // Save to storage
    _storage.write(_storageKey, languageCode);

    // Update GetX locale
    Get.updateLocale(_currentLocale.value);
  }

  // Toggle between Arabic and English
  void toggleLanguage() {
    if (isArabic) {
      changeLocale('en');
    } else {
      changeLocale('ar');
    }
  }

  // Get language name
  String get currentLanguageName => isArabic ? 'العربية' : 'English';
  String get otherLanguageName => isArabic ? 'English' : 'العربية';
}
