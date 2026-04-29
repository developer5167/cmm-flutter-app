import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../screens/onboarding_screen.dart';

class Step5Family extends StatefulWidget {
  const Step5Family({super.key});

  @override
  State<Step5Family> createState() => _Step5FamilyState();
}

class _Step5FamilyState extends OnboardingStepState<Step5Family> {
  String? _familyType;
  String? _familyValue;
  final _fatherCtrl = TextEditingController();
  final _motherCtrl = TextEditingController();

  // Maps: display label → API value
  final _familyTypes = {'Nuclear': 'nuclear', 'Joint': 'joint', 'Other': 'other'};
  final _familyValuesMap = {'Orthodox': 'middle', 'Traditional': 'middle', 'Moderate': 'upper_middle', 'Liberal': 'affluent'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parent = context.findAncestorStateOfType<OnboardingScreenState>();
      final family = parent?.onboardingData?['family'];
      if (family != null && mounted) {
        setState(() {
          if (family['father_occupation'] != null) _fatherCtrl.text = family['father_occupation'];
          if (family['mother_occupation'] != null) _motherCtrl.text = family['mother_occupation'];
          
          if (family['family_type'] != null) {
            _familyType = _familyTypes.entries.cast<MapEntry<String, String>?>().firstWhere((e) => e?.value == family['family_type'], orElse: () => null)?.key;
          }
          
          if (family['family_class'] != null) {
            _familyValue = _familyValuesMap.entries.cast<MapEntry<String, String>?>().firstWhere((e) => e?.value == family['family_class'], orElse: () => null)?.key;
          }
        });
      }
    });
  }

  @override
  Map<String, dynamic>? getStepData() {
    if (_familyType == null || _familyValue == null) {
      return null;
    }
    return {
      'family_type': _familyTypes[_familyType],
      'family_class': _familyValuesMap[_familyValue],
      'father_occupation': _fatherCtrl.text.trim(),
      'mother_occupation': _motherCtrl.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Family Type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _familyTypes.keys
                .map((t) => _selectChip(
                    t, _familyType, (v) => setState(() => _familyType = v)))
                .toList(),
          ),
          const SizedBox(height: 24),

          _fieldLabel('Family Values'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _familyValuesMap.keys
                .map((v) => _selectChip(
                    v, _familyValue, (val) => setState(() => _familyValue = val)))
                .toList(),
          ),
          const SizedBox(height: 24),

          _fieldLabel("Father's Occupation"),
          _inputField(_fatherCtrl, 'e.g. Retired Govt Employee'),
          const SizedBox(height: 24),

          _fieldLabel("Mother's Occupation"),
          _inputField(_motherCtrl, 'e.g. Homemaker'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(label, style: AppTextStyles.labelMedium),
      );

  Widget _inputField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: AppTextStyles.labelLarge,
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _selectChip(String label, String? selected, ValueChanged<String> onTap) {
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
