import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/state/active_chat_state.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/network/socket_service.dart';
import '../data/chat_repository.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String? otherUserPhoto;
  final String? otherUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserPhoto,
    this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _myUserId;
  int _prevMessageCount = 0;

  bool _isOnline = false;
  String? _lastSeenAt;
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _loadMyUserId();
    ActiveChatState.conversationId = widget.conversationId;
    final bloc = context.read<ChatBloc>();
    bloc.add(SetCurrentConversationEvent(widget.conversationId));
    bloc.add(FetchMessagesEvent(widget.conversationId));

    // Fetch initial status then keep updated via socket
    _fetchStatus();
    _statusSubscription = di.sl<SocketService>().userStatusStream.listen((data) {
      if (data['user_id']?.toString() == widget.otherUserId) {
        if (mounted) {
          setState(() {
            _isOnline = data['type'] == 'online';
            if (data['type'] == 'offline') {
              _lastSeenAt = data['last_seen_at']?.toString();
            }
          });
        }
      }
    });
  }

  Future<void> _loadMyUserId() async {
    final id = await AppStorage.getUserId();
    if (mounted) setState(() => _myUserId = id);
  }

  Future<void> _fetchStatus() async {
    if (widget.otherUserId == null) return;
    final data = await di.sl<ChatRepository>().fetchUserStatus(widget.otherUserId!);
    if (mounted) {
      setState(() {
        _isOnline = data['is_online'] == true;
        _lastSeenAt = data['last_seen_at']?.toString();
      });
    }
  }

  @override
  void dispose() {
    ActiveChatState.conversationId = null;
    _statusSubscription?.cancel();
    context.read<ChatBloc>().add(SetCurrentConversationEvent(''));
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(
          conversationId: widget.conversationId,
          text: text,
          myUserId: _myUserId,
        ));
    _msgCtrl.clear();
    _scrollToNewest();
  }

  void _scrollToNewest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatLastSeen() {
    if (_isOnline) return 'Online';
    if (_lastSeenAt == null) return 'Offline';
    final dt = DateTime.tryParse(_lastSeenAt!)?.toLocal();
    if (dt == null) return 'Offline';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last seen ${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Last seen yesterday';
    return 'Last seen ${diff.inDays}d ago';
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '';
    DateTime? dt;
    if (raw is DateTime) {
      dt = raw;
    } else if (raw is String && raw.isNotEmpty) {
      dt = DateTime.tryParse(raw)?.toLocal();
    }
    if (dt == null) return '';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  // Derive status for a message in the sent state
  String _resolveStatus(Map<String, dynamic> msg) {
    final explicit = msg['_status']?.toString();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return msg['is_read'] == true ? 'read' : 'sent';
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return const Icon(Icons.access_time_rounded,
            size: 12, color: AppColors.textTertiary);
      case 'sent':
        return const Icon(Icons.check_rounded,
            size: 14, color: AppColors.textSecondary);
      case 'delivered':
        return const Icon(Icons.done_all_rounded,
            size: 14, color: AppColors.textSecondary);
      case 'read':
        return const Icon(Icons.done_all_rounded,
            size: 14, color: AppColors.gold);
      case 'failed':
        return const Icon(Icons.error_outline_rounded,
            size: 14, color: AppColors.error);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is MessagesLoaded) {
          // Auto-scroll to newest when message count grows
          if (state.messages.length > _prevMessageCount) {
            _prevMessageCount = state.messages.length;
            _scrollToNewest();
          } else {
            _prevMessageCount = state.messages.length;
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(child: _buildBody(state)),
              _buildInputBar(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: AppColors.surfaceElevated,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/chat');
          }
        },
      ),
      title: InkWell(
        onTap: () {
          final id = widget.otherUserId;
          if (id == null || id.isEmpty) return;
          context.push('/profile/$id?source=chat');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceHighest,
                  image: widget.otherUserPhoto != null &&
                          widget.otherUserPhoto!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.otherUserPhoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.otherUserPhoto == null ||
                        widget.otherUserPhoto!.isEmpty
                    ? const Icon(Icons.person,
                        color: AppColors.textTertiary, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
          Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.otherUserName,
                        style: AppTextStyles.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isOnline
                                  ? const Color(0xFF4CAF50)
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatLastSeen(),
                            style: TextStyle(
                              fontSize: 11,
                              color: _isOnline
                                  ? const Color(0xFF4CAF50)
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(ChatState state) {
    if (state is ChatLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }
    if (state is ChatError) {
      return Center(
          child:
              Text(state.message, style: const TextStyle(color: Colors.white)));
    }
    if (state is MessagesLoaded) {
      return _buildMessageList(state.messages);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageList(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Say "Praise the Lord!" to start.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final senderId = msg['sender_id']?.toString();
        final isMe = _myUserId != null && senderId == _myUserId;
        // Group header: show date separator if this message is on a different
        // day than the next one (index + 1 is older since list is reversed).
        final showDate =
            index == messages.length - 1 || _isDifferentDay(msg, messages[index + 1]);
        return Column(
          children: [
            if (showDate) _buildDateSeparator(msg['created_at']),
            _buildMessageBubble(msg, isMe),
          ],
        );
      },
    );
  }

  bool _isDifferentDay(Map<String, dynamic> a, Map<String, dynamic> b) {
    final da = DateTime.tryParse(a['created_at']?.toString() ?? '')?.toLocal();
    final db = DateTime.tryParse(b['created_at']?.toString() ?? '')?.toLocal();
    if (da == null || db == null) return false;
    return da.year != db.year || da.month != db.month || da.day != db.day;
  }

  Widget _buildDateSeparator(dynamic raw) {
    DateTime? dt;
    if (raw is String) dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return const SizedBox.shrink();

    final now = DateTime.now();
    String label;
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      label = 'Today';
    } else if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label =
          '${dt.day} ${_monthName(dt.month)} ${dt.year != now.year ? dt.year.toString() : ''}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.surfaceHighest)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textTertiary),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.surfaceHighest)),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[m - 1];
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final text = msg['content']?.toString() ?? '';
    final timeStr = _formatTime(msg['created_at']);
    final status = isMe ? _resolveStatus(msg) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 4),
          // ConstrainedBox caps the max width; IntrinsicWidth shrinks to content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                decoration: BoxDecoration(
                  // Sent: goldSubtle — matches the Message button in the Matches tab
                  color: isMe ? AppColors.goldSubtle : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  border: isMe
                      ? Border.all(color: AppColors.goldMild, width: 1)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isMe ? AppColors.gold : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (isMe && status.isNotEmpty) ...[
                          const SizedBox(width: 3),
                          _buildStatusIcon(status),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: AppColors.surfaceHighest)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded,
                color: AppColors.gold),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceHighest),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: TextField(
                  controller: _msgCtrl,
                  style: AppTextStyles.bodyMedium,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: AppColors.background,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded,
                  color: AppColors.textOnGold, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
