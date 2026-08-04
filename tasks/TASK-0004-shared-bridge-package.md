---
task: TASK-0004
title: One published bridge package to replace the four divergent bridge.ts copies
owner: athena
status: blocked
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

## Real-browser migration gate (frozen 2026-08-04)

This gate validates the shared bridge in the five migrated plugin UIs. It authorizes only the
listed read paths and bridge handshakes. Do not enter admin controls, create plans, mutate plugin
data, inspect network payloads, or expose identifiers. All five rows are **NOT VERIFIED** while
the fresh isolated environment is absent.

| Plugin / exact head | Route and browser action | Exact PASS evidence | Safe persisted evidence | State |
|---|---|---|---|---|
| Sub-Store `3bf7bf5350ad2527665fbc66479e90ce0f5a47e8` | `/plugins/latticenet.sub-store/sub-store`; Pipelines → Reload. | Frame initializes without alert; `list_pipelines` resolves to empty or count state. | Header/status crop only; no pipeline names or payloads. | NOT VERIFIED — environment absent |
| Reference template `a2e355b8c89c269ec479177a0e4e7820be288aeb` | `/plugins/example.lattice-plugin/reference`; reload once. Do **not** click Generate dry-run plan. | `Host connected` is visible and the `Generate dry-run plan` button is exposed, proving the shared-client handshake, route pin, theme/init delivery, and callable-interface discovery. | Hero/status crop only; exclude the Sandbox state JSON. | NOT VERIFIED — environment absent |
| VPN Core `74eb20c08d039dfa7e50729d74f646a5cb24251d` | `/plugins/latticenet.vpn-core/lines`; press Refresh once. | `Lines` loads without alert; `latticenet.vpn-core/lines.list` resolves to the table or `No matching lines`. | Header plus empty/table-header crop; exclude line, node, user, traffic, and credential data. | NOT VERIFIED — environment absent |
| NetGuard `22ea8e5a819df14cfe789e608a20041e8f2fcef4` | `/plugins/latticenet.netguard/firewall`; press Refresh once. | `NetGuard` loads without alert; `latticenet.netguard/firewall.overview` resolves and summary counts/empty state render. | Header/summary-count crop; exclude node names, bindings, rules, zones, drift anchors, and plans. | NOT VERIFIED — environment absent |
| WireGuard `6ad14c76da3f1180599279564cfa75c11523edc2` | `/plugins/latticenet.wireguard/networks`; press Refresh once. | `WireGuard Networks` loads without alert; `latticenet.wireguard/networks.overview` resolves and summary counts/empty state render. | Header/summary-count crop; exclude node names, addresses, endpoints, key previews, config previews, and plans. | NOT VERIFIED — environment absent |

The common host identity is server `1e6103001f16d48110bce471d68e6e638e805ada`
plus dashboard `04c404601d5ab32d11dcd05c25e2f11ba9b8f39a`; plugin-index mirror is
`4ed4e5049eed77f76f91bee93a7c0c742c0fd310`. Any mismatch is a recorded finding and stops the
pass.

**Principal amendment (2026-08-04)** — same two deviations recorded in TASK-0003: the server head
moves to the no-ff merge `d6399ac81c7dcd6864032be2c6c087db6705fd64`, whose tree differs from
`1e61030` in exactly one line (`dashboard.ref`) and in no runtime code, and the environment is the
operator's own deployment under a read-only boundary instead of a fresh isolated one.

One row cannot be reached under that boundary and is called out in advance rather than quietly
counted: the **reference template** (`example.lattice-plugin`) is not among the four bundles
installed on that deployment, and installing it is exactly what the ruling forbids. That row stays
**NOT VERIFIED** and needs an isolated environment or a separate ruled install.

### Minimal human-run environment checklist (outcomes, not commands)

1. A human operator owns startup and shutdown of one fresh, isolated, non-production loopback
   environment assembled from the exact frozen heads above; no tag, release, signing, workflow
   dispatch, or production deployment is part of this proof.
2. Before browsing, the operator records exact server, dashboard, plugin, and index identity.
   Any mismatch remains FAIL/NOT VERIFIED; do not substitute another head.
3. Use only an already authenticated browser session with the least read/navigation scopes needed
   for these routes (`substore:read`, `vpncore:read`, `netguard:read`, `node:read`, and the
   template's `network:plan` navigation scope). No credential or browser state is transferred.
4. Execute the five rows above and TASK-0003's deterministic error row. Do not use admin buttons,
   write methods, plan methods, subscription endpoints, real subscription contents, or DevTools
   request/response inspection.
5. Return one UTC result matrix with exact-head match and per-row PASS/FAIL/NOT VERIFIED. Attach
   only the narrowly cropped safe UI regions specified above; do not send credentials, cookies,
   headers, storage, request/response bodies, keys, trust material, identifiers, config paths, or
   secret paths.

If a browser controller is unavailable, the human-run matrix is the evidence path; controller
attachment is not a prerequisite and must not be worked around by relaying browser secrets.

## Log

- 2026-08-04 (11:44Z): post-TASK-0018 exact baseline consumed and code-freeze blocker released.
  Read-only inspection of each frozen manifest/UI object produced the five-plugin matrix above:
  four manifest-declared read calls plus the template's fail-closed handshake/interface proof;
  every plan/write/admin path is excluded. **NOT VERIFIED**: the fresh isolated real-browser
  environment is not running. Environment outcome request sent to zeus; task moved to `blocked`;
  no code repo or other-seat worktree was changed.

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
