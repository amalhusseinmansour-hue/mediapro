# 📦 باقات الاشتراك: الأفراد والأعمال

## 📋 نظرة عامة

تم إضافة نظام باقات الاشتراك المنفصل للأفراد والأعمال في التطبيق.

### الباقات المتاحة:

#### 🧑 باقات الأفراد (Individual Plans):
1. **باقة الأفراد الأساسية** - 29 AED/شهرياً
2. **باقة الأفراد المتقدمة** - 59 AED/شهرياً ⭐ الأكثر شعبية
3. **باقة الأفراد السنوية** - 550 AED/سنوياً

#### 🏢 باقات الأعمال (Business Plans):
1. **باقة الأعمال الصغيرة** - 99 AED/شهرياً
2. **باقة الأعمال المتقدمة** - 199 AED/شهرياً ⭐ الأكثر شعبية
3. **باقة المؤسسات** - 499 AED/شهرياً
4. **باقة الأعمال السنوية** - 1750 AED/سنوياً

---

## ✅ التغييرات في Backend (Laravel)

### 1. Migration الجديد

**الملف:** `backend/database/migrations/2025_01_09_000002_add_audience_type_to_subscription_plans.php`

```php
Schema::table('subscription_plans', function (Blueprint $table) {
    $table->enum('audience_type', ['individual', 'business'])
          ->default('individual')
          ->after('type');

    $table->index('audience_type');
});
```

**تشغيل Migration:**
```bash
cd backend
php artisan migrate
```

---

### 2. تحديث Model

**الملف:** `backend/app/Models/SubscriptionPlan.php`

**التغييرات:**
- إضافة `audience_type` إلى `$fillable`
- إضافة scope methods جديدة:
  - `scopeIndividual()` - للباقات الفردية
  - `scopeBusiness()` - للباقات التجارية

**الاستخدام:**
```php
// باقات الأفراد
$individualPlans = SubscriptionPlan::individual()->get();

// باقات الأعمال
$businessPlans = SubscriptionPlan::business()->get();

// باقات الأفراد الشهرية
$monthlyIndividual = SubscriptionPlan::individual()->monthly()->get();
```

---

### 3. Seeder

**الملف:** `backend/database/seeders/SubscriptionPlanSeeder.php`

**تشغيل Seeder:**
```bash
cd backend
php artisan db:seed --class=SubscriptionPlanSeeder
```

هذا سينشئ:
- 3 باقات للأفراد
- 4 باقات للأعمال

---

### 4. API Controller جديد

**الملف:** `backend/app/Http/Controllers/Api/SubscriptionPlanController.php`

**Endpoints المتاحة:**

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/subscription-plans` | جميع الباقات |
| GET | `/api/subscription-plans/individual` | باقات الأفراد فقط |
| GET | `/api/subscription-plans/business` | باقات الأعمال فقط |
| GET | `/api/subscription-plans/monthly` | الباقات الشهرية |
| GET | `/api/subscription-plans/yearly` | الباقات السنوية |
| GET | `/api/subscription-plans/popular` | الباقات الشعبية |
| GET | `/api/subscription-plans/{slug}` | تفاصيل باقة محددة |

**أمثلة على الاستخدام:**

```bash
# جميع الباقات
curl https://mediaprosocial.io/api/subscription-plans

# باقات الأفراد فقط
curl https://mediaprosocial.io/api/subscription-plans/individual

# باقات الأعمال فقط
curl https://mediaprosocial.io/api/subscription-plans/business

# الباقات الشهرية للأفراد
curl "https://mediaprosocial.io/api/subscription-plans/monthly?audience_type=individual"

# تفاصيل باقة محددة
curl https://mediaprosocial.io/api/subscription-plans/individual-pro
```

**Response Example:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "باقة الأفراد المتقدمة",
      "slug": "individual-pro",
      "description": "باقة شاملة للأفراد المحترفين",
      "type": "monthly",
      "audience_type": "individual",
      "price": 59.00,
      "currency": "AED",
      "max_accounts": 5,
      "max_posts": 100,
      "ai_features": true,
      "analytics": true,
      "scheduling": true,
      "is_popular": true,
      "features": [
        "ربط حتى 5 حسابات",
        "100 منشور شهرياً",
        "ميزات الذكاء الاصطناعي",
        "جدولة متقدمة",
        "تحليلات متقدمة"
      ]
    }
  ]
}
```

---

## ✅ التغييرات في Frontend (Flutter)

### 1. تحديث Model

**الملف:** `lib/models/subscription_plan_model.dart`

**التغييرات:**
- إضافة حقل `audienceType`
- تحديث `fromJson` لقراءة `audience_type`
- تحديث `toJson` و `copyWith`

**الاستخدام:**
```dart
final plan = SubscriptionPlanModel.fromJson(jsonData);

// التحقق من نوع الباقة
if (plan.audienceType == 'individual') {
  print('باقة للأفراد');
} else if (plan.audienceType == 'business') {
  print('باقة للأعمال');
}
```

---

### 2. استخدام API في التطبيق

