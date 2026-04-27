import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

class UpdateSettingsEvent extends ProfileEvent {
  final Map<String, dynamic> settings;
  const UpdateSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}
