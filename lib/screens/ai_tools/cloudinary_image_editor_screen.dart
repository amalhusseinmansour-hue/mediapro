import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/cloudinary_service.dart';

class CloudinaryImageEditorScreen extends StatefulWidget {
  const CloudinaryImageEditorScreen({Key? key}) : super(key: key);

  @override
  State<CloudinaryImageEditorScreen> createState() => _CloudinaryImageEditorScreenState();
}

class _CloudinaryImageEditorScreenState extends State<CloudinaryImageEditorScreen>
    with SingleTickerProviderStateMixin {
  late CloudinaryService _cloudinaryService;
  late TabController _tabController;

  File? _selectedImage;
  String? _originalUrl;
  String? _editedUrl;
  String? _selectedFilter;
  String? _selectedEffect;
  String? _selectedPreset;

  final List<String> _editHistory = [];

  @override
  void initState() {
    super.initState();
    _initService();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _initService() {
    try {
      _cloudinaryService = Get.find<CloudinaryService>();
    } catch (e) {
      _cloudinaryService = Get.put(CloudinaryService());
    }
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            flex: 5,
            child: _buildImagePreview(),
          ),

          // Tools Tabs
          _buildToolsTabs(),

          // Tools Content
          Expanded(
            flex: 3,
            child: _buildToolsContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'محرر الصور',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_editedUrl != null)
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white70),
            onPressed: _undoLastEdit,
            tooltip: 'تراجع',
          ),
        if (_editedUrl != null)
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF10B981)),
            onPressed: _downloadImage,
            tooltip: 'تحميل',
          ),
        if (_editedUrl != null)
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF6366F1)),
            onPressed: _shareImage,
            tooltip: 'مشاركة',
          ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_selectedImage == null && _editedUrl == null)
              _buildImagePlaceholder()
            else if (_editedUrl != null)
              _buildNetworkImage(_editedUrl!)
            else if (_selectedImage != null)
              Image.file(_selectedImage!, fit: BoxFit.contain),

            // Processing Overlay
            Obx(() {
              if (_cloudinaryService.isProcessing.value) {
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => Text(
                          _cloudinaryService.status.value,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        )),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                          '${(_cloudinaryService.progress.value * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        )),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: _showImageSourceDialog,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'اختر صورة للتعديل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط هنا لاختيار صورة من المعرض أو الكاميرا',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 8),
              Text('فشل تحميل الصورة', style: TextStyle(color: Colors.red)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolsTabs() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.filter), text: 'فلاتر'),
          Tab(icon: Icon(Icons.auto_fix_high), text: 'تأثيرات'),
          Tab(icon: Icon(Icons.crop), text: 'قص'),
          Tab(icon: Icon(Icons.tune), text: 'تحسين'),
          Tab(icon: Icon(Icons.more_horiz), text: 'المزيد'),
        ],
      ),
    );
  }

  Widget _buildToolsContent() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildFiltersTab(),
          _buildEffectsTab(),
          _buildCropTab(),
          _buildEnhanceTab(),
          _buildMoreTab(),
        ],
      ),
    );
  }

  Widget _buildFiltersTab() {
    final filters = _cloudinaryService.getAvailableFilters();

    return ListView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter['id'];
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () => _applyFilter(filter['id']!),
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    filter['icon']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filter['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEffectsTab() {
    final effects = _cloudinaryService.getAvailableArtEffects();

    return ListView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      children: effects.map((effect) {
        final isSelected = _selectedEffect == effect['id'];
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () => _applyArtEffect(effect['id']!),
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    effect['icon']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    effect['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCropTab() {
    final presets = _cloudinaryService.getSocialMediaPresets();

    return ListView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      children: presets.entries.map((entry) {
        final isSelected = _selectedPreset == entry.key;
        final name = _getPresetDisplayName(entry.key);
        final icon = _getPresetIcon(entry.key);

        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () => _resizeForPlatform(entry.key, entry.value),
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF10B981) : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.value['width']}x${entry.value['height']}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhanceTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEnhanceButton(
            icon: Icons.auto_awesome,
            label: 'تحسين تلقائي',
            color: const Color(0xFF6366F1),
            onTap: _enhanceImage,
          ),
          _buildEnhanceButton(
            icon: Icons.wb_sunny,
            label: 'سطوع',
            color: const Color(0xFFF59E0B),
            onTap: () => _applyFilter('bright'),
          ),
          _buildEnhanceButton(
            icon: Icons.contrast,
            label: 'تباين',
            color: const Color(0xFF8B5CF6),
            onTap: () => _applyFilter('sharp'),
          ),
          _buildEnhanceButton(
            icon: Icons.blur_on,
            label: 'ضبابية',
            color: const Color(0xFF06B6D4),
            onTap: _blurImage,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhanceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _selectedImage != null ? onTap : null,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMoreButton(
            icon: Icons.remove_circle_outline,
            label: 'إزالة الخلفية',
            color: const Color(0xFFEF4444),
            onTap: _removeBackground,
          ),
          _buildMoreButton(
            icon: Icons.rounded_corner,
            label: 'زوايا دائرية',
            color: const Color(0xFF10B981),
            onTap: _roundCorners,
          ),
          _buildMoreButton(
            icon: Icons.photo_size_select_large,
            label: 'صورة مصغرة',
            color: const Color(0xFF6366F1),
            onTap: _createThumbnail,
          ),
          _buildMoreButton(
            icon: Icons.refresh,
            label: 'إعادة تعيين',
            color: const Color(0xFF94A3B8),
            onTap: _resetImage,
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _selectedImage != null ? onTap : null,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _getPresetDisplayName(String preset) {
    switch (preset) {
      case 'instagram_post': return 'Instagram\nبوست';
      case 'instagram_story': return 'Instagram\nستوري';
      case 'instagram_landscape': return 'Instagram\nأفقي';
      case 'facebook_post': return 'Facebook\nبوست';
      case 'facebook_cover': return 'Facebook\nغلاف';
      case 'twitter_post': return 'Twitter\nبوست';
      case 'twitter_header': return 'Twitter\nهيدر';
      case 'linkedin_post': return 'LinkedIn\nبوست';
      case 'youtube_thumbnail': return 'YouTube\nصورة مصغرة';
      case 'tiktok_video': return 'TikTok\nفيديو';
      default: return preset;
    }
  }

  IconData _getPresetIcon(String preset) {
    if (preset.contains('instagram')) return Icons.camera_alt;
    if (preset.contains('facebook')) return Icons.facebook;
    if (preset.contains('twitter')) return Icons.flutter_dash;
    if (preset.contains('linkedin')) return Icons.work;
    if (preset.contains('youtube')) return Icons.play_circle;
    if (preset.contains('tiktok')) return Icons.music_note;
    return Icons.image;
  }

  // Action Methods
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'اختر مصدر الصورة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(
                  icon: Icons.photo_library,
                  label: 'المعرض',
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
                _buildSourceButton(
                  icon: Icons.camera_alt,
                  label: 'الكاميرا',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _editedUrl = null;
        _originalUrl = null;
        _selectedFilter = null;
        _selectedEffect = null;
        _selectedPreset = null;
        _editHistory.clear();
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _editedUrl = null;
        _originalUrl = null;
        _selectedFilter = null;
        _selectedEffect = null;
        _selectedPreset = null;
        _editHistory.clear();
      });
    }
  }

  Future<void> _applyFilter(String filterId) async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.applyFilter(_selectedImage!, filterId);

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['edited_url'];
        _originalUrl ??= result['original_url'];
        _selectedFilter = filterId;
      });
      _showSuccessMessage('تم تطبيق الفلتر');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل تطبيق الفلتر');
    }
  }

  Future<void> _applyArtEffect(String effectId) async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.applyArtEffect(_selectedImage!, effectId);

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['edited_url'];
        _originalUrl ??= result['original_url'];
        _selectedEffect = effectId;
      });
      _showSuccessMessage('تم تطبيق التأثير');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل تطبيق التأثير');
    }
  }

  Future<void> _resizeForPlatform(String preset, Map<String, int> size) async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.resizeImage(
      _selectedImage!,
      width: size['width']!,
      height: size['height']!,
    );

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['edited_url'];
        _originalUrl ??= result['original_url'];
        _selectedPreset = preset;
      });
      _showSuccessMessage('تم تغيير الحجم');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل تغيير الحجم');
    }
  }

  Future<void> _enhanceImage() async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.enhanceImage(_selectedImage!);

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['edited_url'];
        _originalUrl ??= result['original_url'];
      });
      _showSuccessMessage('تم تحسين الصورة');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل تحسين الصورة');
    }
  }

  Future<void> _blurImage() async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.blurImage(_selectedImage!, strength: 300);

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['edited_url'];
        _originalUrl ??= result['original_url'];
      });
      _showSuccessMessage('تم تطبيق الضبابية');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل تطبيق الضبابية');
    }
  }

  Future<void> _removeBackground() async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.removeBackground(_selectedImage!);

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['edited_url'];
        _originalUrl ??= result['original_url'];
      });
      _showSuccessMessage('تم إزالة الخلفية');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل إزالة الخلفية');
    }
  }

  Future<void> _roundCorners() async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.roundCorners(_selectedImage!, radius: 50);

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['edited_url'];
        _originalUrl ??= result['original_url'];
      });
      _showSuccessMessage('تم تدوير الزوايا');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل تدوير الزوايا');
    }
  }

  Future<void> _createThumbnail() async {
    if (_selectedImage == null) {
      _showSelectImageMessage();
      return;
    }

    final result = await _cloudinaryService.createThumbnail(_selectedImage!, size: 200);

    if (result['success'] == true) {
      setState(() {
        if (_editedUrl != null) _editHistory.add(_editedUrl!);
        _editedUrl = result['thumbnail_url'];
        _originalUrl ??= result['original_url'];
      });
      _showSuccessMessage('تم إنشاء الصورة المصغرة');
    } else {
      _showErrorMessage(result['message'] ?? 'فشل إنشاء الصورة المصغرة');
    }
  }

  void _undoLastEdit() {
    if (_editHistory.isNotEmpty) {
      setState(() {
        _editedUrl = _editHistory.removeLast();
      });
    } else if (_originalUrl != null) {
      setState(() {
        _editedUrl = _originalUrl;
      });
    }
  }

  void _resetImage() {
    setState(() {
      _editedUrl = null;
      _originalUrl = null;
      _selectedFilter = null;
      _selectedEffect = null;
      _selectedPreset = null;
      _editHistory.clear();
    });
  }

  Future<void> _downloadImage() async {
    if (_editedUrl == null) return;

    final file = await _cloudinaryService.downloadImage(_editedUrl!);
    if (file != null) {
      _showSuccessMessage('تم حفظ الصورة');
    } else {
      _showErrorMessage('فشل حفظ الصورة');
    }
  }

  void _shareImage() {
    if (_editedUrl == null) return;
    // Implement share functionality
    _showSuccessMessage('سيتم إضافة المشاركة قريباً');
  }

  void _showSelectImageMessage() {
    Get.snackbar(
      'تنبيه',
      'الرجاء اختيار صورة أولاً',
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'نجح',
      message,
      backgroundColor: const Color(0xFF10B981).withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
}
