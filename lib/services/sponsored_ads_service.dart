import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sponsored_ad_model.dart';
import 'auth_service.dart';

class SponsoredAdsService extends GetxController {
  static const String _adsBoxName = 'sponsoredAds';

  final RxList<SponsoredAdModel> ads = <SponsoredAdModel>[].obs;
  final RxBool isLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  Box<SponsoredAdModel>? _adsBox;

  @override
  void onInit() {
    super.onInit();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    isLoading.value = true;
    try {
      _adsBox = await Hive.openBox<SponsoredAdModel>(_adsBoxName);
      await loadAds();
    } catch (e) {
      print('Error initializing sponsored ads box: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل جميع الإعلانات للمستخدم الحالي
  Future<void> loadAds() async {
    try {
      if (_adsBox == null) {
        print('⚠️ Ads box not initialized yet');
        return;
      }

      final user = _authService.currentUser.value;
      if (user == null) return;

      final allAds = _adsBox!.values.toList();

      // فلترة الإعلانات للمستخدم الحالي فقط
      ads.value = allAds.where((ad) => ad.userId == user.id).toList();

      // ترتيب حسب التاريخ (الأحدث أولاً)
      ads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error loading ads: $e');
    }
  }

  // جلب جميع الإعلانات (للأدمن - بدون فلترة)
  List<SponsoredAdModel> getAllAds() {
    if (_adsBox == null) {
      print('⚠️ Ads box not initialized yet');
      return [];
    }
    final allAds = _adsBox!.values.toList();
    allAds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allAds;
  }

  // تحميل جميع الإعلانات إلى القائمة المحلية (للأدمن)
  Future<void> loadAllAds() async {
    try {
      if (_adsBox == null) {
        print('⚠️ Ads box not initialized yet');
        return;
      }
      ads.value = _adsBox!.values.toList();
      ads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error loading all ads: $e');
    }
  }

  // إنشاء إعلان ممول جديد
  Future<SponsoredAdModel?> createAd({
    required String title,
    required String description,
    required AdType adType,
    required List<AdPlatform> platforms,
    required AdObjective objective,
    required double budget,
    required int durationDays,
    TargetAudience? targetAudience,
    String? websiteUrl,
    String? callToAction,
    List<String>? imageUrls,
  }) async {
    try {
      if (_adsBox == null) {
        print('❌ Ads box not initialized yet. Cannot create ad.');
        Get.snackbar(
          'خطأ',
          'الرجاء الانتظار حتى يتم تحميل البيانات',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      final user = _authService.currentUser.value;
      if (user == null) {
        print('❌ User not logged in. Cannot create ad.');
        return null;
      }

      const uuid = Uuid();

      final ad = SponsoredAdModel(
        id: uuid.v4(),
        userId: user.id,
        title: title,
        description: description,
        adType: adType,
        platforms: platforms,
        objective: objective,
        budget: budget,
        durationDays: durationDays,
        targetAudience: targetAudience,
        websiteUrl: websiteUrl,
        callToAction: callToAction,
        imageUrls: imageUrls,
        status: AdStatus.pending,
        createdAt: DateTime.now(),
      );

      await _adsBox!.put(ad.id, ad);
      ads.insert(0, ad);

      print('✅ Ad created successfully: ${ad.id}');
      return ad;
    } catch (e) {
      print('❌ Error creating ad: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الإعلان: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // تحديث حالة الإعلان (للباك اند)
  Future<bool> updateAdStatus({
    required String adId,
    required AdStatus status,
    String? adminNote,
    String? rejectionReason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (_adsBox == null) {
        print('⚠️ Ads box not initialized yet');
        return false;
      }

      final ad = _adsBox!.get(adId);
      if (ad == null) return false;

      final updatedAd = SponsoredAdModel(
        id: ad.id,
        userId: ad.userId,
        title: ad.title,
        description: ad.description,
        adType: ad.adType,
        platforms: ad.platforms,
        objective: ad.objective,
        budget: ad.budget,
        durationDays: ad.durationDays,
        targetAudience: ad.targetAudience,
        websiteUrl: ad.websiteUrl,
        callToAction: ad.callToAction,
        imageUrls: ad.imageUrls,
        status: status,
        createdAt: ad.createdAt,
        reviewedAt: DateTime.now(),
        startDate: startDate ?? ad.startDate,
        endDate: endDate ?? ad.endDate,
        adminNote: adminNote ?? ad.adminNote,
        rejectionReason: rejectionReason ?? ad.rejectionReason,
        statistics: ad.statistics,
      );

      await _adsBox!.put(adId, updatedAd);

      // تحديث القائمة المحلية
      final index = ads.indexWhere((a) => a.id == adId);
      if (index != -1) {
        ads[index] = updatedAd;
        ads.refresh();
      }

      return true;
    } catch (e) {
      print('Error updating ad status: $e');
      return false;
    }
  }

  // تحديث إحصائيات الإعلان (للباك اند)
  Future<bool> updateAdStatistics({
    required String adId,
    required Map<String, dynamic> statistics,
  }) async {
    try {
      if (_adsBox == null) {
        print('⚠️ Ads box not initialized yet');
        return false;
      }

      final ad = _adsBox!.get(adId);
      if (ad == null) return false;

      final updatedAd = SponsoredAdModel(
        id: ad.id,
        userId: ad.userId,
        title: ad.title,
        description: ad.description,
        adType: ad.adType,
        platforms: ad.platforms,
        objective: ad.objective,
        budget: ad.budget,
        durationDays: ad.durationDays,
        targetAudience: ad.targetAudience,
        websiteUrl: ad.websiteUrl,
        callToAction: ad.callToAction,
        imageUrls: ad.imageUrls,
        status: ad.status,
        createdAt: ad.createdAt,
        reviewedAt: ad.reviewedAt,
        startDate: ad.startDate,
        endDate: ad.endDate,
        adminNote: ad.adminNote,
        rejectionReason: ad.rejectionReason,
        statistics: statistics,
      );

      await _adsBox!.put(adId, updatedAd);

      // تحديث القائمة المحلية
      final index = ads.indexWhere((a) => a.id == adId);
      if (index != -1) {
        ads[index] = updatedAd;
        ads.refresh();
      }

      return true;
    } catch (e) {
      print('Error updating ad statistics: $e');
      return false;
    }
  }

  // إلغاء إعلان
  Future<bool> cancelAd(String adId) async {
    try {
      return await updateAdStatus(
        adId: adId,
        status: AdStatus.cancelled,
      );
    } catch (e) {
      print('Error cancelling ad: $e');
      return false;
    }
  }

  // حذف إعلان
  Future<bool> deleteAd(String adId) async {
    try {
      if (_adsBox == null) {
        print('⚠️ Ads box not initialized yet');
        return false;
      }

      await _adsBox!.delete(adId);
      ads.removeWhere((ad) => ad.id == adId);
      return true;
    } catch (e) {
      print('Error deleting ad: $e');
      return false;
    }
  }

  // الحصول على عدد الإعلانات حسب الحالة
  int getAdCountByStatus(AdStatus status) {
    return ads.where((ad) => ad.status == status).length;
  }

  // الحصول على إجمالي الميزانية المنفقة
  double get totalBudget {
    return ads.fold(0.0, (sum, ad) => sum + ad.budget);
  }

  // الحصول على إجمالي الميزانية للإعلانات النشطة
  double get activeBudget {
    return ads
        .where((ad) => ad.status == AdStatus.active)
        .fold(0.0, (sum, ad) => sum + ad.budget);
  }

  // الحصول على عدد الإعلانات المعلقة
  int get pendingAdsCount => getAdCountByStatus(AdStatus.pending);

  // الحصول على عدد الإعلانات قيد المراجعة
  int get underReviewAdsCount => getAdCountByStatus(AdStatus.underReview);

  // الحصول على عدد الإعلانات النشطة
  int get activeAdsCount => getAdCountByStatus(AdStatus.active);

  // الحصول على عدد الإعلانات المكتملة
  int get completedAdsCount => getAdCountByStatus(AdStatus.completed);

  // الحصول على عدد الإعلانات المرفوضة
  int get rejectedAdsCount => getAdCountByStatus(AdStatus.rejected);

  // محاكاة موافقة من الباك اند (للاختبار فقط)
  Future<void> simulateApproval(String adId) async {
    if (_adsBox == null) {
      print('⚠️ Ads box not initialized yet');
      return;
    }

    final ad = _adsBox!.get(adId);
    if (ad == null) return;

    // تغيير الحالة إلى "قيد المراجعة" بعد ثانيتين
    await Future.delayed(const Duration(seconds: 2));
    await updateAdStatus(
      adId: adId,
      status: AdStatus.underReview,
      adminNote: 'يتم مراجعة طلبك من قبل فريق الدعم',
    );

    // تغيير الحالة إلى "مقبول" بعد 5 ثواني
    await Future.delayed(const Duration(seconds: 5));
    final startDate = DateTime.now().add(const Duration(days: 1));
    final endDate = startDate.add(Duration(days: ad.durationDays));

    await updateAdStatus(
      adId: adId,
      status: AdStatus.approved,
      adminNote: 'تم قبول طلبك! سيبدأ الإعلان قريباً',
      startDate: startDate,
      endDate: endDate,
    );

    // تغيير الحالة إلى "نشط" بعد 3 ثواني
    await Future.delayed(const Duration(seconds: 3));
    await updateAdStatus(
      adId: adId,
      status: AdStatus.active,
      adminNote: 'إعلانك نشط الآن!',
    );

    // إضافة إحصائيات تجريبية
    await updateAdStatistics(
      adId: adId,
      statistics: {
        'impressions': 1250,
        'clicks': 87,
        'ctr': 6.96,
        'conversions': 12,
        'spend': ad.budget * 0.3,
      },
    );
  }
}
