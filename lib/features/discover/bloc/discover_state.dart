import 'package:equatable/equatable.dart';

abstract class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<Map<String, dynamic>> profiles;
  final bool hasReachedMax;

  const DiscoverLoaded({required this.profiles, this.hasReachedMax = false});

  @override
  List<Object?> get props => [profiles, hasReachedMax];
}

class DiscoverError extends DiscoverState {
  final String message;
  const DiscoverError(this.message);

  @override
  List<Object?> get props => [message];
}
