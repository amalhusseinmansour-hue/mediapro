import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Upload-Post API Service
/// Integration with upload-post.com for multi-platform social media posting
class UploadPostService extends GetxController {
  // ========== Configuration ==========

  /// Upload-Post API Base URL
  static const String baseUrl = 'https://api.upload-post.com/v1';

  /// API Key من upload-post.com
  static const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFtYWxodXNzZWlubWFuc291ckBnbWFpbC5jb20iLCJleHAiOjQ5MTY1NDQ4MDAsImp0aSI6IjJlNDRiODljLTRhYzYtNGMyMi1hZmMwLTM4NTk0ZGYwMWI5MyJ9.T-ylMe9tcxD3Zefwg3GmLEx_oqrOBykyhe_U9Lnlyjo';

  /// Default username for upload-post account
  static const String defaultUsername = 'amalhusseinmansour';

  // ========== State Management ==========

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxList<ConnectedAccount> connectedAccounts = <ConnectedAccount>[].obs;

  // ========== Initialization ==========

  @override
  void onInit() {
    super.onInit();
    print('✅ UploadPostService initialized');
    _loadConnectedAccounts();
  }

  // ========== Account Management ==========

  /// Load connected accounts from local storage
  Future<void> _loadConnectedAccounts() async {
    try {
      // TODO: Load from Hive or SharedPreferences
      // For now, using demo data
      connectedAccounts.value = [];
    } catch (e) {
      print('❌ Error loading connected accounts: $e');
    }
  }

  /// Get authorization URL for a platform
  String getAuthorizationUrl(String platform) {
    // URL للمصادقة على upload-post
    return 'https://www.upload-post.com/connect/$platform?api_key=$apiKey';
  }

  /// Check if a platform is connected
  bool isPlatformConnected(String platform) {
    return connectedAccounts.any((account) =>
      account.platform.toLowerCase() == platform.toLowerCase() &&
      account.isActive
    );
  }

