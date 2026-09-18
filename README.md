# GLPI Mobile

An offline-first native mobile client (Android + iOS, Flutter) for
[GLPI](https://glpi-project.org/) 11, built for **technicians in the field**.

Everything on screen is rendered from a local database, and every write goes
through an outbox that drains when there is signal — so the app works on a
client site with no bars, in a basement, or on a plane, and reconciles when the
connection comes back.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Flutter](https://img.shields.io/badge/Flutter-3.44%2B-02569B)
![GLPI](https://img.shields.io/badge/GLPI-11.0%2B-orange)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-lightgrey)

> ### 🤖 Built with AI
>
> **Substantially all of the code, tests and documentation in this repository
> was written by an AI assistant** (Anthropic's Claude, via Claude Code), working
> from a human maintainer's direction and reviewed, run and verified on real
> devices against a live GLPI 11 server before each change landed.
> This is disclosed up front so you can weigh it when deciding whether to deploy
> it. Read [AI-DISCLOSURE.md](AI-DISCLOSURE.md) for the full account of what that
> means, what was verified and how, and what you should check yourself.

It needs a companion GLPI plugin —
**[GLPI Mobile Plugin](https://github.com/bijstaan/glpi-mobile-plugin)** — which is what
makes passwordless pairing, push notifications and the endpoints GLPI's REST API
doesn't publish possible.

---

## Status

Early but broadly complete: the Assistance module (tickets, changes, problems),
service-catalog ticket intake, assets and management browsing, planning,
projects, reminders, knowledge base, RSS and reservations are all implemented,
offline-capable and verified on-device against GLPI 11.0.8.

It has **not** yet been run at scale in production, published to an app store,
or independently security-reviewed. Treat `0.1.0` as a first public release:
useful, honest about its limits, and looking for real-world feedback.

## Requirements

| | |
| --- | --- |
| **Server** | GLPI **11.0** or newer, with the high-level API enabled (*Setup → General → API*) |
| **Plugin** | https://github.com/bijstaan/glpi-mobile-plugin installed and active |
| **Android** | 7.0+ (API 24). Camera permission for QR pairing; notification permission for push |
| **iOS** | 15+ (the floor Firebase's iOS SDK sets). Requires a Mac and an Apple developer account to build; APNs for push |
| **Build** | Flutter 3.44+ / Dart 3.12+, JDK 21, Android SDK with `platforms;android-37.0` |

## Getting started

### 1. Install the plugin on your GLPI server

```sh
cd /var/www/glpi/plugins
git clone https://github.com/bijstaan/glpi-mobile-plugin.git glpimobile
```

Then *Setup → Plugins → GLPI Mobile → Install → Enable*. The directory **must**
be named `glpimobile`. On install it creates its own OAuth client and keeps the
secret server-side — there is nothing to copy into the app. Full instructions
live in that repository's README.

### 2. Install the app

Grab an APK from [Releases](https://github.com/bijstaan/glpi-mobile-app/releases),
or [build it yourself](#building-from-source). There is no Play Store or App
Store listing yet.

### 3. Pair a device

1. In the app, enter the GLPI server URL.
2. In GLPI web, sign in as the technician and open **My Settings → Mobile app**.
3. Scan the QR code with the app — or use *"Enter the code manually"* and type
   the short code printed under it.

That's it. **No password, client id or client secret is ever typed into the
app.** Because the QR is produced by an authenticated web session, whatever
protects your GLPI login — SSO, 2FA, LDAP — protects pairing too.

## How the app is built

### Offline-first, not offline-tolerant

The UI reads **only** local `drift` (SQLite) streams; it never awaits the
network to paint. Every mutation is a single transaction that writes the
optimistic change *and* an outbox row (`pending_ops`) together, and only the
sync engine talks to the server.

That means a technician can reply to a ticket, log a task with a duration,
change status, add or remove actors, attach a photo, link an asset, submit a
service-catalog form, edit change/problem analysis fields, reschedule a planning
event or file a whole new ticket **with no connectivity at all** — and see it
reflected immediately. When signal returns, the outbox drains in order, per
ticket, with exponential backoff.

Two properties make that safe rather than merely optimistic:

- **Idempotency.** Every queued write carries a UUID marker embedded as an HTML
  comment (`<!-- op:… -->`, which survives GLPI's sanitiser) or a marker column
  server-side. A retry after a lost response re-adopts the existing object
  instead of creating a duplicate.
- **Dependency resolution.** Ops queued against an object that doesn't exist
  yet — an attachment on a ticket composed offline, a link to a
  not-yet-created ticket — carry a `0` sentinel that the drainer resolves at
  execution time, once the create has landed.

Writes that genuinely can't succeed (a rejected reservation, a permission error)
surface in a **Needs attention** screen where they can be retried or discarded,
rather than vanishing.

### Staying signed in for weeks

A technician pairs once and keeps working; the access token lasts an hour and is
renewed behind the scenes, with the pairing's one-month lease extended each time
the app refreshes. A device untouched for ~30 days expires on its own.

**The app does not hold the OAuth refresh token, and that is the point.** GLPI
revokes a refresh token the instant it is exchanged, so an app holding one is a
single dropped response away from being locked out with no recovery but a
re-scan. Instead pairing returns a **device credential that never rotates**; the
plugin stores the rotating GLPI refresh token against that device, encrypted.

Failure handling is deliberately asymmetric, because confusing these two cases
is how a busy server signs out every technician at once:

| What happened | Server says | App does |
| --- | --- | --- |
| Device unknown, revoked, or its grant is dead | `401` | Wipe credentials, return to sign-in |
| Broker can't reach GLPI — timeout, 5xx, offline | `503` | Keep the pairing, retry later |

Admins can revoke any device from *Setup → GLPI Mobile → Paired devices*; a lost
phone loses access within the hour.

> **GLPI quirk worth knowing:** a dead access token comes back as HTTP **400**,
> not 401 — `Router::handleRequest` catches the OAuth exception and returns
> `{status: ERROR_INVALID_PARAMETER, title: 'Invalid OAuth token'}`. Matching on
> 401 alone means a revoked token never triggers a refresh and the app quietly
> serves stale data. `isTokenChallenge()` matches both.

### Push notifications, without a mandatory Google dependency

Ticket events — assigned to you, assigned to your group, approval requested, new
reply, new or assigned task — are enqueued by the plugin and delivered from
cron, including to a killed app. Transports, in the order the app tries them:

- **UnifiedPush** (Android, Firebase-free). Point the plugin at a self-hosted
  push server such as [ntfy](https://ntfy.sh/) and install a UnifiedPush
  distributor on the device. Payloads are encrypted with self-generated VAPID
  keys (RFC 8291 / 8292, implemented in the plugin in plain PHP), so no
  third-party account is involved at all.
- **FCM** (Android fallback when no distributor is installed). There is **no
  baked-in `google-services.json`**: Firebase is initialised at runtime from
  config the app fetches from your server, so one published APK works against
  each self-hosted instance's own Firebase project. Enter your project's client
  config *and* a service account under *Setup → GLPI Mobile*.
- **APNs** (iOS). Provide an Apple `.p8` key, key id, team id and bundle id in
  the same place, and enable the Push Notifications + Background Modes
  capabilities in Xcode.

Tapping a notification deep-links to the ticket, from a cold start too.

### Switching entity

GLPI scopes nearly everything by entity — which tickets exist, which categories
and locations are offered, and, for writes, **which entity a new ticket is filed
into**. Technicians covering several client entities switch from the navigation
drawer (the entity sits under the account name, because it is part of "who am I
right now") or from Settings, with an optional sub-entity include and a profile
picker for multi-profile users. Any surface can trigger it: the shell watches
the working context, not the button that changed it.

Two things make that safe:

**Caches are reset, not blended.** Synced rows from the previous context are
dropped and refetched; anything the outbox still owns — a ticket composed
offline, a queued reply, an attachment mid-upload — survives untouched.

**Queued writes stay in the entity they were written in.** Each op records its
entity at enqueue time and the drainer replays it in that entity
(`EntityScope`, a zone-scoped header override) no matter where the technician
has moved since. This is not theoretical: posting to a Delta ticket while the
header says Acme returns `403 ERROR_RIGHT_MISSING`, so without pinning, a reply
written offline would fail permanently the moment someone switched entity.

The entity tree is cached, so switching works with no signal — which is exactly
when a technician arrives on a client site.

## What the app does

### Assistance: tickets, changes and problems

All three ITIL objects run through **one code path**, mirroring GLPI's own
`CommonITILObject`: tables carry an `itemtype` discriminator, and GLPI's
high-level API is already generic (`/Assistance/{itemtype}/…`). Switch modules
from the app bar; each keeps its own queue and its own status set (Changes add
Evaluation / Testing / Qualification / Applied / Cancelled / Refused; Problems
use Accepted / Under observation).

- **Queue** — Mine / My groups / Unassigned, with search, status, priority,
  category filters and sorting, all evaluated locally so they work offline.
- **Detail** — requester, assignees and observers (editable), category,
  urgency and impact with GLPI's **derived** priority (fetched from your
  instance's own priority matrix, not a hardcoded one), status, location,
  entity, SLA due date with an at-risk badge, and the full timeline.
- **Timeline** — followups, tasks (with durations, done/todo, and a running
  **timer** that pre-fills the duration when stopped), solutions and approvals.
  Private notes are unmistakable rather than politely greyed out.
- **Attachments** — camera or gallery, uploaded through the plugin, with
  thumbnails and a full-screen viewer.
- **Relationships** — every pair GLPI allows (ticket↔ticket, change↔ticket,
  change↔problem, problem↔ticket, and same-type links with duplicate-of /
  child-of / parent-of), resolved in both directions.
- **Analysis fields** — change impact, control list, rollout and backout plans,
  checklist; problem impact, cause and symptom.

### Ticket intake through the Service Catalog

New tickets are filed through **GLPI's own Service Catalog forms**, not an
app-invented field set, so your instance's questions, mandatory rules,
visibility conditions and destination mapping apply exactly as they do on the
web.

**And it is arranged the way your instance arranged it.** The catalog is a
category tree, one screen per level — Back is the breadcrumb — with search
across every category, and knowledge-base articles listed beside the forms just
as the portal lists them. Two decisions are read from the server rather than
made here: GLPI's *Expand categories in the service catalog* entity setting
(a category is either a section with its forms already under it, or a row you
open) and the ordering (pinned first, then categories, then the entity's sort
strategy). The artwork is GLPI's own illustrations, not an icon set invented
for the app — a technician filing a request from a phone should be looking at
the same pictures as the person who files it from the portal. The app renders every shipped question type (text, number, email, choice
lists, GLPI dropdowns, urgency, request type, date-time, actors, user devices,
files) and evaluates conditions live.

Submission is offline-first: a placeholder ticket appears in the queue at once,
the answers drain through the outbox, and the server deduplicates by marker so a
retry can never file twice. Files picked in a form upload against the ticket the
submission creates. If an instance publishes no catalog forms, a plain
create-ticket form is offered instead.

### Everything else in the drawer

| Module | What the app does |
| --- | --- |
| **Planning** | Day/week calendar of everything GLPI schedules — ticket, change, problem and project tasks, reminders, external events — from one aggregated feed. Reschedule and re-state offline. |
| **Projects** | Projects with progress and at-risk end dates; task tree (parent/child, milestones) with percent-done and status edits. |
| **Reminders** | Personal reminders: create, edit, delete, plan into the calendar. |
| **Knowledge base** | Category browse, full-text search, article view with comments, and "attach an article" from a ticket. |
| **RSS / Reservations** | Configured feeds; bookable items with create and cancel (GLPI rejects overlaps server-side, so a clash lands in Needs attention). |
| **Assets** | One generic browser over every asset itemtype the server reports, including custom asset definitions. |
| **Management** | The same browser over contracts, suppliers, contacts, documents, licences, certificates, budgets, lines, domains, datacenters, clusters and databases. |

**Assets and Management are one browser, not thirty screens.** GLPI exposes ~30
itemtypes through an identical contract, so there is a single hub → list →
detail path keyed `(domain, itemtype, serverId)`, keeping the server payload
verbatim; a custom asset definition renders like any other type, and fields the
app doesn't model explicitly still appear under **Other fields**. Detail shows
identity, the fields a technician actually changes on site (status, location,
user, comment — each edited offline), purchase and warranty with a countdown
badge, network ports with MAC and resolved IPs, installed software, the
tickets/changes/problems logged against the asset, and attachments.

Mobile-native additions: **scan** a barcode or QR from the Assets hub to look a
code up as a serial or inventory number; **new ticket for this asset**, which
creates *and* links in one offline-capable gesture; **link asset** on any ITIL
object with search-as-you-type; **reserve** on reservable assets; expiry badges
on contracts, certificates and licences; and tap-to-call / mail / maps on
suppliers and contacts.

### What your profile can do

The app shows what your GLPI profile allows and nothing else. Rights come with
the session (`active_profile.rights` — the same bitmask map GLPI builds its own
menus from), are re-read on every profile or entity switch, and are cached so
gating still works offline. Anything unknown is treated as *not allowed*, so a
technician is never shown a door that answers 403.

That means the drawer only lists the modules you can open — Planning, Projects,
Knowledge base, Reminders, RSS feeds, Reservations, and the Assets and
Management hubs each appear only with the matching right, and the hubs list only
the itemtypes you may read (GLPI's own `/Assets` list is the same for everyone,
so the filtering is the app's). Tickets, Changes and Problems are separate
rights in GLPI, so the module switcher offers the ones you hold and moves itself
off one you have lost. Inside a ticket the same rule applies per action:
replying, adding a task, taking the ticket (GLPI's *Associate myself* right, and
only while nobody else has it), editing the assignee field, changing a field,
writing a solution, requesting an approval, linking an asset, attaching a photo.
A profile that may only read gets a ticket it can read, without a composer that
would refuse it.

Answering an approval is the deliberate exception: GLPI lets the person the
approval was addressed to answer it whatever their rights say, so the app gates
that on being the approver, exactly as the server does.

### Server plugins the app can use

Some of what the app offers exists only when the server runs the matching
companion plugin. It asks the server once per session which of them are
installed *and which this user may use* (`GET /GlpiMobile/capabilities`), and
shows or hides whole areas accordingly — so one build works against every mix of
plugins a fleet is running, and a technician never sees a control that will
refuse them. The last-known answer is cached, so gating still works offline.

| Plugin | What the app gains |
| --- | --- |
| **glpi-signal** | Monitoring alerts with acknowledge and close, and the on-call rota. |
| **glpi-major** | Major incidents: declare from a ticket, attach tickets, post updates, resolve. |
| **glpi-kedb** | Known-error offers on a ticket ("use workaround" stages the text into the reply box), plus the searchable library. |
| **glpi-entitle** | The cover card on a ticket: which contract pays for this work, and what is not covered. |
| **glpi-change** | The change calendar, a change's scheduling picture, and active freezes. |
| **glpi-ai** | The assistant, the drafted solution, the triage suggestion, and reply review — below. |
| **glpi-sop** | The procedures attached to a ticket, answered step by step — below. |
| **glpi-presence** | Who else is on this ticket, who is typing, and who has picked the work up. |

#### The assistant (glpi-ai)

A troubleshooting conversation with the model your instance is configured for,
opened from the drawer or **from the ticket you are looking at** — the context
is resolved and rights-checked server-side, so a technician standing in front of
the problem never has to describe the ticket they already have open.

The answer **streams**. A tool-using run is four to eight vendor round trips and
takes the better part of a minute; the app shows which turn is running, which
tool is being consulted and the words as they arrive, because a still spinner
for that long reads as a crash — and a backgrounded app is a killed request.
Under each answer sits the trail of what the model actually looked at, which is
the difference between an answer from the machine and an answer from the model's
general knowledge. Past conversations are listed and resumable: a browser keeps
the panel open across navigation and a phone does not.

On a ticket the app also offers, where the server has each switched on:

- **Draft a solution** — the draft is read on screen and moved into the reply
  box; it is never sent by the app. Used or discarded is recorded, which is the
  entire measurement of whether the feature is any good.
- **Suggested triage** — category, urgency, impact and procedure proposals, each
  applied or dismissed on its own, shown against what the ticket says now.
- **Check this reply** — reads what you have typed before it goes and says what
  it would stop a colleague about (internal detail, unexplained jargon, no next
  step, tone), quoting your own words back. A clean verdict sends straight away;
  nothing is ever rewritten for you.

#### Procedures (glpi-sop)

The checklists your instance attaches to tickets, answered *while doing the
work* — which is the point of having them on a phone, since a good share of that
work happens in front of a rack. Steps show their branch numbering, their
guidance and who answered what; checkboxes, yes/no, text, numbers, choices,
dates and multi-choice are answered in place, a step can be skipped with a
reason or annotated, and a ticket-step raises its ticket.

Answers are **not** queued offline, unlike ticket writes: a step marked done is
a compliance claim about a moment, the server decides whether the answer is even
valid, and a queued answer that fails validation an hour later — after you have
left the site — is worse than one you could not give. Every answer comes back as
the whole run recomputed, because one answer can open a branch, close another,
and unblock the ticket.

#### Presence (glpi-presence)

Who else has this ticket open, who is typing, and who has claimed the work —
with claim, take-over and hand-back. The person on a phone is the one out at a
site, least likely to know what the office already started. The app announces
itself far more slowly than the web bar does (a phone screen is off most of the
time, and radio wake-ups cost battery); the server expires presence on its own
TTL, so a slow beat simply reads as coarser arrival and departure.

### Formatted text

GLPI stores descriptions, followups, tasks, solutions, analysis fields and KB
articles as **HTML**. `RichContent` renders it — paragraphs, lists,
bold/italic/underline, headings, quotes, code, tables, tappable links —
replacing the tag-stripping that used to flatten a numbered procedure into one
unreadable sentence. Embedded images (served from authenticated document URLs)
become a labelled chip pointing at Attachments rather than a broken box.

`RichEditor` composes it: the quick composer stays a plain field for one-liners
(its text wrapped as HTML so line breaks survive), and an **A** button opens a
full editor used for solutions, approval comments, KB comments and analysis
fields. Editing round-trips — GLPI's HTML loads with formatting intact and comes
back as HTML. Plain text and HTML are told apart explicitly rather than assumed,
because a lot of real GLPI content is plain and feeding it to an HTML renderer
silently eats the line breaks.

### Phones, tablets and foldables

Layout follows the **window**, not the device — a folded foldable and a phone
are the same thing, and so are a tablet and a phone in split-screen.

| Window | Navigation | Content |
| --- | --- | --- |
| Compact (< 600 dp) | Bottom bar | One pane; tapping a ticket pushes its screen |
| Medium (600–839 dp) | Navigation rail | One pane |
| Expanded (≥ 840 dp) | Extended rail | **List and detail side by side**; tapping swaps the detail in place |

On a foldable the split lands **on the hinge**, in both the flat and half-opened
postures, and folding collapses to a single pane live without a restart. Bottom
sheets cap at 640 dp and centre instead of stretching; the asset grid grows
columns by available width; KB articles are capped to a readable measure.

### Accessibility

Every surface is built to be usable with a screen reader, at a large system font
size, and by someone who cannot separate the status colours:

- **Nothing means anything by colour alone.** Status, priority, SLA and privacy
  always carry words as well as a hue.
- **Semantic colours are re-derived for contrast** where they become text. The
  GLPI palette is tuned to work as a 4px card edge; several of those colours sit
  near 2:1 as a label, so `AccentColors`/`ensureContrast` darken or lighten them
  until they clear WCAG AA on the surface behind them — hue intact.
- **A row is one node, not eight.** A queue card reads as *"Ticket 42. Email
  outage. Priority High. Status New. Alice, Acme, Hardware. Updated 4 hours
  ago."*, and the terse on-screen forms (`4h`, `in 3h 20m`) are expanded for the
  reader.
- **Every gesture has a non-gesture equivalent.** Pull-to-refresh — which a
  screen reader would otherwise swallow whole — is also a "Refresh" action in
  TalkBack's actions menu; long-press to reschedule announces itself.
- **Camera-only flows offer the alternative first.** Pairing starts on manual
  code entry when a screen reader is active; the asset scanner always shows a
  code field.
- **Layouts survive 200% text.** Detail rows stack instead of truncating, and
  the text scaler is never clamped.

The rules, the tests that enforce them and the known gaps (chiefly: not yet
walked through with a real screen reader on a device) are in
[docs/accessibility.md](docs/accessibility.md).

## Building from source

```sh
flutter pub get
make check                 # dart format --set-exit-if-changed + flutter analyze + flutter test
flutter build apk --release
```

Prerequisites that bite in this project specifically:

- **JDK 21.** A system Java 25 *JRE* has no compiler; point Gradle at a real JDK
  (`org.gradle.java.home` in `android/gradle.properties`).
- **`compileSdk = 37`**, required by `flutter_secure_storage` 11. The SDK
  package is named `platforms;android-37.0` — minor-versioned; plain
  `android-37` does not exist.
- **Core library desugaring** and a `tink` exclusion are already configured in
  `android/app/build.gradle.kts`; don't remove them or
  `flutter_local_notifications` and UnifiedPush stop building.
- `flutter build apk | tee log` **masks the real exit code** — check it.
- **`cmake` must be on `PATH` to run the tests.** `webcrypto` builds a native
  host asset through CMake, so `flutter test` fails with "Failed to find cmake
  version: latest" without it. Any system `cmake` works; the Android SDK also
  ships one at `$ANDROID_HOME/cmake/<version>/bin`.

### Signing a release build

`android/app/build.gradle.kts` uses a release signing config when
`android/key.properties` exists, and falls back to the debug key when it doesn't
(so `flutter run --release` still works out of the box). To sign properly:

```sh
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
cat > android/key.properties <<'EOF'
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
EOF
```

`key.properties` and `*.jks` are git-ignored. **Never commit them.**

### iOS

Building for iOS needs a Mac with Xcode. The APNs plumbing is written
(`AppDelegate.swift`, a `com.bijstaan.glpi/push` method channel,
`Runner.entitlements`, the background mode) but has **not** been built or
verified on a real device — see [Known limitations](#known-limitations). Enable
the *Push Notifications* and *Background Modes → Remote notifications*
capabilities, and set `aps-environment` to `production` for release builds.

## Continuous integration and releases

`.github/workflows/ci.yml` runs on every push to `main`, every pull request, and
on demand:

| Job | Runner | What it proves |
| --- | --- | --- |
| Format, analyze, test | ubuntu | `dart format`, `flutter analyze`, `flutter test` (live tests stay skipped — they need a real GLPI) |
| Build debug APK | ubuntu | Android still links; the APK is attached to the run |
| Build iOS (unsigned) | macOS | The Xcode project, `AppDelegate.swift` and every iOS plugin still compile, with no Apple account involved. An unsigned IPA is attached to the run |

Flutter is pinned (`FLUTTER_VERSION`) so a red build means our code changed, not
the toolchain. Bump it deliberately.

### Cutting a release

Tags are created by hand. `version:` in `pubspec.yaml` is the source of truth —
the release run refuses to publish if the tag disagrees with it:

```sh
# 1. bump pubspec.yaml (version: 0.2.0+2) and CHANGELOG.md, commit
# 2. tag and push
git tag -a v0.2.0 -m 'v0.2.0'
git push origin v0.2.0
```

`.github/workflows/release.yml` then re-runs analyze and tests, builds, and
publishes a GitHub release containing:

- per-ABI APKs (`arm64-v8a`, `armeabi-v7a`, `x86_64`) and a universal APK,
- an App Bundle (`.aab`) — only when a signing keystore is configured,
- an IPA, signed if Apple credentials are configured and otherwise clearly
  marked `-unsigned`,
- `SHA256SUMS.txt` over everything.

A version containing a hyphen (`v0.2.0-rc.1`) is published as a pre-release.
Running the workflow manually builds the same artifacts and attaches them to the
run without creating a release.

### Release secrets

Everything is optional; the workflow degrades to debug-signed Android artifacts
and an unsigned IPA rather than failing.

| Secret | Purpose |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS` | the keystore's credentials |
| `APPLE_CERTIFICATE_BASE64`, `APPLE_CERTIFICATE_PASSWORD` | a distribution `.p12` and its export password |
| `APPLE_PROVISIONING_PROFILE_BASE64` | a `.mobileprovision` for `com.bijstaan.glpi` |
| `APPLE_TEAM_ID` | your 10-character Apple team id |

Two optional repository *variables* tune the iOS export: `APPLE_EXPORT_METHOD`
(default `ad-hoc`) and `APPLE_CODE_SIGN_IDENTITY` (default `Apple
Distribution`).

Without an Android keystore the APKs are **debug-signed**: installable, but a
user cannot upgrade in place to a properly signed build later. Configure the
keystore before the first release anyone else installs.

## Development

You need a GLPI 11 server with the
[glpi mobile plugin](https://github.com/bijstaan/glpi-mobile-plugin) installed;
any instance works. The targets below assume the Dockerised dev instance this
app was built against, at `http://localhost:8081` — which is
`http://10.0.2.2:8081` from an Android emulator, since the emulator reaches the
host through that address. Adjust the `DEV_SERVER` define for your own.

```sh
make run-dev      # run against the dev server (prefills the URL)
make run-device   # run on a USB phone, pointing at this machine's LAN address
make apk          # debug APK
make l10n         # regenerate localizations from lib/l10n/*.arb

flutter test                        # 137 unit + widget tests
flutter test --run-skipped -t live  # live tests against a real GLPI (skipped by default)
```

Debug builds pre-fill the server URL from `--dart-define=DEV_SERVER=…`. Cleartext
HTTP is permitted **only** in the Android debug manifest and via
`NSAllowsLocalNetworking` on iOS; release builds are HTTPS-only.

### Project layout

```
lib/
  core/
    api/           high-level API client, DTOs, RSQL, itemtype helpers
    auth/          QR pairing flow, token manager, device credentials, entity context
    db/            drift schema (v13), migrations, cache reset
    repositories/  one per domain — the only writers to the cache
    sync/          outbox writer, drainer, sync service, entity scoping
    push/          UnifiedPush / FCM / APNs wiring
    widgets/       RichContent, RichEditor, shared tiles, inline error widget
  features/        one folder per screen area: providers + UI
  l10n/            app_en.arb, app_fr.arb
test/
  unit/            pure logic: conditions, matrices, drainer, repositories
  widget/          layout + onboarding
  live/            real-server round-trips (tagged `live`, skipped by default)
docs/
  api-notes.md     verified GLPI 11 API behaviour
  roadmap.md       phase plan, status, deviations log, traps found the hard way
```

Verified server quirks — the ones that cost hours — are collected in
[`docs/api-notes.md`](docs/api-notes.md) and appendices D/E of
[`docs/roadmap.md`](docs/roadmap.md). A sample, because they will bite anyone
writing against this API:

> **Writes to `/Assets` and `/Management` key on *schema* field names, not
> database columns.** `{"status": 3}` works; `{"states_id": 3}` returns **200 and
> silently changes nothing.** Never trust a 200 — read the row back.

> **A widget that throws is painted as a plain grey box in release builds** — no
> error, no log. `installInlineErrorWidget()` replaces that with an inline
> message naming the exception. This behaviour hid two separate real bugs before
> it was added.

## Known limitations

- **iOS is unverified at runtime.** It now compiles in CI on every push, so the
  Xcode project and the APNs plumbing are known to build — but the app has never
  been *run* on Apple hardware, and APNs delivery is untested end-to-end.
- **One build warning is upstream and cannot be fixed here.** `mobile_scanner`
  and `unifiedpush_android` still apply the Kotlin Gradle Plugin, which Flutter
  warns will become a build error in a future release. The fix belongs to those
  packages.
- **Push was not re-verified on a device after the Firebase 4 /
  flutter_local_notifications 22 upgrade.** It compiles, analyzes and tests
  clean, but the delivery path (UnifiedPush, FCM, the killed-app background
  isolate) has not been exercised on hardware since.
- **Localization is partial.** English and French exist, but screens added after
  the Assistance module are English-only pending an `.arb` sweep. The
  accessibility labels are inline English strings for the same reason, and
  should be localized in that same pass.
- **Accessibility has not been walked through with a real screen reader.** The
  semantics tree, tap targets and colour contrast are asserted in the test
  suite; TalkBack/VoiceOver pronunciation and focus order on a device have not
  been checked by hand. See [docs/accessibility.md](docs/accessibility.md).
- **Release builds are debug-signed** until you supply `key.properties`.
- **No app-store distribution** — install the APK, or build it yourself.
- Documents open by caching and copying the path; there is no external "open
  with" handoff yet.
- Cartridge/consumable stock, contract costs, `Contract_Item`, domain records and
  datacenter room/rack listings surface only under **Other fields**.
- No independent security review has been performed.

## Contributing

Issues and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
`make check` must pass, and anything touching the sync engine, auth or the API
client should come with a test. If you use an AI assistant to write a
contribution, say so in the PR; that is normal here, not a black mark.

## Security

Please don't file security issues in the public tracker — see
[SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE) © 2026 Bijstaan.

GLPI is a registered trademark of Teclib'. This project is an independent
client and is not affiliated with or endorsed by Teclib' or the GLPI project.
