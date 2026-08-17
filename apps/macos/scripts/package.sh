#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPOSITORY_DIR="$(cd "$PROJECT_DIR/../.." && pwd)"
ARTIFACT_DIR="$REPOSITORY_DIR/artifacts"
APP_PATH="$ARTIFACT_DIR/BlueBridge.app"
ZIP_PATH="$ARTIFACT_DIR/BlueBridge-macOS-v0.2.0.zip"
EXECUTABLE_PATH="$PROJECT_DIR/.build/release/BlueBridgeMac"

swift build --package-path "$PROJECT_DIR" -c release

if [[ -e "$APP_PATH" ]]; then
    rm -rf "$APP_PATH"
fi
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"
cp "$EXECUTABLE_PATH" "$APP_PATH/Contents/MacOS/BlueBridgeMac"
cp "$PROJECT_DIR/Resources/Info.plist" "$APP_PATH/Contents/Info.plist"
cp "$PROJECT_DIR/Resources/BlueBridge.icns" "$APP_PATH/Contents/Resources/BlueBridge.icns"
chmod 755 "$APP_PATH/Contents/MacOS/BlueBridgeMac"

xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"
COPYFILE_DISABLE=1 ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "$APP_PATH"
echo "$ZIP_PATH"
