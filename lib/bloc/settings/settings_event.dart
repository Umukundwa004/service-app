import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleNotifications extends SettingsEvent {
  final bool enabled;

  const ToggleNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleLocationNotifications extends SettingsEvent {
  final bool enabled;

  const ToggleLocationNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleDarkMode extends SettingsEvent {
  final bool enabled;

  const ToggleDarkMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
