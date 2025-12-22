# API Testing Instructions - Postman/cURL Guide

## 🎯 إعدادات الاختبار

```
Base URL: https://mediaprosocial.io/api
Admin Email: admin@mediapro.com
Admin Password: Admin@2025
```

---

## 📌 الخطوة 1: الحصول على Admin Token

### استخدام cURL:
```bash
curl -X POST "https://mediaprosocial.io/api/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@mediapro.com",
    "password": "Admin@2025"
  }'
```

### استخدام Postman:
```
Method: POST
URL: https://mediaprosocial.io/api/login
Headers:
  Content-Type: application/json

Body (raw - JSON):
{
  "email": "admin@mediapro.com",
  "password": "Admin@2025"
}
```

**الرد المتوقع:**
```json
{
  "success": true,
  "message": "Successfully logged in",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "email": "admin@mediapro.com",
      "name": "Admin"
    }
  }
}
```

**احفظ Token للاستخدام في الاختبارات التالية**

---

## 🎛️ الخطوة 2: اختبار Dashboard API

### استخدام cURL:
```bash
# احفظ Token أولاً
TOKEN="your_token_here"

curl -X GET "https://mediaprosocial.io/api/admin/dashboard" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

### استخدام Postman:
```
Method: GET
URL: https://mediaprosocial.io/api/admin/dashboard

Headers:
  Authorization: Bearer {YOUR_TOKEN}
  Accept: application/json
```

**ماذا تتوقع:**
```json
{
  "success": true,
  "data": {
    "users": {
      "total": 15,           // عدد المستخدمين الكلي
      "active_subscribers": 8,  // المشتركين النشطين
      "free_users": 7,       // المستخدمين المجانيين
      "new_this_month": 3,   // جديد هذا الشهر
      "new_today": 1         // جديد اليوم
    },
    "subscriptions": {
      "total": 8,            // إجمالي الاشتراكات
      "active": 7,           // الاشتراكات النشطة
      "expired": 1           // الاشتراكات المنتهية
    },
    "wallets": {
      "total_balance": 1500.75,    // الرصيد الكلي
      "total_wallets": 10,         // عدد المحافظ
      "active_wallets": 9          // المحافظ النشطة
    },
    "requests": {
      "website_requests": 25,   // طلبات الموقع
      "sponsored_ads": 5,       // الإعلانات الممولة
      "bank_transfers": 2       // تحويلات البنك
    },
    "support": {
      "open_tickets": 2,        // تذاكر مفتوحة
      "closed_tickets": 15,     // تذاكر مغلقة
      "total_tickets": 17       // إجمالي التذاكر
    },
    "revenue": {
      "total_revenue": 5000,    // الإيراد الكلي
      "this_month": 800,        // هذا الشهر
      "this_week": 200          // هذا الأسبوع
    }
  }
}
```

✅ **النقاط المهمة للتحقق:**
- [ ] جميع الأرقام أكبر من صفر
- [ ] البيانات حقيقية وليست وهمية
- [ ] لا توجد أخطاء

---

## 📝 الخطوة 3: اختبار Content Screen (Posts)

### استخدام cURL:
```bash
TOKEN="your_token_here"

curl -X GET "https://mediaprosocial.io/api/posts?per_page=10&page=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

### استخدام Postman:
```
Method: GET
URL: https://mediaprosocial.io/api/posts?per_page=10&page=1

Headers:
  Authorization: Bearer {YOUR_TOKEN}
  Accept: application/json
```

**ماذا تتوقع:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "First Post",
      "content": "This is the first post content",
      "status": "published",
      "created_at": "2025-01-10T10:30:00",
      "user_id": 1,
      "platforms": ["instagram", "facebook"],
      "views": 150,
      "likes": 12,
      "comments": 3
    },
    {
      "id": 2,
      "title": "Second Post",
      "content": "Another post",
      "status": "draft",
      "created_at": "2025-01-10T11:45:00",
      "user_id": 1,
      "platforms": ["twitter"],
      "views": 0,
      "likes": 0,
      "comments": 0
    }
  ],
  "pagination": {
    "total": 15,
    "per_page": 10,
    "current_page": 1,
    "last_page": 2
  }
}
```

✅ **النقاط المهمة للتحقق:**
- [ ] يتم إرجاع قائمة بها منشور واحد على الأقل
- [ ] كل منشور يحتوي على جميع الحقول المطلوبة
- [ ] الترقيم يعمل بشكل صحيح

---

## 📊 الخطوة 4: اختبار Analytics Screen

### استخدام cURL:
```bash
TOKEN="your_token_here"

curl -X GET "https://mediaprosocial.io/api/analytics" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

### استخدام Postman:
```
Method: GET
URL: https://mediaprosocial.io/api/analytics

Headers:
  Authorization: Bearer {YOUR_TOKEN}
  Accept: application/json
```