  /// Get connected account for a platform
  ConnectedAccount? getConnectedAccount(String platform) {
    try {
      return connectedAccounts.firstWhere(
        (account) => account.platform.toLowerCase() == platform.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // ========== Post Upload Methods ==========

  /// Upload video to multiple platforms
  Future<Map<String, dynamic>> uploadVideo({
    required String videoUrl,
    required String title,
    required String description,
    required List<String> platforms,
    Map<String, dynamic>? platformSpecificData,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final results = <String, dynamic>{};

      for (final platform in platforms) {
        if (!isPlatformConnected(platform)) {
          results[platform] = {
            'success': false,
            'error': 'Platform not connected',
          };
          continue;
        }

        final result = await _uploadToPlatform(
          platform: platform,
          videoUrl: videoUrl,
          title: title,
          description: description,
          platformData: platformSpecificData,
        );

        results[platform] = result;
      }

      return {
        'success': true,
        'results': results,
      };
    } catch (e) {
      lastError.value = e.toString();
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload image to multiple platforms
  Future<Map<String, dynamic>> uploadImage({
    required String imageUrl,
    required String caption,
    required List<String> platforms,
    Map<String, dynamic>? platformSpecificData,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final results = <String, dynamic>{};

      for (final platform in platforms) {
        if (!isPlatformConnected(platform)) {
          results[platform] = {
            'success': false,
            'error': 'Platform not connected',
          };
          continue;
        }

        final result = await _uploadImageToPlatform(
          platform: platform,
          imageUrl: imageUrl,
          caption: caption,
          platformData: platformSpecificData,
        );

        results[platform] = result;
      }

      return {
        'success': true,
        'results': results,
      };
    } catch (e) {
      lastError.value = e.toString();
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload text post to multiple platforms
  Future<Map<String, dynamic>> uploadText({
    required String text,
    required List<String> platforms,
    Map<String, dynamic>? platformSpecificData,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final results = <String, dynamic>{};

      for (final platform in platforms) {
        if (!isPlatformConnected(platform)) {
          results[platform] = {
            'success': false,
            'error': 'Platform not connected',
          };
          continue;
        }

        final result = await _uploadTextToPlatform(
          platform: platform,
          text: text,
          platformData: platformSpecificData,
        );

        results[platform] = result;
      }

      return {
        'success': true,
        'results': results,
      };
    } catch (e) {
      lastError.value = e.toString();
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Private Helper Methods ==========

  /// Upload video to specific platform
  Future<Map<String, dynamic>> _uploadToPlatform({
    required String platform,
    required String videoUrl,
    required String title,
    required String description,
    Map<String, dynamic>? platformData,
  }) async {
    try {
      print('🎬 Uploading video to $platform via upload-post.com');
      print('   Video: $videoUrl');
      print('   Title: $title');

      final body = {
        'user': defaultUsername,
        'platform': [platform.toLowerCase()],
        'title': title,
        'description': description,
        'video': videoUrl,
      };

      // Add platform-specific data
      if (platformData != null) {
        switch (platform.toLowerCase()) {
          case 'instagram':
            if (platformData.containsKey('instagramTitle')) {
              body['instagramTitle'] = platformData['instagramTitle'];
            }
            if (platformData.containsKey('mediaType')) {
              body['instagramMediaType'] = platformData['mediaType'];
            }
            break;
          case 'youtube':
            if (platformData.containsKey('youtubeTitle')) {
              body['youtubeTitle'] = platformData['youtubeTitle'];
            }
            if (platformData.containsKey('youtubeDescription')) {
              body['youtubeDescription'] = platformData['youtubeDescription'];
            }
            break;
          case 'facebook':
            if (platformData.containsKey('pageId')) {
              body['facebookPageId'] = platformData['pageId'];
            }
            break;
          case 'tiktok':
            if (platformData.containsKey('tiktokTitle')) {
              body['tiktokTitle'] = platformData['tiktokTitle'];
            }
            break;
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/upload/video'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Upload image to specific platform
  Future<Map<String, dynamic>> _uploadImageToPlatform({
    required String platform,
    required String imageUrl,
    required String caption,
    Map<String, dynamic>? platformData,
  }) async {
    try {
      final body = {
        'user': defaultUsername,
        'platform': [platform.toLowerCase()],
        'caption': caption,
        'image': imageUrl,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/upload/image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Upload text to specific platform
  Future<Map<String, dynamic>> _uploadTextToPlatform({
    required String platform,
    required String text,
    Map<String, dynamic>? platformData,
  }) async {
    try {
      final body = {
        'user': defaultUsername,
        'platform': [platform.toLowerCase()],
        'text': text,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/upload/text'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ========== Supported Platforms ==========

  /// Get list of supported platforms
  static List<SocialPlatform> getSupportedPlatforms() {
    return [
      SocialPlatform(
        id: 'instagram',
        name: 'Instagram',
        displayName: 'انستغرام',
        icon: '📷',
        color: 'E1306C',
        supportsVideo: true,
        supportsImage: true,
        supportsText: false,
      ),
      SocialPlatform(
        id: 'facebook',
        name: 'Facebook',
        displayName: 'فيسبوك',
        icon: '👤',
        color: '1877F2',
        supportsVideo: true,
        supportsImage: true,
        supportsText: true,
      ),
      SocialPlatform(
        id: 'youtube',
        name: 'YouTube',
        displayName: 'يوتيوب',
        icon: '▶️',
        color: 'FF0000',
        supportsVideo: true,
        supportsImage: false,
        supportsText: false,
      ),
      SocialPlatform(
        id: 'tiktok',
        name: 'TikTok',
        displayName: 'تيك توك',
        icon: '🎵',
        color: '000000',
        supportsVideo: true,
        supportsImage: false,
        supportsText: false,
      ),
      SocialPlatform(
        id: 'linkedin',
        name: 'LinkedIn',
        displayName: 'لينكد إن',
        icon: '💼',
        color: '0A66C2',
        supportsVideo: true,
        supportsImage: true,
        supportsText: true,
      ),
      SocialPlatform(
        id: 'x',
        name: 'X (Twitter)',
        displayName: 'إكس (تويتر)',
        icon: '🐦',
        color: '000000',
        supportsVideo: true,
        supportsImage: true,
        supportsText: true,
      ),
      SocialPlatform(
        id: 'threads',
        name: 'Threads',
        displayName: 'ثريدز',
        icon: '🧵',
        color: '000000',
        supportsVideo: true,
        supportsImage: true,
        supportsText: true,
      ),
    ];
  }
}

// ========== Models ==========

/// Connected Social Media Account Model
class ConnectedAccount {
  final String id;
  final String platform;
  final String username;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime connectedAt;
  final DateTime? lastUsedAt;

  ConnectedAccount({
    required this.id,
    required this.platform,
    required this.username,
    this.profileImageUrl,
    this.isActive = true,
    required this.connectedAt,
    this.lastUsedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'connectedAt': connectedAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  factory ConnectedAccount.fromJson(Map<String, dynamic> json) {
    return ConnectedAccount(
      id: json['id'],
      platform: json['platform'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'] ?? true,
      connectedAt: DateTime.parse(json['connectedAt']),
      lastUsedAt: json['lastUsedAt'] != null
        ? DateTime.parse(json['lastUsedAt'])
        : null,
    );
  }
}

/// Social Platform Model
class SocialPlatform {
  final String id;
  final String name;
  final String displayName;
  final String icon;
  final String color;
  final bool supportsVideo;
  final bool supportsImage;
  final bool supportsText;

  SocialPlatform({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.supportsVideo,
    required this.supportsImage,
    required this.supportsText,
  });
}
