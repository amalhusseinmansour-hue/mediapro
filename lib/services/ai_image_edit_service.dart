import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'http_service.dart';
import 'google_drive_service.dart';
import '../core/config/api_config.dart';
import '../core/config/env_config.dart';
import 'gemini_service.dart';

/// AI-powered image editing service
/// Uses Gemini for AI-based image editing with fallback to N8N workflow
class AiImageEditService extends GetxController {
  final GoogleDriveService _driveService = Get.find<GoogleDriveService>();
  final HttpService _httpService = Get.find<HttpService>();
  final RxBool isEditing = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxString status = ''.obs;

  // Gemini API configuration
  static String get _geminiApiKey => EnvConfig.googleAIApiKey;
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // GeminiService for AI features
  GeminiService? get _geminiService {
    try {
      return Get.find<GeminiService>();
    } catch (e) {
      return null;
    }
  }

  bool get _useGemini => _geminiApiKey.isNotEmpty;

  /// Edit image using AI (Gemini with fallback to backend)
  ///
  /// Parameters:
  /// - imageFile: The image file to edit
  /// - editPrompt: What to change in the image (e.g., "make the sky blue", "add sunglasses")
  /// - imageName: Optional custom name for the image
  ///
  /// Returns:
  /// - Map with success status, edited image URL, and Google Drive file ID
  Future<Map<String, dynamic>> editImage({
    required File imageFile,
    required String editPrompt,
    String? imageName,
  }) async {
    try {
      isEditing.value = true;
      progress.value = 0.0;

      // Try Gemini Imagen editing first
      if (_useGemini) {
        status.value = 'تحرير الصورة باستخدام Gemini AI...';
        print('🎨 Editing image with Gemini Imagen...');

        final geminiResult = await _editImageWithGemini(
          imageFile: imageFile,
          editPrompt: editPrompt,
        );

        if (geminiResult['success'] == true) {
          progress.value = 1.0;
          return geminiResult;
        }

        print('⚠️ Gemini edit failed, falling back to backend...');
      }

      // Fallback: Upload to Google Drive and use backend workflow
      status.value = 'رفع الصورة إلى Google Drive...';
      final uploadResult = await _uploadToGoogleDrive(
        imageFile: imageFile,
        fileName:
            imageName ??
            'image_to_edit_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (uploadResult['success'] != true) {
        return {
          'success': false,
          'message': uploadResult['message'] ?? 'فشل رفع الصورة',
        };
      }

      progress.value = 0.2;
      final pictureID = uploadResult['fileId'];

      // Step 2: Execute the full editing workflow (80%)
      status.value = 'تحرير الصورة باستخدام AI...';
      final result = await editImageFull(
        pictureID: pictureID,
        editPrompt: editPrompt,
        imageName: uploadResult['fileName'],
      );

      progress.value = 1.0;
      status.value = '';

      if (result['success'] == true) {
        result['originalImageUrl'] = uploadResult['fileUrl'];
        return result;
      } else {
        return result;
      }
    } catch (e) {
      print('❌ Error editing image: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
        'error': e.toString(),
      };
    } finally {
      isEditing.value = false;
      progress.value = 0.0;
      status.value = '';
    }
  }

