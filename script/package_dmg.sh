#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Unspool"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
DMG_STAGING="$DIST_DIR/dmg-staging"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
NOTARY_PROFILE="${NOTARY_PROFILE:-Transcripted}"

developer_id_application() {
  security find-identity -v -p codesigning 2>/dev/null \
    | awk '/Developer ID Application/ { print $2; exit }'
}

cd "$ROOT_DIR"
DEVELOPER_ID_APPLICATION="${DEVELOPER_ID_APPLICATION:-$(developer_id_application)}"
if [[ -z "$DEVELOPER_ID_APPLICATION" ]]; then
  echo "error: no Developer ID Application signing identity found" >&2
  exit 1
fi

SIGN_IDENTITY="$DEVELOPER_ID_APPLICATION" SWIFT_CONFIGURATION=release bash script/build_and_run.sh --verify
pkill -x "$APP_NAME" >/dev/null 2>&1 || true
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

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

codesign --force --timestamp --sign "$DEVELOPER_ID_APPLICATION" "$DMG_PATH"

if [[ -n "$NOTARY_PROFILE" ]]; then
  xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG_PATH"
  xcrun stapler validate "$DMG_PATH"
else
  echo "note: NOTARY_PROFILE is empty, skipping notarization"
fi

spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG_PATH"
echo "$DMG_PATH"
