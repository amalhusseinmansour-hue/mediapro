import 'package:get/get.dart';
import '../models/post_model.dart';
import '../models/community_post_model.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
// import 'laravel_community_service.dart'; // ❌ Removed - Not core feature
import 'settings_service.dart';

/// خدمة المجتمع - لجلب وإدارة البوستات المنشورة والترندات
class CommunityService extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  // final LaravelCommunityService _laravelCommunityService = Get.find<LaravelCommunityService>(); // ❌ Removed
  final AuthService _authService = Get.find<AuthService>();
  final SettingsService _settingsService = Get.find<SettingsService>();

  final RxList<PostModel> allCommunityPosts = <PostModel>[].obs;
  final RxList<TrendingTopicModel> trendingTopics = <TrendingTopicModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'الكل'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCommunityPosts();
    fetchTrendingTopics();
  }

  /// جلب جميع البوستات المنشورة من جميع المستخدمين
  Future<void> fetchCommunityPosts() async {
    try {
      isLoading.value = true;

      // استخدام Laravel API إذا كان Firebase معطل في الإعدادات
      if (!_settingsService.firebaseEnabled) {
        /* Laravel Community Service removed
        print('📤 Fetching community posts from Laravel API...');
        final result = await _laravelCommunityService.getCommunityPosts(
          page: 1,
          perPage: 50,
          visibility: 'public',
        );

        if (result['success'] == true && result['data'] != null) {
          // تحويل البيانات من Laravel إلى PostModel
          final posts = (result['data'] as List)
              .map((postData) => _convertLaravelPostToPostModel(postData))
              .toList();

          if (posts.isNotEmpty) {
            allCommunityPosts.value = posts;
            print('✅ ${posts.length} posts loaded from Laravel API');
            return;
          }
        }
        */
        print('ℹ️ Community feature disabled, using demo data');
        allCommunityPosts.value = _getDemoPosts();
      } else {
        // استخدام Firebase إذا كان مفعل
        print('📤 Fetching community posts from Firebase...');
        final posts = await _firestoreService.getAllPublishedPosts();

        if (posts.isEmpty) {
          print('ℹ️ No posts found in Firebase, using demo data');
          allCommunityPosts.value = _getDemoPosts();
        } else {
          allCommunityPosts.value = posts;
          print('✅ ${posts.length} posts loaded from Firebase');
        }
      }
    } catch (e) {
      print('⚠️ خطأ في جلب بوستات المجتمع: $e');
      print('✅ استخدام بيانات تجريبية بدلاً من ذلك');
      // في حالة الفشل، استخدم بيانات تجريبية
      allCommunityPosts.value = _getDemoPosts();
    } finally {
      isLoading.value = false;
    }
  }

  /// تحويل بيانات Laravel إلى PostModel
  PostModel _convertLaravelPostToPostModel(Map<String, dynamic> laravelPost) {
    return PostModel(
      id: laravelPost['id'].toString(),
      content: laravelPost['content'] ?? '',
      platforms: ['community'], // Community posts
      createdAt: DateTime.tryParse(laravelPost['created_at'] ?? '') ?? DateTime.now(),
      publishedAt: DateTime.tryParse(laravelPost['published_at'] ?? ''),
      status: laravelPost['published_at'] != null ? PostStatus.published : PostStatus.draft,
      hashtags: List<String>.from(laravelPost['tags'] ?? []),
      analytics: {
        'likes': laravelPost['likes_count'] ?? 0,
        'comments': laravelPost['comments_count'] ?? 0,
        'views': laravelPost['media_count'] ?? 0,
      },
    );
  }

  /// جلب البوستات المفلترة حسب الفئة
  List<PostModel> getFilteredPosts() {
    if (selectedCategory.value == 'الكل') {
      return allCommunityPosts;
    }

    // فلترة حسب الهاشتاج أو المحتوى
    return allCommunityPosts
        .where((post) =>
            post.hashtags.any((tag) => tag.contains(selectedCategory.value)) ||
            post.content.contains(selectedCategory.value))
        .toList();
  }

  /// جلب الترندات المفلترة حسب الفئة
  List<TrendingTopicModel> getFilteredTrendingTopics() {
    if (selectedCategory.value == 'الكل') {
      return trendingTopics;
    }

    // فلترة حسب الفئة
    return trendingTopics
        .where((trend) => trend.category == selectedCategory.value)
        .toList();
  }

  /// تحديث الفئة المختارة
  void setSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  /// إعجاب ببوست
  Future<bool> likePost(String postId) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) return false;

      // هنا يمكن إضافة logic لحفظ الإعجاب في قاعدة البيانات
      // await _firestoreService.addLikeToPost(postId, userId);

      return true;
    } catch (e) {
      print('خطأ في الإعجاب بالبوست: $e');
      return false;
    }
  }

  /// إضافة تعليق على بوست
  Future<bool> addComment(String postId, String comment) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) return false;

      // هنا يمكن إضافة logic لحفظ التعليق في قاعدة البيانات
      // await _firestoreService.addCommentToPost(postId, userId, comment);

      return true;
    } catch (e) {
      print('خطأ في إضافة التعليق: $e');
      return false;
    }
  }

  /// بيانات تجريبية للعرض (في حالة عدم وجود بيانات أو فشل الاتصال)
  List<PostModel> _getDemoPosts() {
    return [
      PostModel(
        id: 'demo_1',
        content: '🚀 10 نصائح لزيادة التفاعل على Instagram\n\n'
            'اكتشف أفضل الطرق لزيادة التفاعل على حسابك في Instagram وبناء مجتمع متفاعل...',
        platforms: ['Instagram'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: PostStatus.published,
        hashtags: ['#تسويق', '#انستغرام', '#نصائح'],
        analytics: {'likes': 245, 'comments': 32, 'shares': 12},
      ),
      PostModel(
        id: 'demo_2',
        content: '🎥 كيفية إنشاء محتوى فيديو جذاب\n\n'
            'تعلم كيفية إنشاء محتوى فيديو احترافي يجذب انتباه جمهورك ويزيد من المشاهدات...',
        platforms: ['TikTok', 'Instagram'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: PostStatus.published,
        hashtags: ['#محتوى', '#فيديو', '#تيك_توك'],
        analytics: {'likes': 189, 'comments': 21, 'shares': 8, 'views': 3400},
      ),
      PostModel(
        id: 'demo_3',
        content: '💼 استراتيجيات Facebook للشركات الصغيرة\n\n'
            'دليل شامل لاستخدام Facebook لتنمية أعمالك الصغيرة والوصول إلى جمهور أوسع...',
        platforms: ['Facebook'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        status: PostStatus.published,
        hashtags: ['#استراتيجية', '#فيسبوك', '#أعمال'],
        analytics: {'likes': 312, 'comments': 45, 'shares': 23},
      ),
      PostModel(
        id: 'demo_4',
        content: '⏰ أفضل أوقات النشر على Twitter\n\n'
            'تحليل شامل لأفضل الأوقات للنشر على Twitter للحصول على أقصى تفاعل...',
        platforms: ['Twitter'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: PostStatus.published,
        hashtags: ['#توقيت', '#تويتر', '#تحليلات'],
        analytics: {'likes': 156, 'comments': 18, 'shares': 9, 'retweets': 34},
      ),
      PostModel(
        id: 'demo_5',
        content: '🎨 بناء العلامة التجارية على TikTok\n\n'
            'كيف تستخدم TikTok لبناء علامة تجارية قوية وجذب جمهور الشباب...',
        platforms: ['TikTok'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: PostStatus.published,
        hashtags: ['#علامة_تجارية', '#تيك_توك', '#تسويق'],
        analytics: {'likes': 278, 'comments': 39, 'shares': 17, 'views': 8900},
      ),
    ];
  }

  /// تحديث البوستات
  Future<void> refreshPosts() async {
    await fetchCommunityPosts();
    await fetchTrendingTopics();
  }

  /// جلب الترندات الحالية
  Future<void> fetchTrendingTopics() async {
    try {
      // في المستقبل، يمكن جلب الترندات من API خارجي (Twitter API, Google Trends, etc.)
      // أو من تحليل الهاشتاجات في البوستات المحلية

      trendingTopics.value = _getDemoTrends();
    } catch (e) {
      print('خطأ في جلب الترندات: $e');
      trendingTopics.value = _getDemoTrends();
    }
  }

  /// بيانات ترندات تجريبية مع أفكار محتوى عملية
  List<TrendingTopicModel> _getDemoTrends() {
    return [
      TrendingTopicModel(
        id: '1',
        title: 'الذكاء الاصطناعي في التسويق',
        hashtag: '#الذكاء_الاصطناعي',
        postsCount: 45678,
        category: 'تقنية',
        description: 'استخدام AI في إنشاء المحتوى والتحليلات',
        trendingScore: 9.8,
        relatedHashtags: ['#AI', '#تسويق', '#تقنية', '#ChatGPT'],
        iconEmoji: '🤖',
        trendingReason: 'ارتفاع بنسبة 234% في آخر 7 أيام',
        contentIdeas: [
          ContentIdeaModel(
            id: 'ai_1',
            title: 'كيف يساعدك ChatGPT في كتابة المحتوى',
            description: 'شارك تجربتك مع الذكاء الاصطناعي في إنشاء محتوى السوشيال ميديا',
            suggestedPlatforms: ['Instagram', 'TikTok', 'LinkedIn'],
            contentType: 'فيديو قصير',
            estimatedEngagement: 85,
            exampleText: '5 طرق أستخدم بها ChatGPT لتوفير 10 ساعات أسبوعياً في صناعة المحتوى',
          ),
          ContentIdeaModel(
            id: 'ai_2',
            title: 'أدوات AI المجانية للمسوقين',
            description: 'قائمة بأفضل أدوات الذكاء الاصطناعي المجانية',
            suggestedPlatforms: ['Twitter', 'LinkedIn', 'Facebook'],
            contentType: 'carousel/thread',
            estimatedEngagement: 78,
            exampleText: 'أفضل 10 أدوات AI مجانية يحتاجها كل مسوق\n\n1. ChatGPT - كتابة المحتوى\n2. Midjourney - توليد الصور\n3. Jasper - التسويق بالمحتوى',
          ),
          ContentIdeaModel(
            id: 'ai_3',
            title: 'قبل وبعد استخدام AI',
            description: 'مقارنة بين عملك قبل وبعد استخدام الذكاء الاصطناعي',
            suggestedPlatforms: ['Instagram', 'Facebook'],
            contentType: 'صورة مقارنة',
            estimatedEngagement: 92,
            exampleText: 'من 8 ساعات إلى 2 ساعات فقط!\nهكذا غيّر الذكاء الاصطناعي طريقة عملي',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '2',
        title: 'Reels ومحتوى الفيديو القصير',
        hashtag: '#Reels',
        postsCount: 123456,
        category: 'محتوى',
        description: 'ترند الفيديوهات القصيرة على جميع المنصات',
        trendingScore: 9.5,
        relatedHashtags: ['#فيديو', '#محتوى', '#انستقرام', '#TikTok'],
        iconEmoji: '🎬',
        trendingReason: 'أعلى معدل تفاعل في 2025',
        contentIdeas: [
          ContentIdeaModel(
            id: 'reels_1',
            title: 'سر Reels الفيرال',
            description: 'شارك السر وراء Reel حصل على مليون مشاهدة',
            suggestedPlatforms: ['Instagram', 'TikTok'],
            contentType: 'فيديو تعليمي',
            estimatedEngagement: 95,
            exampleText: '3 أسرار جعلت Reel الأخير يحصل على مليون مشاهدة\n\n1. Hook في أول 3 ثواني\n2. موسيقى ترندينج\n3. CTA واضح',
          ),
          ContentIdeaModel(
            id: 'reels_2',
            title: 'من وراء الكواليس',
            description: 'أظهر كيف تصنع Reels احترافي من الهاتف',
            suggestedPlatforms: ['Instagram', 'YouTube'],
            contentType: 'behind the scenes',
            estimatedEngagement: 88,
            exampleText: 'هكذا أصنع Reels احترافي بهاتفي فقط',
          ),
          ContentIdeaModel(
            id: 'reels_3',
            title: 'Reels Templates',
            description: 'شارك قوالب Reels جاهزة للاستخدام',
            suggestedPlatforms: ['Instagram', 'TikTok'],
            contentType: 'tutorial',
            estimatedEngagement: 91,
            exampleText: '10 قوالب Reels احفظها واستخدمها\n\n✅ Before & After\n✅ Day in the Life\n✅ Quick Tips',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '3',
        title: 'التسويق بالمؤثرين 2025',
        hashtag: '#مؤثرين',
        postsCount: 78901,
        category: 'تسويق',
        description: 'أحدث استراتيجيات التعاون مع المؤثرين',
        trendingScore: 9.2,
        relatedHashtags: ['#تسويق', '#تعاون', '#برانديانج', '#UGC'],
        iconEmoji: '🌟',
        trendingReason: 'نمو سوق المؤثرين 21% في Q1',
        contentIdeas: [
          ContentIdeaModel(
            id: 'inf_1',
            title: 'كيف أصبحت مايكرو مؤثر',
            description: 'رحلتك من 0 إلى 10K متابع ومتوسط الدخل',
            suggestedPlatforms: ['Instagram', 'LinkedIn', 'YouTube'],
            contentType: 'قصة شخصية',
            estimatedEngagement: 87,
            exampleText: 'من 500 متابع إلى مايكرو مؤثر براتب 5000 ريال شهرياً\n\nخطة الـ 90 يوم',
          ),
          ContentIdeaModel(
            id: 'inf_2',
            title: 'أسعار المؤثرين في السعودية',
            description: 'دليل أسعار التعاون مع المؤثرين حسب عدد المتابعين',
            suggestedPlatforms: ['Twitter', 'LinkedIn'],
            contentType: 'infographic',
            estimatedEngagement: 93,
            exampleText: 'كم يأخذ المؤثر السعودي؟\n\nNano (1K-10K): 300-1000 ريال\nMicro (10K-50K): 1000-5000 ريال\nMid (50K-500K): 5000-30000 ريال',
          ),
          ContentIdeaModel(
            id: 'inf_3',
            title: 'Brand Deals لا تقبلها',
            description: 'Red flags في عروض التعاون مع الشركات',
            suggestedPlatforms: ['TikTok', 'Instagram', 'Twitter'],
            contentType: 'قائمة تحذيرية',
            estimatedEngagement: 89,
            exampleText: '5 علامات تحذيرية في عروض Brands:\n\n🚩 exposure بدل دفع\n🚩 بدون عقد\n🚩 حقوق غير محدودة',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '4',
        title: 'محتوى UGC - المحتوى الأصيل',
        hashtag: '#UGC',
        postsCount: 56789,
        category: 'محتوى',
        description: 'المحتوى الذي ينشئه المستخدمون',
        trendingScore: 8.9,
        relatedHashtags: ['#محتوى', '#مجتمع', '#تفاعل', '#Authentic'],
        iconEmoji: '📸',
        trendingReason: 'UGC يحصل على 4X تفاعل أكثر',
        contentIdeas: [
          ContentIdeaModel(
            id: 'ugc_1',
            title: 'أمثلة UGC ناجحة',
            description: 'شارك حملات UGC حصلت على ملايين المشاهدات',
            suggestedPlatforms: ['Instagram', 'TikTok', 'LinkedIn'],
            contentType: 'case study',
            estimatedEngagement: 86,
            exampleText: '3 حملات UGC سعودية حققت ملايين المشاهدات\n\n1. #رمضان_زمان لـ @brand\n2. #تحدي_القهوة\n3. #شارك_قصتك',
          ),
          ContentIdeaModel(
            id: 'ugc_2',
            title: 'كيف تصنع فيديو UGC احترافي',
            description: 'دليل خطوة بخطوة لإنشاء UGC content',
            suggestedPlatforms: ['YouTube', 'Instagram', 'TikTok'],
            contentType: 'tutorial',
            estimatedEngagement: 92,
            exampleText: 'كيف تصنع UGC فيديو بـ 500 ريال فقط\n\nالمعدات + الإضاءة + السكريبت',
          ),
          ContentIdeaModel(
            id: 'ugc_3',
            title: 'أدخل من UGC شهرياً',
            description: 'كشف دخل UGC creator والعملاء',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'income reveal',
            estimatedEngagement: 94,
            exampleText: 'كم أربح من UGC شهرياً؟\n\nعملاء: 8\nمتوسط: 800 ريال\nالإجمالي: 6400 ريال',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '5',
        title: 'السوشيال ميديا والصحة النفسية',
        hashtag: '#صحة_نفسية',
        postsCount: 34567,
        category: 'توعية',
        description: 'العلاقة بين السوشيال ميديا والصحة النفسية',
        trendingScore: 8.7,
        relatedHashtags: ['#صحة', '#توعية', '#DigitalWellbeing'],
        iconEmoji: '💚',
        trendingReason: 'موضوع ترند عالمياً في 2025',
        contentIdeas: [
          ContentIdeaModel(
            id: 'mental_1',
            title: 'Digital Detox تجربتي',
            description: 'شارك تجربتك في الابتعاد عن السوشيال ميديا',
            suggestedPlatforms: ['Instagram', 'Twitter', 'LinkedIn'],
            contentType: 'تجربة شخصية',
            estimatedEngagement: 88,
            exampleText: 'أسبوع بدون انستقرام - ماذا حدث؟\n\nالنوم تحسن 80%\nالإنتاجية زادت\nالقلق قل',
          ),
          ContentIdeaModel(
            id: 'mental_2',
            title: 'علامات إدمان السوشيال ميديا',
            description: 'قائمة بعلامات الإفراط في استخدام السوشيال ميديا',
            suggestedPlatforms: ['TikTok', 'Instagram', 'Twitter'],
            contentType: 'توعية',
            estimatedEngagement: 85,
            exampleText: '7 علامات إدمان السوشيال ميديا:\n\n✓ أول ما تفتحه صباحاً\n✓ Scroll قبل النوم\n✓ FOMO مستمر',
          ),
          ContentIdeaModel(
            id: 'mental_3',
            title: 'روتين صحي للسوشيال ميديا',
            description: 'كيف تستخدم السوشيال ميديا بشكل صحي',
            suggestedPlatforms: ['Instagram', 'YouTube'],
            contentType: 'نصائح عملية',
            estimatedEngagement: 91,
            exampleText: 'روتيني الصحي للسوشيال ميديا:\n\n⏰ 30 دقيقة صباحاً\n⏰ 30 دقيقة مساءً\n🚫 ممنوع في السرير',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '6',
        title: 'التجارة الإلكترونية في السعودية',
        hashtag: '#التجارة_الالكترونية',
        postsCount: 42134,
        category: 'أعمال',
        description: 'ثورة البيع أونلاين في المملكة',
        trendingScore: 9.0,
        relatedHashtags: ['#متجر_الكتروني', '#dropshipping', '#سلة', '#زد'],
        iconEmoji: '🛒',
        trendingReason: 'نمو التجارة الإلكترونية 45% في السعودية',
        contentIdeas: [
          ContentIdeaModel(
            id: 'ecom_1',
            title: 'أرباحي من متجري الإلكتروني',
            description: 'كشف دخل شهري من متجر إلكتروني صغير',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'income report',
            estimatedEngagement: 96,
            exampleText: 'كم ربحت من متجري الإلكتروني أول شهر؟\n\nالمبيعات: 15,000 ريال\nالتكلفة: 8,000 ريال\nالربح: 7,000 ريال',
          ),
          ContentIdeaModel(
            id: 'ecom_2',
            title: 'سلة vs زد - المقارنة الكاملة',
            description: 'مقارنة شاملة بين أشهر منصات المتاجر الإلكترونية',
            suggestedPlatforms: ['Twitter', 'LinkedIn', 'Instagram'],
            contentType: 'مقارنة',
            estimatedEngagement: 89,
            exampleText: 'سلة 🆚 زد - أيهما أفضل؟\n\n💰 التسعير\n🛠️ المميزات\n📱 سهولة الاستخدام',
          ),
          ContentIdeaModel(
            id: 'ecom_3',
            title: 'نيتش مربحة للمبتدئين',
            description: 'أفكار نيتش مربحة للبدء في التجارة الإلكترونية',
            suggestedPlatforms: ['TikTok', 'Instagram', 'Twitter'],
            contentType: 'قائمة أفكار',
            estimatedEngagement: 93,
            exampleText: '5 نيتش مربحة في السعودية 2025:\n\n1. منتجات رمضانية\n2. ملابس محتشمة عصرية\n3. قهوة مختصة\n4. عطور طبيعية\n5. ديكور منزلي',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '7',
        title: 'التصميم الجرافيكي للمبتدئين',
        hashtag: '#تصميم',
        postsCount: 67890,
        category: 'محتوى',
        description: 'تعلم التصميم الجرافيكي وإنشاء محتوى بصري احترافي',
        trendingScore: 8.8,
        relatedHashtags: ['#Canva', '#فوتوشوب', '#تصميم_جرافيك', '#GraphicDesign'],
        iconEmoji: '🎨',
        trendingReason: 'الطلب على المصممين زاد 67%',
        contentIdeas: [
          ContentIdeaModel(
            id: 'design_1',
            title: 'Canva Hacks احترافية',
            description: 'حيل وأسرار Canva لتصميمات احترافية',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'tutorial',
            estimatedEngagement: 91,
            exampleText: '10 حيل Canva لا يعرفها المبتدئون\n\n✨ Magic Resize\n✨ Brand Kit\n✨ Background Remover',
          ),
          ContentIdeaModel(
            id: 'design_2',
            title: 'أخطاء المصممين المبتدئين',
            description: 'أخطاء شائعة في التصميم وكيفية تجنبها',
            suggestedPlatforms: ['Instagram', 'LinkedIn', 'Twitter'],
            contentType: 'قائمة نصائح',
            estimatedEngagement: 87,
            exampleText: '7 أخطاء تدمر تصاميمك:\n\n❌ استخدام خطوط كثيرة\n❌ الألوان غير متناسقة\n❌ عدم التوازن البصري',
          ),
          ContentIdeaModel(
            id: 'design_3',
            title: 'كم أربح كمصمم فريلانسر',
            description: 'كشف دخل شهري من التصميم الجرافيكي',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'income reveal',
            estimatedEngagement: 94,
            exampleText: 'دخلي الشهري من التصميم:\n\nعدد المشاريع: 12\nمتوسط السعر: 500 ريال\nالإجمالي: 6,000 ريال',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '8',
        title: 'التصوير الفوتوغرافي بالهاتف',
        hashtag: '#تصوير',
        postsCount: 89012,
        category: 'محتوى',
        description: 'فن التصوير الاحترافي باستخدام الهاتف',
        trendingScore: 8.6,
        relatedHashtags: ['#Photography', '#MobilePhotography', '#تصوير_احترافي'],
        iconEmoji: '📷',
        trendingReason: '90% من المحتوى يتم تصويره بالهواتف',
        contentIdeas: [
          ContentIdeaModel(
            id: 'photo_1',
            title: 'إعدادات كاميرا الآيفون للمحترفين',
            description: 'الإعدادات السرية لكاميرا iPhone',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'tutorial',
            estimatedEngagement: 92,
            exampleText: 'إعدادات آيفون للتصوير الاحترافي:\n\n📱 HDR: تشغيل\n📱 Grid: تشغيل\n📱 ProRAW: تفعيل',
          ),
          ContentIdeaModel(
            id: 'photo_2',
            title: 'أفضل تطبيقات تحرير الصور',
            description: 'مقارنة شاملة لتطبيقات تعديل الصور',
            suggestedPlatforms: ['Instagram', 'Twitter', 'LinkedIn'],
            contentType: 'مقارنة',
            estimatedEngagement: 88,
            exampleText: 'أفضل 5 تطبيقات تعديل صور:\n\n1. Lightroom - للمحترفين\n2. VSCO - للفلاتر\n3. Snapseed - مجاني وقوي',
          ),
          ContentIdeaModel(
            id: 'photo_3',
            title: 'تحدي التصوير اليومي',
            description: 'تحدي 30 يوم لتطوير مهارات التصوير',
            suggestedPlatforms: ['Instagram', 'TikTok'],
            contentType: 'challenge',
            estimatedEngagement: 90,
            exampleText: 'تحدي التصوير 30 يوم\n\nاليوم 1: Golden Hour\nاليوم 2: Portrait\nاليوم 3: Flat Lay',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '9',
        title: 'بناء العلامة الشخصية',
        hashtag: '#Personal_Branding',
        postsCount: 54321,
        category: 'تسويق',
        description: 'استراتيجيات بناء هوية شخصية قوية على السوشيال ميديا',
        trendingScore: 9.3,
        relatedHashtags: ['#علامة_شخصية', '#تسويق_شخصي', '#ContentCreator'],
        iconEmoji: '💎',
        trendingReason: 'أهم استثمار في 2025',
        contentIdeas: [
          ContentIdeaModel(
            id: 'pb_1',
            title: 'كيف بنيت علامتي الشخصية',
            description: 'رحلة بناء Personal Brand من الصفر',
            suggestedPlatforms: ['LinkedIn', 'Instagram', 'YouTube'],
            contentType: 'قصة شخصية',
            estimatedEngagement: 89,
            exampleText: 'من موظف عادي إلى Personal Brand\n\nالبداية: 300 متابع\nبعد سنة: 50K متابع\nالدخل: 20,000 ريال/شهر',
          ),
          ContentIdeaModel(
            id: 'pb_2',
            title: 'استراتيجية المحتوى الشخصي',
            description: 'خطة محتوى لبناء علامة شخصية قوية',
            suggestedPlatforms: ['Twitter', 'LinkedIn', 'Instagram'],
            contentType: 'استراتيجية',
            estimatedEngagement: 91,
            exampleText: 'خطة المحتوى الأسبوعية:\n\nالإثنين: تعليمي\nالأربعاء: قصة شخصية\nالجمعة: إنجازات\nالسبت: Engagement',
          ),
          ContentIdeaModel(
            id: 'pb_3',
            title: 'Niche Down - اختر تخصصك',
            description: 'كيف تختار النيتش المناسب لعلامتك',
            suggestedPlatforms: ['TikTok', 'Instagram', 'LinkedIn'],
            contentType: 'نصائح',
            estimatedEngagement: 86,
            exampleText: 'كيف تختار النيتش:\n\n✅ شغفك\n✅ خبرتك\n✅ الطلب في السوق\n✅ المنافسة',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '10',
        title: 'العمل الحر والفريلانسينج',
        hashtag: '#فريلانسر',
        postsCount: 98765,
        category: 'أعمال',
        description: 'النجاح في العمل الحر والحصول على عملاء',
        trendingScore: 9.1,
        relatedHashtags: ['#Freelancing', '#عمل_حر', '#مستقل', '#Upwork'],
        iconEmoji: '💼',
        trendingReason: 'سوق الفريلانس نما 156% في السعودية',
        contentIdeas: [
          ContentIdeaModel(
            id: 'free_1',
            title: 'أول 1000 دولار من Upwork',
            description: 'استراتيجية الحصول على أول عميل على Upwork',
            suggestedPlatforms: ['LinkedIn', 'YouTube', 'Twitter'],
            contentType: 'دليل عملي',
            estimatedEngagement: 95,
            exampleText: 'كيف حققت أول 1000 دولار على Upwork:\n\n✅ Profile احترافي\n✅ Proposals مخصصة\n✅ الصبر والاستمرار',
          ),
          ContentIdeaModel(
            id: 'free_2',
            title: 'أسعار الخدمات في مستقل',
            description: 'دليل التسعير للفريلانسرز المبتدئين',
            suggestedPlatforms: ['Twitter', 'LinkedIn', 'Instagram'],
            contentType: 'دليل أسعار',
            estimatedEngagement: 92,
            exampleText: 'متوسط الأسعار في مستقل:\n\nكتابة مقال: 50-200 ريال\nتصميم لوجو: 200-800 ريال\nتطوير موقع: 2000-10000 ريال',
          ),
          ContentIdeaModel(
            id: 'free_3',
            title: 'أخطاء الفريلانسر المبتدئ',
            description: 'أخطاء تكلفك آلاف الريالات',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'تحذيرات',
            estimatedEngagement: 88,
            exampleText: '5 أخطاء كلفتني 30,000 ريال:\n\n❌ التسعير المنخفض\n❌ بدون عقد\n❌ Scope Creep',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '11',
        title: 'كتابة المحتوى Copywriting',
        hashtag: '#Copywriting',
        postsCount: 43210,
        category: 'محتوى',
        description: 'فن كتابة محتوى تسويقي مقنع',
        trendingScore: 8.7,
        relatedHashtags: ['#كتابة', '#تسويق_بالمحتوى', '#ContentWriter'],
        iconEmoji: '✍️',
        trendingReason: 'الطلب على Copywriters زاد 234%',
        contentIdeas: [
          ContentIdeaModel(
            id: 'copy_1',
            title: 'صيغ Copywriting الذهبية',
            description: 'صيغ مجربة لكتابة محتوى يبيع',
            suggestedPlatforms: ['LinkedIn', 'Twitter', 'Instagram'],
            contentType: 'تعليمي',
            estimatedEngagement: 93,
            exampleText: '4 صيغ copywriting تزيد المبيعات:\n\nPAS: Problem-Agitate-Solution\nAIDA: Attention-Interest-Desire-Action',
          ),
          ContentIdeaModel(
            id: 'copy_2',
            title: 'Headlines تجذب الانتباه',
            description: 'كيف تكتب عناوين لا تقاوم',
            suggestedPlatforms: ['Instagram', 'TikTok', 'LinkedIn'],
            contentType: 'أمثلة عملية',
            estimatedEngagement: 89,
            exampleText: 'صيغ Headlines قوية:\n\n"كيف...بدون..."\n"السر في..."\n"X طرق لـ..."',
          ),
          ContentIdeaModel(
            id: 'copy_3',
            title: 'دخلي من الكتابة',
            description: 'كم تربح ككاتب محتوى محترف',
            suggestedPlatforms: ['YouTube', 'Instagram', 'TikTok'],
            contentType: 'income reveal',
            estimatedEngagement: 96,
            exampleText: 'دخلي الشهري من الكتابة:\n\nمقالات SEO: 4,000 ريال\nCopywriting: 6,000 ريال\nإجمالي: 10,000 ريال',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '12',
        title: 'الإنتاجية وإدارة الوقت',
        hashtag: '#إنتاجية',
        postsCount: 76543,
        category: 'توعية',
        description: 'أساليب وأدوات لزيادة الإنتاجية',
        trendingScore: 8.5,
        relatedHashtags: ['#Productivity', '#تنظيم_الوقت', '#TimeManagement'],
        iconEmoji: '⚡',
        trendingReason: 'الإنتاجية أولوية 2025',
        contentIdeas: [
          ContentIdeaModel(
            id: 'prod_1',
            title: 'روتيني الصباحي المنتج',
            description: 'روتين صباحي يضاعف إنتاجيتك',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'يومي',
            estimatedEngagement: 90,
            exampleText: 'روتيني الصباحي (5 صباحاً):\n\n⏰ 5:00 - تأمل 10 دقائق\n⏰ 5:15 - رياضة\n⏰ 6:00 - Deep Work',
          ),
          ContentIdeaModel(
            id: 'prod_2',
            title: 'أدوات الإنتاجية المفضلة',
            description: 'أفضل التطبيقات لإدارة المهام',
            suggestedPlatforms: ['Twitter', 'LinkedIn', 'Instagram'],
            contentType: 'قائمة أدوات',
            estimatedEngagement: 87,
            exampleText: 'Stack الإنتاجية:\n\n📝 Notion - كل شيء\n✅ Todoist - المهام\n⏱️ Toggl - تتبع الوقت',
          ),
          ContentIdeaModel(
            id: 'prod_3',
            title: 'Pomodoro Technique',
            description: 'كيف تعمل 4 ساعات وتنجز عمل 8 ساعات',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'تقنية',
            estimatedEngagement: 92,
            exampleText: 'تقنية Pomodoro:\n\n🍅 25 دقيقة تركيز\n☕ 5 دقائق راحة\n🔁 كرر 4 مرات\n🏖️ راحة 30 دقيقة',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '13',
        title: 'محتوى الطعام Food Content',
        hashtag: '#Food',
        postsCount: 234567,
        category: 'محتوى',
        description: 'إنشاء محتوى طعام جذاب ومربح',
        trendingScore: 9.0,
        relatedHashtags: ['#FoodPhotography', '#وصفات', '#طبخ', '#FoodBlogger'],
        iconEmoji: '🍔',
        trendingReason: 'محتوى الطعام الأعلى مشاهدة',
        contentIdeas: [
          ContentIdeaModel(
            id: 'food_1',
            title: 'تصوير الطعام بالهاتف',
            description: 'أسرار تصوير الطعام بشكل احترافي',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'tutorial',
            estimatedEngagement: 94,
            exampleText: 'سر تصوير الطعام:\n\n💡 الإضاءة الطبيعية\n📐 زاوية 45 درجة\n🎨 الألوان المتناسقة',
          ),
          ContentIdeaModel(
            id: 'food_2',
            title: 'وصفات سريعة تريند',
            description: 'وصفات سهلة تحصد ملايين المشاهدات',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'وصفات',
            estimatedEngagement: 97,
            exampleText: '5 وصفات فيرال:\n\n1. Pasta Chips\n2. Feta Pasta\n3. Cloud Bread\n4. Dalgona Coffee',
          ),
          ContentIdeaModel(
            id: 'food_3',
            title: 'كم أربح من Food Blogging',
            description: 'مصادر دخل مدونة الطعام',
            suggestedPlatforms: ['YouTube', 'Instagram', 'LinkedIn'],
            contentType: 'income reveal',
            estimatedEngagement: 91,
            exampleText: 'دخلي من Food Content:\n\nإعلانات: 3,000 ريال\nسپونسر: 5,000 ريال\nأفلييت: 2,000 ريال',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '14',
        title: 'السفر Travel Content',
        hashtag: '#Travel',
        postsCount: 187654,
        category: 'محتوى',
        description: 'محتوى السفر والرحلات',
        trendingScore: 8.8,
        relatedHashtags: ['#سفر', '#سياحة', '#TravelBlogger', '#Wanderlust'],
        iconEmoji: '✈️',
        trendingReason: 'السياحة عادت بقوة بعد الجائحة',
        contentIdeas: [
          ContentIdeaModel(
            id: 'travel_1',
            title: 'السفر بميزانية محدودة',
            description: 'كيف تسافر العالم بأقل تكلفة',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'نصائح',
            estimatedEngagement: 92,
            exampleText: 'أسرار السفر الرخيص:\n\n✈️ احجز قبل 3 أشهر\n🏨 Airbnb أرخص\n🍽️ كل محلي',
          ),
          ContentIdeaModel(
            id: 'travel_2',
            title: 'وجهات سعودية خفية',
            description: 'أجمل الأماكن السياحية في السعودية',
            suggestedPlatforms: ['Instagram', 'TikTok', 'Twitter'],
            contentType: 'دليل سياحي',
            estimatedEngagement: 95,
            exampleText: '10 أماكن سعودية خيالية:\n\n1. العلا\n2. الأحساء\n3. الباحة\n4. فرسان\n5. حائل',
          ),
          ContentIdeaModel(
            id: 'travel_3',
            title: 'كيف أسافر مجاناً',
            description: 'استراتيجيات السفر المدفوع',
            suggestedPlatforms: ['YouTube', 'Instagram', 'TikTok'],
            contentType: 'استراتيجية',
            estimatedEngagement: 98,
            exampleText: 'كيف أسافر مجاناً:\n\n✅ سپونسر من فنادق\n✅ تعاون مع هيئة السياحة\n✅ برامج الأفلييت',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '15',
        title: 'الدورات التعليمية Online Courses',
        hashtag: '#التعليم_الالكتروني',
        postsCount: 56432,
        category: 'أعمال',
        description: 'إنشاء وبيع الدورات التعليمية',
        trendingScore: 9.2,
        relatedHashtags: ['#دورات', '#تعليم', '#OnlineCourse', '#EdTech'],
        iconEmoji: '🎓',
        trendingReason: 'سوق التعليم الإلكتروني نما 300%',
        contentIdeas: [
          ContentIdeaModel(
            id: 'course_1',
            title: 'كيف صنعت دورتي الأولى',
            description: 'خطوات إنشاء دورة تعليمية من الصفر',
            suggestedPlatforms: ['YouTube', 'LinkedIn', 'Instagram'],
            contentType: 'دليل',
            estimatedEngagement: 89,
            exampleText: 'خطوات إنشاء الدورة:\n\n1. اختر موضوع\n2. صمم المنهج\n3. سجّل الفيديوهات\n4. أطلق وسوّق',
          ),
          ContentIdeaModel(
            id: 'course_2',
            title: 'أرباحي من بيع الدورات',
            description: 'كشف دخل شهري من الدورات',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'income reveal',
            estimatedEngagement: 96,
            exampleText: 'دخل شهر يناير:\n\nمبيعات: 120 دورة\nالسعر: 500 ريال\nالإجمالي: 60,000 ريال',
          ),
          ContentIdeaModel(
            id: 'course_3',
            title: 'أفضل منصات بيع الدورات',
            description: 'مقارنة بين منصات الدورات العربية',
            suggestedPlatforms: ['Twitter', 'LinkedIn', 'Instagram'],
            contentType: 'مقارنة',
            estimatedEngagement: 87,
            exampleText: 'مقارنة منصات الدورات:\n\nتيرا - عمولة 15%\nيوديمي - عمولة 50%\nمنصتك - عمولة 0%',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '16',
        title: 'اللياقة والصحة Fitness',
        hashtag: '#لياقة',
        postsCount: 145678,
        category: 'توعية',
        description: 'محتوى اللياقة البدنية والحياة الصحية',
        trendingScore: 8.9,
        relatedHashtags: ['#Fitness', '#صحة', '#رياضة', '#Workout'],
        iconEmoji: '💪',
        trendingReason: 'الوعي الصحي زاد 189%',
        contentIdeas: [
          ContentIdeaModel(
            id: 'fit_1',
            title: 'تحولي في 90 يوم',
            description: 'رحلة تحول جسدي مع الصور',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'قصة تحول',
            estimatedEngagement: 95,
            exampleText: 'تحولي 90 يوم:\n\nالوزن: من 95 إلى 75 كجم\nالدهون: من 28% إلى 15%\nالعضلات زادت 5 كجم',
          ),
          ContentIdeaModel(
            id: 'fit_2',
            title: 'تمارين منزلية بدون معدات',
            description: 'برنامج رياضي كامل في البيت',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'workout routine',
            estimatedEngagement: 93,
            exampleText: 'برنامج منزلي 30 دقيقة:\n\n- Push-ups: 3x15\n- Squats: 3x20\n- Plank: 3x60 sec',
          ),
          ContentIdeaModel(
            id: 'fit_3',
            title: 'نظامي الغذائي اليومي',
            description: 'ماذا آكل في اليوم كاملاً',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'what I eat',
            estimatedEngagement: 97,
            exampleText: 'نظامي الغذائي:\n\nفطور: شوفان + موز\nغداء: دجاج + أرز بني\nعشاء: سلطة + بروتين',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '17',
        title: 'الألعاب والإسبورت Gaming',
        hashtag: '#Gaming',
        postsCount: 298765,
        category: 'محتوى',
        description: 'صناعة محتوى الألعاب والبث المباشر',
        trendingScore: 9.4,
        relatedHashtags: ['#Esports', '#Twitch', '#Gaming', '#Streaming'],
        iconEmoji: '🎮',
        trendingReason: 'سوق الإسبورت في السعودية نما 400%',
        contentIdeas: [
          ContentIdeaModel(
            id: 'game_1',
            title: 'كيف تبدأ في Twitch',
            description: 'دليل البدء في البث المباشر',
            suggestedPlatforms: ['YouTube', 'TikTok', 'Twitter'],
            contentType: 'دليل',
            estimatedEngagement: 90,
            exampleText: 'خطوات البدء في Twitch:\n\n1. معدات بسيطة\n2. اختر لعبة\n3. جدول ثابت\n4. تفاعل مع المتابعين',
          ),
          ContentIdeaModel(
            id: 'game_2',
            title: 'دخل Streamer سعودي',
            description: 'كم تربح من البث المباشر',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'income reveal',
            estimatedEngagement: 98,
            exampleText: 'دخلي من Streaming:\n\nSubscriptions: 8,000 ريال\nDonations: 5,000 ريال\nSponsors: 10,000 ريال',
          ),
          ContentIdeaModel(
            id: 'game_3',
            title: 'Setup الستريمر الاحترافي',
            description: 'معدات البث الاحترافي',
            suggestedPlatforms: ['YouTube', 'Instagram', 'TikTok'],
            contentType: 'gear review',
            estimatedEngagement: 92,
            exampleText: 'Setup الستريمنج:\n\n🎤 Mic: Blue Yeti\n📷 Cam: Logitech C920\n💡 إضاءة: Ring Light',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '18',
        title: 'الموضة والأزياء Fashion',
        hashtag: '#موضة',
        postsCount: 187654,
        category: 'محتوى',
        description: 'محتوى الموضة والأزياء',
        trendingScore: 8.7,
        relatedHashtags: ['#Fashion', '#Style', '#OOTD', '#FashionBlogger'],
        iconEmoji: '👗',
        trendingReason: 'Fashion Content الأعلى تفاعلاً',
        contentIdeas: [
          ContentIdeaModel(
            id: 'fashion_1',
            title: 'Capsule Wardrobe',
            description: 'كيف تبني خزانة ملابس عملية',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'دليل',
            estimatedEngagement: 91,
            exampleText: 'Capsule Wardrobe أساسية:\n\n👕 5 تيشرتات أساسية\n👖 3 بناطيل\n👟 2 أحذية\n🧥 جاكيت واحد',
          ),
          ContentIdeaModel(
            id: 'fashion_2',
            title: 'تنسيقات SHEIN مقابل ZARA',
            description: 'مقارنة أسعار وجودة',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'مقارنة',
            estimatedEngagement: 94,
            exampleText: 'SHEIN vs ZARA:\n\nالسعر: SHEIN أرخص 70%\nالجودة: ZARA أفضل\nالتنوع: SHEIN',
          ),
          ContentIdeaModel(
            id: 'fashion_3',
            title: 'Haul من متاجر محلية',
            description: 'تسوق من متاجر سعودية',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'haul',
            estimatedEngagement: 89,
            exampleText: 'Haul من متاجر سعودية:\n\nالميزانية: 1000 ريال\nالقطع: 15 قطعة\nمن: Namshi, 6th Street',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '19',
        title: 'العملات الرقمية والNFTs',
        hashtag: '#Crypto',
        postsCount: 123987,
        category: 'تقنية',
        description: 'عالم الكريبتو والأصول الرقمية',
        trendingScore: 8.4,
        relatedHashtags: ['#Bitcoin', '#NFT', '#Web3', '#Blockchain'],
        iconEmoji: '₿',
        trendingReason: 'اهتمام عالمي متزايد',
        contentIdeas: [
          ContentIdeaModel(
            id: 'crypto_1',
            title: 'دليل المبتدئين للكريبتو',
            description: 'كيف تبدأ في العملات الرقمية بأمان',
            suggestedPlatforms: ['YouTube', 'Twitter', 'LinkedIn'],
            contentType: 'تعليمي',
            estimatedEngagement: 88,
            exampleText: 'البداية في Crypto:\n\n1. تعلم الأساسيات\n2. اختر منصة موثوقة\n3. ابدأ بمبالغ صغيرة\n4. لا تستثمر ما لا تستطيع خسارته',
          ),
          ContentIdeaModel(
            id: 'crypto_2',
            title: 'NFTs للفنانين',
            description: 'كيف تبيع أعمالك الفنية كـNFTs',
            suggestedPlatforms: ['Instagram', 'Twitter', 'YouTube'],
            contentType: 'دليل',
            estimatedEngagement: 86,
            exampleText: 'بيع NFTs خطوة بخطوة:\n\n🎨 أنشئ العمل\n💰 Mint على OpenSea\n📢 سوّق للمجتمع',
          ),
          ContentIdeaModel(
            id: 'crypto_3',
            title: 'أخطاء كلفتني 50,000 ريال',
            description: 'أخطاء شائعة في الكريبتو',
            suggestedPlatforms: ['TikTok', 'Instagram', 'YouTube'],
            contentType: 'تحذيرات',
            estimatedEngagement: 92,
            exampleText: 'أخطائي في Crypto:\n\n❌ FOMO Buying\n❌ عدم البحث\n❌ استثمار كل الأموال',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '20',
        title: 'العمل عن بُعد Remote Work',
        hashtag: '#العمل_عن_بعد',
        postsCount: 87654,
        category: 'أعمال',
        description: 'ثقافة العمل عن بُعد والوظائف الرقمية',
        trendingScore: 9.0,
        relatedHashtags: ['#RemoteWork', '#WorkFromHome', '#DigitalNomad'],
        iconEmoji: '🏠',
        trendingReason: '65% من الشركات تتبنى العمل المرن',
        contentIdeas: [
          ContentIdeaModel(
            id: 'remote_1',
            title: 'مكتبي المنزلي Setup',
            description: 'تجهيز مكتب منزلي مثالي',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'home office tour',
            estimatedEngagement: 90,
            exampleText: 'Setup مكتبي:\n\n💻 شاشتين\n🪑 كرسي إرجونومي\n💡 إضاءة طبيعية\n🌱 نباتات',
          ),
          ContentIdeaModel(
            id: 'remote_2',
            title: 'وظائف عن بُعد عالية الأجر',
            description: 'أفضل الوظائف للعمل عن بُعد',
            suggestedPlatforms: ['LinkedIn', 'Twitter', 'Instagram'],
            contentType: 'قائمة وظائف',
            estimatedEngagement: 95,
            exampleText: 'وظائف Remote مربحة:\n\n1. مطور Full-Stack\n2. مصمم UX/UI\n3. مدير مشاريع\n4. محلل بيانات',
          ),
          ContentIdeaModel(
            id: 'remote_3',
            title: 'يومي كـ Digital Nomad',
            description: 'حياة العمل أثناء السفر',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'day in life',
            estimatedEngagement: 93,
            exampleText: 'يومي من بالي:\n\n🌅 استيقظ بجانب الشاطئ\n💻 عمل 4 ساعات\n🏄 Surf بعد الظهر\n✈️ أسافر كل شهر',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '21',
        title: 'البودكاست Podcasting',
        hashtag: '#بودكاست',
        postsCount: 65432,
        category: 'محتوى',
        description: 'إنشاء وتنمية البودكاست',
        trendingScore: 8.6,
        relatedHashtags: ['#Podcast', '#Audio', '#Spotify', '#ContentCreator'],
        iconEmoji: '🎙️',
        trendingReason: 'البودكاست العربي نما 340%',
        contentIdeas: [
          ContentIdeaModel(
            id: 'pod_1',
            title: 'كيف بدأت بودكاستي',
            description: 'خطوات إطلاق بودكاست ناجح',
            suggestedPlatforms: ['YouTube', 'Twitter', 'LinkedIn'],
            contentType: 'دليل',
            estimatedEngagement: 87,
            exampleText: 'خطوات البودكاست:\n\n1. اختر موضوع\n2. معدات بسيطة\n3. سجل أول حلقة\n4. انشر على المنصات',
          ),
          ContentIdeaModel(
            id: 'pod_2',
            title: 'معدات البودكاست بـ 1000 ريال',
            description: 'Setup كامل بميزانية محدودة',
            suggestedPlatforms: ['Instagram', 'TikTok', 'YouTube'],
            contentType: 'gear guide',
            estimatedEngagement: 89,
            exampleText: 'معدات البودكاست:\n\n🎤 Samson Q2U: 400 ريال\n🎧 سماعات: 200 ريال\n🔊 معالج صوت مجاني',
          ),
          ContentIdeaModel(
            id: 'pod_3',
            title: 'Monetize البودكاست',
            description: 'طرق الربح من البودكاست',
            suggestedPlatforms: ['YouTube', 'LinkedIn', 'Twitter'],
            contentType: 'monetization',
            estimatedEngagement: 93,
            exampleText: 'مصادر دخل البودكاست:\n\nإعلانات: 2,000 ريال\nسپونسر: 5,000 ريال\nPatreon: 3,000 ريال',
          ),
        ],
      ),
      TrendingTopicModel(
        id: '22',
        title: 'التسويق بالإيميل Email Marketing',
        hashtag: '#EmailMarketing',
        postsCount: 54321,
        category: 'تسويق',
        description: 'بناء قائمة بريدية وزيادة المبيعات',
        trendingScore: 8.5,
        relatedHashtags: ['#Newsletter', '#تسويق_الكتروني', '#ConvertKit'],
        iconEmoji: '📧',
        trendingReason: 'Email Marketing أعلى ROI في التسويق',
        contentIdeas: [
          ContentIdeaModel(
            id: 'email_1',
            title: 'بنيت قائمة 10K مشترك',
            description: 'استراتيجية بناء القائمة البريدية',
            suggestedPlatforms: ['Twitter', 'LinkedIn', 'YouTube'],
            contentType: 'استراتيجية',
            estimatedEngagement: 88,
            exampleText: 'كيف بنيت 10K مشترك:\n\n✅ Lead Magnet قوي\n✅ Pop-up ذكي\n✅ محتوى قيّم\n✅ تسلسلات آلية',
          ),
          ContentIdeaModel(
            id: 'email_2',
            title: 'صيغ إيميلات تبيع',
            description: 'نماذج إيميلات تحقق مبيعات',
            suggestedPlatforms: ['LinkedIn', 'Twitter', 'Instagram'],
            contentType: 'templates',
            estimatedEngagement: 91,
            exampleText: 'صيغة الإيميل البيعي:\n\n1. Subject جذاب\n2. قصة شخصية\n3. قيمة مجانية\n4. CTA واحد',
          ),
          ContentIdeaModel(
            id: 'email_3',
            title: 'دخلي من Newsletter',
            description: 'كيف تربح من القائمة البريدية',
            suggestedPlatforms: ['YouTube', 'Instagram', 'TikTok'],
            contentType: 'income reveal',
            estimatedEngagement: 94,
            exampleText: 'أرباح Newsletter الشهرية:\n\nمنتجات رقمية: 8,000 ريال\nأفلييت: 3,000 ريال\nسپونسر: 5,000 ريال',
          ),
        ],
      ),
    ];
  }
}
