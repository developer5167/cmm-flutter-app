import 'package:equatable/equatable.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();
  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<Map<String, dynamic>> notifications;
  final int unreadNotifications;

  // Views
  final List<Map<String, dynamic>> viewers;
  final int totalViews;
  final bool viewsPremiumRequired;

  // Shortlists
  final List<Map<String, dynamic>> shortlists;

  const ActivityLoaded({
    this.notifications = const [],
    this.unreadNotifications = 0,
    this.viewers = const [],
    this.totalViews = 0,
    this.viewsPremiumRequired = false,
    this.shortlists = const [],
  });

  ActivityLoaded copyWith({
    List<Map<String, dynamic>>? notifications,
    int? unreadNotifications,
    List<Map<String, dynamic>>? viewers,
    int? totalViews,
    bool? viewsPremiumRequired,
    List<Map<String, dynamic>>? shortlists,
  }) {
    return ActivityLoaded(
      notifications: notifications ?? this.notifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      viewers: viewers ?? this.viewers,
      totalViews: totalViews ?? this.totalViews,
      viewsPremiumRequired: viewsPremiumRequired ?? this.viewsPremiumRequired,
      shortlists: shortlists ?? this.shortlists,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadNotifications,
        viewers,
        totalViews,
        viewsPremiumRequired,
        shortlists,
      ];
}

class ActivityError extends ActivityState {
  final String message;
  const ActivityError(this.message);
  @override
  List<Object?> get props => [message];
}
