# 📱 Flutter Implementation Guide

## 📁 Project Structure

```
lib/
├── models/
│   ├── social_account.dart
│   ├── social_post.dart
│   └── scheduled_post.dart
├── services/
│   ├── api_service.dart
│   └── social_media_service.dart
├── screens/
│   ├── accounts/
│   │   ├── accounts_management_screen.dart
│   │   └── add_account_dialog.dart
│   ├── posts/
│   │   ├── create_post_screen.dart
│   │   ├── post_history_screen.dart
│   │   └── scheduled_posts_screen.dart
│   └── ai/
│       └── ai_content_generator_screen.dart
└── main.dart
```

---

## 1️⃣ Models

### social_account.dart

```dart
class SocialAccount {
  final int id;
  final String platform;
  final String? accountName;
  final String? platformAccountId;
  final String status;
  final DateTime createdAt;

  SocialAccount({
    required this.id,
    required this.platform,
    this.accountName,
    this.platformAccountId,
    required this.status,
    required this.createdAt,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      id: json['id'],
      platform: json['platform'],
      accountName: json['account_name'],
      platformAccountId: json['platform_account_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

### social_post.dart

```dart
class SocialPost {
  final int id;
  final String content;
  final String platform;
  final List<String>? mediaUrls;
  final String status;
  final DateTime postedAt;
  final String? postUrl;

  SocialPost({
    required this.id,
    required this.content,
    required this.platform,
    this.mediaUrls,
    required this.status,
    required this.postedAt,
    this.postUrl,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      content: json['content'],
      platform: json['platform'],
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'])
          : null,
      status: json['status'],
      postedAt: DateTime.parse(json['posted_at']),
      postUrl: json['post_url'],
    );
  }
}
```

---

## 2️⃣ API Service

### api_service.dart

```dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({required this.baseUrl}) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // GET Request
  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(endpoint, queryParameters: params);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response!.data['message'] ?? 'حدث خطأ';
      }
      return 'خطأ في الاتصال بالسيرفر';
    }
    return error.toString();
  }
}
```

---

## 3️⃣ Social Media Service

### social_media_service.dart

```dart
import 'api_service.dart';

class SocialMediaService {
  final ApiService _api;

  SocialMediaService(this._api);

  // Get connected accounts
  Future<List<SocialAccount>> getAccounts() async {
    final response = await _api.get('/api/social/accounts');
    final List data = response.data['data'];
    return data.map((json) => SocialAccount.fromJson(json)).toList();
  }

  // Create post
  Future<Map<String, dynamic>> createPost({
    required String content,
    required List<String> platforms,
    List<String>? mediaUrls,
    DateTime? scheduledAt,
  }) async {
    final response = await _api.post('/api/social/post', data: {
      'content': content,
      'platforms': platforms,
      'media_urls': mediaUrls,
      'scheduled_at': scheduledAt?.toIso8601String(),
    });
    return response.data;
  }

  // Generate AI content
  Future<String> generateAIContent({
    required String topic,
    String platform = 'general',
    String tone = 'professional',
  }) async {
    final response = await _api.post('/api/social/ai-content', data: {
      'topic': topic,
      'platform': platform,
      'tone': tone,
    });
    return response.data['data']['content'];
  }

  // Get post history
  Future<List<SocialPost>> getPosts({int page = 1}) async {
    final response = await _api.get('/api/social/posts', params: {'page': page});
    final List data = response.data['data']['data'];
    return data.map((json) => SocialPost.fromJson(json)).toList();
  }

  // Get scheduled posts
  Future<List<ScheduledPost>> getScheduledPosts() async {
    final response = await _api.get('/api/social/scheduled-posts');
    final List data = response.data['data']['data'];
    return data.map((json) => ScheduledPost.fromJson(json)).toList();
  }

  // Cancel scheduled post
  Future<void> cancelScheduledPost(int id) async {
    await _api.delete('/api/social/scheduled-posts/$id');
  }
}
```

---

## 4️⃣ UI Implementation

The complete Flutter UI implementation is provided in the following files:

- `create_post_screen_example.dart` - Full example with AI generation
- `accounts_management_screen.dart` - Manage connected accounts
- `post_history_screen.dart` - View published posts
- `scheduled_posts_screen.dart` - View and cancel scheduled posts

---

## 📦 Required Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP & API
  dio: ^5.4.0

  # State Management
  get: ^4.6.6

  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0

  # Date & Time
  intl: ^0.19.0

  # Image Picker
  image_picker: ^1.0.7

  # File Picker
  file_picker: ^6.1.1

  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

---

## 🎯 Usage Flow

### 1. Initialize Services

```dart
void main() {
  final apiService = ApiService(baseUrl: 'https://your-api.com');
  final socialMediaService = SocialMediaService(apiService);

  // Set authentication token
  apiService.setToken('your_user_token');

  runApp(MyApp());
}
```

### 2. Create Immediate Post

```dart
await socialMediaService.createPost(
  content: 'Hello World!',
  platforms: ['facebook', 'instagram'],
  mediaUrls: ['https://example.com/image.jpg'],
);
```

### 3. Schedule Post

```dart
await socialMediaService.createPost(
  content: 'Scheduled post',
  platforms: ['twitter'],
  scheduledAt: DateTime.now().add(Duration(hours: 2)),
);
```

### 4. Generate AI Content

```dart
String content = await socialMediaService.generateAIContent(
  topic: 'الذكاء الاصطناعي في التسويق',
  platform: 'linkedin',
  tone: 'professional',
);
```

---

## ✅ Features Checklist

- [x] Account management (view, delete)
- [x] Create immediate posts
- [x] Schedule posts for later
- [x] Multi-platform posting
- [x] AI content generation
- [x] Post history view
- [x] Scheduled posts management
- [x] Media upload support
- [x] Error handling
- [x] Loading states

---

## 🔐 Security Notes

- Store auth tokens in `flutter_secure_storage`
- Never hardcode API keys
- Use HTTPS for all requests
- Implement token refresh mechanism
- Validate user input before sending

---

## 🎨 UI/UX Best Practices

1. **Loading States**: Show spinners during API calls
2. **Error Messages**: Display user-friendly Arabic error messages
3. **Success Feedback**: Show snackbars on successful operations
4. **Image Preview**: Preview selected images before upload
5. **Character Counter**: Show remaining characters for Twitter
6. **Platform Icons**: Use recognizable icons for each platform
7. **Schedule Picker**: Easy-to-use date/time picker
8. **Draft Saving**: Save posts as drafts locally

---

## 🚀 Next Steps

1. Implement account connection from admin dashboard
2. Add post analytics and insights
3. Implement media library
4. Add post templates
5. Implement bulk scheduling
6. Add post approval workflow

