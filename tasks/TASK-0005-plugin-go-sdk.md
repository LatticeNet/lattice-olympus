---
task: TASK-0005
title: Extract a plugin Go SDK (stdio runtime loop + typed host client + manifest types)
owner: hephaestus
status: merged
plan_ref: plan/design-substore-embed.md §3 F5
repos: [lattice-sdk, lattice-plugin-template, lattice-plugin-sub-store, lattice-plugin-vpn-core, lattice-plugin-wireguard, lattice-plugin-netguard]
branches: [feat/hephaestus-task0005-plugin-go-sdk, integration@lattice-sdk:00943f6e, integration@lattice-plugin-template:85f4e24f, integration@lattice-plugin-vpn-core:3b8949f3, integration@lattice-plugin-wireguard:857b7d58, integration@lattice-plugin-netguard:e1547813, integration@lattice-plugin-sub-store:b5f6fc8]
last_touched_by: hephaestus
depends_on: []
blocked_by_ruling: —
needs_ack: no     # zeus acked SDK + all plugin migrations 2026-07-27T04:12Z
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

- [x] merged into integration
- [x] all five plugins build on the SDK with their conformance tests still green
- [x] SDK has its own tests for framing + fd-3 host-call round-trip
- [x] `go test -race -cover ./...` green in SDK and every migrated plugin (real numbers)
- [x] artifact digests recomputed and manifests re-signed by zeus where artifacts changed
- [x] finish letter sent

## Log

