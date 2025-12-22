import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../core/config/backend_config.dart';
import 'api_service.dart';

/// خدمة التحقق من حسابات الشركات
/// تدير رفع المستندات التجارية (السجل التجاري والرخصة التجارية)
/// ملاحظة: قبول ورفض الطلبات يتم من خلال Filament Admin Panel في Laravel
class BusinessVerificationService extends GetxController {
  static String get baseUrl => BackendConfig.baseUrl;

  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// رفع السجل التجاري
  Future<String?> uploadCommercialRegistration(File file) async {
    return await _uploadDocument(file, 'commercial_registration');
  }

  /// رفع الرخصة التجارية
  Future<String?> uploadTradeLicense(File file) async {
    return await _uploadDocument(file, 'trade_license');
  }

  /// رفع مستند (عام)
  Future<String?> _uploadDocument(File file, String documentType) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📤 Uploading $documentType...');

      final uri = Uri.parse('$baseUrl/api/v1/business/upload-document');
      final request = http.MultipartRequest('POST', uri);

      // إضافة التوكن
      final token = _apiService.authToken;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // إضافة نوع المستند
      request.fields['document_type'] = documentType;

      // إضافة الملف
      final fileName = path.basename(file.path);
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        'document',
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final documentUrl = data['url'] ?? data['document_url'];
        print('✅ $documentType uploaded successfully: $documentUrl');
        return documentUrl;
      } else {
        final errorData = json.decode(response.body);
        errorMessage.value = errorData['message'] ?? 'فشل رفع المستند';
        print('❌ Failed to upload $documentType: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading document: $e');
      errorMessage.value = 'حدث خطأ أثناء رفع المستند: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// تقديم طلب التحقق من حساب الشركة
  /// سيتم مراجعة الطلب من Filament Admin Panel
  Future<Map<String, dynamic>> submitVerificationRequest({
    required String companyName,
    required String commercialRegistrationUrl,
    required String tradeLicenseUrl,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📤 Submitting business verification request...');

      final response = await _apiService.post(
        '/api/v1/business/verify',
        data: {
          'company_name': companyName,
          'commercial_registration': commercialRegistrationUrl,
          'trade_license': tradeLicenseUrl,
        },
      );

      if (response['success'] == true) {
        print('✅ Verification request submitted successfully');
        return {
          'success': true,
          'message': response['message'] ?? 'تم تقديم طلب التحقق بنجاح. سيتم مراجعته من قبل الإدارة',
          'status': 'pending',
        };
      } else {
        errorMessage.value = response['message'] ?? 'فشل تقديم طلب التحقق';
        return {
          'success': false,
          'message': errorMessage.value,
        };
      }
    } catch (e) {
      print('❌ Error submitting verification request: $e');
      errorMessage.value = 'حدث خطأ أثناء تقديم الطلب: $e';
      return {
        'success': false,
        'message': errorMessage.value,
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على حالة التحقق من المستندات
  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get('/api/v1/business/verification-status');

      if (response['success'] == true) {
        return {
          'success': true,
          'status': response['data']?['status'] ?? 'none',
          'company_name': response['data']?['company_name'],
          'rejection_reason': response['data']?['rejection_reason'],
          'verified_at': response['data']?['verified_at'],
        };
      } else {
        return {
          'success': false,
          'status': 'none',
        };
      }
    } catch (e) {
      print('❌ Error getting verification status: $e');
      return {
        'success': false,
        'status': 'none',
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على حالة الحساب (تفعيل الحساب من الأدمن)
  Future<Map<String, dynamic>> getAccountStatus() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get('/api/v1/account/status');

      if (response['success'] == true) {
        return {
          'success': true,
          'account_status': response['data']?['account_status'] ?? 'pending',
          'account_rejection_reason': response['data']?['account_rejection_reason'],
          'account_activated_at': response['data']?['account_activated_at'],
          'business_verification_status': response['data']?['business_verification_status'] ?? 'none',
          'verification_rejection_reason': response['data']?['verification_rejection_reason'],
        };
      } else {
        return {
          'success': false,
          'account_status': 'pending',
        };
      }
    } catch (e) {
      print('❌ Error getting account status: $e');
      return {
        'success': false,
        'account_status': 'pending',
      };
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // Admin Methods (للمشرفين فقط)
  // =====================================================

  /// الحصول على جميع طلبات التحقق (للمشرفين)
  Future<List<Map<String, dynamic>>> getAllVerifications({String? status}) async {
    try {
      isLoading.value = true;

      String endpoint = '/api/admin/business-verifications';
      if (status != null && status.isNotEmpty) {
        endpoint += '?status=$status';
      }

      final response = await _apiService.get(endpoint);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting verifications: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// الموافقة على طلب التحقق (للمشرفين)
  Future<bool> approveVerification(String verificationId) async {
    try {
      isLoading.value = true;

      final response = await _apiService.post(
        '/api/admin/business-verifications/$verificationId/approve',
        data: {},
      );

      if (response['success'] == true) {
        print('✅ Verification approved successfully');
        return true;
      }
      errorMessage.value = response['message'] ?? 'فشل الموافقة على الطلب';
      return false;
    } catch (e) {
      print('❌ Error approving verification: $e');
      errorMessage.value = 'حدث خطأ أثناء الموافقة: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// رفض طلب التحقق (للمشرفين)
  Future<bool> rejectVerification(String verificationId, {String? reason}) async {
    try {
      isLoading.value = true;

      final response = await _apiService.post(
        '/api/admin/business-verifications/$verificationId/reject',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      if (response['success'] == true) {
        print('✅ Verification rejected successfully');
        return true;
      }
      errorMessage.value = response['message'] ?? 'فشل رفض الطلب';
      return false;
    } catch (e) {
      print('❌ Error rejecting verification: $e');
      errorMessage.value = 'حدث خطأ أثناء الرفض: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// إعادة تقديم طلب التحقق (بعد الرفض)
  Future<Map<String, dynamic>> resubmitVerification({
    required String companyName,
    required String commercialRegistrationUrl,
    required String tradeLicenseUrl,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📤 Resubmitting business verification request...');

      final response = await _apiService.post(
        '/api/v1/business/resubmit-verification',
        data: {
          'company_name': companyName,
          'commercial_registration': commercialRegistrationUrl,
          'trade_license': tradeLicenseUrl,
        },
      );

      if (response['success'] == true) {
        print('✅ Verification resubmitted successfully');
        return {
          'success': true,
          'message': response['message'] ?? 'تم إعادة تقديم طلب التحقق بنجاح. سيتم مراجعته من قبل الإدارة',
          'status': 'pending',
        };
      } else {
        errorMessage.value = response['message'] ?? 'فشل إعادة تقديم طلب التحقق';
        return {
          'success': false,
          'message': errorMessage.value,
        };
      }
    } catch (e) {
      print('❌ Error resubmitting verification: $e');
      errorMessage.value = 'حدث خطأ أثناء إعادة تقديم الطلب: $e';
      return {
        'success': false,
        'message': errorMessage.value,
      };
    } finally {
      isLoading.value = false;
    }
  }
}
