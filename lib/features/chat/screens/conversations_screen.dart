import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(FetchConversationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Chat', style: AppTextStyles.headlineMedium),
            elevation: 0,
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.shield_rounded, color: AppColors.gold),
                onPressed: () {},
              )
            ],
          ),
          body: state is ChatLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : state is ChatError
                  ? Center(child: Text(state.message, style: const TextStyle(color: Colors.white)))
                  : state is ConversationsLoaded
                      ? _buildConversationList(state.conversations)
                      : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildConversationList(List<Map<String, dynamic>> conversations) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.surfaceHighest),
            const SizedBox(height: 16),
            Text('No active chats', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text('Matches will appear here once both like each other.', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conv = conversations[index];
        final isUnread = conv['is_unread'] as bool? ?? false;
        final name = conv['other_user_name'] ?? 'Match';
        final lastMsg = conv['last_message'] ?? 'Start a conversation';
        final time = conv['last_message_time'] ?? '';

        return InkWell(
          onTap: () {
            context.go('/chat/${conv['id']}', extra: {'name': name});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: isUnread ? AppColors.surfaceElevated.withAlpha(50) : null,
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceHighest,
                        border: isUnread ? Border.all(color: AppColors.gold, width: 2) : null,
                        image: conv['other_user_photo'] != null 
                          ? DecorationImage(image: NetworkImage(conv['other_user_photo']), fit: BoxFit.cover)
                          : null,
                      ),
                      child: conv['other_user_photo'] == null 
                        ? const Icon(Icons.person, color: AppColors.textTertiary)
                        : null,
                    ),
                    if (isUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                          Text(
                            time,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isUnread ? AppColors.gold : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

