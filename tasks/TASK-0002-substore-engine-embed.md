---
task: TASK-0002
title: Embed the Sub-Store conversion engine in the plugin artifact (engine spike → implementation)
owner: hephaestus
status: in_progress
plan_ref: plan/design-substore-embed.md §4 (Option C) + §6 step 3
repos: [lattice-plugin-sub-store, lattice-server]
branches: [feat/hephaestus-task0002-substore-engine-spike, feat/hephaestus-task0002-f6-budgets, feat/hephaestus-task0002-substore-engine]
last_touched_by: hephaestus
depends_on: [TASK-0001 items 1–4 — Phase 2 only; Phase 1 depends on nothing]
blocked_by_ruling: — (§4 RULED Option C 2026-07-26, QuickJS-on-wazero per spike; source olympus-launch/operator-ruling-2026-07-26.md §2)
needs_ack: yes    # capabilities, manifest methods, and the §4 ruling all need zeus
created: 2026-07-25
---

## Goal

`latticenet.sub-store` stops being an adapter to an external Sub-Store service and carries the
conversion capability inside its own signed artifact — no separately installed Sub-Store, no
resident Node process, fork-per-call preserved.

**Gating, precisely** (the point is that you are never idle):

| | Phase 1 · engine spike | Phase 2 · implementation |
|---|---|---|
| Waits on | **nothing — start now** | zeus's §4 ruling letter **and** TASK-0001 items 1–4 ack'd |
| Why | its output is what informs the ruling | the ruling picks the engine; the merges make the manifest loadable at all |

Do not treat "TASK-0001" as a whole: only items 1–4 (server #7 → #8 → #10 → #11, sdk#6 →
server#12) are on your path. Item 5 (dashboard bridge) belongs to TASK-0003, not here. If the
ruling is late, keep going on Phase 1 depth or pick up TASK-0005 — rulings arrive in batches
(`pantheon/README.md §The gatekeeper's obligation`), so waiting is never the plan.

## Scope & boundaries

- **Phase 1 (spike, allowed now)**: evaluate a pure-Go JS interpreter (`goja`) against
  QuickJS-on-`wazero` by the single criterion *"Sub-Store's core evaluates unmodified"*. Report
  in a letter: ES level reached, which core modules load, shims required, memory/time per
  representative conversion, artifact size delta. No production code merges from the spike.
- **Phase 2 (after ruling)**: build `lib/substore-core.js` in plugin CI from a **pinned**
  upstream commit; embed the chosen engine in `system-go`; implement the conversion + record
  methods; all remote fetching stays on host capabilities (`http.do` / `http.operator.do`) —
  the engine must never get sockets or fs.
- **Phase 2 scope WIDENED by operator ruling 2026-07-26 (§7 q2)**: scripting, node filtering,
  and operator pipelines are IN — the operator wants as much of Sub-Store's surface as
  possible, overriding the narrow-v1 recommendation.
- Out: a resident/service runner tier (Option A stays deferred — design it separately if ever);
  reimplementing parsers in Go (Option B, rejected); any dashboard work (TASK-0003).
- **Allowed paths**: `lattice-plugin-sub-store/system-go/**` · `.../tools/**` ·
  `.../.github/workflows/**` (build-only; not a deploy change) · `.../manifest.json` **content**
  fields · `.../README.md`; F6 budget capability slice may also touch
  `lattice-server/internal/plugin/**` and directly necessary server plugin invocation plumbing.
- **Forbidden**: touching manifest **signature** fields (zeus-exclusive); weakening
  `verify:build`, the double-pack digest gate, or conformance tests to make something pass;
  adding any capability not in the server's risk table; anything under `ui/` (athena's).

## Notes

- Prerequisite merges (design §6 step 2): `secret:read|write`, `interfaces[].backing`, the
  operations/execute path, `substore:*` scopes. Until they land on the server, this plugin's
  published manifest **cannot load on a `main` server** (design §3 F1) — verify against the
  merged server, not a branch, before declaring done.
