import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/profile_card.dart';
import '../widgets/action_buttons.dart';
import '../bloc/discover_bloc.dart';
import '../bloc/discover_event.dart';
import '../bloc/discover_state.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _currentIndex = 0;
  bool _isAnimatingOut = false;
  List<Map<String, dynamic>> _profiles = [];

  @override
  void initState() {
    super.initState();
    context.read<DiscoverBloc>().add(const FetchFeedEvent());
  }

  void _onSwipe(bool liked, {bool superLike = false}) async {
    if (_isAnimatingOut || _currentIndex >= _profiles.length) return;
    
    final currentProfile = _profiles[_currentIndex];
    
    // Dispatch swipe event
    context.read<DiscoverBloc>().add(SwipeProfileEvent(
      targetUserId: currentProfile['id'].toString(),
      isInterest: liked,
      isSuperInterest: superLike,
    ));

    setState(() => _isAnimatingOut = true);

    if (liked) {
      await AppHaptics.heavy();
    } else {
      await AppHaptics.light();
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() {
      _isAnimatingOut = false;
      _currentIndex++;
      
      // If nearing end, could fetch more
      if (_currentIndex >= _profiles.length - 2) {
        // context.read<DiscoverBloc>().add(FetchFeedEvent(page: ...));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        if (state is DiscoverLoading && _profiles.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          );
        }

        if (state is DiscoverError && _profiles.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(state.message, style: const TextStyle(color: Colors.white)),
            ),
          );
        }

        if (state is DiscoverLoaded) {
          _profiles = state.profiles;
        }

        final hasProfiles = _currentIndex < _profiles.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: hasProfiles
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_currentIndex + 1 < _profiles.length)
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(44, 20, 44, 80),
                                  child: ProfileCard(
                                    profile: _profiles[_currentIndex + 1],
                                    scale: 0.95,
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
                                child: ProfileCard(
                                  key: ValueKey(_profiles[_currentIndex]['id']),
                                  profile: _profiles[_currentIndex],
                                  onSwipeLeft: () => _onSwipe(false),
                                  onSwipeRight: () => _onSwipe(true),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildEmptyState(),
                ),
                if (hasProfiles)
                  DiscoverActionButtons(
                    onPass: () => _onSwipe(false),
                    onInterest: () => _onSwipe(true),
                    onSuperInterest: () => _onSwipe(true, superLike: true),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discover', style: AppTextStyles.headlineLarge),
              Text(
                'Telugu Christian Matches',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => AppHaptics.light(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceHighest),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.gold, size: 20),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✝', style: TextStyle(fontSize: 56, color: AppColors.goldMild)),
          const SizedBox(height: 16),
          Text("You've seen everyone for now",
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text('Check back tomorrow for new matches',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.read<DiscoverBloc>().add(const FetchFeedEvent()),
            child: const Text('Refresh Feed', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}

