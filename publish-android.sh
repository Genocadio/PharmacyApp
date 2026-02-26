#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

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

ensure_key_properties() {
  local key_props="android/key.properties"
  if [[ ! -f "$key_props" ]]; then
    cp android/key.properties.example "$key_props"
    echo "Created $key_props from example."
    echo "Fill real signing values and rerun: ./publish-android.sh"
    exit 1
  fi

  local store_file store_password key_alias key_password
  store_file="$(read_prop "$key_props" "storeFile")"
  store_password="$(read_prop "$key_props" "storePassword")"
  key_alias="$(read_prop "$key_props" "keyAlias")"
  key_password="$(read_prop "$key_props" "keyPassword")"

  for v in store_file store_password key_alias key_password; do
    if [[ -z "${!v}" ]]; then
      echo "android/key.properties is missing required value: ${v}"
      exit 1
    fi
  done

  if [[ "$store_password" == "CHANGE_ME" || "$key_password" == "CHANGE_ME" ]]; then
    echo "android/key.properties still has placeholder secrets."
    exit 1
  fi

  local store_path
  if [[ "$store_file" = /* ]]; then
    store_path="$store_file"
  else
    store_path="$(cd android && cd "$(dirname "$store_file")" && pwd)/$(basename "$store_file")"
  fi

  if [[ ! -f "$store_path" ]]; then
    echo "Keystore file not found at: $store_path"
    exit 1
  fi

  require_cmd keytool
  if ! keytool -list -keystore "$store_path" -storepass "$store_password" -alias "$key_alias" -keypass "$key_password" >/dev/null 2>&1; then
    echo "Signing key authentication failed. Check keystore path/password/alias/keyPassword."
    exit 1
  fi

  echo "Signing key is available and authenticated."
}

ensure_git_access() {
  require_cmd git
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    exit 1
  fi

  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "Git remote 'origin' is not configured."
    exit 1
  fi

  if ! git ls-remote --exit-code origin HEAD >/dev/null 2>&1; then
    echo "Unable to authenticate against origin. Ensure git access is valid."
    exit 1
  fi

  echo "Git remote authentication check passed."
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

commit_and_push() {
  shopt -s nullglob
  local files=(release/android/*.apk release/android/*.aab)
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No Android artifacts found under release/android. Build step may have failed."
    exit 1
  fi

  git add release/android/*.apk release/android/*.aab

  local version
  version="$(get_version)"

  if git diff --cached --quiet; then
    echo "No staged artifact changes to commit."
  else
    git commit -m "chore(android): publish prebuilt artifacts $version"
  fi

  git push origin HEAD:main
  echo "Pushed to main. GitHub workflow android-publish.yml will publish release artifacts."
}

main() {
  require_cmd flutter
  require_cmd awk
  require_cmd grep

  ensure_key_properties
  ensure_git_access

  echo "Building signed Android artifacts locally..."
  bash ./build-android-release.sh

  echo "Committing and pushing release/android/* ..."
  commit_and_push

  echo "Done."
}

main "$@"
