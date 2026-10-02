# booxgestures.koplugin — BOOX gestures for KOReader

Adds three persistent toggles to KOReader's
**Settings → Taps and gestures → BOOX system gestures** submenu:

- **Disable BOOX top gestures in KOReader**
- **Disable BOOX bottom gestures in KOReader**
- **Disable BOOX side gestures in KOReader**

Top and bottom gesture controls tested on a BOOX Go 7 device. The side gesture
control still needs device testing.

## Install

Download `booxgestures.koplugin.zip` from the
[latest release](https://github.com/schudt/booxgestures.koplugin/releases/latest) and
extract it into KOReader's `plugins` directory. The archive already contains
the required `booxgestures.koplugin` directory. Then restart KOReader.

Alternatively, clone the repository directly into KOReader's `plugins` directory:

```sh
cd /path/to/koreader/plugins
git clone https://github.com/schudt/booxgestures.koplugin.git
```

## Release

Push a version tag to build and publish an install-ready ZIP and its SHA-256
checksum:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The plugin is Android-only. It sends BOOX's runtime broadcasts:

```text
com.onyx.action.BOTTOM_GESTURE_ENABLE
com.onyx.action.TOP_GESTURE_ENABLE
com.onyx.action.SIDE_GESTURE_ENABLE
```

with boolean extra `args_enable`. Each toggle independently disables its gestures
while KOReader is active, restores them when KOReader goes into the background,
and disables them again when KOReader resumes.

The plugin sends the broadcast through KOReader's native Android/JNI bridge;
it does not require root, ADB, or a companion application.

Android does not deliver a pause event when KOReader is force-stopped or crashes.
In that case, re-enable the gestures with:

```sh
adb shell am broadcast -a com.onyx.action.BOTTOM_GESTURE_ENABLE --ez args_enable true
adb shell am broadcast -a com.onyx.action.TOP_GESTURE_ENABLE --ez args_enable true
adb shell am broadcast -a com.onyx.action.SIDE_GESTURE_ENABLE --ez args_enable true
```
