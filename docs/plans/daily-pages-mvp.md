# Daily Pages MVP Plan

## Shape

- Build a SwiftPM macOS SwiftUI app named `DailyPages`.
- Keep app code split into `App`, `Models`, `Storage`, `Views`, and `Support`.
- Use local Markdown files as the source of truth.
- Add a project run script that builds a small `.app` bundle from SwiftPM output.

## Core Pieces

- `DailyEntry`: one writing day, word count, goal state, timestamps, optional export and mood fields.
- `WordCounter`: small reusable whitespace-based counter.
- `MarkdownEntrySerializer`: frontmatter Markdown serialization and loading.
- `EntryStore`: loads entries, manages today, debounced autosave, and visible save errors.
- `StreakCalculator`: counts consecutive 750-word days ending today or yesterday.
- `AIContextDraftGenerator`: local keyword heuristic only, with editable draft text.
- `ContextExportStore`: chooses the export folder and writes user-approved Markdown.

## UI

- Open directly to Today's Page with a focused text editor.
- Show live word count, 750-word progress, daily goal, status copy, streak, and previous entries.
- Use a native sidebar/detail layout for previous days.
- Show an AI context sheet where the user edits selected context before exporting.
- Add simple Settings with storage and export paths.

## Tests

- Word count edge cases.
- Markdown serialize/save/load round trip.
- Streak calculation.
- AI context keyword extraction and fallback.
- Export folder choice.

## Verification

- Run `swift test`.
- Run `./script/build_and_run.sh --verify` if the app builds.
