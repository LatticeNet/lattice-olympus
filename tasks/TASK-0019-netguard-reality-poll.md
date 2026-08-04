---
task: TASK-0019
title: NetGuard G3d - node-agent reality poll wiring
owner: hephaestus
status: done
plan_ref: lattice/docs/designs/design-13-wireguard-and-netguard-plugins.md §9 G3
repos: [lattice-node-agent]
branches: [feat/hephaestus-task0019-netguard-reality-poll, integration@lattice-node-agent:bbcc26c8]
last_touched_by: hephaestus
depends_on: [TASK-0015, TASK-0017]
blocked_by_ruling: -
needs_ack: yes
created: 2026-08-04
---

## Goal

Complete the node-agent transport half of NetGuard G3 reality reporting. An explicit opt-in flag
causes each agent poll cycle to collect one complete low-trust guard-reality snapshot and POST it
to the existing bearer-authenticated `/api/agent/guard-reality` endpoint. Collection or transport
failure must be visible and must never send a partial snapshot or stop the rest of the poll loop.

## Scope & boundaries

- In:
  - Opt-in `--report-guard-reality` flag with environment parity; disabled by default.
  - One complete collector invocation and one report attempt per normal poll cycle when enabled.
  - Existing `postAgentJSON` transport, node identity, and bearer-token behavior without semantic
    changes.
  - Unit tests for disabled, success, collection-failure, and server-failure paths.
  - Node-agent README documentation for the opt-in report behavior.
- Out:
  - Server endpoint/storage changes, suggestion evaluation, dashboard drift UI, binding apply-state
    changes, bootstrap/install plans, nft mutation, WireGuard behavior, release/version work, or
    deployment.
  - Auth timing, token format, transport policy, enrollment, RBAC, or endpoint-contract changes.
- **Allowed paths** (globs - checked mechanically at finish):
  - `lattice-node-agent/cmd/lattice-agent/main.go`
  - `lattice-node-agent/cmd/lattice-agent/guard_reality_test.go`
  - `lattice-node-agent/README.md`
- **Forbidden**:
  - Do not run live `ss`, `ip`, or `nft` discovery commands during tests or agent work.
  - Do not add dependencies or edit SDK/proto, server, workflows, install scripts, release files,
    task execution, terminal transport, or agent-auth semantics.

## Notes

- TASK-0015 provides the fail-whole `internal/guardreality` collector; TASK-0017 provides the
  accepted endpoint and persisted contract. Both are merged.
- The flag is deliberately opt-in because collection invokes host discovery binaries and G3 is
  still an alpha path. Tests inject the collector and HTTP transport; they do not inspect the
  workstation.
- `needs_ack: yes` preserves the Zeus gate because the new call rides the existing agent bearer
  channel, even though this task must not modify authentication behavior.

## DoD

- [x] merged into `lattice-node-agent` integration after exact-head Zeus `[ack]`
- [x] diff stays inside Allowed paths (mechanical check)
- [x] disabled mode performs zero collector calls and zero requests - proven by
      `TestReportGuardReality/disabled`
- [x] success sends the exact node-bound payload and bearer-authenticated endpoint request - proven
      by `TestReportGuardReality/success`
- [x] collector failure sends no partial request, and server failure is surfaced without masking -
      proven by `TestReportGuardReality/collect_failure` and `/server_failure`
- [x] `gofmt`, `go vet ./...`, and `go test -race -cover ./...` pass
- [x] README documents the opt-in behavior and low-trust/no-apply boundary
- [x] finish letter sent

## Log (append-only, newest first)

- 2026-08-04T07:27Z: Zeus `[ack]` on exact `c1c2161` was persisted before landing. A detached
  Hephaestus-only merge candidate from unchanged `origin/integration@3e505d6` produced
  `bbcc26c8fa271f3ae2f068ca10f2ed7b6d55372f` with exact ordered parents `3e505d6`, `c1c2161`,
  and a tree identical to the acknowledged feature. Final gofmt, release-workflow,
  install-integrity, vet, and full race/coverage gates passed; the post-merge `go test ./...
  -count=1` quick regression passed. Remote integration equals `bbcc26c8`; PR #9 is MERGED with
  landing comment `5175883620`. GitHub's automatic feature-ref deletion was repaired by an
  ordinary non-force push restoring exact `c1c2161`. Both clean Hephaestus TASK-0019 worktrees
  were removed and no other worktree was touched. No live discovery, cross-process report,
  release, signing, deployment, CI dispatch, or Olympus push occurred.
- 2026-08-04T06:36Z: implementation committed locally as
  `c1c2161350aebc07bc1c403b2538a1d1cdfbae`. Exact diff is the three Allowed paths. The final
  report runs after core poll work, shares one 10-second context across collection and POST, sends
  nothing on collection failure, and leaves auth semantics unchanged. Focused normal/race tests,
  next-cycle recovery, injected POST deadline, `gopls check`, release-workflow check,
  install-integrity check, `go vet ./...`, and `go test -race -cover ./... -count=1` all passed;
  package coverage includes `cmd/lattice-agent` 34.2% and `internal/guardreality` 81.1%.
  Independent review's MEDIUM poll-starvation and LOW invalid-SHA findings were fixed; its
  remaining LOW whole-loop coverage observation is bounded by the next-cycle recovery test and
  the report's final position in the loop. Live discovery and cross-process server reporting were
  not executed. Branch push and Draft PR follow this Touch.
- 2026-08-04T06:15Z: started in isolated worktree
  `.wt/hephaestus-lattice-node-agent-task0019` on
  `feat/hephaestus-task0019-netguard-reality-poll` from exact
  `origin/integration@3e505d66c3a6982e680107edc0f4d816f11adea3`. TASK-0015 collector and
  TASK-0017 endpoint are merged; no open Hephaestus letters or conflicting seat claims were found.
