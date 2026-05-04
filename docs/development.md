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

## Verify Launch

```bash
./script/build_and_run.sh --verify
```

## Build A Local DMG

```bash
./script/package_dmg.sh
```

The DMG is written to:

```text
dist/Unspool.dmg
```

The local DMG is ad-hoc signed for local validation. Public distribution still needs Developer ID signing and notarization.

## Source Layout

- `Sources/Unspool`: app entry point
- `Sources/UnspoolCore`: reusable app logic and SwiftUI views
- `Tests/UnspoolTests`: storage, streak, word count, and export tests
- `script`: local run and packaging scripts
- `Assets`: app icon and GitHub cover image
