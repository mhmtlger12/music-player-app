part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class ParentModeEnabled extends SettingsEvent {}

class ChildModeEnabled extends SettingsEvent {
  final String pin;
  const ChildModeEnabled({required this.pin});

  @override
  List<Object> get props => [pin];
}

class PinEntered extends SettingsEvent {
  final String pin;
  const PinEntered({required this.pin});

  @override
  List<Object> get props => [pin];
}