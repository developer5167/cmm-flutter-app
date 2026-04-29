import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatusEvent extends OnboardingEvent {}

class SaveStepEvent extends OnboardingEvent {
  final int step;
  final Map<String, dynamic> data;

  const SaveStepEvent(this.step, this.data);

  @override
  List<Object?> get props => [step, data];
}

class UploadPhotoEvent extends OnboardingEvent {
  final String filePath;
  final int index;

  const UploadPhotoEvent(this.filePath, this.index);

  @override
  List<Object?> get props => [filePath, index];
}
