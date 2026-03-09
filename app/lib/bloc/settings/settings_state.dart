import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final bool notificationsEnabled;
  final bool locationNotificationsEnabled;
  final bool darkModeEnabled;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.notificationsEnabled = true,
    this.locationNotificationsEnabled = true,
    this.darkModeEnabled = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    bool? notificationsEnabled,
    bool? locationNotificationsEnabled,
    bool? darkModeEnabled,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationNotificationsEnabled:
          locationNotificationsEnabled ?? this.locationNotificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notificationsEnabled,
    locationNotificationsEnabled,
    darkModeEnabled,
    errorMessage,
  ];
}
