import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../services/api_service.dart';

/// شاشة OAuth لربط حساب TikTok
class TikTokOAuthScreen extends StatefulWidget {
  const TikTokOAuthScreen({super.key});

  @override
  State<TikTokOAuthScreen> createState() => _TikTokOAuthScreenState();
}

class _TikTokOAuthScreenState extends State<TikTokOAuthScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  String? _authUrl;
  String? _state;

  // TikTok callback URL
  static const String _callbackUrl = 'https://mediaprosocial.io/api/tiktok/callback';

  @override
  void initState() {
    super.initState();
    _getAuthUrl();
  }

  Future<void> _getAuthUrl() async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getTikTokAuthUrl();

      if (response['success'] == true) {
        setState(() {
          _authUrl = response['auth_url'];
          _state = response['state'];
        });
        _initWebView();
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to get auth URL';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initWebView() {
    if (_authUrl == null) return;

    print('TikTok Auth URL: $_authUrl');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E1E1E))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('Page started: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            print('Page finished: $url');
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            print('Navigation request: ${request.url}');
            return _handleNavigation(request.url);
          },
          onWebResourceError: (error) {
            print('WebView error: ${error.description}');
            setState(() {
              _error = error.description;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_authUrl!));
  }

  NavigationDecision _handleNavigation(String url) {
    final uri = Uri.parse(url);

    // Check if this is the callback URL
    if (url.startsWith(_callbackUrl)) {
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];
      final state = uri.queryParameters['state'];

      if (error != null) {
        print('OAuth error: $error - $errorDescription');
        Navigator.pop(context, {
          'success': false,
          'error': errorDescription ?? error,
        });
        return NavigationDecision.prevent;
      }

      if (code != null) {
        print('Got authorization code');
        _handleCallback(code, state ?? _state ?? '');
        return NavigationDecision.prevent;
      }
    }

    // Check for cancel
    if (url.contains('error=access_denied') || url.contains('denied=')) {
      Navigator.pop(context, {'cancelled': true});
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _handleCallback(String code, String state) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Exchanging code for token...');

      // Call our backend to handle the OAuth callback
      final response = await http.get(
        Uri.parse('$_callbackUrl?code=$code&state=$state'),
        headers: {'Accept': 'application/json'},
      );

      print('Callback response status: ${response.statusCode}');
      print('Callback response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Return success with user data
          if (mounted) {
            Navigator.pop(context, {
              'success': true,
              'data': data['data'],
            });
          }
        } else {
          throw Exception(data['error'] ?? 'Failed to connect TikTok');
        }
      } else {
        throw Exception('Failed to connect: ${response.body}');
      }
    } catch (e) {
      print('Callback error: $e');
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
        backgroundColor: const Color(0xFF000000),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F2EA), Color(0xFFFF0050)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ربط TikTok',
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
                            _getAuthUrl();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0050),
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
          else if (_authUrl != null)
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF1E1E1E).withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00F2EA), Color(0xFFFF0050)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'جاري الاتصال بـ TikTok...',
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
