# Development

Unspool is a SwiftPM macOS app.

## Requirements

- macOS 14 or newer
- Swift 6 toolchain

## Run

```bash
./script/build_and_run.sh
```

## Test

```bash
swift test
```

CI on `macos-15` runs the same `swift test` command, then `./script/build_and_run.sh --verify`.

## Verify Launch

```bash
./script/build_and_run.sh --verify
```

## Build A Signed DMG

v0.1.3 is already Developer ID signed and notarized. Use the packaging script for later signed releases:

```bash
NOTARY_PROFILE=your-notary-profile ./script/package_dmg.sh
```

The DMG is written to:

```text
dist/Unspool.dmg
```

`NOTARY_PROFILE` must be set to your notarytool keychain profile when notarizing. The script fails if it is unset. Do not default it to another product's profile.

## Source Layout

- `Sources/Unspool`: app entry point
- `Sources/UnspoolCore`: reusable app logic and SwiftUI views
- `Tests/UnspoolTests`: storage, streak, and word count tests
- `script`: local run and packaging scripts
- `Assets`: app icon, README GIF, social preview PNG, and app screenshot
