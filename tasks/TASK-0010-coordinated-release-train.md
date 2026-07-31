---
task: TASK-0010
title: Coordinated public release train — one verified standard version across the fleet of repos
owner: zeus
status: in_progress
plan_ref: olympus-launch/operator-ruling-2026-07-26.md §1b (operator requirement)
repos: [lattice-olympus, lattice-sdk, lattice-server, lattice-dashboard, lattice-node-agent, lattice-plugin-template, lattice-plugin-vpn-core, lattice-plugin-netguard, lattice-plugin-wireguard, lattice-plugin-sub-store, lattice-plugin-index, latticenet.github.io]
branches: []
last_touched_by: zeus
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # amends rules/01 §8.5 → co-sign per rules/02 §7; release mechanics stay operator-only
created: 2026-07-26
---

## Goal

LatticeNet publicly presents ONE verified standard version a user deploys or upgrades to —
server · dashboard · node-agent · sdk · every plugin — with mutual dependency pins explicit
and legible **from the release itself**, not from tribal knowledge.

Operator's stated model (ruling §1b):
- dev/test builds carry `vX.Y.Z-alpha.N` / `-beta.N` while the released line is `vX.Y.(Z-1)`;
- a train that passes verification is promoted to plain `vX.Y.Z` across the whole fleet as
  ONE coordinated act;
- cross-repo pins (server↔sdk↔dashboard refs, plugin↔server minimum version, plugin-index
  channel entries) resolve from the release artifacts themselves.

## Scope & boundaries (sliced — slice 1 depends on nothing)

- **Slice 1 — document the CURRENT pin graph (standalone, first deliverable)**: one document
  (home: `lattice` design-docs repo or latticenet.github.io — record the choice) mapping every
  cross-repo pin as it exists today: server's `sdk.ref` + `dashboard.ref` SHAs, each plugin's
  minimum-server expectation, plugin-index channel entries, node-agent↔server compatibility,
  Astra's pin if any. Every claim carries its source path (repo + file). No process change.
- **Slice 2 — the release-manifest format**: a machine-checkable release matrix (versions +
  pins + digests) that a train produces and a user can read; where it lives (likely
  plugin-index or a release asset per repo) and what CI validates.
- **Slice 3 — amend `rules/01 §8.5`**: add the promotion protocol (alpha/beta train →
  verification → coordinated `vX.Y.Z` cut) to the three-lane law. Rules change ⇒ co-sign per
  rules/02 §7; zeus holds the pen.
- Out: executing any release (operator-only, rules/03); changing the three tag lanes
  themselves; retroactive re-tagging.
- **Allowed paths**: docs + `rules/01` (slice 3, co-signed) + CI validation additions under
  the normal review flow. Tag pushes NEVER (operator hands).

## Notes

- The written release manifest/matrix must exist BEFORE the next stable cut (operator: hard
  requirement).
- Public-surface conditions apply (ruling §7): no internal hosts/IPs/fleet posture in any of
  it; latticenet.github.io updates ride the same work.

## DoD

- [x] slice 1: pin-graph document merged, every pin sourced (repo + file path), gaps named
- [x] slice 2: release-manifest format agreed (letter round) and validated by CI on at least
      one repo
- [x] slice 3: rules/01 §8.5 amendment co-signed and merged
- [ ] operator sign-off that the next stable cut can run from this (release itself stays theirs)
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-31T11:43Z: post-merge verification exposed a stable-cut readiness gap that the green
  workflow does not report. The isolated CI-layout `make test` exited 0 but changed tracked
  `go.work.sum` from 2 lines to 10; the current workflow does not assert a clean tree after tests.
  The temporary worktree and its modification were removed after the diff was inspected; no shared
  clone changed. This does not invalidate the docs-only merge, but TASK-0010 operator sign-off stays
  open until a separate reviewed slice decides whether to refresh the workspace sums, tighten the
  pins, and/or add a dirty-tree guard. No workflow edit or dispatch was performed in this round.

- 2026-07-31T11:34Z: slices 1 and 2 landed in their recorded order. lattice#3 was reviewed at
  exact head `680be3a`, received Athena r4 `[ack]`, and landed as the Olympus-required no-ff merge
  `4015f17` on `integration`; an isolated five-worktree CI layout then ran the original `make test`
  successfully without writing any shared clone. plugin-index#3 followed only after that landing,
  received Hephaestus r4 `[ack]`, reran `npm test` (1 accepted, 7 rejected), and landed as no-ff
  merge `a54bb9e` on `integration`. Both PRs are MERGED. No tag, release, signing, deployment, or
  workflow dispatch occurred. The task remains `in_progress`: only the human operator may sign off
  that the next stable cut can run from this, and the finish letter stays open until that decision.

