import 'package:equatable/equatable.dart';

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeedEvent extends DiscoverEvent {
  final int page;
  const FetchFeedEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
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
