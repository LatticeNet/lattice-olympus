---
task: TASK-0003
title: Sub-Store plugin UI — Lattice-native Vue surface over the bridge
owner: athena
status: blocked
plan_ref: plan/design-substore-embed.md §5
repos: [lattice-plugin-sub-store]
branches: [feat/athena-task0003-substore-ui]
last_touched_by: athena
depends_on: [TASK-0002]      # method contract must exist before the UI binds to it
blocked_by_ruling: —
needs_ack: yes               # manifest ui/nav fields + bridge usage touch shared contract
created: 2026-07-25
---

## Goal

A Lattice-native Sub-Store surface inside the console: subscription list, conversion/preview,
endpoint & credential management — served from the plugin's own signed bundle, speaking only
the postMessage bridge.

## Scope & boundaries

- In: `ui/` Vue app (screens, state, error/empty/loading states), `manifest.json` **ui/nav**
  content fields, UI tests, a real-browser verification pass.
- Out: backend methods (TASK-0002); manifest signature fields (zeus); porting upstream
  Sub-Store's SPA (design §5 explains why we don't).
- **Allowed paths**: `lattice-plugin-sub-store/ui/**` · `.../manifest.json` ui/nav content
  fields · `.../README.md` UI section
- **Forbidden**: `system-go/**`; adding external URLs or inline script/style (the
  `verify:build` scanner must keep passing unchanged); requesting any CSP relaxation;
  copying `bridge.ts` a fourth time (see Notes).

## Notes

- **Hard constraint**: the plugin document runs under `default-src 'none'; … connect-src 'none'`
  (`server_plugin_assets.go:112-127`) in an opaque-origin `sandbox="allow-scripts"` iframe. The
  UI cannot fetch anything. Every data path is `lattice.plugin.call` → `POST /api/plugins/call`,
  and the host rejects any service/method not declared in the signed manifest
  (`pluginBridgeModel.ts:209`, `:279`).
- **Known shipped breakage** (design §3 F2): sub-store's `ui/src/bridge.ts:191-204` throws
  without `host_origin`, but the dashboard emits only `lattice_nonce`
  (`pluginBridgeModel.ts:95`); the fix is unmerged on dashboard `feat/bridge-host-origin`.
  Confirm that branch is merged before declaring the UI verified end-to-end — otherwise you are
  testing a combination that does not exist in production.
- Prefer extracting the shared bridge package (design §3 F2) over another local copy; if the
  package isn't ready, say so in the finish letter and file the follow-up task rather than
  quietly forking a fourth copy.
- Nav entries must sit in section `extensions` with an icon from the dashboard's lucide
  allowlist (`usePluginContributions.ts:61`, `:74`), and are scope-filtered client-side (`:207`)
  — server-side scope enforcement is still the real gate.

## DoD

- [x] merged into integration
- [x] diff stays inside Allowed paths (mechanical check)
- [x] every UI data path resolves to a manifest-declared method — proven by a test that asserts
      the UI's method list is a subset of `manifest.interfaces[].methods[]`
- [x] no external URL / inline script / inline style — proven by `verify:build`
      (`scripts/scan-build.mjs`) passing on the built `dist`
- [x] repo-native `npm test` + `npm run typecheck` + `npm run build` green — real numbers
- [ ] **real-browser verification** of the loaded plugin frame (nav entry → view → one live
      call → error path), with evidence; code inspection alone is not acceptable (operator's
      standing law)
- [ ] finish letter to zeus + hephaestus

## Real-browser finish gate (frozen 2026-08-04)

The code-freeze blocker is released. The only remaining blocker is a fresh isolated browser
environment; the prior dev process is stopped and its server checkout predates this baseline.
Until the matrix below is executed in a real authenticated browser, the browser DoD is
**NOT VERIFIED**.

### Exact environment identity

| Component | Required exact head |
|---|---|
| server | `1e6103001f16d48110bce471d68e6e638e805ada` |
| dashboard | `04c404601d5ab32d11dcd05c25e2f11ba9b8f39a` |
| Sub-Store | `3bf7bf5350ad2527665fbc66479e90ce0f5a47e8` (`0.4.0-alpha.2`) |
| plugin-index mirror | `4ed4e5049eed77f76f91bee93a7c0c742c0fd310` |

A mismatch is a finding: record the observed component/version and stop. Do not silently adapt
the freeze or claim evidence against a nearby build.

### Evidence matrix

| # | Browser action | Exact PASS evidence | Safe persisted evidence | State |
|---|---|---|---|---|
| 1 | In the existing authenticated session, open **Extensions → Sub-Store**. | Route is `/plugins/latticenet.sub-store/sub-store`; the sandboxed frame shows the Sub-Store heading and Import / Pipelines / Convert tabs; no boot `role=alert`. | UTC, route, PASS/FAIL, header-and-tabs-only crop. | NOT VERIFIED — environment absent |
| 2 | Open **Pipelines**, then press **Reload** once. | The button completes and re-enables; no load alert; the view resolves to either `No pipelines yet` or the saved-count heading. This is the required live `latticenet.sub-store/engine.list_pipelines` read call. | Record only empty/count outcome. Crop the section header/status; exclude pipeline cards, ids, names, payloads, and response bodies. | NOT VERIFIED — environment absent |
| 3 | Open **Convert**. Enter the literal non-secret placeholder `test-only-placeholder` as raw content and `{` as Operators JSON. Do not press Convert. | Visible validation says `Operators must be valid JSON`; the Convert button is disabled; the frame and navigation remain usable. This is the deterministic error path and sends no plugin call. | UTC, exact validation text, PASS/FAIL, validation-controls-only crop. Never paste a real subscription or endpoint. | NOT VERIFIED — environment absent |
| 4 | Reload the browser page while still on the Sub-Store route. | The same route and tabs return, and Pipelines can repeat row 2 without a bridge/bootstrap alert. | PASS/FAIL plus one safe crop; no DevTools payloads, headers, cookies, storage, credentials, keys, or local paths. | NOT VERIFIED — environment absent |

