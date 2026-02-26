#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

BUILD_APK=true
BUILD_AAB=true
OUTPUT_DIR="release/android"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apk)
      BUILD_APK=true
      shift
      ;;
    --no-apk)
      BUILD_APK=false
      shift
      ;;
    --aab)
      BUILD_AAB=true
      shift
      ;;
    --no-aab)
      BUILD_AAB=false
      shift
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: ./build-android-release.sh [--apk|--no-apk] [--aab|--no-aab] [--output-dir <dir>]"
      exit 1
      ;;
  esac
done

if [[ "$BUILD_APK" == "false" && "$BUILD_AAB" == "false" ]]; then
  echo "Nothing to build: both APK and AAB are disabled."
  exit 1
fi

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command not found: $1"
    exit 1
  }
}

read_prop() {
  local file="$1"
  local key="$2"
  grep -E "^${key}=" "$file" | head -n1 | cut -d'=' -f2-
}

ensure_signing_config() {
  local key_props_path="$ROOT_DIR/android/key.properties"
  if [[ ! -f "$key_props_path" ]]; then
    echo "Missing android/key.properties. Copy android/key.properties.example and fill real values."
    exit 1
  fi

  local store_file store_password key_alias key_password
  store_file="$(read_prop "$key_props_path" "storeFile")"
  store_password="$(read_prop "$key_props_path" "storePassword")"
  key_alias="$(read_prop "$key_props_path" "keyAlias")"
  key_password="$(read_prop "$key_props_path" "keyPassword")"

  for v in store_file store_password key_alias key_password; do
    if [[ -z "${!v}" ]]; then
      echo "android/key.properties is missing required value: ${v}"
      exit 1
    fi
  done

  if [[ "$store_password" == "CHANGE_ME" || "$key_password" == "CHANGE_ME" ]]; then
    echo "android/key.properties still has placeholder secret values."
    exit 1
  fi

  if [[ "$store_file" = /* ]]; then
    STORE_FILE_PATH="$store_file"
  else
    STORE_FILE_PATH="$(cd "$ROOT_DIR/android" && cd "$(dirname "$store_file")" && pwd)/$(basename "$store_file")"
  fi

  if [[ ! -f "$STORE_FILE_PATH" ]]; then
    echo "Keystore file not found at: $STORE_FILE_PATH"
    exit 1
  fi

  require_cmd keytool
  if ! keytool -list -keystore "$STORE_FILE_PATH" -storepass "$store_password" -alias "$key_alias" -keypass "$key_password" >/dev/null 2>&1; then
    echo "Unable to authenticate keystore/keyAlias using android/key.properties values."
    exit 1
  fi

  echo "Signing config validated."
}

get_version() {
  local version
  version="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
  if [[ -z "$version" ]]; then
    echo "Unable to read version from pubspec.yaml"
    exit 1
  fi
  echo "$version"
}

require_cmd flutter

VERSION="$(get_version)"
ARTIFACT_VERSION="${VERSION//+/-}"

echo "Building Android release for version: $VERSION"
ensure_signing_config

flutter pub get

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

if [[ "$BUILD_APK" == "true" ]]; then
  echo "Building signed APK..."
  flutter build apk --release

  APK_SOURCE="build/app/outputs/flutter-apk/app-release.apk"
  if [[ ! -f "$APK_SOURCE" ]]; then
    echo "APK not found at $APK_SOURCE"
    exit 1
  fi

  APK_TARGET="$OUTPUT_DIR/nexxpharma-android-${ARTIFACT_VERSION}.apk"
  cp "$APK_SOURCE" "$APK_TARGET"
  echo "APK staged at: $APK_TARGET"
fi

if [[ "$BUILD_AAB" == "true" ]]; then
  echo "Building signed AAB..."
  flutter build appbundle --release

  AAB_SOURCE="build/app/outputs/bundle/release/app-release.aab"
  if [[ ! -f "$AAB_SOURCE" ]]; then
    echo "AAB not found at $AAB_SOURCE"
    exit 1
  fi

  AAB_TARGET="$OUTPUT_DIR/nexxpharma-android-${ARTIFACT_VERSION}.aab"
  cp "$AAB_SOURCE" "$AAB_TARGET"
  echo "AAB staged at: $AAB_TARGET"
fi

echo "Android artifacts are ready in: $OUTPUT_DIR"
