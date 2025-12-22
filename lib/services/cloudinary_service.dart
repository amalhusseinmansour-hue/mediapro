import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../core/config/env_config.dart';
import 'http_service.dart';

/// Cloudinary Service for Image Editing and Transformations
/// Provides powerful image manipulation capabilities
class CloudinaryService extends GetxService {
  final RxBool isProcessing = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxString status = ''.obs;

  // Cloudinary configuration
  String get _cloudName => EnvConfig.cloudinaryCloudName;
  String get _apiKey => EnvConfig.cloudinaryApiKey;
  String get _apiSecret => EnvConfig.cloudinaryApiSecret;
  String get _uploadPreset => EnvConfig.cloudinaryUploadPreset;

  // Base URLs
  String get _uploadUrl => 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
  String get _transformUrl => 'https://res.cloudinary.com/$_cloudName/image/upload';

  // Check if configured
  bool get isConfigured => _cloudName.isNotEmpty && _apiKey.isNotEmpty;

  // HttpService for backend calls
  HttpService? get _httpService {
    try {
      return Get.find<HttpService>();
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('🖼️ Cloudinary Service initialized');
    if (isConfigured) {
      print('✅ Cloudinary is configured: $_cloudName');
    } else {
      print('⚠️ Cloudinary not configured - will use backend');
    }
  }

  /// Upload image to Cloudinary
  Future<Map<String, dynamic>> uploadImage(File imageFile, {String? folder}) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري رفع الصورة...';
      progress.value = 0.1;

      // Try backend first (recommended for security)
      final httpService = _httpService;
      if (httpService != null) {
        return await _uploadViaBackend(imageFile, folder: folder);
      }

      // Direct upload if backend not available
      if (!isConfigured) {
        return {'success': false, 'message': 'Cloudinary غير مُعَدّ'};
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Create signature for authenticated upload
      final signature = _generateSignature(timestamp, folder: folder);

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      if (folder != null) request.fields['folder'] = folder;

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      progress.value = 0.5;
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        progress.value = 1.0;
        return {
          'success': true,
          'public_id': data['public_id'],
          'url': data['secure_url'],
          'width': data['width'],
          'height': data['height'],
        };
      }

      return {'success': false, 'message': 'فشل رفع الصورة: ${response.statusCode}'};
    } catch (e) {
      print('❌ Upload error: $e');
      return {'success': false, 'message': 'خطأ في رفع الصورة: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
      progress.value = 0.0;
    }
  }

  /// Upload directly to Cloudinary (no backend)
  Future<Map<String, dynamic>> _uploadDirectToCloudinary(File imageFile, {String? folder}) async {
    try {
      if (!isConfigured) {
        return {'success': false, 'message': 'Cloudinary غير مُعَدّ'};
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final bytes = await imageFile.readAsBytes();

      // Create signature for authenticated upload
      final signature = _generateSignature(timestamp, folder: folder);

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      if (folder != null) request.fields['folder'] = folder;

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      progress.value = 0.5;
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return {
          'success': true,
          'public_id': data['public_id'],
          'url': data['secure_url'],
          'width': data['width'],
          'height': data['height'],
        };
      }

      print('❌ Cloudinary upload failed: ${response.statusCode} - $responseBody');
      return {'success': false, 'message': 'فشل رفع الصورة: ${response.statusCode}'};
    } catch (e) {
      print('❌ Direct upload error: $e');
      return {'success': false, 'message': 'خطأ في رفع الصورة: $e'};
    }
  }

