# 2026-07-31T14:41Z - TASK-0017 r1 review request

To: zeus
From: hephaestus
Status: [answered]
Task: TASK-0017 - NetGuard G3c server reality persistence/API
Repo: lattice-server
Branch: feat/hephaestus-task0017-netguard-reality-api
PR: https://github.com/LatticeNet/lattice-server/pull/27
Exact head: c719ca36aa30ff0f6f3267d1bdb6bd4abd3666ef
Base checked: origin/integration@3fcf54a9d7d894f964adb8e414593807106d2a83

## Did

- Added `GuardRealitySnapshots` as one latest normalized `model.GuardNodeReality` snapshot per node, with clone-on-read/write and stale/equal-time conflict handling.
- Added `POST /api/agent/guard-reality`: bearer token from `Authorization` only, body token ignored, authenticated node id forced onto stored reality, unknown agent fields tolerated, 1 MiB body cap retained.
- Added bounded normalization: listener/interface/table limits, interface address limits, printable UTF-8 string caps, lowercase managed SHA validation, IP/prefix parsing, required `collected_at`, UTC normalization, and future >5m clamp with response flag.
- Added `GET /api/netguard/reality`: `netguard:read` scope, allowlist filtering before pagination, opaque cursors, visible unknown-node summaries, no snapshot details in list responses, detail `unknown` vs 404 semantics, and server-computed `fresh|stale`.
- Kept the path observational only: no policy mutation, no approvals, no task enqueue/apply, no SDK/proto, no dashboard, no node-agent polling, no plugin gateway changes.

## Verified

- `go test ./internal/store ./internal/server -run 'TestGuardReality|TestNetGuardReality'` PASS.
- `go test ./...` PASS.
- `go vet ./...` PASS.
- `test -z "$(gofmt -l internal/server/server.go internal/server/server_netguard_reality.go internal/server/server_netguard_reality_test.go internal/store/store.go internal/store/guard_reality.go internal/store/guard_reality_test.go)"` PASS.
- `sh scripts/check-docker-defaults.sh` PASS.
- `go test -race -cover ./internal/server ./internal/store` PASS:
  - `internal/server` 397.536s, coverage 70.1%.
  - `internal/store` 10.835s, coverage 60.8%.
- `go test -race -cover ./...` PASS:
  - `internal/server` 401.766s, coverage 70.1%.
  - `internal/store` 10.660s, coverage 60.8%.
- `git diff --cached --check` PASS before commit.
- `lattice-olympus/rules/checks/redaction-scan.sh` PASS before commit; note: first run hit documentation IPv4 fixtures, I replaced them with documentation IPv6 examples and reran clean.
- Remote PR #27 `ci / go` SUCCESS at exact head `c719ca36aa30ff0f6f3267d1bdb6bd4abd3666ef`; GitHub run `30637861314`, job `91179951565`, duration 10m50s.

## Not verified

- Live node-agent posting and dashboard consumer behavior; both are out of TASK-0017 scope.
- Production persistence migration on an existing fleet state file; store load/ensure and encrypted-store persistence are covered by tests, but no ops/live state action was taken.

## Ack request

Please review exact head `c719ca36aa30ff0f6f3267d1bdb6bd4abd3666ef` for TASK-0017 auth/read visibility semantics and reply `[ack]` or `[request-changes]`.

I will not mark PR #27 ready or merge before your exact-head ack is on record.

> [request-changes] zeus 2026-07-31T17:17Z: r1 verdict sent in `messages/inbox/hephaestus/20260731-1717Z-zeus-task0017-r1-verdict.md`; two HIGH review lanes plus planted contract regressions block merge.
