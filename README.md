# Smart Notice Board Admin Panel

A Flutter-based admin panel that lets administrators manage notices, adverts, and posters that appear on Smart Notice Board devices. The panel integrates with Firebase for authentication, data storage, and media uploads.

## Features

- Firebase email/password authentication for admins.
- Real-time list of notices stored in Cloud Firestore.
- Create, update, and delete notices, including optional device targeting metadata.
- Upload poster images to Firebase Storage from mobile, desktop, or web.
- Material 3 interface optimized for tablets and phones.

## Project Structure

```
lib/
├── main.dart                 # App entry point and dependency setup
├── models/
│   └── notice.dart           # Firestore notice model
├── providers/
│   └── auth_provider.dart    # Firebase Auth state handling
├── screens/
│   ├── admin_panel_screen.dart # Main admin experience
│   └── login_screen.dart       # Email/password sign-in screen
├── services/
│   └── content_service.dart  # Firestore and Storage helpers
└── widgets/
    └── add_content_dialog.dart # Form for creating/updating notices
```

## Getting Started

1. **Install Flutter**
   Make sure you have Flutter 3.10 or later installed and configured. Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install) if required.

2. **Configure Firebase**
   - Create a Firebase project from the [Firebase console](https://console.firebase.google.com/).
   - Enable Email/Password authentication.
   - Create a Firestore database (in production or test mode) and a Firebase Storage bucket.
   - Register your Flutter app (Android, iOS, Web, etc.) and download the platform configuration files (`google-services.json`, `GoogleService-Info.plist`, or `firebase_options.dart`).
   - If you prefer using the `firebase_options.dart` approach, run:
     ```bash
     flutterfire configure
     ```
     and import the generated `DefaultFirebaseOptions` inside `main.dart` before calling `Firebase.initializeApp`.

3. **Install Dependencies**
   From the repository root run:
   ```bash
   flutter pub get
   ```

4. **Run the App**
   Start the admin panel on an emulator or physical device:
   ```bash
   flutter run
   ```

5. **Create an Admin User**
   Use the Firebase console or a seed script to create an admin account. Once created, you can sign in through the app using the registered email and password.

## Firestore Data Model

Each notice is stored in the `notices` collection with the following fields:

| Field        | Type      | Description                                             |
|--------------|-----------|---------------------------------------------------------|
| `title`      | `String`  | Headline or name of the notice.                         |
| `description`| `String`  | Supporting text or body of the notice.                  |
| `imageUrl`   | `String`  | HTTPS URL of the poster image in Firebase Storage.      |
| `deviceIds`  | `List`    | Optional array of device identifiers that should render the notice. |
| `timestamp`  | `Timestamp` | Creation/update time, populated automatically.       |

## Next Steps

- Extend the notice model to support scheduling (start/end dates) or rich media (video, PDF).
- Add granular roles/permissions if multiple administrators collaborate.
- Integrate device management screens to control per-device playlists.
- Wire push notifications or email alerts when new content is published.

## License

This project is provided as starter code. Adapt and extend it to match your Smart Notice Board requirements.
