# BOOX gestures for KOReader

Adds two persistent toggles to KOReader's **Settings → Screen** menu:

- **Disable BOOX top gestures in KOReader**
- **Disable BOOX bottom gestures in KOReader**

## Install

Clone the repository into KOReader's `plugins` directory using the required
`.koplugin` suffix, then restart KOReader:

```sh
cd /path/to/koreader/plugins
git clone https://github.com/schudt/booxgestures.git booxgestures.koplugin
```

The plugin is Android-only. It sends BOOX's runtime broadcasts:

```text
com.onyx.action.BOTTOM_GESTURE_ENABLE
com.onyx.action.TOP_GESTURE_ENABLE
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
```