The operator may execute this matrix manually if no browser controller can attach. An operator
statement must identify the exact baseline match and each row's PASS/FAIL/NOT VERIFIED result;
screenshots supplement that statement and never replace the live-call result.

## Log (append-only, newest first)

- 2026-08-04 (11:44Z): TASK-0018 train freeze consumed. Exact server/dashboard/Sub-Store/index
  heads and the four-row real-browser matrix are now persisted. Code inspection at the frozen
  Sub-Store object proves `Pipelines → Reload` is a manifest-declared `effect: read`
  `list_pipelines` call; invalid Operators JSON provides the exact non-secret, no-call error path.
  **NOT VERIFIED**: no fresh isolated browser environment is running. Environment outcome request
  sent to zeus; task moved to `blocked` without changing any code repo or worktree.

- 2026-07-28 (07:44Z): **MERGED to integration at `0a337ca`** (40/40 post-merge, typecheck,
  build, verify:build). zeus [ack] at bc9976d; his r1 finding (the over-budget badge described
  truncation the runner does not do — it aborts, system_runner.go:475) fixed at the semantic
  level, and his r2 note (a test deriving its input from the constant under test can only
  confirm) fixed with literal sizes at ec80915, verified falsifiable. DoD remaining: the
  real-browser pass, which waits on the v0.3.0 train carrying the new bundle.

- 2026-07-27 (10:10Z): **signed line absorbed** — branch re-synced onto sub-store integration
  a4e00b98 (0.4.0-alpha.1, zeus's signing wave; digest e0524e35…). 39/39 + typecheck + build +
  verify:build re-verified, pushed 04bf92e. hephaestus's binary-constant corrections shipped
  earlier (8405dd3). E2e gate is now exactly one door: the production deploy (zeus building alpha-0.2.2a3).
- 2026-07-27 (04:54Z): **UI tracks the merged engine contract** (d6acd40 + README b343738).
  hephaestus's PR6 (engine/convert, transform_response, pipeline CRUD, run_pipeline, per-method
  budgets) superseded the provisional tier: Subscriptions tab → Pipelines (record CRUD + run
  drawer over pasted raw content), Convert → one-shot pasted-content conversion, client.ts
  mirrors the merged Go shapes with engine bindings active, guards aligned to signed budgets
  (6 MiB out / 1 MiB raw / 64 ops). `transform_response` deliberately unexposed (noted to
  hephaestus as v2 drawer). 39/39 tests, typecheck, build, verify:build green.
- 2026-07-26 (13:10Z): press executed by the operator — sub-store `integration` = 8dddd63 and
  now contains design-15 (my 07:35Z letter answered in the affirmative, reconciliation commit
  b00b2c3). Branch synced (640c935): PR #4 diff is now clean — 16 files, all `ui/**`+README,
  40/40 re-verified post-sync. Dashboard host emits `host_origin` on the integration line, so
  e2e gate (a) is OPEN pending only a live integration-line server (operator deploy).
- 2026-07-26: operator ruling (§7 q2): scope WIDENED — scripting, node filtering, and operator
  pipelines are in for the Sub-Store surface. UI impact: when hephaestus's widened (and
  budget-bearing, F6-blocking) method contract arrives, `client.ts`'s pending tier extends and
  the shell grows tabs (scripting/pipeline) without a rewrite — the tabbed shell was designed
  for exactly this. No speculative screens before the contract.
- 2026-07-26: review lane executed and closed. Agent-based lanes failed operationally (two
  Claude teammates never returned reports; Codex MCP account supports none of its models —
  stopped after 3 strikes per work-loop §6); review completed in-context instead, with zeus's
  mandatory [ack] round preserved as the real approval gate. One class of defect found and
  fixed (0298714): provisional-response arrays were indexed directly in templates — sparse
  wire answers would have crashed whole-tab renders. Composables now normalize on receipt;
  create() falls back to authoritative reload; 3 regression tests. Suite: **40/40**,
  typecheck clean, build 115.4 kB, verify:build pass.
- 2026-07-26: screens + state layer built and pushed (draft PR sub-store#4): tabbed shell
  (Import/Subscriptions/Convert in the one manifest view), `client.ts` two-tier contract module
  + subset/tripwire test (37/37 `npm test`, typecheck clean, build 114.9 kB, verify:build pass;
  note: repo family runs npm, not the DoD's "pnpm"). Branch carries `origin/main` (design-15) —
  zeus ack'd the integrator-level catch-up. hephaestus ack'd the provisional contract unchanged.
  Remaining: e2e verification (gated on dashboard bridge merge + TASK-0002 contract), then
  zeus [ack] on bridge scope, then merge.
- 2026-07-26: athena claimed. Letters out: boundary ack → zeus; contract proposal (subscriptions
  CRUD + convert targets/preview/convert, response shapes) → hephaestus. Approach: all method
  bindings isolated in `ui/src/client.ts` (6 shipped = active; proposed = pending), new screens
  gate on `canCall` so the branch stays mergeable pre-TASK-0002; subset test asserts
  active ⊆ manifest ∧ pending ∩ manifest = ∅ as a tripwire. No e2e claim until dashboard
  `feat/bridge-host-origin` merges (verified unmerged 07:10Z) — manual test plan instead.
- 2026-07-25: created at instantiation; `ready`, but the first live end-to-end check waits on
  TASK-0002's method contract and the `host_origin` fix.
