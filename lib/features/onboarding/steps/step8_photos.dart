import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/onboarding_screen.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class Step8Photos extends StatefulWidget {
  const Step8Photos({super.key});

  @override
  State<Step8Photos> createState() => _Step8PhotosState();
}

class _Step8PhotosState extends OnboardingStepState<Step8Photos> {
  final List<String?> _photoPaths = List.filled(6, null);
  final ImagePicker _picker = ImagePicker();

  @override
  Map<String, dynamic>? getStepData() {
    if (_photoPaths[0] == null) {
      return null;
    }
    // Step 8 data might just be a confirmation or the list of server URLs if we had them
    // For now, let's just return a placeholder or the counts
    return {
      'photo_count': _photoPaths.where((p) => p != null).length,
    };
  }

  Future<void> _pickPhoto(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _photoPaths[index] = image.path);
      // Upload immediately
      if (mounted) {
        context.read<OnboardingBloc>().add(UploadPhotoEvent(image.path, index));
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths[index] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is PhotoUploadedSuccess) {
          // Photo index state.index was uploaded successfully
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload up to 6 photos. The first photo will be your profile picture. Smiles get more matches!',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return _buildPhotoSlot(index);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    final path = _photoPaths[index];
    final hasPhoto = path != null;

    return GestureDetector(
      onTap: () => hasPhoto ? null : _pickPhoto(index),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: index == 0 ? AppColors.gold : AppColors.surfaceHighest,
              width: index == 0 && !hasPhoto ? 2 : 1),
        ),
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        color: Colors.black54,
                        child: Text(
                          'Primary',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.overline
                              .copyWith(color: AppColors.gold),
                        ),
                      ),
                    ),
                ],
              )
            : Center(
                child: Icon(
                  Icons.add_a_photo_rounded,
                  color: index == 0 ? AppColors.gold : AppColors.textTertiary,
                  size: 28,
                ),
              ),
      ),
    );
  }
}

