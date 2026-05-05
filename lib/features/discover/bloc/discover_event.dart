import 'package:equatable/equatable.dart';
import 'discover_filters.dart';

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeedEvent extends DiscoverEvent {
  final int page;
  final DiscoverFilters? filters;
  const FetchFeedEvent({this.page = 1, this.filters});

  @override
  List<Object?> get props => [page, filters];
}

class FetchDailyMatchesEvent extends DiscoverEvent {
  const FetchDailyMatchesEvent();
}

class SwipeProfileEvent extends DiscoverEvent {
  final String targetUserId;
  final bool isInterest;
  final bool isSuperInterest;

  const SwipeProfileEvent({
    required this.targetUserId,
    required this.isInterest,
    this.isSuperInterest = false,
  });

  @override
  List<Object?> get props => [targetUserId, isInterest, isSuperInterest];
}
