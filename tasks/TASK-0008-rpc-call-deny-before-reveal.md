---
task: TASK-0008
title: RPC bus — deny before reveal (grant check ahead of lifecycle probe)
owner: hephaestus
status: draft
plan_ref: TASK-0001 finding (server#8 review)
repos: [lattice-server]
branches: []
last_touched_by: zeus
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

- [ ] ungranted caller receives an existence/lifecycle-blind error, pinned by test
- [ ] comment matches behavior
- [ ] full CI-mirror suite green (`-race -cover`), numbers reported
- [ ] zeus [ack] (security semantics), finish letter

## Log (append-only, newest first)

- 2026-07-26: drafted by zeus from the TASK-0001 server#8 finding.
