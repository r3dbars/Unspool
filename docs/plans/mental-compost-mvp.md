# Mental Compost MVP Plan

## Shape

- Refactor the existing SwiftPM macOS SwiftUI app into `MentalCompost`.
- Keep a small executable target and a testable `MentalCompostCore` target.
- Use local Markdown files as the source of truth for entries and compost reviews.
- Keep the run script staging a small `.app` bundle from SwiftPM output.

## Core Pieces

- `DailyEntry`: one writing day, word count, goal state, timestamps, optional compost/export timestamps.
- `CompostReview`: one review for a daily entry with Seeds, Weeds, Compost, Fruit, and Weather.
- `AppSettings`: minimal local-first settings model and defaults.
- `WordCounter`: small reusable whitespace-based counter.
- `MarkdownEntrySerializer`: frontmatter Markdown serialization and loading for daily entries.
- `MarkdownCompostSerializer`: Markdown serialization and loading for compost reviews.
- `EntryStore`: loads entries, manages today, debounced autosave, and visible save errors.
- `CompostReviewStore`: loads and saves compost review Markdown.
- `StreakCalculator`: counts consecutive 750-word days ending today or yesterday.
- `CompostGenerator`: uses optional local AI or heuristic fallback.
- `HeuristicCompostGenerator`: local keyword extraction with manual template fallback.
- `LocalAIClient`: protocol for tests and localhost-compatible AI clients.
- `OpenAICompatibleLocalAIClient`: calls a configured chat completions endpoint, defaulting to localhost.
- `ExportPathResolver` and `AIContextExporter`: choose export paths and write user-selected compost only.

## UI

- Open directly to Today's Pile with a focused editor.
- Show live word count, compost metaphor progress, daily goal, status copy, and streak.
- Use a native sidebar/detail layout for previous entries, including compost status.
- Add a compost review sheet with local AI, heuristic fallback, editable Markdown, and export editor.
- Add simple Settings with storage paths, local AI endpoint/model, and reveal/test actions.
- Include clear privacy copy in Settings.

## Tests

- Word count edge cases.
- Markdown serialize/save/load round trip.
- Streak calculation.
- Heuristic compost extraction and fallback.
- Local AI mock success/failure without network.
- Export folder choice and selected-compost-only export.

## Verification

- Run `swift test`.
- Run `./script/build_and_run.sh --verify` if the app builds.
