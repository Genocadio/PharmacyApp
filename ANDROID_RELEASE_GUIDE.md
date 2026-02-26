# Android Release Guide (Local Signed Build + Publish on Push)

This project now supports Android release flow similar to Windows packaging, with one key difference:

- Android builds are signed and built locally on your PC.
- GitHub Actions does not build Android binaries.
- On push to `main`, GitHub Actions publishes committed Android artifacts to GitHub Releases.
- In-app on Android: checks latest release and announces when newer version exists.
- In-app on Android: **no self-update download/install**.

---

## 1) One-time local signing setup

1. Create your keystore (example):

```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

2. Place keystore on your machine (recommended outside repo, or in ignored folder).

3. Create `android/key.properties` from `android/key.properties.example`.

4. Fill values:

```properties
storeFile=../keystore/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

`android/key.properties` is gitignored; never commit secrets.

---

## 2) Build signed Android artifacts locally (macOS/Linux)

Run:

```bash
bash ./build-android-release.sh
```

By default this builds both:
- signed APK
- signed AAB

And stages them in:

- `release/android/nexxpharma-android-<version>.apk`
- `release/android/nexxpharma-android-<version>.aab`

You can choose one format:

```bash
bash ./build-android-release.sh --apk --no-aab
bash ./build-android-release.sh --no-apk --aab
```

---

## 3) One-command publish flow (recommended)

Run:

```bash
bash ./publish-android.sh
```

This script will:
1. Ensure `android/key.properties` exists (creates from example if missing).
2. Validate key fields and authenticate keystore/alias using `keytool`.
3. Validate git remote authentication to `origin`.
4. Build signed Android artifacts locally.
5. Commit `release/android/*` artifacts.
6. Push to `main`.

If key auth or git auth fails, it stops before build/push.

---

## 4) Publish on push (what CI does)

After local build:

1. Commit the files in `release/android/`.
2. Push to `main`.

Workflow: `.github/workflows/android-publish.yml`

Behavior:
- Reads app version from `pubspec.yaml`.
- Finds committed files under `release/android/*.apk` and `release/android/*.aab`.
- Creates/updates release tag `v<version>`.
- Uploads Android artifacts to that release.

If no files are found, workflow skips publish.

---

## 5) Android in-app release announcement

Android app now:
- checks GitHub latest release periodically,
- compares with installed app version,
- shows an in-app info notification when a newer release exists.

No automatic download or install is performed on Android.

---

## 6) Notes

- Keep artifact size in mind when committing binaries.
- Ensure `pubspec.yaml` version is updated before each release.
- Windows auto-update flow remains unchanged.
