# Android Release & Update Guide

This mirrors the existing Windows release/update flow with Android-specific tooling.

## 1) Local Android Release Build

Use the new script at project root:

```bash
./build-android-release.sh
```

It will:
- Read version from `pubspec.yaml`
- Build `AAB` and `APK` artifacts
- Output files to `release/android/`
- Create `release/nexxpharma-android-<version>.zip`

## 2) Android Signing (Required for production)

1. Copy template:
```bash
cp android/key.properties.example android/key.properties
```
2. Fill real values in `android/key.properties`
3. Ensure the keystore file exists at `storeFile` path

If `android/key.properties` is missing, release build falls back to debug signing (for testing only).

## 3) GitHub Actions CI Flow (Android)

### Inner build workflow
File: `.github/workflows/Inner Build - Android.yml`

- Builds signed Android `AAB` + `APK`
- Packages artifacts into `nexxpharma-android-<version>.zip`
- Uploads `nexxpharma-android-release` artifact

Required GitHub secrets:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

### Release publish workflow
File: `.github/workflows/release-build-android.yml`

- Triggered when inner build succeeds (or manually)
- Downloads zipped artifact
- Publishes `.aab` and `.apk` files to GitHub Release tag `v<version>`

## 4) Runtime Updates on Android

Android now uses Play Core in-app updates (not zip replacement like Windows).

- Service: `lib/services/android_update_service.dart`
- Initialization: `main.dart` (Android-only)
- Periodic check: every 6 hours
- First check: 10 seconds after app launch

### Notes
- In-app updates require Play-distributed app installs.
- On sideloaded/debug builds, update checks may report failure or unavailable.

## 5) Release Artifacts

Expected outputs:
- `nexxpharma-<version>.aab` (Play Console upload)
- `nexxpharma-<version>-universal.apk`
- ABI-split APKs (`armeabi-v7a`, `arm64-v8a`, `x86_64`)

## 6) Recommended Production Path

- Publish `AAB` to Google Play (Internal testing -> Production)
- Use in-app updates for installed users
- Keep GitHub release artifacts for QA/distribution outside Play
