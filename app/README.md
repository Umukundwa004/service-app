# Kigali City Services App

Flutter app using Firebase Authentication with built-in email verification.

## Project Documentation

- Technical architecture and development notes: `TECHNICAL_REPORT.md`

## Firebase Email Verification Setup

Use Firebase built-in email service (no custom SMTP needed).

1. In Firebase Console, open **Authentication** > **Sign-in method**.
2. Enable **Email/Password** provider.
3. In **Authentication** > **Settings** > **Authorized domains**, add:
   - `localhost` (for web local testing)
   - your deployed web domain (if applicable)
4. In **Authentication** > **Templates**, customize verification email text if needed.
5. Keep **SMTP settings disabled** unless you have your own mail server.

## How It Works In This App

- During sign up, the app creates the account and sends a Firebase verification email.
- Unverified users are routed to the verification screen.
- The app periodically reloads auth state and allows access only after `emailVerified` is true.

## Run

```bash
flutter pub get
flutter run
```

## Web Map API Note

If you run on web, replace `YOUR_API_KEY` in `web/index.html` with a valid Google Maps JavaScript API key.
