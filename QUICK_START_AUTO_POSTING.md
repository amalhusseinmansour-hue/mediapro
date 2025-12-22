# 🚀 دليل البدء السريع - نظام النشر التلقائي

## ✅ ما تم إنجازه

### 1. شاشة الحسابات
- ✅ تم إزالة قسم "الحسابات المتصلة"
- ✅ الشاشة الآن تركز على الجدولة والأوتوميشن

### 2. Backend
- ✅ Model: `AutoScheduledPost.php`
- ✅ Migration: `2025_11_10_000002_create_auto_scheduled_posts_table.php`
- ✅ SQL File: `AUTO_SCHEDULED_POSTS_MIGRATION.sql` (للسيرفر)

### 3. التوثيق
- ✅ `AUTO_POSTING_SYSTEM.md` - توثيق شامل للنظام

---

## 📋 المتبقي للتنفيذ

### Backend (الأولوية 1)

#### 1. Controller
إنشاء: `backend/app/Http/Controllers/Api/AutoScheduledPostController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AutoScheduledPost;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AutoScheduledPostController extends Controller
{
    // 1. جلب جميع الجدولات للمستخدم
    public function index(Request $request, string $userId) {
        $posts = AutoScheduledPost::where('user_id', $userId)
            ->recent()
            ->paginate(20);

        return response()->json([
            'success' => true,
            'posts' => $posts->items(),
            'pagination' => [...]
        ]);
    }

    // 2. إنشاء جدولة جديدة
    public function store(Request $request) {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'content' => 'required|string',
            'platforms' => 'required|array',
            'schedule_time' => 'required|date',
            'recurrence_pattern' => 'required|in:once,daily,weekly,monthly,custom',
            // ...
        ]);

        $post = AutoScheduledPost::create($validated);
        return response()->json(['success' => true, 'post' => $post]);
    }

    // 3. تفعيل
    public function activate(int $id) {
        $post = AutoScheduledPost::findOrFail($id);
        $post->activate();
        return response()->json(['success' => true]);
    }

    // 4. إيقاف
    public function pause(int $id) {
        $post = AutoScheduledPost::findOrFail($id);
        $post->pause();
        return response()->json(['success' => true]);
    }

    // 5. المنشورات المستحقة للنشر
    public function getDueForPosting() {
        $posts = AutoScheduledPost::dueForPosting()->get();
        return response()->json(['success' => true, 'posts' => $posts]);
    }
}
```

#### 2. Routes
إضافة في `backend/routes/api.php`:

```php
// Auto Scheduled Posts
Route::prefix('auto-scheduled-posts')->group(function () {
    Route::get('/user/{userId}', [AutoScheduledPostController::class, 'index']);
    Route::post('/', [AutoScheduledPostController::class, 'store']);
    Route::get('/{id}', [AutoScheduledPostController::class, 'show']);
    Route::put('/{id}', [AutoScheduledPostController::class, 'update']);
    Route::delete('/{id}', [AutoScheduledPostController::class, 'delete']);
    Route::post('/{id}/activate', [AutoScheduledPostController::class, 'activate']);
    Route::post('/{id}/pause', [AutoScheduledPostController::class, 'pause']);
    Route::get('/due/posting', [AutoScheduledPostController::class, 'getDueForPosting']);
});
```

#### 3. Cron Job (مهم جداً!)
إنشاء: `backend/app/Console/Commands/ProcessAutoScheduledPosts.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\AutoScheduledPost;
use App\Services\MultiPlatformPostService;

class ProcessAutoScheduledPosts extends Command
{
    protected $signature = 'auto-posts:process';
    protected $description = 'Process auto scheduled posts';

    public function handle()
    {
        $posts = AutoScheduledPost::dueForPosting()->get();

        foreach ($posts as $post) {
            try {
                // نشر على كل منصة
                foreach ($post->platforms as $platform) {
                    // استدعاء API النشر
                    // MultiPlatformPostService::post(...)
                }

                // تسجيل النشر
                $post->markAsPosted();

                $this->info("Posted: {$post->id}");
            } catch (\Exception $e) {
                $this->error("Failed: {$post->id} - {$e->getMessage()}");
            }
        }
    }
}
```

تفعيل في `backend/app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule)
{
    $schedule->command('auto-posts:process')
             ->everyMinute(); // كل دقيقة
}
```

---

### Flutter (الأولوية 2)

#### 1. Model
إنشاء: `lib/models/auto_scheduled_post.dart`

```dart
class AutoScheduledPost {
  final int id;
  final String userId;
  final String content;
  final List<String> mediaUrls;
  final List<String> platforms;
  final DateTime scheduleTime;
  final String recurrencePattern;
  final int? recurrenceInterval;
  final DateTime? recurrenceEndDate;
  final bool isActive;
  final String status;
  final DateTime? lastPostedAt;
  final DateTime? nextPostAt;
  final int postCount;

  AutoScheduledPost({required this.id, ...});

  factory AutoScheduledPost.fromJson(Map<String, dynamic> json) {
    return AutoScheduledPost(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      platforms: List<String>.from(json['platforms'] ?? []),
      scheduleTime: DateTime.parse(json['schedule_time']),
      recurrencePattern: json['recurrence_pattern'],
      recurrenceInterval: json['recurrence_interval'],
      recurrenceEndDate: json['recurrence_end_date'] != null
          ? DateTime.parse(json['recurrence_end_date'])
          : null,
      isActive: json['is_active'] ?? false,
      status: json['status'] ?? 'pending',
      lastPostedAt: json['last_posted_at'] != null
          ? DateTime.parse(json['last_posted_at'])
          : null,
      nextPostAt: json['next_post_at'] != null
          ? DateTime.parse(json['next_post_at'])
          : null,
      postCount: json['post_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'media_urls': mediaUrls,
      'platforms': platforms,
      'schedule_time': scheduleTime.toIso8601String(),
      'recurrence_pattern': recurrencePattern,
      'recurrence_interval': recurrenceInterval,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      'is_active': isActive,
    };
  }
}
```