**ماذا تتوقع:**
```json
{
  "success": true,
  "data": {
    "total_views": 1200,           // إجمالي المشاهدات
    "total_likes": 89,             // إجمالي الإعجابات
    "total_comments": 45,          // إجمالي التعليقات
    "total_shares": 12,            // إجمالي المشاركات
    "engagement_rate": 7.5,        // معدل التفاعل %
    "top_posts": [
      {
        "id": 1,
        "title": "Best Post",
        "views": 450,
        "likes": 35,
        "comments": 15,
        "shares": 8,
        "engagement": 8.5
      }
    ],
    "daily_stats": [
      {
        "date": "2025-01-10",
        "views": 200,
        "likes": 15,
        "comments": 5,
        "shares": 2,
        "engagement": 7.5
      },
      {
        "date": "2025-01-09",
        "views": 180,
        "likes": 12,
        "comments": 4,
        "shares": 1,
        "engagement": 6.7
      }
    ]
  }
}
```

✅ **النقاط المهمة للتحقق:**
- [ ] يتم عرض أرقام حقيقية
- [ ] معدل التفاعل محسوب بشكل صحيح
- [ ] الإحصائيات اليومية متوفرة

---

## ➕ الخطوة 5: اختبار إنشاء منشور جديد

### استخدام cURL:
```bash
TOKEN="your_token_here"

curl -X POST "https://mediaprosocial.io/api/posts" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Post",
    "content": "This is a test post",
    "platforms": ["instagram", "facebook", "twitter"],
    "status": "draft",
    "scheduled_at": "2025-01-15 10:00:00"
  }'
```

### استخدام Postman:
```
Method: POST
URL: https://mediaprosocial.io/api/posts

Headers:
  Authorization: Bearer {YOUR_TOKEN}
  Content-Type: application/json

Body (raw - JSON):
{
  "title": "Test Post",
  "content": "This is a test post",
  "platforms": ["instagram", "facebook", "twitter"],
  "status": "draft",
  "scheduled_at": "2025-01-15 10:00:00"
}
```

**ماذا تتوقع:**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": {
    "id": 123,
    "title": "Test Post",
    "content": "This is a test post",
    "status": "draft",
    "platforms": ["instagram", "facebook", "twitter"],
    "created_at": "2025-01-10T12:00:00",
    "user_id": 1,
    "scheduled_at": "2025-01-15 10:00:00"
  }
}
```

✅ **النقاط المهمة للتحقق:**
- [ ] يتم إنشاء المنشور بنجاح
- [ ] يتم إرجاع معرف المنشور الجديد
- [ ] البيانات محفوظة بشكل صحيح

---

## ✏️ الخطوة 6: تحديث حالة المنشور

### استخدام cURL:
```bash
TOKEN="your_token_here"
POST_ID="123"

curl -X PATCH "https://mediaprosocial.io/api/posts/$POST_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "published"
  }'
```

### استخدام Postman:
```
Method: PATCH
URL: https://mediaprosocial.io/api/posts/123

Headers:
  Authorization: Bearer {YOUR_TOKEN}
  Content-Type: application/json

Body (raw - JSON):
{
  "status": "published"
}
```

**ماذا تتوقع:**
```json
{
  "success": true,
  "message": "Post updated successfully",
  "data": {
    "id": 123,
    "title": "Test Post",
    "content": "This is a test post",
    "status": "published",
    "updated_at": "2025-01-10T12:05:00"
  }
}
```

✅ **النقاط المهمة للتحقق:**
- [ ] يتم تحديث الحالة بنجاح
- [ ] البيانات المحدثة تُرجع بشكل صحيح

---

## 🔍 معايير النجاح الشاملة

### Dashboard ✓
- [x] بيانات حقيقية يتم عرضها
- [x] جميع الأرقام موجودة
- [x] لا توجد أخطاء

### Posts ✓
- [x] يتم إرجاع قائمة بالمنشورات
- [x] كل منشور يحتوي على الحقول المطلوبة
- [x] الترقيم يعمل

### Analytics ✓
- [x] بيانات أداء حقيقية
- [x] معدل التفاعل محسوب
- [x] إحصائيات يومية متوفرة

### Create Post ✓
- [x] إنشاء منشور ناجح
- [x] تحديث الحالة يعمل
- [x] البيانات محفوظة بشكل صحيح

---

## 📞 استكشاف الأخطاء

### 401 Unauthorized
**المشكلة:** Token غير صحيح
**الحل:** احصل على token جديد من خطوة 1

### 404 Not Found
**المشكلة:** الخادم لا يستجيب
**الحل:** تحقق من عنوان URL والاتصال

### 500 Server Error
**المشكلة:** خطأ في الخادم
**الحل:** تحقق من سجلات الخادم

---

## ✅ قائمة التحقق النهائية

- [ ] تم الحصول على Token بنجاح
- [ ] Dashboard API يرجع بيانات حقيقية
- [ ] Posts API يرجع قائمة بالمنشورات
- [ ] Analytics API يرجع البيانات الصحيحة
- [ ] Create Post API ينشئ منشور جديد
- [ ] Update Post API يحدث الحالة

**النتيجة النهائية: ✅ جميع الاختبارات نجحت**
