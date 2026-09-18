# AI disclosure

This project was built with AI, and says so plainly because you deserve to know
what you are installing on a technician's phone and pointing at your helpdesk.

## The short version

**Substantially all of the source code, tests and documentation in this
repository — including this file — was written by Anthropic's Claude, operating
as an agent through [Claude Code](https://claude.com/claude-code).** A human
maintainer directed the work, made the product and architecture decisions,
supplied the GLPI environment, ran and watched the on-device verification, and
decided what was good enough to keep. But the characters in these files were, in
the overwhelming majority, produced by a model rather than typed by a person.

The same is true of the companion GLPI plugin,
[glpimobile](https://github.com/bijstaan/glpi-mobile-plugin).

## What that means in practice

### How it was actually built

Work proceeded feature by feature, and each one followed the same loop:

1. **Verify the server contract first.** Endpoints were exercised with `curl`
   against a real GLPI 11.0.8 instance before any client code was written. The
   surprises this caught are recorded in [`docs/api-notes.md`](docs/api-notes.md)
   and the appendices of [`docs/roadmap.md`](docs/roadmap.md).
2. **Implement**, then run `dart format`, `flutter analyze` and the test suite.
3. **Verify on a device.** Every feature was exercised on an Android emulator
   against the live server — including at least one offline round-trip for
   anything that writes: turn the radio off, perform the action, confirm the
   server is untouched, reconnect, confirm it lands exactly once.
4. **Record what went wrong.** Bugs found during verification were fixed and
   written down, along with the trap that produced them.

That loop is why the READMEs are full of specific, unglamorous warnings: they are
failures that actually happened, not advice copied from a tutorial.

### What is genuinely verified

- **137 unit and widget tests** run in CI and locally.
- **Live integration tests** (`flutter test --run-skipped -t live`) perform real
  round-trips against a GLPI server: pairing, token refresh, writes, solutions
  and approvals, push registration.
- Every feature listed in the README was exercised by hand on an Android
  emulator against GLPI 11.0.8, and offline behaviour was tested by actually
  disabling the radio rather than by mocking it.
- Several bug classes were caught this way and fixed — a missing drift
  migration, offline writes being abandoned instead of queued, an entity switch
  corrupting queued writes, a two-pane layout blanking on an empty list, form
  fields silently failing on inconsistently-typed server data.

### What is not verified

- **iOS has never been built or run.** No Mac was available. The APNs code is
  written and reviewed but untested end-to-end.
- **No independent security review** — human or otherwise — has been performed
  on the auth/pairing design, the plugin's endpoints, or the Web Push crypto
  implementation. The RFC 8291 encryption was checked against the RFC's own test
  vectors, which is necessary but not sufficient.
- **No production deployment at scale.** Testing used a dev instance with tens
  of tickets, not a live helpdesk with tens of thousands.
- Localization coverage, accessibility and performance under large datasets have
  had far less attention than correctness.

## What you should do about it

The honest recommendation is the same one you should apply to any code from an
unfamiliar author, held slightly more firmly:

- **Read the diff before you deploy it**, especially `lib/core/auth/`,
  `lib/core/sync/` and the plugin's controllers. They are the parts that hold
  credentials and write to your data.
- **Pilot it** with a couple of technicians before rolling it out.
- **Review the plugin's permissions model** against your own policy — it adds
  unauthenticated endpoints by design (a pairing code and a device credential
  are themselves the credentials), and that is a decision worth agreeing with
  rather than inheriting.
- **Report what you find.** Bugs from real deployments are the most valuable
  thing this project can receive right now.

## Attribution and licensing

The code is released under the [MIT License](LICENSE), copyright the maintainer.
AI-generated output does not change the license you receive or the obligations
attached to it. No claim is made that the model's output is free of
similarity to other code; the implementation was written against GLPI's public
API and its own source, and no third-party code was knowingly copied into this
repository.

Contributions written with AI assistance are welcome. Say so in the pull
request — not as a confession, but because knowing how a change was produced
helps reviewers aim their attention.
