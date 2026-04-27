import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('PublicProfileScreen', style: AppTextStyles.headlineMedium)),
      body: const Center(child: Text('Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
