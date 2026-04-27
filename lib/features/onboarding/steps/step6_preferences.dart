import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../screens/onboarding_screen.dart';

class Step6Preferences extends StatefulWidget {
  const Step6Preferences({super.key});

  @override
  State<Step6Preferences> createState() => _Step6PreferencesState();
}

class _Step6PreferencesState extends OnboardingStepState<Step6Preferences> {
  RangeValues _ageRange = const RangeValues(22, 35);
  RangeValues _heightRange = const RangeValues(150, 180); // in cm
  final List<String> _selectedDenominations = [];
  bool _denominationFlexible = true;

  @override
  Map<String, dynamic>? getStepData() {
    if (!_denominationFlexible && _selectedDenominations.isEmpty) {
      return null;
    }
    return {
      'age_min': _ageRange.start.round(),
      'age_max': _ageRange.end.round(),
      'height_min': _heightRange.start.round(),
      'height_max': _heightRange.end.round(),
      'preferred_denominations': _selectedDenominations,
      'denomination_flexible': _denominationFlexible,
    };
  }

  final _denominations = [
    'Any',
    'CSI',
    'Catholic',
    'Pentecostal',
    'Baptist',
    'Born Again',
    'Orthodox'
  ];

  void _toggleDenomination(String denomination) {
    setState(() {
      if (denomination == 'Any') {
        _selectedDenominations.clear();
        _selectedDenominations.add('Any');
      } else {
        _selectedDenominations.remove('Any');
        if (_selectedDenominations.contains(denomination)) {
          _selectedDenominations.remove(denomination);
        } else {
          _selectedDenominations.add(denomination);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Age Range (Years)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_ageRange.start.round()}',
                  style: AppTextStyles.labelLarge),
              Text('${_ageRange.end.round()}', style: AppTextStyles.labelLarge),
            ],
          ),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 60,
            activeColor: AppColors.gold,
            inactiveColor: AppColors.surfaceHighest,
            onChanged: (values) => setState(() => _ageRange = values),
          ),
          const SizedBox(height: 24),

          _fieldLabel('Height Range (cm)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_heightRange.start.round()}',
                  style: AppTextStyles.labelLarge),
              Text('${_heightRange.end.round()}',
                  style: AppTextStyles.labelLarge),
            ],
          ),
          RangeSlider(
            values: _heightRange,
            min: 140,
            max: 220,
            activeColor: AppColors.gold,
            inactiveColor: AppColors.surfaceHighest,
            onChanged: (values) => setState(() => _heightRange = values),
          ),
          const SizedBox(height: 24),

          _fieldLabel('Preferred Denominations'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _denominations
                .map((d) => _multiSelectChip(
                    d, _selectedDenominations.contains(d),
                    () => _toggleDenomination(d)))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _denominationFlexible,
                  activeColor: AppColors.gold,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _denominationFlexible = val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('I am flexible about denomination',
                    style: AppTextStyles.bodyMedium),
              ),
            ],
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

  Widget _multiSelectChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
