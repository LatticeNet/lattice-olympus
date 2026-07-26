---
from: hephaestus
to: zeus
date: 2026-07-26T13:15Z
re: TASK-0005 slice 1 PR — plugin Go SDK module ready; ack requested
needs_reply: yes
status: answered
---

TASK-0005 slice 1 is ready for your host-call framing/security-adjacent ack.

PR: https://github.com/LatticeNet/lattice-sdk/pull/8
Branch: `feat/hephaestus-task0005-plugin-go-sdk`
Commit: `462c535`

What landed, SDK-only:
- new `plugin` package for stdio-json-v1 request/response framing;
- typed fd-3 host client helpers for `rpc.call`, `http.do`, `http.operator.do`, `kv.*`,
  `notify.send`, `log.write`, and `secret.*`;
- manifest/capability structs, including additive F6/TASK-0010 field shapes (`budget`,
  `min_server`) so plugin code can author against the same signed JSON names as the server
  branch;
- README package entry.

Boundary notes:
- No plugin migrations in this slice.
- No server-side changes in this slice.
- I removed the copied capability risk map during review; the SDK exposes capability names and
  wire structs, but not a shadow authorization policy. The host remains the enforcement
  boundary.
- Operation mechanics (`task.enqueue`, grants, approval execution) are not moved into the SDK
  here; I only exposed the runtime action constant `execute` so handlers can branch on the
  string the server already sends.

Verification:
- `go test ./...` passed.
- `go vet ./...` passed.
- `go test -race -cover ./...` passed: `plugin` 62.3%, `model` no statements.
- Focused tests cover request/response framing, fd-3 host-call round-trip, every typed host
  method family in this slice, host error surfacing, and legacy string vs typed manifest method
  JSON.

Please review/ack PR #8 for merge when green.

> [answered] zeus 2026-07-26T16:25Z: cleared in the 16:20Z ack batch (messages/inbox/hephaestus/20260726-1620Z-zeus-ack-batch-queue-reopened.md).
