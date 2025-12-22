import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/intelligent_auto_posting_service.dart';

class IntelligentAutoPostingScreen extends StatefulWidget {
  const IntelligentAutoPostingScreen({super.key});

  @override
  State<IntelligentAutoPostingScreen> createState() =>
      _IntelligentAutoPostingScreenState();
}

class _IntelligentAutoPostingScreenState
    extends State<IntelligentAutoPostingScreen>
    with SingleTickerProviderStateMixin {
  final IntelligentAutoPostingService _service = Get.put(
    IntelligentAutoPostingService(),
  );

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'النشر التلقائي الذكي',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        actions: [
          Obx(
            () => Switch(
              value: _service.autoSchedulingEnabled.value,
              onChanged: (val) => _service.toggleAutoScheduling(val),
              activeThumbColor: const Color(0xFF00D9FF),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D9FF),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'الأوقات الأمثل'),
            Tab(text: 'المنشورات المجدولة'),
            Tab(text: 'الإحصائيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOptimalTimesTab(),
          _buildScheduledPostsTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPostDialog,
        backgroundColor: const Color(0xFF00D9FF),
        icon: const Icon(Icons.add_rounded, color: Color(0xFF0A0A0A)),
        label: const Text(
          'جدولة منشور',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOptimalTimesTab() {
    return Obx(
      () => _service.isAnalyzing.value
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF00D9FF)),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _service.refreshOptimalTimes(),
              color: const Color(0xFF00D9FF),
              backgroundColor: const Color(0xFF1E1E2E),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  ..._service.optimalTimeSlots.map(
                    (slot) => _buildTimeSlotCard(slot),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'نصيحة ذكية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              _service.optimalTimeSlots.isNotEmpty
                  ? 'أفضل وقت للنشر هو يوم ${_service.optimalTimeSlots.first.dayName} الساعة ${_service.optimalTimeSlots.first.timeString}'
                  : 'جاري تحليل البيانات...',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _service.refreshOptimalTimes(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تحديث التحليل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6A11CB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(PostingTimeSlot slot) {
    final scoreColor = slot.successRate >= 0.9
        ? Colors.green
        : slot.successRate >= 0.75
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule_rounded, color: scoreColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.dayName} - ${slot.timeString}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'تفاعل متوسط: ${slot.avgEngagement} • نجاح: ${(slot.successRate * 100).toInt()}%',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${slot.score}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledPostsTab() {
    return Obx(
      () => _service.scheduledPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 100,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'لا توجد منشورات مجدولة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _service.scheduledPosts.length,
              itemBuilder: (context, index) {
                final post = _service.scheduledPosts[index];
                return _buildScheduledPostCard(post);
              },
            ),
    );
  }

  Widget _buildScheduledPostCard(ScheduledPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (post.isAutoScheduled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'جدولة ذكية',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF00D9FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF2A2A3E),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text(
                      'تعديل',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _editScheduledPost(post),
                  ),
                  PopupMenuItem(
                    child: const Text(
                      'حذف',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _service.deleteScheduledPost(post.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Color(0xFF00D9FF),
              ),
              const SizedBox(width: 6),
              Text(
                post.scheduledTime != null
                    ? '${post.scheduledTime!.day}/${post.scheduledTime!.month} - ${post.scheduledTime!.hour}:${post.scheduledTime!.minute.toString().padLeft(2, '0')}'
                    : 'غير محدد',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.public_rounded,
                size: 16,
                color: Color(0xFF00D9FF),
              ),
              const SizedBox(width: 6),
              Text(
                '${post.platforms.length} منصة',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatsCard(
          'المنشورات المجدولة',
          '${_service.postsInQueue.value}',
          Icons.event_note_rounded,
          const Color(0xFF00D9FF),
        ),
        const SizedBox(height: 12),
        _buildStatsCard(
          'المنشورات المنشورة',
          '45',
          Icons.check_circle_rounded,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildStatsCard(
          'معدل النجاح',
          '94%',
          Icons.trending_up_rounded,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildStatsCard(
          'متوسط التفاعل',
          '520',
          Icons.favorite_rounded,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E2E), color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPostDialog() {
    final contentController = TextEditingController();
    final selectedPlatforms = <String>[].obs;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'جدولة منشور جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: contentController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'محتوى المنشور...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر المنصات:',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildPlatformChip('Facebook', 'facebook', selectedPlatforms),
                  _buildPlatformChip(
                    'Instagram',
                    'instagram',
                    selectedPlatforms,
                  ),
                  _buildPlatformChip('Twitter', 'twitter', selectedPlatforms),
                  _buildPlatformChip('LinkedIn', 'linkedin', selectedPlatforms),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (contentController.text.isNotEmpty &&
                          selectedPlatforms.isNotEmpty) {
                        _service.addToAutoSchedule(
                          content: contentController.text,
                          platforms: selectedPlatforms.toList(),
                        );
                        Get.back();
                      } else {
                        Get.snackbar('تنبيه', 'الرجاء ملء جميع الحقول');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: const Color(0xFF0A0A0A),
                    ),
                    child: const Text('جدولة ذكية'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformChip(
    String label,
    String value,
    RxList<String> selectedPlatforms,
  ) {
    return Obx(
      () => FilterChip(
        label: Text(label),
        selected: selectedPlatforms.contains(value),
        onSelected: (selected) {
          if (selected) {
            selectedPlatforms.add(value);
          } else {
            selectedPlatforms.remove(value);
          }
        },
        selectedColor: const Color(0xFF00D9FF),
        labelStyle: TextStyle(
          color: selectedPlatforms.contains(value)
              ? const Color(0xFF0A0A0A)
              : Colors.white,
        ),
      ),
    );
  }

  void _editScheduledPost(ScheduledPost post) {
    // TODO: Implement edit functionality
    Get.snackbar('قريباً', 'ميزة التعديل ستكون متاحة قريباً');
  }
}
