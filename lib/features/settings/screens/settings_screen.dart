import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('SettingsScreen', style: AppTextStyles.headlineMedium)),
      body: const Center(child: Text('Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
