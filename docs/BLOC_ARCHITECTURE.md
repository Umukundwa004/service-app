# BLoC Architecture Overview

## Blocs in the app

### AuthBloc

- Handles sign in, sign up, sign out, auth checks.
- Subscribes to Firebase auth state changes.
- Enforces email verification before full authenticated state.

### ListingBloc

- Subscribes to all listings stream.
- Maintains raw listings and filtered listings.
- Applies search and category filters.

### MyListingsBloc

- Subscribes to user-scoped listings stream.
- Supports add/update/delete for owned listings.

### SettingsBloc

- Loads and persists local preferences.
- Handles notification/location/dark mode toggles.

## Design rationale

- Keeps UI widgets lean.
- Centralizes business rules and error states.
- Makes feature behavior easier to test and debug.
