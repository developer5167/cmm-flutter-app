import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_state.dart';
import 'identity_verification_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text(state.message, style: const TextStyle(color: Colors.white))),
          );
        }

        final data = state is ProfileLoaded ? state.profile : <String, dynamic>{};
        final profile = data['profile'] as Map<String, dynamic>? ?? {};
        
        final name = profile['first_name'] ?? profile['full_name'] ?? 'User';
        final dob = profile['date_of_birth'] != null ? DateTime.parse(profile['date_of_birth'].toString()) : null;
        final age = dob != null ? (DateTime.now().year - dob.year) : 26;
        final denomination = profile['denomination'] ?? 'CSI';
        final profession = profile['profession'] ?? 'Software Engineer';
        final photos = data['photos'] as List? ?? [];
        String? photoUrl;
        if (photos.isNotEmpty) {
          final firstPhoto = photos[0];
          if (firstPhoto is Map) {
            photoUrl = firstPhoto['photo_url'] as String?;
          } else if (firstPhoto is String) {
            photoUrl = firstPhoto;
          }
        }
        final isVerified = profile['is_id_verified'] ?? profile['trust_badge'] ?? false;
        final hasVideo = profile['video_selfie_url'] != null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.background,
                  pinned: true,
                  centerTitle: false,
                  title: Text('My Profile', style: AppTextStyles.headlineLarge),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: AppColors.gold),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.goldMild, width: 2),
                                  color: AppColors.surfaceElevated,
                                  image: photoUrl != null 
                                    ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                                    : null,
                                ),
                                child: photoUrl == null 
                                  ? const Center(child: Icon(Icons.person, size: 60, color: AppColors.textTertiary))
                                  : null,
                              ),

                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$name, $age', style: AppTextStyles.headlineMedium),
                            if (isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: Colors.blue, size: 20),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('$denomination • $profession', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/profile/preview'),
                          icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                          label: const Text('Preview as Public'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.goldMild),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),

                        if (hasVideo) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.goldSubtle,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.goldMild),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.videocam_rounded, color: AppColors.gold, size: 14),
                                const SizedBox(width: 4),
                                Text('Video Identity Available', style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold)),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                        
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldenGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppColors.gold.withAlpha(40), blurRadius: 16, offset: const Offset(0, 4))
                            ]
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded, size: 40, color: AppColors.textOnGold),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('GraceMatch Free', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textOnGold)),
                                    Text('Upgrade for 5x more matches', style: AppTextStyles.labelSmall.copyWith(color: AppColors.surface)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textOnGold),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        _buildSettingsTile(
                          Icons.person_rounded, 
                          'Basic Information', 
                          'Name, age, and location',
                          onTap: () => context.push('/onboarding', extra: 0),
                        ),
                        _buildSettingsTile(
                          Icons.photo_library_rounded, 
                          'My Photos', 
                          'Manage your gallery',
                          onTap: () => context.push('/onboarding', extra: 7),
                        ),
                        _buildSettingsTile(
                          Icons.text_snippet_rounded, 
                          'Bio & Details', 
                          'Edit your personal intro',
                          onTap: () => context.push('/onboarding', extra: 2),
                        ),
                        _buildSettingsTile(
                          Icons.church_rounded, 
                          'Faith Details', 
                          'Denomination & Church',
                          onTap: () => context.push('/onboarding', extra: 1),
                        ),
                        _buildSettingsTile(
                          Icons.volunteer_activism_rounded, 
                          'Lifestyle & Hobbies', 
                          'Smoking, drinking, hobbies',
                          onTap: () => context.push('/onboarding', extra: 3), // Lifestyle is index 3
                        ),
                        _buildSettingsTile(
                          Icons.favorite_rounded, 
                          'My Hobbies', 
                          'Select what you love',
                          onTap: () => context.push('/onboarding', extra: 6), // Hobbies is index 6
                        ),
                        _buildSettingsTile(
                          Icons.family_restroom_rounded, 
                          'Family Background', 
                          'Update parent occupation',
                          onTap: () => context.push('/onboarding', extra: 4),
                        ),
                        _buildSettingsTile(
                          Icons.tune_rounded, 
                          'Partner Preferences', 
                          'Who are you looking for?',
                          onTap: () => context.push('/onboarding', extra: 5),
                        ),
                        _buildSettingsTile(
                          Icons.verified_user_rounded, 
                          'Identity Verification', 
                          isVerified ? 'Verified Account' : 'Trust badge status',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IdentityVerificationScreen())),
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceHighest),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

