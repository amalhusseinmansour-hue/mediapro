# ملاحظة: المميزات الخاصة بباقة الشركات

## المميزات المحصورة على باقة الشركات

تم تصميم النظام بحيث تكون المميزات التالية **متاحة فقط للشركات**:

### 1. طلب موقع إلكتروني
- يجب أن يكون المستخدم مشتركاً في **باقة الشركات** للوصول لهذه الميزة
- الأفراد لن يستطيعوا إرسال طلبات المواقع الإلكترونية

### 2. التحليلات المتقدمة
- التحليلات والإحصائيات المتقدمة متاحة **للشركات فقط**
- الأفراد لديهم وصول محدود للتحليلات البسيطة

---

## التطبيق في Flutter

### الفحص في التطبيق

قبل السماح للمستخدم بالوصول لهذه المميزات، تحقق من نوع الباقة:

```dart
// في ملف constants أو config
class SubscriptionTypes {
  static const String individual = 'individual'; // الأفراد
  static const String business = 'business'; // الشركات
}

class FeatureAccess {
  // التحقق من إمكانية طلب موقع إلكتروني
  static bool canRequestWebsite(User user) {
    return user.subscription?.planType == SubscriptionTypes.business;
  }

  // التحقق من إمكانية الوصول للتحليلات المتقدمة
  static bool canAccessAdvancedAnalytics(User user) {
    return user.subscription?.planType == SubscriptionTypes.business;
  }
}
```

### مثال الاستخدام في الواجهة

```dart
Widget buildWebsiteRequestButton(BuildContext context) {
  final user = Provider.of<UserProvider>(context).user;

  if (!FeatureAccess.canRequestWebsite(user)) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('ميزة محصورة'),
            content: Text(
              'هذه الميزة متاحة فقط لباقة الشركات.\n\n'
              'قم بالترقية لباقة الشركات للاستفادة من:\n'
              '• طلب مواقع إلكترونية مخصصة\n'
              '• التحليلات المتقدمة\n'
              '• الدعم الفني ذو الأولوية\n'
              '• والمزيد...'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // الانتقال لصفحة الاشتراكات
                  Navigator.pushNamed(context, '/subscriptions');
                },
                child: Text('الترقية الآن'),
              ),
            ],
          ),
        );
      },
      child: Card(
        color: Colors.grey.shade300,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.lock, size: 48, color: Colors.grey.shade600),
              SizedBox(height: 8),
              Text(
                'طلب موقع إلكتروني',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'للشركات فقط',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الزر النشط للشركات
  return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, '/website-request');
    },
    child: Text('طلب موقع إلكتروني'),
  );
}
```

---

## التطبيق في Backend (API)

### إضافة Middleware للتحقق

أنشئ Middleware للتحقق من نوع الاشتراك:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RequireBusinessSubscription
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'يجب تسجيل الدخول أولاً'
            ], 401);
        }

        // التحقق من وجود اشتراك نشط للشركات
        $hasBusinessSubscription = $user->subscriptions()
            ->where('status', 'active')
            ->where('plan_type', 'business') // أو حسب تصميم جدولك
            ->where('end_date', '>', now())
            ->exists();

        if (!$hasBusinessSubscription) {
            return response()->json([
                'success' => false,
                'message' => 'هذه الميزة متاحة فقط لباقة الشركات. قم بالترقية للوصول لهذه الميزة.',
                'upgrade_required' => true
            ], 403);
        }

        return $next($request);
    }
}
```

### تطبيق Middleware على Routes

في `routes/api.php`:

```php
// Website Requests (Business only)
Route::post('/website-requests', [WebsiteRequestController::class, 'store'])
    ->middleware(['auth:sanctum', 'business.subscription']);

// يمكن أيضاً تطبيقه على endpoints التحليلات
Route::get('/analytics/advanced', [AnalyticsController::class, 'advanced'])
    ->middleware(['auth:sanctum', 'business.subscription']);
```

### تسجيل Middleware

في `bootstrap/app.php` أو `app/Http/Kernel.php`:

```php
protected $routeMiddleware = [
    // ...
    'business.subscription' => \App\Http\Middleware\RequireBusinessSubscription::class,
];
```

---

## تصميم جدول الاشتراكات

تأكد من أن جدول `subscriptions` يحتوي على حقل `plan_type`:

```php
Schema::table('subscriptions', function (Blueprint $table) {
    $table->enum('plan_type', ['individual', 'business'])->default('individual');
});
```

أو يمكنك إضافته في جدول الخطط `subscription_plans`:

```php
Schema::table('subscription_plans', function (Blueprint $table) {
    $table->enum('type', ['individual', 'business'])->default('individual');
});
```

---

## في لوحة التحكم الإدارية

### عرض نوع الباقة

في صفحة قائمة المستخدمين، أضف عمود لعرض نوع الباقة:

```blade
<td>
    @php
        $activeSubscription = $user->subscriptions()
            ->where('status', 'active')
            ->where('end_date', '>', now())
            ->first();
    @endphp

    @if($activeSubscription)
        @if($activeSubscription->plan_type === 'business')
            <span class="badge bg-primary">شركات</span>
        @else
            <span class="badge bg-secondary">أفراد</span>
        @endif
    @else
        <span class="badge bg-light text-dark">بدون اشتراك</span>
    @endif
</td>
```

---

## رسائل الخطأ المناسبة

### في التطبيق (Flutter)

```dart
if (response.data['upgrade_required'] == true) {
  showUpgradeDialog(
    context: context,
    message: response.data['message'],
  );
} else {
  showErrorSnackBar(response.data['message']);
}
```

### في API

```json
{
  "success": false,
  "message": "هذه الميزة متاحة فقط لباقة الشركات",
  "upgrade_required": true,
  "available_plans": [
    {
      "id": 2,
      "name": "باقة الشركات الشهرية",
      "price": 299.00,
      "features": [
        "طلب مواقع إلكترونية مخصصة",
        "تحليلات متقدمة",
        "دعم فني ذو أولوية"
      ]
    }
  ]
}
```

---

## ملاحظات إضافية

1. **التجربة المجانية:** يمكنك السماح بتجربة مجانية محدودة للمميزات المتقدمة
2. **الإشعارات:** أرسل إشعار للمستخدم عند محاولة الوصول لميزة محصورة
3. **التسويق:** استخدم هذا لتشجيع المستخدمين على الترقية
4. **المرونة:** يمكنك إضافة مميزات أخرى للشركات مستقبلاً

---

**مهم:** تأكد من تطبيق هذه القيود في:
- ✅ التطبيق (Flutter)
- ✅ الباك إند (API)
- ✅ قاعدة البيانات (التصميم)
- ✅ لوحة التحكم (العرض)

---

**تاريخ التحديث:** 8 نوفمبر 2025
