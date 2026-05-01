/// Tracks which conversation the user is currently viewing.
/// Used by the FCM foreground handler to suppress notifications
/// when the user is already inside that specific chat.
class ActiveChatState {
  ActiveChatState._();

  static String? conversationId;
}