- **Budgets — F6 is now a BLOCKING prerequisite of Phase 2** (operator ruling 2026-07-26 §3):
  the spike put the 1 MiB output ceiling at ~4306 synthetic nodes, and the widened scope
  (pipelines/scripting) pushes past it. Per-method budgets are declared in the SIGNED manifest
  and clamped by host maxima. Operator's explicit prohibitions: no silent truncation; no
  widening the global constants (`system_runner.go:29-35`) as a shortcut. Letter zeus a
  concrete budget proposal early — manifest field shape is signed-surface, so zeus review
  gates it and a re-sign pass follows.
- Zeus F6 ack adjustments (20260726-1218Z): rollout is additive first. Absent method budget
  resolves to old global defaults with warn-once semantics; strict must-declare enforcement is
  deferred to TASK-0006/TASK-0010 after the re-sign wave. Signing parity must be pinned:
  no-budget manifests keep byte-identical signing payloads, declared budgets change the payload.
  Success with over-budget stderr must carry an explicit truncation marker and host log without
  turning the call into a failure. Deployment order: additive server -> budget-carrying
  re-signed manifests -> strict flip. Budgets reach production only through zeus/operator signing.
- Artifact changes ⇒ new digest ⇒ zeus re-signs; reproduce the old digest with the CI toolchain
  first to prove environment parity ([[gotcha-plugin-digest-reproduction]] — memory).
- Version bump moves manifest = ui = Go const together (`tools/bump.sh`).

## DoD

- [ ] merged into integration
- [ ] **per-method budgets (F6)**: declared in the signed manifest, clamped by host maxima —
      proven by a named test that (a) a conversion exceeding the old global 1 MiB cap succeeds
      under its declared method budget, and (b) output exceeding the DECLARED budget fails
      loudly (no silent truncation)
- [ ] F6 compatibility: absent `budget` preserves existing signed manifest payload bytes and
      resolves to old global defaults with warn-once behavior until the strict flip
- [ ] F6 stderr semantics: a successful call with over-budget stderr returns success plus an
      explicit truncation marker and emits a host log; it must not fail spuriously or go silent
- [ ] diff stays inside Allowed paths (mechanical check, finish-task §1)
- [ ] spike letter on record with the numbers named above, and zeus's §4 ruling letter linked
- [x] conversion runs entirely inside the artifact — proven by a test that runs a
      representative subscription conversion with **no** network capability granted
- [x] all remote fetches go through host capabilities — proven by a test asserting the engine
      context exposes no socket/fs binding
- [ ] `lib/substore-core.js` is built from a pinned upstream ref and covered by the bundle
      digest — proven by the existing double-pack byte-compare gate still passing
- [x] conformance_test green for every manifest-declared method (runtime-backed must answer)
- [x] `go test -race -cover ./...` green — real numbers
- [ ] plugin loads on a server built from merged `integration` (not a branch) — stated explicitly
- [x] README documents the upstream pin + bump procedure
- [ ] finish letter to zeus + athena (UI contract implications)

## Log (append-only, newest first)

- 2026-07-26T15:27Z: reconciled DoD evidence at PR #6 head `505e64c`.
  Marked four already-proven items complete: embedded representative conversion
  without host/network capability (`TestSubStoreEngineConvertCallDoesNotUseHost`
  and `TestEmbeddedSubStoreCoreConvertsRepresentativeSubscription`), no
  socket/fs-style host globals in the engine context
  (`TestSubStoreEngineConvertsWithQuickJSCoreFixture`), conformance for current
  manifest-declared methods (`system-go/conformance_test.go` in CI), and
  `system-go` race/coverage (latest local full run: 72.4%; latest GitHub run
  `30208029099` passed the runtime test stage). Left the pinned-core bundle
  digest item open until manifest digest/signature are refreshed, because the
  current CI still fails at the expected signed digest gate by design.
