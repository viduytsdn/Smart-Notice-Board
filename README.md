# Smart Notice Board Admin Panel

This repository contains a Flutter-only prototype of the Smart Notice Board admin experience. It focuses on the user interface and interaction design so you can explore the admin flow without setting up Firebase or any other backend services.

## Highlights

- 📋 **Notice management dashboard** – browse sample content in either a list or responsive grid view.
- ➕ **Create & edit dialogs** – add new notices or tweak existing ones with a compact Material 3 form.
- 🎯 **Device targeting chips** – quickly visualise which displays will receive a notice.
- 🔐 **Mock authentication** – sign in with demo credentials (`admin@smartboard.app` / `password123`) to simulate an admin login.

## Project Structure

```
lib/
├── main.dart                     # App entry point and provider wiring
├── models/
│   └── notice.dart               # Lightweight notice model
├── providers/
│   ├── auth_provider.dart        # Mock authentication state
│   └── content_provider.dart     # In-memory notice catalogue
├── screens/
│   ├── admin_panel_screen.dart   # Dashboard UI with list/grid layouts
│   └── login_screen.dart         # Email/password sign-in form
└── widgets/
    └── add_content_dialog.dart   # Modal used for creating or editing notices
```

## Getting Started

1. **Install Flutter** – Ensure Flutter 3.10 (or newer) is configured on your machine. Follow the [official installation guide](https://docs.flutter.dev/get-started/install) if needed.
2. **Fetch packages** – From the repo root run:
   ```bash
   flutter pub get
   ```
3. **Launch the prototype** –
   ```bash
   flutter run
   ```
4. **Sign in** – When prompted, use the demo credentials above to unlock the admin panel. All data lives in memory, so restarting the app resets it.

## Customising the UI

- Update the seed notices in `lib/providers/content_provider.dart` to match your project branding.
- Tweak the layouts inside `lib/screens/admin_panel_screen.dart` to experiment with tablet/desktop breakpoints.
- Expand the `Notice` model (`lib/models/notice.dart`) with additional fields such as schedules or tags, then surface them in the dialog and cards.

## Next Steps

When you are ready to connect the UI to a backend (Firebase, REST API, Supabase, etc.), replace the mock providers with real data sources. The separation between models, providers, and widgets in this prototype should make that transition straightforward.

Happy building!