  /// Edit image using Gemini Imagen API
  Future<Map<String, dynamic>> _editImageWithGemini({
    required File imageFile,
    required String editPrompt,
  }) async {
    try {
      // Read image and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Detect mime type
      final extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      progress.value = 0.3;

      // Use Gemini's image understanding to create an edited version
      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-exp:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inlineData': {
                    'mimeType': mimeType,
                    'data': base64Image,
                  }
                },
                {
                  'text': '''Analyze this image and describe how it would look after applying this edit: "$editPrompt"

Provide a detailed description of the edited image that can be used to generate a new image.
Focus on:
1. The main elements that should be kept
2. What changes need to be made
3. The overall style and mood

Respond with just the image description, no explanations.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode != 200) {
        print('❌ Gemini analysis failed: ${response.statusCode}');
        return {'success': false, 'message': 'فشل تحليل الصورة'};
      }

      final analysisData = jsonDecode(response.body);
      final description = analysisData['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (description == null || description.isEmpty) {
        return {'success': false, 'message': 'فشل تحليل الصورة'};
      }

      progress.value = 0.5;
      status.value = 'إنشاء الصورة المعدلة...';

      // Now generate the edited image using Imagen
      final editedImageResult = await _generateEditedImageWithImagen(
        originalDescription: description,
        editPrompt: editPrompt,
      );

      return editedImageResult;
    } catch (e) {
      print('❌ Error in Gemini image edit: $e');
      return {'success': false, 'message': 'فشل تحرير الصورة: $e'};
    }
  }

  /// Generate edited image using Imagen API
  Future<Map<String, dynamic>> _generateEditedImageWithImagen({
    required String originalDescription,
    required String editPrompt,
  }) async {
    try {
      final combinedPrompt = '''Create an image based on this description with the following edit applied:

Original: $originalDescription

Edit to apply: $editPrompt

Generate a high-quality, professional image that combines the original content with the requested edit.''';

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/imagen-3.0-generate-002:predict?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instances': [
            {'prompt': combinedPrompt}
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '1:1',
            'personGeneration': 'allow_adult',
          }
        }),
      );

      progress.value = 0.8;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List?;

        if (predictions != null && predictions.isNotEmpty) {
          final base64Image = predictions[0]['bytesBase64Encoded'];
          if (base64Image != null) {
            // Save image to temp file
            final directory = await getTemporaryDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final filePath = '${directory.path}/edited_image_$timestamp.png';

            final imageBytes = base64Decode(base64Image);
            await File(filePath).writeAsBytes(imageBytes);

            print('✅ Image edited successfully with Gemini Imagen');
            return {
              'success': true,
              'editedImagePath': filePath,
              'editedImageUrl': 'file://$filePath',
              'message': 'تم تحرير الصورة بنجاح',
            };
          }
        }
      }

      // Try fallback with gemini-2.0-flash-exp image generation
      print('⚠️ Imagen failed, trying Gemini Flash...');
      return await _generateWithGeminiFlash(originalDescription, editPrompt);
    } catch (e) {
      print('❌ Imagen generation failed: $e');
      return {'success': false, 'message': 'فشل توليد الصورة المعدلة'};
    }
  }

  /// Fallback image generation with Gemini Flash
  Future<Map<String, dynamic>> _generateWithGeminiFlash(
    String description,
    String editPrompt,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-exp:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Generate an image based on:
Description: $description
With this modification: $editPrompt'''
                }
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['image', 'text'],
            'temperature': 0.8,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;

