---
task: TASK-0005
title: Extract a plugin Go SDK (stdio runtime loop + typed host client + manifest types)
owner: hephaestus
status: draft
plan_ref: plan/design-substore-embed.md §3 F5
repos: [lattice-sdk, lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard]
branches: []
last_touched_by: hephaestus
depends_on: []
blocked_by_ruling: —
needs_ack: yes    # host-call framing is security-adjacent → zeus
created: 2026-07-25
---

## Goal

Plugin authors import the runtime loop instead of re-implementing it: stdio framing, fd-3 host
call/response scanning, error mapping, and manifest/capability types.

## Scope & boundaries

- In: a Go module (in `lattice-sdk` or a new `lattice-plugin-sdk` — decide in the task, record
  the reason) carrying the stdio loop, a typed host client (`rpc.call`, `http.do`,
  `http.operator.do`, `kv.*`, `notify.send`, `log.write`, and `secret.*` once merged), and the
  manifest/capability types; migrate the five plugins onto it.
- Out: changing the wire protocol; server-side changes.
- **Allowed paths**: the SDK module + each plugin's `system-go/**`.
- **Forbidden**: duplicating the server's authorization logic into the SDK (the host is the
  gate — an SDK-side check is a convenience, never a control).

## Notes

- Today every manifest/capability/plan/secret type lives in `lattice-server/internal/plugin`
  and is unimportable; each plugin hand-rolls framing (sub-store `system-go/main.go` 779L vs
  template 117L).
- Keep the SDK free of anything that would tempt a plugin to assume it is trusted; the artifact
  boundary is the security boundary.

## DoD

- [ ] merged into integration
- [ ] all five plugins build on the SDK with their conformance tests still green
- [ ] SDK has its own tests for framing + fd-3 host-call round-trip
- [ ] `go test -race -cover ./...` green in SDK and every migrated plugin (real numbers)
- [ ] artifact digests recomputed and manifests re-signed by zeus where artifacts changed
- [ ] finish letter sent

## Log

- 2026-07-25: created as `draft` at instantiation (F5 in the framework review).
