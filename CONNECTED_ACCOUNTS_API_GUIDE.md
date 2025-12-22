# دليل API ربط الحسابات - Connected Accounts

## ✅ ما تم إنشاؤه

تم إنشاء نظام كامل لربط/فك ربط حسابات Social Media:

1. **Model:** `ConnectedAccount`
2. **Migration:** `create_connected_accounts_table`
3. **Controller:** `ConnectedAccountController`
4. **Routes:** تحت `/api/connected-accounts`

---

## 📋 API Endpoints

### الحصول على جميع الحسابات المتصلة

```http
GET /api/connected-accounts
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "accounts": [
    {
      "id": 1,
      "platform": "facebook",
      "platform_name": "Facebook",
      "platform_icon": "facebook",
      "platform_color": "#1877F2",
      "username": "john_doe",
      "display_name": "John Doe",
      "profile_picture": "https://...",
      "is_active": true,
      "connected_at": "2025-11-08T10:00:00Z",
      "last_used_at": "2025-11-08T12:00:00Z"
    }
  ]
}
```

---

### الحصول على المنصات المدعومة

```http
GET /api/connected-accounts/platforms
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "platforms": [
    {
      "id": "facebook",
      "name": "Facebook",
      "name_ar": "فيسبوك",
      "icon": "facebook",
      "color": "#1877F2",
      "supported": true
    },
    {
      "id": "instagram",
      "name": "Instagram",
      "name_ar": "إنستغرام",
      "icon": "instagram",
      "color": "#E4405F",
      "supported": true
    }
  ]
}
```

---

### ربط حساب جديد

```http
POST /api/connected-accounts/connect
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "platform": "facebook",
  "access_token": "your_access_token_here",
  "platform_user_id": "123456789",
  "username": "john_doe",
  "display_name": "John Doe",
  "profile_picture": "https://graph.facebook.com/123456789/picture",
  "email": "john@example.com",
  "refresh_token": "optional_refresh_token",
  "expires_in": 3600
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "تم ربط الحساب بنجاح",
  "account": {
    "id": 1,
    "platform": "facebook",
    "platform_name": "Facebook",
    "username": "john_doe",
    "display_name": "John Doe",
    "profile_picture": "https://..."
  }
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "فشل ربط الحساب. حاول مرة أخرى.",
  "errors": {
    "platform": ["The platform field is required."]
  }
}
```

---

### فك ربط حساب

```http
DELETE /api/connected-accounts/{id}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "تم فك ربط الحساب بنجاح"
}
```

---

### تفعيل/تعطيل حساب

```http
POST /api/connected-accounts/{id}/toggle-status
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تفعيل الحساب",
  "is_active": true
}
```

---

### الحصول على إحصائيات

```http
GET /api/connected-accounts/statistics
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "statistics": {
    "total_accounts": 5,
    "active_accounts": 4,
    "inactive_accounts": 1,
    "by_platform": {
      "facebook": 1,
      "instagram": 2,
      "twitter": 1,
      "linkedin": 1
    }
  }
}
```

---

## 🔐 Authentication

جميع endpoints تتطلب Authentication عبر Bearer Token:

```http
Authorization: Bearer your_sanctum_token_here
```

---

## 🗃️ Database Structure

### جدول `connected_accounts`:

| Column | Type | Description |
|--------|------|-------------|
| id | bigint | Primary key |
| user_id | bigint | Foreign key to users table |
| platform | string | المنصة (facebook, instagram, etc.) |
| platform_user_id | string | معرف المستخدم على المنصة |
| username | string | اسم المستخدم |
| display_name | string | الاسم المعروض |
| profile_picture | string | رابط صورة الملف الشخصي |
| email | string | البريد الإلكتروني |
| access_token | text | Access token (مشفر) |
| refresh_token | text | Refresh token (مشفر) |
| token_expires_at | timestamp | تاريخ انتهاء الـ token |
| scopes | json | الصلاحيات الممنوحة |
| is_active | boolean | الحساب مفعل/معطل |
| connected_at | timestamp | تاريخ الربط |
| last_used_at | timestamp | آخر استخدام |
| metadata | json | بيانات إضافية |

