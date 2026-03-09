# Kigali City Services Directory

A Flutter mobile app for discovering and managing services in Kigali, Rwanda.
The project uses Firebase Authentication, Cloud Firestore, `flutter_bloc` state management, and OpenStreetMap via `flutter_map`.

# demo video:

## https://youtu.be/N8-GWywYkjo

## Features

- **Firebase Authentication**: Sign up, login, logout, and enforced email verification
- **Listings CRUD**: Create, read, update, and delete service listings in Firestore
- **Search and Category Filtering**: Real-time filtering by query and category
- **Interactive Map**: OpenStreetMap markers for all available listings
- **Listing Detail**: Detail page with embedded map and navigation handoff
- **My Listings**: Manage only listings created by the signed-in user
- **Settings and Profile**: Profile editing, notification toggles, and light/dark theme
- **Real-time Firestore Updates**: Stream-based UI updates across screens

---

## Firebase Setup

### Prerequisites

- Flutter SDK `^3.10.4`
- A Firebase project connected to this app
- Android config file: `android/app/google-services.json`
- iOS config file: `ios/Runner/GoogleService-Info.plist` (if iOS is used)

### Firebase Services Used

| Service                 | Purpose                                                   |
| ----------------------- | --------------------------------------------------------- |
| Firebase Authentication | Email/password sign up, login, logout, email verification |
| Cloud Firestore         | Real-time storage for users and listings                  |

### Authentication Setup

1. Firebase Console -> Authentication -> Sign-in method
2. Enable **Email/Password**
3. Keep **email verification** enabled in app flow before full access

### Firestore Setup

1. Firebase Console -> Firestore Database -> Create database
2. Suggested security rules:

```javascript
rules_version = '2';
service cloud.firestore {
   match /databases/{database}/documents {
      match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /listings/{listingId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null && (
            resource.data.userId == request.auth.uid ||
            resource.data.ownerId == request.auth.uid
         );
      }
   }
}
```

---

## Firestore Database Structure

### Collection: `users`

```text
users/
   {uid}/
      email: string
      displayName: string
      photoUrl: string
      createdAt: timestamp
      notificationsEnabled: bool
```

### Collection: `listings`

```text
listings/
   {listingId}/
      name: string
      description: string
      category: string
      address: string
      phone: string
      email: string
      imageUrl: string
      latitude: number
      longitude: number
      userId: string
      ownerId: string
      createdAt: timestamp
      updatedAt: timestamp
      openingHours: string
      amenities: string[]
```

---

## State Management - BLoC

The app uses **BLoC** (`flutter_bloc`) with a service layer.

```text
UI Screens/Widgets
      -> BLoC (events/states)
      -> Services
      -> Firebase (Auth + Firestore)
```

| BLoC             | Responsibility                                                |
| ---------------- | ------------------------------------------------------------- |
| `AuthBloc`       | Session checks, login/signup/logout, email verification flow  |
| `ListingBloc`    | Public listings stream, search, category filtering, selection |
| `MyListingsBloc` | User-scoped listing stream and listing CRUD actions           |
| `SettingsBloc`   | Theme mode and settings toggles persistence                   |

---

## Navigation Structure

```text
AuthWrapper
├── LoginScreen                    (unauthenticated)
├── EmailVerificationScreen        (authenticated but not verified)
└── MainShell                      (authenticated + verified)
      ├── Tab 0: DirectoryScreen
      ├── Tab 1: MyListingsScreen
      ├── Tab 2: MapViewScreen
      └── Tab 3: SettingsScreen

Additional routes:
- ListingDetailScreen
- AddEditListingScreen
- NavigationMapScreen
- ProfileScreen
```

---

## Installation

```bash
# Open project
cd service-app

# Install dependencies
flutter pub get

# Run app
flutter run
```

---

## Project Structure

```text
lib/
├── main.dart
├── firebase_options.dart
├── bloc/
│   ├── auth/
│   ├── listing/
│   ├── my_listings/
│   └── settings/
├── models/
│   ├── user_model.dart
│   ├── listing_model.dart
│   ├── category_model.dart
│   ├── favorite_model.dart
│   └── review_model.dart
├── services/
│   ├── auth_service.dart
│   ├── listing_service.dart
│   ├── settings_service.dart
│   ├── favorite_service.dart
│   └── review_service.dart
├── screens/
│   ├── auth_wrapper.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── email_verification_screen.dart
│   ├── main_shell.dart
│   ├── directory_screen.dart
│   ├── my_listings_screen.dart
│   ├── add_edit_listing_screen.dart
│   ├── listing_detail_screen.dart
│   ├── map_view_screen.dart
│   ├── navigation_map_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── booking_screen.dart
│   ├── review_screen.dart
│   └── detail_page.dart
├── widgets/
│   ├── listing_card.dart
│   ├── category_chip.dart
│   └── search_bar_widget.dart
├── domain/
├── data/
└── utils/
```

---

## Dependencies

```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.3.4
cloud_firestore: ^5.6.0
flutter_bloc: ^9.0.0
equatable: ^2.0.7
flutter_map: ^8.2.1
latlong2: ^0.9.1
url_launcher: ^6.3.1
geolocator: ^13.0.2
shared_preferences: ^2.3.4
uuid: ^4.5.1
```
