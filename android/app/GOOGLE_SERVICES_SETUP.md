# google-services.json — REQUIRED for Google Sign-In on Android

## What to do:

1. Go to the [Firebase Console](https://console.firebase.google.com/) OR [Google Cloud Console](https://console.cloud.google.com/)

### Option A — Firebase Console (Recommended, easiest)
1. Create a new Firebase project (or use an existing one linked to your Google Cloud project)
2. Click **"Add app"** → choose **Android**
3. Enter the package name: `com.example.uee_project`
4. To get the SHA-1 fingerprint, run this in your terminal:
   ```
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   Copy the **SHA-1** value and paste it into Firebase
5. Click **"Register app"**
6. Download the `google-services.json` file
7. **Place the file here**: `android/app/google-services.json`

### Option B — Google Cloud Console Only
If you don't want to use Firebase:
1. Go to [Google Cloud Console](https://console.cloud.google.com/) → **APIs & Services → Credentials**
2. Create an OAuth 2.0 Client ID for **Android**:
   - Package: `com.example.uee_project`
   - SHA-1: (from the keytool command above)
3. Create one for **Web application** — this Client ID goes into `application.properties` → `google.client.id`
4. You still need a `google-services.json`. The simplest way is to use Firebase Console with the same Google Cloud project.

## After placing google-services.json:

Update the Flutter `auth_service.dart`:
```dart
// Replace these placeholders:
static const String _webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
```

Update the Spring Boot `application.properties`:
```properties
# Replace this:
google.client.id=${GOOGLE_CLIENT_ID:YOUR_GOOGLE_WEB_CLIENT_ID_HERE}
# With your actual Web Client ID:
google.client.id=123456789-abc.apps.googleusercontent.com
```
