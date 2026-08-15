# GLPI Mobile — full-portal roadmap & build spec

This document is an **autonomous execution spec**: an agent should be able to
build every feature below, in order, without human input. It defines what each
feature looks like, which existing code to imitate, the data contracts, and how
to verify completion. When something is ambiguous, apply the
[decision rules](#decision-rules-when-in-doubt) — never stop to ask.

Priority order: **Assistance: Planning** → **Tools (Projects, Reminders,
Knowledge Base, RSS, Reservations)** → **Assets** → **Management**.
Administration and Setup are out of scope.

---

## How to work this document (agent operating manual)

**Standing invariants (never violate):**
1. **Offline-first.** Every screen renders from drift streams. Every write is
   one transaction: optimistic local change + `pending_ops` outbox row, drained
   by the existing `OutboxDrainer`. Creates carry an op-uuid idempotency marker
   dedupable server-side.
2. **Plugin only where the HL API is silent.** Use `/Assistance`, `/Project`,
   `/Tools`, `/Knowledgebase`, `/Assets`, `/Management` first; add
   `dev-env/glpi/plugins/glpimobile/src/*Controller.php` endpoints only for
   verified gaps. Follow `ItilController.php` as the pattern.
3. **Imitate existing UI.** Before building a screen, read the named prototype
   files. Reuse `_InfoTile`-style rows, `StatusChip`, `DueBadge`, `OptionSheet`,
   `ComposeSheet`, `UserPicker`, `AttachmentsSection`, `LinkedItemsSection`,
   card style from `ticket_card.dart`. New shared widgets go in
   `lib/core/widgets/`.

**Per-feature ritual (definition of done):**
1. Verify the server contract first with curl against the dev env
   (`http://localhost:8081`, password-grant client
   `glpi-mobile-dev-client` / `glpi-mobile-dev-secret-0123456789abcdef`,
   user `glpi`/`glpi`). Never build app code against an unverified route.
2. Plugin changes: `php -l` each file, then
   `docker exec glpi-glpi-1 php /var/www/glpi/bin/console cache:clear
   --allow-superuser` (the HL route table is cached; a container restart alone
   is NOT enough).
3. App: `flutter analyze` clean; `flutter test` green; add unit tests for every
   new outbox op (drain + offline-retry) and every pure helper.
4. Device-verify on the emulator: the happy path AND one full offline
   round-trip (`adb shell svc wifi disable` + `svc data disable` → act → prove
   the server unchanged via `docker exec glpi-db-1 mariadb -uglpi -pglpi glpi
   -e "..."` → re-enable + relaunch app → prove the server updated).
   Screenshot coordinates: screenshots render at 900×2000 but the device is
   1080×2400 — **multiply displayed coordinates by 1.2 before `adb input tap`**.
5. Seed demo data through the API where possible; delete throwaway rows after;
   keep curated demo data (it makes future verification easier).
6. Update: the Status column in this file, `README.md` (one section per
   module), and the auto-memory file `glpi-mobile-app.md` (gotchas + verified
   facts only).
7. Track work with TaskCreate/TaskUpdate; one task per numbered deliverable.

### Decision rules (when in doubt)
- **Behavior questions** → do what GLPI web does; read the GLPI source in the
  container (`/var/www/glpi/src/...`) to confirm.
- **HL API missing a route** → check for a schema first
  (`grep "schemas\['X'\]"`); if routes are absent, add a plugin endpoint
  following the existing controllers, and document it in the endpoint appendix.
- **Dart dependency conflicts** → prefer dropping the dependency and degrading
  gracefully over downgrading `flutter_secure_storage`/core deps (precedent:
  `file_picker` was dropped for `image_picker`). Record the trade-off here.
- **Rich text (HTML) rendering** → try `flutter_widget_from_html_core`; if it
  conflicts, fall back to the plain-text stripper pattern
  (`_plain()` in `ticket_detail_screen.dart`) and note the deviation.
- **A write GLPI might reject** (reservation conflicts, permission edges) →
  send it through the outbox anyway; a server rejection surfaces in the
  existing Needs Attention screen. That is acceptable UX.
- **Scope creep** → if a sub-feature isn't in this doc, don't build it; add a
  one-line note under [Deviations](#deviations-log) instead.

---

## Feature inventory & status

Source of truth for the feature list: `Html::getMenuInfos()` in GLPI core.
Update the Status column as you go: ✅ done · 🟡 in progress · ⬜ planned · ➖ out.

| Module | Feature | Status |
| --- | --- | --- |
| Assistance | Tickets, Service Catalog, Changes, Problems | ✅ |
| Assistance | Planning (calendar) | ✅ **(1)** |
| Assistance | Statistics, Recurring tickets/changes | ➖ |
| Tools | Projects | ✅ **(2)** |
| Tools | Reminders | ✅ **(3)** |
| Tools | Knowledge Base | ✅ **(4)** |
| Tools | RSS feeds, Reservations | ✅ **(5)** |
| Tools | Saved searches, Reports, Impact | ➖ |
| Assets | All itemtypes via generic browser + scan | ✅ **(6)** |
| Management | Tier 1 (Documents, Contracts, Suppliers, Contacts, Licenses, Certificates) | ✅ **(7)** |
| Management | Tier 2 (Budgets, Lines, Domains, Datacenters, Clusters, Appliances, Databases) | ✅ **(8)** |
| Carried over | `/MyWork` endpoint; status-change push; iOS/APNs build (needs Mac); generic file picking | ⬜ backlog |

**Verified API surface** (re-verify with curl before relying on it):
- `/Assistance/{Ticket|Change|Problem}` CRUD + `/Timeline` + `/TeamMember`;
  `/Assistance/ExternalEvent` CRUD; Task schema has `planned_begin`,
  `planned_end`, `state`. No aggregated calendar route.
- `/Project` + `/Project/Task` (global GET!) + `/Project/{id}/Task` + Cost + KB.
- `/Tools/{Reminder|RSSFeed|Reservation|ReservationItem|SavedSearch}` CRUD.
- `/Knowledgebase/Article|Category|…/Comment|Revision` read/write.
- `/Assets` (itemtype directory incl. custom assets), `/Assets/{itemtype}`
  CRUD, `/Assets/{itemtype}/{id}/Infocom` CRUD.
- `/Management/{SoftwareLicense|Budget|Supplier|Contact|Contract|Document|Line|Certificate|Datacenter|Cluster|Domain|Appliance|Database}` (+ ContractCost,
  DomainRecord, Document_Item, Infocom sub-schemas), `/Management/Document/{id}/Download`.
- Schemas **without routes** (need plugin endpoints): `Item_Ticket`,
  `Itil_Project`, `KnowbaseItem_Item`.
- Planning types: `ChangeTask, ProblemTask, TicketTask, ProjectTask, Reminder,
  PlanningExternalEvent` (`$CFG_GLPI['planning_types']`).

---

## Phase 0 — Navigation hub (prerequisite, small)

**Goal:** the drawer becomes the module hub mirroring GLPI's sidebar, so every
later phase just adds a destination.

**Prototype:** `lib/features/shell/primary_nav_drawer.dart` (current drawer),
`home_shell.dart`.

**Spec:**
- Drawer contents, top to bottom:
  - Header (existing account header, unchanged).
  - **Assistance** (`Icons.headset_mic_outlined`) — closes the drawer, returns
    to the shell (current behavior). The Tickets/Changes/Problems switcher
    stays in the app bar as-is.
  - **Planning** (`Icons.calendar_month_outlined`) → `/planning`
  - **Projects** (`Icons.account_tree_outlined`) → `/projects`
  - **Knowledge base** (`Icons.menu_book_outlined`) → `/kb`
  - **Reminders** (`Icons.sticky_note_2_outlined`) → `/reminders`
  - **Reservations** (`Icons.event_available_outlined`) → `/reservations`
  - **Assets** (`Icons.devices_other_outlined`) → `/assets`
  - **Management** (`Icons.business_center_outlined`) → `/management`
  - Divider, then the existing Needs Attention + Settings entries.
- All new routes are root-navigator full-screen routes
  (`parentNavigatorKey: rootNavigatorKey`) with their own back button —
  same pattern as `Routes.sync` / `Routes.settings`.
- Selected-module highlight: `ListTile(selected:)` based on current location.
- Destinations for unbuilt phases are simply absent until their phase lands
  (never show dead entries).

**Done when:** drawer shows Assistance + Settings/Sync plus the destinations of
every phase completed so far; navigation round-trips verified on device.

---

## Phase 1 — Planning (Assistance calendar)

**Goal:** a technician sees everything scheduled — ticket/change/problem tasks,
project tasks, reminders, external events — in a day/agenda view; can toggle
task done-state, reschedule, and create events/reminders; all offline.

### 1.1 Server: plugin planning feed

New `src/PlanningController.php` (register in `setup.php` `api_controllers`):

- `GET /GlpiMobile/planning?start=YYYY-MM-DD&end=YYYY-MM-DD` (authenticated)
  → JSON array of normalized events for the signed-in user. Implement by
  iterating `$CFG_GLPI['planning_types']` and calling each class's
  `populatePlanning(['who' => $uid, 'whogroup' => …, 'begin' => …, 'end' => …])`
  exactly the way `Planning::constructEventsArray` does (read that method in
  `/var/www/glpi/src/Planning.php` and mirror its options, including group
  events). Normalize each event to:

  ```json
  {
    "key": "TicketTask-42",
    "event_itemtype": "TicketTask",
    "event_id": 42,
    "parent_itemtype": "Ticket",      // null for Reminder / ExternalEvent
    "parent_id": 7,
    "parent_name": "Email outage",
    "title": "Replace switch port",   // task content excerpt or event name
    "begin": "2026-08-10 09:00:00",
    "end": "2026-08-10 10:30:00",
    "is_all_day": false,
    "state": 1                        // 0 info, 1 todo, 2 done (GLPI Planning::INFO/TODO/DONE)
  }
  ```
- Curl-verify: seed one of each of the six types with planned dates, assert all
  six appear, assert a group-assigned task appears for a member.

### 1.2 App: data layer

- drift **v9**: table `PlanningEvents` (`@DataClassName('PlanningEventRow')`):
  `localId` PK, `eventItemtype`, `eventServerId` nullable (null = created
  offline, not yet synced), `parentItemtype` nullable, `parentServerId`
  nullable, `title`, `begin`, `end`, `isAllDay`, `state`, `pending` bool.
- `PlanningRepository`: `watchDay(date)` / `watchRange(start,end)` streams;
  `refresh(start,end)` replaces non-pending rows in the window (same
  keep-pending pattern as `ItilLinkRepository.refreshLinks`). Default fetch
  window: 7 days back, 28 forward, refreshed on screen open + pull-to-refresh.
- API methods (`GlpiApi`): `fetchPlanning(start,end)`;
  `createExternalEvent/patchExternalEvent/deleteExternalEvent`
  (`/Assistance/ExternalEvent`); `createReminder/patchReminder/deleteReminder`
  (`/Tools/Reminder`); `patchProjectTask` (`/Project/Task/{id}`). ITIL task
  planning PATCH already exists (extend `setTaskState`-style method with
  `planned_begin/planned_end`).
- New op types + writer methods + drainer branches (all with unit tests):
  - `taskPlan` — payload `{plannedBegin, plannedEnd, state}`; targets an ITIL
    task (`parent itemtype` in `op.itemtype`, parent id in `ticketServerId`,
    task id in `targetServerId`) or a ProjectTask (use `itemtype: 'ProjectTask'`
    and route to `/Project/Task/{id}` in the drainer).
  - `externalEventCreate/Patch/Delete`, `reminderCreate/Patch/Delete` —
    partition key = the planning row's `localId`; creates stamp the returned
    server id onto the row (`_completeTicketCreate` pattern) and use a
    `<!-- op:uuid -->` marker in `content`/`comment` for dup-recovery, probing
    with a name/content filter on retry.

### 1.3 App: UI

Route `/planning`, screen `lib/features/planning/ui/planning_screen.dart`.

- **App bar:** title "Planning"; actions: `today` icon (jump to today),
  view toggle (`Day` / `Week` `SegmentedButton` under the app bar).
- **Date strip (Day view):** horizontal 14-day scroller of date chips
  (weekday letter + day number; today outlined, selected filled). Below it a
  chronological list for the selected day:
  - All-day events first as full-width tinted tiles.
  - Then event cards sorted by `begin`. **Event card anatomy** (imitate
    `ticket_card.dart`): 4px left color bar by event type, leading icon,
    `HH:MM–HH:MM` (monospace-ish, `bodySmall`), title (max 2 lines), subtitle
    `parent label` (e.g. "Ticket #7 · Email outage"), trailing: for tasks a
    `Checkbox` bound to state todo/done (tap = optimistic `taskPlan` op).
  - Empty state: "Nothing planned" + FAB hint.
- **Week view:** an agenda list — 7 day-sections with headers ("Mon 10 Aug"),
  each listing that day's events in compact single-line rows; tapping a header
  switches to Day view for that date. (No month grid in v1.)
- **Type colors** (add to `GlpiColors` as `planningTicket`, `planningChange`,
  `planningProblem`, `planningProject`, `planningReminder`, `planningEvent`):
  ticket tasks = statusAssigned blue, change tasks = purple `#8E24AA`,
  problem tasks = teal `#00897B`, project tasks = orange `#FB8C00`,
  reminders = amber `#FFB300`, external events = green `#43A047`
  (dark-theme variants lightened, matching the existing palette style).
- **Interactions:**
  - Tap a ticket/change/problem task → open the parent via
    `ticketRepository.openByServerId(parentId, itemtype:)` →
    `Routes.ticket(localId)` (existing deep-link pattern from push).
  - Tap a project task → Phase 2 project-task sheet (until Phase 2 lands:
    read-only detail sheet with reschedule).
  - Tap a reminder / external event → its editor sheet.
  - Long-press any event → **Reschedule sheet**: begin + end pickers
    (reuse `_DateTimeField` from `dynamic_form_screen.dart`), Save enqueues the
    matching op. Pending rows render at 55% opacity with "syncing…" (imitate
    `_LinkTile`).
  - FAB → bottom sheet: **New event** / **New reminder**.
    - External-event editor (modal screen): title*, description, all-day
      switch, begin/end pickers, state selector (Information/To do/Done via
      `OptionSheet`). Creates default to the selected day 09:00–10:00.
    - Reminder editor: see Phase 3 spec (same editor reused).

**Done when:** all six event types render from the seeded feed with correct
colors and parents; done-toggle round-trips; offline reschedule + offline
event-create sync on reconnect; unit tests cover the feed repo window-replace
logic and each new op.

---

## Phase 2 — Projects

**Goal:** browse projects, drill into tasks, update the fields a tech owns
(state, percent, dates, task creation), and connect projects to tickets.

### 2.1 Data
- drift **v10**: `Projects` (`localId`, `serverId`, `name`, `code`, `content`,
  `stateName`+`stateColor` (server-provided hex, render as dot), `percentDone`,
  `planBeginDate`, `planEndDate`, `managerName`, `entityLabel`, `dateMod`) and
  `ProjectTasks` (`localId`, `serverId`, `projectLocalId` FK-cascade,
  `parentTaskServerId` nullable, `name`, `content`, `stateName`, `percentDone`,
  `planBeginDate`, `planEndDate`, `effectiveDuration`, `pending`).
- Repository `ProjectRepository`: `watchProjects()` (open first: percent < 100
  or no end date, then closed), `refreshProjects()` (paged, `Content-Range`),
  `watchTasks(projectLocalId)`, `refreshTasks(projectLocalId, serverId)`.
- Ops: `projectTaskPatch` (percent/state/dates), `projectTaskCreate`
  (marker-in-content dedup, probe `/Project/{id}/Task` on retry). Project
  header fields stay read-only in v1.

### 2.2 UI
- Route `/projects` → **Projects list**: search field in app bar (local
  filter), cards: name (+ small `code` suffix in outline color), linear
  progress bar (`percentDone`), state dot + label, due `DueBadge` on
  `planEndDate` (reuse the 4h-warn logic but with a 7-day warn window for
  projects), manager subtitle. Pull-to-refresh.
- **Project detail** (`/projects/:localId`):
  - Header: name, progress bar with "N% done", state chip, priority row.
  - `_InfoTile` rows: Manager, Manager group, Planned start/end
    (`formatDateTime`), Entity, Code.
  - Description block (plain-text rendered).
  - **Tasks section**: flattened tree — parent tasks as section rows (bold),
    children indented 16px. Each row: state dot, name, right-aligned
    `NN%` mini-label + planned-end `DueBadge` when at risk. Tap → **Task
    sheet** (modal bottom sheet): name (read-only), description, percent
    stepper (0–100 by 10), state via `OptionSheet` (from the project-state
    dropdown cache), planned begin/end pickers, Save → `projectTaskPatch`.
    "Add task" `TextButton.icon` in the section header → same sheet in create
    mode (name editable, optional parent = tapped section).
  - **Linked tickets section**: reuse `LinkedItemsSection` visual; data from
    the plugin links endpoint extended with `Project` support (below).
  - Costs: collapsed `ExpansionTile`, read-only rows (name · date · cost).
- **Ticket ↔ project links:** extend `ItilController.php` links endpoint to
  accept `target_itemtype: 'Project'` (table `glpi_itils_projects`: columns
  `itemtype`, `items_id`, `projects_id`) for GET/POST/DELETE in both
  directions, and teach the app's `ItilLinkType`/pickers a `Project` target
  (picker gains a "Projects" segment; search via `/Project?filter=name…`).
  Project tasks feed Planning automatically (Phase 1 feed).

**Done when:** list+detail render seeded projects with a task tree; percent
and state edits round-trip offline; task create dedups on retry (unit test);
a ticket links to a project from either side and both directions render.

---

## Phase 3 — Reminders

**Goal:** personal notes with optional scheduling, full CRUD, offline.

- Data: drift **v11** (shared with KB): `Reminders` (`localId`, `serverId`,
  `name`, `content`, `beginViewDate`, `endViewDate`, `isPlanned`, `begin`,
  `end`, `state`, `isMine`, `pending`). Repository with
  `watchReminders()` / `refresh()` (GET `/Tools/Reminder` returns mine +
  shared; flag `isMine = users_id == me` to gate editing).
- Ops: `reminderCreate/Patch/Delete` (shared with Phase 1 — if Phase 1 built
  them, reuse; the editor is the shared piece).
- UI: Route `/reminders` → list: cards with title, 2-line content snippet,
  footer row: visibility window (`bodySmall`, outline color) + amber
  `planningReminder` dot + planned window when planned + a lock icon when not
  editable (shared, not mine). FAB → editor.
  **Editor** (full-screen): Title*, Content (multiline 6+), "Visible from/to"
  date pickers (optional), "Plan this reminder" switch revealing begin/end
  pickers + a To do/Done/Information state selector. App-bar delete (confirm
  dialog) for `isMine` rows only.
- Planned reminders appear in Planning (already via the feed).

**Done when:** CRUD round-trips offline; shared reminders render read-only;
a planned reminder shows in the Planning day view.

---

## Phase 4 — Knowledge Base

**Goal:** find and read articles fast, comment, and use articles from tickets.

### 4.1 Data
- drift v11: `KbCategories` (`serverId`, `parentId`, `name`, `completename`),
  `KbArticles` (`localId`, `serverId`, `name`, `contentHtml`, `categoryId`,
  `isFaq`, `views`, `dateMod`, `cachedAt`) — only *opened* articles cache
  their content; list rows may have null content.
- Repository: `searchArticles(query, {faqOnly, categoryId})` server-first
  (`filter=name=ilike="*q*",content=ilike="*q*"` OR-combined) with local-cache
  fallback offline (the established `itilSearchProvider` pattern);
  `getArticle(id)` caches content; `watchCachedArticles()` for the offline
  shelf; comments read/add via `/Knowledgebase/Article/{id}/Comment`.
- Ops: `kbCommentCreate` only (articles are read-only in the app).

### 4.2 UI
- Route `/kb` → **Browse screen**: search bar pinned top (server search,
  300ms debounce — imitate `user_picker.dart`), below it a `FilterChip` row:
  "FAQ only", category chips (top-level categories; tapping opens a
  category picker sheet fed by `completename`, like `category_picker.dart`).
  Result cards: title, category `completename` (outline color), updated
  `relativeAge`, a filled star icon when `isFaq`. Second tab or segmented
  control "Saved" → `watchCachedArticles()` (offline shelf).
- **Article reader** (`/kb/:serverId`): title (headline), category breadcrumb,
  body rendered with `flutter_widget_from_html_core` (decision rule applies —
  plain-text fallback acceptable), embedded images resolved via the existing
  `downloadDocument` cache when they reference GLPI documents, otherwise
  loaded by URL. Bottom: **Comments** `ExpansionTile` (author, age, text; add
  via `ComposeSheet` → `kbCommentCreate`). App bar: bookmark icon = "keep
  offline" (forces content cache; filled when cached).
- **Ticket integration** (the point of the feature):
  - Ticket/Change/Problem detail app-bar menu gains **"Search knowledge
    base"** → opens `/kb` with the query pre-filled from the object title.
  - The reader, when reached from that flow, shows a bottom action bar:
    **Use as solution** / **Add as reply** — pops back to the object and
    pre-fills the solution `ComposeSheet` / composer with the article's
    plain-text body, and enqueues a `linkAdd` op recording
    `KnowbaseItem_Item` via the plugin links endpoint (extend it with
    `KnowbaseItem` target, table `glpi_knowbaseitems_items`).

**Done when:** search/FAQ/category filters work online and degrade offline to
cached articles; an article renders with images; comment posts offline; the
use-as-solution flow prefills, links, and the link shows on the article side.

---

## Phase 5 — RSS feeds & Reservations (small)

### RSS
- Route `/rss` (drawer entry folded under Knowledge base? No — keep separate,
  tiny). List feeds from `/Tools/RSSFeed`; card: name, url host, refresh rate.
  Tap → open `url` externally via `url_launcher` (add dep; if it conflicts,
  copy-to-clipboard + snackbar fallback). No item parsing in v1. CRUD: create/
  edit sheet (name, URL, refresh rate) through the outbox; low ceremony.

### Reservations
- Route `/reservations`, two `SegmentedButton` views:
  - **Items**: reservable items from `/Tools/ReservationItem` (joined asset
    name/type); search field; tap → **Item schedule** screen: next-14-days
    list of existing reservations (who + window), FAB **Reserve**: begin/end
    pickers (default next full hour +1h) + comment → `reservationCreate` op.
  - **Mine**: my upcoming reservations; swipe-to-cancel (confirm) →
    `reservationDelete` op.
- Conflicts: server rejects overlaps → op lands in Needs Attention; the item
  schedule screen shows the local pending row greyed until then (accepted UX,
  per decision rules).
- Phase 6 hook: asset detail gains a "Reserve" button when the asset is
  reservable.

**Done when:** a reservation created offline syncs (or conflicts visibly);
cancel works; RSS opens externally.

---

## Phase 6 — Assets

**Goal:** one generic browser covering every asset itemtype (including custom
asset definitions), with the mobile-native additions: barcode lookup, on-site
edits, create-ticket-for-asset, reserve.

### 6.1 Data
- drift **v12**: `AssetItems`: `localId`, `itemtype`, `serverId`, promoted
  columns `name`, `serial`, `otherserial`, `statusName`, `locationName`,
  `userName`, `groupName`, `manufacturerName`, `modelName`, `dateMod`, plus
  `fieldsJson` (the full HL payload) and `pending`. Key on
  `(itemtype, serverId)` unique.
- `AssetRepository`: `itemtypeDirectory()` from `GET /Assets` (cache in
  `AppConfig`; includes custom definitions — render them identically);
  `watchList(itemtype)` + `refreshList(itemtype, {query, status})` (server
  filter `name=ilike|serial=ilike|otherserial=ilike`, paged);
  `search(query)` across the primary types
  (`Computer, Monitor, NetworkEquipment, Peripheral, Printer, Phone, Software`)
  via parallel queries merged; `getDetail(itemtype, id)` refreshes
  `fieldsJson` + Infocom.
- Ops: `assetPatch` (generic `PATCH /Assets/{itemtype}/{id}` — optimistic
  update of promoted columns + fieldsJson merge). Editable fields v1:
  `states_id`, `locations_id`, `users_id`, `groups_id`, `comment`. Everything
  else read-only.
- Plugin: **`Item_Ticket` links** — extend the links endpoint to accept asset
  itemtypes as targets on ITIL objects (table `glpi_items_tickets`, plus
  `glpi_items_problems` / `glpi_changes_items` for the other two), so asset
  detail can list its tickets and ticket detail can list its assets. The
  Linked-items picker gains an "Assets" segment (searches via the asset
  search above).

### 6.2 UI
- Route `/assets` → **Hub**: pinned search-all field (results grouped by
  itemtype), `GridView` of itemtype cards (2 columns): icon (map the common
  types to Material icons; custom/unknown → `Icons.category_outlined`), label,
  count badge (from a `limit=1` request's `Content-Range`, cached daily).
  App-bar action: **scan** (`Icons.qr_code_scanner`).
- **Scan flow** (reuse `mobile_scanner` from pairing): on decode, search
  `serial==code OR otherserial==code` across primary types → exactly one hit:
  open detail; several: results list; none: snackbar "No asset with this
  code".
- **List** (`/assets/:itemtype`): search field (server-backed, cache
  fallback), status filter chip (`OptionSheet` fed from the `State` dropdown —
  verify `/Dropdowns/State` exists; if not, plugin dropdown passthrough).
  Cards: name, serial (monospace, outline), status chip (neutral colors),
  location · user subtitle.
- **Detail** (`/assets/:itemtype/:localId`), sections in order:
  1. Identity `_InfoTile`s: Name, Serial, Inventory number (`otherserial`),
     Model, Type, Manufacturer — read-only; **Status**, **Location**,
     **User**, **Group** — editable (`OptionSheet`/`UserPicker` →
     `assetPatch`); Comment — editable via `ComposeSheet`.
  2. **Warranty/Infocom** `ExpansionTile`: purchase date, warranty start +
     duration, computed warranty end with `DueBadge` (warn 30 days), supplier,
     order/invoice numbers, value. Read-only v1.
  3. **Network ports** (types that have them): read-only rows — name, MAC,
     IPs (from `/Assets/{itemtype}/{id}` payload's port data or a
     `NetworkPort` sub-fetch; verify shape by curl first).
  4. **Software** (Computer only): count + first 20 installed titles,
     read-only, behind an `ExpansionTile`.
  5. **Tickets**: `LinkedItemsSection` listing ITIL objects linked to this
     asset; **"Create ticket"** `FilledButton.tonalIcon` → opens the Service
     Catalog with a pending asset-link stash: after the form submission's
     ticket resolves, enqueue `linkAdd` (asset↔ticket) against the new ticket
     (reuse the 0-sentinel resolution — same mechanism as form file
     attachments).
  6. **Documents**: `AttachmentsSection` generalized (widen the plugin
     document endpoints' allow-list from ITIL types to asset + management
     types — keep one shared `ITEMTYPES` map in the plugin).
  7. **Reserve** button when a matching `ReservationItem` exists (Phase 5).
- Cartridges/Consumables lists additionally show stock counts
  (`Cartridge`/`Consumable` sub-schemas); no take/install action in v1
  (note as deviation if demand appears).

**Done when:** hub shows real counts incl. a custom asset definition if one
exists in dev (create one to verify); scan finds a seeded serial; status +
location edits round-trip offline; create-ticket-for-asset links end-to-end;
documents upload/view on a Computer.

---

## Phase 7 — Management (tier 1)

**Goal:** the reference data techs need in the field, read-focused with
targeted edits, plus tap-to-communicate.

Shared infrastructure: a **generic management browser** mirroring the asset
browser (same list/detail scaffolding, `ManagementItems` drift table in
**v13** with `fieldsJson`), parameterized per itemtype by a small config
(`icon`, promoted columns, detail layout builder).

Per-itemtype specifics:
- **Documents** (`/management/documents`): list (name, filename, mime icon,
  updated); detail: preview images inline via the existing document cache;
  other mimes → "Open" button that saves to cache and launches an OS open
  intent (add `open_filex`; conflict → share via `share_plus`; both conflict →
  note deviation and show path copy). Upload from camera/gallery via the
  generalized plugin endpoint (`Document` standalone: allow `itemtype=null`
  uploads — plugin accepts a no-link upload).
- **Contracts**: list with `DueBadge` on end date (warn 30 days; compute end =
  begin + duration months); detail: dates, renewal, cost rows (ContractCost),
  linked suppliers, linked items (read-only list from `Contract_Item`).
- **Suppliers / Contacts**: detail rows for phone/mobile/fax/email/website —
  phone rows tappable → `tel:` URI, email → `mailto:`, website → browser (all
  via `url_launcher`). Address block with a "Open in maps" `geo:` link.
  Contact↔supplier association listed both ways.
- **Software licenses**: list: name, total seats (`number`), expiry
  `DueBadge`; detail: linked software, used-count if cheaply available
  (skip if it needs N+1 queries — deviation note).
- **Certificates**: list sorted by expiry with `DueBadge` (warn 30 days);
  detail read-only.
- Edits across tier 1: `comment` only (via `ComposeSheet` → generic
  `managementPatch` op). Everything else read-only.

**Done when:** all five tier-1 types list/detail from seeded data; a contract
and certificate show correct expiry badges; tel/mailto links launch; a
standalone document uploads and opens.

## Phase 8 — Management (tier 2) + polish

- Add the remaining itemtypes to the same browser: Budgets, Lines, Domains
  (+ DomainRecord rows in detail), Datacenters (detail lists DCRooms → racks
  read-only), Clusters, Appliances, Databases (+ instances). All read-only +
  comment.
- Polish pass: any deviations logged below get revisited; localization strings
  for all new screens (the app is EN/FR — mirror every new user-facing string
  into the l10n arb files, which earlier phases must also do — add to each
  phase's done-check).
- **Accessibility sweep: DONE (2026-08-15).** It went well beyond the "semantic
  labels on icon-only buttons" scoped here — contrast-derived semantic colours,
  one-node-per-row semantics, spoken forms of the abbreviated labels, 48dp
  targets, a non-gesture equivalent for pull-to-refresh, announcements for
  invisible state changes, large-text layouts, and 42 tests. The rules, what is
  enforced and what is still missing are in [accessibility.md](accessibility.md);
  the remaining gap is a hands-on TalkBack/VoiceOver pass on a device. New
  screens must use the shared widgets (`InfoTile`/`LabelledRow`, `AccentPill`,
  `SectionHeading`, `AccessibleRefresh`, `TapTarget`) to inherit it.

---

## Appendices

### A. Outbox op registry (target state)
Existing: `ticketCreate, formSubmit, attachmentUpload, linkAdd, linkRemove,
extraPatch, followupCreate, taskCreate, taskSetState, ticketPatch, teamAdd,
teamRemove, solutionCreate, solutionAnswer, validationCreate, validationAnswer`.
Added by this roadmap: `taskPlan, externalEventCreate/Patch/Delete,
reminderCreate/Patch/Delete, projectTaskPatch, projectTaskCreate,
kbCommentCreate, reservationCreate/Delete, rssFeedCreate/Patch/Delete,
assetPatch, managementPatch`.
Rules for every new op: itemtype-aware where routes vary; FIFO partition key =
owning object's localId; creates get marker-based dup recovery; a unit test in
`outbox_drainer_test.dart` per op (happy + offline-retry).

### B. Plugin endpoint registry (target state)
Existing: pair/refresh/config/devices; `/forms*`; `/itil/{t}/{id}/documents`;
`/itil/{t}/{id}/links`; `/itil/{t}/{id}/extra`.
Added: `/GlpiMobile/planning` (feed); links endpoint targets extended with
`Project`, `KnowbaseItem`, and asset itemtypes (tables:
`glpi_itils_projects`, `glpi_knowbaseitems_items`, `glpi_items_tickets`,
`glpi_changes_items`, `glpi_items_problems`); document endpoints widened to
asset/management itemtypes + standalone uploads. Remember: **route changes
need `cache:clear`**, and uploads must `copy()` (never `move_uploaded_file`)
the PHP temp file.

### C. drift schema sequence
v9 PlanningEvents · v10 Projects/ProjectTasks · v11 Reminders + KbCategories/
KbArticles · v12 AssetItems · v13 ManagementItems. Every bump: registered in
`app_database.dart` tables list, `schemaVersion`, and an `onUpgrade` block;
`@DataClassName` to avoid model-name collisions (established gotcha).

### D. Deviations log
Record every place the implementation diverged from this spec (what, why,
follow-up). Keep it short; this is the hand-off ledger between agent sessions.

| Date | Deviation | Why | Follow-up |
| --- | --- | --- | --- |
| 2026-08-08 | One `CatalogItems` drift table (v12) with a `domain` column serves **both** Assets and Management, instead of separate `AssetItems` (v12) + `ManagementItems` (v13). | The two domains have an identical HL contract (`/{domain}/{itemtype}` CRUD); a second table would have been the same columns twice, and one browser now covers both. Schema stops at **v12**. | None. If the domains ever diverge, split then. |
| 2026-08-08 | Ops named `catalogPatch` / `itemLinkAdd` / `itemLinkRemove`, not `assetPatch` / `managementPatch`. | Same reason — one op serves both domains, and asset↔ITIL links needed their own pair. | None. |
| 2026-08-08 | `SoftwareLicense` and `Certificate` are searched as **Assets**, not Management. | GLPI files them under `/Assets`; its `/Management` directory *lists* SoftwareLicense but that route 404s. The hub still renders whatever the server reports, so the dead entry shows a `—` count. | Watch for a GLPI fix; harmless today. |
| 2026-08-08 | Plugin gained `GET /GlpiMobile/record/{itemtype}/{id}/raw` (whole DB row) beyond the planned endpoints. | GLPI 11's HL schemas for Supplier/Contact expose only `{id,name,comment,entity,type}` — no phone, email, website or address — and Contract has no end date. Tap-to-call was impossible without it. | Drop it if GLPI widens those schemas. |
| 2026-08-08 | Network ports, installed software and asset↔ITIL links come from new plugin routes (`/asset/{itemtype}/{id}/{ports,software,itil}`), not the HL API. | Verified by curl: `/Assets` publishes only the item schema and Infocom. | — |
| 2026-08-08 | Asset/management **writes must use HL *schema* field names** (`status`, `location`, `user`), not DB columns (`states_id`, …). A PATCH with column names returns **200 and changes nothing**. | Discovered in device testing — a silent no-op, the worst kind. Encoded in `TicketActions.patchCatalogItem` with a comment. | Applies to any future generic PATCH. |
| 2026-08-08 | Infocom keys are `date_buy` / `date_warranty` / `invoice_number` (the roadmap assumed `buy_date` / `warranty_date` / `bill`). | Verified against the live payload. | — |
| 2026-08-08 | Contract expiry is **computed** (`date_begin` + `duration` months) in `CatalogItemDto.expiryDate`. | GLPI stores no end date for contracts. Unit-tested. | — |
| 2026-08-08 | Cartridge/Consumable stock counts, ContractCost rows, Contract_Item lists, DomainRecord rows and DCRoom/rack drill-down are **not** rendered as bespoke sections. | They surface generically in the detail's "Other fields"; each would need its own sub-fetch for a read-only list a technician rarely needs in the field. | Add on demand. |
| 2026-08-08 | Documents open by **caching the file and copying its path**, not by an OS open intent. | Avoids adding `open_filex`/`share_plus`; images preview inline, which covers the common field case (photos). | Add `open_filex` if PDFs come up. |
| 2026-08-08 | Localization: new screens ship **English-only strings** rather than l10n arb entries. | The existing Assistance screens are the only localized surface; mirroring ~120 new strings into `app_en.arb`/`app_fr.arb` is mechanical work better done in one pass once the copy settles. | One l10n sweep across Phases 1–8. |

### E. Traps found the hard way (device-verified)

**Rich text (2026-08-08).** GLPI content is HTML everywhere (`content`,
followups, solutions, `impactcontent` &co, KB articles). Display goes through
`core/widgets/rich_content.dart` (flutter_html); composing goes through
`core/widgets/rich_editor.dart` (flutter_quill + Delta↔HTML converters), and
`ComposeSheet(rich: true)` is the entry point.
- `FlutterQuillLocalizations.delegate` is **required** in the app's
  `localizationsDelegates` or every toolbar button throws.
- Plain text and HTML must be distinguished (`looksLikeHtml`): handing plain
  text to the HTML renderer eats its line breaks, and plenty of GLPI content is
  plain (scripts, email drops, this app's own quick composer).
- The outbox's `<!-- op:uuid -->` marker is HTML and survives the round trip —
  strip it before rendering (`sanitizeGlpiHtml`), never before sending.
- Inline images point at authenticated document URLs; they render as a chip,
  not a broken image.


**GLPI types the same field two ways (2026-08-08).** A form built in the newer
editor sent `"is_multiple_actors": "0"` (string) where older forms sent `true`
(bool). `as bool?` on the string threw, and — see the grey-box trap below —
that took the whole form down: only the first question rendered. Never cast
GLPI JSON directly; coerce (`FormQuestionDto._flag`). Actor questions also
default to a JSON *object* (`{"users_ids":[],…}`) while the field wants a list,
so defaults are now seeded per question kind.

**A widget that throws is a silent grey box in release.** No error, no log. It
has now hidden two real bugs. `installInlineErrorWidget()` (called from
`main`) replaces it with an inline "This part didn't load" + the exception —
which is exactly how the second form bug was identified in one screenshot.


**Tablets & foldables (2026-08-08).** `core/utils/layout.dart` holds the M3
window-size classes and the hinge lookup; `core/widgets/two_pane.dart` does the
list/detail split.
- **`findRenderObject()` inside `LayoutBuilder` throws** (not laid out yet), and
  release builds paint the throw as a **bare grey box** — no error, no red
  screen. It blanked both panes whenever a scope was empty. Derive the offset
  from `MediaQuery.sizeOf(context).width - constraints.maxWidth` instead.
- The scaffold FAB floats over the *detail* pane in two-pane mode, landing on
  the reply box; it belongs to the list column there.
- The pairing screen's action used `onPrimary` (white) on a surface app bar —
  invisible until a tablet made the bar light.
- Emulators: `avdmanager create avd -d pixel_tablet|pixel_9_pro_fold`; drive
  postures with `adb shell cmd device_state state 0|1|2` (CLOSED / HALF_OPENED /
  OPENED). The stylus tutorial dialog hijacks input on tablet AVDs — disable it
  with `adb shell settings put secure stylus_handwriting_enabled 0`.


**Entity switching (2026-08-08).** drift **v13** adds `PendingOps.entityId` /
`entityRecursive`.
- GLPI takes the entity from a **request header**, for reads *and* writes: a
  POST with `GLPI-Entity: 4` files the new ticket into entity 4 (verified).
- A write aimed at an object outside the header's entity is **403
  ERROR_RIGHT_MISSING** — so an op composed in one entity and drained after a
  switch fails permanently. Ops are pinned at enqueue and replayed inside
  `EntityScope.run(...)`, a Zone-scoped override the dio interceptor reads.
- Repositories only upsert; nothing pruned. `clearSyncedCaches()` runs on a
  switch (keeping outbox-owned rows), and `refreshQueue` now prunes objects the
  server no longer returns.
- The entity tree is cached in `AppConfig`, so the switcher works offline.


**Session longevity (2026-08-08).** The app now holds a non-rotating device
credential; the plugin keeps the GLPI refresh token
(`glpi_plugin_glpimobile_sessions`). Reasons, all verified:
- GLPI's refresh tokens are **1 month, sliding**, and `RefreshTokenGrant`
  **revokes the old one before replying** — so an app holding the token is one
  lost response away from a forced re-scan.
- **A dead access token returns HTTP 400**, not 401
  (`Glpi\Api\HL\Router::handleRequest` → `ERROR_INVALID_PARAMETER` /
  'Invalid OAuth token'). Reactive refresh keyed on 401 never fired; the app
  showed stale data until local expiry. Use `isTokenChallenge()`.
- The broker used to answer **401 for any `Throwable`**, including a 4-second
  curl timeout — a busy server wiped every technician's credentials. Transport
  failures are now **503** (retryable); only a rejected grant is 401.
- Clearing credentials is not enough: `TokenManager` must **tell the UI**
  (`onReauthRequired`) or the app sits on a cached queue failing every call.
- A plugin front page must **not** call `Session::checkCSRF()` — GLPI 11's
  `CheckCsrfListener` already validated and consumed the token, so the second
  check always 403s.
- `Platform.isAndroid` reported false in a release build where
  `Platform.operatingSystem` correctly returned `android`; the latter is what
  the device panel now records.


- **A `read` of a `StreamProvider` nobody is listening to has no value.** The
  status/location pickers silently came up empty until the screens `watch`ed
  `assetStatusesProvider` / `locationsProvider` in `build`.
- **Never cache an API error body as a file.** A 401 JSON body was written to
  the document cache and served forever after, because the cache returned any
  existing non-empty file. Both the download and the cache-hit path now reject
  bodies that start with `{` or `<`.
- **The HL API ignores unknown write fields silently** (see the deviation
  above) — always verify a PATCH by reading the row back, not by the 200.
