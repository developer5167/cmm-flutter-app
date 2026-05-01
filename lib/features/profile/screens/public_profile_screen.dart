import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/widgets/full_screen_gallery.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../bloc/profile_event.dart';
import '../../../core/storage/app_storage.dart';

class PublicProfileScreen extends StatefulWidget {
  final String? userId; // If null, shows own profile preview
  final bool showBottomActions;
  const PublicProfileScreen({
    super.key,
    this.userId,
    this.showBottomActions = true,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  late PageController _headerPageController;
  int _currentPhotoIndex = 0;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _headerPageController = PageController();
    _loadMyUserId();
    if (widget.userId != null) {
      context.read<ProfileBloc>().add(FetchProfileEvent(userId: widget.userId));
    } else {
      // Ensure we have the latest data for preview
      context.read<ProfileBloc>().add(FetchProfileEvent());
    }
  }

  Future<void> _loadMyUserId() async {
    final id = await AppStorage.getUserId();
    if (mounted) setState(() => _myUserId = id);
  }

  @override
  void dispose() {
    _headerPageController.dispose();
    super.dispose();
  }

  void _nextPhoto(int total) {
    if (_currentPhotoIndex < total - 1) {
      final nextIndex = _currentPhotoIndex + 1;
      _headerPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPhotoIndex = nextIndex);
      AppHaptics.light();
    }
  }

