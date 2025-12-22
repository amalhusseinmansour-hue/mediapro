import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// مساعد إعداد وتهيئة Firebase
class FirebaseHelper {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// تهيئة Firebase
  static Future<bool> initialize() async {
    try {
      if (_initialized) {
        print('✅ Firebase already initialized');
        return true;
      }

      await Firebase.initializeApp();
      _initialized = true;
      print('✅ Firebase initialized successfully');

      // اختبار الاتصال
      await _testConnection();

      return true;
    } catch (e) {
      print('⚠️ Firebase initialization failed: $e');
      print('💡 App will run in local-only mode');
      print('📄 See FIREBASE_SETUP_GUIDE.md for setup instructions');
      return false;
    }
  }

  /// اختبار الاتصال بFirebase
  static Future<void> _testConnection() async {
    try {
      // اختبار Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('_test')
          .doc('connection')
          .set({'timestamp': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      print('✅ Firestore connection OK');

      // اختبار Auth
      final auth = FirebaseAuth.instance;
      print('✅ Auth service OK - Current user: ${auth.currentUser?.uid ?? "none"}');
    } catch (e) {
      print('⚠️ Firebase services test failed: $e');
    }
  }

  /// إنشاء Indexes تلقائياً
  static Future<void> createIndexes() async {
    if (!_initialized) {
      print('⚠️ Firebase not initialized');
      return;
    }

    try {
      // تنبيه المستخدم بضرورة إنشاء Indexes يدوياً
      print('📝 Important: Create these Firestore indexes manually:');
      print('');
      print('1. Collection: posts');
      print('   Fields: userId (Ascending), status (Ascending), publishedAt (Descending)');
      print('');
      print('2. Collection: posts');
      print('   Fields: userId (Ascending), createdAt (Descending)');
      print('');
      print('3. Collection: ai_content_history');
      print('   Fields: userId (Ascending), createdAt (Descending)');
      print('');
      print('4. Collection: payments');
      print('   Fields: userId (Ascending), status (Ascending), createdAt (Descending)');
      print('');
      print('Go to: Firebase Console → Firestore → Indexes');
    } catch (e) {
      print('⚠️ Index creation notice failed: $e');
    }
  }

  /// فحص حالة Firebase
  static Future<Map<String, dynamic>> checkStatus() async {
    if (!_initialized) {
      return {
        'initialized': false,
        'firestore': false,
        'auth': false,
        'storage': false,
      };
    }

    final Map<String, dynamic> status = {
      'initialized': true,
    };

    try {
      // فحص Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('_test').limit(1).get();
      status['firestore'] = true;
    } catch (e) {
      status['firestore'] = false;
      print('⚠️ Firestore not accessible: $e');
    }

    try {
      // فحص Auth
      final auth = FirebaseAuth.instance;
      status['auth'] = true;
      status['currentUser'] = auth.currentUser?.uid;
    } catch (e) {
      status['auth'] = false;
      print('⚠️ Auth not accessible: $e');
    }

    status['storage'] = false; // يحتاج تفعيل منفصل

    return status;
  }

  /// إعدادات Firestore الموصى بها
  static Future<void> configureFirestore() async {
    if (!_initialized) return;

    try {
      final firestore = FirebaseFirestore.instance;

      // تفعيل Offline Persistence
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      print('✅ Firestore configured with offline persistence');
    } catch (e) {
      print('⚠️ Firestore configuration failed: $e');
    }
  }

  /// قواعد الأمان الموصى بها (للنسخ واللصق في Firebase Console)
  static String getRecommendedSecurityRules() {
    return '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper Functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isAdmin() {
      return isAuthenticated() &&
             get(/databases/\$(database)/documents/users/\$(request.auth.uid)).data.isAdmin == true;
    }

    // Users Collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Posts Collection
    match /posts/{postId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated() &&
                               resource.data.userId == request.auth.uid;
    }

    // Social Accounts Collection
    match /social_accounts/{accountId} {
      allow read, write: if isAuthenticated() &&
                           resource.data.userId == request.auth.uid;
    }

    // Analytics Collection
    match /analytics/{analyticsId} {
      allow read: if isAuthenticated() &&
                    resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update, delete: if false; // Read-only after creation
    }

    // AI Content History
    match /ai_content_history/{historyId} {
      allow read: if isAuthenticated() &&
                    resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update, delete: if false; // Read-only after creation
    }

    // Payments Collection
    match /payments/{paymentId} {
      allow read: if isAuthenticated() &&
                    resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update: if isAdmin(); // Only admins can update payment status
      allow delete: if false; // Never delete payments
    }

    // Support Tickets
    match /support_tickets/{ticketId} {
      allow read: if isAuthenticated() &&
                    (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
                      (resource.data.userId == request.auth.uid || isAdmin());
      allow delete: if isAdmin();
    }

    // Sponsored Ads
    match /sponsored_ads/{adId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
                      (resource.data.advertiserId == request.auth.uid || isAdmin());
      allow delete: if isAdmin();
    }
  }
}
''';
  }

  /// طباعة دليل الإعداد
  static void printSetupGuide() {
    print('''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 Firebase Setup Guide - Social Media Manager
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ Firebase is not configured yet. Follow these steps:

1️⃣ Create Firebase Project:
   → https://console.firebase.google.com
   → Click "Add project"
   → Enter project name: "Social Media Manager"
   → Follow the setup wizard

2️⃣ Add Android App:
   → In Firebase Console → Project Overview
   → Click "Add app" → Android icon
   → Package name: com.mediaprosocial.app
   → Download google-services.json
   → Place it in: android/app/google-services.json

3️⃣ Enable Services:
   → Authentication:
     • Go to Authentication → Get Started
     • Enable Email/Password
     • Enable Phone (optional)

   → Firestore Database:
     • Go to Firestore Database → Create Database
     • Start in production mode
     • Choose location (closest to users)

   → Storage (optional):
     • Go to Storage → Get Started
     • Use default rules

4️⃣ Security Rules:
   → Copy rules from: FirebaseHelper.getRecommendedSecurityRules()
   → Paste in Firestore → Rules tab

5️⃣ Create Indexes:
   → Run: FirebaseHelper.createIndexes()
   → Copy the index definitions
   → Paste in Firestore → Indexes tab

6️⃣ Restart App:
   → flutter clean
   → flutter pub get
   → flutter run

📄 For detailed guide, see: FIREBASE_SETUP_GUIDE.md
💡 For API keys guide, see: API_KEYS_SETUP_GUIDE.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''');
  }

  /// معلومات النسخة
  static Future<Map<String, String>> getVersionInfo() async {
    return {
      'firebase_core': '2.24.2',
      'firebase_auth': '4.16.0',
      'cloud_firestore': '4.14.0',
      'app_version': '1.0.0',
      'build_number': '1',
    };
  }
}
