import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/controllers/theme_controller.dart';
import 'core/controllers/locale_controller.dart';
import 'core/translations/app_translations.dart';

// Core Services Only
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/analytics_service.dart';
import 'services/social_accounts_service.dart';
import 'services/oauth_service.dart';
import 'services/string_style_oauth_service.dart';
import 'services/wallet_service.dart';
import 'services/auto_posting_service.dart';
import 'services/payment_service.dart';
import 'services/social_media_service.dart';
import 'services/shared_preferences_service.dart';
import 'services/http_service.dart';
import 'services/settings_service.dart';
import 'services/advanced_ai_content_service.dart';
import 'services/n8n_workflow_service.dart';
import 'services/google_drive_service.dart';
import 'services/background_telegram_service.dart';
import 'services/app_events_tracker.dart';

// Core Models Only
import 'models/post_model.dart';
import 'models/social_account_model.dart';
import 'models/user_model.dart';
import 'models/user_preferences_model.dart';
import 'models/wallet_model.dart';
import 'models/scheduled_post_model.dart';

import 'screens/splash/epic_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting MediaPro Social - Simplified SaaS Version');

  // Initialize Firebase (optional)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase not configured (local mode)');
  }

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize SharedPreferences
  final sharedPrefsService = SharedPreferencesService();
  await sharedPrefsService.init();
  print('✅ SharedPreferences initialized');

  // Initialize HTTP Service
  final httpService = HttpService();
  await httpService.init();
  Get.put(httpService);
  print('✅ HTTP Service initialized');

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Core Hive Adapters Only
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PostModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PostStatusAdapter());
  if (!Hive.isAdapterRegistered(16)) Hive.registerAdapter(SocialAccountModelAdapter());
  if (!Hive.isAdapterRegistered(17)) Hive.registerAdapter(AccountStatsAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(UserPreferencesModelAdapter());
  if (!Hive.isAdapterRegistered(24)) Hive.registerAdapter(UserModelAdapter());
  if (!Hive.isAdapterRegistered(40)) Hive.registerAdapter(WalletAdapter());
  if (!Hive.isAdapterRegistered(41)) Hive.registerAdapter(WalletTransactionAdapter());
  if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(ScheduledPostAdapter());

  print('✅ Hive adapters registered');

  // Initialize Core Controllers
  Get.put(ThemeController());
  Get.put(LocaleController());

  // Initialize Settings Service (fetch app settings from backend)
  final settingsService = Get.put(SettingsService());
  print('📤 Loading app settings...');
  final settingsLoaded = await settingsService.fetchAppConfig();
  if (settingsLoaded) {
    print('✅ Settings loaded');
    print('   App Name: ${settingsService.appName}');
    print('   Currency: ${settingsService.currency}');
  } else {
    print('⚠️ Using default settings');
  }

  // Initialize Core Services
  Get.put(AuthService());
  Get.put(SubscriptionService());
  Get.put(AnalyticsService());
  Get.put(SocialAccountsService());
  Get.put(OAuthService());
  Get.put(StringStyleOAuthService());

  print('✅ Core services initialized');

  // Initialize Payment & Wallet Services
  await Get.putAsync<PaymentService>(() async => PaymentService().init());
  await Get.putAsync<WalletService>(() async => WalletService().init());
  Get.put(AutoPostingService());

  print('✅ Payment & Wallet services initialized');

  // Initialize Social Media Services
  Get.put(SocialMediaService());
  Get.put(N8nWorkflowService());
  Get.put(GoogleDriveService());

  print('✅ Social media services initialized');

  // Initialize AI Service (Simple Content Generator)
  Get.put(AdvancedAIContentService());
  print('✅ AI content service initialized');

  // Initialize Background Telegram Service
  Get.put(BackgroundTelegramService());
  Get.put(AppEventsTracker());
  print('✅ Telegram bot integration initialized');

  print('🎉 All core services initialized successfully!');
  print('📱 Launching app...');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return Obx(() {
      return GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        // Locale configuration
        locale: localeController.currentLocale,
        fallbackLocale: const Locale('ar', 'AE'),
        translations: AppTranslations(),

        // RTL/LTR support
        builder: (context, child) {
          return Directionality(
            textDirection: localeController.textDirection,
            child: child!,
          );
        },

        home: const EpicSplashScreen(),
      );
    });
  }
}
