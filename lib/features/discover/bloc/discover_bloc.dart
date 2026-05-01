import 'package:flutter_bloc/flutter_bloc.dart';
import 'discover_event.dart';
import 'discover_state.dart';
import '../data/discover_repository.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final DiscoverRepository _repository;
  int _currentPage = 1;

  DiscoverBloc(this._repository) : super(DiscoverInitial()) {
    on<FetchFeedEvent>(_onFetchFeed);
    on<SwipeProfileEvent>(_onSwipeProfile);
  }

  Future<void> _onFetchFeed(FetchFeedEvent event, Emitter<DiscoverState> emit) async {
    if (state is DiscoverInitial) emit(DiscoverLoading());
    try {
      _currentPage = event.page;
      final profiles = await _repository.fetchFeed(page: _currentPage);
      emit(DiscoverLoaded(
        profiles: profiles,
        hasReachedMax: profiles.length < 10,
      ));
    } catch (e) {
      emit(DiscoverError(e.toString()));
    }
  }

  Future<void> _onSwipeProfile(SwipeProfileEvent event, Emitter<DiscoverState> emit) async {
    try {
      if (event.isInterest) {
        await _repository.sendInterest(event.targetUserId, isSuperInterest: event.isSuperInterest);
      } else {
        await _repository.passProfile(event.targetUserId);
      }
    } catch (e) {
      // Swipes shouldn't interrupt the feed, but we should log errors for debugging
      print('Swipe Error: $e');
    }
  }
}
