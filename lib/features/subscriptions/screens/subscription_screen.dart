import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/subscription_bloc.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(FetchPlansEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is PaymentProcessed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? (state.success ? 'Success' : 'Failed')),
              backgroundColor: state.success ? Colors.green : Colors.red,
            ),
          );
        } else if (state is SubscriptionError) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Premium Plans', style: AppTextStyles.headlineMedium),
          elevation: 0,
          backgroundColor: AppColors.background,
        ),
        body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }

            if (state is SubscriptionError && state is! PlansLoaded) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
            }

            List<Map<String, dynamic>> plans = [];
            if (state is PlansLoaded) {
              plans = state.plans;
            } else if (state is PaymentPending || state is PaymentProcessed) {
              // try to get plans from a previous state or just show loading if missing
              // For simplicity, we assume PlansLoaded was the previous state
            }

            if (plans.isEmpty && state is! SubscriptionLoading) {
              return const Center(child: Text('No active plans found.', style: TextStyle(color: Colors.white)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Unlock Your God-Given Match Faster',
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get direct contacts, unlimited matches, and priority spotlight.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ...plans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildPlanCard(
                          plan: plan,
                          context: context,
                          isProcessing: state is PaymentPending,
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Converts the backend features JSONB object into human-readable bullet strings.
  /// Values of -1 mean "Unlimited"; 0 / false means skip.
  List<String> _featuresToStrings(dynamic raw) {
    if (raw == null) return [];

    // Backend sends a Map: {"unlimited_swipes": true, "contact_reveals_per_month": 5, ...}
    final Map<String, dynamic> map = raw is Map
        ? Map<String, dynamic>.from(raw)
        : {};

    String count(dynamic v, String singular, String plural) {
      if (v == null || v == false || v == 0) return '';
      if (v == -1 || v == true) return 'Unlimited $plural';
      return '$v ${v == 1 ? singular : plural}';
    }

    final lines = <String>[];

    void add(dynamic v, String Function(dynamic) fn) {
      final s = fn(v);
      if (s.isNotEmpty) lines.add(s);
    }

    add(map['unlimited_swipes'],           (v) => v == true ? 'Unlimited daily swipes' : '');
    add(map['see_who_viewed'],             (v) => v == true ? 'See who viewed your profile' : '');
    add(map['contact_reveals_per_month'],  (v) => count(v, 'Contact reveal', 'Contact reveals') + (v != -1 && v != null && v != 0 ? ' / month' : ''));
    add(map['spotlight_boosts'],           (v) => count(v, 'Spotlight boost', 'Spotlight boosts'));
    add(map['super_interests'],            (v) => count(v, 'Super interest', 'Super interests'));
    add(map['priority_discover'],          (v) => v == true ? 'Priority in discovery' : '');
    add(map['dedicated_support'],          (v) => v == true ? 'Dedicated support' : '');

    return lines.where((s) => s.isNotEmpty).toList();
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required BuildContext context,
    required bool isProcessing,
  }) {
    final bool isPopular = plan['name']?.toString().toLowerCase() == 'gold';
    final List<String> features = _featuresToStrings(plan['features']);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? AppColors.gold : AppColors.surfaceHighest,
          width: isPopular ? 2 : 1,
        ),
        gradient: isPopular
            ? LinearGradient(
                colors: [AppColors.surfaceElevated, AppColors.gold.withAlpha(20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Text(
                'MOST POPULAR',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textOnGold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plan['name'] ?? 'Plan', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.gold)),
                    Text('${plan['duration_months']} Months', style: AppTextStyles.labelLarge),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${plan['price_inr']}', style: AppTextStyles.displayMedium),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('Total', style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(f, style: AppTextStyles.bodyMedium)),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isProcessing ? null : () {
                    context.read<SubscriptionBloc>().add(InitiatePaymentEvent(plan));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? AppColors.gold : AppColors.surfaceHighest,
                    foregroundColor: isPopular ? AppColors.textOnGold : AppColors.gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: isProcessing 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isPopular ? 'Subscribe Now' : 'Choose Plan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
