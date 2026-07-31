---
task: TASK-0015
title: NetGuard G3a - node-agent reality collector core
owner: hephaestus
status: in_progress
plan_ref: lattice/docs/designs/design-13-wireguard-and-netguard-plugins.md §9 G3
repos: [lattice-node-agent]
branches: [feat/hephaestus-task0015-netguard-reality-collector]
last_touched_by: hephaestus
depends_on: []
blocked_by_ruling: -
needs_ack: no
created: 2026-07-31
---

## Goal

Build the node-agent side of NetGuard G3 reality collection as an isolated, testable core. The
observable result is a pure Go collector/parser package that can normalize listening sockets,
interfaces, managed-table hash, foreign nft tables, and nft version into `model.GuardNodeReality`
without yet adding a server API or changing the agent poll loop.

## Scope & boundaries

- In:
  - Internal node-agent package for guard reality collection.
  - Injected command runner so tests do not execute host `ss`, `ip`, or `nft`.
  - Parsers/normalizers for representative `ss -tulpnH`, `ip -j addr`,
    `nft -j list ruleset`, `nft --version`, and managed table JSON.
  - Unit tests that reproduce the design-13 `dmit-eb-wee` class inputs: SSH listener, overlay
    interface, missing/foreign nft state, and stale managed table hash.
- Out:
  - `/api/agent/guard-reality` or any other server API.
  - Agent flag/poll-loop wiring.
  - Dashboard drift/suggestion UI.
  - Bootstrap/install plans, root execution, nft mutation, WireGuard mutation, workflows,
    releases, deploys, signing, or production access.
- **Allowed paths** (globs - checked mechanically at finish):
  - `lattice-node-agent/internal/guardreality/**`
  - `lattice-node-agent/go.mod`
  - `lattice-node-agent/go.sum`
- **Forbidden**:
  - Do not run live host discovery commands as part of this task.
  - Do not add dependencies.
  - Do not change server API, SDK/proto field numbers, CI workflows, task executor behavior, or
    node-agent startup flags.

## Notes

- Design-13 G3 exit is bigger than this slice: report endpoint, storage, suggestions engine,
  drift badge, and poll-loop wiring are follow-up tasks.
- SDK `model.GuardNodeReality`, `GuardListener`, and `GuardInterface` already exist on
  `lattice-sdk origin/integration@00943f6e`; this slice should reuse them rather than changing
  model contracts.
- The collector treats node facts as low-trust display/diff input only; it must not author policy
  or mutate nftables.

## DoD

- [ ] package returns `model.GuardNodeReality` with caller-supplied node id and collection time
- [ ] parser tests cover TCP/UDP listeners, interface addresses/up state, managed-table hashing,
      foreign table summaries, nft version, and command failure propagation
- [ ] no live `ss`, `ip`, `nft`, or root command is executed by tests
- [ ] diff stays inside Allowed paths
- [ ] `go test -race -cover ./...` passes in `lattice-node-agent`
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-31T12:23Z: started after TASK-0014 closed the already-satisfied server
  `jump_edges` producer. Worktree:
  `.wt/hephaestus-lattice-node-agent-task0015` from
  `lattice-node-agent origin/integration@03f730acb9653cc1a99c62c95510cafd58a4afad`.