---

## 📱 Integration في التطبيق (Flutter)

### 1. الحصول على الحسابات المتصلة

```dart
Future<List<ConnectedAccount>> getConnectedAccounts() async {
  final response = await dio.get(
    '/connected-accounts',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );

  if (response.data['success']) {
    return (response.data['accounts'] as List)
        .map((json) => ConnectedAccount.fromJson(json))
        .toList();
  }

  throw Exception('Failed to load connected accounts');
}
```

### 2. ربط حساب جديد

```dart
Future<void> connectAccount({
  required String platform,
  required String accessToken,
  String? username,
  String? displayName,
  String? profilePicture,
}) async {
  final response = await dio.post(
    '/connected-accounts/connect',
    data: {
      'platform': platform,
      'access_token': accessToken,
      'username': username,
      'display_name': displayName,
      'profile_picture': profilePicture,
    },
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );

  if (!response.data['success']) {
    throw Exception(response.data['message']);
  }
}
```

### 3. فك ربط حساب

```dart
Future<void> disconnectAccount(int accountId) async {
  final response = await dio.delete(
    '/connected-accounts/$accountId',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );

  if (!response.data['success']) {
    throw Exception(response.data['message']);
  }
}
```

---

## 🔧 الملفات المطلوب رفعها للسيرفر

```
1. backend/app/Models/ConnectedAccount.php
2. backend/app/Http/Controllers/Api/ConnectedAccountController.php
3. backend/database/migrations/2025_11_08_000005_create_connected_accounts_table.php
4. backend/routes/api.php (محدث)
```

---

## 📦 طريقة الرفع

### الخيار 1: رفع عبر cPanel

1. سجل دخول cPanel: `https://mediaprosocial.io:2083`
2. افتح File Manager
3. ارفع الملفات في المواقع الصحيحة
4. نفذ Migration:
   ```bash
   cd domains/mediaprosocial.io/public_html
   php artisan migrate
   ```

### الخيار 2: استخدم ملف ZIP

سأنشئ لك ملف `connected_accounts.zip` يحتوي على جميع الملفات.

---

## 🧪 اختبار API

### Test 1: الحصول على المنصات المدعومة

```bash
curl -X GET https://mediaprosocial.io/api/connected-accounts/platforms \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test 2: ربط حساب Facebook (تجريبي)

```bash
curl -X POST https://mediaprosocial.io/api/connected-accounts/connect \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "facebook",
    "access_token": "test_token_123",
    "username": "john_doe",
    "display_name": "John Doe"
  }'
```

### Test 3: الحصول على الحسابات

```bash
curl -X GET https://mediaprosocial.io/api/connected-accounts \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ⚠️ ملاحظات مهمة

### 1. OAuth Integration

حالياً، الـ API يقبل `access_token` مباشرة. لكن في الإنتاج، يجب:
- إضافة OAuth flow لكل منصة
- تكوين App IDs و Secrets
- إضافة Redirect URLs
- استخدام SDKs رسمية

### 2. Token Security

- Access tokens يتم تخزينها **مشفرة** في قاعدة البيانات
- لا يتم إرجاع tokens في responses
- استخدم HTTPS دائماً

### 3. Subscription Limits

تحقق من عدد الحسابات المسموحة حسب الباقة:
- Individual: 3 حسابات
- Business: 10 حسابات
- Enterprise: غير محدود

---

## 🚀 Next Steps

بعد رفع الملفات:

1. ✅ نفذ Migration
2. ✅ اختبر API endpoints
3. ✅ ادمج مع التطبيق
4. ⏳ أضف OAuth flow (اختياري)
5. ⏳ أضف validation للـ subscription limits

---

**تم الإنشاء:** 8 نوفمبر 2025
**الإصدار:** 1.0.0

استمتع بنظام ربط الحسابات! 🎉
