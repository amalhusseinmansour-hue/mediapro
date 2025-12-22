import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/multi_platform_post_service.dart';
import '../../services/ai_media_service.dart';
import '../schedule/schedule_post_screen.dart';

/// شاشة تقويم المحتوى
/// تعرض المنشورات المجدولة في شكل تقويم شهري مع اقتراحات AI
class ContentCalendarScreen extends StatefulWidget {
  const ContentCalendarScreen({super.key});

  @override
  State<ContentCalendarScreen> createState() => _ContentCalendarScreenState();
}

class _ContentCalendarScreenState extends State<ContentCalendarScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  late PageController _pageController;
  late AnimationController _fadeController;

  MultiPlatformPostService? _postService;
  AIMediaService? _aiMediaService;

  bool _isLoadingSuggestions = false;
  List<String> _aiSuggestions = [];

  // Sample events for demonstration
  final Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: 500);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.forward();

    // Initialize services
    try {
      _postService = Get.find<MultiPlatformPostService>();
    } catch (e) {
      print('MultiPlatformPostService not found: $e');
    }

    try {
      _aiMediaService = Get.find<AIMediaService>();
    } catch (e) {
      print('AIMediaService not found: $e');
    }

    _loadScheduledPosts();
  }

  void _loadScheduledPosts() {
    if (_postService == null) return;

    // تحميل المنشورات المجدولة وتحويلها إلى أحداث
    for (var post in _postService!.scheduledPosts) {
      final date = DateTime(
        post.scheduledTime.year,
        post.scheduledTime.month,
        post.scheduledTime.day,
      );

      if (!_events.containsKey(date)) {
        _events[date] = [];
      }

      _events[date]!.add(CalendarEvent(
        id: post.id ?? '',
        title: post.content.length > 50
            ? '${post.content.substring(0, 50)}...'
            : post.content,
        time: DateFormat('HH:mm').format(post.scheduledTime),
        platforms: post.platforms,
        type: EventType.scheduled,
        color: AppColors.primaryPurple,
      ));
    }
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAISuggestions() async {
    if (_aiMediaService == null) return;

    setState(() => _isLoadingSuggestions = true);

    // محاكاة اقتراحات AI
    await Future.delayed(const Duration(seconds: 1));

    final dayName = DateFormat('EEEE', 'ar').format(_selectedDate);
    final suggestions = [
      'منشور ملهم ليوم $dayName - اقتباس عن النجاح والتحفيز',
      'فيديو قصير عن نصائح احترافية في مجالك',
      'استطلاع رأي للتفاعل مع جمهورك',
      'قصة نجاح ملهمة من عملائك',
      'محتوى تعليمي - شرح خطوة بخطوة',
    ];

    setState(() {
      _aiSuggestions = suggestions;
      _isLoadingSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: _fadeController,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildCalendarHeader(),
                  _buildCalendarGridSafe(),
                  const SizedBox(height: 20),
                  _buildSelectedDateEventsSafe(),
                  const SizedBox(height: 20),
                  _buildAISuggestionsSafe(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Safe wrapper for calendar grid with error handling
  Widget _buildCalendarGridSafe() {
    try {
      return _buildCalendarGrid();
    } catch (e) {
      print('Error building calendar grid: $e');
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'خطأ في تحميل التقويم',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  /// Safe wrapper for selected date events with error handling
  Widget _buildSelectedDateEventsSafe() {
    try {
      return _buildSelectedDateEvents();
    } catch (e) {
      print('Error building selected date events: $e');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'خطأ في تحميل المنشورات',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  /// Safe wrapper for AI suggestions with error handling
  Widget _buildAISuggestionsSafe() {
    try {
      return _buildAISuggestions();
    } catch (e) {
      print('Error building AI suggestions: $e');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'خطأ في تحميل اقتراحات AI',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPurple,
              AppColors.neonBlue,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: const Text(
            'تقويم المحتوى',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.8),
                  AppColors.neonBlue.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 60, right: 20, top: 20),
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.today_rounded),
          onPressed: () {
            setState(() {
              _selectedDate = DateTime.now();
              _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
            });
          },
          tooltip: 'اليوم',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loadScheduledPosts,
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    final monthYear = DateFormat('MMMM yyyy', 'ar').format(_focusedMonth);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            monthYear,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;

    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );

    // Get the weekday (Saturday = 6 in Arabic calendar)
    int startOffset = (firstDayOfMonth.weekday + 1) % 7;

    final dayNames = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Days header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayNames.map((day) {
              return SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + startOffset,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox();
              }

              final day = index - startOffset + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final hasEvents = _events[date]?.isNotEmpty ?? false;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadAISuggestions();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : isToday
                            ? AppColors.primaryPurple.withValues(alpha: 0.3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primaryPurple, width: 2)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColors.primaryPurple
                                  : Colors.white,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (hasEvents)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateEvents() {
    final events = _events[DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    )] ?? [];

    final formattedDate = DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.neonBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المنشورات المجدولة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${events.length} منشور',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (events.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد منشورات مجدولة لهذا اليوم',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Get.to(() => const SchedulePostScreen()),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('إضافة منشور'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            )
          else
            ...events.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(
            color: event.color,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getEventIcon(event.type),
              color: event.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ...event.platforms.take(3).map((platform) => Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            _getPlatformIcon(platform),
                            size: 14,
                            color: Colors.grey[500],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.grey[500],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.2),
            AppColors.neonBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.neonBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'اقتراحات AI للمحتوى',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!_isLoadingSuggestions && _aiSuggestions.isEmpty)
                TextButton.icon(
                  onPressed: _loadAISuggestions,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('تحميل'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingSuggestions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppColors.primaryPurple,
                ),
              ),
            )
          else if (_aiSuggestions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'اضغط "تحميل" للحصول على اقتراحات محتوى من AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_aiSuggestions.length, (index) {
              return _buildSuggestionCard(index, _aiSuggestions[index]);
            }),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(int index, String suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Navigate to create post with suggestion
            Get.to(() => const SchedulePostScreen(), arguments: {
              'suggestion': suggestion,
              'date': _selectedDate,
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.neonBlue],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => const SchedulePostScreen()),
      backgroundColor: AppColors.primaryPurple,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'إضافة منشور',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.scheduled:
        return Icons.schedule_rounded;
      case EventType.published:
        return Icons.check_circle_rounded;
      case EventType.draft:
        return Icons.edit_note_rounded;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'facebook':
        return Icons.facebook_rounded;
      case 'twitter':
      case 'x':
        return Icons.alternate_email_rounded;
      case 'tiktok':
        return Icons.music_note_rounded;
      case 'linkedin':
        return Icons.work_rounded;
      case 'youtube':
        return Icons.play_circle_rounded;
      default:
        return Icons.public_rounded;
    }
  }
}

/// أنواع الأحداث
enum EventType {
  scheduled,
  published,
  draft,
}

/// نموذج حدث التقويم
class CalendarEvent {
  final String id;
  final String title;
  final String time;
  final List<String> platforms;
  final EventType type;
  final Color color;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.time,
    required this.platforms,
    required this.type,
    required this.color,
  });
}
