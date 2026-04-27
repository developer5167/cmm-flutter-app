import 'package:equatable/equatable.dart';

abstract class InterestsState extends Equatable {
  const InterestsState();

  @override
  List<Object?> get props => [];
}

class InterestsInitial extends InterestsState {}

class InterestsLoading extends InterestsState {}

class InterestsLoaded extends InterestsState {
  final List<Map<String, dynamic>> received;
  final List<Map<String, dynamic>> matches;
  final List<Map<String, dynamic>> sent;

  const InterestsLoaded({
    required this.received,
    required this.matches,
    required this.sent,
  });

  @override
  List<Object?> get props => [received, matches, sent];
}

class InterestsError extends InterestsState {
  final String message;
  const InterestsError(this.message);

  @override
  List<Object?> get props => [message];
}
