# uee_project

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
