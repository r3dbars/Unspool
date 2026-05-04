# Unspool

![Unspool social preview](Assets/GitHub/unspool-social-preview.png)

Unspool is a tiny Mac app for getting thoughts out of your head.

Open it. Write whatever is already in your head. When you hit 750 words, Unspool marks the day done and keeps the raw page as local Markdown.

No account. No feed. No prompts. Just a quiet place to unspool the noise.

## Why It Exists

Some thoughts are hard to organize while they are still in your head.

Unspool is built around the morning-pages / 750-words idea: write before you sort. The first few sentences are usually obvious. Somewhere deeper in the page, the real signal starts to show up.

The app keeps the writing session simple so you do not turn relief into another productivity system.

## How It Feels

1. Open the app.
2. Start typing into the empty page.
3. Keep going until the page feels lighter.
4. Hit 750 words if you want the daily mark.
5. Come back tomorrow to a fresh page.

If you reopen Unspool later the same day, it brings you back to today's page. If it is a new day, it starts fresh.

## What It Does

- opens straight into today's writing page
- saves local Markdown files automatically
- resumes today's page if you reopen the app
- starts a fresh page on a new day
- tracks word count, streak, and simple writing stats
- celebrates when you reach 750 words
- lets you choose where Markdown pages are saved
- supports light/dark mode, font size, and font style
- can disable delete/backspace for stricter freewriting

## What It Does Not Do

- no account
- no cloud sync
- no analytics
- no social feed
- no forced prompts
- no forced summaries
- no productivity score

## Where Your Writing Goes

By default, Unspool stores entries here:

```text
~/Library/Application Support/Unspool/Entries
```

You can choose a different folder in Settings. That makes it easy to save pages directly into a notes folder, second brain, or Git-backed archive.

Each entry is a plain Markdown file with small frontmatter metadata and the raw writing body.

## Run It Locally

Requirements:

- macOS 14 or newer
- Swift 6 toolchain

Start the app:

```bash
./script/build_and_run.sh
```

Run tests:

```bash
swift test
```

Build a local DMG:

```bash
./script/package_dmg.sh
```

The DMG is written to:

```text
dist/Unspool.dmg
```

## Project Map

- `Sources/Unspool`: macOS app entry point
- `Sources/UnspoolCore`: writing UI, local storage, stats, settings
- `Tests/UnspoolTests`: unit tests for storage, word count, streaks, and export behavior
- `Assets`: icon, cover image, and brand assets
- `docs`: product notes, privacy notes, development guide, and release checklist

## Docs

- [How Unspool Works](docs/how-it-works.md)
- [Privacy](docs/privacy.md)
- [Development](docs/development.md)
- [Release Checklist](docs/release-checklist.md)
- [Product Principles](docs/product-principles.md)

## Status

Unspool is early and private for now. The local DMG builds, but public distribution still needs Developer ID signing and notarization.

## Product Rule

Write it out. Keep the signal.

Unspool should stay quiet, local, and focused on the page.
