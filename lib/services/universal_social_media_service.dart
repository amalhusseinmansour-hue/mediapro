import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'facebook_graph_api_service.dart';

/// Universal Social Media Service
/// Supports ALL social media platforms via:
/// - APIs (Facebook, Instagram, Twitter)
/// - Share Intents (TikTok, YouTube, LinkedIn, Pinterest, Snapchat)
class UniversalSocialMediaService extends GetxController {
  final FacebookGraphApiService _facebookService =
      Get.find<FacebookGraphApiService>();
  // TODO: Reserve for universal account management
  // final SocialAccountsService _accountsService =
  //     Get.find<SocialAccountsService>();

  // ========== Supported Platforms ==========

  static const List<SocialPlatformInfo> allPlatforms = [
    SocialPlatformInfo(
      id: 'facebook',
      name: 'Facebook',
      displayName: 'فيسبوك',
      icon: '📘',
      color: '1877F2',
      method: PostMethod.api,
      supportsText: true,
      supportsImage: true,
      supportsVideo: true,
    ),
    SocialPlatformInfo(
      id: 'instagram',
      name: 'Instagram',
      displayName: 'انستغرام',
      icon: '📷',
      color: 'E4405F',
      method: PostMethod.share, // Changed to share - API requires Facebook Business
      supportsText: true, // Can share text as caption
      supportsImage: true,
      supportsVideo: true, // Instagram supports reels
    ),
    SocialPlatformInfo(
      id: 'twitter',
      name: 'Twitter (X)',
      displayName: 'تويتر (إكس)',
      icon: '🐦',
      color: '1DA1F2',
      method: PostMethod.share,
      supportsText: true,
      supportsImage: true,
      supportsVideo: true,
    ),
    SocialPlatformInfo(
      id: 'tiktok',
      name: 'TikTok',
      displayName: 'تيك توك',
      icon: '🎵',
      color: '000000',
      method: PostMethod.share,
      supportsText: false,
      supportsImage: false,
      supportsVideo: true,
    ),
    SocialPlatformInfo(
      id: 'youtube',
      name: 'YouTube',
      displayName: 'يوتيوب',
      icon: '▶️',
      color: 'FF0000',
      method: PostMethod.share,
      supportsText: false,
      supportsImage: false,
      supportsVideo: true,
    ),
    SocialPlatformInfo(
      id: 'linkedin',
      name: 'LinkedIn',
      displayName: 'لينكد إن',
      icon: '💼',
      color: '0A66C2',
      method: PostMethod.share,
      supportsText: true,
      supportsImage: true,
      supportsVideo: true,
    ),
    SocialPlatformInfo(
      id: 'pinterest',
      name: 'Pinterest',
      displayName: 'بينترست',
      icon: '📌',
      color: 'E60023',
      method: PostMethod.share,
      supportsText: true,
      supportsImage: true,
      supportsVideo: false,
    ),
    SocialPlatformInfo(
      id: 'snapchat',
      name: 'Snapchat',
      displayName: 'سناب شات',
      icon: '👻',
      color: 'FFFC00',
      method: PostMethod.share,
      supportsText: true,
      supportsImage: true,
      supportsVideo: true,
    ),
    SocialPlatformInfo(
      id: 'whatsapp',
      name: 'WhatsApp',
      displayName: 'واتساب',
      icon: '💬',
      color: '25D366',
      method: PostMethod.share,
      supportsText: true,
      supportsImage: true,
      supportsVideo: true,
    ),
    SocialPlatformInfo(
      id: 'telegram',
      name: 'Telegram',
      displayName: 'تليجرام',
      icon: '✈️',
      color: '26A5E4',
      method: PostMethod.share,
      supportsText: true,
      supportsImage: true,
      supportsVideo: true,
    ),
  ];

  // ========== Universal Post Method ==========

