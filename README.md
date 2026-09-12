# uee_project

## Explore Places API

The Explore screen uses the Rootly backend endpoints at `/api/v1/explore/places`
and `/api/v1/explore/categories`.

The default development URL is `http://localhost:8080` on desktop, iOS simulator,
and web. Android emulators automatically use `http://10.0.2.2:8080`.

For a USB-connected physical Android phone, use the helper below. It forwards the
phone's port 8080 to the computer and supplies the matching API URL to Flutter:

```powershell
.\tool\run_android_phone.ps1 -DeviceId R5CW81K5WPD
```

Alternatively, when the phone and computer are on the same network, override the
backend URL with the computer's current LAN address:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.21:8080
```

Start `Rootly_Backend` before opening Explore. The phone and backend computer must
be on the same network when using a LAN address.
## Google Maps setup

Enable **Maps SDK for Android** and **Places API** in Google Cloud, then run with
the same restricted API key available to the native map and Dart Places client:

```powershell
$env:ORG_GRADLE_PROJECT_GOOGLE_MAPS_API_KEY='YOUR_KEY'
flutter run --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY
```

For a normal Android Studio build, add `GOOGLE_MAPS_API_KEY=YOUR_KEY` to the
user-level Gradle properties file and keep the Dart define in the run config.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
