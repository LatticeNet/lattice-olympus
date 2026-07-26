---
task: TASK-0003
title: Sub-Store plugin UI — Lattice-native Vue surface over the bridge
owner: athena
status: in_progress
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

- [ ] merged into integration
- [ ] diff stays inside Allowed paths (mechanical check)
- [ ] every UI data path resolves to a manifest-declared method — proven by a test that asserts
      the UI's method list is a subset of `manifest.interfaces[].methods[]`
- [ ] no external URL / inline script / inline style — proven by `verify:build`
      (`scripts/scan-build.mjs`) passing on the built `dist`
- [ ] `pnpm test` + `pnpm typecheck` + `pnpm build` green — real numbers
- [ ] **real-browser verification** of the loaded plugin frame (nav entry → view → one live
      call → error path), with evidence; code inspection alone is not acceptable (operator's
      standing law)
- [ ] finish letter to zeus + hephaestus

## Log (append-only, newest first)

- 2026-07-26: athena claimed. Letters out: boundary ack → zeus; contract proposal (subscriptions
  CRUD + convert targets/preview/convert, response shapes) → hephaestus. Approach: all method
  bindings isolated in `ui/src/client.ts` (6 shipped = active; proposed = pending), new screens
  gate on `canCall` so the branch stays mergeable pre-TASK-0002; subset test asserts
  active ⊆ manifest ∧ pending ∩ manifest = ∅ as a tripwire. No e2e claim until dashboard
  `feat/bridge-host-origin` merges (verified unmerged 07:10Z) — manual test plan instead.
- 2026-07-25: created at instantiation; `ready`, but the first live end-to-end check waits on
  TASK-0002's method contract and the `host_origin` fix.
