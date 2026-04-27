import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';

import '../screens/onboarding_screen.dart';

class Step2Faith extends StatefulWidget {
  const Step2Faith({super.key});
  @override State<Step2Faith> createState() => _Step2FaithState();
}

class _Step2FaithState extends OnboardingStepState<Step2Faith> {
  String? _denomination;
  String? _marriageIntent;
  String? _faithLevel;
  String? _churchInvolvement;
  final _churchNameCtrl = TextEditingController();
  final _casteCtrl = TextEditingController();

  final _denominations = ['CSI', 'Catholic', 'Pentecostal', 'Baptist', 'Born Again', 'Orthodox', 'Other'];
  final _intents = ['Ready Now', 'Within 6 Months', 'Within 1 Year', 'Within 2 Years'];
  final _faithLevels = ['Very Strong', 'Strong', 'Moderate', 'Growing'];
  final _involvements = ['Very Active', 'Active', 'Occasional', 'Rare'];

  @override
  Map<String, dynamic>? getStepData() {
    if (_denomination == null || _marriageIntent == null || _faithLevel == null || _churchInvolvement == null || _churchNameCtrl.text.isEmpty) {
      return null;
    }
    return {
      'denomination': _denomination,
      'marriage_intent': _marriageIntent,
      'faith_level': _faithLevel,
      'church_involvement': _churchInvolvement,
      'church_name': _churchNameCtrl.text.trim(),
      'caste': _casteCtrl.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Denomination'),
          Wrap(spacing: 8, runSpacing: 8, children: _denominations.map((d) =>
            _selectChip(d, _denomination, (v) => setState(() => _denomination = v))
          ).toList()),

          const SizedBox(height: 24),
          _sectionLabel('Church Name'),
          TextField(
            controller: _churchNameCtrl,
            style: AppTextStyles.labelLarge,
            decoration: const InputDecoration(hintText: 'e.g. CSI Cathedral Kochi'),
          ),

          const SizedBox(height: 24),
          _sectionLabel('Marriage Intent'),
          Wrap(spacing: 8, runSpacing: 8, children: _intents.map((i) =>
            _selectChip(i, _marriageIntent, (v) => setState(() => _marriageIntent = v))
          ).toList()),

          const SizedBox(height: 24),
          _sectionLabel('Faith Level'),
          Wrap(spacing: 8, runSpacing: 8, children: _faithLevels.map((f) =>
            _selectChip(f, _faithLevel, (v) => setState(() => _faithLevel = v))
          ).toList()),

          const SizedBox(height: 24),
          _sectionLabel('Church Involvement'),
          Wrap(spacing: 8, runSpacing: 8, children: _involvements.map((c) =>
            _selectChip(c, _churchInvolvement, (v) => setState(() => _churchInvolvement = v))
          ).toList()),

          const SizedBox(height: 24),
          _sectionLabel('Caste (Optional)'),
          TextField(
            controller: _casteCtrl,
            style: AppTextStyles.labelLarge,
            decoration: const InputDecoration(hintText: 'e.g. Syrian Christian'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: AppTextStyles.labelLarge),
  );

  Widget _selectChip(String label, String? selected, ValueChanged<String> onTap) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () { AppHaptics.selection(); onTap(label); },
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
        child: Text(label, style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? AppColors.gold : AppColors.textSecondary)),
      ),
    );
  }
}
