import 'package:get/get.dart';
import '../models/community_post_model.dart';
import 'api_service.dart';

class CommunityPostService extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<CommunityPostModel> communityPosts = <CommunityPostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCommunityPosts();
  }

  /// Load community posts
  Future<void> loadCommunityPosts({int page = 1, int perPage = 20}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(
        '/community/posts',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
          'visibility': 'public',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> posts = response['data'] as List<dynamic>;
        communityPosts.value = posts.map((p) {
          final postData = p as Map<String, dynamic>;
          return CommunityPostModel(
            id: postData['id'].toString(),
            authorName: postData['user']?['name'] ?? 'Unknown',
            authorAvatar: postData['user']?['profile_image'] ?? '',
            content: postData['content'] ?? '',
            images: List<String>.from(postData['media_urls'] ?? []),
            platform: 'community',
            likes: postData['likes_count'] ?? 0,
            comments: postData['comments_count'] ?? 0,
            shares: postData['shares_count'] ?? 0,
            createdAt: postData['created_at'] != null
                ? DateTime.parse(postData['created_at'])
                : DateTime.now(),
            hashtags: List<String>.from(postData['tags'] ?? []),
          );
        }).toList();

        print('✅ Loaded ${communityPosts.length} community posts');
      } else {
        errorMessage.value = response['message'] ?? 'فشل تحميل المنشورات';
        print('⚠️ Failed to load posts: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error loading community posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new community post
  Future<bool> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
    String visibility = 'public',
  }) async {
    try {
      isPosting.value = true;
      errorMessage.value = '';

      final response = await _apiService.post(
        '/community/posts',
        data: {
          'content': content,
          'media_urls': mediaUrls ?? [],
          'tags': tags ?? [],
          'visibility': visibility,
        },
      );

      if (response['success'] == true) {
        print('✅ Post created successfully');
        // Reload posts to show the new one
        await loadCommunityPosts();
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل إنشاء المنشور';
        print('⚠️ Failed to create post: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error creating post: $e');
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  /// Update a community post
  Future<bool> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
    String? visibility,
  }) async {
    try {
      isPosting.value = true;
      errorMessage.value = '';

      final updateData = <String, dynamic>{'content': content};

      if (mediaUrls != null) {
        updateData['media_urls'] = mediaUrls;
      }
      if (tags != null) {
        updateData['tags'] = tags;
      }
      if (visibility != null) {
        updateData['visibility'] = visibility;
      }

      final response = await _apiService.put(
        '/community/posts/$postId',
        data: updateData,
      );

      if (response['success'] == true) {
        print('✅ Post updated successfully');
        await loadCommunityPosts();
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل تحديث المنشور';
        print('⚠️ Failed to update post: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error updating post: $e');
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  /// Delete a community post
  Future<bool> deletePost(String postId) async {
    try {
      isPosting.value = true;
      errorMessage.value = '';

      final response = await _apiService.delete('/community/posts/$postId');

      if (response['success'] == true) {
        print('✅ Post deleted successfully');
        await loadCommunityPosts();
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل حذف المنشور';
        print('⚠️ Failed to delete post: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error deleting post: $e');
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  /// Pin a post
  Future<bool> pinPost(String postId) async {
    try {
      final response = await _apiService.post('/community/posts/$postId/pin');

      if (response['success'] == true) {
        print('✅ Post pinned successfully');
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل تثبيت المنشور';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error pinning post: $e');
      return false;
    }
  }

  /// Unpin a post
  Future<bool> unpinPost(String postId) async {
    try {
      final response = await _apiService.post('/community/posts/$postId/unpin');

      if (response['success'] == true) {
        print('✅ Post unpinned successfully');
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل إلغاء تثبيت المنشور';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error unpinning post: $e');
      return false;
    }
  }

  /// Get user's community posts
  Future<List<CommunityPostModel>> getUserPosts(
    String userId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/community/posts/user/$userId',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> posts = response['data'] as List<dynamic>;
        return posts.map((p) {
          final postData = p as Map<String, dynamic>;
          return CommunityPostModel(
            id: postData['id'].toString(),
            authorName: postData['user']?['name'] ?? 'Unknown',
            authorAvatar: postData['user']?['profile_image'] ?? '',
            content: postData['content'] ?? '',
            images: List<String>.from(postData['media_urls'] ?? []),
            platform: 'community',
            likes: postData['likes_count'] ?? 0,
            comments: postData['comments_count'] ?? 0,
            shares: postData['shares_count'] ?? 0,
            createdAt: postData['created_at'] != null
                ? DateTime.parse(postData['created_at'])
                : DateTime.now(),
            hashtags: List<String>.from(postData['tags'] ?? []),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error getting user posts: $e');
      return [];
    }
  }

  // ==================== INTERACTIONS ====================

  /// Like a post
  Future<bool> likePost(String postId) async {
    try {
      final response = await _apiService.post('/community/posts/$postId/like');

      if (response['success'] == true) {
        print('✅ Post liked successfully');
        // Update the post in the list
        final postIndex = communityPosts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final post = communityPosts[postIndex];
          communityPosts[postIndex] = CommunityPostModel(
            id: post.id,
            authorName: post.authorName,
            authorAvatar: post.authorAvatar,
            content: post.content,
            images: post.images,
            platform: post.platform,
            likes: post.likes + 1,
            comments: post.comments,
            shares: post.shares,
            createdAt: post.createdAt,
            hashtags: post.hashtags,
            isVerified: post.isVerified,
            category: post.category,
          );
        }
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل الإعجاب بالمنشور';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error liking post: $e');
      return false;
    }
  }

  /// Unlike a post
  Future<bool> unlikePost(String postId) async {
    try {
      final response = await _apiService.delete('/community/posts/$postId/like');

      if (response['success'] == true) {
        print('✅ Post unliked successfully');
        // Update the post in the list
        final postIndex = communityPosts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final post = communityPosts[postIndex];
          communityPosts[postIndex] = CommunityPostModel(
            id: post.id,
            authorName: post.authorName,
            authorAvatar: post.authorAvatar,
            content: post.content,
            images: post.images,
            platform: post.platform,
            likes: post.likes > 0 ? post.likes - 1 : 0,
            comments: post.comments,
            shares: post.shares,
            createdAt: post.createdAt,
            hashtags: post.hashtags,
            isVerified: post.isVerified,
            category: post.category,
          );
        }
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل إلغاء الإعجاب';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error unliking post: $e');
      return false;
    }
  }

  /// Get comments for a post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _apiService.get('/community/posts/$postId/comments');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> comments = response['data'] as List<dynamic>;
        return comments.map((c) => c as Map<String, dynamic>).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error getting comments: $e');
      return [];
    }
  }

  /// Add a comment to a post
  Future<bool> addComment(String postId, String comment) async {
    try {
      final response = await _apiService.post(
        '/community/posts/$postId/comments',
        data: {'comment': comment},
      );

      if (response['success'] == true) {
        print('✅ Comment added successfully');
        // Update the post in the list
        final postIndex = communityPosts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final post = communityPosts[postIndex];
          communityPosts[postIndex] = CommunityPostModel(
            id: post.id,
            authorName: post.authorName,
            authorAvatar: post.authorAvatar,
            content: post.content,
            images: post.images,
            platform: post.platform,
            likes: post.likes,
            comments: post.comments + 1,
            shares: post.shares,
            createdAt: post.createdAt,
            hashtags: post.hashtags,
            isVerified: post.isVerified,
            category: post.category,
          );
        }
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل إضافة التعليق';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error adding comment: $e');
      return false;
    }
  }

  /// Share a post
  Future<bool> sharePost(String postId) async {
    try {
      final response = await _apiService.post('/community/posts/$postId/share');

      if (response['success'] == true) {
        print('✅ Post shared successfully');
        // Update the post in the list
        final postIndex = communityPosts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final post = communityPosts[postIndex];
          communityPosts[postIndex] = CommunityPostModel(
            id: post.id,
            authorName: post.authorName,
            authorAvatar: post.authorAvatar,
            content: post.content,
            images: post.images,
            platform: post.platform,
            likes: post.likes,
            comments: post.comments,
            shares: post.shares + 1,
            createdAt: post.createdAt,
            hashtags: post.hashtags,
            isVerified: post.isVerified,
            category: post.category,
          );
        }
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'فشل مشاركة المنشور';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error sharing post: $e');
      return false;
    }
  }
}
