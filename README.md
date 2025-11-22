# JSON-Driven Video Player App

A Flutter application that plays videos based on JSON instructions with automatic change detection and offline persistence using GetX state management and clean architecture.

## Features

- **JSON-Driven Playback**: Define video playlists via JSON configuration
- **Automatic Change Detection**: Detects and reloads JSON changes automatically
- **Offline Persistence**: Caches instructions locally for offline playback
- **Error Recovery**: Automatically skips failed videos and continues playback
- **Performance Optimized**: Uses Dart isolates for JSON parsing to prevent UI freezing
- **Clean Architecture**: Domain, Data, and Presentation layers with GetX

---

## How JSON Change Detection Works

### 1. **Initial Load Flow**
\`\`\`
App Start → Load from Assets → Parse JSON → Build Playlist → Start Playback
\`\`\`

The app loads `assets/video_instructions.json` on startup and extracts all video instructions from the `update_schedule` type entries.

### 2. **Persistence Strategy**

**Storage Locations:**
- **Assets**: `assets/video_instructions.json` (bundled with app)
- **Local Storage**: `ApplicationDocumentsDirectory/video_instructions.json` (created at runtime)

**How Persistence Works:**
1. App first tries to load from assets
2. If successful, it saves a copy to local storage using `path_provider`
3. On next app launch, if assets fail to load, it uses the cached version from local storage
4. This ensures the app continues working even if the JSON file is removed from assets


## Android Build & Run Instructions

### Prerequisites

- **Flutter SDK** (version 3.0.0 or higher)
- **Android Studio** with Android SDK (API 21+)
- **Device or Emulator** running Android 5.0+
- **Video files** placed in `assets/videos/ads/`

### Step 1: Setup Flutter

\`\`\`bash
# Check Flutter installation
flutter --version

# Get all dependencies
flutter pub get

# Check for setup issues
flutter doctor
\`\`\`

### Step 2: Prepare Android Environment

\`\`\`bash
# Accept Android licenses
flutter doctor --android-licenses

# Verify Android SDK
flutter doctor -v
\`\`\`

### Step 3: Build for Android

#### **Option A: Development Build (Fastest)**
\`\`\`bash
# Run on connected device or emulator
flutter run -v

# Or specify device
flutter run -d <device-id> -v
\`\`\`

#### **Option B: Debug APK**
\`\`\`bash
# Build debug APK
flutter build apk --debug

# APK location: build/app/outputs/flutter-apk/app-debug.apk
\`\`\`

#### **Option C: Release APK**
\`\`\`bash
# Build optimized release APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
\`\`\`

#### **Option D: App Bundle (Google Play)**
\`\`\`bash
# Build app bundle for Play Store
flutter build appbundle --release

# Bundle location: build/app/outputs/bundle/release/app-release.aab
\`\`\`

### Step 4: Run on Device

# Run app
flutter run
\`\`\`

### Step 5: Verify Installation

Once app is running, you should see:
- Loading screen briefly
- Video playback starting
- Console logs showing playlist info

Check logs:
\`\`\`bash
flutter logs
\`\`\`

### Step 6: Test with Your Video

1. Place MP4 files in `assets/videos/ads/`
2. Update `assets/video_instructions.json` with filenames
3. Rebuild and run:
   \`\`\`bash
   flutter clean
   flutter pub get
   flutter run
   \`\`\`

---

## Android-Specific Troubleshooting

| Issue | Solution |
|-------|----------|
| **"flutter: command not found"** | Add Flutter to PATH: `export PATH="$PATH:~/flutter/bin"` |
| **No devices found** | Enable USB debugging, check ADB: `adb devices` |
| **Gradle build fails** | Run `flutter clean && flutter pub get` |
| **Video plays black screen** | Check video codec (H.264) and verify file path in JSON |
| **Out of memory crash** | Reduce repeat count in JSON or split videos |

---

## Checking Persisted Data on Android

The cached JSON is stored in the app's documents directory:

\`\`\`bash
# View cached files
adb shell run-as com.example.play_b2b ls -la /data/data/com.example.play_b2b/app_flutter/

# Pull cached JSON to computer
adb shell run-as com.example.play_b2b cat /data/data/com.example.play_b2b/app_flutter/video_instructions.json
\`\`\`


### Making Changes to JSON

1. Edit `assets/video_instructions.json`
2. Ensure valid JSON format
3. Run `flutter run` to rebuild and reload
4. App will re-parse and create new playlist

### Adding New Features

1. Create entities in `domain/entities/`
2. Add models in `data/models/`
3. Implement repository in `data/repositories/`
4. Update use cases in `domain/usecases/`
5. Modify `VideoController` in `presentation/controllers/`


