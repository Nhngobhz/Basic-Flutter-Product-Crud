# Nexus App (Frontend)

This repository contains the **frontend** of the Nexus mobile application built with Flutter. The app provides user authentication, profile management, and sample business logic through a clean dark‑themed UI.

---

## Overview

- **Name:** Nexus
- **Platform:** Flutter (iOS, Android, Web, Desktop)
- **Language:** Dart
- **Architecture:** MVC‑like structure with `screens`, `services`, `widgets`, and `style`
- **Theme:** Dark mode by default (custom color scheme defined in `theme.dart`)
- **Device Preview:** Integrated via `device_preview` for responsive testing

The application is intended as an interview test example and demonstrates typical features such as sign in/up, password reset, and API communication.

---

## Features

- Splash screen with branding
- Sign in and sign up flows with form validation
- Forgot password/reset OTP flow
- Home screen placeholder
- Role of services for authentication and API handling
- Responsive layout with dynamic sizing
- Local storage using `shared_preferences`
- Dark color scheme with custom fonts and icons

---

## ⚙️ Prerequisites

1. [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.0)
2. A device/emulator or a browser for web
3. Optional: Android Studio / VS Code with Flutter extension

Run `flutter doctor` to verify your setup.

---

## Getting Started

Clone the repository and fetch dependencies:

```bash
flutter pub get
```

To run the app:

```bash
flutter run            
# (Some Features like scroll down does not work on chrome so use an emulator/real phone to use such features)
```

Device Preview is enabled by default; disable it in `main.dart` before publishing.

---

## Project Structure

```
lib/
├── main.dart              # application entry point
├── api/
│   ├── api_base_url.dart
│   └── api_end_point.dart
├── screens/               # UI pages
│   ├── splash_screen.dart
│   ├── sign_in_screen.dart
│   ├── sign_up_screen.dart
│   ├── forgot_password_screen.dart
│   ├── otp_reset_screen.dart
│   ├── home_screen.dart
│   └── ...
├── services/              # business logic & HTTP calls
│   ├── auth_service.dart
│   └── api_service.dart
├── style/
│   └── theme.dart         # theme configuration
└── widgets/               # reusable widgets
```

- **`main.dart`** initializes the app and configures system UI overlays.
- **`screens`** contain stateful widgets representing each page.
- **`services`** handle API requests and authentication logic; they wrap `http` calls and throw `ApiException` on errors.
- **`style/theme.dart`** defines color scheme, font, and common `TextStyle` helpers.
- **`widgets`** include shared UI components (buttons, text fields, etc.).

---

## API & Authentication

- `api_service.dart` defines a simple wrapper around `http` for making requests.
- `auth_service.dart` provides `login`, `register`, `requestPasswordReset`, and `resetOtp` methods. All responses are validated and throw `ApiException` when the server returns an error.
- Base URLs and endpoints are configurable via `api_base_url.dart` and `api_end_point.dart`.

> Replace placeholder URLs with your backend endpoints when integrating.

---

## Testing

A basic widget test (`widget_test.dart`) verifies that `NexusApp` builds without crashing.
You can run tests with:

```bash
flutter test
```

Extend this with more tests as your application grows.

---

## Styling & Theming

Dark theme is defined in `lib/style/theme.dart`. Customize colors, fonts, and `ColorScheme` there.

Common styling values (padding, font sizes) are computed dynamically in each screen using `MediaQuery` for responsiveness.

---

## Customization Tips

- **Disable Device Preview:** Set `enabled: false` in `main.dart` when shipping a release build.
- **Add new screens:** Create new files under `screens/` and register them with navigation routes or `MaterialPageRoute`.
- **Persist data:** Use `SharedPreferences` (already included) or integrate `hive`/`moor`.

---

## Dependencies

Key packages used:

| Package             | Purpose                          |
|---------------------|----------------------------------|
| `flutter`           | SDK core                        |
| `http`              | REST API calls                  |
| `shared_preferences`| Local key-value storage         |
| `device_preview`    | Layout testing on multiple devices |
| `image_picker`      | Photo picking (used in services) |

---

## Build & Release

Follow Flutter's [official docs](https://docs.flutter.dev/deployment) for building APKs, app bundles, or desktop executables.

---

## License

This code is provided as-is for interview/test purposes. Add your own licensing information if you intend to reuse it.

---

🗿🗿🗿