        if (parts != null) {
          for (final part in parts) {
            if (part['inlineData'] != null) {
              final base64Image = part['inlineData']['data'];
              if (base64Image != null) {
                final directory = await getTemporaryDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final filePath = '${directory.path}/edited_image_$timestamp.png';

                final imageBytes = base64Decode(base64Image);
                await File(filePath).writeAsBytes(imageBytes);

                print('✅ Image edited successfully with Gemini Flash');
                return {
                  'success': true,
                  'editedImagePath': filePath,
                  'editedImageUrl': 'file://$filePath',
                  'message': 'تم تحرير الصورة بنجاح',
                };
              }
            }
          }
        }
      }

      return {'success': false, 'message': 'فشل توليد الصورة'};
    } catch (e) {
      print('❌ Gemini Flash generation failed: $e');
      return {'success': false, 'message': 'فشل توليد الصورة'};
    }
  }

  /// Edit image with full parameters (direct N8N call)
  ///
  /// This method directly calls the N8N workflow with all required parameters
  Future<Map<String, dynamic>> editImageFull({
    required String pictureID,
    required String editPrompt,
    required String imageName,
    String? chatID,
  }) async {
    try {
      isEditing.value = true;
      status.value = 'تحرير الصورة باستخدام AI...';

      // The app now calls our own backend, which will then securely call N8N.
      // This is the correct and secure architecture.
      final result = await _executeBackendEditWorkflow(
        pictureID: pictureID,
        editPrompt: editPrompt,
        imageName: imageName, // The backend will handle the rest
        chatID: chatID,
      );

      return result;
    } catch (e) {
      print('❌ Error in editImageFull: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
        'error': e.toString(),
      };
    } finally {
      isEditing.value = false;
      status.value = '';
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('❌ Error picking image: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('❌ Error taking photo: $e');
      return null;
    }
  }

  /// Upload image to Google Drive
  Future<Map<String, dynamic>> _uploadToGoogleDrive({
    required File imageFile,
    required String fileName,
  }) async {
    try {
      isUploading.value = true;

      final result = await _driveService.uploadFile(
        file: imageFile,
        fileName: fileName,
        folderId:
            ApiConfig.googleDriveMediaFolderId, // Using centralized config
      );

      return result;
    } catch (e) {
      print('❌ Error uploading to Drive: $e');
      return {
        'success': false,
        'message': 'فشل رفع الصورة إلى Google Drive',
        'error': e.toString(),
      };
    } finally {
      isUploading.value = false;
    }
  }

  /// Execute edit workflow via our backend
  ///
  /// This method calls a dedicated endpoint on our Laravel backend.
  /// The backend will then securely execute the N8N workflow.
  Future<Map<String, dynamic>> _executeBackendEditWorkflow({
    required String pictureID,
    required String editPrompt,
    required String imageName,
    String? chatID,
  }) async {
    try {
      // This is the new, secure endpoint in our Laravel backend
      final backendApiUrl = '${ApiConfig.backendBaseUrl}/api/v1/images/edit';

      final response = await _httpService.post(
        backendApiUrl,
        body: {
          'pictureID': pictureID,
          'edit_prompt': editPrompt,
          'image_name': imageName,
          if (chatID != null) 'chatID': chatID,
        },
      );

      return {'success': true, ...response};
    } catch (e) {
      print('❌ Backend edit workflow execution failed: $e');
      return {'success': false, 'message': 'فشل الاتصال بالخادم لتعديل الصورة'};
    }
  }

  /// Get edit suggestions based on image type
  List<String> getEditSuggestions() {
    return [
      'اجعل الخلفية ضبابية',
      'أضف تأثير درامي',
      'اجعل السماء زرقاء',
      'أضف إضاءة ذهبية',
      'حول الصورة إلى أبيض وأسود',
      'أضف تأثير الغروب',
      'اجعل الألوان أكثر حيوية',
      'أضف تأثير الضباب',
      'أضف نظارات شمسية',
      'غير الخلفية إلى شاطئ',
      'أضف تأثير المطر',
      'اجعل الصورة أكثر سطوعاً',
    ];
  }

  /// Validate edit prompt
  bool isValidPrompt(String prompt) {
    return prompt.trim().isNotEmpty && prompt.length >= 3;
  }

  /// Get example prompts for users
  Map<String, List<String>> getExamplePrompts() {
    return {
      'تأثيرات الطقس': [
        'أضف تأثير المطر',
        'اجعل السماء غائمة',
        'أضف قوس قزح',
        'أضف ثلج',
      ],
      'تحسين الصورة': [
        'اجعل الألوان أكثر حيوية',
        'أضف إضاءة احترافية',
        'حسن جودة الصورة',
        'اجعل الصورة أوضح',
      ],
      'تعديلات إبداعية': [
        'حول الصورة لرسم زيتي',
        'أضف تأثير كرتوني',
        'اجعلها تبدو كصورة قديمة',
        'أضف تأثير النيون',
      ],
      'تعديلات الخلفية': [
        'غير الخلفية إلى غابة',
        'أضف خلفية فضائية',
        'اجعل الخلفية بيضاء نقية',
        'أضف خلفية مدينة',
      ],
    };
  }
}
