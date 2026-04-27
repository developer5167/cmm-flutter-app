import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';

class ProfileCard extends StatefulWidget {
  final Map<String, dynamic> profile;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final double scale;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.scale = 1.0,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _dragController;
  Offset _dragOffset = Offset.zero;
  double _rotation = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _rotation = _dragOffset.dx / 350; // max ~25 degree rotation
    });
  }

  void _onPanEnd(DragEndDetails details) async {
    final threshold = MediaQuery.of(context).size.width * 0.35;

    if (_dragOffset.dx > threshold) {
      // Swipe right = Like
      await AppHaptics.heavy();
      widget.onSwipeRight?.call();
    } else if (_dragOffset.dx < -threshold) {
      // Swipe left = Pass
      await AppHaptics.light();
      widget.onSwipeLeft?.call();
    } else {
      // Snap back
      setState(() {
        _dragOffset = Offset.zero;
        _rotation = 0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final likeOpacity = (_dragOffset.dx / 120).clamp(0.0, 1.0);
    final passOpacity = (-_dragOffset.dx / 120).clamp(0.0, 1.0);

    return Transform.scale(
      scale: widget.scale,
      child: GestureDetector(
        onPanStart: widget.onSwipeLeft != null ? _onPanStart : null,
        onPanUpdate: widget.onSwipeLeft != null ? _onPanUpdate : null,
        onPanEnd: widget.onSwipeLeft != null ? _onPanEnd : null,
        onTap: () {
          AppHaptics.light();
          // Navigate to full profile
        },
        child: AnimatedContainer(
          duration: _isDragging
              ? Duration.zero
              : const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(_dragOffset.dx, _dragOffset.dy * 0.3, 0)
            ..rotateZ(_rotation * 0.3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // ── Background Photo ─────────────────────────
                _buildPhoto(),

                // ── Gradient Overlay ─────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.profileCardGradient,
                  ),
                ),

                // ── LIKE/PASS Overlay indicators ─────────────
                Positioned(
                  top: 40,
                  left: 24,
                  child: Opacity(
                    opacity: likeOpacity,
                    child: Transform.rotate(
                      angle: -0.3,
                      child: _stampBadge('INTEREST', AppColors.blessing),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 24,
                  child: Opacity(
                    opacity: passOpacity,
                    child: Transform.rotate(
                      angle: 0.3,
                      child: _stampBadge('PASS', AppColors.error),
                    ),
                  ),
                ),

                // ── Profile Info ─────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name + Age + Trust badge
                        Row(
                          children: [
                            Text(
                              '${widget.profile['name']}, ${widget.profile['age']}',
                              style: AppTextStyles.profileName,
                            ),
                            if (widget.profile['trust_badge'] == true) ...[
                              const SizedBox(width: 8),
                              _trustBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Denomination + City
                        Row(
                          children: [
                            const Icon(Icons.church_rounded,
                                size: 14, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Text(
                              widget.profile['denomination'] ?? '',
                              style: AppTextStyles.profileMeta
                                  .copyWith(color: AppColors.gold),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              widget.profile['city'] ?? '',
                              style: AppTextStyles.profileMeta,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Profession
                        Row(
                          children: [
                            const Icon(Icons.work_rounded,
                                size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              widget.profile['profession'] ?? '',
                              style: AppTextStyles.profileMeta,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Compatibility score
                        _compatibilityBar(
                            widget.profile['compatibility'] as int? ?? 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(
        begin: const Offset(0.92, 0.92),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.easeOutCubic,
      ).fadeIn(duration: 300.ms),
    );
  }

  Widget _buildPhoto() {
    final photos = widget.profile['photos'] as List?;
    final photoUrl = photos?.isNotEmpty == true ? photos!.first as String : null;

    if (photoUrl == null) {
      return Container(
        color: AppColors.surfaceElevated,
        child: const Center(
          child: Icon(Icons.person_rounded,
              color: AppColors.textTertiary, size: 80),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: photoUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Container(
        color: AppColors.surfaceElevated,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.gold),
            strokeWidth: 2,
          ),
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _trustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.blessingSubtle,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.blessing),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded,
              color: AppColors.blessing, size: 12),
          const SizedBox(width: 3),
          Text('Verified',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.blessing)),
        ],
      ),
    );
  }

  Widget _stampBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.headlineSmall.copyWith(
            color: color, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _compatibilityBar(int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Match Score',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textTertiary)),
            const Spacer(),
            Text('$score%',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.surfaceHighest,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
