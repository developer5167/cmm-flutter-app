import 'package:equatable/equatable.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class FetchActivityEvent extends ActivityEvent {
  const FetchActivityEvent();
}

class FetchNotificationsEvent extends ActivityEvent {
  const FetchNotificationsEvent();
}

class FetchViewsEvent extends ActivityEvent {
  const FetchViewsEvent();
}

class FetchShortlistsEvent extends ActivityEvent {
  const FetchShortlistsEvent();
}

class MarkAllReadEvent extends ActivityEvent {
  const MarkAllReadEvent();
}

class MarkOneReadEvent extends ActivityEvent {
  final String notificationId;
  const MarkOneReadEvent(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class ToggleShortlistEvent extends ActivityEvent {
  final String targetUserId;
  const ToggleShortlistEvent(this.targetUserId);
  @override
  List<Object?> get props => [targetUserId];
}
