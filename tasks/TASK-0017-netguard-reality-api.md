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

- [x] `POST /api/agent/guard-reality` authenticates node bearer tokens from `Authorization` only,
      rejects mismatched/invalid nodes uniformly, enforces the 1 MiB body and per-field bounds,
      normalizes before atomic replacement, and audits only node id plus counts.
- [x] `GET /api/netguard/reality` returns node-id-sorted, allowlist-filtered, cursor-paginated
      summaries including visible unknown nodes, and returns filtered details with the
      unknown/404 distinction from contract §2.2.
- [x] Timestamp semantics covered: required UTC `collected_at`, future clamp with response flag,
      stale/equal-time conflict behavior, `stale_after = collected_at + 30h`, and server-time
      freshness.
- [x] No low-trust reality path mutates NetGuard intent, approvals, tasks, or apply state.
- [x] Targeted contract tests plus `go test -race -cover ./internal/server ./internal/store`
      pass; full `gofmt`, `sh scripts/check-docker-defaults.sh`, `go vet ./...`, and
      `go test -race -cover ./...` pass before merge.
- [ ] Zeus `[ack]` received on exact tested head before merge.
- [x] PR opened against `integration`.
- [ ] Finish letter sent with tests, conflicts, docs, and leftovers after merge.

## Log (append-only, newest first)

- 2026-08-03T10:34Z: resumed for bounded r4 after Zeus's exact-head r3 request-changes. The
  registered `.wt/hephaestus-lattice-server-task0017` is clean at local/remote/PR head
  `b18009675fd5f604044d8b575169a7c9f74704bd`. Sole HIGH: process restart loses the in-memory
  durability-degraded flag without confirming parent-directory sync. r4 will explicitly and
  testably sync the existing state file's parent during open, leaving startup unhealthy on
  failure and clearing only on confirmed success. Auth timing, policy/apply, UI, release, and the
  pre-existing general `Store.Save` lock contract remain out of scope.
- 2026-08-03T08:57Z: automatic GitHub `ci / go` run `30798882690`, job `91638637323`,
  completed SUCCESS on exact r3 head `b18009675fd5f604044d8b575169a7c9f74704bd` in 7m09s;
  gofmt, Docker defaults, vet, tests, gosec, and govulncheck all passed. PR #27 is
  OPEN/CLEAN/Draft. Sent r3 exact-head review request
  `20260803-0857Z-hephaestus-task0017-r3-review.md`; merge remains gated on Zeus `[ack]`.
- 2026-08-03T08:49Z: r3 commit `b18009675fd5f604044d8b575169a7c9f74704bd`
  pushed by ordinary fast-forward to draft PR #27. The r2→r3 delta changes only
  `internal/store/store.go` and `internal/store/guard_reality_test.go`: a committed
  parent-directory sync failure now makes `ReadyCheck` sticky-unhealthy; idempotent no-write and
  pre-rename failed retries keep it unhealthy; a later committed write with successful parent
  sync clears it. Normal health plus live/reopened/retry convergence remain covered. Exact-tree
  targeted normal/race tests, full `go test ./... -count=1`, `go vet ./...`, Docker defaults,
  gofmt, diff-check, staged redaction, and `go test -race -cover ./...` passed
  (`internal/server` 499.982s / 70.0%, `internal/store` 10.971s / 61.3%). Independent read-only
  review returned `[ack]`; its one actionable LOW test gap was added before final gates. Automatic
  exact-head CI run `30798882690`, job `91638637323`, is in progress; no manual trigger attempted.
- 2026-08-03T08:24Z: resumed for narrow r3 after Zeus's persisted r2 request-changes. Verified
  `.wt/hephaestus-lattice-server-task0017` remains the registered clean worktree on
  `feat/hephaestus-task0017-netguard-reality-api`; local HEAD, remote feature branch, and draft
  PR #27 all equal r2 `cacb1c318917b1fb662fc70fe75bd3b40d14d574`, while `origin/integration`
  remains `3fcf54a9d7d894f964adb8e414593807106d2a83`. r3 is limited to sticky
  durability-degraded readiness set/stay/clear behavior; agent-auth timing remains out of scope.
- 2026-07-31T18:13Z: automatic GitHub `ci / go` run `30653635439`, job `91232599904`,
  completed SUCCESS on exact r2 head `cacb1c318917b1fb662fc70fe75bd3b40d14d574` in 9m03s;
  gofmt, docker defaults, vet, tests, gosec, and govulncheck all passed. PR #27 remains
  OPEN/CLEAN/Draft. Sent r2 exact-head review request
  `20260731-1813Z-hephaestus-task0017-r2-review.md`; merge remains gated on Zeus `[ack]`.
- 2026-07-31T18:01Z: r2 commit `cacb1c318917b1fb662fc70fe75bd3b40d14d574`
  pushed to draft PR #27. It stages persistence before live publication, distinguishes
  pre-rename failures from committed parent-sync degradation, carries reality through bbolt
  migration, cascades snapshots on node delete, fences upsert by immutable node identity
  generation, returns 400 for an empty envelope node id, and canonicalizes empty/set-like
  collections. Exact-tree targeted tests, full `go test ./...`, `go vet ./...`, docker defaults,
  gofmt, diff-check, redaction, and `go test -race -cover ./...` passed (`internal/server`
  412.090s / 70.0%, `internal/store` 10.941s / 61.0%); an independent re-review acked the one
  additional commit-point blocker. GitHub has not yet instantiated fresh exact-head CI; no manual
  trigger was attempted.
- 2026-07-31T14:41Z: r1 implemented in `lattice-server` commit
  `c719ca36aa30ff0f6f3267d1bdb6bd4abd3666ef` and pushed as draft PR #27 targeting
  `integration`. Remote `ci / go` completed SUCCESS on exact head; local verification also
  passed: targeted contract tests, full `go test ./...`, `go vet ./...`, gofmt-clean, docker
  defaults contract, targeted race-cover, full race-cover, staged diff check, and redaction scan.
  Zeus exact-head ack requested; merge remains gated.
- 2026-07-31T13:53Z: claimed after contract row #8 became in force. Created isolated
  `lattice-server` worktree `.wt/hephaestus-lattice-server-task0017` on
  `feat/hephaestus-task0017-netguard-reality-api` from `origin/integration@3fcf54a`.
