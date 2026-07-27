---
task: TASK-0006
title: CI gate — no manifest is signed or published unless the released server accepts it
owner: hephaestus
status: merged
plan_ref: plan/design-substore-embed.md §3 F1
repos: [lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard, lattice-plugin-index, lattice-server]
branches: [feat/hephaestus-task0006-manifest-validator, integration@lattice-server:c9c67107, integration@lattice-plugin-template:85f4e24f, integration@lattice-plugin-vpn-core:3b8949f3, integration@lattice-plugin-wireguard:857b7d58, integration@lattice-plugin-netguard:e1547813, integration@lattice-plugin-sub-store:b5f6fc8]
last_touched_by: hephaestus
depends_on: [TASK-0001]
blocked_by_ruling: —
needs_ack: no
created: 2026-07-25
---

## Goal

Close the published-vs-acceptable gap: a plugin CI job validates the manifest against the
**released** server's validator, so we can never again publish a signed bundle that the running
server rejects.

## Scope & boundaries

- In: expose the server's manifest validator as a runnable check (small command or exported
  package); each plugin CI runs it against a pinned released server version; failure blocks the
  release job. Also: refresh the stale reference implementation (F4) so new plugins start from
  the current shape.
- Out: changing validation rules themselves.
- **Allowed paths**: `lattice-server/cmd/**` + `internal/plugin/**` (validator export only),
  each plugin's `.github/workflows/**` and `tools/**`, template `system-go/**` + `manifest.json`.
- **Forbidden**: making the gate skippable by default; pinning the check to a branch instead of
  a release.

## Notes

- Motivating incident: sub-store's signed manifest declares `secret:read|write`, which server
  `main` rejects outright — the published bundle cannot load
  ([[gotcha-published-vs-acceptable-manifest]] in memory).
- The gate must name the server version it validated against in its output, so a green CI run
  is evidence about a specific server, not a vague claim.

## DoD

- [x] merged into integration
- [x] every plugin repo's CI fails when a manifest declares something the pinned released
      server rejects — proven by a deliberately-bad fixture in the test
- [x] the gate prints the server version it validated against
- [x] template refreshed to the current plugin shape (host calls, backing, operator targets)
- [x] finish letter sent

## Log

- 2026-07-27T10:27Z: CLOSED as merged. Zeus completed the ops-owned half under
  the operator grant: released-server manifest gate live in all five plugin
  repos, pinned to server `alpha-0.2.2a4` / `c9c67107`, and `integration`
  included in each trigger list. First full GitHub CI runs on the signed
  integration tips succeeded five-for-five, covering source pipeline,
  released-server validator output, and digest gate. Failing-on-reject evidence
  comes from the command's deliberately bad fixtures plus the pre-wave smoke
  that rejected stale manifests; the live gate now prints the pinned server
  version in each run. Template refresh is signed at `0.2.1-alpha.5`. Final
  plugin heads after the tools-only bump fix: template `85f4e24f`, vpn-core
  `3b8949f3`, wireguard `857b7d58`, netguard `e1547813`, sub-store
  `b5f6fc8`. Finish letter sent.

- 2026-07-27T04:54Z: carried the missing #2 backing PR conformance tests onto
  plugin `integration` after Zeus's 04:48Z verification note said to confirm
  them before stale PR closure. The first check showed `system-go/conformance_test.go`
  was absent from template, vpn-core, wireguard, and netguard integration heads,
  so new test-only hephaestus branches added an SDK-era
  `TestManifestInterfacesAreServedAsDeclared` to each repo and merged them:
  template `eff0bc462ea4fe06fba4c5d16aff821b7e5b37b8`, vpn-core
  `5a65752fdcafdc09e38268e6223b5c82982251c0`, wireguard
  `8ee86b2b4fbf1eac4e2553191dbbb0bb587ec075`, netguard
  `71a3be86b2b6b10c01a84b2d14e9517074f4bad2`. Verification per repo:
  focused conformance test, `go vet ./...`, `go test -race -cover -count=1
  ./...`, gofmt-clean, diff-check, and diff limited to
  `system-go/conformance_test.go`. Closed stale draft PR #2 in those four repos
  with supersession comments. Test-only changes do not alter bundle bytes, so
  prior signing digests remain the artifact digests; signing should use the new
  integration heads.
- 2026-07-27T04:34Z: template refresh content is now merged to
  `lattice-plugin-template` `integration` in combined head
  `92f470f9558649478b871c1a4dcfd02c6fbe7a74` after Zeus's 04:12Z ack for
  template #4 and #5. Post-merge template verification passed gofmt/diff,
  `system-go` vet + race/coverage (73.0%), `tools/pluginpack` vet +
  race/coverage (71.2%), UI test/typecheck/build/verify, merged-server
  `lattice-plugin-manifest-check manifest.json`, and deterministic
  double-pack/byte-compare. Actual bundle digest at merged tip is
  `3df5722b5babcba06d63cbc00f5275ce459d88c3217bd31d0e2821b1a3557e70`;
  hephaestus did not edit digest/signature fields. Remaining TASK-0006 work is
  Zeus-owned per 2026-07-27T04:12Z: released-server CI wiring/tag/signing are
  outside this seat under rules/03.
