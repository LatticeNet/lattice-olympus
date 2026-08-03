---
task: TASK-0012
title: Dashboard banner while a non-official publisher is trusted
owner: athena
status: in_progress
plan_ref: TASK-0011 Decision 3 (operator-ratified 2026-07-28)
repos: [lattice-dashboard, lattice-server]
branches: [feat/athena-task0012-trust-banner]
last_touched_by: athena
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # trust-surface semantics → zeus
created: 2026-07-28
---

## Goal

A server that trusts a publisher other than `latticenet` must **say so in the UI**, so a
dev-trusted node can never be mistaken for production in a screenshot.

## The condition is narrower than "dev mode"

There is no dev mode to announce (TASK-0011 Decision 2: production refusal is structural, not a
switch). The honest condition is: **the trust policy lists any publisher other than
`latticenet`** — or `allow_unsigned_host_risk` is true, which should never happen but must not
be silent if it does.

## Scope & boundaries

- In: server exposes the condition (a boolean + the publisher list is enough — no key material);
  dashboard shows a persistent, unmissable marker while it holds.
- Out: any change to trust evaluation; any dev-key tooling (that is hephaestus's TASK-0011
  slice); "dev mode" wording — name the condition, not a mode.
- **Forbidden**: exposing key material, or a marker that can be dismissed away for the session.

## DoD