- 2026-07-26T15:24Z: pushed production Phase 2 branch commit `505e64c`
  to draft PR #6. Documented the embedded Sub-Store core pin in the root
  README: upstream commit/backend package, checked-in payload location, rebuild
  command, pin test, upstream bump procedure, signed-byte implication, and the
  no-Node-sidecar architecture boundary. Verification: `node --test
  tools/substore-core/build.test.mjs`; `git diff --check`. GitHub PR verify
  passed formatting, `system-go` race tests, deterministic packer tests, UI
  install/test/typecheck/build/scan, linux runtime binary builds, and failed
  only at the digest gate with unchanged actual digest
  `b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`
  versus manifest
  `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
  (run `30208029099`, job `89809385654`). Sent updated signing handoff
  `messages/inbox/zeus/20260726-1524Z-hephaestus-task0002-pr6-readme-pin-docs.md`.
- 2026-07-26T15:17Z: pushed production Phase 2 branch commit `bbe41f3`
  to draft PR #6. Added focused `run_pipeline` validation coverage proving
  blank raw subscriptions and raw subscriptions above `maxPipelineRawBytes`
  stop before any host KV call and do not echo the raw input in the returned
  error. Verification: `GOTOOLCHAIN=go1.26.4 go test -run
  'TestPipelineRecords|TestPipelineRecord' -count=1 -v`; `GOTOOLCHAIN=go1.26.4
  go test -race -cover -count=1 ./...` in `system-go` (72.4%);
  `GOTOOLCHAIN=go1.26.4 go vet ./...`. GitHub PR verify passed formatting,
  `system-go` race tests, deterministic packer tests, UI
  install/test/typecheck/build/scan, linux runtime binary builds, and failed
  only at the digest gate with unchanged actual digest
  `b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`
  versus manifest
  `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
  (run `30207773170`, job `89808728358`). Sent updated signing handoff
  `messages/inbox/zeus/20260726-1517Z-hephaestus-task0002-pr6-raw-budget-tests.md`.
- 2026-07-26T15:08Z: pushed production Phase 2 branch commit `3dfb245`
  to draft PR #6. Added internal `engine/run_pipeline`: it loads saved target
  and operators from the KV-backed pipeline record, accepts raw subscription
  text only for the current call, runs the embedded conversion, and returns the
  conversion result without storing the raw input. Verification: focused
  pipeline record tests including missing-record raw redaction;
  `GOTOOLCHAIN=go1.26.4 go test -race -cover -count=1 ./... && go vet ./...`
  in `system-go` (72.1%); `GOTOOLCHAIN=go1.26.4 go vet ./... && go test
  -race -cover -count=1 ./...` in `tools/pluginpack` (71.2%);
  `npm test && npm run typecheck && npm run build && npm run verify:build`;
  `node --test tools/substore-core/build.test.mjs`; gofmt-clean and
  `git diff --check`; local CI-style package twice yielded digest
  `b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`.
  GitHub PR verify passed all source/UI/build steps and failed only at the
  digest gate with the same actual digest versus manifest
  `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
  (run `30207447949`, job `89807873141`). Sent updated signing handoff
  `messages/inbox/zeus/20260726-1508Z-hephaestus-task0002-pr6-run-pipeline.md`.
- 2026-07-26T15:01Z: pushed production Phase 2 branch commit `2243e86`
  to draft PR #6. Added internal `engine` pipeline record methods
  (`save_pipeline`, `get_pipeline`, `list_pipelines`, `delete_pipeline`) backed
  by one scoped host KV document (`engine-pipelines-v1`) and intentionally kept
  raw subscription bodies out of the record schema. List responses return
  metadata and `operator_count`, not operator script bodies. These methods are
  still not manifest-declared because public surfacing waits on F6 budgets,
  `kv:*` capability signing, and zeus/operator digest refresh. Verification:
  local focused record tests; `GOTOOLCHAIN=go1.26.4 go test -race -cover
  -count=1 ./... && go vet ./...` in `system-go` (72.0%);
  `GOTOOLCHAIN=go1.26.4 go vet ./... && go test -race -cover -count=1 ./...`
  in `tools/pluginpack` (71.2%); `npm test && npm run typecheck && npm run
  build && npm run verify:build`; `node --test tools/substore-core/build.test.mjs`;
  gofmt-clean and `git diff --check`; local CI-style go1.26.4 package twice
  yielded digest
  `abd3d884c87fedc3106c37f3b82872ec9ff5c9119b0c243a378760a697ea90f7`.
  GitHub PR verify passed all source/UI/build steps and failed only at the
  digest gate with the same actual digest versus manifest
  `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
  (run `30207191425`, job `89807207769`). Sent updated signing handoff
  `messages/inbox/zeus/20260726-1501Z-hephaestus-task0002-pr6-pipeline-records.md`.
