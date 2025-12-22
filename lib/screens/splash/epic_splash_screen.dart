import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../controllers/dashboard_controller.dart';
import '../auth/modern_login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class EpicSplashScreen extends StatefulWidget {
  const EpicSplashScreen({super.key});

  @override
  State<EpicSplashScreen> createState() => _EpicSplashScreenState();
}

class _EpicSplashScreenState extends State<EpicSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particlesController;
  late AnimationController _glowController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Logo animations
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotate = Tween<double>(begin: -math.pi * 2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Particles animation
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Text animations
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });

    // Navigate after delay - with Auto-Login check
    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (mounted) {
        await _navigateToNextScreen();
      }
    });
  }

  /// Check authentication and navigate to appropriate screen
  Future<void> _navigateToNextScreen() async {
    try {
      final authService = Get.find<AuthService>();

      print('🔍 Checking authentication status...');

      // Check if user is authenticated
      if (authService.isAuthenticated.value &&
          authService.currentUser.value != null) {
        print(
          '✅ User is authenticated: ${authService.currentUser.value!.name}',
        );
        print('   - User ID: ${authService.currentUser.value!.id}');
        print('   - Phone: ${authService.currentUser.value!.phoneNumber}');
        print(
          '   - Is Logged In: ${authService.currentUser.value!.isLoggedIn}',
        );

        // Initialize DashboardController
        try {
          Get.find<DashboardController>();
        } catch (e) {
          Get.put(DashboardController());
        }

        // Navigate to Dashboard
        Get.off(
          () => DashboardScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800),
        );
      } else {
        print('⚠️ User not authenticated, going to login screen');

        // Navigate to Login Screen
        Get.off(
          () => const ModernLoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800),
        );
      }
    } catch (e) {
      print('❌ Error checking authentication: $e');

      // Fallback to Login Screen
      Get.off(
        () => const ModernLoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 800),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particlesController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Animated grid background
          ...List.generate(20, (index) {
            return AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                final progress =
                    (_particlesController.value + index * 0.05) % 1.0;
                final opacity = (math.sin(progress * math.pi) * 0.3).clamp(
                  0.0,
                  0.3,
                );

                return Positioned(
                  left: (index % 5) * MediaQuery.of(context).size.width / 5,
                  top:
                      (index ~/ 5) * MediaQuery.of(context).size.height / 4 +
                      (math.sin(progress * math.pi * 2) * 20),
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: opacity),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // Floating neon particles
          ...List.generate(30, (index) {
            return AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                final offset = (index * 0.1 + _particlesController.value) % 1.0;
                final x =
                    math.sin(offset * math.pi * 2 + index) *
                    MediaQuery.of(context).size.width *
                    0.4;
                final y = offset * MediaQuery.of(context).size.height;
                final size = 2.0 + (index % 3);
                final colorIndex = index % 3;
                final color = colorIndex == 0
                    ? AppColors.neonCyan
                    : colorIndex == 1
                    ? AppColors.neonPurple
                    : AppColors.neonMagenta;

                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 + x,
                  top: y,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with neon glow effect
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoController,
                    _glowController,
                  ]),
                  builder: (context, child) {
                    final glowIntensity = 0.7 + (_glowController.value * 0.3);

                    return Transform.rotate(
                      angle: _logoRotate.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoFade.value,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyan.withValues(alpha: glowIntensity * 0.3,),
                                  blurRadius: 60 * glowIntensity,
                                  spreadRadius: 20 * glowIntensity,
                                ),
                                BoxShadow(
                                  color: AppColors.neonPurple.withValues(alpha: glowIntensity * 0.3,),
                                  blurRadius: 80 * glowIntensity,
                                  spreadRadius: 30 * glowIntensity,
                                ),
                                BoxShadow(
                                  color: AppColors.neonMagenta.withValues(alpha: glowIntensity * 0.2,),
                                  blurRadius: 100 * glowIntensity,
                                  spreadRadius: 40 * glowIntensity,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),

                // Animated text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            // App name with neon gradient
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.neonGradient.createShader(bounds),
                              child: const Text(
                                'MEDIA PRO',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Subtitle
                            Text(
                              'إدارة احترافية لحسابات السوشال ميديا',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Loading indicator
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.neonCyan,
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
          ),
        ],
      ),
    );
  }
}
