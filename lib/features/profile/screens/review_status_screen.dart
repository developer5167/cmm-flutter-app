import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/widgets/app_button.dart';

class ReviewStatusScreen extends StatelessWidget {
  const ReviewStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = AppStorage.getReviewStatus();
    final isRejected = status == 'rejected';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isRejected ? AppColors.error.withOpacity(0.1) : AppColors.gold.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isRejected ? AppColors.error : AppColors.gold,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isRejected ? Icons.error_outline_rounded : Icons.access_time_rounded,
                  size: 60,
                  color: isRejected ? AppColors.error : AppColors.gold,
                ),
              ).animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 2.seconds),
              
              const SizedBox(height: 48),
              
              Text(
                isRejected ? 'Application Update' : 'Profile Under Review',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 16),
              
              Text(
                isRejected 
                  ? 'We noticed some issues with your profile details. Please contact our support team to update your application.'
                  : 'Welcome to GraceMatch! Our team is currently reviewing your profile to ensure a safe community. You\'ll receive a notification once approved.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 64),
              
              if (isRejected)
                AppButton(
                  label: 'Contact Support',
                  onPressed: () {
                    // TODO: Open email/WhatsApp support
                  },
                ).animate().fadeIn(delay: 600.ms)
              else
                AppButton(
                  label: 'Refresh Status',
                  onPressed: () {
                    // This will trigger a re-check of the status
                    context.go('/splash');
                  },
                ).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () {
                  AppStorage.clearAll();
                  context.go('/auth/phone');
                },
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.textTertiary),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