- 2026-07-26T14:51Z: pushed test-only PR #6 commit `b26fce4`.
  Added explicit embedded-core coverage for Sub-Store's shortcut `$server`
  Script Filter + Script Operator node pipeline, after verifying upstream
  semantics: shortcut Script Operator snippets mutate `$server` in place; a
  top-level `return` exits the generated operator early. Local verification:
  `GOTOOLCHAIN=go1.26.4 go test -run 'TestEmbeddedSubStoreCoreApplies(NodeShortcut|Script)Pipeline' -count=1 -v`;
  `GOTOOLCHAIN=go1.26.4 go test -race -cover -count=1 ./... && go vet ./...`
  in `system-go` (73.7%); gofmt-clean and `git diff --check`. GitHub PR verify
  passed formatting, `system-go` race tests, deterministic packer tests, UI
  install/test/typecheck/build/scan, and linux binary builds; it failed only at
  package digest compare with the same current digest
  `actual=78600d26069f8495d797c5b271e485d052de601f57eaaa7d2742b204ec08f220`
  vs manifest
  `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
  (run `30206868747`, job `89806366677`). Sent head-update handoff
  `messages/inbox/zeus/20260726-1451Z-hephaestus-task0002-pr6-node-filter-head.md`.
- 2026-07-26T14:42Z: pushed production Phase 2 branch commit `607e0ac`
  to draft PR #6. Added the embedded `ProxyUtils.processResponse` path as an
  internal `engine/transform_response` dispatcher method so Response Transformer
  scripts are covered alongside proxy Script Filter / Script Operator pipelines;
  the method is still not manifest-declared because public surfacing waits on
  F6 budgets and zeus/operator signing. Verification: GitHub PR verify passed
  formatting, `system-go` race tests, deterministic packer tests, UI install/test/
  typecheck/build/scan, and linux binary builds; it failed only at package digest
  compare. Authoritative digest line:
  `actual=78600d26069f8495d797c5b271e485d052de601f57eaaa7d2742b204ec08f220`
  vs manifest expected
  `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`
  (run `30206553554`, job `89805545652`). Local CI-toolchain reproduction with
  `go1.26.4` also packed the same digest twice; linux binaries were 10,561,703
  bytes (amd64) and 10,220,310 bytes (arm64). Sent updated signing handoff
  `messages/inbox/zeus/20260726-1442Z-hephaestus-task0002-pr6-response-transform.md`,
  superseding the earlier `c44335a...` digest in the 14:27Z letter.
- 2026-07-26T14:27Z: PR #6 CI `verify` failed only at the package
  digest comparison after head `f8cbb67`; GitHub run `30205966563`, job
  `89803954187`. The package step reported
  `bundle digest actual=c44335a081f61fb5c89c00779236b848d8501ae9991669ac319a5af7e23242e1`
  while `manifest.json` still expects
  `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`.
  This is the expected artifact-integrity failure after embedding qjs + the
  full Sub-Store core, not a source/test failure. Digest/signature refresh is
  zeus/operator-owned, so no manifest signing fields were changed locally.
  Sent `messages/inbox/zeus/20260726-1427Z-hephaestus-task0002-pr6-resign.md`.
- 2026-07-26T14:23Z: pushed production Phase 2 branch commit `f8cbb67`
  to draft PR #6. Switched the pin from the narrow `products/proxy-utils.esm.js`
  entry to upstream `src/core/proxy-utils/index.js`, because the widened
  operator scope needs `ProxyUtils.process` / `processResponse` as well as
  `parse` / `produce`. Regenerated `system-go/lib/substore-core.js` at
  1,266,359 bytes with sha256
  `994423340ddfbbcb4c858dc497bbbd249aac89b736a03606ada2f8958b1f0d4b`.
  `engine/convert` now accepts an optional operator pipeline and awaits upstream
  `process` before produce; test coverage includes a real `Script Filter` +
  `Script Operator` pipeline with no host calls. Verification:
  `go test -race -cover ./... && go vet ./...` in `system-go` (74.0%);
  `go vet ./... && go test -race -cover ./...` in `tools/pluginpack` (71.2%);
  `node --test tools/substore-core/build.test.mjs`; full-core builder-to-checked-in
  `cmp` reproduced hash `99442334...`; linux `amd64`/`arm64` cross-builds
  passed (10,545,756 and 10,215,715 bytes); `git diff --check`. PR #6 CI
  `verify` was in progress when checked at 2026-07-26T14:23Z.
- 2026-07-26T14:11Z: pushed production Phase 2 branch commit `59ab062`
  to draft PR #6. Embedded the pinned ProxyUtils bundle at
  `system-go/lib/substore-core.js` (1,266,414 bytes; sha256
  `9e77eb7b65dbe1e65a7c9eed7d618fbc786aab0b5d360945d65c2e8b84d8428c`) and
  wired an internal `latticenet.sub-store/engine` `convert` dispatcher path so
  the Linux runtime binary actually carries qjs + the core instead of linker
  dropping them. The manifest still does not declare the method: publication
  waits on F6 budgets + digest/signature refresh. Verification:
  `go test -race -cover ./... && go vet ./...` in `system-go` (74.6%);
  `go vet ./... && go test -race -cover ./...` in `tools/pluginpack` (71.2%);
  `node --test tools/substore-core/build.test.mjs`; builder-to-checked-in
  `cmp` reproduced the same core hash; linux `amd64`/`arm64` cross-builds
  passed (10,535,944 and 10,214,119 bytes); `git diff --check`. PR #6 CI
  `verify` was in progress when checked at 2026-07-26T14:11Z.
- 2026-07-26T14:03Z: pushed production Phase 2 branch commit `f8e1963`
  to draft PR #6. Added `system-go` QuickJS-on-wazero wrapper around the
  pinned Sub-Store ProxyUtils core contract, with per-conversion fresh runtime,
  no-op mutable `console` shim, stdout/stderr discarded, local memory/stack/GC
  guardrails, byte-accurate output length, and hash-only conversion/panic error
  reporting so raw subscription contents do not leak. Verification:
  `go test -race -cover ./...` in `system-go` (74.5%); `go vet ./...` in
  `system-go`; `LATTICE_SUBSTORE_CORE_JS=/tmp/hephaestus-substore-core-builder-check.js
  go test -run TestSubStoreEngineConvertsPinnedCoreWhenProvided -count=1 -v`;
  `go vet ./... && go test -race -cover ./...` in `tools/pluginpack` (71.2%);
  `node --test tools/substore-core/build.test.mjs`; `git diff --check`.
  PR #6 CI `verify` was in progress when checked at 2026-07-26T14:03Z.
  Not yet wired: checked-in core artifact path, manifest methods/budgets,
  digest/signature refresh.
- 2026-07-26T13:52Z: pushed production Phase 2 branch commit `c44a4c1` and
  opened draft `https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6`.
  Added `tools/substore-core/` with upstream pin metadata and a reproducible
  builder for `backend/src/products/proxy-utils.esm.js` from
  `sub-store-org/Sub-Store` commit `48d83214ffe3e1de86a03d80247f2d8202885948`
  (backend `2.36.22`). Verification: `node --test
  tools/substore-core/build.test.mjs`; `node tools/substore-core/build.mjs
  --source /tmp/hephaestus-substore-upstream.uv08XE/Sub-Store --skip-install
  --output /tmp/hephaestus-substore-core-builder-check.js` reproduced 1,266,414
  bytes and sha256 `9e77eb7b65dbe1e65a7c9eed7d618fbc786aab0b5d360945d65c2e8b84d8428c`;
  `go test -race ./...` in `system-go`; `go test -race ./...` in
  `tools/pluginpack`; `git diff --check`. Not yet wired: CI bundle assembly,
  checked-in core artifact path, digest/signature refresh.
- 2026-07-26T13:44Z: started Phase 2 production plugin branch
  `feat/hephaestus-task0002-substore-engine` in private worktree
  `.wt/hephaestus-lattice-plugin-sub-store-task0002-phase2` from
  `lattice-plugin-sub-store` `origin/integration` (`8dddd63`). The Phase 1 spike
  branch remains evidence only; production work starts from pressed integration.
  F6 server PR #22 remains the merge blocker for manifest budgets, and any plugin
  digest/signature or workflow wiring remains zeus/operator-only.
- 2026-07-26T12:54Z: pushed F6 server capability branch and opened
  `https://github.com/LatticeNet/lattice-server/pull/22`. Commits: `5daf862`
  signed per-method budget schema + runner enforcement; `5f1ab58` additive signed
  `min_server` for TASK-0010 Decision A. Verification: `go test ./... && go vet ./...`;
  `go test -race -cover ./internal/plugin ./internal/server` (plugin 77.7%, server 69.8%).
  Awaiting zeus schema/security ack before merge and before plugin manifest budget content.
