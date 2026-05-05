import 'package:equatable/equatable.dart';
import 'discover_filters.dart';

abstract class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<Map<String, dynamic>> profiles;
  final bool hasReachedMax;
  final DiscoverFilters activeFilters;
  final List<Map<String, dynamic>> dailyMatches;

  const DiscoverLoaded({
    required this.profiles,
    this.hasReachedMax = false,
    this.activeFilters = const DiscoverFilters(),
    this.dailyMatches = const [],
  });

  DiscoverLoaded copyWith({
    List<Map<String, dynamic>>? profiles,
    bool? hasReachedMax,
    DiscoverFilters? activeFilters,
    List<Map<String, dynamic>>? dailyMatches,
  }) {
    return DiscoverLoaded(
      profiles: profiles ?? this.profiles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      activeFilters: activeFilters ?? this.activeFilters,
      dailyMatches: dailyMatches ?? this.dailyMatches,
    );
  }

  @override
  List<Object?> get props => [profiles, hasReachedMax, activeFilters, dailyMatches];
}

class DiscoverError extends DiscoverState {
  final String message;
  const DiscoverError(this.message);

  @override
  List<Object?> get props => [message];
}
