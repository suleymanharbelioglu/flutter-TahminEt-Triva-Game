#!/usr/bin/env bash
set -euo pipefail
ADB="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
PACKAGE="com.appliculture.tahmin_et"
"$ADB" devices
"$ADB" shell setprop debug.firebase.analytics.app "$PACKAGE"
echo "DebugView ENABLED → $PACKAGE"
echo "Firebase Console → Analytics → DebugView"
echo "Then: flutter run -d <android-device-id>"
echo "Disable later: $ADB shell setprop debug.firebase.analytics.app .none."
