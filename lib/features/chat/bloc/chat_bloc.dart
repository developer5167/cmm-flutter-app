import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../data/chat_repository.dart';
import '../../../core/network/socket_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final SocketService _socketService;
  StreamSubscription? _socketSubscription;

  ChatBloc(this._repository, this._socketService) : super(ChatInitial()) {
    on<FetchConversationsEvent>(_onFetchConversations);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);

    _socketSubscription = _socketService.messageStream.listen((message) {
      add(NewMessageReceivedEvent(message));
    });
  }

  Future<void> _onFetchConversations(FetchConversationsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final conversations = await _repository.fetchConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onFetchMessages(FetchMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.fetchMessages(event.conversationId);
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await _repository.sendMessage(event.conversationId, event.text);
      // Wait for socket to deliver the message back, or handle optimistically
      add(FetchMessagesEvent(event.conversationId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onNewMessageReceived(NewMessageReceivedEvent event, Emitter<ChatState> emit) {
    if (state is MessagesLoaded) {
      final currentMessages = List<Map<String, dynamic>>.from((state as MessagesLoaded).messages);
      // Check if message belongs to current conversation (if we are in one)
      // Note: we might need to handle this more precisely with ID checks
      currentMessages.insert(0, event.message);
      emit(MessagesLoaded(currentMessages));
    } else {
      // If we are on conversation list, we might want to trigger FetchConversationsEvent
      add(FetchConversationsEvent());
    }
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
}