- 2026-07-27T10:27Z: CLOSED as merged after Zeus/operator signing and CI
  wiring. Signed plugin versions now on integration: template `0.2.1-alpha.5`
  digest `c4bfe8be4065e9fd64780259e88d641518fbe2555aeecf6221ecb39ef5d9e770`
  at `85f4e24f`; vpn-core `0.8.0-alpha.6` digest
  `d2e681a6a808d8a1f19b941a5067969edb7c601d2e8780256aca7343aad88d86`
  at `3b8949f3`; wireguard `0.1.0-alpha.8` digest
  `34eb6c0765e018ae3ff21331bebfc65957a1f9ec5a4821fd0a718260c9e415d1`
  at `857b7d58`; netguard `0.1.0-alpha.8` digest
  `c00334a8715bfeb7aa55a21a91f2a5a1de1321955a000b22a09675857dc9f36d`
  at `e1547813`; sub-store `0.4.0-alpha.1` digest
  `e0524e358d2a4c65c11e78405e90956e12712ba7e3fd91a181d88eb918403300`
  at `b5f6fc8`. The vpn-core and sub-store final heads include a tools-only
  `bump.sh` alignment fix (PRs #6 and #8) so future bumps update aligned
  `pluginVersion` constants; no manifest digest/signature fields changed in
  that follow-up. Verification: Zeus signing-wave letter records parity pack,
  bump, double-pack, pluginsign self-verify, merged-server validator, race
  suites, and no-ff merges; Zeus TASK-0006 letter records first CI success x5
  on the signed integration tips. Local post-fix verification passed for
  vpn-core (`system-go` 75.0%, pluginpack 71.2%, UI 13/13) and sub-store
  (`system-go` 80.3%, pluginpack 71.2%, UI 12/12). GitHub integration CI also
  passed after the bump fix: vpn-core run `30258007891` at `3b8949f3`, sub-store
  run `30258009066` at `b5f6fc8`. Finish letter sent.

- 2026-07-27T04:34Z: moved TASK-0005 to signing-wait. Slice 1 SDK is already
  merged to `lattice-sdk` `integration` at `00943f6`; slice 2 plugin runtime
  migrations are now merged to plugin `integration` heads after Zeus's 04:12Z
  `[ack]`: template `92f470f` (combined TASK-0006 template refresh + SDK),
  vpn-core `7a992ff`, wireguard `695170a`, netguard `d82f598`, and sub-store
  `ed92baa` (folded into TASK-0002 PR #6 before merge). Post-merge local gates
  passed for every plugin: gofmt/diff, `system-go` vet + race/coverage,
  `tools/pluginpack` vet + race/coverage, UI test/typecheck/build/verify,
  merged-server manifest validator, and deterministic double-pack/byte-compare.
  Merged-tip actual bundle digests for the signing queue: template
  `3df5722b5babcba06d63cbc00f5275ce459d88c3217bd31d0e2821b1a3557e70`,
  vpn-core `764b385eabf02dd5123f99a361d398e5217bf5a38b963037db25151108cfe215`,
  wireguard `d98dcc21fbe71d95de05611784e66a41c3f2f3b624a62b43c78436bd210b0320`,
  netguard `c0b42c11effec42fd229f874558687306e3bda66cccc5035a9ccd043240c323e`,
  sub-store `55749d194c54a5d4e8b9b183acf3e8e70e7dbcd6c759e0c6e392c2e38a8f8def`.
  Hephaestus did not edit digest or signature fields; remaining TASK-0005 DoD
  item is zeus/operator re-sign of changed artifacts.
- 2026-07-26T18:06Z: completed the fifth plugin as a dependent sub-store SDK branch without
  touching TASK-0002 PR #6. Created `.wt/hephaestus-lattice-plugin-sub-store-task0005-sdk`
  from `origin/feat/hephaestus-task0002-substore-engine` at `f9ccb92`, committed
  `e78b6c0`, and pushed `origin/feat/hephaestus-task0005-plugin-go-sdk`. No PR opened yet:
  targeting `integration` would include all PR #6 changes while PR #6 is still unsigned, and
  pushing onto PR #6 directly would invalidate the signing queue without zeus ack. Migration
  deleted the local stdio/fd-3 framing types and routes Sub-Store through
  `lattice-sdk/plugin` `Serve`, `CallPayload`, action constants, host method constants, and
  response helpers while preserving the existing domain logic and fake-host tests. Verification:
  `test -z "$(gofmt -l system-go tools/pluginpack)"`, `git diff --check`,
  `GOTOOLCHAIN=go1.26.4 go vet ./...` and `GOTOOLCHAIN=go1.26.4 go test -race -cover
  -count=1 ./...` in `system-go` (80.2%) and `tools/pluginpack` (71.2%),
  `node --test tools/substore-core/build.test.mjs`, `npm ci`, `npm test`, `npm run
  typecheck`, `npm run build`, `npm run verify:build`, `CGO_ENABLED=0` linux amd64/arm64
  runtime builds, and pluginpack double digest/byte compare. Dependent-branch actual digest is
  `55749d194c54a5d4e8b9b183acf3e8e70e7dbcd6c759e0c6e392c2e38a8f8def`; manifest still
  expects `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`.
- 2026-07-26T17:56Z: slice 2 partial checkpoint: migrated four independent plugin backends
  onto the merged SDK runtime and opened draft PRs against `integration`:
  `lattice-plugin-template#5` at `60e36ce`, `lattice-plugin-vpn-core#4` at
  `5c50c04`, `lattice-plugin-wireguard#3` at `4bf197e`, and
  `lattice-plugin-netguard#3` at `dac94fa`. Local verification passed for
  each repo: `test -z "$(gofmt -l system-go tools/pluginpack)"`, `git diff
  --check`, `GOTOOLCHAIN=go1.26.4 go vet ./...` in `system-go` and
  `tools/pluginpack`, `GOTOOLCHAIN=go1.26.4 go test -race -cover -count=1
  ./...` in both Go modules, `npm ci`, `npm test`, `npm run typecheck`, `npm
  run build`, `npm run verify:build`, `CGO_ENABLED=0` linux amd64/arm64 runtime
  builds, and pluginpack double digest/byte compare. GitHub CI reached package
  digest compare and failed only on the expected signed manifest digest mismatch:
  template actual `fd83843a6f4a08744860a942f332349764345794bb02f8824048ddfa78be9bbe`
  vs manifest `a7631567e67d0b0d2f8c971af3b3b5414cf8f2a00c88c396774c4190adb689d1`;
  vpn-core actual `764b385eabf02dd5123f99a361d398e5217bf5a38b963037db25151108cfe215`
  vs manifest `662354b0c15d461514f6c49262cd4e6b4e541cba77ce89092a9fcdc93fe74a32`;
  wireguard actual `d98dcc21fbe71d95de05611784e66a41c3f2f3b624a62b43c78436bd210b0320`
  vs manifest `0c947045617d4c2c0558ba1ac0dcfb8b6474e0d090abcd3b6be3ed768ec68baf`;
  netguard actual `c0b42c11effec42fd229f874558687306e3bda66cccc5035a9ccd043240c323e`
  vs manifest `873c4461c68f2673c3792735ab8e67a675bc012bf5b6af55d88012b4c69bfcc4`.
  `lattice-plugin-sub-store` remains deferred behind TASK-0002 PR #6 so this
  slice does not collide with its already-open signing queue.
- 2026-07-26T17:38Z: started slice 2 plugin migrations after SDK slice 1
  merged. Created private worktrees from fresh `origin/integration` on
  `feat/hephaestus-task0005-plugin-go-sdk` for
  `.wt/hephaestus-lattice-plugin-template-task0005`,
  `.wt/hephaestus-lattice-plugin-vpn-core-task0005`,
  `.wt/hephaestus-lattice-plugin-wireguard-task0005`, and
  `.wt/hephaestus-lattice-plugin-netguard-task0005`. `lattice-plugin-sub-store`
  migration is intentionally deferred or dependency-recorded separately because
  PR #6 is an unmerged, signing-blocked system-go branch; migrating it from
  plain `integration` would create a known collision with TASK-0002.
- 2026-07-26T17:22Z: slice 1 SDK module merged to `lattice-sdk` `integration`
  via PR #8 at merge commit `00943f6ec9e78f27f0dc18f1bc43c11decba4f8f`
  (feature head `462c535b4ab8ddfadc2ea18d040ebcdd7387132e`). GitHub CI run
  `30203688209` passed. Merge-commit verification: `test -z "$(gofmt -l .)"`,
  `go vet ./...`, and fresh `go test -count=1 -race -cover ./...` passed
  (`plugin` 62.3%; `model` no statements). Per the operator slicing, slice 2
  is now open: migrate plugin `system-go/**` packages onto the SDK with per-plugin
  conformance still green, then hand changed artifacts to zeus for digest/signing.
- 2026-07-26T13:15Z: slice 1 SDK module pushed in `lattice-sdk` commit `462c535` and PR
  `https://github.com/LatticeNet/lattice-sdk/pull/8` targets `integration`. Added importable
  `plugin` package for stdio-json-v1 framing, fd-3 host client (`rpc.call`, `http.do`,
  `http.operator.do`, `kv.*`, `notify.send`, `log.write`, `secret.*`), manifest/capability
  structs, and F6/TASK-0010 additive signed fields (`budget`, `min_server`). Verification:
  `go test ./...`, `go vet ./...`, `go test -race -cover ./...` (plugin 62.3%; model no
  statements). Zeus ack requested in
  `messages/inbox/zeus/20260726-1315Z-hephaestus-task0005-sdk-pr.md`.
- 2026-07-26T13:01Z: resumed slice 1 as the no-idle fallback while F6 server PR #22 remains
  open with CI in progress and no zeus schema/security ack yet. SDK worktree is still clean on
  `feat/hephaestus-task0005-plugin-go-sdk`, behind `origin/integration` by the post-press SDK
  merge; next step is `git merge origin/integration` before edits.
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
