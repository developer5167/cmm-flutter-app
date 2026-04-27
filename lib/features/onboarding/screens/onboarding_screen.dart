import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/app_haptics.dart';
import '../widgets/step_indicator.dart';
import '../steps/step1_basic.dart';
import '../steps/step2_faith.dart';
import '../steps/step3_personal.dart';
import '../steps/step4_lifestyle.dart';
import '../steps/step5_family.dart';
import '../steps/step6_preferences.dart';
import '../steps/step7_hobbies.dart';
import '../steps/step8_photos.dart';
import '../steps/step9_verification.dart';
import '../steps/step10_final.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 10;

  // Keys to access step data
  final List<GlobalKey<OnboardingStepState>> _stepKeys = 
      List.generate(10, (index) => GlobalKey<OnboardingStepState>());

  final _stepTitles = [
    'About You',
    'Your Faith',
    'Career & Life',
    'Lifestyle',
    'Family',
    'Partner Preferences',
    'Hobbies',
    'Photos',
    'Verification',
    'Almost There!',
  ];

  final _stepSubtitles = [
    'Let\'s start with the basics',
    'Your faith is your foundation',
    'Tell us about your career',
    'How do you like to live?',
    'Tell us about your family',
    'What are you looking for?',
    'What do you enjoy?',
    'Show your best smile',
    'Build trust with others',
    'Who manages this profile?',
  ];

  void _nextStep() {
    final currentKey = _stepKeys[_currentStep];
    final stepData = currentKey.currentState?.getStepData();

    if (stepData == null) {
      // Step validation failed or data not ready
      AppHaptics.error();
      return;
    }

    // Save step data to backend
    context.read<OnboardingBloc>().add(SaveStepEvent(_currentStep + 1, stepData));
  }

  void _onStepSaved() {
    if (_currentStep < _totalSteps - 1) {
      AppHaptics.light();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      _finalize();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      AppHaptics.light();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    }
  }

  void _finalize() async {
    await AppHaptics.match();
    context.go('/discover');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is StepSavedSuccess) {
          _onStepSaved();
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is OnboardingLoading;
        
        final List<Widget> steps = [
          Step1Basic(key: _stepKeys[0]),
          Step2Faith(key: _stepKeys[1]),
          Step3Personal(key: _stepKeys[2]),
          Step4Lifestyle(key: _stepKeys[3]),
          Step5Family(key: _stepKeys[4]),
          Step6Preferences(key: _stepKeys[5]),
          Step7Hobbies(key: _stepKeys[6]),
          Step8Photos(key: _stepKeys[7]),
          Step9Verification(key: _stepKeys[8]),
          Step10Final(key: _stepKeys[9]),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(isLoading),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  child: OnboardingStepIndicator(
                    total: _totalSteps,
                    current: _currentStep,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _stepTitles[_currentStep],
                          key: ValueKey('title_$_currentStep'),
                          style: AppTextStyles.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _stepSubtitles[_currentStep],
                          key: ValueKey('sub_$_currentStep'),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: steps,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: AppButton(
                    label: _currentStep == _totalSteps - 1 ? 'Complete Profile ✓' : 'Continue',
                    isLoading: isLoading,
                    onPressed: _nextStep,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              onPressed: isLoading ? null : _prevStep,
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textPrimary),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldSubtle,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.goldMild),
            ),
            child: Text(
              '${_currentStep + 1} / $_totalSteps',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: isLoading
                ? null
                : () {
                    AppHaptics.light();
                    _onStepSaved();
                  },
            child: Text('Skip', style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    );
  }
}

abstract class OnboardingStepState<T extends StatefulWidget> extends State<T> {
  Map<String, dynamic>? getStepData();
}
