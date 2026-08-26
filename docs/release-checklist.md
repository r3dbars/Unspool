# Release Checklist

Use this before publishing a new Unspool build.

v0.1.3 is already Developer ID signed and notarized. Later releases should stay on that same public path.

## Local Checks

```bash
swift test
./script/build_and_run.sh --verify
NOTARY_PROFILE=your-notary-profile ./script/package_dmg.sh
```

`package_dmg.sh` fails if `NOTARY_PROFILE` is unset. Set it to your notarytool keychain profile when notarizing.

## App

- Opens straight to the writing page.
- Reopens today's writing if the user already wrote today.
- Starts a fresh page on a new day.
- Shows the 750-word completion moment once per day.
- Opens the simple stats popover from the word counter.
- Saves Markdown locally.
- Lets the user choose the Markdown entries folder in Settings.
- Uses the Unspool app icon in the app bundle and DMG.

## Repo

- `README.md` explains the app simply.
- `CHANGELOG.md` has the new version.
- `docs/how-it-works.md`, `docs/privacy.md`, and `docs/development.md` are current.
- Brand assets live in `Assets/`.
- README keeps `Assets/GitHub/unspool-writing-demo.gif` and `Assets/GitHub/unspool-social-preview.png`.
- `Assets/GitHub/unspool-app-screenshot.png` is the static fallback image.
- GitHub social preview still has to be attached in the repo Settings UI. The GitHub API cannot set that image easily.
- The signed DMG builds at `dist/Unspool.dmg`.
- The worktree is clean before tagging or publishing.

## Distribution Notes

Public builds use Developer ID signing, hardened runtime, notarization, stapling, and Gatekeeper validation.

The core rule is simple:

> Write it out. Keep the signal.
