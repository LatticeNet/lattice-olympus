---
task: TASK-0004
title: One published bridge package to replace the four divergent bridge.ts copies
owner: athena
status: ready
plan_ref: plan/design-substore-embed.md §3 F2 (spec §8 "Plugin UI Toolkit")
repos: [lattice-dashboard, lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard]
branches: []
last_touched_by: athena
depends_on: []
blocked_by_ruling: —
needs_ack: yes    # bridge protocol is security semantics → zeus
created: 2026-07-25
---

## Goal

Every plugin UI consumes one versioned bridge client instead of a local copy, so the weakest
copy stops setting the security bar.

## Scope & boundaries

- In: extract the bridge client (handshake, nonce validation, `host_origin` requirement, call
  transport, error mapping) into a published package; migrate all plugin UIs; delete local copies.
- Out: changing bridge **protocol** semantics (that's a contract change of its own).
- **Allowed paths**: the new package + each repo's `ui/**` + `contract/api-contract.md` row.
- **Forbidden**: leaving any repo on a local copy "for now"; loosening nonce/origin checks to
  make a migration easier.

## Notes

- Current divergence (2026-07-25): template 360L reads only `lattice_nonce` (`bridge.ts:355`);
  sub-store/vpn-core 247L require `host_origin` and throw without it (`:191-204`); wireguard
  carries an older copy. Dashboard emits only `lattice_nonce` (`pluginBridgeModel.ts:95`) —
  dashboard `feat/bridge-host-origin` fixes the host side and must land first or with this.
- The bridge protocol belongs in `contract/` once extracted (rules/04: design travels with
  contract) — add the row and get the co-sign.

## DoD

- [ ] merged into integration (all six repos)
- [ ] zero local `bridge.ts` copies remain — proven by a repo-wide grep in the finish letter
- [ ] handshake/nonce/origin invariants covered by package tests
- [ ] each migrated UI: `test` + `typecheck` + `build` + `verify:build` green (real numbers)
- [ ] one real-browser check per migrated plugin
- [ ] contract row co-signed · finish letter sent

## Log

- 2026-07-25: created as `draft` at instantiation (F2 in the framework review).
