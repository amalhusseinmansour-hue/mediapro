import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../core/config/api_config.dart';
import '../models/auto_scheduled_post.dart';
import 'auth_service.dart';

class AutoPostingService extends GetxService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.backendBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final AuthService _authService = Get.find<AuthService>();
  final RxList<AutoScheduledPost> posts = <AutoScheduledPost>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = _authService.currentUser.value?.id;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('Auto Posting API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Create a new auto scheduled post
  Future<Map<String, dynamic>> createAutoPost({
    required String userId,
    required String content,
    List<String>? mediaUrls,
    required List<String> platforms,
    required DateTime scheduleTime,
    required String recurrencePattern,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
  }) async {
    try {
      isLoading.value = true;

      final response = await _dio.post('/auto-scheduled-posts', data: {
        'user_id': userId,
        'content': content,
        'media_urls': mediaUrls ?? [],
        'platforms': platforms,
        'schedule_time': scheduleTime.toIso8601String(),
        'recurrence_pattern': recurrencePattern,
        'recurrence_interval': recurrenceInterval,
        'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        final post = AutoScheduledPost.fromJson(response.data['post']);
        posts.insert(0, post);

        return {
          'success': true,
          'message': response.data['message'] ?? 'تم إنشاء الجدولة بنجاح',
          'post': post,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'فشل إنشاء الجدولة',
        };
      }
    } on DioException catch (e) {
      print('Create auto post error: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'حدث خطأ أثناء إنشاء الجدولة',
      };
    } catch (e) {
      print('Create auto post error: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Get user's auto scheduled posts
  Future<void> getUserPosts(String userId, {String? status}) async {
    try {
      isLoading.value = true;

      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/auto-scheduled-posts/user/$userId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> postsData = response.data['posts'] ?? [];
        posts.value = postsData
            .map((json) => AutoScheduledPost.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      print('Get user posts error: ${e.message}');
      posts.value = [];
    } catch (e) {
      print('Get user posts error: $e');
      posts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Get a single post details
  Future<AutoScheduledPost?> getPostDetails(int id) async {
    try {
      final response = await _dio.get('/auto-scheduled-posts/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AutoScheduledPost.fromJson(response.data['post']);
      }
      return null;
    } on DioException catch (e) {
      print('Get post details error: ${e.message}');
      return null;
    } catch (e) {
      print('Get post details error: $e');
      return null;
    }
  }

  /// Update a post
  Future<Map<String, dynamic>> updatePost(
    int id, {
    String? content,
    List<String>? mediaUrls,
    List<String>? platforms,
    DateTime? scheduleTime,
    String? recurrencePattern,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
  }) async {
    try {
      isLoading.value = true;

      final data = <String, dynamic>{};
      if (content != null) data['content'] = content;
      if (mediaUrls != null) data['media_urls'] = mediaUrls;
      if (platforms != null) data['platforms'] = platforms;
      if (scheduleTime != null) data['schedule_time'] = scheduleTime.toIso8601String();
      if (recurrencePattern != null) data['recurrence_pattern'] = recurrencePattern;
      if (recurrenceInterval != null) data['recurrence_interval'] = recurrenceInterval;
      if (recurrenceEndDate != null) data['recurrence_end_date'] = recurrenceEndDate.toIso8601String();

      final response = await _dio.put('/auto-scheduled-posts/$id', data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update in local list
        final index = posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          posts[index] = AutoScheduledPost.fromJson(response.data['post']);
        }

        return {
          'success': true,
          'message': response.data['message'] ?? 'تم تحديث الجدولة بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'فشل تحديث الجدولة',
        };
      }
    } on DioException catch (e) {
      print('Update post error: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'حدث خطأ أثناء التحديث',
      };
    } catch (e) {
      print('Update post error: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Activate a post
  Future<bool> activatePost(int id) async {
    try {
      final response = await _dio.post('/auto-scheduled-posts/$id/activate');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update in local list
        final index = posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          posts[index] = AutoScheduledPost.fromJson(response.data['post']);
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Activate post error: ${e.message}');
      return false;
    } catch (e) {
      print('Activate post error: $e');
      return false;
    }
  }

  /// Pause a post
  Future<bool> pausePost(int id) async {
    try {
      final response = await _dio.post('/auto-scheduled-posts/$id/pause');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update in local list
        final index = posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          posts[index] = AutoScheduledPost.fromJson(response.data['post']);
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Pause post error: ${e.message}');
      return false;
    } catch (e) {
      print('Pause post error: $e');
      return false;
    }
  }

  /// Delete a post
  Future<bool> deletePost(int id) async {
    try {
      final response = await _dio.delete('/auto-scheduled-posts/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Remove from local list
        posts.removeWhere((p) => p.id == id);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Delete post error: ${e.message}');
      return false;
    } catch (e) {
      print('Delete post error: $e');
      return false;
    }
  }

  /// Get active posts
  List<AutoScheduledPost> get activePosts {
    return posts.where((p) => p.isActive).toList();
  }

  /// Get pending posts
  List<AutoScheduledPost> get pendingPosts {
    return posts.where((p) => p.isPending).toList();
  }

  /// Get paused posts
  List<AutoScheduledPost> get pausedPosts {
    return posts.where((p) => p.isPaused).toList();
  }

  /// Get completed posts
  List<AutoScheduledPost> get completedPosts {
    return posts.where((p) => p.isCompleted).toList();
  }

  /// Clear all data
  void clear() {
    posts.clear();
  }
}
