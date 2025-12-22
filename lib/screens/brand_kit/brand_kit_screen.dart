import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/brand_kit_model.dart';
import '../../services/brand_kit_service.dart';
import 'create_brand_kit_screen.dart';

class BrandKitScreen extends StatefulWidget {
  const BrandKitScreen({super.key});

  @override
  State<BrandKitScreen> createState() => _BrandKitScreenState();
}

class _BrandKitScreenState extends State<BrandKitScreen>
    with SingleTickerProviderStateMixin {
  BrandKitService? _brandKitService;
  late TabController _tabController;
  final RxInt _currentTabIndex = 0.obs;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _currentTabIndex.value = _tabController.index;
    });
    _initService();
  }

  Future<void> _initService() async {
    try {
      // Check if BrandKitService is registered
      if (Get.isRegistered<BrandKitService>()) {
        _brandKitService = Get.find<BrandKitService>();
        setState(() {
          _isInitialized = true;
        });
      } else {
        // Try to register it
        Get.put(BrandKitService());
        _brandKitService = Get.find<BrandKitService>();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing BrandKitService: $e');
      setState(() {
        _initError = e.toString();
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if not initialized
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      );
    }

    // Show error if initialization failed
    if (_initError != null || _brandKitService == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Brand Kit'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                const Text(
                  'خدمة Brand Kit غير متاحة حالياً',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'يرجى إعادة تشغيل التطبيق',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _initService(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'Brand Kit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonCyan,
          labelColor: AppColors.neonCyan,
          unselectedLabelColor: AppColors.textLight,
          tabs: const [
            Tab(text: 'Brand Kits', icon: Icon(Icons.palette_rounded)),
            Tab(text: 'الترندات', icon: Icon(Icons.trending_up_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrandKitsTab(),
          _buildTrendsTab(),
        ],
      ),
      floatingActionButton: Obx(() {
        if (_currentTabIndex.value != 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => _showAddBrandKitDialog(),
          backgroundColor: AppColors.neonCyan,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة Brand Kit'),
        );
      }),
    );
  }

  // ==================== Brand Kits Tab ====================
  Widget _buildBrandKitsTab() {
    return Obx(() {
      if (_brandKitService!.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        );
      }

      if (_brandKitService!.brandKits.isEmpty) {
        return _buildEmptyState(
          icon: Icons.palette_rounded,
          title: 'لا توجد Brand Kits',
          subtitle: 'ابدأ بإنشاء Brand Kit الأول لك',
          actionLabel: 'إنشاء Brand Kit',
          onAction: () => _showAddBrandKitDialog(),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _brandKitService!.brandKits.length,
        itemBuilder: (context, index) {
          final brandKit = _brandKitService!.brandKits[index];
          return _buildBrandKitCard(brandKit);
        },
      );
    });
  }

  Widget _buildBrandKitCard(BrandKit brandKit) {
    final isActive = brandKit.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.neonCyan.withValues(alpha: 0.5)
              : AppColors.neonPurple.withValues(alpha: 0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.1),
                  AppColors.neonPurple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                if (brandKit.logoUrl != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(brandKit.logoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.cyanPurpleGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              brandKit.brandName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.cyanPurpleGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'نشط',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        brandKit.industry,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brandKit.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Colors
                Row(
                  children: [
                    const Icon(
                      Icons.palette_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: brandKit.primaryColors.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 30,
                              height: 30,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: _parseColor(brandKit.primaryColors[index]),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Keywords
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: brandKit.keywords.take(5).map((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neonPurple.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        keyword,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neonPurple,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkBg.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                if (!isActive)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _activateBrandKit(brandKit),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('تفعيل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neonCyan,
                        side: const BorderSide(color: AppColors.neonCyan),
                      ),
                    ),
                  ),
                if (!isActive) const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _analyzeTrends(brandKit),
                    icon: const Icon(Icons.trending_up_rounded),
                    label: const Text('تحليل الترندات'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neonPurple,
                      side: const BorderSide(color: AppColors.neonPurple),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showBrandKitOptions(brandKit),
                  icon: const Icon(Icons.more_vert_rounded),
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Trends Tab ====================
  Widget _buildTrendsTab() {
    return Obx(() {
      final activeBrand = _brandKitService!.activeBrand;

      if (activeBrand == null) {
        return _buildEmptyState(
          icon: Icons.warning_rounded,
          title: 'لا يوجد Brand Kit نشط',
          subtitle: 'قم بتفعيل Brand Kit لعرض الترندات',
        );
      }

      if (_brandKitService!.isAnalyzing.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.neonCyan),
              SizedBox(height: 20),
              Text(
                'جارِ تحليل الترندات...',
                style: TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
        );
      }

      if (_brandKitService!.trendingIdeas.isEmpty) {
        return _buildEmptyState(
          icon: Icons.trending_up_rounded,
          title: 'لا توجد ترندات',
          subtitle: 'قم بتحليل الترندات للحصول على أفكار جديدة',
          actionLabel: 'تحليل الترندات',
          onAction: () => _analyzeTrends(activeBrand),
        );
      }

      return Column(
        children: [
          // Trends List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _brandKitService!.trendingIdeas.length,
              itemBuilder: (context, index) {
                final trend = _brandKitService!.trendingIdeas[index];
                return _buildTrendCard(trend);
              },
            ),
          ),

          // Generate Suggestions Button
          if (_brandKitService!.suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () => _generateSuggestions(activeBrand),
                icon: const Icon(Icons.lightbulb_rounded),
                label: const Text('توليد اقتراحات تحسين'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            _buildSuggestionsSection(activeBrand),
        ],
      );
    });
  }

  Widget _buildTrendCard(TrendingIdea trend) {
    // Calculate color based on popularity
    final popularityColor = trend.popularity > 70
        ? const Color(0xFF10B981) // Green for hot
        : trend.popularity > 40
            ? const Color(0xFFF59E0B) // Orange for warm
            : AppColors.neonCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: popularityColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: popularityColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  popularityColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Animated fire icon for hot trends
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        popularityColor,
                        popularityColor.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: popularityColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    trend.popularity > 70
                        ? Icons.local_fire_department_rounded
                        : Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.source_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trend.source,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Popularity meter
                _buildPopularityMeter(trend.popularity, popularityColor),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              trend.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),

          // Hashtags with modern style
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trend.hashtags.map((hashtag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonCyan.withValues(alpha: 0.2),
                        AppColors.neonPurple.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tag_rounded,
                        size: 14,
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hashtag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkBg.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTrendAction(
                  Icons.content_copy_rounded,
                  'نسخ',
                  () => _copyTrendContent(trend),
                ),
                _buildTrendAction(
                  Icons.auto_awesome_rounded,
                  'إنشاء محتوى',
                  () => _createContentFromTrend(trend),
                ),
                _buildTrendAction(
                  Icons.share_rounded,
                  'مشاركة',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularityMeter(int popularity, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: popularity / 100,
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '$popularity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyTrendContent(TrendingIdea trend) {
    final content = '''${trend.title}

${trend.description}

${trend.hashtags.map((h) => '#$h').join(' ')}''';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: content));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ محتوى الترند',
      backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }

  void _createContentFromTrend(TrendingIdea trend) {
    Get.snackbar(
      'قريباً',
      'إنشاء محتوى من الترند قيد التطوير',
      backgroundColor: AppColors.neonPurple.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }

  Widget _buildSuggestionsSection(BrandKit brandKit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.neonPurple.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.neonPurple,
              ),
              const SizedBox(width: 12),
              const Text(
                'اقتراحات التحسين',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _brandKitService!.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _brandKitService!.suggestions[index];
                return _buildSuggestionCard(brandKit, suggestion);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(BrandKit brandKit, BrandSuggestion suggestion) {
    final isApplied = suggestion.applied;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isApplied
            ? AppColors.neonCyan.withValues(alpha: 0.1)
            : AppColors.darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApplied
              ? AppColors.neonCyan.withValues(alpha: 0.3)
              : AppColors.neonPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isApplied)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.neonCyan,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'مطبق',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neonCyan,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.reason,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (!isApplied) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: suggestion.confidence / 100,
                    backgroundColor: AppColors.neonPurple.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.neonPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${suggestion.confidence}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neonPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _applySuggestion(brandKit, suggestion),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('تطبيق الاقتراح'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== Actions ====================
  void _showAddBrandKitDialog() {
    Get.to(
      () => const CreateBrandKitScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _activateBrandKit(BrandKit brandKit) async {
    await _brandKitService!.setActiveBrandKit(brandKit);
    Get.snackbar(
      'تم التفعيل',
      'تم تفعيل ${brandKit.brandName} بنجاح',
      backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }

  void _analyzeTrends(BrandKit brandKit) async {
    await _brandKitService!.analyzeTrends(brandKit);

    if (_brandKitService!.trendingIdeas.isNotEmpty) {
      _tabController.animateTo(1); // Switch to trends tab
      Get.snackbar(
        'تم التحليل',
        'تم العثور على ${_brandKitService!.trendingIdeas.length} ترند',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
    }
  }

  void _generateSuggestions(BrandKit brandKit) async {
    await _brandKitService!.generateBrandSuggestions(brandKit);

    Get.snackbar(
      'تم التوليد',
      'تم توليد ${_brandKitService!.suggestions.length} اقتراح',
      backgroundColor: AppColors.neonPurple.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }

  void _applySuggestion(BrandKit brandKit, BrandSuggestion suggestion) async {
    final success = await _brandKitService!.applySuggestion(brandKit, suggestion);

    if (success) {
      Get.snackbar(
        'تم التطبيق',
        'تم تطبيق اقتراح: ${suggestion.title}',
        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
    }
  }

  void _showBrandKitOptions(BrandKit brandKit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.neonCyan),
              title: const Text(
                'تعديل',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                // TODO: Show edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text(
                'حذف',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                _deleteBrandKit(brandKit);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBrandKit(BrandKit brandKit) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'هل أنت متأكد من حذف ${brandKit.brandName}؟',
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _brandKitService!.deleteBrandKit(brandKit.id);
      if (success) {
        Get.snackbar(
          'تم الحذف',
          'تم حذف ${brandKit.brandName} بنجاح',
          backgroundColor: Colors.red.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
      }
    }
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present
      colorString = colorString.replaceAll('#', '');

      // Add FF for opacity if not present
      if (colorString.length == 6) {
        colorString = 'FF$colorString';
      }

      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return AppColors.neonCyan;
    }
  }
}
