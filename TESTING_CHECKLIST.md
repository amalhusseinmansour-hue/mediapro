# اختبار النظام - شاشة إدارة الحسابات والمنشورات المجتمعية

## ✅ اختبارات الـ Backend API

### 1. اختبار الحسابات المتصلة (Connected Accounts)

#### ✓ الحصول على جميع الحسابات
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:8000/api/social-accounts
```
**النتيجة المتوقعة**:
```json
{
  "success": true,
  "accounts": [
    {
      "id": 1,
      "platform": "facebook",
      "username": "user123",
      "display_name": "John Doe",
      "profile_picture": "...",
      "is_active": true,
      "connected_at": "2025-11-15T10:30:00Z"
    }
  ]
}
```

#### ✓ ربط حساب جديد
```bash
curl -X POST http://localhost:8000/api/social-accounts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "instagram",
    "access_token": "token_value",
    "username": "myinstagram",
    "display_name": "My Instagram"
  }'
```

#### ✓ الحصول على حساب محدد
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:8000/api/social-accounts/1
```

#### ✓ تحديث حساب
```bash
curl -X PUT http://localhost:8000/api/social-accounts/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "display_name": "Updated Name"
  }'
```

#### ✓ فصل حساب
```bash
curl -X DELETE http://localhost:8000/api/social-accounts/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### ✓ اختبار المصادقة (بدون توكن)
```bash
curl http://localhost:8000/api/social-accounts
```
**النتيجة المتوقعة**: `401 Unauthorized`

---

### 2. اختبار المنشورات المجتمعية (Community Posts)

#### ✓ الحصول على جميع المنشورات
```bash
curl http://localhost:8000/api/community/posts?page=1&per_page=20
```
**النتيجة المتوقعة**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "content": "منشور تجريبي",
      "media_urls": [],
      "tags": ["#تجربة"],
      "likes_count": 0,
      "comments_count": 0,
      "shares_count": 0,
      "visibility": "public",
      "is_pinned": false,
      "published_at": "2025-11-15T10:30:00Z",
      "user": {
        "id": 1,
        "name": "John Doe",
        "profile_image": "..."
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "total": 10,
    "per_page": 20,
    "last_page": 1
  }
}
```

#### ✓ إنشاء منشور جديد
```bash
curl -X POST http://localhost:8000/api/community/posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "هذا منشور جديد في المجتمع!",
    "media_urls": [],
    "tags": ["#جديد", "#مجتمع"],
    "visibility": "public"
  }'
```

#### ✓ الحصول على منشور محدد
```bash
curl http://localhost:8000/api/community/posts/1
```

#### ✓ تحديث منشور
```bash
curl -X PUT http://localhost:8000/api/community/posts/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "محتوى محدث",
    "visibility": "followers"
  }'
```

#### ✓ حذف منشور
```bash
curl -X DELETE http://localhost:8000/api/community/posts/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### ✓ تثبيت منشور
```bash
curl -X POST http://localhost:8000/api/community/posts/1/pin \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### ✓ فك تثبيت منشور
```bash
curl -X POST http://localhost:8000/api/community/posts/1/unpin \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### ✓ الحصول على منشورات مستخدم محدد
```bash
curl http://localhost:8000/api/community/posts/user/1?page=1&per_page=20
```

---

## ✅ اختبارات واجهة المستخدم (Flutter)

### 1. شاشة إدارة الحسابات

**الاختبارات**:
- [ ] تظهر الحسابات المتصلة بدل الشاشة السوداء
- [ ] عند عدم وجود حسابات، تظهر رسالة "لا توجد حسابات متصلة"
- [ ] يمكن الضغط على "ربط حساب" لإضافة حساب جديد
- [ ] يمكن تحديث الحسابات من قائمة الخيارات
- [ ] يمكن فصل الحساب من قائمة الخيارات
- [ ] تظهر إحصائيات (عدد الحسابات، عدد المنصات المتصلة)

### 2. شاشة إنشاء منشور مجتمعي

**الاختبارات**:
- [ ] يظهر محرر النص فارغ
- [ ] يمكن إدخال النص (حتى 5000 حرف)
- [ ] يتم عد الأحرف وعرضها
- [ ] يتم اكتشاف الوسوم (#) تلقائياً
- [ ] يمكن إضافة صور
- [ ] يمكن اختيار مستوى الخصوصية (عام/متابعون/خاص)
- [ ] يمكن نشر المنشور
- [ ] تظهر رسالة نجاح عند النشر
- [ ] تظهر رسالة خطأ عند محاولة النشر بدون محتوى

### 3. شاشة المنشورات المجتمعية

**الاختبارات**:
- [ ] تظهر قائمة المنشورات
- [ ] يمكن التمرير لأسفل لتحميل المزيد
- [ ] يمكن تحديث المنشورات
- [ ] يظهر اسم المؤلف وصورة الملف الشخصي
- [ ] يظهر تاريخ النشر بصيغة نسبية (الآن، قبل ساعة، إلخ)
- [ ] يمكن رؤية عدد الإعجابات والتعليقات والمشاركات
- [ ] يمكن الإعجاب بالمنشور
- [ ] يمكن تعليق على المنشور
- [ ] يمكن مشاركة المنشور
- [ ] الزر العائم (+) ينقل لشاشة إنشاء منشور جديد

---

## 🔧 اختبار الأخطاء والاستثناءات

### ✓ بدون توكن:
```bash
curl http://localhost:8000/api/social-accounts
```
**النتيجة**: `401 Unauthorized`

### ✓ توكن غير صحيح:
```bash
curl -H "Authorization: Bearer invalid_token" \
     http://localhost:8000/api/social-accounts
