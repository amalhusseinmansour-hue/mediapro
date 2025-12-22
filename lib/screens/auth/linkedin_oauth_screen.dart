import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

/// شاشة OAuth لربط حساب LinkedIn
class LinkedInOAuthScreen extends StatefulWidget {
  const LinkedInOAuthScreen({super.key});

  @override
  State<LinkedInOAuthScreen> createState() => _LinkedInOAuthScreenState();
}

class _LinkedInOAuthScreenState extends State<LinkedInOAuthScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  // LinkedIn OAuth URLs
  static const String _authUrl = 'https://www.linkedin.com/oauth/v2/authorization';
  static const String _tokenUrl = 'https://www.linkedin.com/oauth/v2/accessToken';
  static const String _profileUrl = 'https://api.linkedin.com/v2/userinfo';

  // Scopes needed
  static const List<String> _scopes = [
    'openid',
    'profile',
    'email',
    'w_member_social', // للنشر على LinkedIn
  ];

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final authorizationUrl = _buildAuthorizationUrl();
    print('🔗 LinkedIn Auth URL: $authorizationUrl');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E1E1E))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('📄 Page started: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            print('✅ Page finished: $url');
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            print('🔀 Navigation request: ${request.url}');
            return _handleNavigation(request.url);
          },
          onWebResourceError: (error) {
            print('❌ WebView error: ${error.description}');
            setState(() {
              _error = error.description;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(authorizationUrl));
  }

  String _buildAuthorizationUrl() {
    final params = {
      'response_type': 'code',
      'client_id': ApiConfig.linkedinClientId,
      'redirect_uri': ApiConfig.linkedinRedirectUri,
      'scope': _scopes.join(' '),
      'state': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$_authUrl?$queryString';
  }

  NavigationDecision _handleNavigation(String url) {
    final uri = Uri.parse(url);

    // Check if this is the redirect URL
    if (url.startsWith(ApiConfig.linkedinRedirectUri)) {
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];

      if (error != null) {
        print('❌ OAuth error: $error - $errorDescription');
        Navigator.pop(context, {
          'success': false,
          'error': errorDescription ?? error,
        });
        return NavigationDecision.prevent;
      }

      if (code != null) {
        print('✅ Got authorization code: ${code.substring(0, 10)}...');
        _exchangeCodeForToken(code);
        return NavigationDecision.prevent;
      }
    }

    // Check for cancel
    if (url.contains('error=user_cancelled') ||
        url.contains('error=access_denied') ||
        url.contains('oauth/v2/login-cancel')) {
      Navigator.pop(context, {'cancelled': true});
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _exchangeCodeForToken(String code) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔄 Exchanging code for token...');

      // Exchange authorization code for access token
      final tokenResponse = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': ApiConfig.linkedinRedirectUri,
          'client_id': ApiConfig.linkedinClientId,
          'client_secret': ApiConfig.linkedinClientSecret,
        },
      );

      print('📊 Token response status: ${tokenResponse.statusCode}');
      print('📊 Token response body: ${tokenResponse.body}');

      if (tokenResponse.statusCode != 200) {
        throw Exception('Failed to get access token: ${tokenResponse.body}');
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      if (accessToken == null) {
        throw Exception('No access token in response');
      }

      print('✅ Got access token: ${accessToken.toString().substring(0, 20)}...');

      // Get user profile
      final profileResponse = await http.get(
        Uri.parse(_profileUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📊 Profile response status: ${profileResponse.statusCode}');
      print('📊 Profile response body: ${profileResponse.body}');

      if (profileResponse.statusCode != 200) {
        throw Exception('Failed to get profile: ${profileResponse.body}');
      }

      final profileData = jsonDecode(profileResponse.body);

      // Return success with user data
      if (mounted) {
        Navigator.pop(context, {
          'success': true,
          'access_token': accessToken,
          'id': profileData['sub'],
          'name': profileData['name'],
          'email': profileData['email'],
          'picture': profileData['picture'],
          'vanity_name': profileData['vanity_name'],
        });
      }
    } catch (e) {
      print('❌ Token exchange error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A66C2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, {'cancelled': true}),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business_center,
                color: Color(0xFF0A66C2),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ربط LinkedIn',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'حدث خطأ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context, {'cancelled': true}),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _error = null;
                              _isLoading = true;
                            });
                            _controller.loadRequest(Uri.parse(_buildAuthorizationUrl()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A66C2),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF1E1E1E).withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'جاري الاتصال بـ LinkedIn...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
