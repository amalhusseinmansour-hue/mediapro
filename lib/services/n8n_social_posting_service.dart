import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'laravel_api_service.dart';

/// N8N Social Media Posting Service
/// يستخدم Laravel Backend + N8N Automation
/// يدعم 4 منصات: Facebook, Twitter, Instagram, LinkedIn
class N8nSocialPostingService extends GetxController {
  final LaravelApiService _api = Get.find();

  /// نشر على منصات متعددة تلقائياً
  Future<Map<String, dynamic>> postToMultiplePlatforms({
    required String content,
    required List<String> platforms, // facebook, twitter, instagram, linkedin
    File? mediaFile,
    String? mediaUrl,
    String? mediaType, // text, image, video
    String? link,
    DateTime? scheduledAt,
  }) async {
    try {
      // 1. رفع الصورة/الفيديو إذا كان موجوداً
      List<String>? mediaPaths;
      if (mediaFile != null) {
        final uploadResult = await _uploadMedia(mediaFile);
        if (uploadResult['success']) {
          mediaPaths = [uploadResult['data']['path']];
        }
      } else if (mediaUrl != null) {
        mediaPaths = [mediaUrl];
      }

      // 2. إنشاء المنشور في Laravel
      final response = await _api.post('/social-posts', {
        'content': content,
        'platforms': platforms,
        'media_type': mediaType ?? 'text',
        'media': mediaPaths,
        'link': link,
        'status': scheduledAt != null ? 'scheduled' : 'published',
        'scheduled_at': scheduledAt?.toIso8601String(),
      });

      if (response['success'] == true) {
        // Observer سيقوم بالنشر تلقائياً!
        return {
          'success': true,
          'message': scheduledAt != null ? 'تم جدولة المنشور' : 'جاري النشر على ${platforms.length} منصة...',
          'post': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'فشل في إنشاء المنشور',
        };
      }
    } catch (e) {
      print('❌ N8nSocialPostingService Error: $e');
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// رفع صورة أو فيديو
  Future<Map<String, dynamic>> _uploadMedia(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${LaravelApiService.baseUrl}/social-posts/upload-media'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${_api.authToken.value}',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      return data;
    } catch (e) {
      print('❌ Media Upload Error: $e');
      return {
        'success': false,
        'message': 'فشل رفع الملف: $e',
      };
    }
  }

  /// الحصول على تاريخ المنشورات
  Future<List<dynamic>> getPostHistory({int page = 1}) async {
    try {
      final response = await _api.get('/social-posts?page=$page');
      if (response['success'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('❌ Get Post History Error: $e');
      return [];
    }
  }

  /// الحصول على منشور واحد
  Future<Map<String, dynamic>?> getPost(int postId) async {
    try {
      final response = await _api.get('/social-posts/$postId');
      if (response['success'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('❌ Get Post Error: $e');
      return null;
    }
  }

  /// إعادة محاولة منشور فاشل
  Future<Map<String, dynamic>> retryPost(int postId) async {
    try {
      final response = await _api.post('/social-posts/$postId/retry', {});
      return response;
    } catch (e) {
      print('❌ Retry Post Error: $e');
      return {
        'success': false,
        'message': 'فشلت إعادة المحاولة: $e',
      };
    }
  }

  /// حذف منشور
  Future<bool> deletePost(int postId) async {
    try {
      final response = await _api.delete('/social-posts/$postId');
      return response['success'] == true;
    } catch (e) {
      print('❌ Delete Post Error: $e');
      return false;
    }
  }

  /// احصائيات النشر
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _api.get('/social-posts/stats');
      if (response['success'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('❌ Get Stats Error: $e');
      return null;
    }
  }

  /// نموذج بيانات المنصة
  static Map<String, Map<String, String>> getPlatformInfo() {
    return {
      'facebook': {
        'name': 'Facebook',
        'displayName': 'فيسبوك',
        'icon': '📘',
        'color': '1877F2',
      },
      'twitter': {
        'name': 'Twitter/X',
        'displayName': 'تويتر',
        'icon': '🐦',
        'color': '1DA1F2',
      },
      'instagram': {
        'name': 'Instagram',
        'displayName': 'انستقرام',
        'icon': '📷',
        'color': 'E4405F',
      },
      'linkedin': {
        'name': 'LinkedIn',
        'displayName': 'لينكد إن',
        'icon': '💼',
        'color': '0A66C2',
      },
    };
  }
}
