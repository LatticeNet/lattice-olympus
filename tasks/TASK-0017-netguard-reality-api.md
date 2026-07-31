---
task: TASK-0017
title: NetGuard G3c - server reality persistence and API
owner: hephaestus
status: in_progress
plan_ref: lattice/docs/designs/design-13-wireguard-and-netguard-plugins.md §9 G3 + contract/api-contract.md §2
repos: [lattice-server]
branches: [feat/hephaestus-task0017-netguard-reality-api]
last_touched_by: hephaestus
depends_on: [TASK-0015, TASK-0016, contract row #8]
blocked_by_ruling: —
needs_ack: yes    # agent auth/read visibility semantics are gated by zeus before merge
created: 2026-07-31
---

## Goal

Persist one latest normalized NetGuard reality snapshot per node and expose the in-force
`POST /api/agent/guard-reality` plus `GET /api/netguard/reality` contract, so later dashboard
and agent-wiring slices can consume reality without inventing storage or visibility semantics.

## Scope & boundaries

- In: `lattice-server` storage/accessors for latest guard reality, HTTP handlers for the signed
  write/read contract, normalization/limits/staleness/cursor logic, audit metadata with counts,
  and server tests proving the contract's security and shape.
- Out: node-agent polling/posting integration; dashboard UI; plugin gateway interfaces; policy
  mutation; plan/apply/approval changes; SDK/proto field changes; release/deploy/signing/CI files.
- Allowed paths: `internal/store/**`, `internal/server/**`, and `internal/netguard/**` only if
  normalization helpers naturally belong with the existing suggestion core.
- Forbidden: persisting raw request bodies, bearer credentials, collector stderr, or using
  reality as policy/apply input. Read summaries must not expose listeners, process names,
  addresses, or foreign-table names.

## Claims

- `contract/api-contract.md` row #8 is in force and co-signed.
- `contract/shared-resources.md`: State collection `GuardRealitySnapshots`, in progress for
  TASK-0017. Plaintext is intentional for this collection: it stores normalized low-trust
  operational facts and server receipt time only, with no secrets, tokens, raw payloads, paths, or
  stderr.

## DoD

- [ ] `POST /api/agent/guard-reality` authenticates node bearer tokens from `Authorization` only,
      rejects mismatched/invalid nodes uniformly, enforces the 1 MiB body and per-field bounds,
      normalizes before atomic replacement, and audits only node id plus counts.
- [ ] `GET /api/netguard/reality` returns node-id-sorted, allowlist-filtered, cursor-paginated
      summaries including visible unknown nodes, and returns filtered details with the
      unknown/404 distinction from contract §2.2.
- [ ] Timestamp semantics covered: required UTC `collected_at`, future clamp with response flag,
      stale/equal-time conflict behavior, `stale_after = collected_at + 30h`, and server-time
      freshness.
- [ ] No low-trust reality path mutates NetGuard intent, approvals, tasks, or apply state.
- [ ] Targeted contract tests plus `go test -race -cover ./internal/server ./internal/store`
      pass; full `gofmt`, `sh scripts/check-docker-defaults.sh`, `go vet ./...`, and
      `go test -race -cover ./...` pass before merge.
- [ ] Zeus `[ack]` received on exact tested head before merge.
- [ ] PR opened against `integration`; finish letter sent with tests, conflicts, docs, and
      leftovers.

## Log (append-only, newest first)

- 2026-07-31T13:53Z: claimed after contract row #8 became in force. Created isolated
  `lattice-server` worktree `.wt/hephaestus-lattice-server-task0017` on
  `feat/hephaestus-task0017-netguard-reality-api` from `origin/integration@3fcf54a`.
