# Unspool

Unspool is a private daily writing app for getting thoughts out of your head.

It opens to one quiet page. You write whatever is on your mind. Unspool saves it locally as Markdown so it can stay private, become part of a second brain, or feed a later reflection system.

The point is relief first. Pattern-finding can come later.

## Why This Exists

Some thoughts are too tangled to organize while they are still in your head.

Unspool gives you a simple place to dump the noise every day:

- what you are anxious about
- what you are working on
- what keeps coming back
- what you want
- what feels stuck

Those raw pages become useful signal over time. A second brain can later see themes, pressure points, goals, and open loops without forcing the writing session to become a task list.

## What It Does

- Opens straight into today's writing page
- Autosaves local Markdown files
- Tracks word count and writing streak
- Supports light/dark writing modes
- Supports serif, system, and monospace writing fonts
- Can disable delete/backspace for freewriting
- Keeps previous pages in a local sidebar
- Stores pages on your Mac, not on a server

## What It Does Not Do

- No account
- No cloud sync
- No analytics
- No social feed
- No forced prompts
- No forced summaries
- No productivity score

## Local Files

Unspool stores entries in:

```text
~/Library/Application Support/Unspool/Entries
```

Each page is a Markdown file with small frontmatter metadata and the raw writing body.

## Second-Brain Shape

Unspool is designed to work well with a local second brain.

The best flow is:

1. Write freely in Unspool.
2. Keep the raw page intact.
3. Let a separate system process patterns later.

That keeps the daily writing ritual simple while still giving agents useful context over time.

## Run Locally

Requirements:

- macOS 14 or newer
- Swift 6 toolchain

Run the app:

```bash
./script/build_and_run.sh
```

Run tests:

```bash
swift test
```

Verify the app bundle launches:

```bash
./script/build_and_run.sh --verify
```

## Product Direction

The core rule is simple:

> Write it out. Keep the signal.

Future work should protect that. Unspool should stay quiet, local, and focused on the page.

