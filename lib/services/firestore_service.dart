import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/social_account_model.dart';
import '../models/payment_model.dart';
import '../models/payment_transaction_model.dart';
import '../models/payment_gateway_config_model.dart';
import '../models/sms_message_model.dart';
import '../models/sms_provider_model.dart';
import '../models/otp_config_model.dart';
import '../models/login_history_model.dart';

/// Firestore Database Service
/// Handles all database operations with Firebase Cloud Firestore
class FirestoreService extends GetxController {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  // Observable loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFirestore();
  }

  void _initializeFirestore() {
    try {
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
      print('✅ FirestoreService initialized with Firebase');
    } catch (e) {
      print('⚠️ FirestoreService: Firebase not available, using local storage only');
      _isFirebaseAvailable = false;
    }
  }

  /// Collection references
  CollectionReference? get _usersCollection => _firestore?.collection('users');
  CollectionReference? get _postsCollection => _firestore?.collection('posts');
  CollectionReference? get _socialAccountsCollection =>
      _firestore?.collection('social_accounts');
  CollectionReference? get _analyticsCollection =>
      _firestore?.collection('analytics');
  CollectionReference? get _aiContentHistoryCollection =>
      _firestore?.collection('ai_content_history');
  CollectionReference? get _paymentsCollection =>
      _firestore?.collection('payments');
  CollectionReference? get _paymentTransactionsCollection =>
      _firestore?.collection('payment_transactions');
  CollectionReference? get _paymentGatewaysCollection =>
      _firestore?.collection('payment_gateways');
  CollectionReference? get _smsMessagesCollection =>
      _firestore?.collection('sms_messages');
  CollectionReference? get _smsProvidersCollection =>
      _firestore?.collection('sms_providers');
  CollectionReference? get _otpConfigsCollection =>
      _firestore?.collection('otp_configs');
  CollectionReference? get _loginHistoryCollection =>
      _firestore?.collection('login_history');

  // ==================== USER OPERATIONS ====================

  /// Create or update user in Firestore
  Future<bool> createOrUpdateUser(UserModel user) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. User data will be stored locally only.');
      return false;
    }

    try {
      isLoading.value = true;

      final userData = user.toJson();
      userData['updatedAt'] = FieldValue.serverTimestamp();

      // Check if user exists
      final doc = await _usersCollection!.doc(user.id).get();

      if (doc.exists) {
        // Update existing user
        await _usersCollection!.doc(user.id).update(userData);
      } else {
        // Create new user
        userData['createdAt'] = FieldValue.serverTimestamp();
        await _usersCollection!.doc(user.id).set(userData);
      }

      return true;
    } catch (e) {
      // Silent fail - data is stored locally in Hive
      print('ℹ️ Firestore not available - user saved locally only: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _usersCollection!.doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }

      return null;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل جلب بيانات المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  /// Update user subscription
  Future<bool> updateUserSubscription({
    required String userId,
    required String tier,
    required String subscriptionType,
    DateTime? endDate,
  }) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _usersCollection!.doc(userId).update({
        'subscriptionTier': tier,
        'subscriptionType': subscriptionType,
        'subscriptionEndDate': endDate?.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث الاشتراك: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Update user data
  Future<bool> updateUser(UserModel user) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final userData = user.toJson();
      userData['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection!.doc(user.id).update(userData);
      return true;
    } catch (e) {
      print('Failed to update user: $e');
      Get.snackbar(
        'خطأ',
        'فشل تحديث بيانات المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Update user last login
  Future<void> updateUserLastLogin(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return;
    }

    try {
      await _usersCollection!.doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
        'isLoggedIn': true,
      });
    } catch (e) {
      print('Failed to update last login: $e');
    }
  }

  // ==================== SOCIAL ACCOUNTS OPERATIONS ====================

  /// Save social media account
  Future<bool> saveSocialAccount(
      String userId, SocialAccountModel account) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final accountData = account.toJson();
      accountData['userId'] = userId;
      accountData['updatedAt'] = FieldValue.serverTimestamp();

      final doc = await _socialAccountsCollection!.doc(account.id).get();

      if (doc.exists) {
        await _socialAccountsCollection!.doc(account.id).update(accountData);
      } else {
        accountData['createdAt'] = FieldValue.serverTimestamp();
        await _socialAccountsCollection!.doc(account.id).set(accountData);
      }

      return true;
    } catch (e) {
      // Silent fail - account is stored locally in Hive
      print('ℹ️ Firestore not available - account saved locally only: $e');
      return false;
    }
  }

  /// Get all social accounts for a user
  Future<List<SocialAccountModel>> getUserSocialAccounts(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _socialAccountsCollection!
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => SocialAccountModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل جلب الحسابات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return [];
    }
  }

  /// Delete social account
  Future<bool> deleteSocialAccount(String accountId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _socialAccountsCollection!.doc(accountId).delete();
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف الحساب: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  // ==================== POSTS OPERATIONS ====================

  /// Save post
  Future<bool> savePost(String userId, PostModel post) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final postData = post.toJson();
      postData['userId'] = userId;
      postData['updatedAt'] = FieldValue.serverTimestamp();

      final doc = await _postsCollection!.doc(post.id).get();

      if (doc.exists) {
        await _postsCollection!.doc(post.id).update(postData);
      } else {
        postData['createdAt'] = FieldValue.serverTimestamp();
        await _postsCollection!.doc(post.id).set(postData);
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حفظ المنشور: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Get all posts for a user
  Future<List<PostModel>> getUserPosts(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _postsCollection!
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل جلب المنشورات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return [];
    }
  }

  /// Get posts by status
  Future<List<PostModel>> getUserPostsByStatus(
      String userId, PostStatus status) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _postsCollection!
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل جلب المنشورات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return [];
    }
  }

  /// Get all published posts from all users (for community feed)
  Future<List<PostModel>> getAllPublishedPosts({int limit = 50}) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _postsCollection!
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('فشل جلب البوستات المنشورة: ${e.toString()}');
      return [];
    }
  }

  /// Update post status
  Future<bool> updatePostStatus(String postId, PostStatus status) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _postsCollection!.doc(postId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث حالة المنشور: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Delete post
  Future<bool> deletePost(String postId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _postsCollection!.doc(postId).delete();
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف المنشور: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Get dashboard statistics for user
  Future<Map<String, dynamic>> getUserDashboardStats(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return {
        'totalPosts': 0,
        'publishedPosts': 0,
        'scheduledPosts': 0,
        'connectedAccounts': 0,
        'totalEngagement': 0,
      };
    }

    try {
      // عدد المنشورات
      final postsSnapshot = await _postsCollection!
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      // عدد المنشورات المنشورة
      final publishedSnapshot = await _postsCollection!
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'published')
          .count()
          .get();

      // عدد المنشورات المجدولة
      final scheduledSnapshot = await _postsCollection!
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'scheduled')
          .count()
          .get();

      // عدد الحسابات المتصلة
      final accountsSnapshot = await _socialAccountsCollection!
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      // حساب إجمالي التفاعل من المنشورات المنشورة
      final postsWithAnalytics = await _postsCollection!
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'published')
          .get();

      int totalEngagement = 0;
      for (var doc in postsWithAnalytics.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final analytics = data['analytics'] as Map<String, dynamic>?;
        if (analytics != null) {
          totalEngagement += (analytics['likes'] as int? ?? 0);
          totalEngagement += (analytics['comments'] as int? ?? 0);
          totalEngagement += (analytics['shares'] as int? ?? 0);
        }
      }

      return {
        'totalPosts': postsSnapshot.count ?? 0,
        'publishedPosts': publishedSnapshot.count ?? 0,
        'scheduledPosts': scheduledSnapshot.count ?? 0,
        'connectedAccounts': accountsSnapshot.count ?? 0,
        'totalEngagement': totalEngagement,
      };
    } catch (e) {
      print('فشل جلب إحصائيات لوحة التحكم: $e');
      return {
        'totalPosts': 0,
        'publishedPosts': 0,
        'scheduledPosts': 0,
        'connectedAccounts': 0,
        'totalEngagement': 0,
      };
    }
  }

  // ==================== ANALYTICS OPERATIONS ====================

  /// Save analytics data
  Future<bool> saveAnalytics({
    required String userId,
    required String accountId,
    required String platform,
    required Map<String, dynamic> metrics,
    required DateTime date,
  }) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final analyticsId =
          '${userId}_${accountId}_${date.millisecondsSinceEpoch}';

      await _analyticsCollection!.doc(analyticsId).set({
        'userId': userId,
        'accountId': accountId,
        'platform': platform,
        'metrics': metrics,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حفظ التحليلات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Get analytics for user in date range
  Future<List<Map<String, dynamic>>> getAnalytics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      Query query = _analyticsCollection!
          .where('userId', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (accountId != null) {
        query = query.where('accountId', isEqualTo: accountId);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل جلب التحليلات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return [];
    }
  }

  // ==================== AI CONTENT HISTORY ====================

  /// Save AI generated content
  Future<bool> saveAIContentHistory({
    required String userId,
    required String prompt,
    required String generatedContent,
    required String contentType,
  }) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _aiContentHistoryCollection!.add({
        'userId': userId,
        'prompt': prompt,
        'generatedContent': generatedContent,
        'contentType': contentType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حفظ المحتوى: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Get AI content history for user
  Future<List<Map<String, dynamic>>> getAIContentHistory(String userId,
      {int limit = 50}) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _aiContentHistoryCollection!
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل جلب السجل: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return [];
    }
  }

  // ==================== SUBSCRIPTION TRACKING ====================

  /// Track monthly usage
  Future<Map<String, int>> getUserMonthlyUsage(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return {
        'posts': 0,
        'aiRequests': 0,
        'accounts': 0,
      };
    }

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Count posts this month
      final postsSnapshot = await _postsCollection!
          .where('userId', isEqualTo: userId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .count()
          .get();

      // Count AI requests this month
      final aiSnapshot = await _aiContentHistoryCollection!
          .where('userId', isEqualTo: userId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .count()
          .get();

      // Count social accounts
      final accountsSnapshot = await _socialAccountsCollection!
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return {
        'posts': postsSnapshot.count ?? 0,
        'aiRequests': aiSnapshot.count ?? 0,
        'accounts': accountsSnapshot.count ?? 0,
      };
    } catch (e) {
      print('Failed to get monthly usage: $e');
      return {
        'posts': 0,
        'aiRequests': 0,
        'accounts': 0,
      };
    }
  }

  // ==================== REAL-TIME LISTENERS ====================

  /// Listen to user changes
  Stream<UserModel?> listenToUser(String userId) {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value(null);
    }

    return _usersCollection!.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
      return null;
    });
  }

  /// Listen to user posts
  Stream<List<PostModel>> listenToUserPosts(String userId) {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _postsCollection!
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Listen to social accounts
  Stream<List<SocialAccountModel>> listenToSocialAccounts(String userId) {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _socialAccountsCollection!
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SocialAccountModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch delete posts
  Future<bool> batchDeletePosts(List<String> postIds) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final batch = _firestore!.batch();

      for (final postId in postIds) {
        batch.delete(_postsCollection!.doc(postId));
      }

      await batch.commit();
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف المنشورات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  // ==================== PAYMENT OPERATIONS ====================

  /// Save payment record
  Future<bool> savePayment(PaymentModel payment) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final paymentData = payment.toJson();
      paymentData['createdAt'] = FieldValue.serverTimestamp();

      await _paymentsCollection!.doc(payment.id).set(paymentData);

      print('✅ Payment saved to Firestore: ${payment.id}');
      return true;
    } catch (e) {
      print('❌ Failed to save payment: $e');
      Get.snackbar(
        'خطأ',
        'فشل حفظ بيانات الدفع: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus({
    required String paymentId,
    required PaymentStatusEnum status,
    int? transactionId,
  }) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final updateData = {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == PaymentStatusEnum.success) {
        updateData['paidAt'] = FieldValue.serverTimestamp();
      }

      if (transactionId != null) {
        updateData['paymobTransactionId'] = transactionId;
      }

      await _paymentsCollection!.doc(paymentId).update(updateData);

      print('✅ Payment status updated: $paymentId -> ${status.name}');
      return true;
    } catch (e) {
      print('❌ Failed to update payment status: $e');
      return false;
    }
  }

  /// Get user payments
  Future<List<PaymentModel>> getUserPayments(String userId,
      {int limit = 50}) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _paymentsCollection!
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              PaymentModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Failed to get user payments: $e');
      return [];
    }
  }

  /// Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _paymentsCollection!.doc(paymentId).get();

      if (doc.exists) {
        return PaymentModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('❌ Failed to get payment: $e');
      return null;
    }
  }

  /// Get active subscription for user
  Future<PaymentModel?> getActiveSubscription(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final snapshot = await _paymentsCollection!
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'success')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final payment = PaymentModel.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);

        // Check if still active
        if (payment.isActive) {
          return payment;
        }
      }

      return null;
    } catch (e) {
      print('❌ Failed to get active subscription: $e');
      return null;
    }
  }

  /// Listen to user payments (real-time)
  Stream<List<PaymentModel>> listenToUserPayments(String userId) {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _paymentsCollection!
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              PaymentModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // ==================== PAYMENT TRANSACTIONS ====================

  /// Create payment transaction
  Future<String?> createPaymentTransaction(
      PaymentTransactionModel transaction) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final docRef = await _paymentTransactionsCollection!.add(
        transaction.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      print('Error creating payment transaction: $e');
      return null;
    }
  }

  /// Update payment transaction
  Future<bool> updatePaymentTransaction(
      String transactionId, Map<String, dynamic> data) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _paymentTransactionsCollection!.doc(transactionId).update(data);
      return true;
    } catch (e) {
      print('Error updating payment transaction: $e');
      return false;
    }
  }

  /// Get payment transaction by ID
  Future<PaymentTransactionModel?> getPaymentTransaction(
      String transactionId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _paymentTransactionsCollection!.doc(transactionId).get();
      if (doc.exists) {
        return PaymentTransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting payment transaction: $e');
      return null;
    }
  }

  /// Get user payment transactions
  Future<List<PaymentTransactionModel>> getUserPaymentTransactions(
      String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _paymentTransactionsCollection!
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user payment transactions: $e');
      return [];
    }
  }

  /// Listen to user payment transactions
  Stream<List<PaymentTransactionModel>> listenToUserPaymentTransactions(
      String userId) {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _paymentTransactionsCollection!
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentTransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return {
        'totalAmount': 0.0,
        'successfulAmount': 0.0,
        'totalCount': 0,
        'successfulCount': 0,
        'failedCount': 0,
        'pendingCount': 0,
        'successRate': 0.0,
      };
    }

    try {
      final transactions = await getUserPaymentTransactions(userId);

      double totalAmount = 0;
      double successfulAmount = 0;
      int totalCount = transactions.length;
      int successfulCount = 0;
      int failedCount = 0;
      int pendingCount = 0;

      for (var transaction in transactions) {
        totalAmount += transaction.amount;

        switch (transaction.status) {
          case PaymentStatus.completed:
            successfulAmount += transaction.amount;
            successfulCount++;
            break;
          case PaymentStatus.failed:
            failedCount++;
            break;
          case PaymentStatus.pending:
          case PaymentStatus.processing:
            pendingCount++;
            break;
          default:
            break;
        }
      }

      return {
        'totalAmount': totalAmount,
        'successfulAmount': successfulAmount,
        'totalCount': totalCount,
        'successfulCount': successfulCount,
        'failedCount': failedCount,
        'pendingCount': pendingCount,
        'successRate':
            totalCount > 0 ? (successfulCount / totalCount * 100) : 0.0,
      };
    } catch (e) {
      print('Error getting payment statistics: $e');
      return {
        'totalAmount': 0.0,
        'successfulAmount': 0.0,
        'totalCount': 0,
        'successfulCount': 0,
        'failedCount': 0,
        'pendingCount': 0,
        'successRate': 0.0,
      };
    }
  }

  // ==================== PAYMENT GATEWAY CONFIG ====================

  /// Save payment gateway config
  Future<bool> savePaymentGatewayConfig(
      PaymentGatewayConfigModel config) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _paymentGatewaysCollection!.doc(config.id).set(
            config.toFirestore(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      print('Error saving payment gateway config: $e');
      return false;
    }
  }

  /// Get payment gateway config
  Future<PaymentGatewayConfigModel?> getPaymentGatewayConfig(
      String gatewayId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _paymentGatewaysCollection!.doc(gatewayId).get();
      if (doc.exists) {
        return PaymentGatewayConfigModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting payment gateway config: $e');
      return null;
    }
  }

  /// Get all payment gateway configs
  Future<List<PaymentGatewayConfigModel>> getAllPaymentGatewayConfigs() async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot =
          await _paymentGatewaysCollection!.orderBy('priority').get();

      return snapshot.docs
          .map((doc) => PaymentGatewayConfigModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting payment gateway configs: $e');
      return [];
    }
  }

  /// Listen to payment gateway configs
  Stream<List<PaymentGatewayConfigModel>> listenToPaymentGatewayConfigs() {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _paymentGatewaysCollection!.orderBy('priority').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => PaymentGatewayConfigModel.fromFirestore(doc))
            .toList();
      },
    );
  }

  /// Get enabled payment gateways
  Future<List<PaymentGatewayConfigModel>> getEnabledPaymentGateways() async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _paymentGatewaysCollection!
          .where('isEnabled', isEqualTo: true)
          .orderBy('priority')
          .get();

      return snapshot.docs
          .map((doc) => PaymentGatewayConfigModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting enabled payment gateways: $e');
      return [];
    }
  }

  /// Delete payment gateway config
  Future<bool> deletePaymentGatewayConfig(String gatewayId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _paymentGatewaysCollection!.doc(gatewayId).delete();
      return true;
    } catch (e) {
      print('Error deleting payment gateway config: $e');
      return false;
    }
  }

  // ==================== SMS OPERATIONS ====================

  /// Create SMS message
  Future<String?> createSMSMessage(SMSMessageModel message) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final docRef = await _smsMessagesCollection!.add(message.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating SMS message: $e');
      return null;
    }
  }

  /// Update SMS message
  Future<bool> updateSMSMessage(
      String messageId, Map<String, dynamic> data) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _smsMessagesCollection!.doc(messageId).update(data);
      return true;
    } catch (e) {
      print('Error updating SMS message: $e');
      return false;
    }
  }

  /// Get SMS message by ID
  Future<SMSMessageModel?> getSMSMessage(String messageId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _smsMessagesCollection!.doc(messageId).get();
      if (doc.exists) {
        return SMSMessageModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting SMS message: $e');
      return null;
    }
  }

  /// Get user SMS messages
  Future<List<SMSMessageModel>> getUserSMSMessages(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _smsMessagesCollection!
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SMSMessageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user SMS messages: $e');
      return [];
    }
  }

  /// Listen to user SMS messages
  Stream<List<SMSMessageModel>> listenToUserSMSMessages(String userId) {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _smsMessagesCollection!
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SMSMessageModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get SMS statistics
  Future<Map<String, dynamic>> getSMSStatistics(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return {
        'totalCount': 0,
        'sentCount': 0,
        'deliveredCount': 0,
        'failedCount': 0,
        'pendingCount': 0,
        'totalCost': 0.0,
        'deliveryRate': 0.0,
        'failureRate': 0.0,
      };
    }

    try {
      final messages = await getUserSMSMessages(userId);

      int totalCount = messages.length;
      int sentCount = 0;
      int deliveredCount = 0;
      int failedCount = 0;
      int pendingCount = 0;
      double totalCost = 0.0;

      for (var message in messages) {
        if (message.cost != null) {
          totalCost += message.cost!;
        }

        switch (message.status) {
          case SMSStatus.sent:
            sentCount++;
            break;
          case SMSStatus.delivered:
            deliveredCount++;
            break;
          case SMSStatus.failed:
            failedCount++;
            break;
          case SMSStatus.pending:
          case SMSStatus.sending:
            pendingCount++;
            break;
          default:
            break;
        }
      }

      return {
        'totalCount': totalCount,
        'sentCount': sentCount,
        'deliveredCount': deliveredCount,
        'failedCount': failedCount,
        'pendingCount': pendingCount,
        'totalCost': totalCost,
        'deliveryRate': totalCount > 0 ? (deliveredCount / totalCount * 100) : 0.0,
        'failureRate': totalCount > 0 ? (failedCount / totalCount * 100) : 0.0,
      };
    } catch (e) {
      print('Error getting SMS statistics: $e');
      return {
        'totalCount': 0,
        'sentCount': 0,
        'deliveredCount': 0,
        'failedCount': 0,
        'pendingCount': 0,
        'totalCost': 0.0,
        'deliveryRate': 0.0,
        'failureRate': 0.0,
      };
    }
  }

  // ==================== SMS PROVIDER CONFIG ====================

  /// Save SMS provider config
  Future<bool> saveSMSProviderConfig(SMSProviderModel config) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _smsProvidersCollection!.doc(config.id).set(
            config.toFirestore(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      print('Error saving SMS provider config: $e');
      return false;
    }
  }

  /// Get SMS provider config
  Future<SMSProviderModel?> getSMSProviderConfig(String providerId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _smsProvidersCollection!.doc(providerId).get();
      if (doc.exists) {
        return SMSProviderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting SMS provider config: $e');
      return null;
    }
  }

  /// Get all SMS provider configs
  Future<List<SMSProviderModel>> getAllSMSProviderConfigs() async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _smsProvidersCollection!.orderBy('priority').get();

      return snapshot.docs
          .map((doc) => SMSProviderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting SMS provider configs: $e');
      return [];
    }
  }

  /// Listen to SMS provider configs
  Stream<List<SMSProviderModel>> listenToSMSProviderConfigs() {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _smsProvidersCollection!.orderBy('priority').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => SMSProviderModel.fromFirestore(doc))
            .toList();
      },
    );
  }

  /// Get enabled SMS providers
  Future<List<SMSProviderModel>> getEnabledSMSProviders() async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _smsProvidersCollection!
          .where('isEnabled', isEqualTo: true)
          .orderBy('priority')
          .get();

      return snapshot.docs
          .map((doc) => SMSProviderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting enabled SMS providers: $e');
      return [];
    }
  }

  /// Delete SMS provider config
  Future<bool> deleteSMSProviderConfig(String providerId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _smsProvidersCollection!.doc(providerId).delete();
      return true;
    } catch (e) {
      print('Error deleting SMS provider config: $e');
      return false;
    }
  }

  // ==================== OTP CONFIGURATION OPERATIONS ====================

  /// Get OTP configuration (there should be only one global config)
  Future<OTPConfigModel?> getOTPConfig() async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _otpConfigsCollection!.doc('global').get();

      if (doc.exists) {
        return OTPConfigModel.fromFirestore(doc);
      }

      // If not exists, create default config
      final defaultConfig = OTPConfigModel.getDefault();
      await saveOTPConfig(defaultConfig);
      return defaultConfig;
    } catch (e) {
      print('Error getting OTP config: $e');
      return null;
    }
  }

  /// Save or update OTP configuration
  Future<bool> saveOTPConfig(OTPConfigModel config) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final data = config.toFirestore();
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _otpConfigsCollection!.doc('global').set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving OTP config: $e');
      return false;
    }
  }

  /// Update specific OTP provider configuration
  Future<bool> updateOTPProviderConfig({
    required String providerName,
    required OTPProviderConfig providerConfig,
  }) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _otpConfigsCollection!.doc('global').update({
        'providers.$providerName': providerConfig.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error updating OTP provider config: $e');
      return false;
    }
  }

  /// Update default OTP provider
  Future<bool> updateDefaultOTPProvider(String providerName) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _otpConfigsCollection!.doc('global').update({
        'defaultProvider': providerName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error updating default OTP provider: $e');
      return false;
    }
  }

  /// Update OTP settings (length, expiry, retries)
  Future<bool> updateOTPSettings({
    int? otpLength,
    int? expiryMinutes,
    int? maxRetries,
    bool? isTestMode,
  }) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (otpLength != null) updates['otpLength'] = otpLength;
      if (expiryMinutes != null) updates['expiryMinutes'] = expiryMinutes;
      if (maxRetries != null) updates['maxRetries'] = maxRetries;
      if (isTestMode != null) updates['isTestMode'] = isTestMode;

      await _otpConfigsCollection!.doc('global').update(updates);
      return true;
    } catch (e) {
      print('Error updating OTP settings: $e');
      return false;
    }
  }

  /// Listen to OTP configuration changes
  Stream<OTPConfigModel?> listenToOTPConfig() {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value(null);
    }

    return _otpConfigsCollection!.doc('global').snapshots().map(
      (doc) {
        if (doc.exists) {
          return OTPConfigModel.fromFirestore(doc);
        }
        return null;
      },
    );
  }

  /// Reset OTP configuration to default
  Future<bool> resetOTPConfigToDefault() async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final defaultConfig = OTPConfigModel.getDefault();
      await saveOTPConfig(defaultConfig);
      return true;
    } catch (e) {
      print('Error resetting OTP config: $e');
      return false;
    }
  }

  // ==================== LOGIN HISTORY OPERATIONS ====================

  /// حفظ سجل تسجيل دخول جديد
  Future<String?> saveLoginHistory(LoginHistoryModel loginHistory) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Login history will be stored locally only.');
      return null;
    }

    try {
      final docRef = await _loginHistoryCollection!.add(
        loginHistory.toFirestore(),
      );
      print('✅ Login history saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Failed to save login history: $e');
      return null;
    }
  }

  /// تحديث سجل تسجيل دخول (مثلاً إضافة وقت الخروج)
  Future<bool> updateLoginHistory(
      String historyId, Map<String, dynamic> data) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      await _loginHistoryCollection!.doc(historyId).update(data);
      print('✅ Login history updated: $historyId');
      return true;
    } catch (e) {
      print('❌ Failed to update login history: $e');
      return false;
    }
  }

  /// تحديث وقت تسجيل الخروج ومدة الجلسة
  Future<bool> recordLogout(String historyId, DateTime logoutTime) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      // الحصول على سجل تسجيل الدخول
      final loginHistory = await getLoginHistory(historyId);
      if (loginHistory != null) {
        final sessionDuration =
            logoutTime.difference(loginHistory.loginTime).inMinutes;

        await _loginHistoryCollection!.doc(historyId).update({
          'logoutTime': Timestamp.fromDate(logoutTime),
          'sessionDuration': sessionDuration,
        });

        print('✅ Logout recorded for history: $historyId');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Failed to record logout: $e');
      return false;
    }
  }

  /// الحصول على سجل تسجيل دخول واحد
  Future<LoginHistoryModel?> getLoginHistory(String historyId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return null;
    }

    try {
      final doc = await _loginHistoryCollection!.doc(historyId).get();
      if (doc.exists) {
        return LoginHistoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Failed to get login history: $e');
      return null;
    }
  }

  /// الحصول على سجل تسجيل الدخول للمستخدم
  Future<List<LoginHistoryModel>> getUserLoginHistory(String userId,
      {int limit = 50}) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _loginHistoryCollection!
          .where('userId', isEqualTo: userId)
          .orderBy('loginTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LoginHistoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Failed to get user login history: $e');
      return [];
    }
  }

  /// الحصول على سجل تسجيل الدخول الناجح فقط
  Future<List<LoginHistoryModel>> getUserSuccessfulLogins(String userId,
      {int limit = 50}) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _loginHistoryCollection!
          .where('userId', isEqualTo: userId)
          .where('isSuccessful', isEqualTo: true)
          .orderBy('loginTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LoginHistoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Failed to get successful logins: $e');
      return [];
    }
  }

  /// الحصول على سجل محاولات تسجيل الدخول الفاشلة
  Future<List<LoginHistoryModel>> getUserFailedLogins(String userId,
      {int limit = 50}) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return [];
    }

    try {
      final snapshot = await _loginHistoryCollection!
          .where('userId', isEqualTo: userId)
          .where('isSuccessful', isEqualTo: false)
          .orderBy('loginTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LoginHistoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Failed to get failed logins: $e');
      return [];
    }
  }

  /// الاستماع إلى سجل تسجيل الدخول (real-time)
  Stream<List<LoginHistoryModel>> listenToUserLoginHistory(String userId) {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Returning empty stream.');
      return Stream.value([]);
    }

    return _loginHistoryCollection!
        .where('userId', isEqualTo: userId)
        .orderBy('loginTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LoginHistoryModel.fromFirestore(doc))
          .toList();
    });
  }

  /// الحصول على إحصائيات تسجيل الدخول
  Future<Map<String, dynamic>> getLoginStatistics(String userId) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return {
        'totalLogins': 0,
        'successfulLogins': 0,
        'failedLogins': 0,
        'averageSessionDuration': 0.0,
        'lastLoginTime': null,
        'mostUsedLoginMethod': 'unknown',
      };
    }

    try {
      final allLogins = await getUserLoginHistory(userId, limit: 1000);

      int totalLogins = allLogins.length;
      int successfulLogins =
          allLogins.where((login) => login.isSuccessful).length;
      int failedLogins = allLogins.where((login) => !login.isSuccessful).length;

      // حساب متوسط مدة الجلسة
      final sessionsWithDuration =
          allLogins.where((login) => login.sessionDuration != null).toList();
      double averageSessionDuration = 0.0;
      if (sessionsWithDuration.isNotEmpty) {
        int totalDuration = sessionsWithDuration.fold(
            0, (sum, login) => sum + (login.sessionDuration ?? 0));
        averageSessionDuration = totalDuration / sessionsWithDuration.length;
      }

      // آخر تسجيل دخول
      DateTime? lastLoginTime;
      if (allLogins.isNotEmpty) {
        lastLoginTime = allLogins.first.loginTime;
      }

      // الطريقة الأكثر استخداماً لتسجيل الدخول
      Map<String, int> loginMethodCount = {};
      for (var login in allLogins) {
        loginMethodCount[login.loginMethod] =
            (loginMethodCount[login.loginMethod] ?? 0) + 1;
      }
      String mostUsedLoginMethod = 'unknown';
      if (loginMethodCount.isNotEmpty) {
        mostUsedLoginMethod = loginMethodCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      return {
        'totalLogins': totalLogins,
        'successfulLogins': successfulLogins,
        'failedLogins': failedLogins,
        'averageSessionDuration': averageSessionDuration,
        'lastLoginTime': lastLoginTime?.toIso8601String(),
        'mostUsedLoginMethod': mostUsedLoginMethod,
        'successRate':
            totalLogins > 0 ? (successfulLogins / totalLogins * 100) : 0.0,
      };
    } catch (e) {
      print('❌ Failed to get login statistics: $e');
      return {
        'totalLogins': 0,
        'successfulLogins': 0,
        'failedLogins': 0,
        'averageSessionDuration': 0.0,
        'lastLoginTime': null,
        'mostUsedLoginMethod': 'unknown',
      };
    }
  }

  /// حذف سجلات تسجيل دخول قديمة (أقدم من تاريخ معين)
  Future<bool> deleteOldLoginHistory(String userId, DateTime beforeDate) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final snapshot = await _loginHistoryCollection!
          .where('userId', isEqualTo: userId)
          .where('loginTime', isLessThan: Timestamp.fromDate(beforeDate))
          .get();

      final batch = _firestore!.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Deleted ${snapshot.docs.length} old login history records');
      return true;
    } catch (e) {
      print('❌ Failed to delete old login history: $e');
      return false;
    }
  }

  // ==================== UTILITIES ====================

  /// Check if collection exists and has data
  Future<bool> collectionHasData(String collection) async {
    if (!_isFirebaseAvailable) {
      print('⚠️ Firebase not available. Operation will use local storage only.');
      return false;
    }

    try {
      final snapshot =
          await _firestore!.collection(collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
