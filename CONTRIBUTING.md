# Contributing

Unspool is private and early right now.

The main rule is simple:

> Write it out. Keep the signal.

## Before Changing The App

- keep the main writing page quiet
- avoid adding dashboards to the daily flow
- keep writing local by default
- do not add network calls to the core flow
- keep copy short and human

## Local Checks

```bash
swift test
./script/build_and_run.sh --verify
```

For packaging changes, also run:

```bash
./script/package_dmg.sh
```