  /// Post to any platform (automatically chooses API or Share)
  Future<PostResult> postToplatform({
    required String platformId,
    String? text,
    File? mediaFile,
    String? mediaUrl,
    MediaType? mediaType,
  }) async {
    try {
      final platform = allPlatforms.firstWhere((p) => p.id == platformId);

      print('📤 Posting to ${platform.name} via ${platform.method}');

      if (platform.method == PostMethod.api) {
        return await _postViaAPI(
          platform: platform,
          text: text,
          mediaFile: mediaFile,
          mediaUrl: mediaUrl,
          mediaType: mediaType,
        );
      } else {
        return await _postViaShare(
          platform: platform,
          text: text,
          mediaFile: mediaFile,
        );
      }
    } catch (e) {
      print('❌ Error posting to $platformId: $e');
      return PostResult(
        success: false,
        platformId: platformId,
        error: e.toString(),
      );
    }
  }

  /// Post to multiple platforms
  Future<MultiPostResult> postToMultiplePlatforms({
    required List<String> platformIds,
    String? text,
    File? mediaFile,
    String? mediaUrl,
    MediaType? mediaType,
  }) async {
    final results = <PostResult>[];

    for (final platformId in platformIds) {
      final result = await postToplatform(
        platformId: platformId,
        text: text,
        mediaFile: mediaFile,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
      );
      results.add(result);
    }

    final successCount = results.where((r) => r.success).length;
    final failedCount = results.where((r) => !r.success).length;

    return MultiPostResult(
      results: results,
      successCount: successCount,
      failedCount: failedCount,
      totalCount: results.length,
    );
  }

  // ========== Private Methods - API Posting ==========

  Future<PostResult> _postViaAPI({
    required SocialPlatformInfo platform,
    String? text,
    File? mediaFile,
    String? mediaUrl,
    MediaType? mediaType,
  }) async {
    try {
      if (platform.id == 'facebook') {
        return await _postToFacebook(
          text: text,
          mediaUrl: mediaUrl,
          mediaType: mediaType,
        );
      } else if (platform.id == 'instagram') {
        return await _postToInstagram(mediaUrl: mediaUrl, caption: text);
      } else {
        return PostResult(
          success: false,
          platformId: platform.id,
          error: 'API not implemented for ${platform.name}',
        );
      }
    } catch (e) {
      return PostResult(
        success: false,
        platformId: platform.id,
        error: e.toString(),
      );
    }
  }

  Future<PostResult> _postToFacebook({
    String? text,
    String? mediaUrl,
    MediaType? mediaType,
  }) async {
    try {
      // Get user's Facebook pages
      if (_facebookService.userPages.isEmpty) {
        await _facebookService.loadUserPages();
      }

      if (_facebookService.userPages.isEmpty) {
        return PostResult(
          success: false,
          platformId: 'facebook',
          error: 'لا توجد صفحات Facebook مرتبطة',
        );
      }

      final firstPage = _facebookService.userPages.first;

      Map<String, dynamic> result;

      if (mediaType == MediaType.image && mediaUrl != null) {
        result = await _facebookService.postPhotoToPage(
          pageId: firstPage.id,
          pageAccessToken: firstPage.accessToken,
          photoUrl: mediaUrl,
          caption: text,
        );
      } else if (mediaType == MediaType.video && mediaUrl != null) {
        result = await _facebookService.postVideoToPage(
          pageId: firstPage.id,
          pageAccessToken: firstPage.accessToken,
          videoUrl: mediaUrl,
          description: text,
        );
      } else {
        result = await _facebookService.postTextToPage(
          pageId: firstPage.id,
          pageAccessToken: firstPage.accessToken,
          message: text ?? '',
        );
      }

      return PostResult(
        success: result['success'] == true,
        platformId: 'facebook',
        postId: result['post_id'],
        error: result['error'],
      );
    } catch (e) {
      return PostResult(
        success: false,
        platformId: 'facebook',
        error: e.toString(),
      );
    }
  }

