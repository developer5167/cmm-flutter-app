import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingStatusLoaded extends OnboardingState {
  final Map<String, dynamic> data;
  const OnboardingStatusLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class StepSavedSuccess extends OnboardingState {
  final int step;
  const StepSavedSuccess(this.step);

  @override
  List<Object?> get props => [step];
}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
