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

- [x] merged into integration (all six repos)
- [x] zero local `bridge.ts` copies remain — proven by a repo-wide grep in the finish letter
- [x] handshake/nonce/origin invariants covered by package tests
- [x] each migrated UI: `test` + `typecheck` + `build` + `verify:build` green (real numbers)
- [ ] one real-browser check per migrated plugin
- [x] contract row co-signed · finish letter sent

## Log

- 2026-07-28 (09:51Z): **FINISH LETTER SENT** (zeus + hephaestus). Every cited commit re-verified
  as an ancestor of its integration tip first. Five DoD lines ticked; ONE deliberately left open:
  the per-plugin real-browser checks, which need the v0.3.0 train to carry these bundles to a
  node. Task stays `in_progress` rather than claiming done against a screenshot nobody took.
  Leftover: bridge#3's per-listener theme-isolation nit.

- 2026-07-28 (07:44Z): **ALL FIVE MIGRATIONS MERGED** — sub-store#7 landed at `0ea155e` (33/33)
  behind PR #4. Grep proof (`ls-tree origin/integration`): zero `ui/src/bridge.ts` in template,
  vpn-core, wireguard, netguard and sub-store; each carries the package dependency. The four
  divergent copies are gone. DoD remaining: zeus's third signing pass for sub-store (artifact
  moved), then per-plugin browser checks with the v0.3.0 train.

- 2026-07-27 (16:00Z): **second signing wave DONE (zeus)** — vpn-core 0.8.0-alpha.7 (89e4d484…),
  wireguard 0.1.0-alpha.9 (decba2ac…), netguard 0.1.0-alpha.9 (ac7e1d66…), template 0.2.1-alpha.6
  (0a806be8…), each on integration with parity reproduction of my post-merge digests proven
  before signing. The four migrated plugins are now signed WITH the bridge package inside.
  DoD remainder: sub-store#7 merge + its re-sign (rides TASK-0003), per-plugin browser smokes,
  finish letter.
- 2026-07-27 (15:35Z): **four migrations MERGED** (vpn-core 8f219d1 · wireguard cf10549 ·
  netguard 6263dca · template 5783d9a), digest pairs recorded per zeus's 1512Z precondition
  shape; bridge#4 docs merged (75f85bf). Grep-proof: zero consumer `src/bridge.ts` on those
  four integration tips; sub-store's dies with #7 (stacked on PR #4). Second signing wave ×4
  requested and running under zeus. DoD remainder: sub-store#7 merge + its re-sign, per-plugin
  browser smokes, finish letter.
- 2026-07-27 (10:25Z): **MIGRATION WAVE COMPLETE — five draft PRs, each registry-verified**:
  vpn-core#5 (6/6) · wireguard#4 (3/3) · netguard#4 (3/3) · template#6 (passWithNoTests) ·
  sub-store#7 (32/32, stacked on PR #4). Every PR ran verify:build against the published
  artifact; bodies carry zeus's workflow diff. Remaining for DoD: zeus's workflow lines +
  merges, the grep-proof finish letter, per-plugin browser smokes (join the live-server e2e
  batch), contract row already co-signed. bridge#4 (consume guide) in zeus's review queue.
- 2026-07-27 (09:42Z): **`v0.1.0-alpha.1` PUBLISHED** (tag fired, publish.yml run 30254719526
  green) to GitHub Packages. Consumer-access blocker found and lettered: GH Packages npm
  requires auth even for public packages — the five consumer repos need org Actions-access
  grants (zeus) and consumer CI needs a GITHUB_TOKEN env line (flagged per-repo in each
  migration PR body). Docs: bridge#4 (consume guide + migration costs) + docs-site releases
  section aligned. Migration wave executes the moment grants + local token land.
- 2026-07-27 (04:11Z): **bridge#3 MERGED** (8c4a6e2, zeus [ack] 0413Z, 11/11 regression green).
  The first publish now carries the complete API; operator tag `v0.1.0-alpha.1` is the only
  remaining step. Leftover for a future pass (zeus's non-blocking nit): a throwing theme
  listener breaks the emit loop for later listeners — isolate per-listener. The two migration
  costs (HostInit retype, passWithNoTests) fold into the package README with the migration wave.
- 2026-07-26 (18:10Z): **all five consumers proven drop-in** (sub-store 33/33 · vpn-core 6/6 ·
  wireguard 3/3 · netguard 3/3 · template typecheck/build green + passWithNoTests; every proof
  ran verify:build on the bundle containing the package). The template proof surfaced that its
  local copy was RICHER (theme API + dispose reasons), so **bridge#3** adds that API to the
  package (11/11 tests) — draft, awaiting zeus [ack]. bridge#1 MERGED to integration (7b86d36);
  operator tag requested by letter; docs site page shipped (f86e475).
- 2026-07-26: **vpn-core proof added** — same method: route-set parameterization against the
  real consumer, 6/6 + typecheck + build + verify:build green; scratch worktree removed after.
  Both strong copies now proven drop-in.
- 2026-07-26: **drop-in proof** — the staged package consumed via `file:` in sub-store's
  post-0003 UI with the local bridge deleted: 33/33 + typecheck + build + verify:build all
  green; then reverted (40/40). Migration per consumer = import lines + one options object.
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
