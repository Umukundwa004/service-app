# Technical Report: Data Model, State Management, and Development Trade-offs

## 1) Firestore Database Structure

The app uses Firebase Authentication for identity and Cloud Firestore for application data.

### Collections

- `users`
  - Document ID: Firebase Auth UID (`users/{uid}`)
  - Purpose: stores app-level user profile and preferences alongside Firebase Auth identity
  - Typical fields used by the app:
    - `email` (String)
    - `displayName` (String)
    - `photoUrl` (String)
    - `createdAt` (Timestamp)
    - optional preference fields like `notificationsEnabled` (bool)

- `listings`
  - Document ID: listing ID generated in app and written as `doc(listing.id)`
  - Purpose: stores service/business listings shown on Home, My Listings, and Map views
  - Core fields:
    - `name`, `description`, `category`
    - `address`, `phone`, `email`
    - `imageUrl`
    - `latitude`, `longitude`
    - owner identity: `userId` (primary) and `ownerId` (compatibility)
    - `createdAt`, `updatedAt` (Timestamp)
    - optional metadata: `rating`, `reviewCount`, `openingHours`, `amenities`

### Why this structure

- A `users` collection complements Firebase Auth, allowing app profile details and settings to be managed in Firestore.
- A single `listings` collection keeps listing queries and real-time streams straightforward.
- Writing listings with deterministic document IDs (`doc(id).set(...)`) simplifies update/delete operations and reduces ambiguity when syncing UI state.

## 2) Listing Modeling and Serialization

Listings are represented by `ListingModel` in the app layer.

### Model design

`ListingModel` is intentionally rich enough for both list and detail screens:

- identity: `id`
- content: `name`, `description`, `category`
- contact/location: `address`, `phone`, `email`, `latitude`, `longitude`
- ownership: `userId`
- lifecycle: `createdAt`, `updatedAt`
- quality/enrichment: `rating`, `reviewCount`, `openingHours`, `amenities`

### Serialization strategy

- `fromMap(...)` maps Firestore documents to model instances with null-safe defaults.
- `toMap()` writes timestamps and all fields expected by UI and services.
- Backward compatibility is built in:
  - reading owner from `userId` first, then fallback to `ownerId`
  - writing both `userId` and `ownerId` to avoid breaking older data paths

This compatibility layer was added to prevent “listing exists on Home but not on My Listings” cases caused by inconsistent owner field names in older/newer documents.

## 3) State Management Implementation (BLoC)

The app uses `flutter_bloc` with feature-specific blocs.

### Auth flow (`AuthBloc`)

- Subscribes to Firebase auth state changes.
- Resolves/creates Firestore user profile (`users/{uid}`) as needed.
- Enforces email verification before full authenticated state:
  - `authenticated` only when `emailVerified == true`
  - otherwise emits `emailNotVerified`

This keeps authorization decisions centralized and predictable.

### Listings flow (`ListingBloc`)

- Subscribes to real-time `listings` stream from `ListingService`.
- Holds both raw list (`listings`) and UI-projected list (`filteredListings`).
- Applies local search/category filtering in bloc for responsive UX.
- Handles add/update/delete via service layer methods.

### My Listings flow (`MyListingsBloc`)

- Subscribes to a user-scoped listing stream from service.
- Maintains status + current user-owned listing list.
- Handles CRUD actions using same service methods as global listings.

### Settings flow (`SettingsBloc`)

- Loads persisted settings on screen entry.
- Toggles app notification flags, including location-based notifications.
- Uses local persistence (`SharedPreferences`) for lightweight simulation where backend preference sync is not required.

### Why BLoC here

- Clear separation between UI and business logic.
- Explicit event/state transitions make debugging easier.
- Scales better than ad-hoc `setState` for multi-screen app behavior.

## 4) Design Trade-offs and Technical Challenges

### Challenge A: Email verification and auth state consistency

**Problem:** Users could appear signed in even when unverified if verification wasn’t enforced at all auth entry points.

**Resolution:** Auth checks and sign-in paths were aligned to emit `emailNotVerified` unless Firebase reports verified email.

**Trade-off:** Slightly stricter flow may feel slower for first-time users, but it improves account integrity.

---

### Challenge B: My Listings visibility mismatch

**Problem:** Some created listings appeared on Home but not My Listings.

**Root causes encountered:**

- owner field inconsistency (`userId` vs `ownerId`)
- query/index coupling and timing concerns

**Resolution:**

- model now supports read fallback and dual-write owner fields
- user-specific stream performs client-side filter + sort as a resilience layer

**Trade-off:**

- client-side filtering is robust and index-independent for small/medium datasets
- at larger scale, server-side indexed queries are still preferred for cost/performance

---

### Challenge C: Map pin coverage for incomplete coordinates

**Problem:** Listings lacking valid lat/lng were not represented on map.

**Resolution:** Map view resolves marker points with fallback coordinates so all listings are visible as pins.

**Trade-off:** Fallback coordinates are approximate and primarily UX-oriented; they are not true geocoding.

---

### Challenge D: Settings preference scope

**Problem:** Requirement needed location-notification toggle, but backend integration was optional.

**Resolution:** Implemented local simulation with `SharedPreferences` through `SettingsBloc`.

**Trade-off:**

- fast, offline-friendly, simple implementation
- preference is device-local unless additionally synced to Firestore

## 5) Practical Lessons and Future Improvements

### Lessons learned

- Keep schema naming consistent early (`userId` ownership) to prevent downstream display mismatches.
- Centralize auth gating logic to avoid fragmented verification behavior.
- BLoC + service/repository boundaries simplify fixes because data flow is explicit.

### Future improvements

- Add indexed Firestore query path for My Listings (`where('userId', isEqualTo: uid).orderBy('createdAt')`) and corresponding composite indexes.
- Add migration/cleanup script to normalize legacy owner fields permanently.
- Introduce true geocoding or address validation for accurate map placement.
- Optionally sync settings preferences to `users/{uid}` for cross-device consistency.

---

This report reflects the implemented architecture and the main engineering decisions made during development of this app.
