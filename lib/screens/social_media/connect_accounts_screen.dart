import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/postiz_manager.dart';

/// شاشة ربط حسابات Social Media
class ConnectAccountsScreen extends StatefulWidget {
  const ConnectAccountsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectAccountsScreen> createState() => _ConnectAccountsScreenState();
}

class _ConnectAccountsScreenState extends State<ConnectAccountsScreen> {
  final PostizManager _postizManager = PostizManager();
  List<SocialAccount> _connectedAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConnectedAccounts();
  }

  Future<void> _loadConnectedAccounts() async {
    setState(() => _isLoading = true);

    try {
      final accounts = await _postizManager.getConnectedAccounts();
      setState(() {
        _connectedAccounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('فشل في تحميل الحسابات: $e');
    }
  }

  Future<void> _connectAccount(SocialPlatform platform) async {
    try {
      final result = await _postizManager.connectSocialAccount(
        platform: platform.name,
        userId: 'USER_ID', // استبدل بـ ID المستخدم الفعلي
      );

      if (result['success'] == true) {
        final url = result['oauth_url'];
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      _showError('فشل في فتح رابط الربط: $e');
    }
  }

  Future<void> _disconnectAccount(SocialAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الفصل'),
        content: Text('هل تريد فصل حساب ${account.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('فصل', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _postizManager.disconnectAccount(account.integrationId);
        if (success) {
          _showSuccess('تم فصل الحساب بنجاح');
          _loadConnectedAccounts();
        } else {
          _showError('فشل في فصل الحساب');
        }
      } catch (e) {
        _showError('حدث خطأ: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ربط الحسابات'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadConnectedAccounts,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // الحسابات المربوطة
                  if (_connectedAccounts.isNotEmpty) ...[
                    const Text(
                      'الحسابات المربوطة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._connectedAccounts.map((account) => _buildConnectedAccountCard(account)),
                    const SizedBox(height: 24),
                  ],

                  // المنصات المتاحة للربط
                  const Text(
                    'ربط حساب جديد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPlatformGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectedAccountCard(SocialAccount account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: account.profilePicture != null
              ? NetworkImage(account.profilePicture!)
              : null,
          child: account.profilePicture == null
              ? Icon(_getPlatformIcon(account.platform))
              : null,
          backgroundColor: _getPlatformColor(account.platform),
        ),
        title: Text(account.name),
        subtitle: Text('@${account.username}'),
        trailing: IconButton(
          icon: const Icon(Icons.link_off, color: Colors.red),
          onPressed: () => _disconnectAccount(account),
        ),
      ),
    );
  }

  Widget _buildPlatformGrid() {
    final platforms = [
      {'platform': SocialPlatform.facebook, 'name': 'Facebook', 'icon': Icons.facebook},
      {'platform': SocialPlatform.instagram, 'name': 'Instagram', 'icon': Icons.camera_alt},
      {'platform': SocialPlatform.twitter, 'name': 'Twitter/X', 'icon': Icons.message},
      {'platform': SocialPlatform.linkedin, 'name': 'LinkedIn', 'icon': Icons.work},
      {'platform': SocialPlatform.tiktok, 'name': 'TikTok', 'icon': Icons.music_note},
      {'platform': SocialPlatform.youtube, 'name': 'YouTube', 'icon': Icons.play_circle},
      {'platform': SocialPlatform.reddit, 'name': 'Reddit', 'icon': Icons.reddit},
      {'platform': SocialPlatform.pinterest, 'name': 'Pinterest', 'icon': Icons.push_pin},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: platforms.length,
      itemBuilder: (context, index) {
        final platform = platforms[index];
        final isConnected = _connectedAccounts.any(
          (acc) => acc.platform == platform['platform'] as SocialPlatform,
        );

        return _buildPlatformCard(
          platform['platform'] as SocialPlatform,
          platform['name'] as String,
          platform['icon'] as IconData,
          isConnected,
        );
      },
    );
  }

  Widget _buildPlatformCard(
    SocialPlatform platform,
    String name,
    IconData icon,
    bool isConnected,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isConnected ? null : () => _connectAccount(platform),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isConnected ? Colors.green.withValues(alpha: 0.1) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isConnected
                    ? Colors.green
                    : _getPlatformColor(platform),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (isConnected)
                const Text(
                  'مربوط',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlatformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.twitter:
        return Icons.message;
      case SocialPlatform.linkedin:
        return Icons.work;
      case SocialPlatform.tiktok:
        return Icons.music_note;
      case SocialPlatform.youtube:
        return Icons.play_circle;
      case SocialPlatform.reddit:
        return Icons.reddit;
      case SocialPlatform.pinterest:
        return Icons.push_pin;
      default:
        return Icons.account_circle;
    }
  }

  Color _getPlatformColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.instagram:
        return const Color(0xFFE4405F);
      case SocialPlatform.twitter:
        return const Color(0xFF1DA1F2);
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.tiktok:
        return const Color(0xFF000000);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.reddit:
        return const Color(0xFFFF4500);
      case SocialPlatform.pinterest:
        return const Color(0xFFBD081C);
      default:
        return Colors.grey;
    }
  }
}
