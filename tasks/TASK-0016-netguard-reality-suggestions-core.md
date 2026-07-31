---
task: TASK-0016
title: NetGuard G3b - server reality suggestion core
owner: hephaestus
status: in_progress
plan_ref: lattice/docs/designs/design-13-wireguard-and-netguard-plugins.md §9 G3
repos: [lattice-server]
branches: [feat/hephaestus-task0016-netguard-suggestions-core]
last_touched_by: hephaestus
depends_on: [TASK-0015]
blocked_by_ruling: -
needs_ack: no
created: 2026-07-31
---

## Goal

Build the server-internal NetGuard G3 suggestion engine core as a pure, deterministic package-level
function. The observable result is test-pinned logic that compares low-trust
`model.GuardNodeReality` with current NetGuard intent and emits stable suggestions for operator
review, without adding the report endpoint, storage, dashboard, plugin interface, or apply wiring.

## Scope & boundaries

- In:
  - Internal `lattice-server/internal/netguard` suggestion types/functions.
  - Unit fixtures reproducing design-13 G3 cases: listener without allow, allow with no listener,
    overlay-only listener, overlay interface present but untrusted, managed-table drift, and clean
    no-suggestion intent.
  - Deterministic ordering and stable IDs/codes suitable for a later API/UI wrapper.
- Out:
  - `/api/agent/guard-reality`, any other API route, `contract/api-contract.md`, and server State
    persistence.
  - Agent poll-loop or `--report-guard-reality` wiring.
  - Dashboard drift badge/suggestion UI.
  - nft/WireGuard mutation, apply scripts, auth/RBAC/plugin gateway, CI/workflows, releases,
    signing, deploys, and production access.
- **Allowed paths**:
  - `lattice-server/internal/netguard/**`
- **Forbidden**:
  - Do not change SDK/proto/model contracts.
  - Do not add dependencies.
  - Do not run live host discovery commands.
  - Do not broaden into endpoint/storage work until the API contract is stewarded by zeus.

## Notes

- TASK-0015 landed the node-agent collector core on `lattice-node-agent
  origin/integration@3e505d66c3a6982e680107edc0f4d816f11adea3`.
- The endpoint/storage half of G3 is intentionally deferred: `prompts/start-task.md` says new
  interfaces must exist in `contract/api-contract.md` first, and Zeus is the contract steward.
  A separate letter requests that future API contract while this pure core proceeds.
- Reality remains low-trust display/diff input only. Suggestions are never applied silently.

## DoD

- [x] suggestion function consumes SDK `GuardNodeReality` plus existing NetGuard intent inputs
- [x] suggestions include stable code, severity, title, detail, and deterministic ordering
- [x] tests cover missing allow, stale allow, overlay-only listener, untrusted overlay interface,
      managed table drift, and a clean no-op case
- [x] no API, State collection, dashboard, agent, auth/RBAC, plugin gateway, workflow, or SDK diff
- [x] diff stays inside Allowed paths
- [x] `sh scripts/check-docker-defaults.sh`, `go vet ./...`, and `go test -race -cover ./...`
      pass in `lattice-server`
- [ ] PR opened against `integration`
- [ ] finish letter sent

## Log (append-only, newest first)

- 2026-07-31T13:21Z: replacement code head `e3238de` fixes Zeus's early-review finding before
  PR push: `Binding.Overrides` is indexed before groups, and permanent tests cover
  override-allowed listeners plus override stale allows. Added CIDR-backed overlay-zone
  classification while still staying inside `internal/netguard/**`. Fresh checks passed:
  `go test ./internal/netguard -run 'TestSuggest' -count=1`,
  `go test -race -cover ./internal/netguard` (81.7%), `sh scripts/check-docker-defaults.sh`,
  `go vet ./...`, full `go test -race -cover ./...`, redaction scan with inspected synthetic
  fixture ledger, and `git diff --check`.
- 2026-07-31T13:13Z: code commit `1a685dd` was local on
  `feat/hephaestus-task0016-netguard-suggestions-core`; diff is limited to
  `internal/netguard/suggest.go` and `internal/netguard/suggest_test.go`. Verified targeted
  red/green, `go test -race -cover ./internal/netguard`, `sh scripts/check-docker-defaults.sh`,
  `go vet ./...`, full `go test -race -cover ./...`, and Olympus redaction scan with the
  synthetic fixture ledger. Zeus API contract r1 reviewed and acked; endpoint/storage work remains
  out of this slice.
- 2026-07-31T12:52Z: started after TASK-0015 landed. Worktree:
  `.wt/hephaestus-lattice-server-task0016` from
  `lattice-server origin/integration@0fef1eb91129a9c0e735aefcccf8ac714d5b8eeb`. Current slice is
  internal suggestion logic only; future `/api/agent/guard-reality` endpoint/storage needs Zeus
  contract stewardship first.
