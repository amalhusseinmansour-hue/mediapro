# 🔌 دليل API الشامل

## قائمة الـ Endpoints

### Authentication
```
POST   /api/auth/login
POST   /api/auth/register
POST   /api/auth/logout
POST   /api/auth/refresh-token
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
```

### Users
```
GET    /api/users/{id}
GET    /api/users/profile
PUT    /api/users/{id}
DELETE /api/users/{id}
POST   /api/users/change-password
```

### Social Accounts
```
GET    /api/social-accounts
POST   /api/social-accounts
PUT    /api/social-accounts/{id}
DELETE /api/social-accounts/{id}
GET    /api/social-accounts/{id}/status
```

### Posts & Scheduling
```
GET    /api/posts
POST   /api/posts
PUT    /api/posts/{id}
DELETE /api/posts/{id}
GET    /api/posts/{id}

POST   /api/posts/schedule
GET    /api/posts/scheduled
PUT    /api/posts/scheduled/{id}
DELETE /api/posts/scheduled/{id}
POST   /api/posts/publish
GET    /api/posts/published
```

### Analytics
```
GET    /api/analytics/overview
GET    /api/analytics/usage
GET    /api/analytics/posts
GET    /api/analytics/platforms
GET    /api/analytics/check-limit/{type}
```

### AI Services
```
POST   /api/ai/generate-text
POST   /api/ai/generate-image
POST   /api/ai/generate-hashtags
POST   /api/ai/generate-ideas
GET    /api/ai/usage
```

### Subscriptions
```
GET    /api/subscriptions
GET    /api/subscriptions/{id}
POST   /api/subscriptions/upgrade
POST   /api/subscriptions/cancel
GET    /api/subscriptions/current
```

### Payments
```
POST   /api/payments/process
GET    /api/payments/history
GET    /api/payments/{id}
POST   /api/payments/cancel
```

### Analytics (متقدم)
```
GET    /api/analytics/engagement
GET    /api/analytics/growth
GET    /api/analytics/export
POST   /api/analytics/report
```

## أمثلة الاستخدام

### التسجيل

```dart
final response = await dio.post(
  '/api/auth/login',
  data: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);

// النتيجة
{
  'success': true,
  'user': {
    'id': 1,
    'name': 'Ahmed',
    'email': 'user@example.com',
  },
  'token': 'eyJhbGc...',
  'expires_in': 86400,
}
```

### إنشاء منشور

```dart
final response = await dio.post(
  '/api/posts',
  data: {
    'content': 'محتوى المنشور',
    'platforms': ['facebook', 'instagram'],
    'scheduled_at': '2025-11-20 10:00:00',
    'media_urls': ['https://...'],
  },
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
    },
  ),
);
```

### الحصول على التحليلات

```dart
final response = await dio.get(
  '/api/analytics/overview',
  queryParameters: {
    'date_from': '2025-11-01',
    'date_to': '2025-11-30',
    'platforms': 'facebook,instagram',
    'metrics': 'views,engagements',
  },
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
    },
  ),
);
```

### توليد محتوى بالذكاء الاصطناعي

```dart
final response = await dio.post(
  '/api/ai/generate-text',
  data: {
    'prompt': 'أكتب نص تسويقي لمنتج جديد',
    'tone': 'professional',
    'language': 'ar',
  },
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
    },
  ),
);

// النتيجة
{
  'success': true,
  'generated_text': 'نص مولد بواسطة AI...',
  'tokens_used': 50,
}
```

## معالجة الأخطاء

### الأخطاء الشائعة

| Code | Message | السبب |
|------|---------|--------|
| 400 | Bad Request | البيانات المرسلة غير صحيحة |
| 401 | Unauthorized | التوكن غير صحيح أو انتهت الصلاحية |
| 403 | Forbidden | لا توجد صلاحية للوصول |
| 404 | Not Found | المورد غير موجود |
| 429 | Too Many Requests | تم تجاوز حد الطلبات |
| 500 | Internal Server Error | خطأ في الخادم |

### التعامل مع الأخطاء

```dart
try {
  final response = await dio.post(
    '/api/posts',
    data: postData,
  );
} on DioException catch (error) {
  if (error.response?.statusCode == 401) {
    // التوكن انتهى - إعادة تحميل
    await refreshToken();
  } else if (error.response?.statusCode == 429) {
    // تم تجاوز حد الطلبات
    showError('الرجاء الانتظار قبل المحاولة مجدداً');
  } else {
    // خطأ عام
    showError(error.message);
  }
} catch (error) {
  // خطأ غير معروف
  logger.error('Unexpected error: $error');
}
```

## Authentication

### الحصول على التوكن

```dart
final token = await security.readSecure('auth_token');

// أو من خلال LoginResponse
final loginResponse = await api.login(email, password);
final token = loginResponse.token;

// حفظ التوكن بأمان
await security.saveSecure('auth_token', token);
```

### تحديث التوكن

```dart
final refreshToken = await security.readSecure('refresh_token');

final response = await dio.post(
  '/api/auth/refresh-token',
  data: {
    'refresh_token': refreshToken,
  },
);

// حفظ التوكن الجديد
await security.saveSecure('auth_token', response.data['token']);
```

### البيانات المطلوبة في كل طلب

```dart
options: Options(
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '1.0',
  },
)
```

## Rate Limiting

### الحدود المسموحة

| Endpoint | الحد الأقصى | الفترة |
|----------|-----------|--------|
| `/api/auth/login` | 5 | دقيقة |
| `/api/posts` | 30 | ساعة |
| `/api/ai/*` | 100 | يوم |
| `/api/analytics/*` | 500 | يوم |
| General | 60 | دقيقة |

### التعامل مع Rate Limiting

```dart
if (error.response?.statusCode == 429) {
  final retryAfter = int.tryParse(
    error.response?.headers.value('retry-after') ?? '60',
  ) ?? 60;

  print('الرجاء الانتظار $retryAfter ثانية');
}
```

## Pagination

### الطلب

```dart
final response = await dio.get(
  '/api/posts',
  queryParameters: {
    'page': 1,
    'per_page': 20,
  },
);
```

### الاستجابة

```json
{
  "data": [...],
  "pagination": {
    "total": 100,
    "count": 20,
    "per_page": 20,
    "current_page": 1,
    "total_pages": 5,
    "next_page": 2,
    "prev_page": null
  }
}
```

## Filtering & Sorting

### الفلترة

```dart
queryParameters: {
  'filter[status]': 'published',
  'filter[date_from]': '2025-11-01',
  'filter[platforms]': 'facebook,instagram',
}
```

### الترتيب

```dart
queryParameters: {
  'sort': '-created_at', // تنازلي
  // أو
  'sort': 'views',  // تصاعدي
}
```

## الملخص

✅ **الميزات:**
- توثيق شامل
- أمثلة عملية
- معالجة أخطاء موحدة
- Rate limiting
- Pagination
- Filtering

📊 **الإحصائيات:**
- 50+ Endpoint
- 8 منصات اجتماعية
- 5 خدمات AI
- معايير أمنية عالية
