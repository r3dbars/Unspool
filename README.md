# Unspool

![Unspool social preview](Assets/GitHub/unspool-social-preview.png)

Unspool is a private daily writing app for getting thoughts out of your head.

It opens to one quiet page. You write whatever is on your mind. Unspool saves it locally as Markdown.

The point is relief first. The signal can come later.

## What It Is

Unspool gives you a simple place to dump the noise every day:

- what you are anxious about
- what you are working on
- what keeps coming back
- what you want
- what feels stuck

Those raw pages become useful over time. A second brain can later spot themes and open loops without turning the writing session into a task list.

## What It Does

- Opens straight into today's writing page
- Autosaves local Markdown files
- Tracks word count, streak, and simple writing stats
- Celebrates when you reach 750 words
- Resumes today's page if you reopen the app
- Starts fresh on a new day
- Supports light/dark mode, font size, and font style
- Can disable delete/backspace for freewriting
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

## Build

Requirements:

- macOS 14 or newer
- Swift 6 toolchain

Run locally:

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

## Brand Assets

- App icon source: `Assets/Brand/unspool-app-icon-source.png`
- App icon: `Assets/AppIcon/Unspool.icns`
- GitHub social preview: `Assets/GitHub/unspool-social-preview.png`

## Product Rule

Write it out. Keep the signal.

Unspool should stay quiet, local, and focused on the page.
