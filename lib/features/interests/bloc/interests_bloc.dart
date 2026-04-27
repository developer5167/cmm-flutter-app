import 'package:flutter_bloc/flutter_bloc.dart';
import 'interests_event.dart';
import 'interests_state.dart';
import '../data/interests_repository.dart';

class InterestsBloc extends Bloc<InterestsEvent, InterestsState> {
  final InterestsRepository _repository;

  InterestsBloc(this._repository) : super(InterestsInitial()) {
    on<FetchInterestsEvent>(_onFetchInterests);
    on<InterestActionEvent>(_onInterestAction);
  }

  Future<void> _onFetchInterests(FetchInterestsEvent event, Emitter<InterestsState> emit) async {
    emit(InterestsLoading());
    try {
      final data = await _repository.fetchInterests();
      emit(InterestsLoaded(
        received: data['received']!,
        matches: data['matches']!,
        sent: data['sent']!,
      ));
    } catch (e) {
      emit(InterestsError(e.toString()));
    }
  }

  Future<void> _onInterestAction(InterestActionEvent event, Emitter<InterestsState> emit) async {
    try {
      await _repository.handleAction(event.interestId, accept: event.accept);
      // Re-fetch to update lists
      add(FetchInterestsEvent());
    } catch (e) {
      emit(InterestsError(e.toString()));
    }
  }
}
