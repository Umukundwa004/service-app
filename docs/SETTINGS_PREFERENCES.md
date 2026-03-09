# Settings Preferences

## Current persisted settings

- Push notifications toggle
- Location-based notifications toggle
- Dark mode toggle

## Persistence mechanism

- Preferences are stored with `SharedPreferences`.
- `SettingsBloc` loads values on screen entry using `LoadSettings`.
- Each toggle dispatches an event and persists immediately.

## Why local simulation

- Meets feature requirements without backend complexity.
- Works offline and keeps settings interactions fast.

## Future extension

- Sync these values to `users/{uid}` for cross-device consistency.
