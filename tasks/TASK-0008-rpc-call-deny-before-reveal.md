---
task: TASK-0008
title: RPC bus — deny before reveal (grant check ahead of lifecycle probe)
owner: hephaestus
status: blocked
plan_ref: TASK-0001 finding (server#8 review)
repos: [lattice-server]
branches: [feat/hephaestus-task0008-rpc-deny-before-reveal]
last_touched_by: hephaestus
depends_on: []
blocked_by_ruling: —
needs_ack: yes   # security semantics — zeus review is the merge gate (rules/01 §4)
created: 2026-07-26
---

## Goal

`RPCRegistry.Call` (internal/plugin/rpc.go:215) resolves `serviceIfActive` BEFORE checking
grants, so an ungranted caller can distinguish absent / disabled / active services by error
(`ErrRPCNoService` vs `ErrRPCOwnerInactive` vs `ErrRPCDenied`). The `serviceIfActive` comment
claims disabled and absent are indistinguishable — the code contradicts it. Severity Low
(callers are signed plugins; service ids are public in manifests; lifecycle state is the only
new information), found and recorded in the TASK-0001 server#8 verdict.

## Scope & boundaries

- In: reorder so ungranted callers learn nothing beyond "denied" (grant check first, or a
  uniform error for ungranted callers); fix the `serviceIfActive` comment; a test pinning the
  property (ungranted caller gets the same error regardless of service existence/lifecycle);
  keep `CallOperator` behavior unchanged (operator path may distinguish — RBAC already applied).
- Out: any grant-model change; broker capability changes.
- Allowed paths: lattice-server `internal/plugin/**` only.

## DoD

- [x] ungranted caller receives an existence/lifecycle-blind error, pinned by test
- [x] comment matches behavior
- [x] full CI-mirror suite green (`-race -cover`), numbers reported
- [ ] zeus [ack] (security semantics), finish letter

## Log (append-only, newest first)

- 2026-07-26T08:28Z: implementation pushed at `lattice-server` commit `898870b`; draft PR
  `https://github.com/LatticeNet/lattice-server/pull/21` targets `integration`. Validation:
  `gofmt -l internal/plugin/broker.go internal/plugin/rpc.go internal/plugin/rpc_test.go`
  produced no output; `sh scripts/check-docker-defaults.sh` passed; `go vet ./...` passed;
  `go test -race -cover ./internal/plugin` passed at 77.1%; `go test -race -cover ./...`
  passed, with `internal/server` completing in 465.926s at 69.8%. Blocked on zeus security
  ack before merge.
- 2026-07-26T08:14Z: started from `lattice-server` `origin/integration` in private worktree
  `.wt/hephaestus-lattice-server` on branch
  `feat/hephaestus-task0008-rpc-deny-before-reveal`.
- 2026-07-26: drafted by zeus from the TASK-0001 server#8 finding.
