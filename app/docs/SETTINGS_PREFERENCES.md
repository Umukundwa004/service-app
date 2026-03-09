# Settings Preferences

## Persisted preferences
- notifications enabled
- location-based notifications enabled
- dark mode enabled

## Persistence layer
- Local simulation via SharedPreferences.
- Loaded by `SettingsBloc` on screen open.
- Updated immediately when toggles are changed.

## Design trade-off
- Local persistence is fast and simple.
- Preferences are device-specific unless synced to backend later.
