# كيفية استخدام التحليلات الجديدة في واجهة المستخدم
# How to Use New Analytics in UI

## 📊 نظرة عامة | Overview

هذا الدليل يوضح كيفية استخدام البيانات الجديدة من API التحليلات في واجهة المستخدم.

This guide shows how to use the new analytics API data in the user interface.

---

## 1️⃣ عرض أفضل المنشورات | Display Top Posts

### الكود | Code:

```dart
import 'package:get/get.dart';
import '../services/analytics_service.dart';

class TopPostsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analyticsService = Get.find<AnalyticsService>();

    return Obx(() {
      // جلب بيانات المنشورات | Get posts data
      final postsData = analyticsService.postsAnalytics.value;
      final topPosts = postsData['top_posts'] as List? ?? [];
      final isLoading = analyticsService.isLoadingPostsAnalytics.value;

      if (isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      if (topPosts.isEmpty) {
        return Center(
          child: Text(
            'لا توجد منشورات للعرض',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: topPosts.length,
        itemBuilder: (context, index) {
          final post = topPosts[index];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                post['content']?.toString() ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Text('${post['engagement_count'] ?? 0}'),
                  SizedBox(width: 16),
                  Icon(Icons.visibility, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text('${post['reach_count'] ?? 0}'),
                  SizedBox(width: 16),
                  Icon(Icons.share, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('${post['shares_count'] ?? 0}'),
                ],
              ),
              leading: CircleAvatar(
                child: Text(post['platform']?.toString()[0]?.toUpperCase() ?? 'P'),
              ),
            ),
          );
        },
      );
    });
  }
}
```

---

## 2️⃣ عرض أداء المنصات | Display Platform Performance

### الكود | Code:

```dart
class PlatformPerformanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analyticsService = Get.find<AnalyticsService>();

    return Obx(() {
      final postsData = analyticsService.postsAnalytics.value;
      final platformPerformance = postsData['platform_performance'] as List? ?? [];

      if (platformPerformance.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'أداء المنصات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...platformPerformance.map((platform) {
            final totalEngagement = platform['total_engagement'] ?? 0;
            final totalReach = platform['total_reach'] ?? 0;
            final engagementRate = totalReach > 0
              ? (totalEngagement / totalReach * 100).toStringAsFixed(1)
              : '0.0';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          platform['platform']?.toString().toUpperCase() ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text('$engagementRate%'),
                          backgroundColor: Colors.green.shade100,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          'المنشورات',
                          '${platform['posts_count'] ?? 0}',
                          Icons.article,
                        ),
                        _buildStat(
                          'التفاعل',
                          '${platform['total_engagement'] ?? 0}',
                          Icons.favorite,
                        ),
                        _buildStat(
                          'الوصول',
                          '${platform['total_reach'] ?? 0}',
                          Icons.visibility,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
```

---

## 3️⃣ عرض إحصائيات المنصات المربوطة | Display Connected Platforms Stats

### الكود | Code:

```dart
class ConnectedPlatformsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analyticsService = Get.find<AnalyticsService>();

    return Obx(() {
      final platforms = analyticsService.platformsAnalytics;
      final isLoading = analyticsService.isLoadingPlatformsAnalytics.value;

      if (isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      if (platforms.isEmpty) {
        return Center(
          child: Text('لا توجد منصات مربوطة'),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          final isConnected = platform['is_connected'] ?? false;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        platform['platform']?.toString().toUpperCase() ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${platform['followers'] ?? 0}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'متابع',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${platform['total_posts'] ?? 0} منشور',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        '${platform['engagement_rate']?.toStringAsFixed(1) ?? 0}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
```

---

## 4️⃣ رسم بياني دائري لتوزيع المنصات | Pie Chart for Platform Distribution

### باستخدام بيانات حقيقية | Using Real Data:

```dart
import 'package:fl_chart/fl_chart.dart';

class PlatformDistributionPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analyticsService = Get.find<AnalyticsService>();

    return Obx(() {
      final platforms = analyticsService.platformsAnalytics;

      if (platforms.isEmpty) {
        return Center(child: Text('لا توجد بيانات'));
      }

      // حساب مجموع المنشورات | Calculate total posts
      final totalPosts = platforms.fold<int>(
        0,
        (sum, p) => sum + (p['total_posts'] as int? ?? 0),
      );

      if (totalPosts == 0) {
        return Center(child: Text('لا توجد منشورات'));
      }

      // إنشاء أقسام الرسم | Create pie sections
      final sections = platforms.asMap().entries.map((entry) {
        final index = entry.key;
        final platform = entry.value;
        final posts = platform['total_posts'] as int? ?? 0;
        final percentage = (posts / totalPosts * 100).toStringAsFixed(1);

        // ألوان مختلفة لكل منصة | Different colors for each platform
        final colors = [
          Color(0xFF1877F2), // Facebook - Blue
          Color(0xFFE4405F), // Instagram - Pink
          Color(0xFF1DA1F2), // Twitter - Light Blue
          Color(0xFF0077B5), // LinkedIn - Dark Blue
          Color(0xFFFF0000), // YouTube - Red
          Color(0xFF25D366), // WhatsApp - Green
        ];

        final color = colors[index % colors.length];

        return PieChartSectionData(
          value: posts.toDouble(),
          title: '$percentage%',
          color: color,
          radius: 60,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();

      return Column(
        children: [
          // الرسم البياني | The chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 16),
          // المفاتيح | Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: platforms.asMap().entries.map((entry) {
              final index = entry.key;
              final platform = entry.value;
              final colors = [
                Color(0xFF1877F2),
                Color(0xFFE4405F),
                Color(0xFF1DA1F2),
                Color(0xFF0077B5),
                Color(0xFFFF0000),
                Color(0xFF25D366),
              ];

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    platform['platform']?.toString() ?? '',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
```

