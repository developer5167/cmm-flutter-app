import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int total;
  final int current;

  const OnboardingStepIndicator({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isCompleted = i < current;
        final isCurrent = i == current;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: isCompleted || isCurrent
                    ? AppColors.goldenGradient
                    : null,
                color: isCompleted || isCurrent
                    ? null
                    : AppColors.surfaceHighest,
              ),
            ),
          ),
        );
      }),
    );
  }
}