  /// Upload via backend (secure method)
  Future<Map<String, dynamic>> _uploadViaBackend(File imageFile, {String? folder}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _httpService!.post(
        '/cloudinary/upload',
        body: {
          'image': base64Image,
          'folder': folder ?? 'social_media',
        },
      );

      if (response['success'] == true) {
        return response;
      }
      return {'success': false, 'message': response['message'] ?? 'فشل الرفع'};
    } catch (e) {
      print('❌ Backend upload error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر'};
    }
  }

  /// Apply transformations to an image
  /// Returns the URL of the transformed image
  String transformImage(String publicId, List<String> transformations) {
    final transformString = transformations.join('/');
    return '$_transformUrl/$transformString/$publicId';
  }

  /// Remove background from image
  Future<Map<String, dynamic>> removeBackground(File imageFile) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري إزالة الخلفية...';
      progress.value = 0.1;

      // Upload first
      final uploadResult = await uploadImage(imageFile, folder: 'bg_remove');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      progress.value = 0.5;
      final publicId = uploadResult['public_id'];

      // Apply background removal transformation
      final transformedUrl = transformImage(publicId, ['e_background_removal']);

      progress.value = 1.0;
      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'message': 'تم إزالة الخلفية بنجاح',
      };
    } catch (e) {
      print('❌ Background removal error: $e');
      return {'success': false, 'message': 'فشل إزالة الخلفية: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
      progress.value = 0.0;
    }
  }

  /// Apply filters to image
  Future<Map<String, dynamic>> applyFilter(File imageFile, String filterName) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري تطبيق الفلتر...';
      progress.value = 0.1;

      // Use direct Cloudinary API (backend route not available)
      final uploadResult = await _uploadDirectToCloudinary(imageFile, folder: 'filters');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      progress.value = 0.5;
      final publicId = uploadResult['public_id'];

      // Get filter transformation
      final filterTransform = _getFilterTransformation(filterName);
      final transformedUrl = transformImage(publicId, filterTransform);

      progress.value = 1.0;
      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'filter': filterName,
        'message': 'تم تطبيق الفلتر بنجاح',
      };
    } catch (e) {
      print('❌ Filter error: $e');
      return {'success': false, 'message': 'فشل تطبيق الفلتر: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
      progress.value = 0.0;
    }
  }

  /// Apply filter via Backend API
  Future<Map<String, dynamic>> _applyFilterViaBackend(File imageFile, String filterName) async {
    try {
      progress.value = 0.2;

      // First upload the image
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      progress.value = 0.4;

      // Call backend filter endpoint
      final response = await _httpService!.post(
        '/cloudinary/filter',
        body: {
          'image': base64Image,
          'filter': filterName,
        },
      );

      progress.value = 0.9;

      if (response['success'] == true) {
        progress.value = 1.0;
        return {
          'success': true,
          'original_url': response['data']?['original_url'],
          'edited_url': response['data']?['filtered_url'] ?? response['data']?['edited_url'],
          'filter': filterName,
          'message': 'تم تطبيق الفلتر بنجاح',
        };
      }

      return {'success': false, 'message': response['message'] ?? 'فشل تطبيق الفلتر'};
    } catch (e) {
      print('❌ Backend filter error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر: $e'};
    }
  }

  /// Apply filter to image URL (without uploading)
  /// Note: This works only for images already on Cloudinary
  Future<Map<String, dynamic>> applyFilterToUrl(String imageUrl, String filterName) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري تطبيق الفلتر...';
      progress.value = 0.1;

      // Check if this is a Cloudinary URL
      if (imageUrl.contains('cloudinary.com') && imageUrl.contains(_cloudName)) {
        progress.value = 0.3;

        // Extract public_id from URL
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        final uploadIndex = pathSegments.indexOf('upload');
        if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
          // Get everything after 'upload' and version (if present)
          var publicIdParts = pathSegments.sublist(uploadIndex + 1);
          // Remove version if present (starts with 'v')
          if (publicIdParts.isNotEmpty && publicIdParts[0].startsWith('v') && publicIdParts[0].length > 1) {
            publicIdParts = publicIdParts.sublist(1);
          }
          final publicId = publicIdParts.join('/').replaceAll(RegExp(r'\.[^.]+$'), '');

          // Get filter transformation
          final filterTransform = _getFilterTransformation(filterName);
          final transformedUrl = transformImage(publicId, filterTransform);

          progress.value = 1.0;
          return {
            'success': true,
            'original_url': imageUrl,
            'edited_url': transformedUrl,
            'filter': filterName,
            'message': 'تم تطبيق الفلتر بنجاح',
          };
        }
      }

      // If not a Cloudinary URL, download and re-upload
      progress.value = 0.3;
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final tempFile = File('${directory.path}/temp_filter_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);

        progress.value = 0.5;
        final result = await applyFilter(tempFile, filterName);

        // Clean up temp file
        try {
          await tempFile.delete();
        } catch (_) {}

        return result;
      }

      return {'success': false, 'message': 'فشل تحميل الصورة من الرابط'};
    } catch (e) {
      print('❌ Filter URL error: $e');
      return {'success': false, 'message': 'فشل تطبيق الفلتر: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
      progress.value = 0.0;
    }
  }

  /// Enhance image quality
  Future<Map<String, dynamic>> enhanceImage(File imageFile) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري تحسين الصورة...';
      progress.value = 0.1;

      final uploadResult = await uploadImage(imageFile, folder: 'enhanced');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      progress.value = 0.5;
      final publicId = uploadResult['public_id'];

      // Apply enhancement transformations
      final transformedUrl = transformImage(publicId, [
        'e_improve',
        'e_sharpen:100',
        'e_auto_brightness',
        'e_auto_contrast',
        'q_auto:best',
      ]);

      progress.value = 1.0;
      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'message': 'تم تحسين الصورة بنجاح',
      };
    } catch (e) {
      print('❌ Enhancement error: $e');
      return {'success': false, 'message': 'فشل تحسين الصورة: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
      progress.value = 0.0;
    }
  }

  /// Resize image
  Future<Map<String, dynamic>> resizeImage(
    File imageFile, {
    required int width,
    required int height,
    String crop = 'fill',
  }) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري تغيير حجم الصورة...';

      final uploadResult = await uploadImage(imageFile, folder: 'resized');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      final publicId = uploadResult['public_id'];
      final transformedUrl = transformImage(publicId, [
        'c_$crop,w_$width,h_$height',
        'q_auto:best',
      ]);

      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'width': width,
        'height': height,
        'message': 'تم تغيير الحجم بنجاح',
      };
    } catch (e) {
      print('❌ Resize error: $e');
      return {'success': false, 'message': 'فشل تغيير الحجم: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
    }
  }

  /// Add text overlay to image
  Future<Map<String, dynamic>> addTextOverlay(
    File imageFile, {
    required String text,
    String fontFamily = 'Arial',
    int fontSize = 40,
    String color = 'white',
    String gravity = 'south',
  }) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري إضافة النص...';

      final uploadResult = await uploadImage(imageFile, folder: 'text_overlay');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      final publicId = uploadResult['public_id'];
      final encodedText = Uri.encodeComponent(text);

      final transformedUrl = transformImage(publicId, [
        'l_text:$fontFamily\_$fontSize:$encodedText,co_$color,g_$gravity,y_20',
      ]);

      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'message': 'تم إضافة النص بنجاح',
      };
    } catch (e) {
      print('❌ Text overlay error: $e');
      return {'success': false, 'message': 'فشل إضافة النص: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
    }
  }

  /// Create rounded corners
  Future<Map<String, dynamic>> roundCorners(File imageFile, {int radius = 50}) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري تدوير الزوايا...';

      final uploadResult = await uploadImage(imageFile, folder: 'rounded');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      final publicId = uploadResult['public_id'];
      final transformedUrl = transformImage(publicId, ['r_$radius']);

      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'message': 'تم تدوير الزوايا بنجاح',
      };
    } catch (e) {
      print('❌ Round corners error: $e');
      return {'success': false, 'message': 'فشل تدوير الزوايا: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
    }
  }

  /// Apply blur effect
  Future<Map<String, dynamic>> blurImage(File imageFile, {int strength = 500}) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري تطبيق الضبابية...';

      final uploadResult = await uploadImage(imageFile, folder: 'blurred');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      final publicId = uploadResult['public_id'];
      final transformedUrl = transformImage(publicId, ['e_blur:$strength']);

      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'message': 'تم تطبيق الضبابية بنجاح',
      };
    } catch (e) {
      print('❌ Blur error: $e');
      return {'success': false, 'message': 'فشل تطبيق الضبابية: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
    }
  }

  /// Create thumbnail
  Future<Map<String, dynamic>> createThumbnail(
    File imageFile, {
    int size = 150,
  }) async {
    try {
      final uploadResult = await uploadImage(imageFile, folder: 'thumbnails');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      final publicId = uploadResult['public_id'];
      final transformedUrl = transformImage(publicId, [
        'c_thumb,g_face,w_$size,h_$size',
        'r_max',
        'q_auto:good',
      ]);

      return {
        'success': true,
        'original_url': uploadResult['url'],
        'thumbnail_url': transformedUrl,
        'public_id': publicId,
      };
    } catch (e) {
      print('❌ Thumbnail error: $e');
      return {'success': false, 'message': 'فشل إنشاء الصورة المصغرة: $e'};
    }
  }

  /// Apply artistic effects
  Future<Map<String, dynamic>> applyArtEffect(File imageFile, String effect) async {
    try {
      isProcessing.value = true;
      status.value = 'جاري تطبيق التأثير الفني...';

      final uploadResult = await uploadImage(imageFile, folder: 'artistic');
      if (uploadResult['success'] != true) {
        return uploadResult;
      }

      final publicId = uploadResult['public_id'];
      final effectTransform = _getArtEffectTransformation(effect);
      final transformedUrl = transformImage(publicId, effectTransform);

      return {
        'success': true,
        'original_url': uploadResult['url'],
        'edited_url': transformedUrl,
        'public_id': publicId,
        'effect': effect,
        'message': 'تم تطبيق التأثير بنجاح',
      };
    } catch (e) {
      print('❌ Art effect error: $e');
      return {'success': false, 'message': 'فشل تطبيق التأثير: $e'};
    } finally {
      isProcessing.value = false;
      status.value = '';
    }
  }

  /// Download transformed image
  Future<File?> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${directory.path}/cloudinary_$timestamp.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Download error: $e');
      return null;
    }
  }

  /// Generate signature for authenticated uploads
  String _generateSignature(int timestamp, {String? folder}) {
    var params = 'timestamp=$timestamp';
    if (folder != null) {
      params = 'folder=$folder&$params';
    }
    final toSign = '$params$_apiSecret';
    return sha1.convert(utf8.encode(toSign)).toString();
  }

  /// Get filter transformations
  List<String> _getFilterTransformation(String filterName) {
    switch (filterName.toLowerCase()) {
      case 'grayscale':
      case 'أبيض وأسود':
        return ['e_grayscale'];
      case 'sepia':
      case 'بني قديم':
        return ['e_sepia:80'];
      case 'vintage':
      case 'كلاسيكي':
        return ['e_sepia:50', 'e_vignette:30'];
      case 'vivid':
      case 'حيوي':
        return ['e_vibrance:50', 'e_saturation:30'];
      case 'warm':
      case 'دافئ':
        return ['e_tint:40:orange'];
      case 'cool':
      case 'بارد':
        return ['e_tint:40:blue'];
      case 'dramatic':
      case 'درامي':
        return ['e_contrast:30', 'e_saturation:-20', 'e_vignette:40'];
      case 'bright':
      case 'مشرق':
        return ['e_brightness:20', 'e_contrast:10'];
      case 'dark':
      case 'داكن':
        return ['e_brightness:-30', 'e_contrast:20'];
      case 'soft':
      case 'ناعم':
        return ['e_blur:100', 'e_brightness:10'];
      case 'sharp':
      case 'حاد':
        return ['e_sharpen:150', 'e_contrast:15'];
      case 'neon':
      case 'نيون':
        return ['e_negate', 'e_tint:80:ff00ff:0p:00ffff:100p'];
      // New Instagram-style filters
      case 'clarendon':
        return ['e_contrast:20', 'e_saturation:35', 'e_brightness:10'];
      case 'gingham':
        return ['e_brightness:10', 'e_hue:20', 'e_saturation:-10'];
      case 'moon':
        return ['e_grayscale', 'e_contrast:20', 'e_brightness:-10'];
      case 'lark':
        return ['e_brightness:10', 'e_saturation:-15', 'e_contrast:10'];
      case 'reyes':
        return ['e_sepia:20', 'e_brightness:15', 'e_contrast:-10'];
      case 'juno':
        return ['e_saturation:30', 'e_tint:10:yellow', 'e_contrast:15'];
      case 'slumber':
        return ['e_saturation:-30', 'e_brightness:10', 'e_tint:20:purple'];
      case 'crema':
        return ['e_saturation:-20', 'e_brightness:15', 'e_tint:10:orange'];
      case 'ludwig':
        return ['e_saturation:-15', 'e_contrast:20', 'e_brightness:5'];
      case 'aden':
        return ['e_saturation:-20', 'e_brightness:20', 'e_tint:15:pink'];
      case 'perpetua':
        return ['e_saturation:10', 'e_tint:10:cyan', 'e_brightness:5'];
      case 'amaro':
        return ['e_brightness:15', 'e_saturation:20', 'e_vignette:20'];
      case 'mayfair':
        return ['e_saturation:15', 'e_contrast:10', 'e_vignette:30'];
      case 'rise':
        return ['e_brightness:15', 'e_saturation:10', 'e_tint:10:orange'];
      case 'hudson':
        return ['e_contrast:20', 'e_brightness:-10', 'e_tint:20:blue'];
      case 'valencia':
        return ['e_brightness:10', 'e_saturation:20', 'e_tint:10:orange'];
      case 'xpro2':
        return ['e_contrast:30', 'e_saturation:30', 'e_tint:20:yellow'];
      case 'sierra':
        return ['e_saturation:-10', 'e_contrast:15', 'e_vignette:40'];
      case 'willow':
        return ['e_grayscale', 'e_brightness:10', 'e_contrast:-10'];
      case 'lofi':
        return ['e_contrast:30', 'e_saturation:20'];
      case 'inkwell':
        return ['e_grayscale', 'e_contrast:30'];
      case 'hefe':
        return ['e_saturation:30', 'e_contrast:20', 'e_vignette:30'];
      case 'nashville':
        return ['e_tint:30:pink', 'e_saturation:-10', 'e_contrast:20'];
      case 'stinson':
        return ['e_saturation:-30', 'e_brightness:20'];
      case 'vesper':
        return ['e_saturation:-20', 'e_tint:15:yellow', 'e_contrast:15'];
      case 'earlybird':
        return ['e_sepia:30', 'e_saturation:20', 'e_vignette:40'];
      case 'brannan':
        return ['e_contrast:30', 'e_sepia:20'];
      case 'sutro':
        return ['e_sepia:40', 'e_vignette:50', 'e_contrast:20'];
      case 'toaster':
        return ['e_saturation:30', 'e_vignette:50', 'e_tint:20:red'];
      case 'walden':
        return ['e_brightness:20', 'e_saturation:-10', 'e_tint:10:yellow'];
      case '1977':
        return ['e_tint:30:pink', 'e_brightness:10', 'e_contrast:10'];
      case 'kelvin':
        return ['e_saturation:30', 'e_tint:20:orange', 'e_contrast:15'];
      case 'maven':
        return ['e_sepia:20', 'e_saturation:-20', 'e_contrast:10'];
      case 'ginza':
        return ['e_sepia:10', 'e_saturation:10', 'e_brightness:10'];
      case 'skyline':
        return ['e_contrast:20', 'e_tint:15:blue', 'e_saturation:10'];
      case 'dogpatch':
        return ['e_saturation:-30', 'e_contrast:30'];
      case 'brooklyn':
        return ['e_contrast:10', 'e_brightness:10', 'e_tint:10:cyan'];
      case 'helena':
        return ['e_tint:20:pink', 'e_brightness:10'];
      case 'ashby':
        return ['e_sepia:30', 'e_brightness:20', 'e_saturation:-20'];
      case 'charmes':
        return ['e_tint:30:red', 'e_contrast:10'];
      default:
        return [];
    }
  }

  /// Get artistic effect transformations
  List<String> _getArtEffectTransformation(String effect) {
    switch (effect.toLowerCase()) {
      case 'oil_paint':
      case 'زيتي':
        return ['e_oil_paint:70'];
      case 'cartoon':
      case 'كرتون':
        return ['e_cartoonify'];
      case 'pixelate':
      case 'بكسل':
        return ['e_pixelate:10'];
      case 'vignette':
      case 'إطار داكن':
        return ['e_vignette:60'];
      case 'shadow':
      case 'ظل':
        return ['e_shadow:50'];
      case 'outline':
      case 'حدود':
        return ['e_outline:outer:5:black'];
      case 'vectorize':
      case 'متجه':
        return ['e_vectorize'];
      case 'gradient':
      case 'تدرج':
        return ['e_gradient_fade:symmetric'];
      default:
        return [];
    }
  }

  /// Get available filters
  List<Map<String, String>> getAvailableFilters() {
    return [
      // Basic filters
      {'id': 'grayscale', 'name': 'أبيض وأسود', 'icon': '⬛', 'category': 'basic'},
      {'id': 'sepia', 'name': 'بني قديم', 'icon': '🟤', 'category': 'basic'},
      {'id': 'vintage', 'name': 'كلاسيكي', 'icon': '📷', 'category': 'basic'},
      {'id': 'vivid', 'name': 'حيوي', 'icon': '🌈', 'category': 'basic'},
      {'id': 'warm', 'name': 'دافئ', 'icon': '🔥', 'category': 'basic'},
      {'id': 'cool', 'name': 'بارد', 'icon': '❄️', 'category': 'basic'},
      {'id': 'dramatic', 'name': 'درامي', 'icon': '🎭', 'category': 'basic'},
      {'id': 'bright', 'name': 'مشرق', 'icon': '☀️', 'category': 'basic'},
      {'id': 'dark', 'name': 'داكن', 'icon': '🌙', 'category': 'basic'},
      {'id': 'soft', 'name': 'ناعم', 'icon': '☁️', 'category': 'basic'},
      {'id': 'sharp', 'name': 'حاد', 'icon': '🔪', 'category': 'basic'},
      {'id': 'neon', 'name': 'نيون', 'icon': '💜', 'category': 'basic'},
      // Instagram-style filters
      {'id': 'clarendon', 'name': 'كلارندون', 'icon': '🌟', 'category': 'instagram'},
      {'id': 'gingham', 'name': 'جينغهام', 'icon': '🎨', 'category': 'instagram'},
      {'id': 'moon', 'name': 'قمر', 'icon': '🌕', 'category': 'instagram'},
      {'id': 'lark', 'name': 'لارك', 'icon': '🐦', 'category': 'instagram'},
      {'id': 'reyes', 'name': 'رييس', 'icon': '👑', 'category': 'instagram'},
      {'id': 'juno', 'name': 'جونو', 'icon': '✨', 'category': 'instagram'},
      {'id': 'slumber', 'name': 'سلمبر', 'icon': '😴', 'category': 'instagram'},
      {'id': 'crema', 'name': 'كريما', 'icon': '☕', 'category': 'instagram'},
      {'id': 'ludwig', 'name': 'لودفيغ', 'icon': '🎵', 'category': 'instagram'},
      {'id': 'aden', 'name': 'عدن', 'icon': '🌸', 'category': 'instagram'},
      {'id': 'perpetua', 'name': 'بربتوا', 'icon': '🌊', 'category': 'instagram'},
      {'id': 'amaro', 'name': 'أمارو', 'icon': '🍂', 'category': 'instagram'},
      {'id': 'mayfair', 'name': 'مايفير', 'icon': '🎪', 'category': 'instagram'},
      {'id': 'rise', 'name': 'رايز', 'icon': '🌅', 'category': 'instagram'},
      {'id': 'hudson', 'name': 'هدسون', 'icon': '🏙️', 'category': 'instagram'},
      {'id': 'valencia', 'name': 'فالنسيا', 'icon': '🍊', 'category': 'instagram'},
      {'id': 'xpro2', 'name': 'إكسبرو', 'icon': '📸', 'category': 'instagram'},
      {'id': 'sierra', 'name': 'سييرا', 'icon': '⛰️', 'category': 'instagram'},
      {'id': 'willow', 'name': 'ويلو', 'icon': '🌿', 'category': 'instagram'},
      {'id': 'lofi', 'name': 'لوفاي', 'icon': '🎧', 'category': 'instagram'},
      {'id': 'inkwell', 'name': 'إنكويل', 'icon': '🖤', 'category': 'instagram'},
      {'id': 'hefe', 'name': 'هيفي', 'icon': '🌻', 'category': 'instagram'},
      {'id': 'nashville', 'name': 'ناشفيل', 'icon': '🎸', 'category': 'instagram'},
      {'id': 'earlybird', 'name': 'إيرلي بيرد', 'icon': '🐥', 'category': 'instagram'},
      {'id': 'toaster', 'name': 'توستر', 'icon': '🍞', 'category': 'instagram'},
      {'id': 'walden', 'name': 'والدن', 'icon': '🌲', 'category': 'instagram'},
      {'id': '1977', 'name': '1977', 'icon': '📼', 'category': 'instagram'},
      {'id': 'kelvin', 'name': 'كلفن', 'icon': '🌡️', 'category': 'instagram'},
      {'id': 'brooklyn', 'name': 'بروكلين', 'icon': '🌉', 'category': 'instagram'},
    ];
  }

  /// Get filters by category
  List<Map<String, String>> getFiltersByCategory(String category) {
    return getAvailableFilters()
        .where((f) => f['category'] == category)
        .toList();
  }

  /// Get filter categories
  List<Map<String, String>> getFilterCategories() {
    return [
      {'id': 'basic', 'name': 'أساسية', 'icon': '🎨'},
      {'id': 'instagram', 'name': 'إنستغرام', 'icon': '📷'},
    ];
  }

  /// Get available art effects
  List<Map<String, String>> getAvailableArtEffects() {
    return [
      {'id': 'oil_paint', 'name': 'رسم زيتي', 'icon': '🎨'},
      {'id': 'cartoon', 'name': 'كرتون', 'icon': '🖼️'},
      {'id': 'pixelate', 'name': 'بكسل', 'icon': '👾'},
      {'id': 'vignette', 'name': 'إطار داكن', 'icon': '🖤'},
      {'id': 'shadow', 'name': 'ظل', 'icon': '👤'},
      {'id': 'outline', 'name': 'حدود', 'icon': '✏️'},
      {'id': 'gradient', 'name': 'تدرج', 'icon': '🌅'},
    ];
  }

  /// Get social media presets
  Map<String, Map<String, int>> getSocialMediaPresets() {
    return {
      'instagram_post': {'width': 1080, 'height': 1080},
      'instagram_story': {'width': 1080, 'height': 1920},
      'instagram_landscape': {'width': 1080, 'height': 566},
      'facebook_post': {'width': 1200, 'height': 630},
      'facebook_cover': {'width': 820, 'height': 312},
      'twitter_post': {'width': 1200, 'height': 675},
      'twitter_header': {'width': 1500, 'height': 500},
      'linkedin_post': {'width': 1200, 'height': 627},
      'youtube_thumbnail': {'width': 1280, 'height': 720},
      'tiktok_video': {'width': 1080, 'height': 1920},
    };
  }
}
