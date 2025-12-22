import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'http_service.dart';

/// Google Drive service for file uploads
/// Handles file uploads to Google Drive via Laravel backend
class GoogleDriveService extends GetxController {
  final HttpService _httpService = Get.find<HttpService>();
  final String baseUrl = 'https://mediaprosocial.io/api';

  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  /// Upload file to Google Drive via backend
  ///
  /// Parameters:
  /// - file: The file to upload
  /// - fileName: Name for the file on Google Drive
  /// - folderId: Optional Google Drive folder ID
  ///
  /// Returns:
  /// - Map with success status, file ID, and file URL
  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String fileName,
    String? folderId,
  }) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      // Read file as base64
      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);

      // Upload via backend API
      final response = await http.post(
        Uri.parse('$baseUrl/google-drive/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ..._httpService.authHeaders,
        },
        body: json.encode({
          'file_data': base64File,
          'file_name': fileName,
          'folder_id': folderId ?? '1YCGwbzPHcEvDv6pVxf1ZltGYOTKmwFr-',
          'mime_type': _getMimeType(fileName),
        }),
      );

      uploadProgress.value = 1.0;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'fileId': data['data']['file_id'],
            'fileName': data['data']['file_name'],
            'fileUrl': data['data']['file_url'],
            'webViewLink': data['data']['web_view_link'],
          };
        }
      }

      // Throw an exception on failure instead of returning a fake success
      final errorData = json.decode(response.body);
      final errorMessage =
          errorData['message'] ??
          'Google Drive upload failed with status: ${response.statusCode}';
      print('❌ Google Drive upload failed: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ Error uploading to Google Drive: $e');
      rethrow; // Rethrow the exception to be handled by the caller
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// Get MIME type from file name
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }

  /// Share file publicly (make it accessible)
  Future<bool> makeFilePublic(String fileId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google-drive/share'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ..._httpService.authHeaders,
        },
        body: json.encode({'file_id': fileId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print('❌ Error sharing file: $e');
      return false;
    }
  }

  /// Get file URL
  String getFileUrl(String fileId) {
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }

  /// Get file download URL
  String getFileDownloadUrl(String fileId) {
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }

  /// Get file web view URL
  String getFileWebViewUrl(String fileId) {
    return 'https://drive.google.com/file/d/$fileId/view';
  }
}
