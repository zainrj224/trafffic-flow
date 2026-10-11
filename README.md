# Neon Highway – Flutter (Android) project

The game (Three.js, all 7 vehicles) runs inside a Flutter shell via `webview_flutter`.
Everything is bundled offline (Three.js r128 is included, no CDN needed).
Touch controls (choose in the menu or with the Controls button): Buttons mode = on-screen left/right, NITRO and BRAKE buttons; Swipe mode = drag left/right to steer, hold swipe up for nitro, hold swipe down to brake. Both auto-accelerate. Add ?touch to the URL to preview the touch UI in Chrome.

## Quick preview in Chrome (no setup, no device prompt)
In this folder (Windows PowerShell):

    .\run_chrome.bat            # or:  flutter pub get ; flutter run -d chrome

`-d chrome` skips the "which device/browser?" question. Keyboard controls work in Chrome
(arrows/WASD, Shift/Space nitro, 1-7 pick vehicle). Click the game once so it gets keyboard focus.
Swipe controls are for phones. Chrome is only a preview; the Play Store build is the Android one below.

## 1. Create the Android project
Install Flutter (latest stable) and run `flutter doctor`, then in this folder:

    ./setup.sh com.yourname      # macOS/Linux/Git Bash. On Windows PowerShell run the same steps by hand:
                                 #   flutter create --platforms=android,web --org com.yourname --project-name neon_highway app
                                 #   then copy lib, assets, pubspec.yaml into app\ and run flutter pub get
    cd app && flutter run        # test on a real phone

Set the app name: in `app/android/app/src/main/AndroidManifest.xml` change `android:label` to `Neon Highway`.
Replace `assets/icon.png` (1024×1024) with your own artwork and re-run `dart run flutter_launcher_icons`.

## 2. Sign the release build
    keytool -genkey -v -keystore ~/neon-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

Create `app/android/key.properties`:

    storePassword=YOUR_PASSWORD
    keyPassword=YOUR_PASSWORD
    keyAlias=upload
    storeFile=/absolute/path/to/neon-upload.jks

In `app/android/app/build.gradle.kts` add at the top:

    import java.util.Properties
    import java.io.FileInputStream
    val keystoreProperties = Properties().apply {
        val f = rootProject.file("key.properties")
        if (f.exists()) load(FileInputStream(f))
    }

and inside `android { ... }`:

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes { release { signingConfig = signingConfigs.getByName("release") } }

Back up the .jks file and passwords somewhere safe.

## 3. Build the bundle
    cd app && flutter build appbundle --release

Upload `app/build/app/outputs/bundle/release/app-release.aab` in Play Console.
Google Play currently requires new apps to target Android 16 (API 36); a recent Flutter stable does this by default.
If the build complains, run `flutter upgrade`.

## 4. Play Console checklist
- Developer account, then Create app → Production/Closed testing → upload the .aab
- Store listing: title, short/full description, 512×512 icon, 1024×500 feature graphic, 2+ phone screenshots (landscape is fine)
- Privacy policy URL (required even if you collect nothing)
- Data safety form (the game stores only a high score on-device, collects nothing)
- Content rating questionnaire, target audience, ads declaration (no ads)
- New personal developer accounts may need a closed test with testers before production – check the Console for the current rule
