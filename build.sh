#!/bin/bash
set -e

APP_NAME="WorldClock"
SDK=$(xcrun --sdk macosx --show-sdk-path)
MIN_OS="26.0"

echo "Building $APP_NAME..."

rm -rf "$APP_NAME.app" "$APP_NAME"

swiftc \
    Sources/WorldClock/ClockModel.swift \
    Sources/WorldClock/AppDelegate.swift \
    Sources/WorldClock/MouseTracker.swift \
    Sources/WorldClock/TimelineBarView.swift \
    Sources/WorldClock/TimezoneRowView.swift \
    Sources/WorldClock/SettingsView.swift \
    Sources/WorldClock/PopoverView.swift \
    Sources/WorldClock/WorldClockApp.swift \
    -parse-as-library \
    -target arm64-apple-macosx${MIN_OS} \
    -sdk "$SDK" \
    -Onone \
    -o "$APP_NAME"

# Create .app bundle
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

cp "$APP_NAME" "$APP_NAME.app/Contents/MacOS/$APP_NAME"
cp "Sources/WorldClock/Resources/Info.plist" "$APP_NAME.app/Contents/Info.plist"
cp "Sources/WorldClock/Resources/AppIcon.icns" "$APP_NAME.app/Contents/Resources/AppIcon.icns"
rm "$APP_NAME"

# Ad-hoc sign
codesign --force --deep --sign - "$APP_NAME.app" 2>/dev/null || true

# Install to /Applications so it's a proper resident app
rm -rf "/Applications/$APP_NAME.app"
cp -R "$APP_NAME.app" "/Applications/$APP_NAME.app"

echo "Done! Installed to /Applications/$APP_NAME.app"
pkill -x "$APP_NAME" 2>/dev/null || true
sleep 0.5
open "/Applications/$APP_NAME.app"