  Future<PostResult> _postToInstagram({
    String? mediaUrl,
    String? caption,
  }) async {
    try {
      if (_facebookService.userPages.isEmpty) {
        return PostResult(
          success: false,
          platformId: 'instagram',
          error: 'لا توجد صفحات Facebook مرتبطة',
        );
      }

      final firstPage = _facebookService.userPages.first;

      // Get Instagram account ID
      final igAccountId = await _facebookService.getInstagramAccountId(
        firstPage.id,
        firstPage.accessToken,
      );

      if (igAccountId == null) {
        return PostResult(
          success: false,
          platformId: 'instagram',
          error: 'لم يتم العثور على حساب Instagram مرتبط',
        );
      }

      if (mediaUrl == null) {
        return PostResult(
          success: false,
          platformId: 'instagram',
          error: 'Instagram يتطلب صورة',
        );
      }

      final result = await _facebookService.postPhotoToInstagram(
        instagramAccountId: igAccountId,
        pageAccessToken: firstPage.accessToken,
        imageUrl: mediaUrl,
        caption: caption,
      );

      return PostResult(
        success: result['success'] == true,
        platformId: 'instagram',
        postId: result['post_id'],
        error: result['error'],
      );
    } catch (e) {
      return PostResult(
        success: false,
        platformId: 'instagram',
        error: e.toString(),
      );
    }
  }

  // ========== Private Methods - Share Intent ==========

  Future<PostResult> _postViaShare({
    required SocialPlatformInfo platform,
    String? text,
    File? mediaFile,
  }) async {
    try {
      print('📲 Sharing to ${platform.name} via Share Intent');

      if (mediaFile != null) {
        // Share with file
        final xFile = XFile(mediaFile.path);
        await Share.shareXFiles(
          [xFile],
          text: text ?? '',
          subject: 'مشاركة على ${platform.displayName}',
        );
      } else if (text != null && text.isNotEmpty) {
        // Share text only
        await Share.share(text, subject: 'مشاركة على ${platform.displayName}');
      } else {
        return PostResult(
          success: false,
          platformId: platform.id,
          error: 'لا يوجد محتوى للمشاركة',
        );
      }

      // Show success message
      Get.snackbar(
        'تم فتح ${platform.displayName}',
        'أكمل عملية النشر في التطبيق',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(
          int.parse('0xFF${platform.color}'),
        ).withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: Text(platform.icon, style: const TextStyle(fontSize: 24)),
      );

      return PostResult(
        success: true,
        platformId: platform.id,
        message: 'تم فتح ${platform.displayName}',
      );
    } catch (e) {
      return PostResult(
        success: false,
        platformId: platform.id,
        error: e.toString(),
      );
    }
  }

  // ========== Helper Methods ==========

  /// Get platform info by ID
  static SocialPlatformInfo? getPlatformInfo(String platformId) {
    try {
      return allPlatforms.firstWhere((p) => p.id == platformId);
    } catch (e) {
      return null;
    }
  }

  /// Get platforms that support specific media type
  static List<SocialPlatformInfo> getPlatformsByMediaType(MediaType mediaType) {
    return allPlatforms.where((p) {
      switch (mediaType) {
        case MediaType.text:
          return p.supportsText;
        case MediaType.image:
          return p.supportsImage;
        case MediaType.video:
          return p.supportsVideo;
      }
    }).toList();
  }
}

// ========== Models ==========

enum PostMethod { api, share }

enum MediaType { text, image, video }

class SocialPlatformInfo {
  final String id;
  final String name;
  final String displayName;
  final String icon;
  final String color;
  final PostMethod method;
  final bool supportsText;
  final bool supportsImage;
  final bool supportsVideo;

  const SocialPlatformInfo({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.method,
    required this.supportsText,
    required this.supportsImage,
    required this.supportsVideo,
  });
}

class PostResult {
  final bool success;
  final String platformId;
  final String? postId;
  final String? message;
  final String? error;

  PostResult({
    required this.success,
    required this.platformId,
    this.postId,
    this.message,
    this.error,
  });
}

class MultiPostResult {
  final List<PostResult> results;
  final int successCount;
  final int failedCount;
  final int totalCount;

  MultiPostResult({
    required this.results,
    required this.successCount,
    required this.failedCount,
    required this.totalCount,
  });

  bool get allSucceeded => successCount == totalCount;
  bool get someFailed => failedCount > 0;
  bool get allFailed => successCount == 0;
}
