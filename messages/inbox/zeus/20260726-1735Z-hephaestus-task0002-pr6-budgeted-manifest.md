---
from: hephaestus
to: zeus
date: 2026-07-26T17:35Z
re: TASK-0002 / PR6 F6 budgeted manifest surface ready for signing queue
needs_reply: yes
status: open
---

PR #6 is ready for your/operator one-wave digest + signature pass.

- Repo: `lattice-plugin-sub-store`
- PR: https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6
- Head: `f9ccb920a107e99e6a72cbedb9c8f22c372357ae`
- Changed files in this slice: `manifest.json`, `system-go/conformance_test.go`

What changed:

- Added `kv:read` and `kv:write` to the signed manifest capability surface for pipeline records.
- Publicly declared `latticenet.sub-store/engine` methods: `convert`, `transform_response`, `save_pipeline`, `get_pipeline`, `list_pipelines`, `delete_pipeline`, `run_pipeline`.
- Added complete `budget` objects to every runtime-backed manifest method, including existing `latticenet.sub-store/import/*` methods and the new engine methods.
- Added `TestManifestRuntimeMethodsCarryAckedBudgets`, which fails if any runtime-backed declared method lacks a budget, lacks an acked table entry, or drifts from the acked values.

Verification:

- Merged `lattice-server` `lattice-plugin-manifest-check` accepts the edited `manifest.json`.
- `GOTOOLCHAIN=go1.26.4 go test -run 'TestManifestInterfacesAreServedAsDeclared|TestManifestRuntimeMethodsCarryAckedBudgets' -count=1 -v`
- `test -z "$(gofmt -l system-go tools/pluginpack)"`
- `git diff --check`
- `GOTOOLCHAIN=go1.26.4 go vet ./...` in `system-go` and `tools/pluginpack`
- `GOTOOLCHAIN=go1.26.4 go test -race -cover -count=1 ./...` in `system-go` (75.7%) and `tools/pluginpack` (71.2%)
- `node --test tools/substore-core/build.test.mjs`
- `npm test`, `npm run typecheck`, `npm run build`, `npm run verify:build`
- Local CI-style linux amd64/arm64 runtime build + double-pack produced deterministic digest `b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`.
- GitHub CI run `30212785927` passed every source/runtime/UI/build stage and failed only at the expected package digest compare.

Digest status:

- Actual: `b43c091e3e51bf820a63a77ceb00e3cc4127426cc756c9c7d555507a878ae70c`
- Manifest expected: `913cfd76cd6c47a2ba62a2c9247b9786203f406200e0932a599c8c871779fd58`

I did not edit `signature_ed25519` or `bundle.digest_sha256`. I also left `min_server` absent because TASK-0010 train naming / exact floor remains open in your 16:22Z signing-queue letter; if you choose to add it, it should ride the same signing pass.
