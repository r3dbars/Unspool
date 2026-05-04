# Implementation Notes

Unspool is a SwiftPM macOS app.

## Shape

- `Unspool` is the executable target.
- `UnspoolCore` holds the reusable SwiftUI views, storage, models, and services.
- Local Markdown files are the source of truth for entries.
- The run script stages a small `.app` bundle from SwiftPM output.

## Core Pieces

- `DailyEntry`: one writing session, word count, goal state, timestamps, and optional metadata.
- `EntryStore`: loads entries, manages today, debounced autosave, folder switching, and visible save errors.
- `EntryDirectoryPreference`: stores the user's chosen Markdown folder.
- `AppSettings`: minimal local-first settings defaults.
- `WordCounter`: small reusable whitespace-based counter.
- `MarkdownEntrySerializer`: frontmatter Markdown serialization and loading for daily entries.
- `StreakCalculator`: counts consecutive 750-word days ending today or yesterday.

## UI

- Open directly to today's page with a focused editor.
- Show live word count, daily goal, status copy, and streak.
- Use a native sidebar/detail layout for previous entries.
- Keep reflection and export surfaces out of the primary writing flow until they are clearly useful.
- Add simple Settings with storage paths and privacy copy.
- Include clear privacy copy in Settings.

## Experimental Reflection Code

The repo still includes local-only reflection/export code from an earlier prototype.

That code is grouped as optional plumbing. It should not interrupt the daily writing page, and it should not send writing anywhere unless the user explicitly chooses an export or endpoint.

## Tests

- Word count edge cases.
- Markdown serialize/save/load round trip.
- Streak calculation.
- Folder switching.
- Experimental local reflection and export behavior.

## Verification

- Run `swift test`.
- Run `./script/build_and_run.sh --verify` if the app builds.
