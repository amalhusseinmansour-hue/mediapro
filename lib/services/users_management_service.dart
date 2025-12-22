import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Users Management Service
/// Handles admin operations for managing all users in the system
class UsersManagementService extends GetxController {
  static const String _usersBoxName = 'allUsersBox';

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterTier = 'all'.obs; // 'all', 'free', 'individual', 'business'
  final RxString sortBy = 'createdAt'.obs; // 'createdAt', 'name', 'lastLogin'

  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  @override
  void onInit() {
    super.onInit();
    _initializeFirestore();
    loadAllUsers();
  }

  void _initializeFirestore() {
    try {
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
      print('✅ UsersManagementService initialized with Firebase');
    } catch (e) {
      print('⚠️ Firebase not available, using local storage only');
      _isFirebaseAvailable = false;
    }
  }

  /// Load all users from Firestore or local storage
  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;

      if (_isFirebaseAvailable && _firestore != null) {
        // Load from Firestore
        await _loadFromFirestore();
      } else {
        // Load from local Hive storage
        await _loadFromLocalStorage();
      }

      _applySorting();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحميل المستخدمين: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load users from Firestore
  Future<void> _loadFromFirestore() async {
    try {
      final snapshot = await _firestore!.collection('users').get();

      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();

      allUsers.value = users;

      // Save to local storage for offline access
      await _saveToLocalStorage(users);
    } catch (e) {
      print('Error loading from Firestore: $e');
      // Fallback to local storage
      await _loadFromLocalStorage();
    }
  }

  /// Load users from local Hive storage
  Future<void> _loadFromLocalStorage() async {
    try {
      final box = await _getUsersBox();
      final users = box.values.toList();
      allUsers.value = users;
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }

  /// Save users to local storage
  Future<void> _saveToLocalStorage(List<UserModel> users) async {
    try {
      final box = await _getUsersBox();
      await box.clear();
      for (var user in users) {
        await box.put(user.id, user);
      }
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  /// Get users box
  Future<Box<UserModel>> _getUsersBox() async {
    if (!Hive.isBoxOpen(_usersBoxName)) {
      return await Hive.openBox<UserModel>(_usersBoxName);
    }
    return Hive.box<UserModel>(_usersBoxName);
  }

  /// Get filtered users based on search and filter criteria
  List<UserModel> get filteredUsers {
    var users = allUsers.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      users = users.where((user) {
        return user.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               user.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               user.phoneNumber.contains(searchQuery.value);
      }).toList();
    }

    // Apply tier filter
    if (filterTier.value != 'all') {
      users = users.where((user) => user.subscriptionTier == filterTier.value).toList();
    }

    return users;
  }

  /// Apply sorting
  void _applySorting() {
    switch (sortBy.value) {
      case 'name':
        allUsers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'lastLogin':
        allUsers.sort((a, b) {
          if (a.lastLogin == null) return 1;
          if (b.lastLogin == null) return -1;
          return b.lastLogin!.compareTo(a.lastLogin!);
        });
        break;
      case 'createdAt':
      default:
        allUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  /// Update user status (active/inactive)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      if (_isFirebaseAvailable && _firestore != null) {
        await _firestore!.collection('users').doc(userId).update({
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Update local storage
      final box = await _getUsersBox();
      final user = box.get(userId);
      if (user != null) {
        final updatedUser = user.copyWith(isActive: isActive);
        await box.put(userId, updatedUser);

        // Update in the list
        final index = allUsers.indexWhere((u) => u.id == userId);
        if (index != -1) {
          allUsers[index] = updatedUser;
          allUsers.refresh();
        }
      }

      Get.snackbar(
        'نجح',
        'تم تحديث حالة المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث حالة المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Update user subscription
  Future<bool> updateUserSubscription({
    required String userId,
    required String tier,
    DateTime? endDate,
  }) async {
    try {
      if (_isFirebaseAvailable && _firestore != null) {
        await _firestore!.collection('users').doc(userId).update({
          'subscriptionTier': tier,
          'subscriptionEndDate': endDate?.toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Update local storage
      final box = await _getUsersBox();
      final user = box.get(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          subscriptionTier: tier,
          subscriptionEndDate: endDate,
        );
        await box.put(userId, updatedUser);

        // Update in the list
        final index = allUsers.indexWhere((u) => u.id == userId);
        if (index != -1) {
          allUsers[index] = updatedUser;
          allUsers.refresh();
        }
      }

      Get.snackbar(
        'نجح',
        'تم تحديث اشتراك المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث اشتراك المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      if (_isFirebaseAvailable && _firestore != null) {
        await _firestore!.collection('users').doc(userId).delete();
      }

      // Delete from local storage
      final box = await _getUsersBox();
      await box.delete(userId);

      // Remove from list
      allUsers.removeWhere((u) => u.id == userId);

      Get.snackbar(
        'نجح',
        'تم حذف المستخدم بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get statistics
  Map<String, int> get statistics {
    return {
      'total': allUsers.length,
      'active': allUsers.where((u) => u.isActive).length,
      'inactive': allUsers.where((u) => !u.isActive).length,
      'free': allUsers.where((u) => u.isFree).length,
      'individual': allUsers.where((u) => u.isIndividualTier).length,
      'business': allUsers.where((u) => u.isBusinessTier).length,
      'verified': allUsers.where((u) => u.isPhoneVerified).length,
    };
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set filter tier
  void setFilterTier(String tier) {
    filterTier.value = tier;
  }

  /// Set sorting
  void setSorting(String sort) {
    sortBy.value = sort;
    _applySorting();
  }

  /// Refresh users list
  @override
  Future<void> refresh() async {
    await loadAllUsers();
  }
}
