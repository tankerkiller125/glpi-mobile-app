# Accessibility

This app is used one-handed, outdoors, in a server room, by someone who may be
holding a screwdriver — and by technicians who use a screen reader, a large
system font, or need more contrast than a designer's monitor suggests. The
accessibility work is not a layer on top of the UI; it lives in the shared
widgets, so a new screen inherits it by using them.

This document is the contract: what the app guarantees, how it is enforced, and
what is still missing.

## The rules

**1. Nothing is carried by colour alone.**
GLPI's semantic palette (status green, priority amber, SLA red) is tuned to be
recognisable as a *mark* — a 4px card edge, a 10px dot. Every one of those marks
is accompanied by words: a status chip says "New", the priority dot announces
"Priority High", a private note carries a filled `PRIVATE` badge rather than a
muted grey.

**2. Colour that becomes text goes through `ensureContrast` first.**
`lib/core/a11y/contrast.dart` walks a colour's lightness (hue and saturation
intact) until it clears the WCAG bar against the background it is drawn on —
4.5:1 for text, 3:1 for meaningful graphics. `AccentColors.of(accent, surface)`
returns the background / border / ink trio every pill uses, and `bestInkOn`
picks black or white for a filled badge. Several shipped colours sat near 2:1
as text before this; `test/unit/contrast_test.dart` asserts that, so deleting
the helper fails a test rather than quietly regressing the UI.

**3. A row of information is one node, not eight.**
A queue card read as fragments is "circle, 42, Email outage, Acme, New, 4h" —
a maze. Read through `semanticSentence` it is *"Ticket 42. Email outage.
Priority High. Status New. Alice, Acme, Hardware. Updated 4 hours ago."* The
same applies to project cards, planning entries, reminders, asset tiles and
every `InfoTile`.

**4. Abbreviations are expanded for the reader.**
`4h`, `in 3h 20m` and `1h 30m` are read literally by TalkBack ("four h"). Every
place that shows one hands the semantics layer the spoken variant instead —
`spokenAge`, `spokenDueRelative`, `spokenDuration` in
`lib/core/utils/formatting.dart`.

**5. Anything you can tap has a name and a 48dp target.**
Icon-only controls carry a `tooltip` (which is also the accessible name);
custom tap areas use `TapTarget` from `lib/core/a11y/a11y.dart`. Where a row
hides its children's semantics to read as one node, the *action* is hoisted
onto that node — otherwise a screen reader's double-tap lands on a node with no
handler and silently does nothing. That mistake is covered by a test.

**6. Gestures always have a non-gesture equivalent.**
Pull-to-refresh is the obvious trap: a screen reader takes over the swipe, so
the list can never be refreshed. `AccessibleRefresh` (used everywhere instead of
`RefreshIndicator`) adds a "Refresh" custom action that appears in TalkBack's
actions menu and VoiceOver's rotor. The planning tile's long-press-to-reschedule
declares `onLongPressHint`, so the reader announces it.

**7. State that changes without a dialog gets announced.**
Going offline, coming back, a reply being queued, a timer stopping, a lookup
finding nothing — `announce()` speaks them. `SnackBar` is already a live region
in Flutter, so anything shown that way is not announced twice. The values that
change under the user's thumb (the duration picker's readout, a "Sending…"
marker) are marked `liveRegion`. The timer banner deliberately is **not**: it
ticks every second and would talk over everything else.

**8. Layouts survive the user's font size.**
Detail rows drop their fixed-width label column and stack once the text scale
passes ~1.4× (`prefersStackedRows`), chip strips and date strips scale their
fixed heights, and rows that used to be `Row`s of chips and badges are `Wrap`s.
The app does not clamp the text scaler.

**9. Headings are marked as headings.**
`SectionHeading` (and `Semantics(header: true)` on screen and sheet titles) lets
a screen reader jump heading-to-heading instead of swiping past thirty fields to
reach the timeline.

