import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';
import '../data/onboarding_repository.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingBloc(this._repository) : super(OnboardingInitial()) {
    on<LoadStatusEvent>(_onLoadStatus);
    on<SaveStepEvent>(_onSaveStep);
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
      if (event.step == 8) {
        // Deferred photo upload: delete removed photos first, then upload new ones
        final deletedIds = (event.data['_deletedPhotoIds'] as List?)?.cast<String>() ?? [];
        final localPaths = (event.data['_localPhotoPaths'] as List?)?.cast<String>() ?? [];

        for (final id in deletedIds) {
          await _repository.deletePhoto(id);
        }
        await _repository.uploadPhotos(localPaths);
      } else if (event.step == 9) {
        final videoPath = event.data['verification_video_path'] as String?;
        if (videoPath != null && videoPath.isNotEmpty) {
          await _repository.submitIdentityVerification(videoPath);
        } else {
          await _repository.saveStep(event.step, {});
        }
      } else {
        await _repository.saveStep(event.step, event.data);
      }
      emit(StepSavedSuccess(event.step));
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