#### 2. Service
إنشاء: `lib/services/auto_posting_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AutoPostingService extends GetxService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final RxList<AutoScheduledPost> posts = <AutoScheduledPost>[].obs;
  final RxBool isLoading = false.obs;

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
        'media_urls': mediaUrls,
        'platforms': platforms,
        'schedule_time': scheduleTime.toIso8601String(),
        'recurrence_pattern': recurrencePattern,
        'recurrence_interval': recurrenceInterval,
        'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      });

      if (response.statusCode == 201) {
        return {'success': true, 'post': AutoScheduledPost.fromJson(response.data['post'])};
      }
      return {'success': false};
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'حدث خطأ'};
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserPosts(String userId) async {
    try {
      isLoading.value = true;
      final response = await _dio.get('/auto-scheduled-posts/user/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['posts'];
        posts.value = data.map((json) => AutoScheduledPost.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> activatePost(int id) async {
    try {
      final response = await _dio.post('/auto-scheduled-posts/$id/activate');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> pausePost(int id) async {
    try {
      final response = await _dio.post('/auto-scheduled-posts/$id/pause');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePost(int id) async {
    try {
      final response = await _dio.delete('/auto-scheduled-posts/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

#### 3. تهيئة Service
في `lib/main.dart`:

```dart
Get.put(AutoPostingService());
```

#### 4. الشاشات
- `lib/screens/automation/create_auto_post_screen.dart` - إنشاء جدولة
- `lib/screens/automation/auto_posts_list_screen.dart` - عرض الجدولات

---

## ⚡ الخطوات السريعة للتنفيذ

### 1. تشغيل Migration (Backend)
```bash
# على السيرفر
mysql -u username -p database_name < backend/database/migrations/AUTO_SCHEDULED_POSTS_MIGRATION.sql

# أو محلياً
cd backend
php artisan migrate
```

### 2. إنشاء Controller + Routes (Backend)
- أنشئ `AutoScheduledPostController.php`
- أضف Routes في `api.php`
- أنشئ Cron Command
- فعّل في `Kernel.php`

### 3. Flutter
- أنشئ Model
- أنشئ Service
- هيئ Service في main.dart
- أنشئ الشاشات

### 4. اختبار
- اختبر إنشاء جدولة
- اختبر التفعيل/الإيقاف
- تأكد من عمل Cron Job

---

## 🎯 ميزات مطلوبة في الشاشات

### شاشة الإنشاء
- [ ] حقل المحتوى (TextArea)
- [ ] رفع صور/فيديوهات
- [ ] اختيار منصات (Checkboxes)
- [ ] تحديد وقت النشر (DateTimePicker)
- [ ] اختيار نمط التكرار (Radio Buttons)
- [ ] تحديد فترة التكرار (Number Input)
- [ ] تاريخ الانتهاء (DatePicker اختياري)
- [ ] زر الحفظ

### شاشة القائمة
- [ ] عرض جميع الجدولات
- [ ] فلترة حسب الحالة (Tabs)
- [ ] عرض حالة كل جدولة (Badge)
- [ ] عرض الوقت القادم
- [ ] عرض عدد المرات المنشورة
- [ ] أزرار (تفعيل، إيقاف، تعديل، حذف)
- [ ] Pull to Refresh

---

## 📱 تصميم الكود المقترح

### بنية المجلدات
```
lib/
├── models/
│   └── auto_scheduled_post.dart
├── services/
│   └── auto_posting_service.dart
└── screens/
    └── automation/
        ├── create_auto_post_screen.dart
        └── auto_posts_list_screen.dart

backend/
├── app/
│   ├── Models/
│   │   └── AutoScheduledPost.php
│   ├── Http/Controllers/Api/
│   │   └── AutoScheduledPostController.php
│   └── Console/Commands/
│       └── ProcessAutoScheduledPosts.php
└── database/migrations/
    └── 2025_11_10_000002_create_auto_scheduled_posts_table.php
```

---

## ⚠️ ملاحظات مهمة

1. **Cron Job ضروري**: بدون Cron Job لن يعمل النشر التلقائي!
2. **Timezone**: تأكد من إعدادات المنطقة الزمنية في Laravel
3. **صلاحيات API**: تحقق من صلاحيات الوصول للمنصات
4. **الأخطاء**: سجل الأخطاء في `metadata` للتتبع
5. **الإشعارات**: أضف إشعارات للمستخدم عند النشر

---

## 🔥 أسرع طريقة للبدء

إذا كنت تريد البدء بسرعة:

1. نفذ Migration على قاعدة البيانات
2. أنشئ Controller بسيط للـ CRUD
3. أضف Routes
4. أنشئ شاشة بسيطة في Flutter لاختبار النظام
5. ثم طور تدريجياً

---

تحديث: 2025-11-10
