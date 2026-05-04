import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {
  final String? userId;

  /// When true, skips [ProfileLoading] and keeps UI stable (e.g. after settings save).
  final bool silentRefresh;
  const FetchProfileEvent({this.userId, this.silentRefresh = false});

  @override
  List<Object?> get props => [userId, silentRefresh];
}

class SendInterestEvent extends ProfileEvent {
  final String userId;
  final bool isSuper;
  const SendInterestEvent({required this.userId, this.isSuper = false});

  @override
  List<Object?> get props => [userId, isSuper];
}

class UpdateSettingsEvent extends ProfileEvent {
  final Map<String, dynamic> settings;
  const UpdateSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class AcceptInterestEvent extends ProfileEvent {
  final String interestId;
  const AcceptInterestEvent(this.interestId);

  @override
  List<Object?> get props => [interestId];
}

class RejectInterestEvent extends ProfileEvent {
  final String interestId;
  const RejectInterestEvent(this.interestId);

  @override
  List<Object?> get props => [interestId];
}
