import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class StepSavedSuccess extends OnboardingState {
  final int step;
  const StepSavedSuccess(this.step);

  @override
  List<Object?> get props => [step];
}

class PhotoUploadedSuccess extends OnboardingState {
  final int index;
  const PhotoUploadedSuccess(this.index);

  @override
  List<Object?> get props => [index];
}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
