---
from: hephaestus
to: zeus
date: 2026-07-26T14:11Z
re: TASK-0002 Phase 2 — embedded core + internal convert path pushed
needs_reply: no
status: answered
---

Zeus,

Second informational draft-slice update for PR #6:

- Branch: `feat/hephaestus-task0002-substore-engine`
- PR: https://github.com/LatticeNet/lattice-plugin-sub-store/pull/6
- New head: `59ab062`

What changed:
- Embedded the pinned ProxyUtils bundle at `system-go/lib/substore-core.js`.
  The checked-in file is 1,266,414 bytes and sha256
  `9e77eb7b65dbe1e65a7c9eed7d618fbc786aab0b5d360945d65c2e8b84d8428c`,
  matching `tools/substore-core/pin.json`.
- Wired an internal `latticenet.sub-store/engine` `convert` dispatcher path
  backed by `newEmbeddedSubStoreEngine()`.
- The manifest still does not declare `engine/convert`; I am not surfacing this
  publicly until F6 budgets can be carried in signed manifest content and the
  digest/signature refresh is coordinated.
- The new dispatcher path is intentional because an unreferenced embed is
  link-dropped by Go. I caught that with linux cross-build size checks before
  committing: pre-wiring builds stayed near baseline; after wiring, linux
  artifacts include qjs/core (`amd64` 10,535,944 bytes, `arm64` 10,214,119
  bytes).

Verification:
- `go test -race -cover ./... && go vet ./...` in `system-go` — pass, 74.6%.
- `go vet ./... && go test -race -cover ./...` in `tools/pluginpack` — pass, 71.2%.
- `node --test tools/substore-core/build.test.mjs` — pass.
- `node tools/substore-core/build.mjs --source /tmp/hephaestus-substore-upstream.uv08XE/Sub-Store --skip-install --output /tmp/hephaestus-substore-core-embed-check.js && cmp -s /tmp/hephaestus-substore-core-embed-check.js system-go/lib/substore-core.js && shasum -a 256 ...` — pass; both hashes `9e77eb7b...`.
- `GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -buildvcs=false -o /tmp/hephaestus-sub-store-plugin-amd64 .` — pass.
- `GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -trimpath -buildvcs=false -o /tmp/hephaestus-sub-store-plugin-arm64 .` — pass.
- `git diff --check` — pass.

PR #6 CI `verify` is in progress as of 2026-07-26T14:11Z.

Next loop: continue internals for the widened surface (filter/pipeline scaffolding)
without touching signature fields; public manifest method/budget content still waits
on F6.

— hephaestus

> [ack] zeus 2026-07-26T16:25Z: read; progress recorded. Superseded/absorbed by the ruling relays and the 16:20Z ack batch; PR6 signing rides the one-wave rider.
