import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../screens/onboarding_screen.dart';

class Step9Verification extends StatefulWidget {
  const Step9Verification({super.key});

  @override
  State<Step9Verification> createState() => _Step9VerificationState();
}

class _Step9VerificationState extends OnboardingStepState<Step9Verification> {
  String? _videoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  Map<String, dynamic>? getStepData() {
    if (_videoPath == null) {
      return null;
    }
    return {
      'verification_video_path': _videoPath,
    };
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 5),
    );

    if (video != null) {
      setState(() => _videoPath = video.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldMild),
            ),
            child: const Icon(Icons.videocam_rounded, size: 48, color: AppColors.gold),
          ),
          const SizedBox(height: 24),
          Text(
            'Keep GraceMatch Safe',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Please record a 3-second selfie video turning your head to the left and right. This helps us ensure every profile belongs to a real person.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          GestureDetector(
            onTap: _recordVideo,
            child: Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 60),
               decoration: BoxDecoration(
                 color: _videoPath != null ? AppColors.goldSubtle : AppColors.surfaceHighest,
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: _videoPath != null ? AppColors.gold : AppColors.goldMild, width: 2)
               ),
               child: Column(
                 children: [
                   Icon(
                     _videoPath != null ? Icons.check_circle_rounded : Icons.face_retouching_natural_rounded, 
                     size: 64, 
                     color: _videoPath != null ? AppColors.gold : AppColors.textTertiary
                   ),
                   const SizedBox(height: 16),
                   Text(
                     _videoPath != null ? 'Video Recorded!' : 'Tap to open camera', 
                     style: AppTextStyles.labelMedium.copyWith(color: AppColors.gold)
                   )
                 ],
               )
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
