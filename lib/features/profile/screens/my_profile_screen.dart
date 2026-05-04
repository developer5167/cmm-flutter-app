import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/storage/app_storage.dart';
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

  Future<void> _shareProfile(String name) async {
    final userId = await AppStorage.getUserId();
    if (userId == null) return;
    final url = 'https://gracematch.app/p/$userId';
    await Share.share(
      'Hey! Check out $name\'s profile on GraceMatch — the Telugu Christian Matrimony app 🙏✝\n$url',
      subject: 'GraceMatch – $name',
    );
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

        final hasRejected = photos.any((p) => p is Map && p['review_status'] == 'rejected');
        final hasPending = photos.any((p) => p is Map && p['review_status'] == 'pending');
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
                      icon: const Icon(Icons.ios_share_rounded, color: AppColors.gold),
                      tooltip: 'Share Profile',
                      onPressed: () => _shareProfile(name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: AppColors.gold),
                      onPressed: () => context.push('/settings'),
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
                        Row(
                          children: [
                            Flexible(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/profile/preview'),
                                icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                                label: const Text('Preview'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.gold,
                                  side: const BorderSide(color: AppColors.goldMild),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  minimumSize: const Size(0, 44),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: OutlinedButton.icon(
                                onPressed: () => _shareProfile(name),
                                icon: const Icon(Icons.ios_share_rounded, size: 18),
                                label: const Text('Share'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.gold,
                                  side: const BorderSide(color: AppColors.goldMild),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  minimumSize: const Size(0, 44),
                                ),
                              ),
                            ),
                          ],
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

                        // My Photos section — always shown when photos exist
                        if (photos.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildMyPhotosSection(photos, hasRejected: hasRejected, hasPending: hasPending),
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
                        _buildSettingsTile(
                          Icons.ios_share_rounded,
                          'Share My Profile',
                          'Invite someone via link',
                          onTap: () => _shareProfile(name),
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

  Widget _buildMyPhotosSection(List photos, {required bool hasRejected, required bool hasPending}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasRejected
              ? Colors.red.withAlpha(100)
              : hasPending
                  ? Colors.amber.withAlpha(80)
                  : AppColors.surfaceHighest,
          width: (hasRejected || hasPending) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.photo_library_rounded, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('My Photos', style: AppTextStyles.labelLarge)),
                GestureDetector(
                  onTap: () => context.push('/onboarding', extra: 7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldMild),
                    ),
                    child: Text('Manage', style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold)),
                  ),
                ),
              ],
            ),
          ),

          // Rejection alert banner
          if (hasRejected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(70)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Some photos were rejected. Tap Manage to upload replacements.',
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (hasPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withAlpha(70)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Some photos are awaiting admin review before becoming visible.',
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Photo grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, i) {
                final p = photos[i];
                if (p is! Map) return const SizedBox.shrink();
                final url = p['photo_url'] as String? ?? '';
                final status = p['review_status'] as String? ?? 'approved';
                final reason = p['rejection_reason'] as String?;
                final isPrimary = p['is_primary'] == true;
                return _buildPhotoCard(url, status: status, reason: reason, isPrimary: isPrimary);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String url, {required String status, String? reason, bool isPrimary = false}) {
    Color borderColor;
    Color badgeBg;
    Widget badgeIcon;

    switch (status) {
      case 'approved':
        borderColor = Colors.green.withAlpha(120);
        badgeBg = Colors.green;
        badgeIcon = const Icon(Icons.check_rounded, color: Colors.white, size: 10);
        break;
      case 'rejected':
        borderColor = Colors.red.withAlpha(180);
        badgeBg = Colors.red;
        badgeIcon = const Icon(Icons.close_rounded, color: Colors.white, size: 10);
        break;
      default: // pending
        borderColor = Colors.amber.withAlpha(180);
        badgeBg = Colors.amber;
        badgeIcon = const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 10);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
            color: AppColors.surface,
            image: url.isNotEmpty
                ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                : null,
          ),
          child: url.isEmpty
              ? const Icon(Icons.broken_image_rounded, color: AppColors.textTertiary, size: 28)
              : null,
        ),

        // Status badge top-right
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
            child: badgeIcon,
          ),
        ),

        // Primary badge bottom
        if (isPrimary)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text('Primary', textAlign: TextAlign.center,
                  style: AppTextStyles.overline.copyWith(color: AppColors.gold)),
            ),
          ),

        // Rejected reason overlay on tap
        if (status == 'rejected' && reason != null && reason.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                reason,
                style: AppTextStyles.overline.copyWith(color: Colors.red.shade300),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
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

