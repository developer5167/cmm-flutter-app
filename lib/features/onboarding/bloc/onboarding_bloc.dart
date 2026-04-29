import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';
import '../data/onboarding_repository.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingBloc(this._repository) : super(OnboardingInitial()) {
    on<LoadStatusEvent>(_onLoadStatus);
    on<SaveStepEvent>(_onSaveStep);
    on<UploadPhotoEvent>(_onUploadPhoto);
  }

  Future<void> _onLoadStatus(LoadStatusEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    try {
      final status = await _repository.getStatus();
      emit(OnboardingStatusLoaded(status));
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onSaveStep(SaveStepEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    try {
      await _repository.saveStep(event.step, event.data);
      emit(StepSavedSuccess(event.step));
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onUploadPhoto(UploadPhotoEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    try {
      await _repository.uploadPhoto(event.filePath, event.index);
      emit(PhotoUploadedSuccess(event.index));
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
