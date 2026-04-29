import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/app_haptics.dart';

import '../screens/onboarding_screen.dart';

class Step1Basic extends StatefulWidget {
  const Step1Basic({super.key});
  @override State<Step1Basic> createState() => _Step1BasicState();
}

class _Step1BasicState extends OnboardingStepState<Step1Basic> {
  String? _gender;
  String? _lookingFor;
  final _nameCtrl = TextEditingController();
  DateTime? _dob;
  final _cityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parent = context.findAncestorStateOfType<OnboardingScreenState>();
      final profile = parent?.onboardingData?['profile'];
      if (profile != null && mounted) {
        setState(() {
          _gender = profile['gender'];
          _lookingFor = profile['looking_for'];
          if (profile['first_name'] != null) _nameCtrl.text = profile['first_name'];
          if (profile['date_of_birth'] != null) _dob = DateTime.tryParse(profile['date_of_birth']);
          if (profile['location_city'] != null) _cityCtrl.text = profile['location_city'];
        });
      }
    });
  }

  @override
  Map<String, dynamic>? getStepData() {
    if (_gender == null || _lookingFor == null || _nameCtrl.text.isEmpty || _dob == null || _cityCtrl.text.isEmpty) {
      return null;
    }
    return {
      'gender': _gender,
      'looking_for': _lookingFor,
      'first_name': _nameCtrl.text.trim(),
      'date_of_birth': _dob!.toIso8601String(),
      'location_city': _cityCtrl.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gender
          Text('I am a', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              _genderChoice('Male', '👨', 'male', _gender, (v) => setState(() => _gender = v)),
              const SizedBox(width: 12),
              _genderChoice('Female', '👩', 'female', _gender, (v) => setState(() => _gender = v)),
            ],
          ),
          const SizedBox(height: 24),

          // Looking for
          Text('Looking for a', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              _genderChoice('Man', '👨', 'male', _lookingFor, (v) => setState(() => _lookingFor = v)),
              const SizedBox(width: 12),
              _genderChoice('Woman', '👩', 'female', _lookingFor, (v) => setState(() => _lookingFor = v)),
            ],
          ),
          const SizedBox(height: 24),

          // Name
          _fieldLabel('First Name'),
          _inputField(_nameCtrl, 'e.g. Samuel'),
          const SizedBox(height: 20),

          // DOB
          _fieldLabel('Date of Birth'),
          _dobPicker(),
          const SizedBox(height: 20),

          // City
          _fieldLabel('City'),
          _inputField(_cityCtrl, 'e.g. Hyderabad'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _genderChoice(String label, String emoji, String value, String? current, ValueChanged<String> onSelect) {
    final isSelected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          onSelect(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? AppColors.goldSubtle : AppColors.surfaceElevated,
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.surfaceHighest,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.gold : AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label, style: AppTextStyles.labelMedium),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: AppTextStyles.labelLarge,
      decoration: InputDecoration(hintText: hint),
      onChanged: (_) => AppHaptics.selection(),
    );
  }

  Widget _dobPicker() {
    return GestureDetector(
      onTap: () async {
        AppHaptics.light();
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(now.year - 25),
          firstDate: DateTime(now.year - 60),
          lastDate: DateTime(now.year - 18),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.gold),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _dob = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceHighest),
        ),
        child: Row(children: [
          Expanded(child: Text(
            _dob != null
                ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                : 'Select date of birth',
            style: _dob != null ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
          )),
          const Icon(Icons.calendar_today_rounded, color: AppColors.gold, size: 18),
        ]),
      ),
    );
  }
}
