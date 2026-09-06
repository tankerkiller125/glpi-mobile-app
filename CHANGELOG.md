# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- **New request is the service catalog, arranged the way the instance arranged
  it** (needs the companion plugin's `/catalog` route). Categories, one screen
  per level so Back is the breadcrumb, and search across every category. The
  two display decisions are the server's: GLPI's *Expand categories in the
  service catalog* entity setting decides whether a category is a section with
  its forms under it or a row you open, and ordering (pinned first, then
  categories, then the entity's sort strategy) is taken as given rather than
  re-sorted — a phone that disagrees with the portal is worse than one that
  looks plain. Knowledge-base articles appear beside the forms, as they do on
  the web. Against an older plugin the screen falls back to the flat list.
- **The catalog draws GLPI's own illustrations.** They live in a single 1.8 MB
  SVG sprite the web page references by fragment; the plugin lifts out the
  symbols a screen is about to draw and the app caches them for the session.
  Anything it cannot draw — an older server, an unknown id, no connection —
  falls back to the icons the app drew before.
- **The AI assistant, on a phone (needs glpi-ai 0.7+).** A troubleshooting
  conversation opened from the drawer or from the ticket in front of you, with
  the answer **streamed**: the app shows which turn is running, which tool is
  being consulted and the words as they arrive. A tool-using run is four to
  eight vendor round trips, and a still spinner for a minute reads as a crash —
  on mobile it also gets the app backgrounded, which kills the request. Past
  conversations are listed and resumable, and each answer carries the trail of
  what the model actually looked at.
- **glpi-ai on the ticket screen**: draft a solution (read it, then move it into
  the reply box — the app never sends it), act on the triage suggestion field by
  field against what the ticket says now, and **check a reply before sending**
  it, which quotes your own words back with what it would stop a colleague
  about. Each is capability-gated and entity-gated: the app re-asks the server
  what it will answer in the entity you are actually working in, because that
  gate is not a session property.
- **Procedures from glpi-sop.** The checklists attached to a ticket, answered
  step by step while doing the work: branch numbering, guidance, per-step notes,
  skip-with-a-reason, and ticket-steps that raise their ticket. Deliberately not
  offline-queued — a step marked done is a compliance claim about a moment, and
  the server owns whether the answer was valid.
- **Presence from glpi-presence.** Who else has this ticket open, who is typing,
  and who has claimed the work, with claim / take over / hand back. The app
  beats much more slowly than the web bar: a phone screen is off most of the
  time and the server expires presence on its own TTL.
- The assistant's failure states say what is wrong in the app's own words (a
  dropped connection is not dio's error string) and carry a **Retry**, since the
  conversation is kept alive across navigation and would otherwise stay in
  whatever state it was first opened in.
- A `decodeSse` helper for `text/event-stream` bodies, with unit tests over the
  three framing details that are easy to get wrong and impossible to notice from
  a passing happy path (frames end at a blank line, `data:` lines accumulate, a
  truncated payload is dropped rather than thrown).

- **An accessibility pass over the whole app.** Screen-reader semantics, contrast
  and large-text behaviour are now part of the shared widgets rather than
  per-screen afterthoughts. See [docs/accessibility.md](docs/accessibility.md).
  - Semantic colours (status, priority, SLA, planning) are re-derived through a
    new `ensureContrast`/`AccentColors` helper wherever they are drawn as text or
    as a meaningful mark, so they clear WCAG AA (4.5:1) and 3:1 respectively in
    both themes. Several shipped colours were close to 2:1 as a label.
  - Cards, detail rows and list tiles read as one sentence instead of a run of
    fragments, and the abbreviated forms (`4h`, `in 3h 20m`, `1h 30m`) are
    expanded for the reader.
  - Icon-only controls all carry names; custom tap areas reach the 48dp target;
    the timeline's task toggle is a real checkbox with checked state.
  - `AccessibleRefresh` replaces `RefreshIndicator` everywhere, adding a
    "Refresh" custom action — a screen reader takes over the swipe, so
    pull-to-refresh was otherwise unreachable.
  - Connectivity changes, queued replies, discarded changes and scan results are
    announced; the duration picker's readout is a live region.
  - Detail rows stack instead of truncating past ~1.4× text scale; chip and date
    strips grow with the font size.
  - QR pairing starts on manual code entry when a screen reader is active, and
    both camera viewfinders are labelled.
  - Section and sheet titles are marked as headings for heading navigation.
- 42 new tests covering contrast, spoken labels and the semantics tree,
  including Flutter's tap-target, labelled-tap-target and text-contrast
  guidelines in both themes.

### Fixed

- **A bottom sheet could put its drag handle behind the status bar**, where
  pulling down opens the notification shade instead of closing the sheet —
  leaving no way out of a modal that owns the screen. Sheets that sized
  themselves to a fraction of the *window* (the user and category pickers, the
  entity switcher, the asset picker) were adding the keyboard's height on top
  of that fraction, so with the keyboard up the sheet was taller than the
  screen. They now size against what is actually left, every modal sheet is
  opened with `useSafeArea: true` and a height ceiling from `sheetConstraints`,
  and a widget test asserts the handle stays below the status bar with a
  keyboard up.
- The queue card showed ticket status labels for changes and problems, so a
  change's status 9 read as "Status 9" instead of "Evaluation".
- The "PRIVATE" badge used white text in both themes; on the dark theme's light
  amber that was around 1.7:1. The ink is now chosen per fill.

### Changed

- **Application id is now `com.tankerkiller125.glpi`** (was `tech.norsewave.glpi`)
  on both platforms, along with the Kotlin package, the iOS bundle ids and the
  `…/push` method channel. Anyone running FCM must register a new Android app
  under the new package name — a token minted for the old one is not deliverable
  — and set the APNs bundle id in the plugin to match.

## [0.2.0] — 2026-08-09

### Changed

- **Minimum iOS version is now 15.0** (was 13.0). Firebase's iOS SDK 12, which
  `firebase_core` 4 and `firebase_messaging` 16 build on, sets that floor.
- Upgraded `firebase_core` 3 → 4, `firebase_messaging` 15 → 16 and
  `flutter_local_notifications` 18 → 22, whose `initialize()` and `show()` moved
  to named parameters. Everything else was already at the newest version its
  constraints allow.
- Added `cupertino_icons`, which `flutter_quill` needs for the Cupertino glyphs
  it reaches; without it those icons would have rendered as empty boxes.

### Fixed

- iOS builds failed outright: `AppDelegate.swift` used the iOS 14+ `.banner`
  presentation option against a lower deployment target. The iOS target now
  compiles in CI on every push.
- Android builds failed on any machine but one: `android/gradle.properties`
  pinned `org.gradle.java.home` to a developer's home directory.

## [0.1.0] — 2026-08-08

First public release. Requires GLPI 11.0+ and the
[`glpimobile`](https://github.com/tankerkiller125/glpi-mobile-plugin) plugin.

### Added

- **Passwordless pairing.** Scan a QR from *My Settings → Mobile app* in GLPI;
  no password, client id or secret is entered on the device. Long-lived
  sessions backed by a non-rotating device credential, with admin revocation.
- **Offline-first architecture.** UI reads only local drift streams; every write
  is an optimistic change plus an outbox row in one transaction, drained with
  per-object ordering, backoff, idempotency markers and dependency resolution.
  Failed writes surface in a Needs attention screen.
- **Assistance module** for tickets, changes and problems through one code path:
  queues (Mine / Groups / Unassigned) with local search and filtering, rich
  detail with editable actors, category, urgency/impact with server-derived
  priority, status, SLA due badges, and full timeline (followups, tasks with
  durations and a timer, solutions, approvals).
- **Ticket intake through GLPI's Service Catalog forms**, including every
  shipped question type, live visibility conditions, and offline submission
  deduplicated server-side.
- **Attachments** from camera or gallery, offline-queued, with thumbnails and a
  full-screen viewer.
- **ITIL relationships** across every pair GLPI allows, resolved bidirectionally,
  plus change and problem analysis fields.
- **Push notifications** over UnifiedPush (Firebase-free), FCM (configured at
  runtime, so no baked-in `google-services.json`) or APNs, with deep links from
  a cold start.
- **Planning, Projects, Reminders, Knowledge base, RSS and Reservations.**
- **Assets and Management** as one generic browser over every itemtype the
  server reports, with barcode scanning, on-site field edits, warranty and
  contract expiry badges, network ports, installed software, and asset↔ticket
  linking.
- **Entity and profile switching** with cache reset and entity-pinned queued
  writes, working offline from a cached entity tree.
- **Rich text** display and editing for GLPI's HTML content.
- **Responsive layout** for phones, tablets and foldables, with a two-pane
  expanded layout that lands on the hinge.
- English and French localization (partial for modules added after Assistance).

### Known limitations

- iOS is written but has never been built or verified; APNs is untested.
- Release builds are debug-signed until `android/key.properties` is supplied.
- No independent security review; no production deployment at scale.

[Unreleased]: https://github.com/tankerkiller125/glpi-mobile-app/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tankerkiller125/glpi-mobile-app/releases/tag/v0.1.0