- 2026-07-31T11:21Z: lattice#3 r4 is pushed at `680be3a`. The node-agent stable row now names
  `v0.2.9` with tag chronology/ancestry verified; the plugin→server edge distinguishes signed
  `compatibility.server` metadata, the optional signed `min_server` mechanism, and the absence of
  selected floors; the deployment observation cites the persisted Olympus field record. All five
  snapshot manifests, server validation semantics, and the deploy record were inspected;
  semantic assertions, `git diff --check`, independent r4 review `[ack]`, and GitHub workspace CI
  (`gofmt`, `make test`, `make build`, `gosec`) passed. Athena's formal r4 is the sole remaining
  train review gate; plugin-index#3 stays ready and ordered after it.

- 2026-07-31T11:04Z: Hephaestus returned the formal plugin-index#3 r4 `[ack]` with an
  independent 1 accepted / 7 rejected validator run and both planted counterexamples rejecting.
  The PR is ready, both checks are green, and its merge-base exactly equals current
  `integration@d64746e`. It remains intentionally unmerged until lattice#3 lands first, preserving
  the task's cross-repo docs-before-index order. Athena r3 is now the only release-train review
  response outstanding.

- 2026-07-31T10:52Z: review corrections are now pushed in both remaining code repos. lattice#3
  r3 is `dad071d`: the whole pin graph is an auditable `2026-07-27T14:53Z` snapshot, later
  versioned train artifacts are separated from snapshot-era `train.json` law, and validator
  claims are limited to structure/tag lanes/local cross-field invariants. `git diff --check`,
  five-component/zero-`min_server` inspection, independent review `[ack]`, and GitHub workspace
  CI passed; Athena's formal r3 remains the merge gate. plugin-index#3 r4 is `ab293d4`: server
  image tags are now server-only, the server lane is exactly `alpha-X.Y.ZaN`, 1 valid + 7 invalid fixtures pass,
  and both GitHub checks are green. Hephaestus's formal r4 remains its merge gate. No release,
  tag, deploy, signing, or workflow dispatch was performed.

- 2026-07-31T10:19Z: resumed from checkpoint with a read-only audit of every core/plugin/docs
  repo and registered worktree. The durable gaps are now explicit: lattice#3 remains open after
  athena's r1 findings were applied; plugin-index#3 remains open after hephaestus's r2 findings
  were applied; the first real train is committed on that branch but not merged. Established the
  missing `latticenet.github.io` integration baseline from its unchanged main tip, retargeted and
  merged docs#2 at `e4ee963b`, then re-ran `npm test` (site-content + VitePress build) and
  `check:pins` (1/1, node-agent latest stable `v0.2.9`) successfully. No release, tag, deploy, or
  workflow dispatch was performed. Final review requests are batched by letter; slice 3 was
  already co-signed/merged and its stale DoD box is corrected above.

- 2026-07-27T04:25Z: slice 2 SUBSTANTIALLY DELIVERED — format proposal ack'd (Decision A(b)
  closed, min_server implemented in server#22 MERGED); schema + zero-dep validator + example
  + CI shipped as plugin-index#3 (draft → integration), verified both directions (planted
  defects all caught). Remaining for slice 2: Decision B naming (operator; schema takes either
  answer) + first REAL train.json generated at the first coordinated cut. Slice 3 (rules/01
  §8.5 amendment) drafts after Decision B or after the 24h buffer with v0.3.0 default.
- 2026-07-26T12:40Z: slice 1 DELIVERED — `docs/contracts/release-pin-graph.md` on branch

- 2026-07-26T12:40Z: slice 1 DELIVERED — `docs/contracts/release-pin-graph.md` on branch
  `docs/zeus-task0010-pin-graph`, draft PR lattice#3 → integration. Every pin sourced; six
  gaps named (G1 no plugin→server min-version · G2 dashboard.ref lacks #9 until reconciliation
  + ref bump · G3 no single train artifact · G4 Astra/sing-box unpinned · G5 index
  hand-generated · G6 injected server version). Slice 2 next: release-manifest format proposal
  letter — must fold the F6 manifest-schema change into the SAME re-sign wave (one wave, not
  two). Merge of #3 awaits a second pair of eyes (no self-approve).
- 2026-07-26T12:30Z: claimed by zeus; starting slice 1. Home choice: the `lattice` design-docs
  repo (design docs are the contract there; the github.io mirror follows in slice 2 with the
  release-manifest format). `lattice` had no `integration` branch — created from `main` under
  the §7 branch-management grant, following the operator's own from-main precedent for the six.
  Branch: `docs/zeus-task0010-pin-graph`.
- 2026-07-26T12:06Z: created by zeus per operator ruling §1b; sliced so slice 1 (pin-graph
  documentation) depends on nothing.
