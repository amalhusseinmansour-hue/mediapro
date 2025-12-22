import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
// flutter_dotenv removed - API keys now fetched from backend for security
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/env_config.dart';
import 'core/controllers/theme_controller.dart';
import 'core/controllers/locale_controller.dart';
import 'core/translations/app_translations.dart';
import 'services/notification_service.dart';
// import 'services/gamification_service.dart'; // ❌ Removed - Not core feature
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/analytics_service.dart';
import 'services/firestore_service.dart';
import 'services/laravel_api_service.dart';
// import 'services/phone_auth_service.dart'; // ❌ OTP Removed
import 'services/support_service.dart';
import 'services/sponsored_ads_service.dart';
import 'services/social_accounts_service.dart';
import 'services/oauth_service.dart';
import 'services/string_style_oauth_service.dart';
import 'services/sms_service.dart';
import 'services/payment_config_service.dart';
import 'services/wallet_service.dart';
import 'services/wallet_recharge_service.dart';
import 'services/auto_posting_service.dart';
import 'services/payment_service.dart';
import 'services/n8n_service.dart';
import 'services/multi_platform_post_service.dart';
// import 'services/otp_service.dart'; // ❌ OTP Removed
import 'services/upload_post_service.dart';
import 'services/direct_social_media_service.dart';
import 'services/facebook_graph_api_service.dart';
import 'services/universal_social_media_service.dart';
import 'services/advanced_ai_content_service.dart';
import 'services/n8n_social_posting_service.dart';
import 'services/social_media_service.dart';
import 'services/shared_preferences_service.dart';
import 'services/http_service.dart';
import 'services/api_service.dart';
import 'services/apify_service.dart';
import 'services/settings_service.dart';
// import 'services/laravel_community_service.dart'; // ❌ Removed - Not core feature
import 'services/n8n_workflow_service.dart';
import 'services/google_drive_service.dart';
import 'services/ai_image_edit_service.dart';
import 'services/background_telegram_service.dart';
import 'services/app_events_tracker.dart';
import 'services/youtube_service.dart';
import 'services/google_apple_pay_service.dart';
import 'services/ai_media_service.dart';
import 'services/ai_scheduling_service.dart';
import 'services/brand_kit_service.dart';
import 'services/cloudinary_service.dart';
import 'services/gemini_service.dart';
import 'services/claude_service.dart';
import 'services/social_media_share_service.dart';
import 'services/openai_service.dart';
import 'services/stable_diffusion_service.dart';
import 'services/runway_service.dart';
import 'services/unified_ai_manager.dart';
import 'services/groq_service.dart';
import 'models/notification_model.dart';
import 'models/brand_kit_model.dart';
// import 'models/gamification_model.dart'; // ❌ Removed - Not core feature
import 'models/post_model.dart';
import 'models/social_account_model.dart';
import 'models/user_model.dart';
import 'models/user_preferences_model.dart';
import 'models/support_ticket_model.dart';
import 'models/sponsored_ad_model.dart';
import 'models/sms_model.dart';
import 'models/login_history_model.dart';
import 'models/wallet_model.dart';
import 'models/scheduled_post_model.dart';
import 'models/analytics_history_model.dart';
import 'screens/splash/epic_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Environment Configuration (API keys fetched from backend for security)
  print('✅ Environment configured - API keys fetched from backend securely');
  EnvConfig.printStatus();

  // Initialize Firebase with platform-specific options
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    print('✅ Firebase initialized successfully');
    print('✅ Firebase Analytics enabled');
  } catch (e) {
    print('⚠️ Firebase not configured yet. App will use local storage only.');
    print('   Error: $e');
    print('   To enable cloud sync, configure Firebase in lib/firebase_options.dart');
  }

  // Initialize GetStorage for locale persistence
  await GetStorage.init();

  // Initialize date formatting for Arabic locale
  await initializeDateFormatting('ar', null);
  print('✅ Arabic date formatting initialized');

  // Initialize SharedPreferences
  final sharedPrefsService = SharedPreferencesService();
  await sharedPrefsService.init();
  print('✅ SharedPreferences initialized');

  // Initialize HTTP Service (loads auth token from SharedPreferences)
  final httpService = HttpService();
  await httpService.init();
  Get.put(httpService); // Register in GetX
  print('✅ HTTP Service initialized');

  // Initialize API Service (wraps HttpService with API methods)
  Get.put(ApiService());
  print('✅ API Service initialized');

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
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

  // Register Hive adapters (check if not already registered)
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(NotificationModelAdapter()); // typeId: 1
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(NotificationTypeAdapter()); // typeId: 2
  // Hive.registerAdapter(UserLevelAdapter()); // ❌ Gamification removed
  // Hive.registerAdapter(AchievementRarityAdapter()); // ❌ Gamification removed
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(PostModelAdapter()); // typeId: 6
  if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(PostStatusAdapter()); // typeId: 7
  if (!Hive.isAdapterRegistered(16)) Hive.registerAdapter(SocialAccountModelAdapter()); // typeId: 16
  if (!Hive.isAdapterRegistered(17)) Hive.registerAdapter(AccountStatsAdapter()); // typeId: 17
  if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(UserPreferencesModelAdapter()); // typeId: 10
  if (!Hive.isAdapterRegistered(60)) Hive.registerAdapter(SupportTicketModelAdapter()); // typeId: 60
  // Note: TicketStatus, TicketPriority, TicketCategory adapters removed due to conflict with PostStatus (typeId 7)
  // These enums will be stored as integers automatically by Hive
  if (!Hive.isAdapterRegistered(70)) Hive.registerAdapter(AdStatusAdapter()); // typeId: 70 (fixed conflict)
  if (!Hive.isAdapterRegistered(71)) Hive.registerAdapter(AdTypeAdapter()); // typeId: 71
  if (!Hive.isAdapterRegistered(72)) Hive.registerAdapter(AdPlatformAdapter()); // typeId: 72
  if (!Hive.isAdapterRegistered(73)) Hive.registerAdapter(AdObjectiveAdapter()); // typeId: 73
  if (!Hive.isAdapterRegistered(74)) Hive.registerAdapter(TargetAudienceAdapter()); // typeId: 74
  if (!Hive.isAdapterRegistered(75)) Hive.registerAdapter(SponsoredAdModelAdapter()); // typeId: 75
  if (!Hive.isAdapterRegistered(20)) Hive.registerAdapter(SmsStatusAdapter()); // typeId: 20
  if (!Hive.isAdapterRegistered(21)) Hive.registerAdapter(SmsPurposeAdapter()); // typeId: 21
  if (!Hive.isAdapterRegistered(22)) Hive.registerAdapter(SmsMessageAdapter()); // typeId: 22
  if (!Hive.isAdapterRegistered(23)) Hive.registerAdapter(SmsSettingsAdapter()); // typeId: 23
  if (!Hive.isAdapterRegistered(24)) Hive.registerAdapter(UserModelAdapter()); // typeId: 24
  if (!Hive.isAdapterRegistered(30)) Hive.registerAdapter(LoginHistoryModelAdapter()); // typeId: 30
  if (!Hive.isAdapterRegistered(40)) Hive.registerAdapter(WalletAdapter()); // typeId: 40
  if (!Hive.isAdapterRegistered(41)) Hive.registerAdapter(WalletTransactionAdapter()); // typeId: 41
  if (!Hive.isAdapterRegistered(50)) Hive.registerAdapter(ScheduledPostAdapter()); // typeId: 50
  if (!Hive.isAdapterRegistered(80)) Hive.registerAdapter(BrandKitAdapter()); // typeId: 80
  if (!Hive.isAdapterRegistered(90)) Hive.registerAdapter(AnalyticsHistoryModelAdapter()); // typeId: 90

  // Initialize GetX controllers
  Get.put(ThemeController());
  Get.put(LocaleController()); // Initialize locale controller
  Get.put(NotificationService());
  // Get.put(GamificationService()); // ❌ Removed - Not core feature

  // Initialize FirestoreService (will work in local-only mode without Firebase)
  Get.put(FirestoreService());

  // Initialize Laravel API Service (for backend communication)
  Get.put(LaravelApiService());

  // Initialize Settings Service (fetch app settings from backend)
  final settingsService = Get.put(SettingsService());
  print('📤 Loading app settings from backend...');

  // Load settings in background (non-blocking) with timeout
  settingsService.fetchAppConfig().timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      print('⚠️ Settings fetch timeout (5s), continuing with defaults');
      return false;
    },
  ).then((settingsLoaded) {
    if (settingsLoaded) {
      print('✅ App settings loaded successfully');
      print('   App Name: ${settingsService.appName}');
      print('   Currency: ${settingsService.currency}');
      print('   AI Enabled: ${settingsService.aiEnabled}');
      print('   Payment Enabled: ${settingsService.paymentEnabled}');
      print('   Google Pay: ${settingsService.googlePayEnabled}');
      print('   Apple Pay: ${settingsService.applePayEnabled}');
    } else {
      print('⚠️ Failed to load settings from backend, using defaults');
    }
  }).catchError((e) {
    print('⚠️ Error loading settings: $e, using defaults');
  });

  // Initialize Google Pay & Apple Pay Service
  Get.put(GoogleApplePayService());
  print('✅ Google Pay & Apple Pay Service initialized');

  // Initialize Laravel Community Service (for community posts)
  // Get.put(LaravelCommunityService()); // ❌ Removed - Not core feature
  // print('✅ Laravel Community Service initialized');

  // ❌ OTP Removed - PhoneAuthService not needed
  // if (firebaseInitialized) {
  //   Get.put(PhoneAuthService());
  // }

  // Initialize Auth and Subscription services
  Get.put(AuthService());
  Get.put(SubscriptionService());
  Get.put(AnalyticsService());
  Get.put(SupportService());
  Get.put(SponsoredAdsService());
  Get.put(SocialAccountsService());
  Get.put(OAuthService()); // OAuth service for social media auto-login
  Get.put(StringStyleOAuthService()); // String-style OAuth service for direct platform linking
  Get.put(SmsService());
  Get.put(PaymentConfigService()); // Payment configuration service

  // Initialize PaymentService first, then WalletService (WalletService depends on PaymentService)
  await Get.putAsync<PaymentService>(() async => PaymentService().init());
  await Get.putAsync<WalletService>(() async => WalletService().init());
  Get.put(WalletRechargeService()); // Wallet recharge requests service
  Get.put(AutoPostingService()); // Auto-posting automation service

  // Initialize N8N Service for automation
  final storage = GetStorage();
  await Get.putAsync<N8nService>(() async {
    final service = N8nService();
    return await service.init(
      n8nUrl: storage.read('n8n_url'),
      apiKey: storage.read('n8n_api_key'),
    );
  });

  // ❌ OTP Removed
  // Get.put(OTPService());

  // Initialize Multi-Platform Post Service (يستخدم Backend API للنشر)
  Get.put(MultiPlatformPostService());

  // Initialize Upload-Post Service (للنشر عبر upload-post.com)
  Get.put(UploadPostService());

  // Initialize Direct Social Media Service (فتح تطبيقات السوشال ميديا مباشرة)
  Get.put(DirectSocialMediaService());

  // Initialize Facebook Graph API Service (نشر حقيقي على Facebook & Instagram)
  try {
    Get.put(FacebookGraphApiService());
    print('✅ FacebookGraphApiService initialized');
  } catch (e) {
    print('⚠️ FacebookGraphApiService skipped (not configured yet)');
  }

  // Initialize Universal Social Media Service (نشر على جميع المنصات)
  Get.put(UniversalSocialMediaService());

  // Initialize N8N Social Posting Service (نشر تلقائي عبر Laravel + N8N)
  Get.put(N8nSocialPostingService());

  // Initialize Claude AI Service (Anthropic Claude - Primary AI)
  Get.put(ClaudeService());
  print('✅ ClaudeService initialized (Anthropic Claude AI - Primary)');

  // Initialize Gemini AI Service (Google Gemini API - Backup)
  Get.put(GeminiService());
  print('✅ GeminiService initialized (Google Gemini AI - Backup)');

  // Initialize OpenAI Service (GPT-4, DALL-E, Whisper, TTS)
  Get.put(OpenAIService());
  print('✅ OpenAIService initialized (GPT-4 + DALL-E + TTS + Whisper)');

  // Initialize Groq Service (FREE - Llama 3.3 70B - Ultra Fast!)
  Get.put(GroqService());
  print('✅ GroqService initialized (FREE - Llama 3.3 70B - Primary AI)');

  // Initialize Stable Diffusion Service (Bulk image generation)
  Get.put(StableDiffusionService());
  print('✅ StableDiffusionService initialized (Stability AI - Bulk Images)');

  // Initialize Runway ML Service (Video generation)
  Get.put(RunwayService());
  print('✅ RunwayService initialized (Runway ML - Video Generation)');

  // Initialize Unified AI Manager (Central AI orchestration with usage limits)
  Get.put(UnifiedAIManager());
  print('✅ UnifiedAIManager initialized (AI orchestration with subscription limits)');

  // Initialize Advanced AI Content Service (AI Studio برنس)
  Get.put(AdvancedAIContentService());

  // Initialize Apify Service (Web scraping لجلب بيانات أي حساب سوشال ميديا)
  Get.put(ApifyService());
  print('✅ ApifyService initialized');

  // Initialize Ayrshare Social Media Service (Laravel Backend + Ayrshare API)
  Get.put(SocialMediaService());

  // Initialize N8N Workflow Service (Social media posting via N8N workflows)
  Get.put(N8nWorkflowService());
  print('✅ N8nWorkflowService initialized');

  // Initialize Google Drive Service (File uploads)
  Get.put(GoogleDriveService());
  print('✅ GoogleDriveService initialized');

  // Initialize AI Image Edit Service (AI-powered image editing)
  Get.put(AiImageEditService());
  print('✅ AiImageEditService initialized');

  // Initialize Background Telegram Service (Hidden bot integration for app features)
  Get.put(BackgroundTelegramService());
  print('✅ BackgroundTelegramService initialized (hidden bot system)');

  // Initialize App Events Tracker (Easy-to-use wrapper for tracking)
  Get.put(AppEventsTracker());
  print('✅ AppEventsTracker initialized (event tracking wrapper)');

  // Initialize YouTube Service (Alenwanmedia channel integration)
  Get.put(YouTubeService());
  print('✅ YouTubeService initialized (@Alenwanmedia channel)');

  // Initialize AI Media Service (Image & Video Generation)
  Get.put(AIMediaService());
  print('✅ AIMediaService initialized (AI-powered media generation)');

  // Initialize AI Scheduling Service (Smart post scheduling with AI)
  Get.put(AISchedulingService());
  print('✅ AISchedulingService initialized (AI-powered smart scheduling)');

  // Initialize Brand Kit Service (Brand identity management with trend analysis)
  Get.put(BrandKitService());
  print('✅ BrandKitService initialized (Brand identity & trend analysis)');

  // Initialize Cloudinary Service (Image editing and transformations)
  Get.put(CloudinaryService());
  print('✅ CloudinaryService initialized (Image editing with Cloudinary)');

  // Initialize Social Media Share Service (Native sharing to social platforms)
  Get.put(SocialMediaShareService());
  print('✅ SocialMediaShareService initialized (Native social media sharing)');

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
        theme: AppTheme.darkTheme, // Only dark theme
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Force dark mode

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
