# 📍 Arrivo

**Never miss your stop again.** Arrivo is a location-based alarm app built with Flutter — set a destination, and get notified the moment you arrive, no matter where you are or what you're doing on your phone.

Applying Flutter, Dart, and Firebase fundamentals to a real-world mobile use case.

---

## ✨ Features

- 🔐 **Secure sign-in** — email/password authentication via Firebase Auth
- 📌 **Save custom alarms** — set a location, name it, and choose a trigger radius
- 🗺️ **Map-based location picking** — tap a spot on the map instead of entering raw coordinates
- 🔔 **Background geofencing** — get notified on arrival even if the app is closed
- ☁️ **Cloud-synced alarms** — your saved locations persist across sessions via Firestore
- ✏️ **Manage alarms** — edit, delete, and toggle alarms active/inactive

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Location services | `geolocator` |
| Maps | `google_maps_flutter` |
| Geofencing | `geofence_service` (background monitoring) |
| Notifications | `flutter_local_notifications` |
| State management | Provider / Riverpod |

---

## 🏗️ Architecture

```
lib/
├── main.dart
├── models/
│   └── alarm.dart              # Alarm data model
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home_screen.dart        # List of saved alarms
│   ├── add_alarm_screen.dart   # Map picker + alarm form
│   └── alarm_detail_screen.dart
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   ├── firestore_service.dart  # CRUD for alarms collection
│   ├── geofence_service.dart   # Background location monitoring
│   └── notification_service.dart
└── providers/
    └── alarm_provider.dart     # App-wide alarm state
```

**Data flow:** User creates an alarm → saved to Firestore under their `userId` → geofencing service registers the location and radius → on entering the radius, a local notification/alarm fires, even if the app isn't in the foreground.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your PATH
- A [Firebase project](https://console.firebase.google.com/) with Authentication and Firestore enabled
- Android Studio / Xcode for running on an emulator or physical device

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/<your-username>/arrivo.git
   cd arrivo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   - Run `flutterfire configure` to link the app to your Firebase project
   - Enable **Email/Password** sign-in under Firebase Authentication
   - Create a Firestore database in test mode (or set up proper security rules — see below)

4. **Add platform permissions**
   - **Android** (`android/app/src/main/AndroidManifest.xml`): add `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, and notification permissions
   - **iOS** (`ios/Runner/Info.plist`): add `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysAndWhenInUseUsageDescription`

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔒 Firestore Security Rules

Alarms should only be readable/writable by the user who created them:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /alarms/{alarmId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 🗺️ Roadmap

- [x] Firebase Authentication (sign up / log in)
- [x] Firestore CRUD for saved alarms
- [ ] Map picker for setting alarm locations
- [ ] Background geofencing + local notification triggers
- [ ] Edit/delete alarm management UI
- [ ] Custom alarm sounds per location
- [ ] iOS background location refinements

---

## 👤 Author

**Boikhethelo Lehata**
Built while studying software engineering at WeThinkCode_.
WTC-47D9AXEL
