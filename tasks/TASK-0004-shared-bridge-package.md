---
task: TASK-0004
title: One published bridge package to replace the four divergent bridge.ts copies
owner: athena
status: in_progress
plan_ref: plan/design-substore-embed.md §3 F2 (spec §8 "Plugin UI Toolkit")
repos: [lattice-plugin-bridge, lattice-dashboard, lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard]
branches: [feat/athena-task0004-shared-bridge @ lattice-plugin-bridge]
last_touched_by: athena
depends_on: []
blocked_by_ruling: —
needs_ack: yes    # bridge protocol is security semantics → zeus
created: 2026-07-25
---

## Design argument (at start, per zeus's promotion riders)

1. **Reference behavior**: the sub-store/vpn-core copy (identical except `expectedPluginId`,
   route-set-vs-single, id prefix — 3 parameters). It pins `host_origin` in+out, retries ready,
   applies host theme, cancels with timeout. Missing there and worth taking from the template's
   copy: the typed `BridgeError` taxonomy. wireguard/netguard carry **pre-host_origin copies**
   (0 `hostOrigin` matches — the weak bar F2 warns about); template diverged furthest (568 diff
   lines, nonce-only). Package = sub-store transport hardened into a parameterized client:
   `{ expectedPluginId, expectedRoutes: string[], idPrefix }`.
2. **Home & distribution** (needs operator): recommend a new repo `lattice-plugin-bridge`
   publishing npm **prereleases** `@latticenet/plugin-bridge@0.x-alpha.N`; plugin repos pin
   exact versions in package-lock. Rationale: my allowed paths exclude plugin CI workflows, so
   submodule consumption cannot be CI-wired by me; registry consumption keeps every plugin CI
   byte-identical (`npm ci`). Falls back to submodule+task-amendment only if the operator
   refuses registry.
3. **Migration order** (rider 3 — never require `host_origin` against a host that doesn't
   emit it): (a) operator lands the dashboard reconciliation (host emits `host_origin`);
   (b) package `0.1.0-alpha.1` published; (c) migrate sub-store + vpn-core (their copies
   already require it — zero behavior change, proves the package is a faithful extraction);
   (d) migrate wireguard + netguard + template (their UIs become fail-closed — the security
   point of the task, safe because (a) landed); (e) delete every local copy, grep proof.
4. **Contract row**: bridge protocol shape goes to zeus for `contract/api-contract.md` with the
   extraction PR (message types + invariants: nonce 16–128 chars, exact-origin match,
   `event.source` primary guard, fail-closed absence).
5. **Real-browser checks** (DoD): one per migrated plugin — joins the live-server manual-e2e
   follow-up zeus already tracks; no separate infrastructure requested.

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

- 2026-07-26: zeus created `lattice-plugin-bridge` (seed a3471aa + integration). Package landed
  as draft **PR bridge#1** (f861d76 + 26a73ca on the task branch): parameterized client, 9/9
  invariant tests, typecheck+build clean, zero deps; README merged with the seed's framing.
  Review + [ack] + contract co-sign requested from zeus. Next: publish on operator's registry
  answer → migrate sub-store + vpn-core → the three weak copies.
- 2026-07-26: package source written and committed in a local staging repo (`231fbc7`):
  parameterized `BridgeClient` (sub-store transport + template error taxonomy), 9 invariant
  tests green, typecheck+build clean, zero runtime deps, README with migration guide. No CI
  workflow (integrator wires) and no `publishConfig.registry` (operator's Packages-vs-npm
  answer pending). Contract-row shape sent to zeus; repo creation requested (his gh grant).
- 2026-07-26: operator ruling: gh authority granted to zeus (can create the repo); npm NOT
  granted — GitHub Packages under evaluation by zeus. athena told to keep building as
  `@latticenet/plugin-bridge`.
- 2026-07-26: promoted draft → ready by zeus (letter 20260726-0805Z ack) with riders: extraction
  not redesign; zeus review gates merge + contract co-sign; merge ordered with/after dashboard
  host reconciliation. athena started: divergence measured (template 568 diff lines, nonce-only;
  wireguard/netguard pre-host_origin; vpn-core = sub-store modulo 3 parameters); design argument
  recorded above; home repo requested from operator by letter.
- 2026-07-25: created as `draft` at instantiation (F2 in the framework review).