- [x] server surfaces the condition; no public keys or paths in the payload — `GET /api/plugin-trust` (server#24, zeus), 4/4 under -race, key-leak guard verified by breaking it
- [ ] dashboard marker visible on every screen while the condition holds — proven by a test,
      and by one screenshot in the finish letter
- [x] marker absent when only `latticenet` is trusted — same test, both directions
- [x] zeus [ack] on the trust surface at dashboard head `404e671`
- [ ] finish letter after the real-browser screenshot

## Current DoD evidence split (operator correction 2026-08-03)

1. **Every-screen placement — VERIFIED.** Dashboard#11 exact head `404e671` merged as
   `04c404601d5ab32d11dcd05c25e2f11ba9b8f39a`; CI is green and the registered navigation suite
   passed 51/51. In that exact tree, `TrustBanner` is mounted in `AppLayout` immediately above
   `AppHeader` and the single `RouterView`. Existing route tests plus this shared-layout placement
   own the every-screen claim; no 30-route manual replay is required.
2. **One authenticated real-browser reload — NOT VERIFIED.** The operator must reload once in the
   existing authenticated isolated browser and report whether the banner remains visible.
3. **One banner-only screenshot — NOT VERIFIED.** It must show the visible non-official publisher
   warning and no surrounding page data or secrets.
4. **Live endpoint truth — NOT VERIFIED.** Accept only the operator's no-secret confirmation that
   `GET /api/plugin-trust` reported `non_official: true`, publisher names only, and no key/path
   fields. Do not request or accept response bodies, headers, cookies/storage, credentials, trust
   material, keys, paths, or startup configuration.

TASK-0012 can close only after items 2–4 arrive and pass review. Environment liveness and “browser
logged in” are prerequisite reports, not substitutes for the reload, screenshot, or live truth
confirmation.

## Superseded controller route matrix (historical only; not current DoD)

The following route matrix was prepared before the operator restored the original DoD evidence
split. Preserve it as history, but do not execute or require it for TASK-0012 completion.

### Input boundary

- Accept only a human-started safe browser URL/context that is already authenticated and whose
  isolated server has already reported the non-official publisher condition.
- Do not receive or inspect cookies, storage exports, request headers/bodies, credentials, seed,
  public-key material, trust-file contents/paths, signing output, or startup configuration.
- The authenticated principal must have enough scope to retain every tested pathname. A redirect
  caused by missing scope is a failed prerequisite, not banner proof.

### Exact route manifest

The dashboard integration tree `04c404601d5ab32d11dcd05c25e2f11ba9b8f39a` has **27 static
authenticated NAV paths**:

```text
/
/nodes
/groups
/map
/inventory
/monitoring
/approvals
/tasks
/terminal
/audit
/network/policy
/network/dns
/network/geo-routing
/network/ddns
/network/tunnels
/platform/plugins
/platform/workers
/platform/kv
/platform/static
/platform/logs
/platform/notifications
/settings/security
/settings/sso
/settings/users
/settings/tokens
/settings/appearance
/settings/about
```

It also has **three authenticated parameterized patterns**: `/nodes/:id`, `/monitoring/:id`, and
`/plugins/:pluginId/:route(.*)*`. Use only safe visible IDs supplied/discovered through the UI.
If the isolated context has no safe instance for a pattern, record it as `NOT VERIFIED` and keep
the task open rather than inventing an ID or treating an error page as proof.

### Per-route proof

For every manifest entry, record target path, actual path, banner count, banner text, and result.
A pass requires all of the following:

1. actual pathname equals the intended pathname (no auth/scope redirect);
2. exactly one `[data-testid="trust-banner"][role="status"]` is visible;
3. text includes `Non-official plugin publisher trusted`, the non-official publisher name, and
   `Do not treat this console as production`;
4. no dismiss/close control exists;
5. the same assertions pass after one mid-matrix reload.

Use a named Playwright CLI session, snapshot before every element reference, re-snapshot after
each navigation/reload, and run from an Athena-owned `output/playwright/task0012/` artifact
directory. Capture only the banner element from a fresh snapshot; do not capture the full page.
The finish letter must carry the 30-row result matrix, exact running server/dashboard revisions,
the element screenshot path/reference, browser viewport, and any explicit `NOT VERIFIED` rows.
When controller access exists, record console-error count without copying message payloads. The
manual fallback must not open DevTools. Do not use request/header/storage inspection as evidence.

### Controller-unavailable operator fallback (issued 2026-08-03)

Use only the already logged-in office-browser tab. Do not open authentication, cookie/storage,
trust, request-detail, credential, key, or startup-configuration surfaces.

1. On **Overview**, confirm exactly one banner is visible, it names the non-official publisher,
   includes `Do not treat this console as production`, and has no dismiss/close control. Capture
   a crop of only this banner; exclude the rest of the page.
2. Click every static sidebar destination in this order, checking that the URL matches the route
   manifest above and the same banner remains visible after every click:
   - Overview: Overview;
   - Fleet: Nodes, Groups, Map, Inventory, Monitoring;
   - Operations: Approvals, Tasks, Terminal, Audit;
   - Networking: Network Policy, Self-host DNS, Geo-Routing, DDNS, Tunnels;
   - Platform: Plugins, Workers, KV Store, Static, Logs, Notifications;
   - Settings: Security & 2FA, Single Sign-On, Users, Access Tokens, Appearance, About.
3. From Nodes, Monitoring, and Plugins, open one safe existing node detail, monitor detail, and
   plugin-contributed view. Confirm the parameterized URL and banner. If no safe item exists,
   report that route pattern `NOT VERIFIED`; do not invent an ID.
4. On About, reload once and confirm the banner remains.
5. Return only: the banner crop; `27/27 static PASS` or exact failed/redirected paths; each of the
   three parameter-route results; `reload PASS/FAIL`; and the visible non-official publisher name.
   Never return credentials, cookies, storage, trust material, request details, keys, or startup
   configuration.

## Log

- 2026-08-03T09:00Z: operator restored the original evidence split after Chrome extension
  reinstall still left both Zeus and Athena controllers unable to attach. No retry or alternate
  automation attempted. Existing dashboard#11 51/51 plus `TrustBanner` in shared `AppLayout`
  now owns every-screen placement. Residuals are stated separately and honestly: authenticated
  reload `NOT VERIFIED`; banner-only screenshot `NOT VERIFIED`; live `/api/plugin-trust`
  no-secret shape confirmation `NOT VERIFIED`. The prior 30-route matrix is historical only.

- 2026-08-03T08:36Z: operator reported the isolated loopback target live and the office browser
  authenticated. Athena's Chrome controller could not attach: browser-client returned
  `Browser is not available: extension` on the initial attempt and the one permitted delayed
  retry. Diagnostics only (no tab/browser state) confirmed Chrome running, Chrome installed,
  extension installed+enabled for `Default`, and native-host manifest correct. Per the requested
  fallback, no alternate shell/AppleScript automation or new browser window was used. Exact
  minimal operator click/screenshot checklist persisted above; browser result remains
  `NOT VERIFIED` pending returned safe evidence.

- 2026-08-03T08:25Z: resume consumed and browser gate prepared. `npx` is available and the
  Playwright CLI wrapper responds through `bash`; exact route enumeration produced 27 static
  NAV paths and three parameterized route patterns. The route matrix, redirect guard, banner
  assertions, reload, element-only screenshot rule, and no-secret browser boundary are now
  persisted above. No safe authenticated target is running/provided yet, so no browser proof is
  claimed. TASK-0017 monitor assumption corrected from r1 to r2 `cacb1c3` with r3 requested.

- 2026-07-31T17:28Z: Zeus accepted the environment request and surfaced the minimal human-only
  action to the operator. Athena's input contract is now explicit: receive only the browser URL
  and safe access context after the isolated target reports `non_official: true`; never receive
  seed, public-key material, trust-file contents, credential paths, or environment-startup work.
  No executable Athena step exists until that safe target is handed over.

- 2026-07-31T17:04Z: both code prerequisites are now integrated: dashboard#11 at
  `04c404601d5ab32d11dcd05c25e2f11ba9b8f39a` (51/51, typecheck/build, Zeus ack) and server#24
  at `7e57b85a8437c59c8ecc53154e24890f10e3409c`. TASK-0013's dev-key tooling is also merged, but
  rules/03 forbids Athena from generating credentials, invoking signing, or configuring an
  environment. Sent Zeus the sole remaining environment request; once an isolated server that
  already trusts a non-official publisher is available, Athena owns the real-browser screenshot
  and finish letter.

- 2026-07-28T11:50Z: server half written by zeus (server#24) after athena proposed the shape
  and verified that extending /api/plugin-contributions would break its bare-array consumers.
  Field names final: non_official · publishers (names only) · allow_unsigned_host_risk.

- 2026-07-28 (09:34Z): athena claimed. Server-field shape proposed to hephaestus (copy to zeus)
  BEFORE writing anything: a new read-only `GET /api/plugin-trust` rather than extending
  `/api/plugin-contributions`, which returns a bare array — adding a sibling field there would
  break every current client (verified at src/lib/api/index.ts:471). Asked who writes the Go.
  Dashboard side starts now, gated so an absent/404 response renders nothing.

- 2026-07-28: created by zeus after the operator ratified TASK-0011 Decision 3. Split from
  hephaestus's tooling slice deliberately: this is UI + a server read-only field, his is
  local ergonomics, and neither should wait on the other.
