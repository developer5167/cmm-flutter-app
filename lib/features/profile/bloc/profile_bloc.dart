import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../data/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<SendInterestEvent>(_onSendInterest);
    on<AcceptInterestEvent>(_onAcceptInterest);
    on<RejectInterestEvent>(_onRejectInterest);
  }

  Future<void> _onAcceptInterest(AcceptInterestEvent event, Emitter<ProfileState> emit) async {
    try {
      await _repository.acceptInterest(event.interestId);
      if (state is ProfileLoaded) {
        final current = state as ProfileLoaded;
        emit(ProfileLoaded({
          ...current.profile,
          'interaction_status': 'accepted'
        }, userId: current.userId));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onRejectInterest(RejectInterestEvent event, Emitter<ProfileState> emit) async {
    try {
      await _repository.rejectInterest(event.interestId);
      if (state is ProfileLoaded) {
        final current = state as ProfileLoaded;
        emit(ProfileLoaded({
          ...current.profile,
          'interaction_status': 'rejected'
        }, userId: current.userId));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onSendInterest(SendInterestEvent event, Emitter<ProfileState> emit) async {
    try {
      await _repository.sendInterest(event.userId, isSuper: event.isSuper);
      // We could emit a specific 'InterestSent' state if needed, 
      // but for now we just refresh or stay on current state.
      if (state is ProfileLoaded) {
        final currentData = (state as ProfileLoaded).profile;
        // Optimization: Update local state to show interest sent
        emit(ProfileLoaded({
          ...currentData,
          'interaction_status': 'sent'
        }));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFetchProfile(FetchProfileEvent event, Emitter<ProfileState> emit) async {
    final silentOwnProfile =
        event.silentRefresh && event.userId == null && state is ProfileLoaded;
    if (!silentOwnProfile) emit(ProfileLoading());
    ProfileLoaded? previous;
    if (state is ProfileLoaded) previous = state as ProfileLoaded;
    try {
      final profile = event.userId != null
          ? await _repository.fetchProfile(event.userId!)
          : await _repository.fetchMyProfile();
      emit(ProfileLoaded(profile, userId: event.userId ?? previous?.userId));
    } catch (e) {
      if (silentOwnProfile && previous != null) {
        emit(previous);
        return;
      }
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(UpdateSettingsEvent event, Emitter<ProfileState> emit) async {
    final previous = state is ProfileLoaded ? state as ProfileLoaded : null;
    try {
      // PUT returns updated settings fields directly — merge them into local state
      // to avoid a second GET /profile/me round-trip.
      final updatedSettings = await _repository.updateSettings(event.settings);
      if (previous != null && updatedSettings.isNotEmpty) {
        final fullData = Map<String, dynamic>.from(previous.profile);
        final profileSection = Map<String, dynamic>.from(
          fullData['profile'] is Map ? fullData['profile'] as Map<String, dynamic> : {},
        );
        profileSection.addAll(updatedSettings);
        fullData['profile'] = profileSection;
        emit(ProfileLoaded(fullData, userId: previous.userId));
      } else {
        add(const FetchProfileEvent(silentRefresh: true));
      }
    } catch (e) {
      if (previous != null) emit(previous);
      else emit(ProfileError(e.toString()));
    }
  }
}
