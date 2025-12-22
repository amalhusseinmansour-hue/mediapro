import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sponsored_ad_model.dart';
import '../../services/sponsored_ads_service.dart';
import 'create_sponsored_ad_screen.dart';
import 'ad_details_screen.dart';
import 'dart:math' as math;

class SponsoredAdsListScreen extends StatefulWidget {
  const SponsoredAdsListScreen({super.key});

  @override
  State<SponsoredAdsListScreen> createState() => _SponsoredAdsListScreenState();
}

class _SponsoredAdsListScreenState extends State<SponsoredAdsListScreen> with SingleTickerProviderStateMixin {
  final SponsoredAdsService _adsService = Get.find<SponsoredAdsService>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.neonCyan.withValues(alpha:0.2),
                      AppColors.neonPurple.withValues(alpha:0.2),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated circles background
                    Positioned(
                      top: -50,
                      right: -50,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animationController.value * 2 * math.pi,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.neonCyan.withValues(alpha:0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.cyanPurpleGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha:0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'الإعلانات الممولة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.neonCyan, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
          ),

          // Content
          Obx(() {
            if (_adsService.isLoading.value) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'جاري التحميل...',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_adsService.ads.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState());
            }

            return SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  ..._adsService.ads.map((ad) => _buildEnhancedAdCard(ad)),
                  const SizedBox(height: 80),
                ]),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: _buildModernFAB(),
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha:0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const CreateSponsoredAdScreen(),
              transition: Transition.rightToLeft);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'إعلان جديد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.neonCyan.withValues(alpha:0.2),
                  AppColors.neonPurple.withValues(alpha:0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha:0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.campaign_rounded,
              size: 60,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.cyanPurpleGradient.createShader(bounds),
            child: const Text(
              'لا توجد إعلانات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'ابدأ بإنشاء أول إعلان ممول لك',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const CreateSponsoredAdScreen()),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إنشاء إعلان'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModernStatCard(
                title: 'الميزانية الكلية',
                value: '\$${_adsService.totalBudget.toStringAsFixed(0)}',
                gradient: LinearGradient(
                  colors: [AppColors.neonCyan, AppColors.neonCyan.withValues(alpha:0.6)],
                ),
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernStatCard(
                title: 'نشطة',
                value: _adsService.activeAdsCount.toString(),
                gradient: LinearGradient(
                  colors: [const Color(0xFF00E676), const Color(0xFF00E676).withValues(alpha:0.6)],
                ),
                icon: Icons.play_circle_filled_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModernStatCard(
                title: 'معلقة',
                value: _adsService.pendingAdsCount.toString(),
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF9800), const Color(0xFFFF9800).withValues(alpha:0.6)],
                ),
                icon: Icons.schedule_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernStatCard(
                title: 'مكتملة',
                value: _adsService.completedAdsCount.toString(),
                gradient: LinearGradient(
                  colors: [AppColors.neonPurple, AppColors.neonPurple.withValues(alpha:0.6)],
                ),
                icon: Icons.verified_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required Gradient gradient,
    required IconData icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 100;
        return Container(
          padding: EdgeInsets.all(isSmall ? 12 : 16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSmall ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: isSmall ? 20 : 24),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Flexible(
                child: ShaderMask(
                  shaderCallback: (bounds) => gradient.createShader(bounds),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmall ? 20 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmall ? 10 : 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedAdCard(SponsoredAdModel ad) {
    final statusColor = _getStatusColor(ad.status);
    final progress = ad.status == AdStatus.active ? 0.65 :
                     ad.status == AdStatus.completed ? 1.0 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkCard,
            AppColors.darkCard.withValues(alpha:0.8),
          ],
        ),
        border: Border.all(
          color: statusColor.withValues(alpha:0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha:0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
              () => AdDetailsScreen(ad: ad),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Progress bar at top
              if (progress > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha:0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status and budget
                    Row(
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor.withValues(alpha:0.3),
                                statusColor.withValues(alpha:0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withValues(alpha:0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withValues(alpha:0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ad.statusText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Ad Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.neonPurple.withValues(alpha:0.2),
                                AppColors.neonPurple.withValues(alpha:0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ad.adTypeText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neonPurple,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Budget with icon
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppColors.cyanPurpleGradient.scale(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.neonCyan.withValues(alpha:0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.payments_rounded,
                                color: AppColors.neonCyan,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '\$${ad.budget.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, Colors.white.withValues(alpha:0.8)],
                      ).createShader(bounds),
                      child: Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Description
                    Text(
                      ad.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Platform icons and time
                    Row(
                      children: [
                        // Platforms
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                spacing: 6,
                                children: ad.platforms
                                    .take(4)
                                    .map((platform) => _buildEnhancedPlatformIcon(platform))
                                    .toList(),
                              ),
                              if (ad.platforms.length > 4) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.cyanPurpleGradient.scale(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${ad.platforms.length - 4}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.neonCyan,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Time ago
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: AppColors.textSecondary.withValues(alpha:0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getTimeAgo(ad.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary.withValues(alpha:0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shimmer effect for active ads
              if (ad.status == AdStatus.active)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1 + _animationController.value * 2, 0),
                              end: Alignment(1 + _animationController.value * 2, 0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha:0.03),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedPlatformIcon(AdPlatform platform) {
    IconData icon = Icons.public;
    Color color = AppColors.neonCyan;

    switch (platform) {
      case AdPlatform.facebook:
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case AdPlatform.instagram:
        icon = Icons.camera_alt_rounded;
        color = const Color(0xFFE4405F);
        break;
      case AdPlatform.twitter:
        icon = Icons.chat_bubble_rounded;
        color = const Color(0xFF1DA1F2);
        break;
      case AdPlatform.linkedin:
        icon = Icons.business_rounded;
        color = const Color(0xFF0A66C2);
        break;
      case AdPlatform.tiktok:
        icon = Icons.music_note_rounded;
        color = Colors.white;
        break;
      case AdPlatform.youtube:
        icon = Icons.play_arrow_rounded;
        color = const Color(0xFFFF0000);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Color _getStatusColor(AdStatus status) {
    switch (status) {
      case AdStatus.active:
        return const Color(0xFF00E676);
      case AdStatus.completed:
        return AppColors.neonPurple;
      case AdStatus.pending:
        return const Color(0xFFFFC107);
      case AdStatus.underReview:
        return const Color(0xFF2196F3);
      case AdStatus.approved:
        return const Color(0xFF4CAF50);
      case AdStatus.rejected:
        return const Color(0xFFF44336);
      case AdStatus.cancelled:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
