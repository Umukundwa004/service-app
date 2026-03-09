# Authentication and Verification Flow

## Sign up

1. User registers with email and password.
2. Profile document is created in `users/{uid}`.
3. Verification email is sent via Firebase Auth templates.
4. App emits `emailNotVerified` until verification is complete.

## Sign in

1. Credentials are validated by Firebase Auth.
2. App resolves user profile from Firestore.
3. Verified users enter authenticated state.
4. Unverified users remain in verification-required state.

## Why this flow

- Prevents access before email ownership is confirmed.
- Keeps auth gating consistent across app restarts.
