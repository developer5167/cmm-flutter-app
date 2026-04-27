import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../screens/onboarding_screen.dart';

class Step3Personal extends StatefulWidget {
  const Step3Personal({super.key});

  @override
  State<Step3Personal> createState() => _Step3PersonalState();
}

class _Step3PersonalState extends OnboardingStepState<Step3Personal> {
  final _heightCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  String? _salaryRange;

  @override
  Map<String, dynamic>? getStepData() {
    if (_heightCtrl.text.isEmpty || _educationCtrl.text.isEmpty || _professionCtrl.text.isEmpty || _salaryRange == null) {
      return null;
    }
    return {
      'height': int.tryParse(_heightCtrl.text) ?? 0,
      'education': _educationCtrl.text.trim(),
      'profession': _professionCtrl.text.trim(),
      'annual_income': _salaryRange,
    };
  }

  final _salaryRanges = [
    'Less than ₹3 Lakhs',
    '₹3L - ₹6L',
    '₹6L - ₹10L',
    '₹10L - ₹15L',
    '₹15L - ₹25L',
    '₹25L and above'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Height (in cm)'),
          _inputField(_heightCtrl, 'e.g. 175', isNumber: true),
          const SizedBox(height: 24),

          _fieldLabel('Highest Education'),
          _inputField(_educationCtrl, 'e.g. B.Tech Computer Science'),
          const SizedBox(height: 24),

          _fieldLabel('Current Profession'),
          _inputField(_professionCtrl, 'e.g. Software Engineer'),
          const SizedBox(height: 24),

          _fieldLabel('Annual Income'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _salaryRanges
                .map((r) => _selectChip(
                    r, _salaryRange, (v) => setState(() => _salaryRange = v)))
                .toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(label, style: AppTextStyles.labelMedium),
      );

  Widget _inputField(TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: AppTextStyles.labelLarge,
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _selectChip(
      String label, String? selected, ValueChanged<String> onTap) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected ? AppColors.goldSubtle : AppColors.surfaceElevated,
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.surfaceHighest,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.gold : AppColors.textSecondary)),
      ),
    );
  }
}
