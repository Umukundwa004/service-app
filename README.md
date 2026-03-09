# Kigali City Directory

A Flutter mobile application for discovering and managing places in Kigali, Rwanda which is built with Firebase Authentication, Cloud Firestore, Provider state management, and OpenStreetMap integration.

# demo video:

---

## Features

- **Firebase Authentication** used to Signup, login, logout with email verification
- **Location Listings (CRUD)** used for Creating, reading, updating, and deleting place listings
- **Search & Filter** used to Search by name, filter by category in real-time
- **Interactive Map** using OpenStreetMap with markers for all listings
- **Listing Detail** used for Embedded map preview + Google Maps navigation launch
- **My Listings** used for View and manage only your own listings
- **Settings** used for User profile to display, notification toggles, dark/light theme
- **Real-time Firestore** used for all changes reflect instantly across screens

---

## Firebase Setup

### Prerequisites

- Flutter SDK 3.10.4+
- Firebase project: `kigali-city`
- Android: `google-services.json` in `android/app/`

### Firebase Services Used

| Service                 | Purpose                                                  |
| ----------------------- | -------------------------------------------------------- |
| Firebase Authentication | Email/password signup, login, logout, email verification |
| Cloud Firestore         | Real-time database for place listings and user profiles  |

### Authentication Setup

1. Firebase Console -> Authentication -> Sign-in method -> Enable **Email/Password**
2. Email verification is enforced so that users cannot access the app until email is verified

### Firestore Setup

1. Firebase Console -> Firestore Database -> Create database
2. Security Rules:

```
rules_version = '2';
service cloud.firestore {
   match /databases/{database}/documents {
      match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /places/{placeId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null
            && request.auth.uid == resource.data.userId;
      }
   }
}
```

---

## Firestore Database Structure

### Collection: `users`

```
users/
   {uid}/
      uid: string
      email: string
      displayName: string
      createdAt: timestamp
```

### Collection: `places`

```
places/
   {docId}/
      name: string
      category: string        // Hospital, Cafe, Restaurant, etc.
      address: string
      contact: string
      description: string
      latitude: number
      longitude: number
      userId: string          // UID of the creator
      timestamp: timestamp
```

---

## State Management - Provider

The app uses the **Provider** package for state management with a strict separation of concerns:

```
UI Widgets
      ↓  (reads state via Provider.of / Consumer)
Providers  (AuthProvider, PlaceProvider)
      ↓  (calls methods on)
Services   (AuthService, FirestoreService)
      ↓  (communicates with)
Firebase   (FirebaseAuth, FirebaseFirestore)
```

| Provider          | Responsibility                                  |
| ----------------- | ----------------------------------------------- |
| `AuthProvider`    | Holds current user, exposes login/signup/logout |
| `PlaceProvider`   | Exposes place stream, add/update/delete methods |
| `ThemeProvider`   | Light/dark theme switching                      |
| `BookingProvider` | Booking state management                        |

**UI widgets never call Firebase directly** so all Firebase operations go through the service layer.

---

## Navigation Structure

```
AuthWrapper
├── LoginScreen         (if not logged in)
├── EmailVerificationScreen  (if logged in but not verified)
└── MainNavigationScreen    (if fully authenticated)
         ├── Tab 0: PlacesListScreen    (Directory)
         ├── Tab 1: MyListingsScreen    (My Listings)
         ├── Tab 2: BookingsScreen      (Bookings)
         ├── Tab 3: MapScreen           (Map View)
         └── Tab 4: SettingsScreen      (Settings)
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/h-mutumwinka/Kigali_Directory.git
cd Kigali_Directory
cd kigali_city_directory

# Install dependencies
flutter pub get

# Run on Android
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                     # App entry point, Firebase init, MultiProvider
├── firebase_options.dart         # Firebase configuration per platform
├── models/
│   ├── place_model.dart          # Place data model + Firestore serialization
│   ├── user_model.dart           # UserProfile model
│   └── booking_model.dart        # Booking model
├── providers/
│   ├── auth_provider.dart        # Authentication state
│   ├── place_provider.dart       # Place listings state
│   ├── booking_provider.dart     # Bookings state
│   └── theme_provider.dart       # Theme state
├── services/
│   ├── auth_service.dart         # Firebase Auth operations
│   ├── firestore_service.dart    # Firestore CRUD + seed data
│   ├── user_service.dart         # User profile Firestore operations
│   └── booking_service.dart      # Booking Firestore operations
├── screens/
│   ├── auth_wrapper.dart         # Auth state router
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── email_verification_screen.dart
│   ├── navigation_screen.dart    # BottomNavigationBar
│   ├── place_list_screen.dart    # Directory (search + filter)
│   ├── my_listing_screen.dart    # User's own listings
│   ├── create_place_screen.dart  # Add new listing
│   ├── edit_place_screen.dart    # Edit listing
│   ├── listing_detail_screen.dart # Detail + embedded map
│   ├── screen_map.dart           # Full map with all markers
│   └── settings_screen.dart      # Profile + preferences
└── widgets/
      └── listing_cards.dart        # Reusable place card widget
```

---

## Dependencies

```yaml
firebase_core: ^3.15.2
firebase_auth: ^5.3.1
cloud_firestore: ^5.6.12
provider: ^6.1.2
flutter_map: ^7.0.2
latlong2: ^0.9.1
url_launcher: ^6.3.0
```
