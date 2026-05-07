# BloodLink App

A robust Flutter application for connecting blood donors with those in need. This project features a multi-role architecture (Donor, Hospital, Blood Bank) and real-time Firebase integration.

## 🚀 Getting Started

To get this project running on your local machine, follow these steps:

### 1. Prerequisites
Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- [Dart SDK](https://dart.dev/get-started/sdk)
- [Android Studio](https://developer.android.com/studio) / [Xcode](https://developer.apple.com/xcode/) (for mobile development)

### 2. Environment Consistency 🛠️
To ensure this project runs exactly as it does on the developer's machine, we have pinned the following versions:
- **Flutter**: `3.41.7` (Specified in `.fvm/fvm_config.json`)
- **Dart**: `^3.11.5` (Specified in `pubspec.yaml`)

**Recommendation**: Use [FVM (Flutter Version Management)](https://fvm.app/) to automatically handle these versions.
1. Install FVM: `dart pub global activate fvm`
2. Use the pinned version: `fvm use`
3. Run all commands with `fvm` prefix (e.g., `fvm flutter run`).

---
> [!TIP]
> **All subsequent commands assume you are using FVM.** If you choose not to use FVM, simply remove the `fvm` prefix from the commands below.

### 3. Setup
Clone the repository and navigate to the project directory:
```bash
git clone <repository-url>
cd bloodLinkapp
```

Install dependencies:
```bash
fvm flutter pub get
```

### 4. Firebase Configuration 🔐
Since sensitive configuration files are ignored by Git, you must re-configure Firebase for your local environment:

1. **Install Firebase CLI**:
   ```bash
   curl -sL https://firebase.tools | upgrade=true bash
   firebase login
   ```

2. **Activate FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. **Configure Project**:
   Run the following command and select your Firebase project. This will regenerate `lib/core/firebase_options.dart` and the necessary platform-specific files:
   ```bash
   flutterfire configure
   ```

### 5. Running the App
Check for any setup issues:
```bash
fvm flutter doctor
```

Run the application:
```bash
fvm flutter run
```

---

## 🛠 Troubleshooting

- **Version Mismatch**: If you see errors related to package versions, run `fvm flutter pub upgrade`.
- **CocoaPods (iOS)**: If building for iOS, ensure you run `pod install` in the `ios` directory.
- **Android SDK**: If the Android build fails, ensure your `local.properties` file points to the correct Android SDK path.

## 📄 License
This project is for internal use/development. Refer to the project owners for licensing details.
