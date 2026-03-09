import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _locationNotificationsKey =
      'location_notifications_enabled';

  // Get notifications enabled status
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Set notifications enabled status
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  // Get dark mode enabled status
  Future<bool> getDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // Set dark mode enabled status
  Future<void> setDarkModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  // Get location-based notifications enabled
  Future<bool> getLocationNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationNotificationsKey) ?? true;
  }

  // Set location-based notifications enabled
  Future<void> setLocationNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationNotificationsKey, enabled);
  }

  // Clear all settings
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
