import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../screens/onboarding_screen.dart';

class Step7Hobbies extends StatefulWidget {
  const Step7Hobbies({super.key});

  @override
  State<Step7Hobbies> createState() => _Step7HobbiesState();
}

class _Step7HobbiesState extends OnboardingStepState<Step7Hobbies> {
  final List<String> _selectedHobbies = [];

  @override
  Map<String, dynamic>? getStepData() {
    if (_selectedHobbies.isEmpty) {
      return null;
    }
    return {
      'hobbies': _selectedHobbies,
    };
  }

  final _hobbyCategories = {
    'Faith & Community': ['Choir', 'Bible Study', 'Youth Ministry', 'Volunteering', 'Mission Trips'],
    'Lifestyle': ['Traveling', 'Photography', 'Reading', 'Cooking', 'Fitness'],
    'Arts & Culture': ['Music', 'Movies', 'Theatre', 'Painting', 'Dancing'],
    'Sports & Outdoors': ['Cricket', 'Badminton', 'Trekking', 'Swimming'],
  };

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else {
        if (_selectedHobbies.length < 10) {
          _selectedHobbies.add(hobby);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can select up to 10 hobbies.')),
          );
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
          Row(
            children: [
              Text('Selected: ', style: AppTextStyles.labelMedium),
              Text('${_selectedHobbies.length}/10',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 20),

          ..._hobbyCategories.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.key, style: AppTextStyles.labelLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.value
                      .map((hobby) => _multiSelectChip(
                          hobby,
                          _selectedHobbies.contains(hobby),
                          () => _toggleHobby(hobby)))
                      .toList(),
                ),
                const SizedBox(height: 32),
              ],
            );
          }),
        ],
      ),
    );
  }

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
