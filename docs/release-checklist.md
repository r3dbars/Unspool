# Release Checklist

Use this before publishing a new Unspool build.

## Local Checks

```bash
swift test
./script/build_and_run.sh --verify
./script/package_dmg.sh
```

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
- Brand assets live in `Assets/`.
- GitHub cover image is ready at `Assets/GitHub/unspool-social-preview.png`.
- The local DMG builds at `dist/Unspool.dmg`.
- The worktree is clean before tagging or publishing.

## Distribution Notes

The local DMG is unsigned and not notarized.

For public distribution, sign with a Developer ID certificate, enable hardened runtime, notarize the DMG, and staple the ticket before sharing broadly.

The core rule is simple:

> Write it out. Keep the signal.
