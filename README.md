# GeoBadge

GeoBadge is a Flutter-based attendance app built to reduce buddy punching and streamline field check-ins using geofencing, QR scanning, and face-based verification.

## What It Does

- Secure login and one-time onboarding flow
- QR-based site check-in
- GPS validation before check-in submission
- Face verification and passive liveness signals
- Local check-in history for quick audit visibility
- Haptic feedback and status messaging for fast user response

## Tech Stack

- Flutter / Dart
- `camera`
- `mobile_scanner`
- `google_mlkit_face_detection`
- `geolocator`
- `flutter_secure_storage`
- `shared_preferences`
- `http`

## Prerequisites

- Flutter SDK (stable)
- Android Studio or VS Code with Flutter tooling
- Android device or emulator (camera + location support recommended)

## Getting Started

```bash
git clone https://github.com/zariffromlatif/GeoBadge.git
cd geobadge
flutter pub get
flutter run
```

## Backend Configuration

The API base URL is configured in `lib/core/constants.dart`.

Default:

```dart
static const String baseUrl = "https://geobadge-hub.onrender.com";
```

For local backend development, update this value to your local server URL.

## Core Flow

1. User logs in with employee credentials.
2. App stores setup state in secure storage.
3. User scans a site QR code.
4. App checks GPS service + permissions and fetches live coordinates.
5. App posts check-in payload to backend.
6. App stores successful entries in local history.

## Project Structure

- `lib/core`: constants and shared utilities
- `lib/services`: API and storage service layer
- `lib/models`: data models
- `assets`: model and media assets

## Notes

- This project is currently optimized for Android testing.
- Ensure camera and location permissions are granted before check-in.
