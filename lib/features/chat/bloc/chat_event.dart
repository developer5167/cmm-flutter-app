import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class FetchConversationsEvent extends ChatEvent {}

class FetchMessagesEvent extends ChatEvent {
  final String conversationId;
  const FetchMessagesEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String text;
  const SendMessageEvent({required this.conversationId, required this.text});

  @override
  List<Object?> get props => [conversationId, text];
}

class NewMessageReceivedEvent extends ChatEvent {
  final Map<String, dynamic> message;
  const NewMessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