- 2026-07-26T17:18Z: server validator command slice merged to `lattice-server`
  `integration` via PR #23 at merge commit `755aaff6b4ece1dba9a766528679836dcc097b70`
  (feature head `22c5c2863ac76fbf3e21895b0f2d2e7eb9138654`). GitHub CI run
  `30211675036` passed gofmt, docker defaults contract, vet, test, gosec, and
  govulncheck. Merge-commit verification: `test -z "$(gofmt -l .)"`,
  `GOTOOLCHAIN=go1.26.4 go vet ./...`, and fresh
  `GOTOOLCHAIN=go1.26.4 go test -count=1 -race -cover ./...` passed
  (`cmd/lattice-plugin-manifest-check` 75.9%, `internal/plugin` 78.1%,
  `internal/server` 69.8%, `internal/store` 60.4%). This unblocks zeus's
  workflow-wiring lane; hephaestus still cannot edit `.github/workflows/**`
  under rules/03, and template PR #4 remains parked for release-builder digest
  refresh + re-sign.
- 2026-07-26T13:42Z: checked draft template PR #4 CI failure. It is the expected
  package digest gate: CI reported `bundle digest actual=2b4184c3... expected=a7631567...`.
  This confirms the source/test path is green and the remaining blocker is the
  intentional release-builder digest + manifest re-sign handoff, not an accidental
  source regression.
- 2026-07-26T13:40Z: template source refresh parked in draft
  `https://github.com/LatticeNet/lattice-plugin-template/pull/4` at commit
  `fb8e61a`. Updated `system-go` to the current `action=call` payload envelope,
  added fd-3 host-call handling with a small `http.operator.do` operator-target
  probe, declared `backing: runtime`, and added method-bound
  `operator_target_fields: ["base_url"]`. Verification: baseline `go test ./...`
  passed before edits; after edits `go test ./...`, `go test -race ./...`,
  `go vet ./... && go test -race -cover ./...` in `system-go` (58.1%), `go vet
  ./... && go test -race -cover ./...` in `tools/pluginpack` (pluginpack 71.2%;
  cmd no statements), `git diff --check`, `lattice-plugin-manifest-check
  manifest.json`, and a process smoke for the current `action=call` envelope all
  passed. Not verified: full plugin package digest/signature gate; runtime bytes
  and signed manifest payload changed, so PR #4 remains draft pending
  zeus/operator release-builder digest refresh and re-sign.
- 2026-07-26T13:32Z: continuing the allowed template refresh slice in private worktree
  `.wt/hephaestus-lattice-plugin-template-task0006` on branch
  `feat/hephaestus-task0006-manifest-validator` from `lattice-plugin-template`
  `origin/integration` (`793b476`). Scope is `system-go/**` + `manifest.json`
  content fields only: refresh runtime call framing and declare current manifest
  backing without touching `.github/workflows/**` or signature fields. Artifact-bound
  changes will require zeus/operator digest + re-sign before merge/release; dependency
  letter sent in `messages/inbox/zeus/20260726-1332Z-hephaestus-task0006-template-resign.md`.
- 2026-07-26T13:25Z: code-side validator slice pushed in `lattice-server` commit
  `86c94a1` and PR `https://github.com/LatticeNet/lattice-server/pull/23` targets
  `integration`. Added `cmd/lattice-plugin-manifest-check`, a thin wrapper around
  `internal/plugin.DecodeManifest` + `ValidateManifest`, with build evidence output and
  good/bad fixtures. Verification: `go test ./cmd/lattice-plugin-manifest-check
  ./internal/plugin`, `go vet ./cmd/lattice-plugin-manifest-check ./internal/plugin`,
  `go test ./... && go vet ./...`, `go test -race -cover
  ./cmd/lattice-plugin-manifest-check ./internal/plugin` (command 75.9%, internal/plugin
  77.1%). Smoke: sub-store/vpn-core manifests accepted; five-plugin smoke returned nonzero and
  rejected template/wireguard/netguard for missing `backing`. Ack letter:
  `messages/inbox/zeus/20260726-1325Z-hephaestus-task0006-validator-pr.md`.
- 2026-07-26T13:18Z: claimed a code-side slice only after reading rules/03 at the action
  boundary. This seat may write the validator command/library under `lattice-server`, but
  rules/03 forbids non-ops agents from editing `.github/workflows/**`; workflow wiring is
  escalated to zeus in
  `messages/inbox/zeus/20260726-1318Z-hephaestus-task0006-ci-boundary.md`.
- 2026-07-26T12:05Z: promoted draft → ready by zeus per operator ruling (ordered-list §3);
  dependency TASK-0001 is done and all ten repos now have `integration` baselines.
- 2026-07-25: created as `draft` at instantiation (F1 + F4 in the framework review).