- 2026-07-26T12:25Z: zeus acked F6 budget proposal with required adjustments in
  `messages/inbox/hephaestus/20260726-1218Z-zeus-re-f6-budget-proposal.md`; created server
  worktree `.wt/hephaestus-lattice-server-f6` on `feat/hephaestus-task0002-f6-budgets` from
  `lattice-server` `origin/integration` (`86422a1`) for the additive budget capability slice.
- 2026-07-26T12:04Z: zeus applied the operator ruling batch (per its explicit instruction —
  source olympus-launch/operator-ruling-2026-07-26.md): §4 = Option C ⇒ unblocked,
  in_progress; scope widened (scripting/filtering/pipelines IN); F6 budgets now BLOCKING with
  a bound DoD test; relay letter 20260726-1202Z in hephaestus's inbox.
- 2026-07-26T08:14Z: parked after Phase 1 + cap sweep; no §4 engine ruling in inbox, so
  switched to TASK-0008 per no-idle rule. Draft PR #5 stays open for the spike branch.
- 2026-07-26T08:11Z: deepened Phase 1 on branch with commit `b82e4ef` (spike harness
  output-budget sweep flags + parser tests). `go test -race -cover ./...` in
  `tools/substore-engine-spike` passed; qjs synthetic sing-box boundary: 4306 nodes =
  1,048,553 bytes (23 bytes under cap), 4307 nodes = 1,048,762 bytes (186 bytes over cap).
- 2026-07-26T08:03Z: opened draft PR
  `https://github.com/LatticeNet/lattice-plugin-sub-store/pull/5` targeting `integration` for
  the Phase 1 spike branch; Phase 2 still waits on zeus's §4 engine ruling.
- 2026-07-26T07:57Z: Phase 1 spike reported in
  `messages/inbox/zeus/20260726-0757Z-hephaestus-task0002-engine-spike.md`; branch pushed with
  commits `d85bb8e` (spike harness), `cac2b45` (merge `origin/main` per zeus 07:36Z baseline
  letter), and `03295c7` (conformance probe fix after design-15 no-arg methods). TASK-0001
  items 1–4 are done; Phase 2 waits only on the §4 engine ruling.
- 2026-07-26T07:32Z: claimed Phase 1 spike; branch registered as
  `feat/hephaestus-task0002-substore-engine-spike`; Phase 2 remains gated on zeus's §4 ruling
  and TASK-0001 items 1–4.
- 2026-07-25: created at instantiation; Phase 1 spike is `ready`, Phase 2 gated on the §4 ruling.
