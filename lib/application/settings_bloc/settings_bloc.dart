import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const _pinKey = 'parental_control_pin';

  SettingsBloc() : super(const SettingsState()) {
    on<ParentModeEnabled>(_onParentModeEnabled);
    on<ChildModeEnabled>(_onChildModeEnabled);
    on<PinEntered>(_onPinEntered);
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey);
    if (pin != null) {
      emit(state.copyWith(appMode: AppMode.child, isLocked: true, pin: pin));
    }
  }

  void _onParentModeEnabled(ParentModeEnabled event, Emitter<SettingsState> emit) {
    emit(state.copyWith(appMode: AppMode.parent, isLocked: false));
  }

  Future<void> _onChildModeEnabled(ChildModeEnabled event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, event.pin);
    emit(state.copyWith(appMode: AppMode.child, isLocked: true, pin: event.pin));
  }

  void _onPinEntered(PinEntered event, Emitter<SettingsState> emit) {
    if (event.pin == state.pin) {
      emit(state.copyWith(isLocked: false));
    } else {
      // Handle incorrect PIN
    }
  }
}