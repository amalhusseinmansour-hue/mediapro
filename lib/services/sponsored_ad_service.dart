import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/sponsored_ad_request_model.dart';
import 'http_service.dart';

/// خدمة إدارة طلبات الإعلانات الممولة
class SponsoredAdService extends GetxController {
  final HttpService _httpService = HttpService();
  final Logger _logger = Logger();

  final RxBool isLoading = false.obs;
  final RxList<SponsoredAdRequestModel> requests = <SponsoredAdRequestModel>[].obs;

  /// إرسال طلب إعلان ممول جديد
  Future<bool> submitRequest(SponsoredAdRequestModel request) async {
    try {
      isLoading.value = true;
      _logger.i('📤 إرسال طلب إعلان ممول...');

      final response = await _httpService.post(
        'sponsored-ad-requests',
        body: request.toJson(),
      );

      if (response['success'] == true) {
        _logger.i('✅ تم حفظ طلب الإعلان الممول في قاعدة البيانات');
        return true;
      } else {
        _logger.e('❌ فشل حفظ طلب الإعلان الممول: ${response['message']}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ خطأ في إرسال طلب الإعلان الممول: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على جميع طلبات المستخدم
  Future<List<SponsoredAdRequestModel>> getMyRequests() async {
    try {
      isLoading.value = true;
      _logger.i('📥 جلب طلبات الإعلانات الممولة...');

      final response = await _httpService.get('sponsored-ad-requests');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data']['data'] ?? [];
        requests.value = data
            .map((json) => SponsoredAdRequestModel.fromJson(json))
            .toList();
        _logger.i('✅ تم جلب ${requests.length} طلب');
        return requests;
      } else {
        _logger.w('⚠️ لا توجد طلبات');
        return [];
      }
    } catch (e) {
      _logger.e('❌ خطأ في جلب الطلبات: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على طلب محدد
  Future<SponsoredAdRequestModel?> getRequest(int id) async {
    try {
      _logger.i('📥 جلب طلب الإعلان #$id...');

      final response = await _httpService.get('sponsored-ad-requests/$id');

      if (response['success'] == true && response['data'] != null) {
        _logger.i('✅ تم جلب الطلب');
        return SponsoredAdRequestModel.fromJson(response['data']);
      } else {
        _logger.w('⚠️ الطلب غير موجود');
        return null;
      }
    } catch (e) {
      _logger.e('❌ خطأ في جلب الطلب: $e');
      return null;
    }
  }

  /// حذف طلب
  Future<bool> deleteRequest(int id) async {
    try {
      _logger.i('🗑️ حذف طلب الإعلان #$id...');

      final response = await _httpService.delete('sponsored-ad-requests/$id');

      if (response['success'] == true) {
        _logger.i('✅ تم حذف الطلب');
        requests.removeWhere((req) => req.id == id);
        return true;
      } else {
        _logger.e('❌ فشل حذف الطلب');
        return false;
      }
    } catch (e) {
      _logger.e('❌ خطأ في حذف الطلب: $e');
      return false;
    }
  }

  /// الحصول على إحصائيات الطلبات
  Future<Map<String, dynamic>?> getStatistics() async {
    try {
      _logger.i('📊 جلب إحصائيات الإعلانات الممولة...');

      final response = await _httpService.get('sponsored-ad-requests/statistics');

      if (response['success'] == true && response['data'] != null) {
        _logger.i('✅ تم جلب الإحصائيات');
        return response['data'];
      } else {
        return null;
      }
    } catch (e) {
      _logger.e('❌ خطأ في جلب الإحصائيات: $e');
      return null;
    }
  }
}
