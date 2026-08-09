# Contributing

Thanks for looking. This is a young project and the most useful contributions
right now are real-world bug reports, iOS verification, and localization.

## Before you start

- Open an issue first for anything larger than a bug fix. The
  [roadmap](docs/roadmap.md) records what is planned, what was deliberately
  skipped, and why — check it before proposing a redesign.
- Read [`docs/api-notes.md`](docs/api-notes.md). GLPI's high-level API has sharp
  edges that have already cost hours; they are all written down.

## Setup

```sh
flutter pub get      # Flutter 3.44+, Dart 3.12+
make check           # format + analyze + test — must pass before you push
```

You need a GLPI 11 server with the
[`glpimobile`](https://github.com/tankerkiller125/glpimobile) plugin installed to
run the app at all. `dev-env/` in the original working tree provisions one with
Docker; any GLPI 11 instance works.

For Android builds you need JDK 21 (not a JRE) and the
`platforms;android-37.0` SDK package — note the minor-versioned name.

## Ground rules for changes

- **`make check` must pass.** CI runs `dart format --set-exit-if-changed`,
  `flutter analyze` and `flutter test`.
- **Anything that writes needs an offline test.** The whole app is built on the
  premise that a write survives no-signal. If you add an outbox op, add a
  drainer test, and verify one round-trip on a device with the radio off.
- **Anything touching auth, sync or the API client needs a unit test.** These
  are the parts where a silent regression costs someone their session or their
  data.
- **Verify server behaviour, don't assume it.** GLPI returns `200` for writes it
  ignores. If you add an API call, `curl` it and read the row back before
  building UI on top of it.
- **Don't add a plugin endpoint if the high-level API already covers it.** The
  plugin exists for verified gaps only.
- New user-visible strings go in `lib/l10n/app_en.arb` (and `app_fr.arb` if you
  can); run `make l10n`.

## Database migrations

The drift schema is at **v13**. Adding a table or column without bumping
`schemaVersion` and writing an `onUpgrade` step means existing installs crash
with `no such table` — this has happened. Test the upgrade path against an app
that was already installed, not just a fresh one.

## Pull requests

- One logical change per PR, with a description of how you verified it —
  ideally "ran X on a device, offline, saw Y".
- Note any GLPI version you tested against.
- **If you used an AI assistant, say so.** Most of this repository was written
  that way (see [AI-DISCLOSURE.md](AI-DISCLOSURE.md)); disclosing it is normal
  and simply tells reviewers where to look hardest.

## Reporting bugs

Include the GLPI version, the plugin version, the device and OS, whether the
device was online, and — if the screen went blank or grey — the text the inline
error widget rendered. A grey region almost always means a widget threw.

Security issues go to [SECURITY.md](SECURITY.md), not the public tracker.
