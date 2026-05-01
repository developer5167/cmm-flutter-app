import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/phone_input_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/discover/screens/discover_screen.dart';
import '../../features/interests/screens/interests_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/my_profile_screen.dart';
import '../../features/profile/screens/public_profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/subscriptions/screens/subscription_screen.dart';
import '../../features/profile/screens/review_status_screen.dart';
import '../storage/app_storage.dart';
import '../../core/widgets/app_shell.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  static late GoRouter router;

  static Future<void> init() async {
    final token = await AppStorage.getAccessToken();
    final onboardingDone = AppStorage.isOnboardingComplete();

    router = GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/splash',
      redirect: (context, state) async {
        final isAuth = await AppStorage.getAccessToken() != null;
        final path = state.uri.path;

        if (path == '/splash') return null;

        if (!isAuth) {
          if (path.startsWith('/auth')) return null;
          return '/auth/phone';
        }

        if (!AppStorage.isOnboardingComplete()) {
          if (path == '/onboarding') return null;
          return '/onboarding';
        }

        // Check review status
        final reviewStatus = AppStorage.getReviewStatus();
        if (reviewStatus != 'approved') {
          if (path == '/review-status') return null;
          return '/review-status';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/review-status',
          builder: (_, __) => const ReviewStatusScreen(),
        ),
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),

        // ─── Auth Routes ──────────────────────────────────────
        GoRoute(
          path: '/auth/phone',
          builder: (_, __) => const PhoneInputScreen(),
          routes: [
            GoRoute(
              path: 'otp',
              builder: (_, state) {
                final phone = state.extra as String? ?? '';
                return OtpVerificationScreen(phone: phone);
              },
            ),
          ],
        ),

        // ─── Onboarding ───────────────────────────────────────
        GoRoute(
          path: '/onboarding',
          builder: (_, state) {
            final initialStep = state.extra as int?;
            return OnboardingScreen(initialStep: initialStep);
          },
        ),

        // ─── Main Shell (bottom nav) ──────────────────────────
        ShellRoute(
          navigatorKey: _shellKey,
          builder: (_, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/discover',
              builder: (_, __) => const DiscoverScreen(),
            ),
            GoRoute(
              path: '/interests',
              builder: (_, __) => const InterestsScreen(),
            ),
            GoRoute(
              path: '/chat',
              builder: (_, __) => const ConversationsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (_, __) => const MyProfileScreen(),
            ),
          ],
        ),

        // ─── Detail Routes (full screen) ──────────────────────
        GoRoute(
          path: '/chat/:convId',
          builder: (_, state) {
            final convId = state.pathParameters['convId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return ChatScreen(
              conversationId: convId,
              otherUserName: extra?['name'] ?? '',
              otherUserPhoto: extra?['photo'],
              otherUserId: extra?['userId']?.toString(),
            );
          },
        ),
        GoRoute(
          path: '/profile/preview',
          builder: (_, __) => const PublicProfileScreen(),
        ),
        GoRoute(
          path: '/profile/:id',
          builder: (_, state) {
            final source = state.uri.queryParameters['source'];
            final hideActions = source == 'interests' || source == 'chat';
            return PublicProfileScreen(
              userId: state.pathParameters['id']!,
              showBottomActions: !hideActions,
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/subscription',
          builder: (_, __) => const SubscriptionScreen(),
        ),
      ],
    );
  }
}
