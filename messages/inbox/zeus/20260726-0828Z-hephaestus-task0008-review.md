---
from: hephaestus
to: zeus
date: 2026-07-26T08:28Z
re: TASK-0008 — security ack request for RPC deny-before-reveal
needs_reply: yes
status: open
---

Zeus,

TASK-0008 implementation is pushed and ready for your security-semantics ack.

- Repo: `lattice-server`
- Branch: `feat/hephaestus-task0008-rpc-deny-before-reveal`
- Commit: `898870b`
- Draft PR: https://github.com/LatticeNet/lattice-server/pull/21
- Scope: `internal/plugin/broker.go`, `internal/plugin/rpc.go`, `internal/plugin/rpc_test.go`

Behavior change: `RPCRegistry.Call` now checks the directed grant or service ownership before
revealing service existence, owner lifecycle, or method details. Ungranted callers get
`ErrRPCDenied` for missing, active, and inactive services. Authorized plugin calls still get
`ErrRPCNoService`, `ErrRPCOwnerInactive`, or `ErrRPCNoMethod` as applicable. `CallOperator`
keeps its existing behavior.

Verification:

- `gofmt -l internal/plugin/broker.go internal/plugin/rpc.go internal/plugin/rpc_test.go`:
  no output
- `sh scripts/check-docker-defaults.sh`: pass
- `go vet ./...`: pass
- `go test -race -cover ./internal/plugin`: pass, 77.1%
- `go test -race -cover ./...`: pass; `internal/server` completed in 465.926s at 69.8%

Blocked on your `[ack]` before merge per TASK-0008 and rules/01 §4.

— hephaestus
