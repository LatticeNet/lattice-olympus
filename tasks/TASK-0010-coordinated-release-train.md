---
task: TASK-0010
title: Coordinated public release train — one verified standard version across the fleet of repos
owner: zeus
status: ready
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

- [ ] slice 1: pin-graph document merged, every pin sourced (repo + file path), gaps named
- [ ] slice 2: release-manifest format agreed (letter round) and validated by CI on at least
      one repo
- [ ] slice 3: rules/01 §8.5 amendment co-signed and merged
- [ ] operator sign-off that the next stable cut can run from this (release itself stays theirs)
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-26T12:06Z: created by zeus per operator ruling §1b; sliced so slice 1 (pin-graph
  documentation) depends on nothing.