  void _prevPhoto() {
    if (_currentPhotoIndex > 0) {
      final prevIndex = _currentPhotoIndex - 1;
      _headerPageController.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPhotoIndex = prevIndex);
      AppHaptics.light();
    }
  }

  Future<void> _openGallery(List<String> photos) async {
    final selectedIndex = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(
          images: photos,
          initialIndex: _currentPhotoIndex,
        ),
      ),
    );
    if (!mounted || selectedIndex == null) return;
    if (selectedIndex >= 0 && selectedIndex < photos.length) {
      setState(() => _currentPhotoIndex = selectedIndex);
      _headerPageController.jumpToPage(selectedIndex);
    }
  }

  List<String> _extractPhotoUrls(Map<String, dynamic> data, Map<String, dynamic> profile) {
    List<dynamic> pickPhotoList(dynamic value) {
      if (value is List) return value;
      if (value is String && value.contains(',')) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const <dynamic>[];
    }

    final photoCandidates = <dynamic>[
      ...pickPhotoList(data['photos']),
      ...pickPhotoList(data['profile_photos']),
      ...pickPhotoList(data['gallery']),
      ...pickPhotoList(data['photo_urls']),
      ...pickPhotoList(data['images']),
      ...pickPhotoList(profile['photos']),
      ...pickPhotoList(profile['profile_photos']),
      ...pickPhotoList(profile['gallery']),
      ...pickPhotoList(profile['photo_urls']),
      ...pickPhotoList(profile['images']),
      if (data['user'] is Map) ...pickPhotoList((data['user'] as Map)['photos']),
      if (data['user'] is Map) ...pickPhotoList((data['user'] as Map)['profile_photos']),
      if (data['user'] is Map) ...pickPhotoList((data['user'] as Map)['gallery']),
      if (data['user'] is Map) ...pickPhotoList((data['user'] as Map)['photo_urls']),
      if (data['user'] is Map) ...pickPhotoList((data['user'] as Map)['images']),
    ];

    final photos = <String>[];

    for (final photo in photoCandidates) {
      if (photo is String) {
        if (photo.isNotEmpty) photos.add(photo);
        continue;
      }

      if (photo is Map) {
        final photoMap = photo.cast<dynamic, dynamic>();
        final url = photoMap['photo_url']?.toString() ??
            photoMap['url']?.toString() ??
            photoMap['image_url']?.toString() ??
            photoMap['secure_url']?.toString() ??
            photoMap['file_url']?.toString() ??
            photoMap['photo']?.toString() ??
            photoMap['src']?.toString();
        if (url != null && url.isNotEmpty) photos.add(url);
      }
    }

    final profileFallbacks = [
      profile['photo_url'],
      profile['profile_photo_url'],
      profile['image_url'],
      profile['secure_url'],
      profile['file_url'],
      profile['photo'],
      profile['avatar_url'],
      if (data['user'] is Map) (data['user'] as Map)['photo_url'],
      if (data['user'] is Map) (data['user'] as Map)['profile_photo_url'],
      if (data['user'] is Map) (data['user'] as Map)['image_url'],
      if (data['user'] is Map) (data['user'] as Map)['avatar_url'],
    ];
    for (final fallback in profileFallbacks) {
      final url = fallback?.toString();
      if (url != null && url.isNotEmpty) photos.add(url);
    }

    return photos.toSet().toList();
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

        if (state is ProfileLoaded && state.userId != widget.userId) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          );
        }

        final data = state is ProfileLoaded ? state.profile : <String, dynamic>{};
        final profile = data['profile'] as Map<String, dynamic>? ?? {};
        final family = data['family'] as Map<String, dynamic>? ?? {};
        final photos = _extractPhotoUrls(data, profile);
        if (_currentPhotoIndex >= photos.length && photos.isNotEmpty) {
          _currentPhotoIndex = photos.length - 1;
        }
        
        final name = profile['first_name'] ?? 'User';
        final dob = profile['date_of_birth'] != null ? DateTime.parse(profile['date_of_birth'].toString()) : null;
        final age = dob != null ? (DateTime.now().year - dob.year) : 26;
        final bio = profile['bio'] ?? 'No bio provided yet.';
        final hobbies = (data['hobbies'] as List?)?.map((h) {
          if (h is Map) return h['name']?.toString() ?? h['hobby_name']?.toString() ?? '';
          return h.toString();
        }).where((s) => s.isNotEmpty).toList() ?? [];

        String formatValue(String? val) {
          if (val == null) return 'Not specified';
          return val.replaceAll('_', ' ').split(' ').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join(' ');
        }

        String formatCurrency(dynamic value) {
          if (value == null) return '0';
          String s = value.toString();
          if (s.length <= 3) return s;
          return s.replaceAllMapped(RegExp(r'(\d+)(\d{3})'), (Match m) => '${m[1]},${m[2]}');
        }


        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 480,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (photos.isNotEmpty)
                        Stack(
                          children: [
                            PageView.builder(
                              controller: _headerPageController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: photos.length,
                              onPageChanged: (index) {
                                setState(() => _currentPhotoIndex = index);
                              },
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () => _openGallery(photos),
                                child: CachedNetworkImage(
                                  imageUrl: photos[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white),
                                ),
                              ),
                            ),
                            if (photos.length > 1) ...[
                              Positioned(
                                left: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: AnimatedOpacity(
                                    opacity: _currentPhotoIndex > 0 ? 1 : 0.35,
                                    duration: const Duration(milliseconds: 150),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.black38,
                                      child: IconButton(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: _currentPhotoIndex > 0 ? _prevPhoto : null,
                                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: AnimatedOpacity(
                                    opacity: _currentPhotoIndex < photos.length - 1 ? 1 : 0.35,
                                    duration: const Duration(milliseconds: 150),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.black38,
                                      child: IconButton(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: _currentPhotoIndex < photos.length - 1
                                            ? () => _nextPhoto(photos.length)
                                            : null,
                                        icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Container(color: AppColors.surfaceElevated, child: const Icon(Icons.person, size: 100, color: AppColors.textTertiary)),
                      
                      // ── Page Indicator ──────────────────────────
                      if (photos.length > 1)
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _headerPageController,
                              count: photos.length,
                              effect: const ScrollingDotsEffect(
                                activeDotColor: AppColors.gold,
                                dotColor: Colors.white54,
                                dotHeight: 8,
                                dotWidth: 8,
                              ),
                            ),
                          ),
                        ),
                      if (photos.isNotEmpty)
                        Positioned(
                          top: 56,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${_currentPhotoIndex + 1} / ${photos.length}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                      IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.transparent, AppColors.background],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('$name, $age', style: AppTextStyles.headlineLarge),
                          const SizedBox(width: 8),
                          if (profile['trust_badge'] == true)
                            const Icon(Icons.verified_rounded, color: AppColors.blessing, size: 24),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${profile['denomination'] ?? 'CSI'} • ${profile['location_city'] ?? 'Unknown'}', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gold)),
                      const SizedBox(height: 24),
                      
                      _sectionTitle('About Me'),
                      const SizedBox(height: 12),
                      Text(bio, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
                      const SizedBox(height: 32),

                      if (hobbies.isNotEmpty) ...[
                        _sectionTitle('Interests & Hobbies'),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: hobbies.map((h) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.surfaceHighest),
                            ),
                            child: Text(h, style: AppTextStyles.labelSmall),
                          )).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      _sectionTitle('Faith & Lifestyle'),
                      const SizedBox(height: 16),
                      _infoGrid([
                        _infoTile(Icons.church_rounded, 'Church', profile['church_name'] ?? 'Not specified'),
                        _infoTile(Icons.auto_awesome_rounded, 'Church Involvement', formatValue(profile['church_involvement'])),
                        _infoTile(Icons.smoking_rooms_rounded, 'Smoking', formatValue(profile['smoking'])),
                        _infoTile(Icons.local_bar_rounded, 'Drinking', formatValue(profile['drinking'])),
                        _infoTile(Icons.restaurant_rounded, 'Diet', formatValue(profile['diet'])),
                      ]),
                      const SizedBox(height: 32),

                      _sectionTitle('Profession & Education'),
                      const SizedBox(height: 16),
                      _infoGrid([
                        _infoTile(Icons.work_rounded, 'Profession', profile['profession'] ?? 'Professional'),
                        _infoTile(Icons.school_rounded, 'Education', profile['education'] ?? 'Degree'),
                        _infoTile(Icons.payments_rounded, 'Annual Income', '₹ ${formatCurrency(profile['annual_income_min'])} - ${formatCurrency(profile['annual_income_max'])}'),
                        _infoTile(Icons.height_rounded, 'Height', '${profile['height_cm'] ?? 170} cm'),
                      ]),
                      const SizedBox(height: 32),

                      _sectionTitle('Family Background'),
                      const SizedBox(height: 16),
                      _infoGrid([
                        _infoTile(Icons.family_restroom_rounded, 'Father', family['father_occupation'] ?? 'Not specified'),
                        _infoTile(Icons.face_retouching_natural_rounded, 'Mother', family['mother_occupation'] ?? 'Not specified'),
                      ]),
                      const SizedBox(height: 20),
                      if (family['sibling_details'] != null && (family['sibling_details'] as List).isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text('Siblings', style: AppTextStyles.labelLarge.copyWith(color: AppColors.goldMild)),
                        ),
                        ...(family['sibling_details'] as List).map((sib) {
                          final s = sib as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceHighest),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: s['type'] == 'Brother' ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    s['type'] == 'Brother' ? Icons.boy_rounded : Icons.girl_rounded,
                                    color: s['type'] == 'Brother' ? Colors.blue : Colors.pink,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${s['type']} • ${formatValue(s['marital_status'])}',
                                        style: AppTextStyles.labelLarge,
                                      ),
                                      if (s['education'] != null && s['education'].toString().isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            s['education'].toString(),
                                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ] else ...[
                        _infoTile(Icons.people_rounded, 'Siblings', '${family['brothers_count'] ?? 0} Brothers, ${family['sisters_count'] ?? 0} Sisters'),
                      ],
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(data),
        );
      },
    );
  }

  Widget? _buildBottomBar(Map<String, dynamic> data) {
    if (!widget.showBottomActions) return null;
    if (widget.userId == null) return null; // Own profile preview
    if (_myUserId == null) return null; // Still loading current user ID

    final status = data['interaction_status'] ?? 'none';
    final senderId = data['interaction_sender_id']?.toString();
    final interestId = data['interest_id']?.toString();
    final isReceiver = senderId != null && senderId != _myUserId;

    if (status == 'none') {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(color: AppColors.background.withOpacity(0.8)),
        child: Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.close_rounded,
                color: AppColors.error,
                onTap: () {
                  AppHaptics.light();
                  context.pop();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  AppHaptics.heavy();
                  context.read<ProfileBloc>().add(SendInterestEvent(userId: widget.userId!));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded),
                    SizedBox(width: 8),
                    Text('SEND INTEREST', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'sent') {
      if (isReceiver && interestId != null) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(color: AppColors.background.withOpacity(0.8)),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    AppHaptics.light();
                    context.read<ProfileBloc>().add(RejectInterestEvent(interestId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceElevated,
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.surfaceHighest),
                  ),
                  child: const Text('DECLINE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    AppHaptics.heavy();
                    context.read<ProfileBloc>().add(AcceptInterestEvent(interestId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.textOnGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('ACCEPT', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldMild),
            ),
            child: const Center(
              child: Text('INTEREST SENT', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
        );
      }
    }

    if (status == 'accepted') {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () {
            // Navigation to chat could be added here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldSubtle,
            foregroundColor: AppColors.gold,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Center(
            child: Text('MATCHED! SEND MESSAGE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    return null;
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary));
  }

  Widget _infoGrid(List<Widget> children) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children.map((w) => SizedBox(width: (MediaQuery.of(context).size.width - 64) / 2, child: w)).toList(),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
