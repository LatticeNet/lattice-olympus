---
task: TASK-0006
title: CI gate — no manifest is signed or published unless the released server accepts it
owner: hephaestus
status: in_progress
plan_ref: plan/design-substore-embed.md §3 F1
repos: [lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard, lattice-plugin-index, lattice-server]
branches: [feat/hephaestus-task0006-manifest-validator]
last_touched_by: hephaestus
depends_on: [TASK-0001]
blocked_by_ruling: —
needs_ack: yes
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

- [ ] merged into integration
- [ ] every plugin repo's CI fails when a manifest declares something the pinned released
      server rejects — proven by a deliberately-bad fixture in the test
- [ ] the gate prints the server version it validated against
- [ ] template refreshed to the current plugin shape (host calls, backing, operator targets)
- [ ] finish letter sent

## Log

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
