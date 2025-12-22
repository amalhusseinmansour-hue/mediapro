import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/error_handler.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../services/scrapfly_service.dart';

/// شاشة تحليل المنافسين باستخدام Scrapfly
///
/// الميزات:
/// - تحليل ملفات Instagram/Twitter للمنافسين
/// - مقارنة عدة حسابات
/// - عرض الإحصائيات
/// - اقتراحات التحسين
class CompetitorAnalysisScreen extends StatefulWidget {
  const CompetitorAnalysisScreen({super.key});

  @override
  State<CompetitorAnalysisScreen> createState() => _CompetitorAnalysisScreenState();
}

class _CompetitorAnalysisScreenState extends State<CompetitorAnalysisScreen> {
  final ScrapflyService _scrapflyService = Get.find<ScrapflyService>();
  final _usernameController = TextEditingController();
  final _competitors = <CompetitorData>[].obs;
  final _selectedPlatform = 'instagram'.obs;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _analyzeCompetitor() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      ErrorHandler.showError('الرجاء إدخال اسم المستخدم');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ErrorHandler.handleAsync<bool>(
      () async {
        if (_selectedPlatform.value == 'instagram') {
          final profile = await _scrapflyService.analyzeInstagramProfile(username);

          if (profile != null) {
            _competitors.add(CompetitorData(
              username: username,
              platform: 'instagram',
              followers: profile.followers,
              following: profile.following,
              posts: profile.posts,
              engagement: _calculateEngagement(
                profile.followers,
                profile.posts,
              ),
            ));
            return true;
          }
        } else if (_selectedPlatform.value == 'twitter') {
          final profile = await _scrapflyService.analyzeTwitterProfile(username);

          if (profile != null) {
            _competitors.add(CompetitorData(
              username: username,
              platform: 'twitter',
              followers: profile.followers,
              following: profile.following,
              posts: profile.tweets,
              engagement: profile.engagement ?? 0.0,
            ));
            return true;
          }
        }

        return false;
      },
      errorMessage: 'فشل تحليل الحساب',
    );

    setState(() => _isLoading = false);

    if (success == true) {
      _usernameController.clear();
      ErrorHandler.showSuccess('تم إضافة المنافس بنجاح');
    }
  }

  double _calculateEngagement(int followers, int posts) {
    if (followers == 0) return 0.0;
    // معادلة بسيطة - يمكن تحسينها
    return (posts / followers) * 100;
  }

  void _removeCompetitor(int index) {
    setState(() {
      _competitors.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'جاري تحليل الحساب...',
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkCard,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) => AppColors.cyanPurpleGradient.createShader(bounds),
            child: const Text(
              'تحليل المنافسين',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.neonCyan),
              onPressed: () {
                _showInfoDialog();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // منصة الاختيار
              _buildPlatformSelector(),
              const SizedBox(height: 20),

              // إدخال اسم المستخدم
              _buildUsernameInput(),
              const SizedBox(height: 20),

              // زر التحليل
              _buildAnalyzeButton(),
              const SizedBox(height: 32),

              // قائمة المنافسين
              if (_competitors.isNotEmpty) ...[
                _buildSectionTitle('المنافسين المضافين (${_competitors.length})'),
                const SizedBox(height: 16),
                Obx(() => _buildCompetitorsList()),
                const SizedBox(height: 32),

                // المقارنة
                _buildSectionTitle('المقارنة'),
                const SizedBox(height: 16),
                Obx(() => _buildComparisonChart()),
              ] else ...[
                _buildEmptyState(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المنصة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildPlatformOption(
                      'Instagram',
                      'instagram',
                      Icons.camera_alt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPlatformOption(
                      'Twitter',
                      'twitter',
                      Icons.chat_bubble_outline,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildPlatformOption(String label, String value, IconData icon) {
    final isSelected = _selectedPlatform.value == value;

    return GestureDetector(
      onTap: () => _selectedPlatform.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : AppColors.darkBorder,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameInput() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.cyanPurpleGradient,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _usernameController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'أدخل اسم المستخدم (بدون @)',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.neonCyan),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          onSubmitted: (_) => _analyzeCompetitor(),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _analyzeCompetitor,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.analytics, color: Colors.white),
        label: const Text(
          'تحليل الحساب',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCompetitorsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _competitors.length,
      itemBuilder: (context, index) {
        final competitor = _competitors[index];
        return _buildCompetitorCard(competitor, index);
      },
    );
  }

  Widget _buildCompetitorCard(CompetitorData competitor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  competitor.platform == 'instagram'
                      ? Icons.camera_alt
                      : Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${competitor.username}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      competitor.platform.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removeCompetitor(index),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('المتابعون', competitor.followers),
              _buildStatItem('يتابع', competitor.following),
              _buildStatItem('المنشورات', competitor.posts),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: competitor.engagement / 100,
            backgroundColor: AppColors.darkBg,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
          ),
          const SizedBox(height: 4),
          Text(
            'معدل التفاعل: ${competitor.engagement.toStringAsFixed(2)}%',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          _formatNumber(value),
          style: const TextStyle(
            color: AppColors.neonCyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildComparisonChart() {
    if (_competitors.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildComparisonRow('المتابعون', (c) => c.followers),
          const Divider(color: AppColors.darkBorder),
          _buildComparisonRow('المنشورات', (c) => c.posts),
          const Divider(color: AppColors.darkBorder),
          _buildComparisonRow('معدل التفاعل', (c) => c.engagement.toInt()),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, int Function(CompetitorData) getValue) {
    final maxValue = _competitors.map(getValue).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._competitors.map((competitor) {
          final value = getValue(competitor);
          final percentage = maxValue > 0 ? value / maxValue : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '@${competitor.username}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.darkBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: AppColors.cyanPurpleGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    _formatNumber(value),
                    style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'ابدأ بإضافة منافسين',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل اسم المستخدم أعلاه لتحليل ملفه',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'عن تحليل المنافسين',
          style: TextStyle(color: AppColors.neonCyan),
        ),
        content: Text(
          'هذه الميزة تستخدم Scrapfly لجلب البيانات العامة من ملفات المنافسين.\n\n'
          '⚠️ ملاحظات:\n'
          '• فقط البيانات العامة\n'
          '• قد يستغرق 5-10 ثوانٍ\n'
          '• محدودة بـ 1000 طلب/شهر (Free plan)\n\n'
          'لمزيد من الطلبات، يمكنك الترقية إلى Scrapfly Pro.',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت', style: TextStyle(color: AppColors.neonCyan)),
          ),
        ],
      ),
    );
  }
}
