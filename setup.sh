#!/usr/bin/env bash
# Usage: ./setup.sh com.yourname   (creates ./app, a ready-to-build Android project)
set -e
ORG=${1:-com.yourname}
flutter create --platforms=android,web --org "$ORG" --project-name neon_highway app
rm -rf app/lib app/test app/assets/game
mkdir -p app/assets
cp -r lib app/lib
cp -r assets/game app/assets/game
cp assets/icon.png app/assets/icon.png
cp pubspec.yaml app/pubspec.yaml
cd app
flutter pub get
dart run flutter_launcher_icons
echo "Done. Test with: cd app && flutter run   |   Release: flutter build appbundle --release"
