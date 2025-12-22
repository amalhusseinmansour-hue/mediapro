import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/apify_service.dart';

class ApifyTestScreen extends StatefulWidget {
  const ApifyTestScreen({Key? key}) : super(key: key);

  @override
  State<ApifyTestScreen> createState() => _ApifyTestScreenState();
}

class _ApifyTestScreenState extends State<ApifyTestScreen> {
  final ApifyService _apify = Get.find<ApifyService>();
  final TextEditingController _controller = TextEditingController(text: 'nike');

  InstagramProfileFull? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _test() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final username = _controller.text.trim();
      print('🌐 Starting scrape for: $username');

      final profile = await _apify.scrapeInstagramProfile(
        username,
        maxPosts: 20,
        saveLocally: true,
      );

      setState(() {
        _result = profile;
        _isLoading = false;
      });

      if (profile != null) {
        Get.snackbar(
          'نجح! 🎉',
          'تم جلب بيانات @$username بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        setState(() {
          _error = 'لم يتم العثور على بيانات';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      Get.snackbar(
        'خطأ ❌',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apify Test'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شعار Apify
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.rocket_launch, size: 60, color: Colors.orange),
                  const SizedBox(height: 8),
                  const Text(
                    'Apify Instagram Scraper',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'جرب جلب أي حساب Instagram!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // حقل الإدخال
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Instagram Username',
                hintText: 'nike',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'أدخل username بدون @',
              ),
            ),

            const SizedBox(height: 16),

            // زر الاختبار
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _test,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isLoading ? 'جاري الجلب...' : 'جلب البيانات',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Progress indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('جاري جلب البيانات من Instagram...'),
                    SizedBox(height: 4),
                    Text(
                      'قد يستغرق 10-30 ثانية ⏱️',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // Error message
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              ),

            // النتيجة
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 30),
                              SizedBox(width: 12),
                              Text(
                                'نجح! 🎉',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 24),

                          // الصورة الشخصية
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _result!.profilePicUrl != null
                                  ? NetworkImage(_result!.profilePicUrl!)
                                  : null,
                              child: _result!.profilePicUrl == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // الاسم
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _result!.fullName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '@${_result!.username}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_result!.isVerified)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, color: Colors.blue, size: 16),
                                        SizedBox(width: 4),
                                        Text('Verified', style: TextStyle(color: Colors.blue)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // الإحصائيات
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple[50]!, Colors.pink[50]!],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat('Posts', _result!.postsCount),
                                _buildDivider(),
                                _buildStat('Followers', _result!.followers),
                                _buildDivider(),
                                _buildStat('Following', _result!.following),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Bio
                          if (_result!.bio.isNotEmpty) ...[
                            const Text(
                              'Bio:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_result!.bio),
                            const SizedBox(height: 16),
                          ],

                          // معدل التفاعل
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.trending_up, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Engagement Rate',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[900],
                                        ),
                                      ),
                                      Text(
                                        '${_result!.engagementRate.toStringAsFixed(2)}%',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // المنشورات الأخيرة
                          if (_result!.latestPosts.isNotEmpty) ...[
                            Text(
                              'Latest Posts (${_result!.latestPosts.length}):',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _result!.latestPosts.length,
                                itemBuilder: (context, index) {
                                  final post = _result!.latestPosts[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: post.imageUrl != null
                                                ? DecorationImage(
                                                    image: NetworkImage(post.imageUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                            color: Colors.grey[300],
                                          ),
                                          child: post.imageUrl == null
                                              ? const Icon(Icons.image, size: 40)
                                              : null,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.favorite, size: 12, color: Colors.red),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${post.likesCount}',
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // معلومات إضافية
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'تم حفظ البيانات محلياً! ✅',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'يمكنك الوصول للبيانات لاحقاً بدون scraping جديد',
                                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    String displayValue;
    if (value >= 1000000) {
      displayValue = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      displayValue = '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      displayValue = value.toString();
    }

    return Column(
      children: [
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[300],
    );
  }
}
