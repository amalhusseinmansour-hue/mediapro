import 'package:get/get.dart';
import '../models/community_post_model.dart';
import '../services/community_post_service.dart';

class CommunityController extends GetxController {
  final CommunityPostService _communityPostService = CommunityPostService();

  final RxList<CommunityPostModel> communityPosts = <CommunityPostModel>[].obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool isCreatingPost = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedVisibility = 'public'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCommunityPosts();
  }

  /// Load all community posts
  Future<void> loadCommunityPosts({int page = 1, int perPage = 20}) async {
    try {
      isLoadingPosts.value = true;
      errorMessage.value = '';
      await _communityPostService.loadCommunityPosts(
        page: page,
        perPage: perPage,
      );
      communityPosts.value = _communityPostService.communityPosts;
    } catch (e) {
      errorMessage.value = 'فشل تحميل المنشورات: $e';
      print('❌ Error loading posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  /// Create a new community post
  Future<bool> createCommunityPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
    String visibility = 'public',
  }) async {
    try {
      isCreatingPost.value = true;
      errorMessage.value = '';

      final success = await _communityPostService.createPost(
        content: content,
        mediaUrls: mediaUrls,
        tags: tags,
        visibility: visibility,
      );

      if (success) {
        // Reload posts after creating
        await loadCommunityPosts();
      }

      return success;
    } catch (e) {
      errorMessage.value = 'خطأ في إنشاء المنشور: $e';
      print('❌ Error creating post: $e');
      return false;
    } finally {
      isCreatingPost.value = false;
    }
  }

  /// Update a community post
  Future<bool> updateCommunityPost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
    String? visibility,
  }) async {
    try {
      isCreatingPost.value = true;
      errorMessage.value = '';

      final success = await _communityPostService.updatePost(
        postId: postId,
        content: content,
        mediaUrls: mediaUrls,
        tags: tags,
        visibility: visibility,
      );

      if (success) {
        await loadCommunityPosts();
      }

      return success;
    } catch (e) {
      errorMessage.value = 'خطأ في تحديث المنشور: $e';
      print('❌ Error updating post: $e');
      return false;
    } finally {
      isCreatingPost.value = false;
    }
  }

  /// Delete a community post
  Future<bool> deleteCommunityPost(String postId) async {
    try {
      isCreatingPost.value = true;
      errorMessage.value = '';

      final success = await _communityPostService.deletePost(postId);

      if (success) {
        await loadCommunityPosts();
      }

      return success;
    } catch (e) {
      errorMessage.value = 'خطأ في حذف المنشور: $e';
      print('❌ Error deleting post: $e');
      return false;
    } finally {
      isCreatingPost.value = false;
    }
  }

  /// Pin a post
  Future<bool> pinPost(String postId) async {
    try {
      return await _communityPostService.pinPost(postId);
    } catch (e) {
      errorMessage.value = 'خطأ في تثبيت المنشور: $e';
      print('❌ Error pinning post: $e');
      return false;
    }
  }

  /// Unpin a post
  Future<bool> unpinPost(String postId) async {
    try {
      return await _communityPostService.unpinPost(postId);
    } catch (e) {
      errorMessage.value = 'خطأ في إلغاء تثبيت المنشور: $e';
      print('❌ Error unpinning post: $e');
      return false;
    }
  }

  /// Get user's posts
  Future<List<CommunityPostModel>> getUserPosts(
    String userId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await _communityPostService.getUserPosts(
        userId,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      errorMessage.value = 'خطأ في تحميل منشورات المستخدم: $e';
      print('❌ Error getting user posts: $e');
      return [];
    }
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    await loadCommunityPosts();
  }
}
