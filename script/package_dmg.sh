#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Unspool"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
DMG_STAGING="$DIST_DIR/dmg-staging"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"

cd "$ROOT_DIR"
bash script/build_and_run.sh --verify
pkill -x "$APP_NAME" >/dev/null 2>&1 || true
codesign --verify --deep --strict "$APP_BUNDLE"

rm -rf "$DMG_STAGING" "$DMG_PATH"
mkdir -p "$DMG_STAGING"

cp -R "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

if ! spctl --assess --type execute "$APP_BUNDLE" 2>/dev/null; then
  echo "note: local DMG is not Developer ID notarized yet"
fi

echo "$DMG_PATH"
