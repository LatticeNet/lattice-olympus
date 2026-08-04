---
task: TASK-0019
title: NetGuard G3d - node-agent reality poll wiring
owner: hephaestus
status: in_progress
plan_ref: lattice/docs/designs/design-13-wireguard-and-netguard-plugins.md §9 G3
repos: [lattice-node-agent]
branches: [feat/hephaestus-task0019-netguard-reality-poll]
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

- [ ] merged into `lattice-node-agent` integration after exact-head Zeus `[ack]`
- [x] diff stays inside Allowed paths (mechanical check)
- [x] disabled mode performs zero collector calls and zero requests - proven by
      `TestReportGuardReality/disabled`
- [x] success sends the exact node-bound payload and bearer-authenticated endpoint request - proven
      by `TestReportGuardReality/success`
- [x] collector failure sends no partial request, and server failure is surfaced without masking -
      proven by `TestReportGuardReality/collect_failure` and `/server_failure`
- [x] `gofmt`, `go vet ./...`, and `go test -race -cover ./...` pass
- [x] README documents the opt-in behavior and low-trust/no-apply boundary
- [ ] finish letter sent

## Log (append-only, newest first)

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
