# GLPI 11 HL API — verified behavior notes (11.0.8, 2026-08-07)

Live-verified against the dev instance (`http://localhost:8081`, HL API v2.3). These
findings drive the sync-engine design; re-verify on GLPI upgrades.

## Auth
- `POST /api.php/token` password grant works with an admin-provisioned OAuth client
  (`glpi_oauthclients`; dev creds in `dev-env/provision-glpi.sh`). Returns
  `access_token` (JWT, 3600 s) + `refresh_token`.
- All HL calls: `Authorization: Bearer` + pin `GLPI-API-Version: 2.3` (or `/v2.3/` URL prefix).

## RSQL filtering — team paths are BROKEN (11.0.8)
- `filter=team.role==assigned` (and `team.name`, `team.type`) → **HTTP 500**, even though
  `role`/`name`/`type` are in the Ticket schema's `team` property.
- Unknown dotted paths under `team` (e.g. `team.users_id==2`, `team.bogus==1`) are
  **silently ignored** — the response is the UNFILTERED set with a 206. Never trust a
  team filter without asserting the total changed.
- Scalar paths work fine: `status.id=in=(1,2)`, `date_mod=gt=...`, `id==3`.

**Consequence:** server-side "assigned to me"/"my groups"/"unassigned" queries are not
possible. v1 pulls ONE scope — all open tickets in the active entity context
(`status=in=(1,2,3,4)` + `date_mod` watermark) — and Mine/Groups/Unassigned tabs are
local drift queries over the cached `team` arrays. List responses DO embed the full
`team` array per ticket (`{role, type, id, display_name, ...}`), so no extra requests.

## Groups for the current user
- `GET /Administration/User/Me` does **not** include groups.
- `GET /api.php/v2.3/session` **does**: `groups: [...]`, plus `profiles` map,
  `active_profile`, `active_entities`. No legacy-API fallback needed.

## Profile rights come with the session (no extra endpoint)
- `active_profile.rights` is the full `$_SESSION['glpiactiveprofile']` bitmask map —
  160 keys for a central profile, 26 for a helpdesk one, plugin rights included
  (`plugin_glpisignal_alert`, …). Verified against the stock Super-Admin, Technician,
  Observer and Self-Service profiles; those four payloads are checked in as
  `test/fixtures/session*.json`.
- **A key that is absent means the right is not held.** `Session::haveRight()` returns
  false for an unknown module, and helpdesk profiles simply omit most keys.
- The `GLPI-Profile` request header selects which profile the session runs as, and the
  rights reported change with it (verified: the same user reading 429063 for `ticket`
  as Technician and 168989 as Observer). `active_profile.interface` is `central` or
  `helpdesk`.
- Values are ints, but a few neighbouring keys in the same map are *not* rights —
  `ticket_status`/`change_status`/`problem_status` are JSON strings, `comment` is text.
  Read the map defensively.
- **Nothing else is rights-filtered.** `GET /Assets` and `GET /Management` return the
  same itemtype list for a super-admin and for a self-service user; only the per-type
  list request 403s (verified: Technician → `/Management/Contract` 403, because the
  stock profile holds `contract` 96 = READNOTE|UPDATENOTE with no READ). Any hub the
  app draws from those lists has to filter by rights itself.

## Timeline
- `GET /Assistance/Ticket/{id}/Timeline` returns merged entries `{type, item}` with type
  strings `Followup`, `Task`, `Solution`, `Validation`, `Document` — NOT class names like
  `ITILFollowup`.
- `POST .../Timeline/Followup` with `{"content": html, "is_private": 1}` → 201.
- `DELETE .../Timeline/Followup/{id}` → 204.

## Idempotency marker — HTML comments SURVIVE
`<p>text</p><!-- op:UUID -->` posted as followup content comes back byte-identical from
the Timeline read. The outbox embeds `<!-- op:{op_uuid} -->` in every created
followup/task/solution content and the duplicate-POST recovery probe matches on it
exactly (no content-similarity heuristic needed). Strip the marker when rendering.

## Misc
- Pagination: 206 + `Content-Range: start-end/total` (e.g. `0-0/24`); 200 = complete.
- Ticket `status` in responses is an object `{id, name}`; PATCH takes `{"status": <id>}`.
- Direct-DB seed note: `glpi_tickets_users.type` 1=requester, 2=assigned.
