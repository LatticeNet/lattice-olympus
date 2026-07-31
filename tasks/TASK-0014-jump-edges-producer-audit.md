---
task: TASK-0014
title: Close the server jump_edges producer backlog item against integration
owner: hephaestus
status: done
plan_ref: plan/dev-history-2026.md open threads + plan/README.md backlog item "jump_edges producer"
repos: [lattice-server]
branches: [audit worktree feat/hephaestus-task0014-jump-edges-producer @ lattice-server:0fef1eb]
last_touched_by: hephaestus
depends_on: []
blocked_by_ruling: -
needs_ack: no
created: 2026-07-31
---

## Goal

Decide whether the planned server-side `jump_edges` producer still needs implementation. Observable
result: either a scoped server diff lands, or the backlog item is closed with exact integration
evidence that the producer already exists and is tested.

## Scope & boundaries

- In:
  - Read-only audit of `lattice-server` `origin/integration`.
  - Targeted verification of the existing Lines read-model relay-edge behavior.
  - Olympus coordination record for the backlog closure.
- Out:
  - Dashboard topology rendering.
  - Node-agent sidecar metadata changes.
  - Any auth, RBAC, plugin trust, signing, release, deploy, workflow, or ops action.
- **Allowed paths** (globs - checked mechanically at finish):
  - `lattice-server/internal/server/lines.go` (read-only audit; no diff)
  - `lattice-server/internal/server/lines_test.go` (read-only audit; no diff)
  - `lattice-olympus/tasks/TASK-0014-jump-edges-producer-audit.md`
  - `lattice-olympus/status/hephaestus.md`
  - `lattice-olympus/messages/inbox/zeus/20260731-1218Z-hephaestus-task0014-jump-edges-closure.md`
- **Forbidden**:
  - Do not fabricate a code delta when integration already satisfies the plan item.
  - Do not touch shared clones or another seat's worktree.

## Notes

- `lattice-server` `origin/integration@0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb` already carries:
  - `Line.JumpEdges []string` with JSON field `jump_edges` in `internal/server/lines.go`.
  - Fleet-wide outbound host/port resolution in `buildLineGroups`.
  - `vpn-core/lines` RPC list/get serialization through the `Line` read model.
  - `TestBuildLineGroupsResolvesJumpEdges` covering hub-to-exit resolution and direct-line absence.
- A hephaestus-owned audit worktree was created at
  `.wt/hephaestus-lattice-server-task0014` from `origin/integration`, verified clean, then
  removed after the audit; no code files changed.

## DoD

- [x] exact integration head recorded: `0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb`
- [x] no code diff from `origin/integration`
- [x] `jump_edges` producer exists in `buildLineGroups` - verified at `internal/server/lines.go`
- [x] relay-edge behavior is pinned by `TestBuildLineGroupsResolvesJumpEdges`
- [x] targeted verification passed:
      `go test ./internal/server -run 'TestBuildLineGroupsResolvesJumpEdges|TestVPNCoreLinesRPC' -count=1`
- [x] finish/audit letter sent

## Log (append-only, newest first)

- 2026-07-31T12:18Z: audited `lattice-server origin/integration@0fef1eb` in
  `.wt/hephaestus-lattice-server-task0014`, then removed that clean worktree. The planned
  `jump_edges` producer is already present: `Line.JumpEdges` is part of the JSON read model,
  `buildLineGroups` resolves outbound host/port to downstream `line_hash_id`, and the targeted
  resolver/RPC tests pass. Closed as a no-code backlog item.
