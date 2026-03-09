import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/settings_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;

  SettingsBloc({required SettingsService settingsService})
    : _settingsService = settingsService,
      super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleLocationNotifications>(_onToggleLocationNotifications);
    on<ToggleDarkMode>(_onToggleDarkMode);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final notificationsEnabled = await _settingsService
          .getNotificationsEnabled();
      final locationNotificationsEnabled = await _settingsService
          .getLocationNotificationsEnabled();
      final darkModeEnabled = await _settingsService.getDarkModeEnabled();

      emit(
        state.copyWith(
          status: SettingsStatus.loaded,
          notificationsEnabled: notificationsEnabled,
          locationNotificationsEnabled: locationNotificationsEnabled,
          darkModeEnabled: darkModeEnabled,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setNotificationsEnabled(event.enabled);
      emit(state.copyWith(notificationsEnabled: event.enabled));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleLocationNotifications(
    ToggleLocationNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setLocationNotificationsEnabled(event.enabled);
      emit(state.copyWith(locationNotificationsEnabled: event.enabled));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsService.setDarkModeEnabled(event.enabled);
      emit(state.copyWith(darkModeEnabled: event.enabled));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
