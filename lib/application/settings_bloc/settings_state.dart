part of 'settings_bloc.dart';

enum AppMode { parent, child }

@immutable
class SettingsState extends Equatable {
  final AppMode appMode;
  final bool isLocked; // Child mode'un PIN ile kilitli olup olmadığını belirtir
  final String? pin;

  const SettingsState({
    this.appMode = AppMode.parent,
    this.isLocked = false,
    this.pin,
  });

  SettingsState copyWith({
    AppMode? appMode,
    bool? isLocked,
    String? pin,
  }) {
    return SettingsState(
      appMode: appMode ?? this.appMode,
      isLocked: isLocked ?? this.isLocked,
      pin: pin ?? this.pin,
    );
  }

  @override
  List<Object?> get props => [appMode, isLocked, pin];
}