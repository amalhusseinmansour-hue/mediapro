import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/utils/app_logger.dart';

/// خدمة يوتيوب لجلب محتوى قناة @Alenwanmedia
class YouTubeService extends GetxController {
  final Dio _dio = Dio();

  // معلومات قناة Alenwanmedia
  static const String channelId = '@Alenwanmedia';
  static const String channelUrl = 'https://www.youtube.com/@Alenwanmedia';

  // YouTube Data API v3
  // ملاحظة: يجب إضافة API Key في البيئة أو في Laravel Backend
  String? _youtubeApiKey;

  final RxList<Map<String, dynamic>> liveStreams = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> videos = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> playlists = <Map<String, dynamic>>[].obs;

  final RxBool isLoadingLive = false.obs;
  final RxBool isLoadingVideos = false.obs;
  final RxBool isLoadingPlaylists = false.obs;

  final RxMap<String, dynamic> channelInfo = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeChannel();
  }

  void _initializeChannel() {
    // بيانات افتراضية للقناة
    channelInfo.value = {
      'id': channelId,
      'name': 'Alenwan Media',
      'url': channelUrl,
      'logo': 'https://yt3.googleusercontent.com/ytc/default_profile.jpg',
      'subscribers': '125K',
      'description': 'قناة متخصصة في أخبار وتحليلات السوشيال ميديا',
    };

    // تحميل البيانات الأولية
    fetchLiveStreams();
    fetchVideos();
  }

  /// جلب البث المباشر (من YouTube API أو Laravel Backend)
  Future<void> fetchLiveStreams() async {
    try {
      isLoadingLive.value = true;
      AppLogger.info('🔴 Fetching live streams from YouTube...');

      // هنا يمكن استدعاء YouTube API أو Laravel Backend
      // مثال: final response = await _dio.get('${ApiConfig.baseUrl}/api/youtube/live');

      // بيانات تجريبية للبث المباشر
      await Future.delayed(Duration(seconds: 1));

      liveStreams.value = [
        {
          'id': 'live1',
          'title': 'البث المباشر - آخر تحديثات السوشيال ميديا 2024',
          'thumbnail': 'https://i.ytimg.com/vi/jfKfPfyJRdk/maxresdefault.jpg',
          'viewers': '1.2K',
          'startedAt': DateTime.now().subtract(Duration(hours: 2)),
          'isLive': true,
        },
      ];

      AppLogger.info('✅ Found ${liveStreams.length} live stream(s)');
    } catch (e) {
      AppLogger.error('❌ Error fetching live streams: $e');
      liveStreams.value = [];
    } finally {
      isLoadingLive.value = false;
    }
  }

  /// جلب الفيديوهات (من YouTube API أو Laravel Backend)
  Future<void> fetchVideos({int maxResults = 20}) async {
    try {
      isLoadingVideos.value = true;
      AppLogger.info('📹 Fetching videos from YouTube channel...');

      // هنا يمكن استدعاء YouTube API أو Laravel Backend
      // مثال: final response = await _dio.get('${ApiConfig.baseUrl}/api/youtube/videos');

      // بيانات تجريبية للفيديوهات
      await Future.delayed(Duration(seconds: 1));

      videos.value = [
        {
          'id': 'video1',
          'title': 'استراتيجيات نمو الحسابات على إنستغرام 2024',
          'thumbnail': 'https://i.ytimg.com/vi/9bZkp7q19f0/maxresdefault.jpg',
          'duration': '15:32',
          'views': '45.2K',
          'publishedAt': DateTime.now().subtract(Duration(days: 2)),
          'isLive': false,
        },
        {
          'id': 'video2',
          'title': 'كيف تزيد متابعينك بطريقة احترافية - دليل شامل',
          'thumbnail': 'https://i.ytimg.com/vi/yXvz2fqfEZw/maxresdefault.jpg',
          'duration': '22:15',
          'views': '89.3K',
          'publishedAt': DateTime.now().subtract(Duration(days: 5)),
          'isLive': false,
        },
        {
          'id': 'video3',
          'title': 'أفضل أدوات إدارة السوشيال ميديا للمحترفين',
          'thumbnail': 'https://i.ytimg.com/vi/HKWxwHlm8Oo/maxresdefault.jpg',
          'duration': '18:47',
          'views': '67.1K',
          'publishedAt': DateTime.now().subtract(Duration(days: 7)),
          'isLive': false,
        },
        {
          'id': 'video4',
          'title': 'تحليل: أهم تريندات السوشيال ميديا لهذا الأسبوع',
          'thumbnail': 'https://i.ytimg.com/vi/LXb3EKWsInQ/maxresdefault.jpg',
          'duration': '12:28',
          'views': '34.5K',
          'publishedAt': DateTime.now().subtract(Duration(days: 10)),
          'isLive': false,
        },
        {
          'id': 'video5',
          'title': 'كيف تنشئ محتوى فيديو احترافي بدون معدات غالية',
          'thumbnail': 'https://i.ytimg.com/vi/jfKfPfyJRdk/maxresdefault.jpg',
          'duration': '25:13',
          'views': '112.8K',
          'publishedAt': DateTime.now().subtract(Duration(days: 14)),
          'isLive': false,
        },
      ];

      AppLogger.info('✅ Loaded ${videos.length} videos');
    } catch (e) {
      AppLogger.error('❌ Error fetching videos: $e');
      videos.value = [];
    } finally {
      isLoadingVideos.value = false;
    }
  }

  /// جلب قوائم التشغيل
  Future<void> fetchPlaylists() async {
    try {
      isLoadingPlaylists.value = true;
      AppLogger.info('📚 Fetching playlists from YouTube channel...');

      await Future.delayed(Duration(seconds: 1));

      playlists.value = [
        {
          'id': 'playlist1',
          'title': 'دروس إدارة السوشيال ميديا',
          'thumbnail': 'https://i.ytimg.com/vi/jfKfPfyJRdk/maxresdefault.jpg',
          'videoCount': 15,
        },
        {
          'id': 'playlist2',
          'title': 'تحليلات وإحصائيات',
          'thumbnail': 'https://i.ytimg.com/vi/yXvz2fqfEZw/maxresdefault.jpg',
          'videoCount': 8,
        },
      ];

      AppLogger.info('✅ Loaded ${playlists.length} playlists');
    } catch (e) {
      AppLogger.error('❌ Error fetching playlists: $e');
      playlists.value = [];
    } finally {
      isLoadingPlaylists.value = false;
    }
  }

  /// جلب معلومات القناة من YouTube API
  Future<void> fetchChannelInfo() async {
    try {
      AppLogger.info('📺 Fetching channel info...');

      // يمكن استدعاء YouTube API هنا
      // مثال: GET https://www.googleapis.com/youtube/v3/channels?part=snippet,statistics&forUsername=Alenwanmedia&key={API_KEY}

      await Future.delayed(Duration(seconds: 1));

      channelInfo.value = {
        'id': channelId,
        'name': 'Alenwan Media',
        'url': channelUrl,
        'logo': 'https://yt3.googleusercontent.com/ytc/default_profile.jpg',
        'subscribers': '125K',
        'description': 'قناة متخصصة في أخبار وتحليلات السوشيال ميديا والتسويق الرقمي',
        'totalViews': '5.2M',
        'videoCount': '234',
      };

      AppLogger.info('✅ Channel info loaded');
    } catch (e) {
      AppLogger.error('❌ Error fetching channel info: $e');
    }
  }

  /// تحديث جميع البيانات
  Future<void> refreshAll() async {
    await Future.wait([
      fetchLiveStreams(),
      fetchVideos(),
      fetchPlaylists(),
      fetchChannelInfo(),
    ]);
  }

  /// فتح فيديو على يوتيوب
  String getVideoUrl(String videoId) {
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// فتح قائمة تشغيل
  String getPlaylistUrl(String playlistId) {
    return 'https://www.youtube.com/playlist?list=$playlistId';
  }

  /// فتح القناة
  String getChannelUrl() {
    return channelUrl;
  }
}