**10. Where sight is genuinely required, offer the alternative first.**
Aiming a camera is a visual feedback loop with no audible "nearly there". The
pairing screen starts on manual code entry when `MediaQuery.accessibleNavigation`
is set, and the asset scanner always shows a code field beside the viewfinder.
Both viewfinders are labelled rather than being anonymous rectangles.

## What is enforced by tests

`test/widget/accessibility_test.dart` and `test/unit/contrast_test.dart` run in
CI with the rest of the suite:

- Flutter's WCAG-derived guidelines — `androidTapTargetGuideline`,
  `labeledTapTargetGuideline`, `textContrastGuideline` — over the queue card and
  the status pills, in **both** themes.
- The *content* of the semantics tree: a card's spoken sentence, "Status: New"
  rather than a bare "New", "Priority Very high", "not yet sent" for an unsynced
  ticket, "Category / Hardware / Edit" for a detail row.
- That merged nodes are still activatable (the hoisted-action rule above).
- That the task checkbox exposes checked state, toggles from the semantics tree,
  and sits in a 48dp target.
- That `AccessibleRefresh` exposes a working "Refresh" custom action.
- That a detail row stacks rather than truncating at 200% text.
- That every status / priority / SLA / planning colour clears AA as pill ink and
  3:1 as a mark, in light and dark — and that the raw colours would not have.

A note on the tree-wide `androidTapTargetGuideline`: it counts *any* node with a
tap or long-press action, which includes selectable body text (`SelectableText`
exposes long-press for the selection handles). On screens with selectable
content the toggle's own size is asserted instead.

## What was verified on a device

On the `glpi_dev` emulator against the dev-env GLPI, the platform accessibility
tree was read back with `adb shell uiautomator dump` — which is the same tree
TalkBack consumes — and the app was driven at a 1.8× system font and in dark
mode. Confirmed there:

- queue cards arrive as one node each: *"Ticket 1. Email outage. Priority High.
  Status Assigned. Acme Corp, Network. updated 5 days ago."*
- detail rows as *"Network, Category, Edit"*, *"High, derived from urgency and
  impact, Priority"*; app-bar controls as "Menu", "Search", "Filter and sort",
  "Switch module", "More actions", "Start timer";
- timeline bylines as *"glpi. 5 days ago. Private, not visible to the
  requester."*, task toggles as "Task done", durations as "Duration 3 hours";
- the composer as "Reply" / "Public note — the requester will see it" /
  "Formatting" / "Send reply";
- form questions merged into their controls — "Urgency, Select…" as one node,
  and the text fields carrying `hint="Description, required"`, which is what
  TalkBack reads for an edit box;
- at 1.8× the detail rows stack (label above value) with no truncation and no
  overflow, and the queue cards grow to two-line titles.

## Known gaps

- **Not driven with TalkBack or VoiceOver itself.** The tree TalkBack reads was
  verified on-device, but pronunciation, focus order, gesture navigation and the
  rotor have not been walked through by hand — and no automated check replaces
  that. iOS has not been run at all (see the README's limitations).
- **The connectivity announcements could not be exercised on the emulator.** Its
  `connectivity_plus` stream doesn't emit when the network is cut (a
  pre-existing quirk of this environment, already noted for the sync work), so
  going offline never flipped the state. The derivation itself is unit-tested;
  the announcement on top of it is not device-verified.
- **English only.** The semantic labels added here are inline strings, matching
  the surrounding screens — most of the app beyond onboarding is not yet in the
  `.arb` files. The l10n sweep and the accessibility strings should be done in
  one pass.
- **The rich-text editor** (`flutter_quill`) is labelled from the outside, but
  its internal editing semantics and toolbar are the package's, not ours.
- **`flutter_html` content** renders GLPI's markup; headings and lists inside a
  ticket description are not exposed as semantic headings or lists.
- **Colour-blind-safe palette.** Contrast is handled; hue confusion is not.
  Status and priority are always accompanied by text, which is the mitigation,
  but the palette itself has not been checked against deuteranopia simulation.
- **No large-text device pass.** The layouts were fixed against the widget
  tester at 2×; they have not been eyeballed on a phone at maximum font size.