---

## 5️⃣ تبديل الفترة الزمنية | Switch Time Period

### الكود | Code:

```dart
class PeriodSelectorWidget extends StatefulWidget {
  @override
  _PeriodSelectorWidgetState createState() => _PeriodSelectorWidgetState();
}

class _PeriodSelectorWidgetState extends State<PeriodSelectorWidget> {
  String selectedPeriod = 'week';
  final analyticsService = Get.find<AnalyticsService>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPeriodButton('يوم', 'day'),
        _buildPeriodButton('أسبوع', 'week'),
        _buildPeriodButton('شهر', 'month'),
        _buildPeriodButton('سنة', 'year'),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = selectedPeriod == period;

    return InkWell(
      onTap: () async {
        setState(() {
          selectedPeriod = period;
        });

        // جلب البيانات للفترة الجديدة | Fetch data for new period
        await analyticsService.fetchPostsAnalytics(period: period);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```

---

## 6️⃣ تحديث جميع البيانات | Refresh All Data

### الكود | Code:

```dart
class AnalyticsRefreshButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analyticsService = Get.find<AnalyticsService>();

    return Obx(() {
      final isLoading = analyticsService.isLoadingUsage.value ||
                       analyticsService.isLoadingOverview.value ||
                       analyticsService.isLoadingPostsAnalytics.value ||
                       analyticsService.isLoadingPlatformsAnalytics.value;

      return IconButton(
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.refresh),
        onPressed: isLoading
            ? null
            : () async {
                await analyticsService.refreshAll();

                Get.snackbar(
                  'تم التحديث',
                  'تم تحديث جميع البيانات بنجاح',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: Duration(seconds: 2),
                );
              },
      );
    });
  }
}
```

---

## 📝 ملاحظات مهمة | Important Notes

### 1. التحقق من الخدمة | Service Check
تأكد دائماً من وجود الخدمة قبل الاستخدام:

Always check if service exists before using:

```dart
final analyticsService = Get.find<AnalyticsService>();
if (analyticsService == null) {
  return Center(child: Text('خدمة التحليلات غير متوفرة'));
}
```

### 2. معالجة الحالات الفارغة | Handle Empty States
تعامل مع الحالات التي لا توجد فيها بيانات:

Handle cases where there's no data:

```dart
if (platforms.isEmpty) {
  return EmptyStateWidget(
    message: 'لا توجد منصات مربوطة',
  );
}
```

### 3. حالة التحميل | Loading State
عرض مؤشر التحميل أثناء جلب البيانات:

Show loading indicator while fetching data:

```dart
if (analyticsService.isLoadingPostsAnalytics.value) {
  return Center(child: CircularProgressIndicator());
}
```

---

## 🎯 نصائح للأداء | Performance Tips

1. **استخدم Obx بشكل محدد | Use Obx Specifically**
   ```dart
   // ❌ سيء - يعيد بناء كل شيء | Bad - Rebuilds everything
   Obx(() => Container(child: ComplexWidget()))

   // ✅ جيد - يعيد بناء فقط ما تغير | Good - Only rebuilds what changed
   Obx(() => Text(analyticsService.postsAnalytics['title']))
   ```

2. **تخزين مؤقت للبيانات | Cache Data**
   البيانات مخزنة تلقائياً في المتغيرات Observable

   Data is automatically cached in Observable variables

3. **تحديث متوازي | Parallel Updates**
   استخدم `refreshAll()` لتحديث جميع البيانات مرة واحدة

   Use `refreshAll()` to update all data at once

---

## ✅ خلاصة | Summary

الآن لديك:

Now you have:

- ✅ بيانات حقيقية من الـ API | Real data from API
- ✅ تحديثات فورية مع GetX | Reactive updates with GetX
- ✅ معالجة حالات التحميل والأخطاء | Loading and error handling
- ✅ أمثلة جاهزة للاستخدام | Ready-to-use examples
- ✅ أفضل ممارسات الأداء | Performance best practices

---

**تاريخ الإنشاء | Created:** 2025-01-20
**اللغة | Language:** العربية + English
**الحالة | Status:** ✅ جاهز للاستخدام | Ready to Use
