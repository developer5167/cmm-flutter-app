import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/storage/app_storage.dart';
import '../profile/data/profile_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  final _profileRepo = ProfileRepository();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _navigate();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final startTime = DateTime.now();
    
    final token = await AppStorage.getAccessToken();
    
    if (token != null) {
      try {
        // Refresh profile status on every launch
        final profile = await _profileRepo.fetchMyProfile();
        if (profile.containsKey('user')) {
          final user = profile['user'];
          if (user != null && user is Map) {
            AppStorage.saveOnboardingComplete(user['is_onboarding_complete'] ?? false);
            AppStorage.saveReviewStatus(user['review_status']?.toString());
          }
        }
      } catch (e) {
        debugPrint('Splash Error: $e');
      }
    }

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = 2800 - elapsed;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
    
    if (!mounted) return;

    if (token == null) {
      context.go('/auth/phone');
      return;
    }

    if (!AppStorage.isOnboardingComplete()) {
      context.go('/onboarding');
      return;
    }

    // Router redirect will handle the review-status check
    context.go('/discover');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // ── Background radial glow ─────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.7,
                      colors: [
                        AppColors.gold
                            .withAlpha((_glowAnimation.value * 30).toInt()),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Cross decorative element (top-left) ────────────
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withAlpha(30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Main content ───────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo mark
                  _buildLogoMark()
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Brand name
                  Text(
                    'GraceMatch',
                    style: AppTextStyles.displayMedium.copyWith(
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            AppColors.gold,
                            AppColors.goldLight,
                            AppColors.gold,
                          ],
                        ).createShader(
                            const Rect.fromLTWH(0, 0, 250, 50)),
                    ),
                  )
                      .animate(delay: 400.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Where faith meets forever',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  )
                      .animate(delay: 700.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),

            // ── Bottom loading indicator ───────────────────────
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.surfaceHighest,
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),
                ),
              ),
            )
                .animate(delay: 1000.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoMark() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) => Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.surface, AppColors.surfaceElevated],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.goldMild, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold
                  .withAlpha((_glowAnimation.value * 80).toInt()),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cross symbol
              Text(
                '✝',
                style: TextStyle(
                  fontSize: 28,
                  color: AppColors.gold.withAlpha(
                      (_glowAnimation.value * 255).toInt()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
