# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

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
