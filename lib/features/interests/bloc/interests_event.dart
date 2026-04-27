import 'package:equatable/equatable.dart';

abstract class InterestsEvent extends Equatable {
  const InterestsEvent();

  @override
  List<Object?> get props => [];
}

class FetchInterestsEvent extends InterestsEvent {}

class InterestActionEvent extends InterestsEvent {
  final String interestId;
  final bool accept;
  const InterestActionEvent({required this.interestId, required this.accept});

  @override
  List<Object?> get props => [interestId, accept];
}
