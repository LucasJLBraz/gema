---
name: run-app
description: Boot the gema_emulator AVD and run the Flutter app against it. Use to manually test UI changes or the full onboarding/logging flow.
disable-model-invocation: true
---

1. Check if the emulator is already running:
   ```bash
   adb devices
   ```
   If `emulator-*` appears and is `device`, skip to step 3.

2. Start the emulator (requires KVM — must be inside the devcontainer):
   ```bash
   emulator -avd gema_emulator -no-snapshot-load &
   adb wait-for-device
   ```

3. Ensure dependencies are up to date:
   ```bash
   flutter pub get
   ```

4. Launch the app:
   ```bash
   flutter run
   ```

5. Report the device it launched on and watch for any runtime errors in the output.
