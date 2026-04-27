import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/interests_bloc.dart';
import '../bloc/interests_event.dart';
import '../bloc/interests_state.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<InterestsBloc>().add(FetchInterestsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InterestsBloc, InterestsState>(
      builder: (context, state) {
        int receivedCount = 0;
        int matchedCount = 0;
        int sentCount = 0;

        if (state is InterestsLoaded) {
          receivedCount = state.received.length;
          matchedCount = state.matches.length;
          sentCount = state.sent.length;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Interests', style: AppTextStyles.headlineMedium),
            elevation: 0,
            backgroundColor: AppColors.background,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.gold,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.labelMedium,
              dividerColor: AppColors.surfaceHighest,
              tabs: [
                Tab(text: 'Received ($receivedCount)'),
                Tab(text: 'Matches ($matchedCount)'),
                Tab(text: 'Sent ($sentCount)'),
              ],
            ),
          ),
          body: state is InterestsLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : state is InterestsError
            ? Center(child: Text(state.message, style: const TextStyle(color: Colors.white)))
            : state is InterestsLoaded
            ? TabBarView(
                controller: _tabController,
                children: [
                  _buildInterestList(state.received, isReceived: true),
                  _buildInterestList(state.matches, isMatch: true),
                  _buildInterestList(state.sent),
                ],
              )
            : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildInterestList(List<Map<String, dynamic>> items, {bool isReceived = false, bool isMatch = false}) {
    if (items.isEmpty) {
      String title = isMatch ? 'No matches yet' : (isReceived ? 'No interests received' : 'No interests sent');
      String desc = isMatch ? 'Keep exploring the discover feed.' : 'You haven\'t received any likes recently.';
      return _buildEmptyTab(title, desc);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final profile = items[index];
        return Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceHighest),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceHighest,
                  border: Border.all(color: AppColors.goldMild, width: 2),
                ),
                child: const Icon(Icons.person, color: AppColors.textTertiary, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${profile['name'] ?? 'Sarah'}, ${profile['age'] ?? 24}', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 4),
                    Text('${profile['denomination'] ?? 'CSI'} • ${profile['profession'] ?? 'Teacher'}', style: AppTextStyles.bodySmall),
                    if (isReceived) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<InterestsBloc>().add(InterestActionEvent(
                                  interestId: profile['id'].toString(),
                                  accept: true,
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.textOnGold,
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<InterestsBloc>().add(InterestActionEvent(
                                  interestId: profile['id'].toString(),
                                  accept: false,
                                ));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(color: AppColors.surfaceHighest),
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text('Decline'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isMatch) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Chat
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldSubtle,
                            foregroundColor: AppColors.gold,
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('Message'),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyTab(String title, String desc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_outline_rounded, size: 64, color: AppColors.surfaceHighest),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(desc, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
