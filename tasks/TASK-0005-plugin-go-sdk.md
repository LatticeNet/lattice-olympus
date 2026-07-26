---
task: TASK-0005
title: Extract a plugin Go SDK (stdio runtime loop + typed host client + manifest types)
owner: hephaestus
status: ready
plan_ref: plan/design-substore-embed.md §3 F5
repos: [lattice-sdk, lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard]
branches: [feat/hephaestus-task0005-plugin-go-sdk]
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

**SLICED (operator ruling 2026-07-26, ordered-list §3): slice 1 stands alone and is claimable
without touching any plugin — the "first unblocked slice must stand alone" rule.**

- **Slice 1 (standalone, depends on nothing)**: the Go module INSIDE `lattice-sdk` (the ruling
  fixes the home; the old in-task decision point is resolved) carrying the stdio loop, a typed
  host client (`rpc.call`, `http.do`, `http.operator.do`, `kv.*`, `notify.send`, `log.write`,
  `secret.*`), and the manifest/capability types — with its own framing + fd-3 round-trip
  tests. Deliverable: importable module, green suite, finish note; NO plugin touched.
- **Slice 2 (after slice 1 merges)**: migrate the five plugins onto it; conformance stays
  green per plugin; digests recomputed ⇒ zeus re-sign pass.
- Out: changing the wire protocol; server-side changes.
- **Allowed paths**: slice 1 `lattice-sdk/**` only · slice 2 adds each plugin's `system-go/**`.
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

- 2026-07-26T12:25Z: parked without code changes after F6 was acked as the first TASK-0002
  Phase 2 slice; branch/worktree remain available for the standalone SDK module.
- 2026-07-26T12:09Z: started slice 1 only in private worktree `.wt/hephaestus-lattice-sdk`
  from `lattice-sdk` `origin/integration` (`e510bd7`) on branch
  `feat/hephaestus-task0005-plugin-go-sdk`. No plugin migration in this slice.
- 2026-07-26T12:05Z: promoted draft → ready by zeus per operator ruling (ordered-list §3);
  sliced so slice 1 (SDK module in lattice-sdk) is separately claimable — the forge-idling
  error this cycle is fixed in the file, not just the routing. Baseline exists: all ten repos
  have `integration`.
- 2026-07-25: created as `draft` at instantiation (F5 in the framework review).
