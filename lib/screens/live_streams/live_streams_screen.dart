import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../services/youtube_service.dart';

/// شاشة البث المباشر والقنوات - عرض محتوى قناة يوتيوب Alenwanmedia
class LiveStreamsScreen extends StatefulWidget {
  const LiveStreamsScreen({super.key});

  @override
  State<LiveStreamsScreen> createState() => _LiveStreamsScreenState();
}

class _LiveStreamsScreenState extends State<LiveStreamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final YouTubeService _youtubeService = Get.find<YouTubeService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // تحديث البيانات عند فتح الشاشة
    _youtubeService.refreshAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildChannelInfo(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLiveTab(),
                  _buildVideosTab(),
                  _buildPlaylistsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.live_tv_rounded,
              color: AppColors.neonCyan,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'البث المباشر والقنوات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelInfo() {
    return Obx(() {
      final channel = _youtubeService.channelInfo;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkCard,
              AppColors.darkCard.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Channel Logo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonCyan,
                  width: 2,
                ),
                image: DecorationImage(
                  image: NetworkImage(channel['logo'] ?? ''),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {},
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Channel Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel['name'] ?? 'Alenwan Media',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel['id'] ?? '@Alenwanmedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${channel['subscribers'] ?? '125K'} مشترك',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Subscribe Button
            ElevatedButton(
              onPressed: () => _openYouTubeChannel(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('اشترك'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.cyanPurpleGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textLight,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'مباشر'),
          Tab(text: 'فيديوهات'),
          Tab(text: 'قوائم التشغيل'),
        ],
      ),
    );
  }

  Widget _buildLiveTab() {
    return Obx(() {
      if (_youtubeService.isLoadingLive.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
      }

      final liveVideos = _youtubeService.liveStreams;

      if (liveVideos.isEmpty) {
        return _buildEmptyState('لا يوجد بث مباشر الآن', Icons.live_tv_rounded);
      }

      return RefreshIndicator(
        onRefresh: () => _youtubeService.fetchLiveStreams(),
        color: AppColors.neonCyan,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: liveVideos.length,
          itemBuilder: (context, index) {
            return _buildVideoCard(liveVideos[index], isLive: true);
          },
        ),
      );
    });
  }

  Widget _buildVideosTab() {
    return Obx(() {
      if (_youtubeService.isLoadingVideos.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
      }

      final videos = _youtubeService.videos;

      if (videos.isEmpty) {
        return _buildEmptyState('لا توجد فيديوهات', Icons.video_library);
      }

      return RefreshIndicator(
        onRefresh: () => _youtubeService.fetchVideos(),
        color: AppColors.neonCyan,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return _buildVideoCard(videos[index]);
          },
        ),
      );
    });
  }

  Widget _buildPlaylistsTab() {
    return Obx(() {
      if (_youtubeService.isLoadingPlaylists.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
      }

      final playlists = _youtubeService.playlists;

      if (playlists.isEmpty) {
        return _buildEmptyState('قوائم التشغيل قريباً', Icons.playlist_play);
      }

      return RefreshIndicator(
        onRefresh: () => _youtubeService.fetchPlaylists(),
        color: AppColors.neonCyan,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            return _buildPlaylistCard(playlists[index]);
          },
        ),
      );
    });
  }

  Widget _buildVideoCard(Map<String, dynamic> video, {bool isLive = false}) {
    return GestureDetector(
      onTap: () => _openVideo(video['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive
                ? Colors.red.withValues(alpha: 0.5)
                : AppColors.neonCyan.withValues(alpha: 0.2),
          ),
          boxShadow: [
            if (isLive)
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video['thumbnail'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.darkBg,
                          child: Icon(
                            Icons.video_library,
                            size: 50,
                            color: AppColors.textLight,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Duration or LIVE badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.red : Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          video['duration'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Video Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${video['views']} مشاهدة',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'يشاهدون الآن',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(Map<String, dynamic> playlist) {
    return GestureDetector(
      onTap: () => _openPlaylist(playlist['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    playlist['thumbnail'],
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 90,
                        color: AppColors.darkBg,
                        child: Icon(Icons.playlist_play, color: AppColors.textLight),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Center(
                        child: Icon(
                          Icons.playlist_play,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Playlist Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${playlist['videoCount']} فيديو',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openYouTubeChannel() async {
    final String url = _youtubeService.getChannelUrl();
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح القناة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openVideo(String videoId) async {
    final String url = _youtubeService.getVideoUrl(videoId);
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح الفيديو',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openPlaylist(String playlistId) async {
    final String url = _youtubeService.getPlaylistUrl(playlistId);
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح قائمة التشغيل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