```
**النتيجة**: `401 Unauthorized`

### ✓ محتوى فارغ:
```bash
curl -X POST http://localhost:8000/api/community/posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": ""}'
```
**النتيجة**: `422 Validation Error`

### ✓ حساب غير موجود:
```bash
curl http://localhost:8000/api/social-accounts/999
```
**النتيجة**: `404 Not Found`

### ✓ محاولة حذف منشور الآخرين:
```bash
curl -X DELETE http://localhost:8000/api/community/posts/1 \
  -H "Authorization: Bearer OTHER_USER_TOKEN"
```
**النتيجة**: `403 Forbidden` مع رسالة "لا يمكنك حذف هذا المنشور"

---

## 📊 اختبار الأداء

### ✓ تحميل 100 منشور:
```bash
curl http://localhost:8000/api/community/posts?page=1&per_page=100
```
**المتوقع**: الاستجابة خلال 2 ثانية

### ✓ البحث عن منشورات (في المستقبل):
```bash
curl "http://localhost:8000/api/community/posts?search=كلمة&page=1"
```

---

## 🗄️ اختبار قاعدة البيانات

### التحقق من إنشاء جداول:
```sql
-- التحقق من وجود جدول community_posts
SHOW TABLES LIKE 'community_posts';

-- التحقق من البيانات
SELECT COUNT(*) FROM community_posts;
SELECT * FROM community_posts LIMIT 5;

-- التحقق من الفهارس
SHOW INDEXES FROM community_posts;
```

### التحقق من الـ Soft Deletes:
```sql
-- عرض المنشورات المحذوفة
SELECT * FROM community_posts WHERE deleted_at IS NOT NULL;
```

---

## 🐛 استكشاف الأخطاء

### إذا لم تظهر الحسابات على الشاشة:

**الخطوة 1**: تحقق من logs
```bash
tail -f storage/logs/laravel.log
flutter logs
```

**الخطوة 2**: تأكد من وجود التوكن
```bash
SharedPreferences prefs = await SharedPreferences.getInstance();
String? token = prefs.getString('auth_token');
print('Token: $token');
```

**الخطوة 3**: اختبر الـ API مباشرة
```bash
curl -H "Authorization: Bearer $TOKEN" \
     http://localhost:8000/api/social-accounts
```

### إذا فشل النشر:

1. تحقق من وجود التوكن
2. تحقق من أن المحتوى ليس فارغاً
3. تحقق من استجابة الـ API
4. تحقق من logs الـ backend

---

## ✅ قائمة التحقق النهائية

- [x] تم إصلاح 500 errors في ConnectedAccountController
- [x] تم إصلاح استجابة الـ API في SocialAccountsService
- [x] تم إنشاء نموذج CommunityPost
- [x] تم إنشاء controller CommunityPostController
- [x] تم إنشاء migration جدول المنشورات
- [x] تم إضافة routes في api.php
- [x] تم إنشاء CommunityController في Flutter
- [x] تم إنشاء CommunityPostService في Flutter
- [x] تم إنشاء UI لإنشاء منشور
- [x] تم تطبيق فحوصات الأمان
- [x] تم تطبيق معالجة الأخطاء
- [x] تم تنظيف الـ cache

**الحالة**: جاهز للاختبار الشامل ✅
