import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/config/api_config.dart';
import 'auth_service.dart';

/// Canva Service - خدمة تكامل Canva للتصميم
/// تدعم إنشاء وتحرير وتصدير التصميمات
class CanvaService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  // حالة الخدمة
  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxBool isConfigured = false.obs;
  final RxBool isConnected = false.obs;

  // بيانات التصميم
  final RxMap<String, int> dimensions = <String, int>{}.obs;
  final RxMap<String, String> categories = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    checkStatus();
  }

  /// الحصول على headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${_authService.currentUser.value?.id ?? ''}',
  };

  /// فحص حالة الخدمة
  Future<void> checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        isConfigured.value = data['configured'] ?? false;

        if (data['dimensions'] != null) {
          dimensions.value = Map<String, int>.from(
            (data['dimensions'] as Map).map((key, value) =>
              MapEntry(key.toString(), value['width'] as int)
            )
          );
        }

        if (data['categories'] != null) {
          categories.value = Map<String, String>.from(data['categories']);
        }
      }
    } catch (e) {
      print('Error checking Canva status: $e');
    }
  }

  /// الحصول على رابط التفويض OAuth
  Future<String?> getAuthorizationUrl() async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/authorize'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['authorization_url'];
      } else {
        throw Exception(data['error'] ?? 'Failed to get authorization URL');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// فتح صفحة التفويض
  Future<bool> openAuthorizationPage() async {
    final url = await getAuthorizationUrl();
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    }
    return false;
  }

  /// الحصول على ملف المستخدم
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/profile'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        isConnected.value = true;
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to get profile');
      }
    } catch (e) {
      lastError.value = e.toString();
      isConnected.value = false;
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على قائمة التصميمات
  Future<List<Map<String, dynamic>>> listDesigns({int limit = 50}) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/designs?limit=$limit'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['designs'] ?? []);
      } else {
        throw Exception(data['error'] ?? 'Failed to list designs');
      }
    } catch (e) {
      lastError.value = e.toString();
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على تصميم محدد
  Future<Map<String, dynamic>?> getDesign(String designId) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/designs/$designId'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to get design');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء تصميم جديد
  Future<Map<String, dynamic>?> createDesign({
    required String type,
    String? title,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/designs'),
        headers: _headers,
        body: json.encode({
          'type': type,
          'title': title,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create design');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء تصميم سريع لسوشال ميديا
  Future<Map<String, dynamic>?> quickCreate({
    required String platform,
    required String contentType,
    String? title,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/designs/quick-create'),
        headers: _headers,
        body: json.encode({
          'platform': platform,
          'content_type': contentType,
          'title': title,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to quick create design');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء تصميم من قالب
  Future<Map<String, dynamic>?> createFromTemplate({
    required String templateId,
    String? title,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/designs/from-template'),
        headers: _headers,
        body: json.encode({
          'template_id': templateId,
          'title': title,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create from template');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// البحث عن قوالب
  Future<List<Map<String, dynamic>>> searchTemplates({
    String? query,
    String? type,
    int limit = 20,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final params = <String, String>{
        'limit': limit.toString(),
      };
      if (query != null) params['query'] = query;
      if (type != null) params['type'] = type;

      final uri = Uri.parse('${ApiConfig.backendBaseUrl}/canva/templates')
          .replace(queryParameters: params);

      final response = await http.get(uri, headers: _headers);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['templates'] ?? []);
      } else {
        throw Exception(data['error'] ?? 'Failed to search templates');
      }
    } catch (e) {
      lastError.value = e.toString();
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// تصدير تصميم
  Future<String?> exportDesign(String designId, {
    String format = 'png',
    String quality = 'regular',
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/designs/$designId/export-download'),
        headers: _headers,
        body: json.encode({
          'format': format,
          'quality': quality,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['download_url'];
      } else {
        throw Exception(data['error'] ?? 'Failed to export design');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// رفع أصل (صورة/فيديو)
  Future<Map<String, dynamic>?> uploadAsset(File file, {String? name}) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/assets'),
      );

      request.headers.addAll(_headers);
      request.fields['name'] = name ?? file.path.split('/').last;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to upload asset');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// رفع أصل من رابط
  Future<Map<String, dynamic>?> uploadAssetFromUrl(String url, {String? name}) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/assets/from-url'),
        headers: _headers,
        body: json.encode({
          'url': url,
          'name': name,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to upload asset from URL');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على المجلدات
  Future<List<Map<String, dynamic>>> listFolders({int limit = 50}) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/folders?limit=$limit'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['folders'] ?? []);
      } else {
        throw Exception(data['error'] ?? 'Failed to list folders');
      }
    } catch (e) {
      lastError.value = e.toString();
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء مجلد
  Future<Map<String, dynamic>?> createFolder(String name, {String? parentId}) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/canva/folders'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'parent_id': parentId,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to create folder');
      }
    } catch (e) {
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// فتح تصميم في محرر Canva
  Future<bool> openInCanva(String designId) async {
    final editUrl = 'https://www.canva.com/design/$designId/edit';
    final uri = Uri.parse(editUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// الحصول على أبعاد التصميم المتاحة
  static Map<String, Map<String, int>> getDesignDimensions() {
    return {
      'instagram_post': {'width': 1080, 'height': 1080},
      'instagram_story': {'width': 1080, 'height': 1920},
      'instagram_reel': {'width': 1080, 'height': 1920},
      'facebook_post': {'width': 1200, 'height': 630},
      'facebook_cover': {'width': 820, 'height': 312},
      'facebook_story': {'width': 1080, 'height': 1920},
      'twitter_post': {'width': 1200, 'height': 675},
      'twitter_header': {'width': 1500, 'height': 500},
      'linkedin_post': {'width': 1200, 'height': 627},
      'linkedin_banner': {'width': 1584, 'height': 396},
      'youtube_thumbnail': {'width': 1280, 'height': 720},
      'tiktok_video': {'width': 1080, 'height': 1920},
      'pinterest_pin': {'width': 1000, 'height': 1500},
    };
  }

  /// الحصول على أنواع التصميم لكل منصة
  static List<Map<String, String>> getDesignTypesForPlatform(String platform) {
    switch (platform) {
      case 'instagram':
        return [
          {'id': 'instagram_post', 'name': 'منشور', 'name_en': 'Post'},
          {'id': 'instagram_story', 'name': 'قصة', 'name_en': 'Story'},
          {'id': 'instagram_reel', 'name': 'غلاف ريل', 'name_en': 'Reel Cover'},
        ];
      case 'facebook':
        return [
          {'id': 'facebook_post', 'name': 'منشور', 'name_en': 'Post'},
          {'id': 'facebook_cover', 'name': 'غلاف', 'name_en': 'Cover'},
          {'id': 'facebook_story', 'name': 'قصة', 'name_en': 'Story'},
        ];
      case 'twitter':
        return [
          {'id': 'twitter_post', 'name': 'منشور', 'name_en': 'Post'},
          {'id': 'twitter_header', 'name': 'هيدر', 'name_en': 'Header'},
        ];
      case 'linkedin':
        return [
          {'id': 'linkedin_post', 'name': 'منشور', 'name_en': 'Post'},
          {'id': 'linkedin_banner', 'name': 'بانر', 'name_en': 'Banner'},
        ];
      case 'youtube':
        return [
          {'id': 'youtube_thumbnail', 'name': 'صورة مصغرة', 'name_en': 'Thumbnail'},
        ];
      case 'tiktok':
        return [
          {'id': 'tiktok_video', 'name': 'فيديو', 'name_en': 'Video'},
        ];
      case 'pinterest':
        return [
          {'id': 'pinterest_pin', 'name': 'بن', 'name_en': 'Pin'},
        ];
      default:
        return [];
    }
  }
}