**مثال على جلب الباقات:**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionService {
  final String baseUrl = 'https://mediaprosocial.io/api';

  // جلب جميع الباقات
  Future<List<SubscriptionPlanModel>> getAllPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscription-plans'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List plans = data['data'];
      return plans.map((p) => SubscriptionPlanModel.fromJson(p)).toList();
    }
    throw Exception('Failed to load plans');
  }

  // جلب باقات الأفراد فقط
  Future<List<SubscriptionPlanModel>> getIndividualPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscription-plans/individual'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List plans = data['data'];
      return plans.map((p) => SubscriptionPlanModel.fromJson(p)).toList();
    }
    throw Exception('Failed to load individual plans');
  }

  // جلب باقات الأعمال فقط
  Future<List<SubscriptionPlanModel>> getBusinessPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscription-plans/business'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List plans = data['data'];
      return plans.map((p) => SubscriptionPlanModel.fromJson(p)).toList();
    }
    throw Exception('Failed to load business plans');
  }
}
```

---

### 3. مثال على شاشة اختيار الباقات

```dart
import 'package:flutter/material.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  @override
  _SubscriptionPlansScreenState createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String selectedType = 'individual'; // 'individual' أو 'business'
  List<SubscriptionPlanModel> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    setState(() => isLoading = true);

    final service = SubscriptionService();
    final fetchedPlans = selectedType == 'individual'
        ? await service.getIndividualPlans()
        : await service.getBusinessPlans();

    setState(() {
      plans = fetchedPlans;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر باقتك'),
      ),
      body: Column(
        children: [
          // Tabs لاختيار النوع
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedType = 'individual');
                    loadPlans();
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedType == 'individual'
                          ? Colors.blue
                          : Colors.grey[200],
                    ),
                    child: Text(
                      'باقات الأفراد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selectedType == 'individual'
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedType = 'business');
                    loadPlans();
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedType == 'business'
                          ? Colors.green
                          : Colors.grey[200],
                    ),
                    child: Text(
                      'باقات الأعمال',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selectedType == 'business'
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // عرض الباقات
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return PlanCard(plan: plan);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;

  const PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plan.isPopular)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'الأكثر شعبية',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            SizedBox(height: 8),
            Text(
              plan.nameAr,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(plan.descriptionAr),
            SizedBox(height: 16),
            Text(
              '${plan.monthlyPrice} ${plan.currency}/شهرياً',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...plan.featuresAr.map((feature) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // الاشتراك في الباقة
              },
              child: Text('اشترك الآن'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🚀 خطوات التفعيل

### في Backend:

```bash
# 1. تشغيل Migration
cd backend
php artisan migrate

# 2. تشغيل Seeder
php artisan db:seed --class=SubscriptionPlanSeeder

# 3. مسح Cache
php artisan optimize:clear

# 4. التحقق من Routes
php artisan route:list | grep subscription-plans
```

### في Frontend:

```bash
# 1. تحديث الباكيجات
flutter pub get

# 2. تشغيل التطبيق
flutter run
```

---

## 📊 مقارنة الباقات

### باقات الأفراد:

| الميزة | أساسية | متقدمة | سنوية |
|-------|--------|---------|-------|
| السعر | 29 AED | 59 AED | 550 AED |
| الحسابات | 3 | 5 | 5 |
| المنشورات | 30/شهر | 100/شهر | 100/شهر |
| AI | ❌ | ✅ | ✅ |
| تحليلات | بسيطة | متقدمة | متقدمة |

### باقات الأعمال:

| الميزة | صغيرة | متقدمة | مؤسسات |
|-------|-------|---------|--------|
| السعر | 99 AED | 199 AED | 499 AED |
| الحسابات | 10 | 25 | غير محدود |
| المنشورات | 200/شهر | 500/شهر | غير محدود |
| الفريق | 3 | 10 | غير محدود |
| API | ❌ | ✅ | ✅ |

---

## 🧪 الاختبار

### اختبار API:

```bash
# 1. جميع الباقات
curl https://mediaprosocial.io/api/subscription-plans

# 2. باقات الأفراد
curl https://mediaprosocial.io/api/subscription-plans/individual

# 3. باقات الأعمال
curl https://mediaprosocial.io/api/subscription-plans/business

# 4. الباقات الشهرية للأفراد
curl "https://mediaprosocial.io/api/subscription-plans/monthly?audience_type=individual"
```

---

## 📝 ملاحظات

1. **العملة:** جميع الأسعار بالدرهم الإماراتي (AED)
2. **الخصومات:**
   - باقة الأفراد السنوية: خصم 20%
   - باقة الأعمال السنوية: خصم 25%
3. **الباقات الشعبية:**
   - باقة الأفراد المتقدمة
   - باقة الأعمال المتقدمة

---

## 🔧 Troubleshooting

### مشكلة: الباقات لا تظهر

```bash
# 1. تأكد من تشغيل Migration
php artisan migrate

# 2. تأكد من تشغيل Seeder
php artisan db:seed --class=SubscriptionPlanSeeder

# 3. تحقق من قاعدة البيانات
php artisan tinker
>>> \App\Models\SubscriptionPlan::count()
```

### مشكلة: API يرجع خطأ

```bash
# مسح Cache
php artisan optimize:clear

# التحقق من Routes
php artisan route:list | grep subscription
```

---

**تاريخ الإنشاء:** 2025-01-09
**الحالة:** ✅ جاهز للاستخدام
