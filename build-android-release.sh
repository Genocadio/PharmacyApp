#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

PUBSPEC_VERSION_LINE=$(grep -E '^version:' pubspec.yaml | head -n 1 | awk '{print $2}')
if [[ -z "${PUBSPEC_VERSION_LINE:-}" ]]; then
  echo "Unable to read version from pubspec.yaml"
  exit 1
fi

BUILD_NAME="${PUBSPEC_VERSION_LINE%%+*}"
if [[ "$PUBSPEC_VERSION_LINE" == *"+"* ]]; then
  BUILD_NUMBER="${PUBSPEC_VERSION_LINE##*+}"
else
  BUILD_NUMBER="1"
fi

echo "Using build-name: $BUILD_NAME"
echo "Using build-number: $BUILD_NUMBER"

if [[ ! -f "android/key.properties" ]]; then
  echo "Warning: android/key.properties not found. Release will fallback to debug signing."
fi

echo "Fetching dependencies..."
flutter pub get

echo "Building Android App Bundle (AAB)..."
flutter build appbundle --release --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"

echo "Building Android APKs (split per ABI)..."
flutter build apk --release --split-per-abi --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"

echo "Building universal Android APK..."
flutter build apk --release --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"

OUT_DIR="release/android"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp build/app/outputs/bundle/release/app-release.aab "$OUT_DIR/nexxpharma-$BUILD_NAME+$BUILD_NUMBER.aab"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT_DIR/nexxpharma-$BUILD_NAME+$BUILD_NUMBER-universal.apk"
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$OUT_DIR/nexxpharma-$BUILD_NAME+$BUILD_NUMBER-armeabi-v7a.apk"
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$OUT_DIR/nexxpharma-$BUILD_NAME+$BUILD_NUMBER-arm64-v8a.apk"
cp build/app/outputs/flutter-apk/app-x86_64-release.apk "$OUT_DIR/nexxpharma-$BUILD_NAME+$BUILD_NUMBER-x86_64.apk"

( cd release && zip -r "nexxpharma-android-$BUILD_NAME+$BUILD_NUMBER.zip" android >/dev/null )

echo "Android release artifacts generated:"
ls -lah "$OUT_DIR"
echo "Package archive: release/nexxpharma-android-$BUILD_NAME+$BUILD_NUMBER.zip"
