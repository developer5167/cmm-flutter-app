import 'package:flutter_bloc/flutter_bloc.dart';
import 'activity_event.dart';
import 'activity_state.dart';
import '../data/activity_repository.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _repository;

  ActivityBloc(this._repository) : super(ActivityInitial()) {
    on<FetchActivityEvent>(_onFetchAll);
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<FetchViewsEvent>(_onFetchViews);
    on<FetchShortlistsEvent>(_onFetchShortlists);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<MarkOneReadEvent>(_onMarkOneRead);
    on<ToggleShortlistEvent>(_onToggleShortlist);
  }

  // ── Fetch everything in parallel ───────────────────────────
  Future<void> _onFetchAll(FetchActivityEvent event, Emitter<ActivityState> emit) async {
    emit(ActivityLoading());
    try {
      final results = await Future.wait([
        _repository.fetchNotifications(),
        _repository.fetchViews(),
        _repository.fetchShortlists(),
      ]);

      final notifData = results[0];
      final viewsData = results[1];
      final shortData = results[2];

      emit(ActivityLoaded(
        notifications: _asList(notifData['notifications']),
        unreadNotifications: (notifData['unread_count'] as num?)?.toInt() ?? 0,
        viewers: _asList(viewsData['viewers']),
        totalViews: (viewsData['total_views'] as num?)?.toInt() ?? 0,
        viewsPremiumRequired: viewsData['is_premium_required'] == true,
        shortlists: _asList(shortData['profiles']),
      ));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onFetchNotifications(FetchNotificationsEvent event, Emitter<ActivityState> emit) async {
    final prev = state is ActivityLoaded ? state as ActivityLoaded : null;
    try {
      final data = await _repository.fetchNotifications();
      final next = ActivityLoaded(
        notifications: _asList(data['notifications']),
        unreadNotifications: (data['unread_count'] as num?)?.toInt() ?? 0,
        viewers: prev?.viewers ?? [],
        totalViews: prev?.totalViews ?? 0,
        viewsPremiumRequired: prev?.viewsPremiumRequired ?? false,
        shortlists: prev?.shortlists ?? [],
      );
      emit(next);
    } catch (e) {
      if (prev != null) emit(prev);
      else emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onFetchViews(FetchViewsEvent event, Emitter<ActivityState> emit) async {
    final prev = state is ActivityLoaded ? state as ActivityLoaded : null;
    try {
      final data = await _repository.fetchViews();
      final next = (prev ?? const ActivityLoaded()).copyWith(
        viewers: _asList(data['viewers']),
        totalViews: (data['total_views'] as num?)?.toInt() ?? 0,
        viewsPremiumRequired: data['is_premium_required'] == true,
      );
      emit(next);
    } catch (e) {
      if (prev != null) emit(prev);
      else emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onFetchShortlists(FetchShortlistsEvent event, Emitter<ActivityState> emit) async {
    final prev = state is ActivityLoaded ? state as ActivityLoaded : null;
    try {
      final data = await _repository.fetchShortlists();
      final next = (prev ?? const ActivityLoaded()).copyWith(
        shortlists: _asList(data['profiles']),
      );
      emit(next);
    } catch (e) {
      if (prev != null) emit(prev);
      else emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onMarkAllRead(MarkAllReadEvent event, Emitter<ActivityState> emit) async {
    final prev = state is ActivityLoaded ? state as ActivityLoaded : null;
    try {
      await _repository.markAllRead();
      if (prev != null) {
        final updated = prev.notifications.map((n) {
          return {...n, 'is_read': true};
        }).toList();
        emit(prev.copyWith(notifications: updated, unreadNotifications: 0));
      }
    } catch (_) {}
  }

  Future<void> _onMarkOneRead(MarkOneReadEvent event, Emitter<ActivityState> emit) async {
    final prev = state is ActivityLoaded ? state as ActivityLoaded : null;
    if (prev == null) return;
    try {
      await _repository.markOneRead(event.notificationId);
      final updated = prev.notifications.map((n) {
        if (n['id'] == event.notificationId) return {...n, 'is_read': true};
        return n;
      }).toList();
      final unread = updated.where((n) => n['is_read'] != true).length;
      emit(prev.copyWith(notifications: updated, unreadNotifications: unread));
    } catch (_) {}
  }

  Future<void> _onToggleShortlist(ToggleShortlistEvent event, Emitter<ActivityState> emit) async {
    final prev = state is ActivityLoaded ? state as ActivityLoaded : null;
    try {
      await _repository.toggleShortlist(event.targetUserId);
      // Refresh shortlist
      add(const FetchShortlistsEvent());
    } catch (e) {
      if (prev != null) emit(prev);
    }
  }

  List<Map<String, dynamic>> _asList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}
